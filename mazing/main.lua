-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local mazing = require ('mazing')
cells = mazing.createCells (30, 18)

love.window.setMode(1280, 800) -- Steam Deck resolution
Width, Height = love.graphics.getDimensions( )

function love.load()
	
end

 
function love.update(dt)
	
end


function love.draw()
	local size = 40
	for i, cell in ipairs (cells) do
		love.graphics.rectangle ('line', size*cell.x, size*cell.y, size*cell.w, size*cell.h)
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