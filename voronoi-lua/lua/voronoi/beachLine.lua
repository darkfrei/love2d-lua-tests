print ('loaded', ...)
local beachLine = {}
local utils = require("lua.voronoi.utils")

-- initialize the beach line structure with metatable
function beachLine.new()
	local instance = { 
		arcs = {},
	} -- list of arcs
	setmetatable(instance, { __index = beachLine }) -- set metatable
	print("new beachLine")
	return instance
end

beachLine.counter = utils.createCounter()


-- update the beach line based on the current event's height (y-coordinate)
function beachLine:update(diagram, eventY)
	-- loop through each arc in the beach line
	local xs = {}
	print ('beachLine:update, eventY', eventY)
	for i = 1, #self.arcs-1 do
		local arc1 = self.arcs[i] -- left arc
		local arc2 = self.arcs[i+1] -- right arc
		local x, y = utils.arcArcCrossing (arc1, arc2, eventY)
		print (i, 'arcArcCrossing')
		print ('arc1:', arc1.x, arc1.y, 'arc2:', arc2.x, arc2.y)
		print ('x:', x, 'y:', y)
		arc1.rightX = x
		arc1.rightY = y
		table.insert (xs, x)
	end
--	print ('updated parabola x:')
--	print (table.concat (xs, ', '))
end

function beachLine:findArc(x)
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


function beachLine:getLeftNeighbor(arc1)
	for i, arc2 in ipairs(self.arcs) do
		if arc1 == arc2 then
			return self.arcs[i-1]
		end
	end
end


function beachLine:getRightNeighbor(arc1)
	for i, arc2 in ipairs(self.arcs) do
		if arc1 == arc2 then
			return self.arcs[i+1]
		end
	end
end


function beachLine:checkNeighborArcs(eventQueue, arc)
	local leftNeighbor = self:getLeftNeighbor(arc)
	local rightNeighbor = self:getRightNeighbor(arc)

	if leftNeighbor and rightNeighbor then
		error ('adding circle event')
		eventQueue:addCircleEvent(leftNeighbor, arc, rightNeighbor)
	end
end





-- create a new arc for a given site
function beachLine:createNewArc(site, rightX)
	local arc =  {
		site = site, -- reference to the site defining the arc
		rightX = rightX, -- x-coordinate of the right boundary of the arc
		rightY = nil,  -- y-coordinate of the right boundary of the arc
		-- parabola focus:
		x = site.x,
		y = site.y,
		index = beachLine.counter() -- unique index for each arc
	}
	print ('created arc', '#'..arc.index)
	return arc
end

function beachLine:insertArcAfter(leftArc, newArc)
	-- find the index of the leftArc
	for i, arc in ipairs(self.arcs) do
		if arc == leftArc then
			-- insert the new arc after the leftArc
			table.insert(self.arcs, i + 1, newArc)
			break
		end
	end
end



function beachLine:showBeachLine()
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
function beachLine:addSiteToBeachLine(eventQueue, site)
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
function beachLine:splitInsertArc(eventQueue, crossingArc, newArc)
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
-- called from init.lua: beachLine:insertPoint (diagram, event)
function beachLine:insertPoint(eventQueue, event)
	-- update the beach line based on the current sweep line:
	self:update(eventQueue, event.y)
	-- add the site to the beach line:
	self:addSiteToBeachLine(eventQueue, event.site)
end


-- handle circle events
function beachLine:handleCircleEvent(diagram, event)
	local vertex = { x = event.x, y = event.y } -- vertex coordinates
	diagram:addVertex(vertex) -- add vertex to diagram
end

return beachLine
