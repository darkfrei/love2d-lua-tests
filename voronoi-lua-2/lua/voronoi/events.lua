print ('loaded', ...)

local utils = require("lua.voronoi.utils")

local events = {}
events.__index = events  -- set the __index for the metatable


-- creates a new event queue
-- initializes an empty list to store events
function events.newQueue()
	local self = setmetatable({}, events)  -- create a new object and set the metatable
	self.queue = {}  -- stores events in the queue (e.g., site and circle events)
	return self
end


-- method to add an event to the queue
-- adds an event to the queue and maintains the proper order
function events:add(event)
	table.insert(self.queue, event)  -- insert event at the end of the queue
	utils.sortYX(self.queue)  -- sort the queue using the provided sort function
end


-- processes the site event for Voronoi diagram, adding parabolas to the beach line
-- [event] — the site event object containing the site data (x, y)
-- [voronoi] — the Voronoi object containing the diagram and beach line
local function processSiteEvent(event, voronoi)
	
	if not (voronoi.sweepLineY == event.y) then
		voronoi.sweepLineY = event.y
		voronoi.beachline:update(voronoi, event.y)
	end
	
--	print ('processSiteEvent')
	local beachline = voronoi.beachline
	
	-- [handle the first site event]
	if beachline:isEmpty() then
		-- [create a new parabola for the first site]
		print ('voronoi.diagram.rightSide', voronoi.diagram.rightSide)
		local arc = beachline:newArc (event.site, voronoi.diagram.rightSide)
		print ('voronoi.diagram.leftSide', voronoi.diagram.leftSide)
		arc.leftX = voronoi.diagram.leftSide
		table.insert(beachline, arc)
		print ('added first arc to the beach line:', #beachline)
		return
	end

	-- [create new arc for the new site]
	local newArc = beachline:newArc(event.site, nil)

	-- [find the arc to insert the new arc next to]
	local prevArc, insertType = beachline:getArcToSplit(event.site)


-- [check the insert type]
	if insertType == 'split' then
		-- [split the previous arc and insert new arc]
		beachline:splitArc(prevArc, newArc)
		print('split an arc and inserted the new one')
	elseif insertType == 'insertAfter' then
		-- [insert the new arc after the previous arc]
		beachline:insertAfter(prevArc, newArc)
		print('inserted new arc after the previous one')
	else
		-- [handle any edge case or error]
		print('unexpected insert type:', insertType)
	end
end



function events:newSiteEvent(site)
	-- [create a new site event] — creates a new site event with the provided site object
	local newEvent = {
		x = site.x,        -- [site x-coordinate] — x-coordinate of the site
		y = site.y,        -- [site y-coordinate] — y-coordinate of the site
		site = site,       -- [the site object itself] — the full site object
		-- [process the site event method] — method to process the site event:
		process = processSiteEvent,  
		type = 'site',
	}

	-- [add the new event to the event queue] — adds the new site event to the queue for processing
	self:add(newEvent)
	print ('added site event', #self.queue)
end



-- method to pop the next event from the queue
-- removes and returns the first event in the queue
function events:pop()
	return table.remove(self.queue, 1)  -- removes and returns the first event
end


-- method to check if the queue is empty
-- returns true if the queue has no events
function events:isEmpty()
	return #self.queue == 0  -- returns true if the queue is empty
end

---------------------------------


--[[

-- initialize new event queue
function events.new(sites)
	local events = {
		queue = {},
		type = "events"
	}

	-- Add site events to the queue based on sites' coordinates
	for _, site in ipairs(sites) do
		local event = {
			type = "site",    -- event type (could be 'site' or 'circle')
			site = site,      -- reference to the site associated with the event
			x = site.x,       -- x-coordinate of the site
			y = site.y,       -- y-coordinate of the site
		}
		table.insert(events.queue, event)
	end

	print ('added site events:', #events.queue)

	-- sort the events (optional: sorting by y-coordinate or x-coordinate)
	table.sort(events.queue, function(a, b)
			return a.y < b.y
		end)

	-- set the metatable to allow events methods to be called on events
	setmetatable(events, { __index = events })

	events:sortQueue()


	return events
end

-- insert an event into the init.lua
function events:addEvent(event)
	table.insert(self.queue, event) -- add event
end

-- remove the next event from the queue
function events:pop()
	if #self.queue > 0 then
		-- extract the first event from the list
		local event = table.remove(self.queue, 1)
		return event
	end
	return nil -- extract the first event from the list

end

-- method to sort the event queue by y-coordinate
function events:sortQueue()
	table.sort(self.queue, function(a, b) return a.y < b.y end)
end


-- remove the next event from the queue
function events:getAmount()
	return #self.queue
end

--- wip

function events:addCircleEvent(leftArc, middleArc, rightArc, diagram)
	local circleCenter, circleY = utils.checkCircleEvent(leftArc, middleArc, rightArc)
	if circleCenter then
		local event = {
			type = "circle",
			y = circleY,
			x = circleCenter.x,
			arc = middleArc,
		}
		table.insert(self.queue, event)
--		table.sort(self.queue, function(a, b) return a.y < b.y end)
	end
end

-- called from beachline:addSiteToBeachLine(events, site)
-- events:addRayEvent(x, y, -dy, dx)
function events:addRayEvent(x, y, dx, dy)
	-- create a ray object with position (x, y) and direction (dx, dy)
	local ray = {x = x, y = y, dx = dx, dy = dy}

	-- get the bounding polygon from the event queue
	local boundingPolygon = self.boundingPolygon

	assert(boundingPolygon and type(boundingPolygon) == "table", "Error: boundingPolygon is required and must be a table.")

	-- find the intersection point of the ray with the bounding polygon
	local bx, by = utils.findRayPolygonCrossing(ray, boundingPolygon)

	-- visualize the ray and its intersection using addTestLine
	local c = 0.5
	addTestLine(x, y, bx, by, {c,c,c,c})
end

--]]

return events
