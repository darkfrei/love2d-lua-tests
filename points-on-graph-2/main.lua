-- main.lua
-- https://youtu.be/DDE6eMN-n-Q

love.window.setMode (1980, 1080)

local diagram = require("diagram")
local data = require("data")
local points = require("points")


local particles = {}



local paths = {
	{startId = 79, endId = 61},
	{startId = 78, endId = 62},
	{startId = 77, endId = 58},
	{startId = 76, endId = 59},
	{startId = 83, endId = 72}, -- replaced 83 with 82 since 83 is missing
}

--local spawnInterval = 0.05  -- spawn a particle every 0.2 seconds
--local spawnTimer = 0      -- timer to track spawn intervals
--local particleSpeed = 60  -- particle movement speed (pixels per second)

-- helper function to find an edge between two nodes
--local function findEdgeBetween(fromId, toId)
--	for _, edge in pairs(data.edges) do
--		if edge.nodeIndices[1] == fromId and edge.nodeIndices[#edge.nodeIndices] == toId then
--			return edge
--		end
--	end
--	return nil
--end

function love.load()
	-- initialize the diagram with nodes and edges
	diagram.initialize(data.nodes, data.edges)
	points.initialize(paths)
end

function love.update(dt)
	if dt > 1/50 then dt = 1/50 end
	points.update(dt, paths)
end

function love.draw()
	-- clear the screen
	love.graphics.setBackgroundColor(0.95, 0.95, 0.95) -- light gray background

	-- draw the diagram (edges, nodes, and labels)
	diagram.draw()

	-- draw moving particles
	points.draw()
end