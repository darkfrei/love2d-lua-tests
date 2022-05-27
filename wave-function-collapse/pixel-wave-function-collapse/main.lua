-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local pwfc = require ('pixel-wave-function-collapse')

function love.load()
--	pwfc:load ('input/city-night.png')
	pwfc:load ('input/chain-squares.png')
	
	
	
end

 
function love.update(dt)
	pwfc:update (dt)
end


function love.draw()
	pwfc:draw ()
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