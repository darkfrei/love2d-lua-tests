-- License CC0 (Creative Commons license) (c) darkfrei, 2022

-- small polygons lib  for LÖVE (Love2d)

local mp = {}
mp.polygons = {}

function mp.newPolygon (vertices, fillColor, lineColor, lineWidth)
	-- vertices {x1,y1, x2,y2, x3,y3 ... xn,yn}
	local newVertices = {}
	local line = {}
	for i, v in ipairs (vertices) do
		newVertices[i] = v
		line[i] = v
	end
	table.insert (line, vertices[1])
	table.insert (line, vertices[2])

	local isConvex = love.math.isConvex(newVertices)
	local triangles
	if not isConvex then
		triangles = love.math.triangulate(newVertices)
	end
	local polygon = {
		lineColor=lineColor,
		fillColor=fillColor,
		vertices = newVertices,
		line = line,
		isConvex = isConvex,
		triangles = triangles,
		lineWidth = lineWidth or 2,
	}
	table.insert (mp.polygons, polygon)
	return polygon
end




function mp.drawPolygon (polygon)
	-- draw fill
	if polygon.fillColor then
		
		love.graphics.setColor (polygon.fillColor)
		if polygon.isConvex then
			love.graphics.polygon("fill", polygon.vertices)
		else
			for i, triangle in ipairs(polygon.triangles) do
				love.graphics.polygon("fill", triangle)
			end
		end
	end
	
	if polygon.lineColor then
		love.graphics.setLineWidth (polygon.lineWidth)
		love.graphics.setColor (polygon.lineColor)
		love.graphics.polygon ("line", polygon.vertices)
	end
end

function mp.drawPolygons ()
	for i, polygon in ipairs (mp.polygons) do
		mp.drawPolygon (polygon)
	end
end

function correctPoints (line)
	-- it makes the line smooth
	if #line > 5 then
		local x1 = line[#line-5]
		local y1 = line[#line-4]
		local x2 = line[#line-3]
		local y2 = line[#line-2]
		local x3 = line[#line-1]
		local y3 = line[#line]
		x2 = 0.25*x1+0.5*x2+0.25*x3
		y2 = 0.25*y1+0.5*y2+0.25*y3
		line[#line-3] = x2
		line[#line-2] = y2
	end
end

function mp.verticesCreating (step, x, y, minDist)
	if step == "mousepressed" then
		mp.temp = {x, y}
	elseif step == "mousemoved" then
		if mp.temp then
			if minDist then
				local dx = x - mp.temp[#mp.temp-1]
				local dy = y - mp.temp[#mp.temp]
				if dx*dx+dy*dy > minDist*minDist then
					table.insert (mp.temp, x)
					table.insert (mp.temp, y)
				end
				correctPoints (mp.temp)
			else
				table.insert (mp.temp, x)
				table.insert (mp.temp, y)
			end
		end
	elseif step == "mousereleased" then
		local vertices = mp.temp
		mp.temp = nil
		return vertices
	else
		error "no step by polygonCreating"
	end
end

function mp.drawTemp ()
	if mp.temp and #mp.temp > 2 then
		love.graphics.line (mp.temp)
	end
end

return mp