-- License CC0 (Creative Commons license) (c) darkfrei, 2023

love.window.setMode(1280, 800) -- Steam Deck resolution
love.window.setTitle("Slot Car Track")

local function setLastPoint (x, y, angle)
	LastPoint = {x=x, y=y, angle = math.rad (angle)}
end

local function addStraightRoad (length, logRoads)
	if logRoads then
		print ('Straight', 'length: ' .. length)
	end
	local x1, y1 = LastPoint.x, LastPoint.y
	local angle = LastPoint.angle
	local x2 = x1 + length*math.cos (angle)
	local y2 = y1 + length*math.sin (angle)
	if logRoads then
		x2 = math.floor(x2+0.5)
		y2 = math.floor(y2+0.5)
	end
	
	local road = {}
	-- line to render
	road.render = {}
	road.render.line = {x1, y1, x2, y2}
	road.render.circles = {{x1, y1}, {x2, y2}}
	
	LastPoint.x = x2
	LastPoint.y = y2
	LastPoint.angle = math.atan2 (y2-y1, x2-x1)
	table.insert (Track, road)
end

local function addCurvedRoad(radius, angle, logRoads)
	if logRoads then
		print ('Curved', 'radius: ' .. radius, 'angle: ' .. angle)
	end
	-- starting point
	local x1, y1 = LastPoint.x, LastPoint.y
	local angle1 = LastPoint.angle
	local angleSign = angle > 0 and 1 or -1
	angle = math.rad(angle)

	local angle2 = angle1 + angle

	-- Middle point
	local xc = x1 - angleSign * radius * math.sin(angle1)
	local yc = y1 + angleSign * radius * math.cos(angle1)

	-- end point
	local x2 = xc + angleSign * radius * math.sin(angle2)
	local y2 = yc - angleSign * radius * math.cos(angle2)
	if logRoads then
		x2 = math.floor(x2+0.5)
		y2 = math.floor(y2+0.5)
	end
	
-- control factor:
	local k = math.abs (4/3*math.tan(angle / 4))
--		print (v1)

	local cp1x = x1 + k * radius * math.cos(angle1)
	local cp1y = y1 + k * radius * math.sin(angle1)

	local cp2x = x2 - k * radius * math.cos(angle2)
	local cp2y = y2 - k * radius * math.sin(angle2)

	local road = {}
	road.render = {}
--	road.render.circles = {{xc, yc}, {x1, y1}, {x2, y2}}
	road.render.circles = {{x1, y1}}
--	road.render.line = {xc, yc, x1, y1, cp1x, cp1y, cp2x, cp2y, x2, y2, xc, yc}

	local curve = love.math.newBezierCurve( x1, y1,  cp1x, cp1y, cp2x, cp2y, x2, y2)

	road.render.line = curve:render()

	LastPoint.x = x2
	LastPoint.y = y2
	LastPoint.angle = angle2

	table.insert(Track, road)
end

local function createTrack (r0, logRoads)
	
	Track = {}

	setLastPoint (500, 700, 0)

	local r1, a1 = r0*2, 30
	local r2, a2 = r0*(2^0.5), 30
--	local r2, a2 = r0*1.4142, 30
--	local r2, a2 = r0*1.53, 30
	local r3, a3 =  r0, 60
	
	
	addStraightRoad (141, logRoads)
	addCurvedRoad (r1, -a1, logRoads)
	addCurvedRoad (r1, -a1, logRoads)
	addCurvedRoad (r1, -a1, logRoads)
	
	addCurvedRoad (r2, -a2, logRoads)
	addCurvedRoad (r2, -a2, logRoads)
	addCurvedRoad (r2, -a2, logRoads)
	addCurvedRoad (r2, -a2, logRoads)
	
	addCurvedRoad (r1,  a1, logRoads)
	
	addCurvedRoad (r3,  a3, logRoads)
	
	addCurvedRoad (r3,  a3, logRoads)
	
	addCurvedRoad (r2,  a2, logRoads)
	addCurvedRoad (r2,  a2, logRoads)
	addCurvedRoad (r1,  a1, logRoads)
	addStraightRoad (200, logRoads)
	
	addCurvedRoad (r2,  a2, logRoads)
	
	addCurvedRoad (r3,  a3, logRoads)
	addCurvedRoad (r3,  a3, logRoads)
	
	addStraightRoad (400, logRoads)
	
	addCurvedRoad (r3, -a3, logRoads)
	addCurvedRoad (r3, -a3, logRoads)
	addCurvedRoad (r3, -a3, logRoads)
	
	addStraightRoad (100, logRoads)
	
--	print (Track[1].render.line[1], Track[1].render.line[2])
--	print (LastPoint.x, LastPoint.y)
	local dy = Track[1].render.line[2] - LastPoint.y
	local dx = Track[1].render.line[1] - LastPoint.x
--	print ('dy:', dy)
	return dy, dx
end

local function findXByBisection(func, y, xMin, xMax, tolerance)
	local xMid = (xMin + xMax) / 2
	local yMid = func(xMid)
	local lastXMid = nil
	while math.abs(yMid - y) > tolerance do
		if (yMid - y) * (func(xMin) - y) > 0 then
			xMin = xMid
		else
			xMax = xMid
		end

		xMid = (xMin + xMax) / 2
		yMid = func(xMid)
		print (xMid, yMid)
		
		if lastXMid == xMid then
			return xMid
		end
		lastXMid = xMid
	end
	print ('error: ', math.abs(yMid - y), yMid, y)
--	return math.floor(xMid+0.5)
	return xMid
end

-- Пример использования


local targetY = 0
local xMin, xMax = 0, 600
local tolerance = 0.00001

--local radius = findXByBisection(createTrack, targetY, xMin, xMax, tolerance)
local radius = 113.85440826416

print(radius)  -- Вывод найденного значения x



function love.load()
	local xMin = 10
	local xMax = 300
	
	local dy, dx = createTrack (radius, true)
	print ('dx: ' .. dx, 'dy: ' .. dy)
end

 
function love.update(dt)
	
end

function love.draw()
	love.graphics.setColor (1,1,1)
	for _, road in ipairs (Track) do
		local r = road.render
		if r.line then
			love.graphics.line (r.line)
		end
		if r.circles then
			for _, point in ipairs (r.circles) do
				love.graphics.circle ('line', point[1], point[2], 4)
			end
		end
	end
	
	love.graphics.setColor (1,1,0)
	
	love.graphics.line (LastPoint.x, LastPoint.y, 
		LastPoint.x + 50*math.cos (LastPoint.angle), 
		LastPoint.y + 50*math.sin (LastPoint.angle))
	love.graphics.circle ('fill', LastPoint.x, LastPoint.y, 3)
	love.graphics.circle ('fill', LastPoint.x + 50*math.cos (LastPoint.angle), LastPoint.y + 50*math.sin (LastPoint.angle), 3)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
	
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end