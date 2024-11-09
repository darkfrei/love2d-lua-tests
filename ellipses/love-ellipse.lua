-- made for love2D

function love.graphics.ellipsePolygon (mode, ox, oy, a, b, rotation, numPoints)
	numPoints = numPoints or 64
	local vertices = {}
	for i = 1, numPoints do
		local theta = (i / numPoints) * (2 * math.pi)
		local x = a * math.cos(theta)
		local y = b * math.sin(theta)
		local rotatedX = ox + x * math.cos(rotation) - y * math.sin(rotation)
		local rotatedY = oy + x * math.sin(rotation) + y * math.cos(rotation)
		table.insert(vertices, rotatedX)
		table.insert(vertices, rotatedY)
	end
	love.graphics.polygon(mode, vertices)

end

function love.graphics.drawRotatedEllipseWithFoci(mode, ox, oy, a, b, rotation, numPoints)
	local c = math.sqrt(math.abs(a^2 - b^2))
	local fx1 = ox + c * math.cos(rotation)
	local fy1 = oy + c * math.sin(rotation)
	local fx2 = ox - c * math.cos(rotation)
	local fy2 = oy - c * math.sin(rotation)
	love.graphics.circle("fill", fx1, fy1, 3)
	love.graphics.circle("fill", fx2, fy2, 3)
	love.graphics.ellipsePolygon (mode, ox, oy, a, b, rotation, numPoints)
end

function love.graphics.drawEllipseFromFociAndP(mode, fx1, fy1, fx2, fy2, p, numPoints)
	local cx = (fx1 + fx2) / 2
	local cy = (fy1 + fy2) / 2
	local c = math.sqrt((fx2 - fx1)^2 + (fy2 - fy1)^2) / 2
	local a = p + c
	local b = math.sqrt(a^2 - c^2)
	local rotation = math.atan2(fy2 - fy1, fx2 - fx1)
	love.graphics.circle("fill", fx1, fy1, 3)
	love.graphics.circle("fill", fx2, fy2, 3)
	love.graphics.ellipsePolygon(mode, cx, cy, a, b, rotation, numPoints)
end

function love.graphics.drawEllipseFromFociAndRadius(mode, fx1, fy1, fx2, fy2, radius, numPoints)
	local cx = (fx1 + fx2) / 2
	local cy = (fy1 + fy2) / 2
	local c = math.sqrt((fx2 - fx1)^2 + (fy2 - fy1)^2) / 2
	local p = (radius - 2*c)/2
	local a = p + c
	local b = math.sqrt(a^2 - c^2)
	local rotation = math.atan2(fy2 - fy1, fx2 - fx1)
	love.graphics.circle("fill", fx1, fy1, 3)
	love.graphics.circle("fill", fx2, fy2, 3)
	love.graphics.ellipsePolygon(mode, cx, cy, a, b, rotation, numPoints)
end

function love.graphics.scaledCircle(mode, ox, oy, radiusX, radiusY, rotation)
	love.graphics.push()
	love.graphics.translate(ox, oy)
	love.graphics.rotate(rotation)
	love.graphics.scale(radiusX / radiusY, 1)
	love.graphics.circle(mode, 0, 0, radiusY)
	love.graphics.pop()
end