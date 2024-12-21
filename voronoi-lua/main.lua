--
-- the other try to make voronoi;
-- now it's the Fortunes algorithm in the given polygon;
-- work in process
-- now circle event
-- main.lua

local voronoi = require ('voronoi')

local diagram = nil

TestPoints = {}
TestLines = {}

-- add test point to the list
function addTestPoint(x, y)
	if x and y then
		table.insert(TestPoints, {x = x, y = y})
		print('added TestPoint', x, y)
	elseif x then
		print('testPoint x:', x)
	elseif y then
		print('testPoint y:', y)
	end
end

-- add test line to the list
function addTestLine(x1, y1, x2, y2, color)
	if x1 and y1 and x2 and y2 then
		table.insert(TestLines, {line = {x1, y1, x2, y2}, color = color or {1, 1, 1}})
	end
end

local camera = {
	x = 0, -- initial camera position on x-axis
	y = 0, -- initial camera position on y-axis
	speed = 5 * 60, -- camera movement speed
}

function love.load()
	local siteCoordinates = {100, 300, 200, 100}

	-- define initial polygon (example: a large rectangle)
	local boundingPolygon = {
		{x = 10, y = 10},
		{x = 790, y = 10},
		{x = 790, y = 590},
		{x = 10, y = 590},
	}

	diagram = voronoi.generate(siteCoordinates, boundingPolygon) -- generate the diagram
	diagram:solve()
--	love.window.setTitle ('press SPACE tp step')
end

function love.update(dt)
	-- check for arrow key presses to move the camera
	if love.keyboard.isDown("right") then
		camera.x = camera.x + camera.speed * dt
	end
	if love.keyboard.isDown("left") then
		camera.x = camera.x - camera.speed * dt
	end
	if love.keyboard.isDown("down") then
		camera.y = camera.y + camera.speed * dt
	end
	if love.keyboard.isDown("up") then
		camera.y = camera.y - camera.speed * dt
	end
end

function love.draw()
	love.graphics.translate(-camera.x, -camera.y)

	-- set color for the polygon (semi-transparent green)
	love.graphics.setColor(0, 1, 0, 0.25)

	-- draw the filled polygon if the vertices are available
	if diagram and diagram.polygonVertices then
		love.graphics.polygon("fill", diagram.polygonVertices)
	end

	-- set color for the polygon outline (solid green)
	love.graphics.setColor(0, 1, 0, 1)

	-- draw the polygon outline if the vertices are available
	if diagram and diagram.polygonVertices then
		love.graphics.polygon("line", diagram.polygonVertices)
	end

	-- draw bounding polygon vertices for clarity (green)
	love.graphics.setColor(0, 1, 0)  -- green color
	for _, vertex in ipairs(diagram.boundingPolygon) do
		love.graphics.circle("fill", vertex.x, vertex.y, 3)  -- draw small circle for each vertex
	end

	-- draw all sites (red circles)
	for _, cell in ipairs(diagram.cells) do
		love.graphics.setColor(cell.color)  -- use the color assigned to the cell
		-- draw a small circle for the site:
		love.graphics.circle("fill", cell.site.x, cell.site.y, 5)

		love.graphics.setColor(cell.color[1], cell.color[2], cell.color[3], 0.5)
		if cell.vertices then
			for _, vertex in ipairs(cell.vertices) do
				love.graphics.line(cell.site.x, cell.site.y, vertex.x, vertex.y)
			end
		end
	end

	-- draw all test lines
	for i, lineHolder in ipairs(TestLines) do
		love.graphics.setColor(lineHolder.color)
		love.graphics.line(lineHolder.line)
	end

	-- draw all test points
	love.graphics.setColor(1, 1, 1)
	for i, point in ipairs(TestPoints) do
		local x = point.x
		local y = point.y
		love.graphics.circle("fill", x, y, 3)
	end
end

function love.keypressed(key, scancode, isrepeat)
	-- check if the 'space' key is pressed
	if key == "space" then
		if diagram then
			diagram:step()  -- call the step function to advance the diagram
		end
	end
end
