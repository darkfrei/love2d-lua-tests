-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function smooth_line (line, factor)
	-- factor from 0 (no smoothnes) to 1 (middle)
	factor = factor or 0.5
	local k = 1-2/3*factor
	local k2 = (1-k)/2
	
	local cline = {}
	for i = 1, #line do
		cline[i] = line[i]
	end
	
	for i = 3, #line-3, 2 do
		line[i] = k*cline[i]+k2*cline[i-2]+k2*cline[i+2]
		line[i+1] = k*cline[i+1]+k2*cline[i-1]+k2*cline[i+3]
	end
end

function generate_path (iy)
	local line = {}
	local max = 4
	for i = 0, max do
		local x = (i/(max+1))*width
		local y = math.random (height)
		table.insert (line, x)
		table.insert (line, y)
	end
	table.insert (line, width)
	table.insert (line, (iy-1)/9*height)
	
	local x1,y1 = line[1], line[2]
	local line2 = {x1,y1}
	for i = 3, #line-1, 2 do
		local x2,y2 = line[i],line[i+1]
		local dx, dy = x2-x1,y2-y1
		local length = (dx*dx+dy*dy)^0.5
		local amount = math.ceil(length/40)
		dx, dy = dx/amount, dy/amount
		for j = 1, amount do
			table.insert (line2, x1+j*dx)
			table.insert (line2, y1+j*dy)
		end
		x1,y1 = x2,y2
	end
	for i = 1, 100 do
		smooth_line (line2, 0.8)
	end
	table.insert (paths, {line = line2})
end

function get_lenght (x1, y1, x2, y2)
	local dx, dy = x2-x1, y2-y1
	local lenght = (dx*dx+dy*dy)^0.5
	return lenght
end

function get_normal (x1, y1, x2, y2)
	local dx, dy = x2-x1, y2-y1
	local lenght = (dx*dx+dy*dy)^0.5
	return dx/lenght, dy/lenght
end

function set_distances (agent)
	local line = agent.line
	local distance = 0
	agent.path_distances = {}
	for n = 1, #line/2-1 do
		local i = (n-1)*2+1
		local lenght = get_lenght (line[i],line[i+1],line[i+2],line[i+3])
		distance = distance + lenght
		table.insert (agent.path_distances, distance)
	end
end

function generate_agent (n_line)
	local agent = {}
	
	local line = paths[n_line].line
	
	agent.line = line
	
	agent.width, agent.height = 40, 20
	
	-- normal
	agent.nx, agent.ny = get_normal (line[1], line[2], line[3], line[4])
	
	agent.traveled_distance = 0
	agent.n_segment = 1
	agent.path_distances = {}
	
	set_distances (agent)
	
	agent.x, agent.y = line[1], line[2]
	agent.max_v = 300
	agent.v = math.random (10, agent.max_v)
	agent.middle = {t=0, s=0, v=0}
	agent.a = 100
	
	agent.angle = math.atan2(agent.ny, agent.nx)
	
	table.insert(agents, agent)
end

function love.load()
	love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	width, height = love.graphics.getDimensions( )
	
	paths = {}
	for i = 1, 10 do
		generate_path (i)
	end
	
	agents = {}
	for i = 1, 30 do
		local n_line = (i-1)%#paths+1
		generate_agent (n_line)
	end
	
end

function reset_agent(agent) 
	local line = agent.line
	agent.x, agent.y = line[1], line[2]
	agent.traveled_distance = 0
	agent.n_segment = 1
	agent.v = math.random (0, agent.max_v)
	agent.middle = {t=0, s=0, v=0}
	
	agent.nx, agent.ny = get_normal (line[1], line[2], line[3], line[4])
	agent.angle = math.atan2(agent.ny, agent.nx)
end

function collision_detection (agent, dt)
	local nx, ny = agent.nx, agent.ny
	
	local narrow_agents = {}
	local gap = 40
	agent.detection_lines = {}
	for i, agent2 in pairs (agents) do
		if not (agent == agent2) 
		and math.abs(agent.x-agent2.x) < 2*gap 
		and math.abs(agent.y-agent2.y) < 2*gap then
			table.insert (narrow_agents, agent2)
		end
	end	
	
	local x1, y1 = agent.x+gap*agent.nx-10*agent.ny, agent.y+gap*agent.ny+10*agent.nx
	for i, agent2 in pairs (narrow_agents) do
		table.insert (agent.detection_lines, {x1, y1, agent2.x, agent2.y})
		local x2, y2 = agent2.x, agent2.y
		local dist = ((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))^0.5
		if dist < gap then
			
			local acceleration1 = 2000*(gap/(dist+10))
			
			local dist2 = ((agent2.x-agent.x)^2+(agent2.y-agent.y)^2)^0.5
			local acceleration2 = 2000*(gap/dist2)
				
			agent.v = math.max(agent.v - math.max (acceleration1, acceleration2) * dt, 10)
		end
	end
end
 
function love.update(dt)
	for i, agent in pairs (agents) do
		agent.v = agent.v + agent.a * dt
		if agent.v > agent.max_v then
			agent.v = agent.max_v
		end
		
		collision_detection (agent, dt)
		
		local ds = agent.v * dt
		
		local critical_distance = agent.path_distances[agent.n_segment]
		
		
		
		if agent.traveled_distance + ds < critical_distance then
			-- continue segment
			agent.traveled_distance = agent.traveled_distance + ds
			
			agent.x = agent.x + ds * agent.nx
			agent.y = agent.y + ds * agent.ny
			
--			agent.middle = {t=0, s=0, v=0}
			agent.middle.t = agent.middle.t + dt
			agent.middle.s = agent.middle.s + ds
			agent.middle.v = agent.middle.s/agent.middle.t
		elseif agent.path_distances[agent.n_segment+1] then
			
			local ds2 = ds-(critical_distance - agent.traveled_distance)
			agent.traveled_distance = agent.traveled_distance + ds
			agent.n_segment = agent.n_segment + 1
			local i = (agent.n_segment-1)*2+1
			local line = agent.line
			agent.x, agent.y = line[i], line[i+1]
			
			agent.nx, agent.ny = get_normal (line[i], line[i+1], line[i+2], line[i+3])
			agent.angle = math.atan2(agent.ny, agent.nx)
			
			
			agent.x = agent.x + ds2 * agent.nx
			agent.y = agent.y + ds2 * agent.ny
			
--			agent.middle = {t=0, s=0, v=0}
			agent.middle.t = agent.middle.t + dt
			agent.middle.s = agent.middle.s + ds
			agent.middle.v = agent.middle.s/agent.middle.t
		else
			reset_agent(agent)
			
		end
		
		
		
	end
end

function draw_paths ()
	love.graphics.setColor (1,1,1)
	for i, path in pairs (paths) do
		local line = path.line
		love.graphics.line (line)
--		for j = 1, #line-1, 2 do
--			love.graphics.circle('line', line[j], line[j+1], 5)
--		end
	end
end

function drawRotatedRectangle(mode, x, y, width, height, angle)
	-- We cannot rotate the rectangle directly, but we
	-- can move and rotate the coordinate system.
	love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.rotate(angle)
	love.graphics.rectangle(mode, -width/2, -height/2, width, height)
	love.graphics.pop()
end

function draw_agents ()
	
	for i, agent in pairs (agents) do
		
		love.graphics.setColor (0,0,0)
		drawRotatedRectangle('fill', agent.x, agent.y, agent.width, agent.height, agent.angle)
		love.graphics.setColor (1,1,1)
		drawRotatedRectangle('line', agent.x, agent.y, agent.width, agent.height, agent.angle)
		
		-- for debug:
--		love.graphics.circle('line', agent.x, agent.y, agent.height/2)
		
--		for i, line in pairs (agent.detection_lines) do
--			love.graphics.line(line)
--		end

--		love.graphics.print (agent.middle.v, agent.x, agent.y)
--		love.graphics.print (agent.middle.s, agent.x, agent.y+20)
--		love.graphics.print (agent.middle.t, agent.x, agent.y+40)
	end
end

function love.draw()
	draw_paths ()
	draw_agents ()
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