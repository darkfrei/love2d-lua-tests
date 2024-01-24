

local generateVoronoiCanvas = require ('voronoi-canvas')

local voronoi = require ('voronoi-cells')




function love.load()
	local numberCells = 8
	local width, height = love.graphics.getWidth(), love.graphics.getHeight()

	-- pointas as love points {x1,y1, x2,y2 ...}
--	local points = voronoi.createPoints(numberCells, width, height)
	local points = {200,200, 410,250, 500,300, 500,450, 300,500, 100,550}

	diagram = voronoi.newDiagram (points, width, height)

	voronoiCanvas = generateVoronoiCanvas (diagram)

	voronoi.processNextEvent (diagram)
--	voronoi.processNextEvent (diagram)


end


function love.draw()
	--reset color
	love.graphics.setColor({ 1, 1, 1 })
	--draw diagram
	love.graphics.draw(voronoiCanvas)

	voronoi.drawBeachline (diagram)
	
	voronoi.drawCells (diagram)
	
	
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	elseif key == "space" then
		voronoi.processNextEvent (diagram)
	end
end

function love.mousemoved (x, y)
	love.window.setTitle ('x: '..x..' y: '..y)
end