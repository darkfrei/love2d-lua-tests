-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function createTarget ()
	local x = width/2 + math.random (-radius, radius)
	local y = height/2 + math.random (-radius, radius)
	table.insert (targets, {x=x,y=y})
end

function love.load()
	love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	width, height = love.graphics.getDimensions( )
	radius = math.min(width, height)/2
	
	local joysticks = love.joystick.getJoysticks()
    joystick = joysticks[1]
	active = "left"
	
	position = {x = width/2, y = height/2}
	targets = {}
	tSize = 40
	createTarget ()
	font = love.graphics.newFont(40)
	love.graphics.setFont(font)
	
	score = 0
	
	moved = false
end

 
function love.update(dt)
	if moved then
		local x, y
		if active == "left" then
			x = width/2 + radius * joystick:getGamepadAxis("leftx")
			y = height/2 + radius * joystick:getGamepadAxis("lefty")
		else
			x = width/2 + radius * joystick:getGamepadAxis("rightx")
			y = height/2 + radius * joystick:getGamepadAxis("righty")
		end
		for i = #targets, 1, -1 do
			local target = targets[i]
			if math.abs (target.x-x) < tSize and math.abs (target.y-y) < tSize then
				score = score + 1
				table.remove(targets, i)
				createTarget ()
				if math.random () > 15/16 then
					createTarget ()
				end
				moved = false
				position = {x = width/2, y = height/2}
				if active == "right" then
					active = "left"
				else
					active = "right"
				end
			end
		end
	end
end


function love.draw()
	
	love.graphics.circle("fill", position.x, position.y, 50)
	
	for i, target in ipairs (targets) do
		love.graphics.circle("fill", target.x, target.y, tSize/2)
	end
	
	
	love.graphics.print (score, 32, 32)
end

function love.gamepadaxis( joystick, axis, value )
	if active == "left" then
		if axis == "leftx" then
			position.x = width/2 + value*radius
			moved = true
		elseif axis == "lefty" then
			position.y = height/2 + value*radius
			moved = true
		end
	else
		if axis == "rightx" then
			position.x = width/2 + value*radius
			moved = true
		elseif axis == "righty" then
			position.y = height/2 + value*radius
			moved = true
		end
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