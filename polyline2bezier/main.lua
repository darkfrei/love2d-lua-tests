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

	bezCurves = nil
	
	colors = {}
end

 
function love.update(dt)
	
end


function love.draw()
	
	
	if bezCurves then
		for i, verticles in ipairs (bezCurves) do
			if not colors[i] then
				colors[i] = {0.7+0.5*math.random(),0.5+0.5*math.random(),0.5+0.5*math.random()}
			end
			love.graphics.setColor(colors[i])
			local x, y = verticles[1], verticles[2]
			love.graphics.circle ('line', x, y, 3)
--			print ('#verticles', #verticles)
			local curve = love.math.newBezierCurve(verticles)
			
			
			love.graphics.line(curve:render())
--			DrawPolyline.draw(verticles)
		end
		local verticles = bezCurves[#bezCurves]
		local x, y = verticles[#verticles-1], verticles[#verticles]
		love.graphics.circle ('line', x, y, 3)
	else
		DrawPolyline.draw(line)
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	bezCurves = nil
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
		
		bezCurves = P2B.polyline2bezier (line, 5000, true)
	elseif button == 2 then -- right mouse button
	end
end

