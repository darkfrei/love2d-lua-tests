local function pointInConvexPolygon(x, y, poly)
	-- poly as {x1,y1, x2,y2, x3,y3, ...}
	local imax = #poly

	local function isVerticesClockwise(poly)
		local sum = 0
		local imax = #poly
		local x1, y1 = poly[imax-1], poly[imax]
		for i = 1, imax - 1, 2 do
			local x2, y2 = poly[i], poly[i + 1]
			sum = sum + (x2 - x1) * (y2 + y1)
			x1, y1 = x2, y2
		end
		local isClockwise = sum < 0
		love.window.setTitle(isClockwise and 'clockwise' or 'counterclockwise')
		return isClockwise
	end

	local sign = isVerticesClockwise(poly) and 1 or -1
	local x1, y1 = poly[imax-1], poly[imax]
	for i = 1, imax - 1, 2 do
		local x2, y2 = poly[i], poly[i + 1]
		local dotProduct = (x - x1) * (y1 - y2) + (y - y1) * (x2 - x1)
		if sign * dotProduct < 0 then
			return false
		end
		x1, y1 = x2, y2
	end
	return true
end



function love.load()
	poly = {100, 100, 400, 150, 200, 300}
	local x, y = 400, 300
	inside = pointInConvexPolygon (x, y, poly)
end


function love.update(dt)

end

local function drawArrow(x1, y1, x2, y2)
	local angle = math.atan2(y2 - y1, x2 - x1)
	local arrowSize = 20
	local x3 = x2 - arrowSize * math.cos(angle - math.pi / 16)
	local y3 = y2 - arrowSize * math.sin(angle - math.pi / 16)
	local x4 = x2 - arrowSize * math.cos(angle + math.pi / 16)
	local y4 = y2 - arrowSize * math.sin(angle + math.pi / 16)
	love.graphics.line(x3, y3, x2, y2, x4, y4)
end

function love.draw()
	love.graphics.setLineStyle ('rough')
	love.graphics.setLineWidth (1)
	love.graphics.setLineJoin ('none')
	if inside then
		love.graphics.setColor (1,1,0)
	else
		love.graphics.setColor (0,1,1)
	end
	if #poly > 4 then
		love.graphics.polygon ('line', poly)
		local imax = #poly
		local x1, y1 = poly[imax-1], poly[imax]
		for i = 1, imax - 1, 2 do
			local x2, y2 = poly[i], poly[i + 1]
			drawArrow(x1, y1, x2, y2)
			x1, y1 = x2, y2
		end
	elseif #poly > 2 then
		love.graphics.line (poly)
		drawArrow(poly[1], poly[2], poly[3], poly[4])
	end
	love.graphics.setColor (1,1,1)
	love.graphics.print ('Left mouse botton to add new point', 14, 14)
	love.graphics.print ('Right mouse botton to remove last point', 14, 2*14)
	love.graphics.print ('Is inside: '..tostring(inside), 14, 4*14)
end


function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
		table.insert (poly, x)
		table.insert (poly, y)
	elseif button == 2 then -- right mouse button
		table.remove (poly)
		table.remove (poly)
	end
	inside = pointInConvexPolygon (x, y, poly)
end

function love.mousemoved( x, y, dx, dy, istouch )
	inside = pointInConvexPolygon (x, y, poly)
end
