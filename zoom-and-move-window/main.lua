-- License CC0 (Creative Commons license) (c) darkfrei, 2022


local Screen = require ("zoom-and-move-window")

local line = require ("line") -- example curve

function love.load()
	Screen:load()
	
end


function love.update(dt)
	
	
end


function love.draw()
	Screen:draw()

	
	
--	example graphics:
--	draws the circle in the middle of the screen
	love.graphics.setColor(1,1,1)
	love.graphics.circle('line',0, 0,300)
	
--	draws xy axies
	love.graphics.line(0,-800,0,800)
	love.graphics.line(-800,0,800,0)
	love.graphics.print ('O', 2, -15)
--	love.graphics.print ('(O: ' .. Screen.translate.x .. ' ' .. Screen.translate.y .. ')', 2, 2)
	
--	draws custom graphics
	love.graphics.setColor(1,1,0)
	love.graphics.line(line)
	
	
	-- debug GUI
	local mx = love.mouse.getX()
	local my = love.mouse.getY()
	love.graphics.origin()
	love.graphics.setColor(0,1,0)
	love.graphics.print ('Debug GUI:', 1, 0)
	love.graphics.print('x: ' .. mx ..', y: '.. my, 1, 15) 
	love.graphics.print('x: ' .. (mx-Screen.translate.x)/Screen.scale ..
		', y: '.. (my-Screen.translate.y)/Screen.scale, 1, 30) 
	
	love.graphics.print('zoom ' .. Screen.scale, 1, 45) 
	love.graphics.print('tr ' .. Screen.translate.x ..', '.. Screen.translate.y, 1, 60) 
end

 
function love.wheelmoved(x, y)
	Screen:wheelmoved(x, y)
end

function love.mousepressed (x, y, button, istouch, presses)
	Screen:mousepressed (x, y, button, istouch, presses)
	
end

function love.mousemoved (x, y, dx, dy, istouch)
	Screen:mousemoved (x, y, dx, dy, istouch)
	
end

function love.mousereleased (x, y, button)
	Screen:mousereleased (x, y, button)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

-- touch screen

function love.touchpressed (id, x, y, dx, dy, pressure)
	Screen:touchpressed (id, x, y, dx, dy, pressure)
	
end

function love.touchmoved (id, x, y, dx, dy, pressure)
    Screen:touchmoved (id, x, y, dx, dy, pressure)
	
end

function love.touchreleased (id, x, y, dx, dy, pressure)
    Screen:touchreleased (id, x, y, dx, dy, pressure)
	
end






