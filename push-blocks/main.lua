-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local pb = require ('push-blocks')
local level = require ('levels.level-1')


function love.load()
	love.window.setMode(1920, 1080, {resizable=true, borderless=false})
--	width, height = love.graphics.getDimensions( )
	
	pb:load (level)
	
end

 
function love.update(dt)
	-- nothing to update
end


function love.draw()
	pb:drawBackgroundGrid ()
	pb:drawMap ()
	pb:drawBlocks ()
	pb:drawAgents ()
	pb:drawMouse ()
	
	love.graphics.print ('WASD to move')
end

function love.keypressed(key, scancode, isrepeat)
	pb:keypressedMoving (scancode)
	if key == 'space' then
		pb:switchAgent ()
	elseif key == 'return' then
		package.loaded['levels.level-1'] = nil
		level = require ('levels.level-1')
		pb:load (level)
	elseif key == "escape" then
		love.event.quit()
	end
end
