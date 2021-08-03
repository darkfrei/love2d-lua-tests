-- settings

grid_size = 32
road_size = 20
car_h=20
car_w=12

function get_line_length (line)
	local length = 0
	for i = 1, #line-3, 2 do
		local l = ((line[i+2]-line[i])^2+(line[i+3]-line[i+1])^2)^0.5
		length = length + l
	end
	return length
end

function new_road (line, typ)
	local road = {}
	road.id = #roads + 1
	road.line = line
	road.line_length = get_line_length (line)
--	road.type = "generator"
	road.frequency = 1
--	road.type = "terminator"
	road.type = typ or "normal"
	road.color = {math.random (60, 120)/255, math.random (60, 120)/255, math.random (60, 120)/255}
	
	road.cars = {}
	
	road.prev = {}
	road.next = {}
	
	roads[#roads+1] = road
end

function love.load()
	
	width, height = 480, 320 -- units, not pixels
	unit = road_size
	scale = 2
--	scale = 6
	love.window.setMode( width*scale, height*scale, {resizable=true} )
	love.graphics.setDefaultFilter( 'nearest', 'nearest' )
	love.graphics.setLineStyle( "rough" )

	map = {}
	for i = 0, (width-unit)/unit do
		map[i] = {}
		for j = 0, (height-unit)/unit do
			map[i][j] = 0
		end
	end
	
	mouse_line = {points = {}, pressed = false, last = {x=0, y=0}}
	lines = {}
	roads = {}
	agents = {}

	topology = {}
	crossing_points = {}
	
	crosslines = {}
end


function create_agent (line)
	local agent = {}
	agent.line = line
	agent.t = 0
	agent.s = 0
	agent.max_v = 30
--	agent.v = agent.max_v
	agent.v = 0
	agent.a = 5
	agent.sign = 1
--	agent.position = {x=line[1], y=line[2]}
	agent.x = line[1]
	agent.y = line[2]
	agent.vx = 0
	agent.vy = 0
	agent.n = 1 -- number of section
	agent.rs = 0 -- section path relative to section length
	
	
	table.insert (agents, agent)
end

function clamp (value, min, max)
	min = min or 0
	max = max or 1
	if value < min then return min end
	if value > max then return max end
	return value
end

function get_segment (line, n)
	local i = (n-1)*2+1
	local x1, y1, x2, y2 = line[i], line[i+1], line[i+2], line[i+3]
	return x1, y1, x2, y2
end

function is_last_segment (line, n)
--	local i = (n-1)*2+1
	if line[(n-1)*2+3] then return false else return true end
end

function update_agents (dt)
	for i, agent in pairs (agents) do
		agent.v = clamp (agent.v+dt*agent.a, 0, agent.max_v)
		
		agent.s = agent.s + dt*agent.v -- total distance
		agent.t = agent.t + dt -- total time
		
		local line = agent.line
		local n = agent.n -- number of segment
		local x1, y1, x2, y2 = get_segment (line, n)
		
		local sq_section = (x2-x1)^2+(y2-y1)^2
		local sq_agent = (agent.x-x1)^2+(agent.y-y1)^2
		agent.rs = (sq_agent/sq_section)^0.5 -- relation of section, 0 to 1
		if agent.rs > 1 then
			n = n + 1
			if is_last_segment (line, n) then 
				n = 1
--				agent.x, agent.y = line[(n-1)/2+1], line[n+1]
			end
			agent.n = n
			local t1 = math.atan2(y2-y1, x2-x1)
			x1, y1, x2, y2 = get_segment (line, n)
			local t2 = math.atan2(y2-y1, x2-x1)
--			local t3 = t2-t1 < -math.pi/2 and 2*math.pi or t2-t1 > math.pi/2 and -2*math.pi or 0
			local t3 = t2-t1 < -math.pi and 2*math.pi or t2-t1 > math.pi and -2*math.pi or 0
--			print (t1, t2, t2-t1) -- 3.1082716577115	-3.0764674902554	-6.184739147967
--			if t2-t1 < -math.pi/2 then
----				print (t1, t2, t2-t1+2*math.pi)
--			elseif t2-t1 > math.pi/2 then
--				-- -2.8632929945847	3.1415926535898	2.8632929945847
----				print (t1, t2, t2-t1-2*math.pi) -- 
--			else
----				print (t1, t2, t2-t1) -- positive when clockwise
--			end
--			print (math.floor(t1*1000+0.5)/1000, math.floor(t2*1000+0.5)/1000, math.floor((t2-t1+t3)*1000+0.5)/1000)
				
			agent.x, agent.y = x1, y1
			
			sq_section = (x2-x1)^2+(y2-y1)^2

			local s = sq_section^0.5
			agent.vx = (x2-x1)/s*agent.v
			agent.vy = (y2-y1)/s*agent.v
			agent.x = x1
			agent.y = y1
		end
		
		local s = sq_section^0.5
		agent.vx = (x2-x1)/s*agent.v
		agent.vy = (y2-y1)/s*agent.v

		agent.x = agent.x + dt*agent.vx
		agent.y = agent.y + dt*agent.vy
	end
end

function love.update(dt)
	update_agents (dt)
end

function draw_mouse_line ()
	love.graphics.setLineWidth(1)
	local line = {}
	for i, point in ipairs (mouse_line.points) do
		table.insert (line, point.x/scale)
		table.insert (line, point.y/scale)
	end
	if #line >4 then
		love.graphics.setColor(1,1,0)
		love.graphics.line(line)
	end
--	table.insert (lines, line)
end

function draw_map ()
	love.graphics.setLineWidth(1)
	love.graphics.setColor(.1,.1,.1)
	for i, js in pairs (map) do
		for j, value in pairs (js) do
			love.graphics.rectangle('line', i*unit, j*unit, unit, unit)
		end
	end
end

function draw_mouse_poiner ()
	love.graphics.setLineWidth(1)
	if mouse_line.pressed then
		love.graphics.circle('line', love.mouse.getX( )/scale, love.mouse.getY( )/scale, 0.5*unit)
	else
		love.graphics.circle('line', love.mouse.getX( )/scale, love.mouse.getY( )/scale, 0.25*unit)
	end
end

function draw_line_points (line)
	love.graphics.setLineWidth(1)
	love.graphics.setColor(0,1,0)
	for i = 1, #line-1, 2 do
		love.graphics.circle('fill', line[i], line[i+1], 2)
	end
end

function draw_roads ()
	
	love.graphics.setLineWidth( 20 )

	
	
	for i, road in pairs (roads) do
		local line = road.line
		love.graphics.setColor(road.color)
		love.graphics.circle('fill', line[1], line[2], 20/2)
		love.graphics.line(line)
		love.graphics.circle('fill', line[#line-1], line[#line], 20/2)
		
--		draw_line_points (line)
	end

end

function draw_lines ()
	local line_width = love.graphics.getLineWidth( )
--	love.graphics.setLineWidth( 2 )

	
	
	for i, line in pairs (lines) do
		love.graphics.setLineWidth(2)
		love.graphics.setColor(1,1,1)
		
		love.graphics.circle('fill', line[1], line[2], 2)
		love.graphics.line(line)
		love.graphics.circle('fill', line[#line-1], line[#line], 2)
		
		love.graphics.setLineWidth(1)
		draw_line_points (line)
	end

end


function draw_crossing_points ()
	love.graphics.setColor(0,1,0)
	for i, crossing in pairs (crossing_points) do
		love.graphics.circle ('line', crossing.x, crossing.y, 5)
--		love.graphics.print((crossing.x ..' '.. crossing.y), crossing.x, crossing.y)
	end
end


function draw_crosslines ()
	love.graphics.setColor(0,1,0)
	for i, line in pairs (crosslines) do
		love.graphics.line(line)
		
	end
end


function love.draw()
	
	love.graphics.scale(scale)
	
	draw_map ()

	draw_roads ()
	draw_lines ()

	draw_mouse_line ()
	
	love.graphics.setColor(1,0,0)
	for i, agent in pairs (agents) do
		local s = (agent.n-1)/2+agent.rs
		local sl = 0.25
		love.graphics.circle('line', agent.x, agent.y, 0.25*unit)
		love.graphics.line(agent.x-sl*agent.vx, agent.y-sl*agent.vy, agent.x+sl*agent.vx, agent.y+sl*agent.vy)
--		love.graphics.print(string.format ("%#0.1f", s), agent.x, agent.y)
--		love.graphics.print(string.format ("%#0.2f", agent.t), agent.x, agent.y)
--		love.graphics.print(string.format ("%#0.2f", agent.s), agent.x, agent.y+15)
	end

	draw_crossing_points ()
	draw_crosslines ()
	
	draw_mouse_poiner ()
	
	
	love.graphics.print (tostring(mouse_line.pressed))
	love.graphics.print (tostring(#mouse_line.points), 0, 15)
	love.graphics.print (tostring(#lines), 0, 30)
end


function love.mousepressed(x, y, button, istouch)
	if button == 1 then
		mouse_line.pressed = true
		mouse_line.last = {x=x, y=y}
		mouse_line.points = {}
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
--	local ds = 0.5*unit/scale
	local ds = 0.5*unit*scale
	if mouse_line.pressed then
		if ((x-mouse_line.last.x)^2+(y-mouse_line.last.y)^2) >= (ds)^2 then
			local point = mouse_line.last
			mouse_line.last = {x=x, y=y}
			table.insert (mouse_line.points, point)
		end
	end
end

function smooth_line (line, n)
	n = n or 1
	
	local sline = {}
	sline[1] = line[1]
	sline[2] = line[2]
	sline[#line-1] = line[#line-1]
	sline[#line] = line[#line]
	for j = 1, n do
		for i = 3, #line-3, 2 do
			sline[i] = 0.5*line[i] + 0.25*line[i-2] + 0.25*line[i+2]
			sline[i+1] = 0.5*line[i+1] + 0.25*line[i-1] + 0.25*line[i+3]
		end
		line = sline
	end
	return line
end

function get_intersection (ax, ay, bx, by, cx, cy, dx, dy) -- start end start end
	local d = (ax-bx)*(cy-dy)-(ay-by)*(cx-dx)
	if d == 0 then return end
	local a, b = ax*by-ay*bx, cx*dy-cy*dx
	local x = (a*(cx-dx) - b*(ax-bx))/d
	local y = (a*(cy-dy) - b*(ay-by))/d
	if x <= math.max(ax, bx) and x >= math.min(ax, bx) and
		x <= math.max(cx, dx) and x >= math.min(cx, dx) then
			return {x=x, y=y}
	end
end

function cut_line (line, last_index, point)
	local new_line = {point.x, point.y}
	
	for i = last_index, #line do
		new_line[#new_line+1] = line[i]
		line[i] = nil
	end
	table.insert(line, point.x)
	table.insert(line, point.y)
	
	new_road (new_line, typ)
	table.insert (lines, new_line)
end

function find_crossing_points (line)
	local crossings = {}
	for i, line2 in pairs (lines) do
		for j = 1, #line2-3, 2 do
			for k = 1, #line-3, 2 do
				local point = get_intersection(
					line[k], line[k+1], line[k+2], line[k+3], 
					line2[j],line2[j+1],line2[j+2], line2[j+3])
				if point then
--					
					
					table.insert (crossings, {line = line, index=k+2, point = point})
					
					table.insert (crossings, {line = line2, index=j+2, point = point})
					
					table.insert (crossing_points, point)
				end
			end
		end
	end
	for i, crossing in pairs (crossings) do
		cut_line (crossing.line, crossing.index, crossing.point)
	end
end

function love.mousereleased(x, y, button)
	if button == 1 then
		mouse_line.pressed = false
		local line = {}
		for i, point in ipairs (mouse_line.points) do
			table.insert (line, point.x/scale)
			table.insert (line, point.y/scale)
		end
		table.insert (line, x/scale)
		table.insert (line, y/scale)
		if #line > 4 then
			line = smooth_line (line, 1)
		end
		if #line > 2 then
			find_crossing_points (line)
			
			table.insert (lines, line)
			new_road (line, typ)
			
			create_agent (line)
		end
		mouse_line.points = {}
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	elseif key == "kp+" then
		scale = scale*2^(1/2)
	elseif key == "kp-" then
		scale = scale/2^(1/2)
	end
end