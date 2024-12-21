print ('loaded', ...)

local eventQueue = {}
local utils = require("lua.voronoi.utils")

eventQueue.eventsDone = 0

-- initialize new event queue
function eventQueue.new(sites)
	local events = {
		queue = {},
		type = "eventQueue"
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

	-- set the metatable to allow eventQueue methods to be called on events
	setmetatable(events, { __index = eventQueue })

	events:sortQueue()


	return events
end

-- insert an event into the init.lua
function eventQueue:addEvent(event)
	table.insert(self.queue, event) -- add event
end

-- remove the next event from the queue
function eventQueue:pop()
	if #self.queue > 0 then
		-- extract the first event from the list
		local event = table.remove(self.queue, 1)
		return event
	end
	return nil -- extract the first event from the list

end

-- method to sort the event queue by y-coordinate
function eventQueue:sortQueue()
	table.sort(self.queue, function(a, b) return a.y < b.y end)
end


-- remove the next event from the queue
function eventQueue:getAmount()
	return #self.queue
end

--- wip

function eventQueue:addCircleEvent(leftArc, middleArc, rightArc, diagram)
	local circleCenter, circleY = utils.checkCircleEvent(leftArc, middleArc, rightArc)
	if circleCenter then
		local event = {
			type = "circle",
			y = circleY,
			x = circleCenter.x,
			arc = middleArc,
		}
		table.insert(self.queue, event)
		table.sort(self.queue, function(a, b) return a.y < b.y end)
	end
end

-- called from beachLine:addSiteToBeachLine(eventQueue, site)
-- eventQueue:addRayEvent(x, y, -dy, dx)
function eventQueue:addRayEvent(x, y, dx, dy)
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


return eventQueue
