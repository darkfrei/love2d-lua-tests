-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function love.load()
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	width, height = love.graphics.getDimensions( )

	time = 0
end

 
function love.update(dt)
	time = time + dt
	t = (-math.cos (time)+1)/2
end


function love.draw()
--	love.graphics.arc( 'fill', x, y, radius, angle1, angle2, segments )
	love.graphics.setColor(0,33/255,124/255)
	love.graphics.arc( 'fill', width/2, height/2, height/3, -math.pi, 0)
	
	love.graphics.setColor(0,94/255,219/255)
	love.graphics.arc( 'fill', width/2, height/2, height/3, -math.pi, -t*math.pi, 90)
	
	love.graphics.setColor(0,0,0)
	love.graphics.arc( 'fill', width/2, height/2, height/(3.5), -math.pi, 0)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end
