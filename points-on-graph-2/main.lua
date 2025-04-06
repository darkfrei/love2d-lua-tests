-- main.lua

local diagram = require("diagram")
local data = require("data")

local particles = {}

-- initialize the diagram with nodes and edges
diagram.initialize(data.nodes, data.edges)

local paths = {
	{startId = 79, endId = 61},
	{startId = 78, endId = 62},
	{startId = 77, endId = 58},
	{startId = 76, endId = 59},
	{startId = 83, endId = 72}, -- replaced 83 with 82 since 83 is missing
}

local spawnInterval = 0.2  -- spawn a particle every 0.2 seconds
local spawnTimer = 0      -- timer to track spawn intervals
local particleSpeed = 60  -- particle movement speed (pixels per second)

-- helper function to find an edge between two nodes
local function findEdgeBetween(fromId, toId)
	for _, edge in pairs(data.edges) do
		if edge.nodeIndices[1] == fromId and edge.nodeIndices[#edge.nodeIndices] == toId then
			return edge
		end
	end
	return nil
end

function love.load()
	-- calculate shortest paths and edges for all pairs
	for i, route in ipairs(paths) do
		local path, distance = diagram.findShortestPath(route.startId, route.endId)
		if path then
			route.path = path
			route.distance = distance
			-- collect edges for the path
			route.edges = {}
			for j = 1, #path - 1 do
				local edge = findEdgeBetween(path[j], path[j + 1])
				if edge then
					table.insert(route.edges, edge)
				else
					print("no direct edge from " .. path[j] .. " to " .. path[j + 1])
				end
			end
		else
			print("no path found from " .. route.startId .. " to " .. route.endId)
			route.path = {route.startId}
			route.edges = {}
		end
	end
end

function love.update(dt)
	-- update spawn timer
	spawnTimer = spawnTimer + dt
	if spawnTimer >= spawnInterval then
		spawnTimer = spawnTimer - spawnInterval
		-- generate a new particle for each path
		for _, route in ipairs(paths) do
			if #route.path > 1 then
				local startNode = data.nodes[route.path[1]]
				table.insert(particles, {
						edges = route.edges,        -- list of path edges
						currentEdgeIdx = 1,         -- index of the current edge
						distanceTraveled = 0,       -- distance traveled along current edge
						x = startNode.x,            -- current x position
						y = startNode.y,            -- current y position
						speed = particleSpeed       -- movement speed
					})
			end
		end
	end

	-- update particle positions
	for i = #particles, 1, -1 do
		local p = particles[i]
		if p.currentEdgeIdx > #p.edges then
			-- particle reached the end of the path, remove it
			table.remove(particles, i)
		else
			local edge = p.edges[p.currentEdgeIdx]
			local line = edge.line
			local totalLength = edge.length
			local totalSegments = (#line / 2) - 1 -- number of segments in edge.line

			-- update distance traveled based on constant speed
			p.distanceTraveled = p.distanceTraveled + p.speed * dt

			-- calculate progress along edge.line based on distance
			local t = p.distanceTraveled / totalLength
			if t >= 1 then
				-- move to the next edge
				p.distanceTraveled = 0
				p.currentEdgeIdx = p.currentEdgeIdx + 1
				if p.currentEdgeIdx <= #p.edges then
					-- set starting position of the next edge
					local nextEdge = p.edges[p.currentEdgeIdx]
					p.x = nextEdge.line[1]
					p.y = nextEdge.line[2]
				end
			else
				-- calculate progress along edge.line based on distance
				local d = p.distanceTraveled
				local segmentLengths = edge.segmentLengths
				local cumulative = edge.segmentCumulative
				local line = edge.line

				local segmentIdx = 1
				while segmentIdx <= #segmentLengths and d > cumulative[segmentIdx] do
					segmentIdx = segmentIdx + 1
				end

				if segmentIdx > #segmentLengths then
					p.x = line[#line - 1]
					p.y = line[#line]
				else
					local segStart = cumulative[segmentIdx - 1] or 0
					local segLength = segmentLengths[segmentIdx]
					local t = (d - segStart) / segLength

					local i = (segmentIdx - 1) * 2 + 1
					local x1, y1 = line[i], line[i + 1]
					local x2, y2 = line[i + 2], line[i + 3]
					p.x = x1 + (x2 - x1) * t
					p.y = y1 + (y2 - y1) * t
				end
			end
		end
	end
end

function love.draw()
	-- clear the screen
	love.graphics.setBackgroundColor(0.95, 0.95, 0.95) -- light gray background

	-- draw the diagram (edges, nodes, and labels)
	diagram.draw()

	-- draw moving particles
	for _, p in ipairs(particles) do
		love.graphics.setColor(1, 0, 0)
		love.graphics.circle("fill", p.x, p.y, 6)
		love.graphics.setColor(0, 0, 0)
		love.graphics.circle("line", p.x, p.y, 6)
	end
end