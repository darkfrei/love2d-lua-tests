-- License CC0 (Creative Commons license) -- 2021 (c) darkfrei

sin = math.sin
cos = math.cos

function get_color (i, maxi, alpha)
	alpha = alpha or 1
	local t = i/maxi
	local r = 2-4*t
	local g = t < 1/2 and 4*t or 4-4*t
	local b = -2 + 4*t
	print ('t: '.. t..' r: '.. r .. ' g: '..g..' b: '..b)
	return {r,g,b,alpha}
end

function love.load()
	love.window.setMode(1920, 1080, {resizable=false, borderless=true})
	love.graphics.setLineWidth( 2 )
	love.graphics.setBlendMode("alpha")
	
	canvas = love.graphics.newCanvas(1920, 1080)
	
	pendulums = {}
	for i = 1, 10000 do
		pendulums[#pendulums+1] = {
			l1 = 250, m1 = 10, O1 = -7+11, w1 = 0, x1 = nil, y1 = nil,
			l2 = 250, m2 = 10, O2 = 117+(i*10^-6), w2 = 0, x2 = nil, y2 = nil,
--			color = {i/10000, i/10000, 0.25+0.75*i^0.5/100, 0.1}
			color = get_color (i, 10000, 1)
		}
	end
	
	g = 9.81*10
	x0 = love.graphics.getWidth()/2
	y0 = love.graphics.getHeight()/2
	
	buffer = 0
	pause = true
	fullscrean = false
	show_dots = true
	show_lines = true
	
	show_canvas = true
end


function update_pendulum (p, dt)
	local alfa1=(-g*(2*p.m1+p.m2)*sin(p.O1)-g*p.m2*sin(p.O1-2*p.O2)
		-2*p.m2*sin(p.O1-p.O2)*(p.w2*p.w2*p.l2+p.w1*p.w1*p.l1*cos(p.O1-p.O2)))
		/( p.l1*(2*p.m1+p.m2-p.m2*cos(2*p.O1-2*p.O2)))
		
	local alfa2=(2*sin(p.O1-p.O2))*(p.w1*p.w1*p.l1*(p.m1+p.m2)+g*(p.m1+p.m2)*cos(p.O1)
		+p.w2*p.w2*p.l2*p.m2*cos(p.O1-p.O2))/p.l2/(2*p.m1+p.m2-p.m2*cos(2*p.O1 -2*p.O2))

	p.w1=p.w1+dt*alfa1
	p.w2=p.w2+dt*alfa2
	
	p.O1=p.O1+dt*p.w1
	p.O2=p.O2+dt*p.w2
	
	p.x1 = x0+p.l1*sin(p.O1)
	p.y1 = y0+p.l1*cos(p.O1)
	
	p.x2 = p.x1+p.l2*sin(p.O2)
	p.y2 = p.y1+p.l2*cos(p.O2)
	

end


function love.update(dt)
	if pause then return end
	dt = 1/60
	
	for i, pendulum in pairs (pendulums) do
		update_pendulum (pendulum, dt)
	end	
	
	local points = {}
	for i, pendulum in pairs (pendulums) do
		table.insert (points, pendulum.x2)
		table.insert (points, pendulum.y2)
	end	
	
	love.graphics.setCanvas(canvas)
--		love.graphics.setBlendMode("alpha")
--		love.graphics.setBlendMode("alpha", "premultiplied")
--		love.graphics.setBlendMode("multiply", "premultiplied")
--		love.graphics.setBlendMode("lighten", "premultiplied")
--		love.graphics.setBlendMode("add", "alphamultiply")
--		love.graphics.setBlendMode("add", "alphamultiply")
--		love.graphics.setBlendMode("add")
--		love.graphics.setColor(1,1,1, 1/255)
--		love.graphics.setColor(1/8, 1/8, 1/255, 1)
		love.graphics.setColor(1, 1, 1, 1/32)
		love.graphics.points(points)	
	love.graphics.setCanvas()
end


function love.draw()
	love.graphics.setColor(1,1,1)
	love.graphics.setBlendMode("alpha")
	if pause then
		love.graphics.print('press space', 30, 10)
	end
	love.graphics.print('pendulums: ' .. #pendulums, 30, 30)
	love.graphics.print('FPS: '.. tostring(love.timer.getFPS( )), 30, 30+20)
	love.graphics.print('z: show lines: '.. tostring(show_lines), 30, 30+2*20)
	love.graphics.print('x: show dots: '.. tostring(show_dots), 30, 30+3*20)
	love.graphics.print('c: clear canvas', 30, 30+4*20)
	
	if fullscreen then
			love.graphics.scale(2,2)
		else
			love.graphics.scale(1,1)
		end
	
	for i, pendulum in pairs (pendulums) do
		if pendulum.x1 then
			love.graphics.setColor(pendulum.color)
			if show_lines then
				love.graphics.line(x0, y0, pendulum.x1, pendulum.y1)
				love.graphics.line(pendulum.x1, pendulum.y1, pendulum.x2, pendulum.y2)
			end
			if show_dots then
--				love.graphics.circle('fill', pendulum.x1, pendulum.y1, 10)
				love.graphics.circle('fill', pendulum.x2, pendulum.y2, 10)
			end
		end
	end
	love.graphics.setColor(1, 1, 1)
--	love.graphics.setBlendMode("add", "premultiplied")
	love.graphics.draw(canvas, 0, 0)
end

function love.keypressed(key, scancode, isrepeat)
	if key == "space" then
		pause = not pause
	elseif key == "f11" then
		fullscreen = not fullscreen
		love.window.setFullscreen( fullscreen )
		
	elseif key == "z" then
		show_dots = not show_dots
		
	elseif key == "x" then
		show_lines = not show_lines
		
	elseif key == "c" then
		love.graphics.setCanvas(canvas)
			love.graphics.clear()
		love.graphics.setCanvas()
	elseif key == "escape" then
		love.event.quit()
	end
end