local voronoilib = require ('voronoilib')

--voronoilib based on:

-- https://gist.github.com/tnlogy/9081637

-- https://github.com/TomK32/iVoronoi/blob/working/tests/voronoilib_getEdges/main.lua

-- https://github.com/darkfrei/love2d-lua-tests/tree/main/voronoi-tnlogy

local function phyllotaxis(cx, cy, s, n)
	local pointVertices = {}
	local phi = 2*math.pi*(1-(5^0.5-1)/2)
	for i = 0, n do
		local angle = i * phi -- Adjust the angle for different phyllotaxis patterns
		local radius = s * math.sqrt(i)
		local x = cx + radius * math.cos(angle)
		local y = cy + radius * math.sin(angle)
		x = math.floor(x/2+0.5)*2
		y = math.floor(y/2+0.5)*2
		table.insert(pointVertices, x)
		table.insert(pointVertices, y)
	end
--	print ('phyllotaxis', '{'..table.concat (pointVertices, ',')..'}')
	return pointVertices
end



local function hexagonalVertices(x0, y0, rows, cols, w, h, s1, s2)
	local pointVertices = {}
	for row = 1, rows do
		for col = 1, cols do
			local x = col * w
			local y = row * h
			x = x + math.random ()-0.5
--			x = x + math.random (3)/1000
--			y = y + math.random (3)/1000
--			y = y + math.random ()-0.5
			if col % 2 == s1 then
				y = y + h/2
			end
			if row % 2 == s2 then
				x = x + w/2
			end
			table.insert(pointVertices, x0+x)
			table.insert(pointVertices, y0+y)
		end
	end

	print ('hexagonal', '{'..table.concat (pointVertices, ',')..'}')
	return pointVertices
end

local siteVertices = phyllotaxis(10, 99, 60, 500)

--local siteVertices = hexagonalVertices (-30, 10, 6, 7, 100, 86, 2, 0)
--local siteVertices = hexagonalVertices (10, -10, 5, 8, 86, 100, 0, 2)
--local siteVertices = hexagonalVertices (250, 100, 2, 2, 86, 100, 0, 2)



specialCaseHLines = {}
specialCaseVLines = {}
specialCaseCircle = {}
specialCaseSectors = {}
specialCaseSectors2 = {}

function love.load ()
	local width, heigth = love.graphics.getDimensions ()
	local polygoncount = 16
	local frameX,frameY = 25, 25
--	local frameW, frameH = width-50, heigth-50
	local frameW, frameH = 550, 550

--	vDiagram = voronoilib:generateNew(polygoncount, minx,miny, maxx,maxy)
	vDiagram = voronoilib:new(siteVertices, frameX,frameY, frameW, frameH)

	hovered = {
		vertex = nil,
		edge = nil,
		polygon = nil,
	}

	colorFill = {0.5,0.5,0.5}
	colorLine = {0.8,0.8,0.8}
end

function love.update()

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
--		love.graphics.print(index, point.x, point.y)
	end

	love.graphics.setColor (1,1,1)
	love.graphics.points (siteVertices)
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
		local x1, y1, x2, y2 = edge[1], edge[2], edge[2], edge[4]
--		love.graphics.line (edge.startPoint.x, edge.startPoint.y, edge.endPoint.x, edge.endPoint.y)
		love.graphics.line (x1, y1, x2, y2)
--		drawArrow (edge.startPoint.x, edge.startPoint.y, edge.endPoint.x, edge.endPoint.y)
		drawArrow (x1, y1, x2, y2)
	end

	love.graphics.setColor (0,1,0)
	for i, line in ipairs (specialCaseHLines) do
--		love.graphics.line (line)
	end

	love.graphics.setColor (1,0,0)
	for i, line in ipairs (specialCaseVLines) do
		love.graphics.line (line)
	end



	for i, circle in ipairs (specialCaseCircle) do
		love.graphics.setColor (0.7,0.7,0.7, 0.7)
		love.graphics.setLineWidth (circle[4])
		love.graphics.circle ('line', circle[1], circle[2], circle[3])
		love.graphics.setColor (1,1,1)
--		love.graphics.circle ('line', circle[1], circle[2], 3)
	end
	
	love.graphics.setColor (0,1,0)
	for i, point in ipairs (vDiagram.uniquePoints) do
		love.graphics.circle ('line', point.x, point.y, 2)
	end
	
	love.graphics.setColor (1,1,0)
	for i, line in ipairs (specialCaseSectors) do
		love.graphics.line (line)
	end
	love.graphics.setColor (1,0,0)
	for i, line in ipairs (specialCaseSectors2) do
		love.graphics.line (line)
	end
	
	-- vertex as crossing points
	love.graphics.setColor (0,0,1)
	for i, c in ipairs (vDiagram.vertex) do
		love.graphics.circle ('line', c.x, c.y, 4)
	end
end


function love.mousepressed (x, y)
	print ('mousepressed', x, y)
end


function love.mousemoved (x, y, dx, dy)
	love.window.setTitle ('mouse x:'..x..' y:'..y)
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