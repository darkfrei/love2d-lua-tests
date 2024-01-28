local voronoilib = require ('voronoilib')

--voronoilib_getEdges
-- https://github.com/TomK32/iVoronoi/blob/working/tests/voronoilib_getEdges/main.lua

-- https://github.com/darkfrei/love2d-lua-tests/tree/main/voronoi-tnlogy



function love.load( arg )
	local width, heigth = love.graphics.getDimensions ()

	drawlist = { }


	-- polygoncount, minx,miny,maxx,maxy
	local polygoncount = 16
	local iterations = 1
	local minx,miny = 25, 25
	local maxx,maxy = width-50, heigth-50



	vDiagram = voronoilib:new(polygoncount, minx,miny, maxx,maxy)

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

	love.graphics.setColor (1,1,1,0.9)
	for index, point in pairs(vDiagram.points) do
		love.graphics.circle('fill', point.x, point.y, 2)
		love.graphics.print(index, point.x, point.y)
	end

	love.graphics.setColor (0,0,0,0.9)
	for index,polygon in pairs(vDiagram.polygons) do
		love.graphics.circle('line', polygon.centroid.x, polygon.centroid.y, 2)
		love.graphics.print(index, polygon.centroid.x, polygon.centroid.y)
	end
end

local function drawArrow (x1, y1, x2, y2)
	local angle = math.atan2(y2 - y1, x2 - x1)
	local arrowLength = 20
	local arrowWidth = 10
	local arrow1x = x2 - arrowLength * math.cos(angle - math.pi / 6)
	local arrow1y = y2 - arrowLength * math.sin(angle - math.pi / 6)
	local arrow2x = x2 - arrowLength * math.cos(angle + math.pi / 6)
	local arrow2y = y2 - arrowLength * math.sin(angle + math.pi / 6)

	love.graphics.line(x2, y2, arrow1x, arrow1y)
	love.graphics.line(x2, y2, arrow2x, arrow2y)
end

function love.draw()
	love.graphics.setLineWidth (1)
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

	love.graphics.setLineWidth (3)
	if hovered.edge then
		local edge = hovered.edge
		love.graphics.setColor (1,1,1)
--		print ('edge')
		love.graphics.line (edge.startPoint.x, edge.startPoint.y, edge.endPoint.x, edge.endPoint.y)
		drawArrow (edge.startPoint.x, edge.startPoint.y, edge.endPoint.x, edge.endPoint.y)
	end
end

function love.update()

end

function love.mousemoved (x, y, dx, dy)
	local radius = 40
	hovered.edge = vDiagram:edgeContains(x, y, radius)
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