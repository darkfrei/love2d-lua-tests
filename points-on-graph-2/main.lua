-- main.lua
-- Moving Points on Graph 2-06
-- https://youtu.be/6T0b0F2nMYQ

love.window.setMode (1980, 1080)

local diagram = require("diagram")
local data = require("data")
local points = require("points")


local particles = {}



local paths = {
	{startId = 77, endId = 61},
	{startId = 76, endId = 62},
	{startId = 79, endId = 59},
	{startId = 78, endId = 72},
	{startId = 83, endId = 58},
	{startId = 90, endId = 91},
--	{startId = 83, endId = 72},
}


function love.load()
	-- initialize the diagram with nodes and edges
	diagram.initialize(data.nodes, data.edges)
	points.initialize(paths)
end

function love.update(dt)
	if dt > 1/50 then dt = 1/50 end
	points.update(dt, paths)
	if love.keyboard.isDown ('space') then
		for i = 0, 100 do
			points.update(dt, paths)
		end
	end
end

function love.draw()
	-- clear the screen
	love.graphics.setBackgroundColor(0.95, 0.95, 0.95) -- light gray background

	-- draw the diagram (edges, nodes, and labels)
	diagram.draw()

	-- draw moving particles
	points.draw()

	love.graphics.setColor (0,0,0)
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
	love.graphics.print("Points: "..tostring(#points), 10, 10+14)
end

function love.keypressed (key, scancode)
	if key == 'f1' then
		logEnabled = not logEnabled
	end
end