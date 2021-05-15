window = require ("zoom-and-move-window")

local line = require ("line") -- example curve

function love.load()
	window:load()
	
end


function love.update(dt)
	window:update(dt)
	
end


function love.draw()
	window:draw()

	
	
--	example graphics:
--	draws the circle in the middle of the screen
	love.graphics.setColor(1,1,1)
	love.graphics.circle('line',0, 0,300)
	
--	draws xy axies
	love.graphics.line(0,-800,0,800)
	love.graphics.line(-800,0,800,0)
	love.graphics.print ('O', 2, -15)
--	love.graphics.print ('(O: ' .. window.translate.x .. ' ' .. window.translate.y .. ')', 2, 2)
	
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
	love.graphics.print('x: ' .. (mx-window.translate.x)/window.zoom ..
		', y: '.. (my-window.translate.y)/window.zoom, 1, 30) 
	
	love.graphics.print('zoom ' .. window.zoom, 1, 45) 
	love.graphics.print('tr ' .. window.translate.x ..', '.. window.translate.y, 1, 60) 
	love.graphics.print('dscale: ' .. window.dscale , 1, 75)
end


--function love.mousepressed(x, y, k)
--	window:mousepressed(x, y, k)
--end

 
function love.wheelmoved(x, y)
	window:wheelmoved(x, y)
end


function love.mousepressed(x, y, button, istouch)
	window:mousepressed(x, y, k)
end










