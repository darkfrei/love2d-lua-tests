-- License CC0 (Creative Commons license) (c) darkfrei, 2022

-- small polygons lib  for LÖVE (Love2d)

local mp = {}

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

return mp