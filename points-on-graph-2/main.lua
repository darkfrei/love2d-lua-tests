-- main.lua
-- https://youtu.be/l7tz9jouJ-I

love.window.setMode (1980, 1080)

local diagram = require("diagram")
local data = require("data")
local points = require("points")


local particles = {}



local paths = {
--	{startId = 79, endId = 61},
--	{startId = 78, endId = 62},
--	{startId = 77, endId = 58},
--	{startId = 76, endId = 59},
--	{startId = 83, endId = 72},
	{startId = 77, endId = 61},
	{startId = 76, endId = 62},
}


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