print ('loaded', ...)
local beachline = {}
local utils = require("lua.voronoi.utils")

local DBL_MIN = 1/(2^37)

-- initialize the beach line structure with metatable
function beachline.new()
	local instance = { 
		arcs = {},
	} -- list of arcs
	setmetatable(instance, { __index = beachline }) -- set metatable
	print("new beachline")
	return instance
end

beachline.counter = utils.createCounter()


--new:
--------------------

-- checks if the beach line is empty
-- returns true if the beach line is empty, false otherwise
function beachline:isEmpty()
	return #self == 0  -- checks if the beach line has any elements (if the length is zero)
end

-- creates a new arc for the beachline, representing a parabola
-- [site] — the site associated with the arc (contains x and y coordinates)
function beachline:newArc (site, rightX)
	local arc = {
		x = site.x,
		y = site.y,
		site = site,  -- the site that this arc corresponds to
		endEvent = nil,
		rightX = rightX,
		rightY = nil, -- optional, sometimes negative huge
	}

	-- return the new arc
	return arc
end


-- finds the arc that needs to be split (if any)
-- [event] — the current event that is being processed, which contains the site to be added
function beachline:getArcToSplit(site)
	print ('beachline, adding new site:', site.x, site.y)
	for i = 1, #self do
		local arc = self[i]
		print ('check arc #'..i, 'rightX: ' .. arc.rightX)

		-- [check if this arc needs to be split]
		-- check if the site is to the right of the arc's rightX
		if site.x < arc.rightX then
			-- the right arc to split
			if arc.y == site.y then
				-- special case: same height
				-- if the arc is at the same height as the site, insert after it (special case)
				print ('beachline: horizontally aligned')
				return arc, 'insertAfter'
			elseif arc.y < site.y then
				-- ok, standard case
				-- if the site is below the arc, we need to split the arc
				print ('beachline: default case')
				return arc, 'split'
			end
		elseif arc.rightX == site.x then
-- special case: 		
-- check for special case when site is vertically aligned with arc's rightX
			print ('beachline: vertically aligned')
			return arc, 'insertAfter'
		end
	end

-- [if no intersection is found, return last and the action type as insertAfter]

	return self[#self], 'insertAfter'
end


-- inserts a new arc after the given arc
-- [prevArc] — the arc that we want to insert the new arc after
-- [newArc] — the new arc to be inserted
function beachline:insertAfter(prevArc, newArc)
	-- [find the index of prevArc in the beachline]
	local prevIndex = nil
	for i, arc in ipairs(self) do
		if arc == prevArc then
			prevIndex = i
			break
		end
	end

	-- [if prevArc is found, insert the new arc after it]
	if prevIndex then
		local oldRightX = prevArc.rightX
		if prevArc.y == newArc.y then
			print ('beachline:insertAfter', 'horizontally aligned')
			local x = (prevArc.x + newArc.x)/2
			newArc.leftX = x
			prevArc.rightX = x
			
			newArc.rightX = oldRightX
		elseif self[prevIndex+1] then
			local nextArc = self[prevIndex+1]
			local x = newArc.x
			newArc.rightX = x + DBL_MIN
			newArc.leftX = x - DBL_MIN
			nextArc.leftX = newArc.rightX
			prevArc.rightX = newArc.leftX
		end
		
		
		table.insert(self, prevIndex + 1, newArc)  -- insert after the prevArc
	else
		error("previous arc not found in the beachline")
	end
end


-- splits an existing arc into two arcs at the given site
-- [prevArc] — the arc to be split
-- [newArc] — the new arc created as a result of the split
function beachline:splitArc(prevArc, newArc2)
	-- [find the index of prevArc in the beachline]
	local prevIndex = nil
	for i, arc in ipairs(self) do
		if arc == prevArc then
			prevIndex = i
			break
		end
	end

	-- [if prevArc is found, split it]
	if prevIndex then
		-- [remove the previous arc from the beachline]
		table.remove(self, prevIndex)

		local newArc1 = self:newArc(prevArc.site, newArc2.x - DBL_MIN)
		newArc1.leftX = prevArc.leftX
		
		newArc2.leftX = newArc1.rightX
		newArc2.rightX = newArc2.x + DBL_MIN
		
		local newArc3 = self:newArc(prevArc.site, prevArc.rightX)
		newArc3.leftX = newArc2.rightX

		-- [insert the new arcs]
		table.insert(self, prevIndex, newArc3)
		table.insert(self, prevIndex, newArc2)
		table.insert(self, prevIndex, newArc1)

		-- {... , newArc1, newArc2, newArc3, ...}
		print ('amount arcs: '.. #self)
		for i, arc in ipairs (self) do
			print (i, 'rightX:' .. arc.rightX)
			print (i, 'leftX:' .. arc.leftX)
		end
	else
		error("previous arc not found in the beachline")
	end
end





-- update the beach line based on the current event's height (y-coordinate)
function beachline:update(diagram, eventY)
	print ('### beachline:update', 'eventY: '..eventY)
	-- loop through each arc in the beach line
	local xs = {}
	for i = 1, #self-1 do
		local arc1 = self[i] -- left arc
		local arc2 = self[i+1] -- right arc
		local x, y = utils.arcArcCrossing (arc1, arc2, eventY)
		print (i, 'arcArcCrossing')
		print ('arc1:', arc1.x, arc1.y, 'arc2:', arc2.x, arc2.y)
		print ('x:', x, 'y:', y)
		if not (arc1.rightX == x) then
			print ('beachline:update right x: '..arc1.rightX..' --> '..x)
			arc1.rightX = x
		end
		
		if not (arc2.leftX == x) then
			print ('beachline:update left x: '..arc2.leftX..' --> '..x)
			arc2.leftX = x
		end
		
		if not (arc1.rightY == y) then
			print ('beachline:update y: '..arc1.rightX..' --> '..x)
			arc1.rightY = y
		end
		table.insert (xs, x)
	end
	
	
end


-- returns the current state of the beach line for the given directrix
-- [dirY] — the Y-coordinate of the current directrix
function beachline:getCurrentBeachLine(eventY)
	local arcLines = {}

	-- iterate over all arcs in the beachline
	for i, arc in ipairs(self) do
		print ('beachline:getCurrentBeachLine', i)
		local leftX = arc.leftX
		local rightX = arc.rightX
--		local rightY = arc.rightY
		local dx = rightX - leftX

		local steps = 32

		
		print ('beachline:getCurrentBeachLine', 'dx: '..dx)
		
		if dx > 2 then
			local line = {}
			for i = 0, steps do
				local x = leftX + dx * i / steps
				local y = utils.evaluateYbyX(arc, x, eventY)
				table.insert (line, x)
				table.insert (line, y)
			end
			table.insert (arcLines, line)

		else
			-- wip
			-- must be {arc.x, arc.y, rightX, rightY}
			local rightArc = self[i+1]
			local x = arc.x
			local y = utils.evaluateYbyX(rightArc, x, eventY)

			local line = {arc.x, arc.y, x, y}
			table.insert (arcLines, line)
		end
		
		
	end
	print ('created #arcLines:', #arcLines)
	return arcLines
end



--old:
--------------------
-------------------

--[[

function beachline:findArc(x)
	-- arcs are always sorted
	for i, arc in ipairs(self.arcs) do
		-- If x is strictly within the arc's range
		if x < (arc.rightX or math.huge) then
			return arc, nil -- return the crossing arc
			-- If x is exactly on the right boundary of this arc
		elseif x == arc.rightX then
			local leftArc = arc
			return nil, leftArc -- return left neighboring arc
		end
	end
end


function beachline:getLeftNeighbor(arc1)
	for i, arc2 in ipairs(self.arcs) do
		if arc1 == arc2 then
			return self.arcs[i-1]
		end
	end
end


function beachline:getRightNeighbor(arc1)
	for i, arc2 in ipairs(self.arcs) do
		if arc1 == arc2 then
			return self.arcs[i+1]
		end
	end
end


function beachline:checkNeighborArcs(eventQueue, arc)
	local leftNeighbor = self:getLeftNeighbor(arc)
	local rightNeighbor = self:getRightNeighbor(arc)

	if leftNeighbor and rightNeighbor then
		error ('adding circle event')
		eventQueue:addCircleEvent(leftNeighbor, arc, rightNeighbor)
	end
end





-- create a new arc for a given site
function beachline:createNewArc(site, rightX)
	local arc =  {
		site = site, -- reference to the site defining the arc
		rightX = rightX, -- x-coordinate of the right boundary of the arc
		rightY = nil,  -- y-coordinate of the right boundary of the arc
		-- parabola focus:
		x = site.x,
		y = site.y,
		index = beachline.counter() -- unique index for each arc
	}
	print ('created arc', '#'..arc.index)
	return arc
end

function beachline:insertArcAfter(leftArc, newArc)
	-- find the index of the leftArc
	for i, arc in ipairs(self.arcs) do
		if arc == leftArc then
			-- insert the new arc after the leftArc
			table.insert(self.arcs, i + 1, newArc)
			break
		end
	end
end



function beachline:showBeachLine()
	-- print the number of arcs in the beach line
	print("Beach line has " .. #self.arcs .. " arcs:")

	-- iterate through each arc and print relevant details
	for i, arc in ipairs(self.arcs) do
		-- print arc details: its site, x, and y coordinates
		print(string.format("Arc %d: Focus (x: %.2f, y: %.2f)", i, arc.x, arc.y))
		print(string.format("Arc index: %d rightX %.2f", arc.index, (arc.rightX or math.huge)))
	end
end


-- add a site to the beach line
function beachline:addSiteToBeachLine(eventQueue, site)
	local directrixY = site.y
	if #self.arcs == 0 then
		local firstArc = self:createNewArc(site, math.huge)
		table.insert(self.arcs, firstArc)
		print ('added first arc', firstArc.x, firstArc.y)
		return
	end

	-- find the crossing arc or the gap to insert the site
	local crossingArc, leftArc = self:findArc(site.x)

	local newArc = self:createNewArc(site, site.x)

	if crossingArc then
		if crossingArc.y == directrixY then
			print ('special case: crossingArc.y == directrixY')
			if newArc.x > crossingArc.x then
				self:insertArcAfter (crossingArc, newArc)
			elseif newArc.x < crossingArc.x then
				print ('!!!!!!!!!!!! wrong sorted X')
			else
				print ('!!!!!!!!!!!! same focus point!')
			end
			local x = (newArc.x+crossingArc.x)/2
			local y = directrixY

			addTestPoint (x, y)

			local dx = crossingArc.x-site.x
			local dy = 0

			eventQueue:addRayEvent(x, y, -dy, dx) -- up directed ray
			eventQueue:addRayEvent(x, y, dy, -dx) -- dow directed ray

			return
		end

		print ('create a new arc #'..newArc.index..' in the arc', '#'..crossingArc.index)
		self:splitInsertArc(eventQueue, crossingArc, newArc)

		-- calculate intersection point between crossingArc and newArc
		local x = site.x
		local y = utils.evaluateYbyX(crossingArc, x, directrixY)

		addTestPoint (x, y)

		-- direction of the ray (perpendicular to the vector between the foci)

		local dx = crossingArc.x-site.x -- direction in x (horizontal difference)
		local dy = crossingArc.y-site.y -- direction in y (vertical difference)

		-- add ray event to the event queue (to find crossing with boundingPolygon)
		-- create two ray events: one left, one right
		assert(eventQueue.boundingPolygon and type(eventQueue.boundingPolygon) == "table", "Error: boundingPolygon is required and must be a table.")

		eventQueue:addRayEvent(x, y, -dy, dx) -- left ray
		eventQueue:addRayEvent(x, y, dy, -dx)   -- right ray



	elseif leftArc then
		print ('!!!! special case: create a new arc between arcs')
		leftArc.rightX = site.x
		self:insertArcAfter(leftArc, newArc)
	else
		print ('ERROR! No arc inserted')
	end

	self:showBeachLine()
end



-- split an existing arc and insert a new arc in its place
function beachline:splitInsertArc(eventQueue, crossingArc, newArc)
	-- create left and right arcs as copies of crossingArc
	local leftArc = self:createNewArc(crossingArc.site, newArc.x)
	local rightArc = self:createNewArc(crossingArc.site, crossingArc.rightX)

	-- replace crossingArc in the beach line with leftArc, newArc, and rightArc
	for i, arc in ipairs(self.arcs) do
		if arc == crossingArc then
			table.remove(self.arcs, i) -- remove the crossing arc
			table.insert(self.arcs, i, rightArc) -- insert the right arc
			table.insert(self.arcs, i, newArc) -- insert the new arc
			table.insert(self.arcs, i, leftArc) -- insert the left arc
			break -- exit the loop
		end
	end

	-- add circle events for neighboring arcs only
	-- wip
	self:checkNeighborArcs(eventQueue, leftArc)
	self:checkNeighborArcs(eventQueue, rightArc)
end


-- insert a site into the beach line
-- called from init.lua: beachline:insertPoint (diagram, event)
function beachline:insertPoint(eventQueue, event)
	-- update the beach line based on the current sweep line:
	self:update(eventQueue, event.y)
	-- add the site to the beach line:
	self:addSiteToBeachLine(eventQueue, event.site)
end


-- handle circle events
function beachline:handleCircleEvent(diagram, event)
	local vertex = { x = event.x, y = event.y } -- vertex coordinates
	diagram:addVertex(vertex) -- add vertex to diagram
end


--]]


return beachline
