-- License CC0 (Creative Commons license) (c) darkfrei, 2023

love.window.setMode(1280, 800) -- Steam Deck resolution
Width, Height = love.graphics.getDimensions( )

Track = {}
--LastPoint = {x=300, y=300, angle = math.rad (30)}
LastPoint = {x=300, y=700, angle = 0}
NextPoints = {}

local function addStraightRoad (length)
	print ('Straight', 'length: ' .. length)
	local x1, y1 = LastPoint.x, LastPoint.y
	local angle = LastPoint.angle
	local x2 = x1 + length*math.cos (angle)
	local y2 = y1 + length*math.sin (angle)
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

local function addCurvedRoad(radius, angle)
	print ('Curved', 'radius: ' .. radius, 'angle: ' .. angle)
	local x1, y1 = LastPoint.x, LastPoint.y
	local angle1 = LastPoint.angle
	local angleSign = angle > 0 and 1 or -1
	angle = math.rad(angle)

	local angle2 = angle1 + angle

	-- Middle point
	local xc = x1 - angleSign * radius * math.sin(angle1)
	local yc = y1 + angleSign * radius * math.cos(angle1)

	local x2 = xc + angleSign * radius * math.sin(angle2)
	local y2 = yc - angleSign * radius * math.cos(angle2)

-- length of the control handle or the distance 
-- between the control point and the corresponding 
-- anchor point on the curve:
	local v1 = math.abs (4/3*math.tan(angle / 4))
--		print (v1)

	local cp1x = x1 + v1 * radius * math.cos(angle1)
	local cp1y = y1 + v1 * radius * math.sin(angle1)

	local cp2x = x2 - v1 * radius * math.cos(angle2)
	local cp2y = y2 - v1 * radius * math.sin(angle2)

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


function love.load()
	local r1 = 240
	local r2 = 160
	local r3 =  80
	addStraightRoad (200)
	addCurvedRoad (r1, -30)
	addCurvedRoad (r1, -30)
	addCurvedRoad (r1, -30)
	addCurvedRoad (r2, -30)
	addCurvedRoad (r2, -30)
	addCurvedRoad (r2, -30)
	addCurvedRoad (r2, -30)
	
	addCurvedRoad (r1,  30)
	addCurvedRoad (r3,  60)
	addCurvedRoad (r3,  60)
	addCurvedRoad (r2,  30)
	addCurvedRoad (r2,  30)
	addCurvedRoad (r1,  30)
	addStraightRoad (300)
	addStraightRoad (51.38438763306)
	addCurvedRoad (r2,  30)
	addCurvedRoad (r3,  60)
	addCurvedRoad (r3,  60)
	addStraightRoad (500)
	addStraightRoad (62+0.87187078898)
	addCurvedRoad (r3, -60)
	addCurvedRoad (r3, -60)
	addCurvedRoad (r3, -60)
	
	print (Track[1].render.line[1], Track[1].render.line[2])
	print (LastPoint.x, LastPoint.y)
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
		LastPoint.x + 50*math.cos (LastPoint.angle), LastPoint.y + 50*math.sin (LastPoint.angle))
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