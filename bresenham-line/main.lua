local function bresenhamLine(x1, y1, x2, y2, step)
	step = step or 1
	x1 = math.floor (x1/step+0.5)*step
	y1 = math.floor (y1/step+0.5)*step
	x2 = math.floor (x2/step+0.5)*step
	y2 = math.floor (y2/step+0.5)*step
	
	local points = {x1, y1}
	local dx = math.abs(x2 - x1)
	local dy = math.abs(y2 - y1)
	local sx = x1 < x2 and step or -step
	local sy = y1 < y2 and step or -step
	local err = dx - dy
	
	while x1 ~= x2 or y1 ~= y2 do
		
		local err2 = err * 2
		if err2 > -dy then
			err = err - dy
			x1 = x1 + sx
		end
		if err2 < dx then
			err = err + dx
			y1 = y1 + sy
		end
		table.insert(points, x1)
		table.insert(points, y1)
	end
	return points
end

function love.load()
	scale = 1
	step = 5
	startPoint = {400/scale, 300/scale}
	linePoints = bresenhamLine(startPoint[1], startPoint[2], 400, 300, step)
end

function love.draw()
	love.graphics.scale (scale)
	love.graphics.points(linePoints)
end

function love.mousemoved (x, y)
	linePoints = bresenhamLine(startPoint[1], startPoint[2], x/scale, y/scale, step)
end