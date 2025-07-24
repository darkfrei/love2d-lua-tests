-- main.lua

-- load the pathfinder module
local pathfinder = require("circles-pathfinder")
debugPoints = {}

-- check if a point is inside any circle
local function distance(point1, point2)
	local dx = point2.x - point1.x
	local dy = point2.y - point1.y
	return math.sqrt(dx*dx + dy*dy)
end

local function isPointInsideCircles(point, circles)
	for _, circle in ipairs(circles) do
		local dist = distance(point, {x = circle.x, y = circle.y})
		if dist <= circle.radius then
			return true
		end
	end
	return false
end

-- initialize game state
function love.load()
	-- set window size (adjust as needed)
	love.window.setMode(800, 600)

	-- create canvas for distance visualization
	canvas = love.graphics.newCanvas(800, 600)

	-- fixed circles for testing
	circles = {
		{
			x = 200,
			y = 200,
			radius = 150
		},
		{
			x = 500,
			y = 250,
			radius = 80
		},
		{
			x = 460,
			y = 340,
			radius = 20
		},
	}

	startPoint = {x = 10, y = 50}
	goalPoint = {x = 530, y = 510}

	-- calculate initial shortest path
	shortestPath, length = pathfinder.getShortestPath(startPoint, goalPoint, circles)
	love.window.setTitle(tostring(length))


	-- draw distance canvas
	love.graphics.setCanvas(canvas)
	love.graphics.clear()
	local maxDistance = 1000
	for x = 0, 799 do
		for y = 0, 599 do
			local point = {x = x, y = y}
			if not isPointInsideCircles(point, circles) then
				local dist = distance(startPoint, point)
				if dist <= maxDistance then
					local intensity = 1 - dist / maxDistance
					love.graphics.setColor(intensity, intensity, intensity)
					love.graphics.points(x, y)
				end
			end
		end
	end
	love.graphics.setCanvas()
end

-- update start point on mouse press
function love.mousepressed(x, y)
	startPoint.x = x
	startPoint.y = y
	-- recalculate shortest path
	shortestPath, length = pathfinder.getShortestPath(startPoint, goalPoint, circles)
	love.window.setTitle(tostring(length))
end

-- update goal point on mouse movement
function love.mousemoved(x, y)
	goalPoint.x = x
	goalPoint.y = y
	-- recalculate shortest path
	shortestPath, length = pathfinder.getShortestPath(startPoint, goalPoint, circles)
	love.window.setTitle(tostring(length))
end

-- draw game elements
function love.draw()
	-- check if goalPoint is inside any circle
	if isPointInsideCircles(goalPoint, circles) then
		-- draw only circles and start/goal points if goal is inside a circle
		love.graphics.setLineWidth(2)
		love.graphics.setColor(1, 1, 1)
		for _, c in ipairs(circles) do
			love.graphics.circle('line', c.x, c.y, c.radius)
			love.graphics.circle('fill', c.x, c.y, 1)
			love.graphics.print(c.id, c.x, c.y)
		end
		love.graphics.setPointSize(8)
		love.graphics.setColor(1, 0, 0)
		love.graphics.points(startPoint.x, startPoint.y)
		love.graphics.points(goalPoint.x, goalPoint.y)
		return
	end



	-- draw canvas
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(canvas)

	-- draw all tangent lines
	love.graphics.setLineWidth(1)
	love.graphics.setColor(1, 1, 1, 0.2)
	for _, line in ipairs(pathfinder.globalTangentLines) do
		love.graphics.line(line)
	end

	love.graphics.setLineWidth(2)

	-- draw circles
	love.graphics.setColor(1, 1, 1)
	for _, c in ipairs(circles) do
		love.graphics.circle('line', c.x, c.y, c.radius)
		love.graphics.circle('fill', c.x, c.y, 1)
		love.graphics.print(c.id, c.x, c.y)
	end

	-- draw start and goal points
	love.graphics.setPointSize(8)
	love.graphics.setColor(1, 0, 0)
	love.graphics.points(startPoint.x, startPoint.y)
	love.graphics.points(goalPoint.x, goalPoint.y)

	-- draw shortest path
	if shortestPath and #shortestPath > 0 then
		for _, segment in ipairs(shortestPath) do
			local arc = segment.arc
			if arc then
				love.graphics.setColor(1, 1, 0)
				if arc.collision then
					love.graphics.setColor(1, 0, 0)
				end
				love.graphics.arc('line', 'open', arc.x, arc.y, arc.radius, arc.angle1, arc.angle2)
				love.graphics.setColor(1, 1, 1)
				love.graphics.print(arc.id, arc.pointP.x + 5, arc.pointP.y + 5)
			end
			love.graphics.setColor(0, 1, 0)
			love.graphics.line(segment.line)
		end
	end

	-- draw debug points
	love.graphics.setColor(1, 0, 1)
	if debugPoints and #debugPoints > 0 then
		for _, point in ipairs(debugPoints) do
			love.graphics.circle('fill', point.x, point.y, 4)
		end
	end
end