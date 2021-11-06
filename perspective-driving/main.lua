-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function love.load()
	love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	width, height = love.graphics.getDimensions( )

	road = {}
	traveledDistance = 0
	tileSize = 1
	for i = 1, 100 do
		local js = math.random (10)
		local value = math.random (-1, 1)
		for j = 1, js do
			table.insert (road, value)
		end
	end
	speed = 20
end

 
function love.update(dt)
	traveledDistance = traveledDistance + dt*speed
	
end


function love.draw()
	local imin = math.floor (traveledDistance/tileSize)
	local dy = (traveledDistance - imin*tileSize)
	
	local k = 0
	local w = width
	local h = height/8
	local y2 = height
	local cx = width/2
	
	for i = imin, imin+450 do
		k = k + 1

		local w2 = (w+dy)/(k+1)
		local w1 = (w+dy)/(k)
		local h1 = math.max(2, 0.5*(h) / (k))
		local y1 = y2 - h1
		local x1 = cx - w2
		local x2 = cx - w1
		local x3 = cx + w1
		local x4 = cx + w2
		
		if i%8 < 4 then
			love.graphics.setColor(22/255,22/255,7/255)
		else
			love.graphics.setColor(34/255,34/255,25/255)
		end
		love.graphics.polygon('fill', x1, y1, x2, y2, x3, y2, x4, y1)
		
		if i%8 < 4 then
			love.graphics.setColor(1,1,1)
		else
			love.graphics.setColor(34/255,34/255,255/255)
		end
		love.graphics.line (x1, y1, x2, y2)
		love.graphics.line (x4, y1, x3, y2)
		
		y2 = y1
	end
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