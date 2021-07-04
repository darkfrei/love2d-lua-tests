-- License CC0 (Creative Commons license) (c) darkfrei, 2021

title = "Schelling's model of segregation"
sms = require ('sms')

function love.load()
	love.window.setTitle( title )
	local ww, wh = love.window.getDesktopDimensions()
	love.window.setMode( ww/2, wh/2)
	width, height = love.graphics.getDimensions( )

	rez = 10
--	agent_parts = {5, 4, 3}
	agent_parts = {5, 5}
	colors = {[0] = {1,1,1}, {0.8, 0.8, 0.3}, {0.5, 0.5, 1}, {0.9, 0.4, 0.3}, {0.4, 0.8, 0.4}}
	map_width, map_height = math.floor(width/rez), math.floor(height/rez)
--	map = sms.create_map (map_width, map_height, 200, agent_parts)
	
	percent = 7.2
	map = sms.create_map (map_width, map_height, math.floor(map_width*map_height*(percent/100)), agent_parts)
end

function remove (tabl, i)
	tabl[i] = tabl[#tabl]
	tabl[#tabl] = nil
end
 
function love.update(dt)
	local min_buffer = 0.1
	buffer = buffer or min_buffer
	if buffer < 0 then
		buffer = buffer + min_buffer
	else
		buffer = buffer - dt
		return
	end
	
	local moving_agents = {}
	local vacancies = {}
	local new_map = {}
	
	for i, js in pairs (map) do
		for j, n_agent in pairs (js) do
			-- n_agent = map[i][j]
			local n_partners, n_foreigns = sms.get_n_neighbours (map, i, j, n_agent)
			if n_agent == 0 then
				table.insert (vacancies, {i=i, j=j})
			elseif n_partners/(n_partners+n_foreigns) <= sms.rules.min then
				table.insert (moving_agents, {i=i, j=j, n = n_agent})
			else
				-- stable
			end
		end
	end
	local n_movings = math.min (#moving_agents, #vacancies)
	for k = 1, n_movings do
		local i_agent = math.random(#moving_agents)
		local agent = moving_agents[i_agent]
		local i_vacan = math.random(#vacancies)
		local vacan = vacancies[i_vacan]
		map[agent.i][agent.j] = 0
		map[vacan.i][vacan.j] = agent.n
		
		remove (moving_agents, i_agent)
		remove (vacancies, i_vacan)
	end
end


function love.draw()
	
	-- draw map
	for i, js in pairs (map) do
		for j, n_agent in pairs (js) do
			local color = colors[n_agent]
			if not color then
				color = {0.5+0.5*math.random (), 0.5+0.5*math.random (), 0.5+0.5*math.random ()}
				colors[n_agent] = color
			end
			love.graphics.setColor(color)
			love.graphics.rectangle('fill', (i-1)*rez, (j-1)*rez, rez, rez)
		end
	end
	
	love.graphics.setColor(1,1,1)
	love.graphics.rectangle('fill',0,0,150,20*(4+#sms.ns))
	
	love.graphics.setColor(0,0,0)
	love.graphics.print ('[z, x] less/more colors')
	love.graphics.print ('[c, v] min similar ' .. sms.rules.min, 0, 20)
	love.graphics.print ('[b, n] percent free ' .. percent, 0, 40)
	for i, amount in pairs (sms.ns) do
		if i == 1 then
			love.graphics.print ('free: ' .. amount, 0, 40+i*20)
		else
			love.graphics.print (i-1 .. ': ' .. amount, 0, 40+i*20)
		end
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "z" then
		agent_parts[#agent_parts] = nil
		for i = 1, #agent_parts do
			math.random (3, 6)
		end
		map = sms.create_map (map_width, map_height, math.floor(map_width*map_height*(percent/100)), agent_parts)
	elseif key == "x" then
		table.insert (agent_parts, math.random (3, 6))
		map = sms.create_map (map_width, map_height, math.floor(map_width*map_height*(percent/100)), agent_parts)
	elseif key == "c" then
		sms.rules.min = sms.rules.min - 0.01
	elseif key == "v" then
		sms.rules.min = sms.rules.min + 0.01
	elseif key == "b" then
		percent = percent - 0.1
		map = sms.create_map (map_width, map_height, math.floor(map_width*map_height*(percent/100)), agent_parts)
	elseif key == "n" then
		percent = percent + 0.1
		map = sms.create_map (map_width, map_height, math.floor(map_width*map_height*(percent/100)), agent_parts)
	elseif key == "escape" then
		love.event.quit()
	end
end