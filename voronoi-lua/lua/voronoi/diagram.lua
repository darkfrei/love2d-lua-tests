-- diagram.lua

print ('loaded', ...)

local diagram = {}
local utils = require("lua.voronoi.utils")
local eventQueue = require("lua.voronoi.eventQueue")
local beachLine = require("lua.voronoi.beachLine")

-- initialize a new diagram
function diagram.new(cells, sites)
--	error ('using')
	-- structure for diagram
	local newDiagram = { 
		cells = cells, 
		sites = sites, 
		edges = {}, 
		vertices = {},
		polygonVertices = nil, -- list of vertices for rendering
		boundingPolygon = nil, -- list of polygon vertices
		beachLine = beachLine.new(),
		eventQueue = eventQueue.new(sites),
		eventsDone = 0,
	}

	setmetatable(newDiagram, { __index = diagram })
	print ('newDiagram')
	return newDiagram
end

-- set an initial bounding polygon
function diagram:setBoundingPolygon(boundingPolygon)
--	error ('using')
	self.boundingPolygon = boundingPolygon -- list of polygon vertices

	-- assign each vertex to the nearest cell
	for _, vertex in ipairs(boundingPolygon) do
		local closestCells = utils.closestCellsToVertex(vertex, self.cells)

		for _, closestCell in ipairs(closestCells) do
			closestCell:addVertex(vertex) -- add vertex to cell
		end
	end

	-- prepare vertices for rendering
	self.polygonVertices = utils.getPolygonVertices(self.boundingPolygon)
end

---- process all events
--function diagram:solve()
--	error ('using')
--	while #self.eventQueue.queue > 0 do
--		self:step()
--	end
--	print("eventsDone:", self.eventsDone)
--end

-- process a single event
function diagram:step()
--	error ('using')
	if #self.eventQueue.queue == 0 then
		print("No events left to process.")
		return false
	end

	local event = self.eventQueue:pop()
	print("------------------------ event #" .. self.eventsDone + 1, 
		event.type, "event.y:" .. event.y)

	if event.type == "site" then
		self.beachLine:insertPoint(self.eventQueue, event)
	elseif event.type == "circle" then
		self.beachLine:handleCircleEvent(self, event)
	end

	self.eventsDone = self.eventsDone + 1
	return true
end

---- generate a new diagram
--function diagram.generate(siteCoordinates, boundingPolygon)
--	error ('using')
--	local sites = require("lua.voronoi.sites").new(siteCoordinates, boundingPolygon)
--	local cells = require("lua.voronoi.cells").new(siteCoordinates)
--	local newDiagram = diagram.new(cells, sites)
--	newDiagram:setBoundingPolygon(boundingPolygon)
--	return newDiagram
--end

function diagram:solve()
--	error ('using')
	local eventQueue = self.eventQueue
	local beachLine = self.beachLine
	assert(eventQueue.boundingPolygon and type(eventQueue.boundingPolygon) == "table", "Error: boundingPolygon is required and must be a table.")

	-- process events from the event queue
	while #eventQueue.queue > 0 do
		local event = eventQueue:pop()
		print('------------------------ event #' .. eventQueue.eventsDone + 1,
			event.type, 'event.y:' .. event.y)

		-- handle site event
		if event.type == "site" then
			beachLine:insertPoint(eventQueue, event)
			eventQueue.eventsDone = eventQueue.eventsDone + 1
			-- handle circle event
		elseif event.type == "circle" then
			beachLine:handleCircleEvent(self, event)
			eventQueue.eventsDone = eventQueue.eventsDone + 1
		end
	end

	print('eventsDone:', eventQueue.eventsDone)
end

return diagram
