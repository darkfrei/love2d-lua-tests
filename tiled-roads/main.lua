-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local TR = require ('tiled-roads')
local State = TR


function love.load()
	TR.load ()
end
 
function love.update(dt)
	State.update(dt)
end

function love.draw()
	State.draw()
end

function love.mousepressed( x, y, button, istouch, presses )
	
end

function love.mousemoved( x, y, dx, dy, istouch )
	
end

function love.mousereleased( x, y, button, istouch, presses )
	
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end