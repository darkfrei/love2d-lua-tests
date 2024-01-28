local voronoilib = require ('voronoilib')

--voronoilib_getEdges
--https://github.com/TomK32/iVoronoi/blob/working/tests/voronoilib_getEdges/main.lua




function love.load( arg )
	local width, heigth = love.graphics.getDimensions ()

	drawlist = { }

	activatedPolygons = { } -- hash

	-- polygoncount,iterations,minx,miny,maxx,maxy
	local polygoncount = 12
	local iterations = 1
	local minx,miny = 25, 25
	local maxx,maxy = width-50, heigth-50



	vDiagram = voronoilib:new(polygoncount, iterations,minx,miny, maxx,maxy)

	hovered = {
		vertex = nil,
		edge = nil,
		polygon = nil,
	}

	colorFill = {0.5,0.5,0.5}
	colorLine = {0.8,0.8,0.8}
end


function drawPolygons (polygons, colorFill, colorLine)
	love.graphics.setColor (colorFill)
	for index,polygon in pairs(vDiagram.polygons) do
		love.graphics.polygon('fill', polygon.points)
	end
	love.graphics.setColor (colorLine)
	for index,polygon in pairs(vDiagram.polygons) do
		love.graphics.polygon('line', polygon.points)
	end
	love.graphics.setColor (0,0,0)
	for index,polygon in pairs(vDiagram.polygons) do
--		love.graphics.print()
	end
end

function love.draw()
	-- draw background
	drawPolygons (vDiagram.polygons, colorFill, colorLine)

--	highlight hovered
	if hovered.polygon then
		love.graphics.setColor (0,1,0,0.2)
		love.graphics.polygon('fill', hovered.polygon.points)
	end

-- highlight neigbours
	if hovered.neighbours then
		for index, polygon in pairs(hovered.neighbours) do
			love.graphics.setColor (1,1,0,0.2)
			love.graphics.polygon('fill', polygon.points)
		end
	end
end

function love.update()

end

function love.mousemoved (x, y, dx, dy)
	local radius = 4
--	hovered.vertex = vDiagram:vertexContains(x, y, radius)
--	hovered.edge = vDiagram:edgeContains(x, y, radius)
	hovered.polygon = vDiagram:polygonContains(x,y)
	if hovered.polygon then
		hovered.neighbours = vDiagram:getNeighborsSingle(hovered.polygon)
	else
		hovered.neighbours = nil
	end
end


function love.keypressed(key,scancode)
	if key == 'escape' then love.event.quit() end
end