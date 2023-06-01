local function bresenhamLine(x1, y1, x2, y2)
	x1 = math.floor (x1+0.5)
	y1 = math.floor (y1+0.5)
	x2 = math.floor (x2+0.5)
	y2 = math.floor (y2+0.5)
	local points = {}
	local dx = math.abs(x2 - x1)
	local dy = math.abs(y2 - y1)
	local sx = x1 < x2 and 1 or -1
	local sy = y1 < y2 and 1 or -1
	local err = dx - dy
	
	while x1 ~= x2 or y1 ~= y2 do
		table.insert(points, {x1, y1})
		local err2 = err * 2
		if err2 > -dy then
			err = err - dy
			x1 = x1 + sx
		end
		if err2 < dx then
			err = err + dx
			y1 = y1 + sy
		end
	end
	return points
end

function love.load()
	scale = 2
	startPoint = {400/scale, 300/scale}
	linePoints = bresenhamLine(startPoint[1], startPoint[2], 400, 300)
end

function love.draw()
	love.graphics.scale (scale)
	love.graphics.points(linePoints)
end

function love.mousemoved (x, y)
	linePoints = bresenhamLine(startPoint[1], startPoint[2], x/scale, y/scale)
end