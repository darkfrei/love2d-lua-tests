-- License CC0 (Creative Commons license) -- 2021 (c) darkfrei

sin = math.sin
cos = math.cos

function draw_circle (circle, outline)
	if circle.color then
		love.graphics.setColor(circle.color)
	end
	love.graphics.circle(
		circle[1] or circle.mode or 'fill', 
		circle[2] or circle.x or circle.x2 or 0,
		circle[3] or circle.y or circle.y2 or 0,
		circle[4] or circle.radius or 10
		)
	if outline then
		love.graphics.setColor(0,0,0)
		love.graphics.circle(
		circle[1] or circle.mode or 'line', 
		circle[2] or circle.x or circle.x2 or 0,
		circle[3] or circle.y or circle.y2 or 0,
		circle[4] or circle.radius or 10
		)
	end
end

function get_color (i, maxi, alpha)
	alpha = alpha or 1
	if maxi == 1 then return {1,1,1,alpha} end
	local t = (i-1)/(maxi-1)
	local r = 2-4*t
	local g = t < 1/2 and 4*t or 4-4*t
	local b = -2 + 4*t
--	print ('t: '.. t..' r: '.. r .. ' g: '..g..' b: '..b)
	r,g,b=r>0 and r^0.5 or r, g>0 and g^0.5 or g, b>0 and b^0.5 or b
--	r,g,b=math.max(r,0.1), math.max(g,0.1), math.max(b,0.1)
	return {r,g,b,alpha}
end

function load_new_level (n_level)
	n_level = n_level or 1
	
	local width, height = love.graphics.getDimensions( )
	local border = 32
	x0, y0 = width/2, height/2
	local big_radius = math.min(width, height)/2 -2*border
	local small_radius = big_radius * 0.5
	local ball_radius = 20
	pendulums = {}
	for i = 1, n_level do
		pendulums[#pendulums+1] = {
			l1 = small_radius, m1 = 10, 
			O1 = (math.random()+0.5)*math.pi, w1 = 0, x1 = nil, y1 = nil,
			l2 = big_radius-small_radius-ball_radius, m2 = 10, 
			O2 = (math.random()*0.8+0.1+0.5)*math.pi, w2 = 0, x2 = nil, y2 = nil,
			color = get_color (i, n_level, 1),
			radius = ball_radius
		}
	end
	main_circle = {mode='fill', x=x0, y=y0, radius=big_radius, color={.9,.9,.95}}
	
	slow_mode = {x=x0, y=y0+small_radius, radius = 5, color = {1,1,0},
		visible = false, taken = false,
		timer_to_spawn = 4+n_level, timer_slow_down = 1+n_level}
--	slow_mode.timer_to_spawn

	love.graphics.setCanvas(path_canvas)
        love.graphics.clear()
	love.graphics.setCanvas()
	
	level_timer = 9 + n_level
end

function reset_char ()
	char.x, char.y = x0-char.w/2, y0
	char.vx, char.vy = 0, 0
	char.ax=100
--	char.jumps = 1
	char.jumps = n_level
end

--function gen_level_number(n_level)
--	big_N = {}
--	local prev_font = love.graphics.getFont( )
--	local size = 72
--	local Font = love.graphics.setNewFont( size )
--	Font:setFilter("linear", "nearest")
	
	
--end

function love.load()
	love.window.setTitle('Double Pendulum Jump Game')

	
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddwidth > 1920 and ddheight > 1080 then
--		love.window.setMode(1920, 1080, {resizable=false, borderless=true})
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
--		love.window.setMode(1920-2, 1080-46, {resizable=true, borderless=false})
	else
		
	end
	
	
	g = 9.81*10*10
	deaths = 0
	total_time = 0
	
	pause = false
	show_dots, show_lines, show_paths = true, true, true
	
	path_canvas = love.graphics.newCanvas(love.graphics.getDimensions( ))
	-- char
	
	local charimg = love.graphics.newImage("char.png")
	local imgwidth, imgheight = charimg:getDimensions( )
	local imgscale = 2
	
	charimg:setFilter( "linear", "nearest")

	char = {img = charimg, w=imgwidth*imgscale, h=(imgheight-32)*imgscale, scale = imgscale, sx=imgscale}
	
	n_level = 1
	load_new_level (n_level)
	reset_char ()
	
	
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
	
	p.x2old = p.x2
	p.y2old = p.y2
	
	p.x2 = p.x1+p.l2*sin(p.O2)
	p.y2 = p.y1+p.l2*cos(p.O2)
end

function update_slow_down (dt)
	if not slow_mode.taken then 
		if level_timer < slow_mode.timer_to_spawn then
			if not slow_mode.visible then
				slow_mode.visible = true
			end
			
		end
		if slow_mode.visible then
			local collsion = circleVsRect(slow_mode.x, slow_mode.y, slow_mode.radius, 
				char.x, char.y, char.w, char.h)
			if collsion then
				slow_mode.visible = false
				slow_mode.taken = true
			end
		end
		
	elseif slow_mode.timer_slow_down > 0 then
		slow_mode.timer_slow_down = slow_mode.timer_slow_down - dt
		return dt/2
	end
	return dt
end

function love.update(dt)
	if pause then return end
	
	
	total_time = total_time + dt
	
	dt = update_slow_down (dt)
	
	level_timer = level_timer - dt
	
	if level_timer <= 0 then
		n_level = n_level + 1
		load_new_level (n_level)
	elseif new_game then
		new_game = false
		load_new_level (n_level)
	end
	
	if love.keyboard.isDown('d', 'right') then
		char.vx = math.max (char.vx + dt*char.ax, 300)
	elseif love.keyboard.isDown('a', 'left') then
		char.vx = math.min (char.vx - dt*char.ax, -300)
--	elseif char.vx > 0 then
--		char.vx = math.min (char.vx - dt * char.ax, 0)
--	elseif char.vx < 0 then
--		char.vx = math.max (char.vx + dt * char.ax, 0)
	end
	
	
	
	char.vy = char.vy + g*dt
	char.y = char.y + char.vy*dt
	
	local cx = main_circle.x - char.x - char.w/2
	local cy = main_circle.y - char.y
	local alpha = math.acos(cx/main_circle.radius)
	local cy_min = -main_circle.radius * math.sin(alpha) + char.h
	local cy_max = main_circle.radius * math.sin(alpha)
	local on_ground = false
	if cy < cy_min then
		char.y = main_circle.y - cy_min
--		char.vx = 0
		char.vy = 0
--		char.jumps = 2
		char.jumps = 1 + n_level
		on_ground = true
	elseif cy > cy_max then
		char.y = main_circle.y - cy_max
		char.vy = 0
	end
	
--	char.vx = char.vx + char.ax*dt
	if on_ground then
		if not love.keyboard.isDown('d', 'a', 'up', 'right') then
			if char.vx > 0 then
				char.vx = math.min (char.vx - dt * char.ax, 0)
			elseif char.vx < 0 then
				char.vx = math.max (char.vx + dt * char.ax, 0)
			end
		end
		char.x = char.x + char.vx*dt*sin(alpha)
		
	else
		char.x = char.x + char.vx*dt
	end
	
	if char.vx > 0 then
		char.sx = char.scale
	elseif char.vx < 0 then
		char.sx = -char.scale
	end
	if char.x+char.w > main_circle.x+main_circle.radius then
		char.x = main_circle.x+main_circle.radius - char.w
		char.vx=0
	elseif char.x < main_circle.x-main_circle.radius then
		char.x = main_circle.x-main_circle.radius
		char.vx=0
	end
	
	love.graphics.setCanvas(path_canvas)
	love.graphics.setLineWidth( 1 )
	for i, pendulum in pairs (pendulums) do
		update_pendulum (pendulum, dt)
		
		love.graphics.setColor(pendulum.color)
--		love.graphics.setColor({0,0,0})
--		love.graphics.points(pendulum.x2, pendulum.y2)
		if n_level > 1 and pendulum.x2old then
			love.graphics.line(pendulum.x2, pendulum.y2, pendulum.x2old, pendulum.y2old)
		end
		
		local collsion = circleVsRect(pendulum.x2, pendulum.y2, pendulum.radius, char.x, char.y, char.w, char.h)
		
		if collsion then
			deaths = deaths + 1
			pause = true
			new_game = true
		end
	end	
	love.graphics.setCanvas()
end



local function clamp(n, min, max) -- https://2dengine.com/?p=intersections#Circle_vs_rectangle
--	return n < min and min or n > max and max or n
	return math.min(math.max(n, min), max)
end

function circleVsRect(cx, cy, cr, l, t, w, h) -- https://2dengine.com/?p=intersections#Circle_vs_rectangle
  local dx = clamp(cx, l, l + w) - cx
  local dy = clamp(cy, t, t + h) - cy
  return dx*dx + dy*dy <= cr*cr
end

function disp_time(time) -- https://stackoverflow.com/questions/45364628/lua-4-script-to-convert-seconds-elapsed-to-days-hours-minutes-seconds
  local days = math.floor(time/86400)
  local hours = math.floor(math.mod(time, 86400)/3600)
  local minutes = math.floor(math.mod(time,3600)/60)
  local seconds = math.floor(math.mod(time,60))
  return string.format("%d:%02d:%02d:%02d",days,hours,minutes,seconds)
end

function love.draw()
	love.graphics.setColor(1,1,1)
	love.graphics.setLineWidth( 3 )
	
	love.graphics.print('pendulums: ' .. #pendulums, 30, 30)
	love.graphics.print('FPS: '.. tostring(love.timer.getFPS( )), 30, 30+20)
	love.graphics.print('z: show lines: '.. tostring(show_lines), 30, 30+2*20)
	love.graphics.print('x: show dots: '.. tostring(show_dots), 30, 30+3*20)
	love.graphics.print('c: show paths: '.. tostring(show_paths), 30, 30+4*20)
	
	local is_inside = circleVsRect(main_circle.x, main_circle.y, main_circle.radius, char.x, char.y, char.w, char.h)
	love.graphics.print('inside: '.. tostring(is_inside), 30, 30+6*20)
	
	love.graphics.print('timer: '.. tostring(level_timer), 30, 30+7*20)
	
	love.graphics.print('level: '.. tostring(n_level), 30, 30+8*20)
	love.graphics.print('deaths: '.. tostring(deaths), 30, 30+9*20)
	love.graphics.print('total time: '.. tostring(disp_time(total_time)), 30, 30+10*20)
	
	draw_circle (main_circle)
	
	
	if show_paths then
		love.graphics.setColor(1,1,1)
		love.graphics.draw(path_canvas)
	end
	
	if slow_mode.visible then
		draw_circle(slow_mode, true)
	end
	
	if n_level == 1 then
		love.graphics.setColor(1,1,1)
	elseif n_level < 4 then
		love.graphics.setColor(1,1,0)
	elseif n_level < 6 then
		love.graphics.setColor(0,1,0)
	elseif n_level < 8 then
		love.graphics.setColor(0,1,1)
	elseif n_level < 12 then
		love.graphics.setColor(1,0,0)
	elseif n_level < 18 then
		love.graphics.setColor(1,0,1)
	else
		love.graphics.setColor(0,0,0)
	end
	love.graphics.draw(char.img, 
		char.x+char.w/2, char.y, -- sx, sy
		0, -- rotation
		char.sx, char.scale, 
		char.w/(2*char.scale),32)
--	love.graphics.rectangle('line', char.x, char.y, char.w, char.h)
	
	for i, pendulum in pairs (pendulums) do
		if pendulum.x1 then
			love.graphics.setColor(pendulum.color)
			if show_lines then
				love.graphics.line(x0, y0, pendulum.x1, pendulum.y1)
				love.graphics.line(pendulum.x1, pendulum.y1, pendulum.x2, pendulum.y2)
			end
			if show_dots then
				draw_circle(pendulum, true)
--				love.graphics.circle('fill', pendulum.x1, pendulum.y1, 10)
--				love.graphics.circle('fill', pendulum.x2, pendulum.y2, pendulum.radius)
--				love.graphics.setColor(0,0,0)
--				love.graphics.circle('line', pendulum.x2, pendulum.y2, pendulum.radius)
			end
		end
	end
	
	
end

function love.keypressed(key, scancode, isrepeat)
	if key == "p" then
		pause = not pause
	elseif key == "f11" then
		fullscreen = not fullscreen
		love.window.setFullscreen( fullscreen )
		
	elseif key == "z" then
		show_dots = not show_dots
		
	elseif key == "x" then
		show_lines = not show_lines
		
	elseif key == "c" then
		show_paths = not show_paths
		
--	elseif key == "a" then
--		char.vx = -300
----		char.ax = -100
--	elseif key == "d" then
----		char.ax = 100
--		char.vx =  300
		
	elseif key == "space" or key == "w" or key == "up" then
		if pause and new_game then
			pause = false
			reset_char ()
		elseif char.jumps > 0 then
			char.vy =  -600
			char.jumps = char.jumps - 1
		end
	elseif key == "escape" then
		love.event.quit()
	else
		char.ax = 0
	end
end