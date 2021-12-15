-- License CC0 (Creative Commons license) (c) darkfrei, 2021

DrawPolyline = require ('draw-polyline')
P2B = require ('polyline2bezier')

function love.load()
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	width, height = love.graphics.getDimensions( )

--	line = {x1, y1, x2, y2...}
	line = {}
	
--	bezier = {line = {x1, y1, x2, y2}, controlPoints = {{x, y}}}

	
end

 
function love.update(dt)
	
end


function love.draw()
	DrawPolyline.draw(line)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
		line = {}
		DrawPolyline.mousepressed(line, x, y, button, istouch, presses )
	elseif button == 2 then -- right mouse button
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
	DrawPolyline.mousemoved(line, x, y, dx, dy, istouch )
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
		DrawPolyline.mousereleased(line, x, y, button, istouch, presses )
		
	elseif button == 2 then -- right mouse button
	end
end

