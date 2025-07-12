-- https://github.com/darkfrei/love2d-lua-tests/tree/main/avoid-single-circle-path
-- 2025-07-12
local pathfinder = require("avoid-single-circle-path")

function love.load()
	start = {x = 250, y = 200}
	goal = {x = 700, y = 500}
	circle = {x = 400, y = 300, radius = 100}
	path = pathfinder.getPath(start, goal, circle)
end

function love.mousepressed (x, y)
	start.x = x
	start.y = y
	path = pathfinder.getPath(start, goal, circle)
end

function love.mousemoved(x, y)
	goal.x = x
	goal.y = y
	path = pathfinder.getPath(start, goal, circle)
end

function love.draw()
	-- draw circle obstacle
	love.graphics.setColor(1, 1, 1)
	love.graphics.circle("line", circle.x, circle.y, circle.radius)

	-- draw start (green) and goal (red) points
	love.graphics.setColor(0, 1, 0)
	love.graphics.circle("fill", start.x, start.y, 8)
	love.graphics.setColor(1, 0, 0)
	love.graphics.circle("fill", goal.x, goal.y, 8)

	-- draw path if found
	love.graphics.setLineWidth(3)
	love.graphics.setColor(0, 0.8, 1)
	if path then
		pathfinder.drawPath (path)
		love.graphics.setLineWidth(1)
	end


end