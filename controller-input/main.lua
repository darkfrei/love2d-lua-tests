-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function love.load()
	width, height = love.graphics.getDimensions( )

	
	local joysticks = love.joystick.getJoysticks()
	joystick = joysticks[1]
	

	leftCircle = {x = 200, y = 280, size = 50}
	rightCircle = {x = 600, y = 280, size = 50}
	speed = 300
	

	
	gamepad = {
		triggerleft=0, triggerright=0,
		leftx=0, lefty=0, 
		rightx=0, righty=0,
		}
end

function love.update(dt)
	if not joystick then return end


	
	if joystick:isGamepadDown("dpleft") then
		leftCircle.x = leftCircle.x - dt*speed
	elseif joystick:isGamepadDown("dpright") then
		leftCircle.x = leftCircle.x + dt*speed
	end

	if joystick:isGamepadDown("dpup") then
		leftCircle.y = leftCircle.y - dt*speed
	elseif joystick:isGamepadDown("dpdown") then
		leftCircle.y = leftCircle.y + dt*speed
	end
	
	leftCircle.x = leftCircle.x + dt*speed*joystick:getGamepadAxis("leftx")
	leftCircle.y = leftCircle.y + dt*speed*joystick:getGamepadAxis("lefty")
	
	rightCircle.x = rightCircle.x + dt*speed*joystick:getGamepadAxis("rightx")
	rightCircle.y = rightCircle.y + dt*speed*joystick:getGamepadAxis("righty")
end

function love.draw()
	if not joystick then return end
	
	local leftSize = (1-joystick:getGamepadAxis("triggerleft"))*leftCircle.size
	local rightSize = (1-joystick:getGamepadAxis("triggerright"))*rightCircle.size
	love.graphics.circle("fill", leftCircle.x, leftCircle.y, leftSize)
	love.graphics.circle("fill", rightCircle.x, rightCircle.y, rightSize)

	local t1, dt = 40, 20
	for axis, value in pairs (gamepad) do
		love.graphics.print(axis..' '.. tostring(value),0,t1)
		t1=t1+dt
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

--function love.joystickaxis( joystick, axis, value )
--	text = 'joystickaxis: '.. axis .. ' - ' .. value
--end

function love.gamepadaxis( joystick, axis, value )
	gamepad[axis] = value
	
end

function love.gamepadpressed( joystick, button )
	gamepad[button] = true
end

function love.gamepadreleased( joystick, button )
	gamepad[button] = false
end
