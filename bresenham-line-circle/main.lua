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

local function bresenhamCircle(x1, y1, x2, y2, step)
	step = step or 1
	x1 = math.floor(x1 / step + 0.5) * step
	y1 = math.floor(y1 / step + 0.5) * step
	x2 = math.floor(x2 / step + 0.5) * step
	y2 = math.floor(y2 / step + 0.5) * step
	
	
	local radius = math.floor(math.sqrt((x2 - x1)^2 + (y2 - y1)^2)/step+0.5)*step
	local x = step/2
	local y = radius-step/2
	local delta = step - 2 * radius
	local error = 0
	
	local points = {}
	
	while y > x-step do
		table.insert(points, x1 + x)
		table.insert(points, y1 - y)
		table.insert(points, x1 + y)
		table.insert(points, y1 - x)
		
		table.insert(points, x1 - x)
		table.insert(points, y1 - y)
		table.insert(points, x1 - y)
		table.insert(points, y1 - x)
		
		table.insert(points, x1 + x)
		table.insert(points, y1 + y)
		table.insert(points, x1 + y)
		table.insert(points, y1 + x)
		
		table.insert(points, x1 - x)
		table.insert(points, y1 + y)
		table.insert(points, x1 - y)
		table.insert(points, y1 + x)
		
		error = 2 * (delta + y) - 1
		
		if delta < step and error <= -step*step then
			x = x + step
			delta = delta + x + 1
		elseif delta > step and error > step*step then
			y = y - step
			delta = delta - y + 1
		else
			x = x + step
			y = y - step
			delta = delta + (x - y)

		end
	end
	
	return points
end




function love.load()
	scale = 1
	step = 8
	startPoint = {400/scale, 300/scale}
	linePoints = bresenhamLine(startPoint[1], startPoint[2], 400+2*step, 300, step)
	circlePoints = bresenhamCircle(startPoint[1], startPoint[2], 400+100, 300, step)
	
	love.graphics.setPointSize (step/2)
end



function love.update()
	local t = love.timer.getTime ()
	local p = 8
	local dx = 2*math.abs (t/p - math.floor (t/p + 1/2)) 
	
	circlePoints = bresenhamCircle(startPoint[1], startPoint[2], 400+300*dx, 300, step)
end

function love.draw()
	love.graphics.scale (scale)
	love.graphics.points(linePoints)
	love.graphics.points(circlePoints)
end

function love.mousemoved (x, y)
	linePoints = bresenhamLine(startPoint[1], startPoint[2], x/scale, y/scale, step)
--	circlePoints = bresenhamCircle(startPoint[1], startPoint[2], x, y, step)
end