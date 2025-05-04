-- main.lua
-- Moving Points on Graph 2-10
-- https://youtu.be/DAaZp8H6oq4

love.window.setMode (1980, 1080)

local diagram = require("diagram")
local data = require("data")
local points = require("points")
local zoom = require("zoom")

local particles = {}



local routes = {
	{startId = 77, targetId = 61},
	{startId = 76, targetId = 62},
	{startId = 79, targetId = 59},
	{startId = 78, targetId = 72},
	{startId = 83, targetId = 58},
	{startId = 90, targetId = 91},
--	{startId = 83, targetId = 72},
}


function love.load()
	-- initialize the diagram with nodes and edges
	diagram.initialize(data.nodes, data.edges)
	points.initialize(routes)
end

function love.update(dt)
	if dt > 1/60 then dt = 1/60 end
	zoom.update(dt)
	
	points.update(dt, routes)
	if love.keyboard.isDown ('space') then
		for i = 0, 100 do
			points.update(dt, routes)
		end
	end
end

function love.draw()
	-- clear the screen
	love.graphics.setBackgroundColor(0.95, 0.95, 0.95) -- light gray background

	-- draw the diagram (edges, nodes, and labels)
	love.graphics.push()
	zoom.apply()
	diagram.draw()

	-- draw moving particles
	points.draw()
	love.graphics.pop()

	love.graphics.setColor (0,0,0)
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
	love.graphics.print("Points: "..tostring(#points), 10, 10+14)
end



function love.wheelmoved(x, y)
    zoom.wheelmoved(x, y)
end