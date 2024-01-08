-- License CC0 (Creative Commons license) (c) darkfrei, 2023

local geometry = require ('geometry')
local sat = require ('sat')


function love.load()
	poly1 = geometry.createPolygon(450, 400, 3, 100, -1.0)
	
	poly2 = geometry.createPolygon(500, 250, 3, 150, -1.57)

	
end


function love.update(dt)
	local speed = 100
	local omega = 1
	local dx, dy, ra = 0,0, 0
	local isScancodeDown = love.keyboard.isScancodeDown
	if isScancodeDown ('a') then dx = dx - dt*speed end
	if isScancodeDown ('d') then dx = dx + dt*speed end
	if isScancodeDown ('w') then dy = dy - dt*speed end
	if isScancodeDown ('s') then dy = dy + dt*speed end
	if isScancodeDown ('q') then ra = ra - dt*omega end
	if isScancodeDown ('e') then ra = ra + dt*omega end
	

	geometry.updatePolygon(poly1, dx, dy, ra, true)
	
	overlap1, overlap2 = sat.checkCollision(poly1.vertices, poly2.vertices)
--	love.window.setTitle (tostring(dist))
end


function love.draw()
	
	if overlap1 then
		love.graphics.setColor (1,0,0)
	else
		love.graphics.setColor (1,1,1)
	end
	geometry.drawPolygon ('line', poly1)
	
	love.graphics.setColor (1,1,1)
	geometry.drawPolygon ('line', poly2)
	
	
	love.graphics.setColor (0,1,0)
	if overlap1 then
		love.graphics.line (overlap1.x, overlap1.y, overlap1.x + overlap1.dx, overlap1.y + overlap1.dy)
		
		love.graphics.line (overlap1.x1, overlap1.y1, overlap1.x2, overlap1.y2)
	end
	
	love.graphics.setColor (0,1,1)
	if overlap2 then
		love.graphics.line (overlap2.x, overlap2.y, overlap2.x + overlap2.dx, overlap2.y + overlap2.dy)
		
		love.graphics.line (overlap2.x1, overlap2.y1, overlap2.x2, overlap2.y2)
	end
	
	love.graphics.setColor (1,1,1)
	love.graphics.print ('WASD to move', 0,0)
	love.graphics.print ('QE to rotate', 0,14)
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