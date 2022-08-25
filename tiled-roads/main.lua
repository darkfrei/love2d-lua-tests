-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local MR = require ('multiresolution')
local TR = require ('tiled-roads')
local State = TR


function love.load()
	love.window.setMode(1280, 800, {resizable = true, borderless = false})
	MR.load(1920, 1080) -- target rendering resolution
	
	
	TR.load (120)
end
 
function love.update(dt)
	State.update(dt)
end

function love.draw()
	MR.draw()
	State.draw()
	
	MR.drawMouse ()
end

function love.resize ()
	MR.resize()
end

function love.mousepressed( x, y, button, istouch, presses )
	
end

function love.mousemoved( x, y, dx, dy, istouch )
	
end

function love.mousereleased( x, y, button, istouch, presses )
	
end

function love.keypressed(key, scancode, isrepeat)
	MR.keypressed(key, scancode, isrepeat)
	
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end