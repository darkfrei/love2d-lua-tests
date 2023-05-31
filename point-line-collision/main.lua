-- License CC0 (Creative Commons license) (c) darkfrei, 2023

point = {x=200, y=200, tx=100, ty=100, speed=200}
segment = {200, 200, 400, 100}

local function handlePointCollision(px, py, x1, y1, x2, y2, dx, dy)
  local segmentDX = x2 - x1
  local segmentDY = y2 - y1
  local segmentLength = math.sqrt(segmentDX * segmentDX + segmentDY * segmentDY)
  segmentDX = segmentDX / segmentLength
  segmentDY = segmentDY / segmentLength
  local dotProduct = (px - x1) * segmentDY - (py - y1) * segmentDX
  local dotProduct2 = (px + dx - x1) * segmentDY - (py + dy - y1) * segmentDX

	if not (dotProduct > -1/256 and dotProduct2 < 0) then
		-- not crossing segment from positive to negative side
		return dx, dy
	end
  
	local segmentDot = (px - x1) * (x2 - x1) + (py - y1) * (y2 - y1)
	local t = segmentDot / (segmentLength * segmentLength)

	if t >= 0 and t <= 1 then
		-- collision with segment
		dx = (x1 + segmentLength*segmentDX * t)-px
		dy = (y1 + segmentLength*segmentDY * t)-py
		love.window.setTitle (dx..' '..dy)
		return dx, dy
	else
		-- no collision with segment
		return dx, dy
	end
end

function love.update(dt)
	local px, py = point.x, point.y
	local speed = point.speed
	local dx0, dy0 = point.tx-point.x, point.ty-point.y
	local angle = math.atan2 (dy0, dx0)
	
	local dx = dt*speed*math.cos (angle)
	local dy = dt*speed*math.sin (angle)
	
	if math.abs (dx0) < math.abs(dx) 
	or math.abs (dy0) < math.abs(dy) then
		dx = dx0
		dy = dy0
	end
	
	local x1, y1 = segment[1], segment[2]
	local x2, y2 = segment[3], segment[4]
	dx, dy = handlePointCollision(px, py, x1, y1, x2, y2, dx, dy)
	point.x, point.y = px+dx, py+dy
end

function love.draw()
	love.graphics.line (segment)
	love.graphics.circle ('fill', point.x, point.y, 5)
	love.graphics.circle ('line', point.tx, point.ty, 7)
	love.graphics.line (point.x, point.y, point.tx, point.ty)
end

function love.mousemoved( x, y)
	point.tx = x
	point.ty = y
end


function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end
