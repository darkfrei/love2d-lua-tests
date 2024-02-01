local voronoilib = require ('voronoilib')

--voronoilib based on:

-- https://gist.github.com/tnlogy/9081637

-- https://github.com/TomK32/iVoronoi/blob/working/tests/voronoilib_getEdges/main.lua

-- https://github.com/darkfrei/love2d-lua-tests/tree/main/voronoi-tnlogy



function love.load ()
	local width, heigth = love.graphics.getDimensions ()
	local polygoncount = 16
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


local function drawArrow (x1, y1, x2, y2)
	local angle = math.atan2(y2 - y1, x2 - x1)
	local arrowLength = 20
	local arrow1x = x2 - arrowLength * math.cos(angle - math.pi / 12)
	local arrow1y = y2 - arrowLength * math.sin(angle - math.pi / 12)
	local arrow2x = x2 - arrowLength * math.cos(angle + math.pi / 12)
	local arrow2y = y2 - arrowLength * math.sin(angle + math.pi / 12)

	love.graphics.line(x2, y2, arrow1x, arrow1y)
	love.graphics.line(x2, y2, arrow2x, arrow2y)
end

local function drawPolygons (polygons, colorFill, colorLine)
	love.graphics.setColor (colorFill)
	for _,polygon in pairs(polygons) do
		if #polygon.points > 4 then
			love.graphics.polygon('fill', polygon.points)
		end
	end
	love.graphics.setColor (colorLine)
	for _,polygon in pairs(polygons) do
		local vertices = polygon.points
		if #vertices > 4 then
			love.graphics.polygon('line', vertices)
		end
	end

	love.graphics.setColor (1,1,1,0.9)
	for index, point in pairs(vDiagram.points) do
		love.graphics.circle('fill', point.x, point.y, 2)
		love.graphics.print(index, point.x, point.y)
	end
end


function love.draw()
	love.graphics.setLineWidth (1)
	-- draw background
	drawPolygons (vDiagram.polygons, colorFill, colorLine)

--	highlight hovered
	if hovered.polygon then
		love.graphics.setColor (0,1,0,0.2)
		local vertices = hovered.polygon.points
		love.graphics.polygon('fill', vertices)
		local x1, y1 = vertices[#vertices-1], vertices[#vertices]
		love.graphics.setColor (0.6,0.8,0.6)
		for i = 1, #vertices, 2 do
			local x2, y2 = vertices[i], vertices[i+1]
			drawArrow (x1, y1, x2, y2)
			x1, y1 = x2, y2
		end
	end

-- highlight neigbours
	if hovered.neighbours then
		for _, polygon in pairs(hovered.neighbours) do
			love.graphics.setColor (1,1,0,0.2)
			if #polygon.points > 4 then
				love.graphics.polygon('fill', polygon.points)
			end
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