local function updatePolygon(polygon, dx, dy, dAngle, direction)
	local oVertices = polygon.oVertices
	
	local cx = polygon.cx
	local cy = polygon.cy
	local angleRad = polygon.angle + dAngle
	local cosA, sinA = math.cos(angleRad), math.sin(angleRad)
	
	if direction then
		cx = cx - dy * cosA - dx * sinA
		cy = cy - dy * sinA + dx * cosA
	else
		cx = cx + dx
		cy = cy + dy
	end
		
	for i = 1, #oVertices-1, 2 do
		local ox = oVertices[i]
		local oy = oVertices[i + 1]
		local rx = ox * cosA - oy * sinA
		local ry = ox * sinA + oy * cosA
		polygon.vertices[i] = cx + rx
		polygon.vertices[i+1] = cy + ry
	end
	polygon.cx = cx
	polygon.cy = cy
	polygon.angle = angleRad
end

local function createPolygon(cx, cy, nVertices, radius, angle)
	local polygon = {
		cx = 0,
		cy = 0,
		nVertices = nVertices,
		radius = radius,
		angle = 0,
		oVertices = {}, -- original vertices
		vertices = {}, -- possibly transformed vertices
	}

	local fTheta = 2 * math.pi / nVertices

	for i = 0, nVertices-1 do
		local dx = radius * math.cos(fTheta * i)
		local dy = radius * math.sin(fTheta * i)

		table.insert(polygon.oVertices, dx)
		table.insert(polygon.oVertices, dy)
	end
	-- Call a function to update possibly transformed vertices
	updatePolygon(polygon, cx, cy, angle)

	return polygon
end

local function drawPolygon(mode, polygon)
	love.graphics.line(polygon.cx, polygon.cy, polygon.vertices[1], polygon.vertices[2])
	love.graphics.polygon("line", polygon.vertices)
end


local geometry = {
	createPolygon = createPolygon,
	updatePolygon = updatePolygon,
	drawPolygon = drawPolygon,
}
return geometry