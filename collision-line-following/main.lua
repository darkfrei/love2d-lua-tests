-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function generate_path (iy)
--	local x1 = 0
--	local y1 = math.random (height)
--	local x2 = width/2
--	local y2 = math.random (height)
--	local x3 = width
--	local y3 = math.random (height)
--	table.insert (paths, {line = {x1,y1,x2,y2,x3,y3}})
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
	table.insert (paths, {line = line})
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

function generate_agent (n_line)
	local agent = {}
	
--	local line = paths[math.random (#paths)].line
	local line = paths[n_line].line
	
	agent.line = line
	
	agent.width, agent.height = 40, 20
	
	-- normal
	agent.nx, agent.ny = get_normal (line[1], line[2], line[3], line[4])
	
	agent.traveled_distance = 0
	agent.n_segment = 1
	agent.path_distances = {}
	
	local distance = 0
	
	agent.path_distances = {}
	
	for n = 1, #line/2-1 do
		local i = (n-1)*2+1
		local lenght = get_lenght (line[i],line[i+1],line[i+2],line[i+3])
		distance = distance + lenght
		table.insert (agent.path_distances, distance)
	end
	
	agent.x, agent.y = line[1], line[2]
	agent.max_v = 200
--	agent.max_v = math.random (150, 250)
--	agent.v = 0
	agent.v = math.random (0, 50)
	agent.middle = {t=0, s=0, v=0}
--	agent.a = 200
	agent.a = math.random (5, 150)
	
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
	for i = 1, 100 do
		local n_line = (i-1)%#paths+1
		generate_agent (n_line)
	end
	
end

function reset_agent(agent) 
	local line = agent.line
	agent.x, agent.y = line[1], line[2]
	
	agent.traveled_distance = 0
	agent.n_segment = 1
	
	agent.a = math.random (5, 150)
	agent.v = math.random (0, 50)
	agent.middle = {t=0, s=0, v=0}
	
	agent.nx, agent.ny = get_normal (line[1], line[2], line[3], line[4])
	agent.angle = math.atan2(agent.ny, agent.nx)
end
 
function love.update(dt)
--	buffer = buffer and buffer + dt or dt
--	if buffer < 0.1 then
--		return
--	else
--		buffer = 0
--		dt = 0.1
--	end
	
	for i, agent in pairs (agents) do
		agent.v = agent.v + agent.a * dt
		if agent.v > agent.max_v then
			agent.v = agent.max_v * (agent.v > 0 and 1 or -1)
		end
		
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
	love.graphics.setColor (1,1,1)
	for i, agent in pairs (agents) do
		
		drawRotatedRectangle('line', agent.x, agent.y, agent.width, agent.height, agent.angle)
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