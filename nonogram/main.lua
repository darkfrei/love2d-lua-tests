-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local nono = require('nonogram')
nono:newMap ('nonograms/nono-1.png')
nono:shortLeftBar ()
nono:shortTopBar ()

function love.load()
	width, height = love.graphics.getDimensions( )

	
end

 
function love.update(dt)
	
end


function love.draw()
	nono:drawSolution(dx, dy)
	nono:drawLeftBar()
	nono:drawTopBar()
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