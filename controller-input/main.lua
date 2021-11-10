-- testing the controller, move left and right sticks

-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function love.load()
	love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	width, height = love.graphics.getDimensions( )

	
	local joysticks = love.joystick.getJoysticks()
	joystick = joysticks[1]
	

	leftCircle = {x0=height/2, x=height/2, y0=height/2, y = height/2, r=height/3, size = 50}
	rightCircle = {x0=width-height/2, x=width-height/2, y0=height/2, y = height/2, r=height/3, size = 50}
	
	canvas = love.graphics.newCanvas()
end

function love.update(dt)
	if not joystick then return end
end

function love.draw()
	if not joystick then return end
	
	local leftSize = (1-joystick:getGamepadAxis("triggerleft"))*leftCircle.size
	love.graphics.circle("fill", leftCircle.x, leftCircle.y, leftSize)
	local rightSize = (1-joystick:getGamepadAxis("triggerright"))*rightCircle.size
	love.graphics.circle("fill", rightCircle.x, rightCircle.y, rightSize)
	
	love.graphics.draw(canvas)
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



function love.gamepadaxis( joystick, axis, value )
	if axis == 'leftx' then
		leftCircle.x = leftCircle.x0+value*leftCircle.r*math.abs(value)
	elseif axis == 'lefty' then
		leftCircle.y = leftCircle.y0+value*leftCircle.r*math.abs(value)
	elseif axis == 'rightx' then
		rightCircle.x = rightCircle.x0+value*rightCircle.r*math.abs(value)
	elseif axis == 'righty' then
		rightCircle.y = rightCircle.y0+value*rightCircle.r*math.abs(value)
		
	elseif axis == 'triggerleft' or axis == 'triggerright' then
		local left = joystick:getGamepadAxis("triggerleft")
		local right = joystick:getGamepadAxis("triggerright")
		
		success = joystick:setVibration(left, right)
	end
	
	love.graphics.setCanvas(canvas)
		
		love.graphics.points (leftCircle.x, leftCircle.y, rightCircle.x, rightCircle.y)
	love.graphics.setCanvas()
	
	
end

function love.gamepadpressed( joystick, button )
	
end

function love.gamepadreleased( joystick, button )
	
end
