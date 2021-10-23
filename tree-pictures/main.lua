-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function draw_tree (x,y,r)
	local n = 150
	for i = 1, n do
--		local a = math.random ()*2*math.pi
--		local a = 2*math.pi*math.random()*0.01 + 8*i
		local a = math.random()*0.001*i + 9*i+math.random()*0.5
		local nx, ny = math.cos(a), math.sin(a)
		local r1 = 1/7*r
--		local s = math.random()*(r-r1)
--		local s = ((n-i)/n)^0.4*(r-r1)
		local r2 = ((n-i)/n)^0.4
		local s = r2*(r-r1)
		love.graphics.setColor(0,0,0)
--		love.graphics.setColor(1,1,1)
--		love.graphics.setBlendMode( 'alpha' )
		love.graphics.circle('fill', x+s*nx, y+s*ny, r1)
--		love.graphics.setColor(0,0,0,0)
--		love.graphics.setBlendMode( 'replace' )
		love.graphics.setColor(172/255,196/255,76/255)
		love.graphics.circle('fill', x+s*nx, y+s*ny, 0.9*r1)
	end
	love.graphics.setBlendMode( 'alpha' )
end

function love.load()
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
		print('ddheight: ' .. ddheight)
		love.window.setMode(1080, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	width, height = love.graphics.getDimensions( )

	canvas = love.graphics.newCanvas(width,height, {msaa=8})
--	canvas = love.graphics.newCanvas(width,height, {dpiscale=2})
	
	love.graphics.setCanvas(canvas)
		draw_tree (width/2, height/2, math.min (width, height)/2)
	love.graphics.setCanvas()
end

 
function love.update(dt)
	
end


function love.draw()
	love.graphics.setBackgroundColor(1,1,1)
	love.graphics.setColor(1,1,1)
	love.graphics.circle('line', width/2, height/2, math.min (width, height)/2)
	
	love.graphics.draw(canvas)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "return" then
		local filename = tostring(os.tmpname ())
		local time = tostring(os.time ())
--		filename = filename:sub(2) -- removing first character
		filename = filename:sub(2, -2) -- removing first and last characters
		
		print(filename, time)
		canvas:newImageData():encode("png",time..'-'..filename..".png")
		
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