-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local cl = require ('color-lines')


function love.load()
	love.window.setMode (1280, 800) -- 8*160, 5*160
	love.window.setTitle(table.concat ({'Color Lines', love.graphics.getDimensions()}, ' '))
	love.graphics.setLineWidth(2)

	cl.load()
end

 
function love.update(dt)
	cl.update(dt)
end


function love.draw()
	cl.draw()
end


function love.mousepressed( x, y, button, istouch, presses )
	cl.mousepressed( x, y, button, istouch, presses )
end

function love.mousemoved( x, y, dx, dy, istouch )
	cl.mousemoved( x, y, dx, dy, istouch )
end

function love.mousereleased( x, y, button, istouch, presses )
	cl.mousereleased( x, y, button, istouch, presses )
end


function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end
