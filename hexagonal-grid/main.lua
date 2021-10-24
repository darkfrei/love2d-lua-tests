-- hexagonal grid

-- License CC0 (Creative Commons license) (c) darkfrei, 2021


function drawHexGrid ()
	local dh = gridSize*3^0.5/3
	
	for i = 1, 14 do
		for j = 1, 9 do
			local x = i*gridSize +0.5
			local y = j*(gridSize*0.25+dh) + 0.5
			
			if j%2==1 then
				x=x-gridSize/2
			end
			
			local x1 = x + gridSize/2
			local y1 = y - gridSize/4
			
			local x2 = x + gridSize
			local y2 = y
			
			local x3 = x + gridSize
			local y3 = y + dh
			
			local x4 = x + gridSize/2
			local y4 = y + dh + gridSize/4
			
			local x5 = x
			local y5 = y + dh
			
			local verticles = {x,y,x1,y1,x2,y2,x3,y3,x4,y4,x5,y5}
			
--			love.graphics.line(verticles)
			
			love.graphics.setColor(224/255,244/255,252/255)
			love.graphics.polygon('fill', verticles)
			
			love.graphics.setColor(178/255,228/255,249/255)
			love.graphics.setLineWidth(3)
			love.graphics.polygon('line', verticles)
		end
	end
	
end

function love.load()
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	width, height = love.graphics.getDimensions( )


	gridSize = 120
	canvas = love.graphics.newCanvas()
	
	love.graphics.setCanvas(canvas)
		drawHexGrid ()
	love.graphics.setCanvas()
end

 
function love.update(dt)
	
end


function love.draw()
	love.graphics.setColor(1,1,1)
	love.graphics.draw(canvas)
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