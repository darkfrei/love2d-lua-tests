-- load pathfinding module
local pathfinding = require("circular-obstacle-pathfinding")

-- game setup
function love.load()
	love.window.setMode(800, 600)

	circles = {
		{id = 1, x = 287, y = 299, radius = 55},
		{id = 2, x = 644, y = 460, radius = 40},
		{id = 3, x = 175, y = 149, radius = 40},
		{id = 4, x = 690, y = 563, radius = 35},
		{id = 5, x = 452, y = 346, radius = 30},
		{id = 6, x = 515, y = 440, radius = 30}
	}

	start = {x = 30, y = 74}
	goal = {x = 771, y = 575}

	path, diagram = pathfinding.circularObstaclePathfinding(circles, start, goal)
end

-- draw circles, path, and graph
function love.draw()
	-- draw all circles as obstacles
	love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
	for _, circle in ipairs(circles) do
		love.graphics.circle("fill", circle.x, circle.y, circle.radius)
	end

	-- draw centers of circles
	love.graphics.setColor(1, 1, 1)
	for _, circle in ipairs(circles) do
		love.graphics.circle("fill", circle.x, circle.y, 3)
		love.graphics.print(circle.id, circle.x+5, circle.y+5)
	end

	-- draw start and goal points
	love.graphics.setColor(0, 1, 0)
	love.graphics.circle("fill", start.x, start.y, 5)
	love.graphics.setColor(1, 0, 0)
	love.graphics.circle("fill", goal.x, goal.y, 5)

	love.graphics.setColor(1, 1, 0)
	if diagram and diagram.debugLines then
		for i, line in ipairs (diagram.debugLines) do
			love.graphics.line (line)
		end
	end

end