-- License CC0 (Creative Commons license) (c) darkfrei, 2021

--https://youtu.be/ihXdFdmzI9Q

function love.load()
	love.window.setMode(1920, 1080, {resizable=true, borderless=false})

	width, height = love.graphics.getDimensions( )

	tileSize = 60
	
	tractor = {
		x=width/2, 
		y=height/2,
		angle = 0,
--		leftForward = true, 
--		rightForward = true,
		topSpeed = 200
	}
	
	local joysticks = love.joystick.getJoysticks()
    joystick = joysticks[1]
	
	image = love.graphics.newImage('dozer.png')
end

 
function love.update(dt)
	if not joystick then return end
	
	local leftPressed = joystick:isGamepadDown ("leftshoulder")
	local rightPressed = joystick:isGamepadDown("rightshoulder")
	local leftValue = joystick:getGamepadAxis ("triggerleft")
	local rightValue = joystick:getGamepadAxis("triggerright")
	leftValue = leftValue*leftValue
	rightValue = rightValue*rightValue
	leftValue  = leftPressed  and -leftValue  or leftValue
	rightValue = rightPressed and -rightValue or rightValue
	local speedLeft  = dt*leftValue *tractor.topSpeed
	local speedRight = dt*rightValue*tractor.topSpeed
	local speed = (speedLeft+speedRight)/2
	local rot = speed-speedLeft
	
	if rot > 1 then
		speed = speed/rot
		rot = 1
	elseif rot < -1 then
		speed = speed/math.abs(rot)
		rot = -1
	end 
	tractor.rot = rot
	tractor.angle = tractor.angle - rot/(tileSize/2)
	local dx = speed * math.cos(tractor.angle)
	local dy = speed * math.sin(tractor.angle)
	tractor.x = tractor.x + dx
	tractor.y = tractor.y + dy
	
end

function drawRotatedRectangle(mode, x, y, width, height, angle)
	-- We cannot rotate the rectangle directly, but we
	-- can move and rotate the coordinate system.
	love.graphics.push()
	love.graphics.translate(x-width/2, y-height/2)
	love.graphics.rotate(angle)
	love.graphics.rectangle(mode, -width/2, -height/2, width, height)
	love.graphics.pop()
end

function love.draw()
	for x = 0, width, tileSize do
		for y = 0, height, tileSize do
			if ((x+y)/tileSize)%2 == 0 then
				love.graphics.setColor(0.7,0.7,0.7)
			else
				love.graphics.setColor(0.6,0.6,0.6)
			end
			love.graphics.rectangle('fill', x, y, tileSize,tileSize)
		end
	end
	love.graphics.setColor(1,1,1)
	if not joystick then
		love.graphics.print('no controller')
	else
--		drawRotatedRectangle('fill', tractor.x, tractor.y, 2*tileSize, tileSize, tractor.angle)
		love.graphics.draw(image, tractor.x-tileSize, tractor.y-tileSize/2, tractor.angle, 1, 1, tileSize, tileSize/2)
	end
--	if tractor.rot then
--		love.graphics.print(tractor.rot)
--	end
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