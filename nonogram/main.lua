-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local nono = require('nonogram')
nono:newMap ('nonograms/nono-3.png')
nono:shortLeftBar ()
nono:shortTopBar ()
--print ('Multisolution:', tostring(nono:isMultisolution()))

function love.load()
	love.window.setMode(1400, 500, {resizable=true, borderless=false})
	width, height = love.graphics.getDimensions( )

	
end

 
function love.update(dt)
	
end


function love.draw()
	nono:drawSolution(dx, dy)
	nono:drawLeftBar()
	nono:drawTopBar()
	if not nono.solved then
		nono:drawGuess()
		nono:drawGrid()
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed (x, y, button, istouch, presses)
	nono:mousepressed (x, y, button, istouch, presses)
end

function love.mousemoved (x, y, dx, dy, istouch)
	nono:mousemoved (x, y, dx, dy, istouch)
end

function love.mousereleased (x, y, button, istouch, presses)
	nono:mousereleased (x, y, button, istouch, presses)
end