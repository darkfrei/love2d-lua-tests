-- License CC0 (Creative Commons license) (c) darkfrei, 2021

window = require ("zoom-and-move-window")


function get_y (x)
	return (math.cos(x*s1)+1)*s2
end

function get_dy (x)
	return -math.sin(x*s1)*s3
end

function love.load()
	window:load()
	
	
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-100, {resizable=true, borderless=false})
	end
	
	
	
	w, h = love.graphics.getDimensions()
	window.translate={x=0, y=h/2}
	
--	s1, s2 = math.pi/w, h/2
--	s3 = 1.5*1.5*math.pi/4	
	s1, s2 = 1, 1
	s3 = 1, 1
	
	f = {}
	for x = 0, w do
		local y = math.sin (2*math.pi*x/w)
		table.insert(f, x)
		table.insert(f, y)
	end
	df = {}
	for x = 0, w do
		local y = math.cos (2*math.pi*x/w)
		table.insert(df, x)
		table.insert(df, y)
	end
	ddf = {}
	for x = 0, w do
		local y = -math.sin(2*math.pi*x/w)
		table.insert(ddf, x)
		table.insert(ddf, y)
	end
	
	
	
	local y, dy = f[2], df[2]
	
--	euler
	local step = 10
	y_euler_line = {}
	dy_euler_line = {}
	ddy_euler_line = {}
	for x = 0, w, step do
		local dt = x > 0 and 2*math.pi*step/w or 0
		local ddy = -math.sin(2*math.pi*(x)/w)
		dy = dy + ddy*dt
		if x > 0 then
			y = y + dy*dt
		end
		
		
		table.insert(y_euler_line, x)
		table.insert(y_euler_line, y)
		table.insert(dy_euler_line, x)
		table.insert(dy_euler_line, dy)
		table.insert(ddy_euler_line, x)
		table.insert(ddy_euler_line, ddy)
	end
	
	print (f[1]..' '..f[2])
	print (y_euler_line[1]..' '..y_euler_line[2])
end

 
function love.update(dt)
	window:update(dt)
end

function rescale (line)
	local sx, sy = love.graphics.getDimensions()
	local new_line = {}
	for i = 1, #line-1, 2 do
		new_line[i] = line[i]
		new_line[i+1] = -line[i+1] * sy/2
	end
--	print (line[#line]..' '..new_line[#line])
	return new_line
end

function love.draw()
	window:draw()
--	love.graphics.scale( w/100, -1 )
	love.graphics.setLineWidth (2)
	love.graphics.setColor(0.5,0.5,0.5)
	love.graphics.line(rescale({0,0,w,0}))

	love.graphics.setLineWidth (3)
	love.graphics.setColor(0,1,0)
	love.graphics.line(rescale(f))
	love.graphics.setColor(1,1,0)
	love.graphics.line(rescale(df))
	love.graphics.setColor(1,0,0)
	love.graphics.line(rescale(ddf))
	
	love.graphics.setLineWidth (1)
	love.graphics.setColor(1,1,1)
	love.graphics.line(rescale(y_euler_line))
	love.graphics.setColor(0,1,1)
	love.graphics.line(rescale(dy_euler_line))
	love.graphics.setColor(0,0,1)
	love.graphics.line(rescale(ddy_euler_line))
end

-------------------------------------------------------------------------

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end

function love.wheelmoved(x, y)
	window:wheelmoved(x, y)
end

function love.mousepressed(x, y, button, istouch)
	window:mousepressed(x, y, button, istouch)
end
