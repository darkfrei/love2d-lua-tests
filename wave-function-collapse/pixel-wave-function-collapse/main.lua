-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local pwfc = require ('pixel-wave-function-collapse')

math.randomseed(love.math.random(65536))

function love.load()
--	
	local w = 50
	local h = 20
--	pwfc:load ('input/chain-squares-01.png', w, h)
	pwfc:load ('input/chain-squares-02.png', w, h)
--	pwfc:load ('input/city-night.png', w, h)
--	pwfc:load ('input/01.png', w, h)
--	pwfc:load ('input/02.png', w, h)
	
--	pwfc:load ('input/03.png', w, h)
--	pwfc:load ('input/04.png', w, h) -- ok

	
	
	
end

 
function love.update(dt)
	pwfc:update (dt)
end


function love.draw()
	pwfc:draw ()
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "space" then
		pwfc:keypressed (key, scancode, isrepeat)
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	
end

function love.mousemoved( x, y, dx, dy, istouch )
	
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end