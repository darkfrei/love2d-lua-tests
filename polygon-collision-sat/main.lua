-- License CC0 (Creative Commons license) (c) darkfrei, 2023

love.window.setMode(1280, 800) -- Steam Deck resolution
Width, Height = love.graphics.getDimensions( )

function love.load()
	
end

 
function love.update(dt)
	
end


function love.draw()
	
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