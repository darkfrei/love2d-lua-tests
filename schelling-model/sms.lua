-- Schelling's model of segregation

--[[
agent_parts = {4, 4, 2} - parts

--]]

local sms = {}

function weighted_random (weights, summ)
	-- from dla-cluster-03
	if not summ then 
		summ = 0
		for i, weight in pairs (weights) do
			summ = summ + weight
		end
		if summ == 0 then return end
		
	end
	local value = math.random (summ)
	summ = 0
	for i, weight in pairs (weights) do
		summ = summ + weight
		if value <= summ then
			return i, weight
		end
	end
end

function sms.create_map (map_width, map_height, n_empties, agent_parts)
	local map = {}
	local ns = {n_empties}
	local parts = 0
	for i, agent_part in pairs (agent_parts) do
		parts = parts + agent_part
	end
	for i, agent_part in pairs (agent_parts) do
		table.insert (ns, math.floor((map_width*map_height-n_empties)*agent_part/parts))
	end
	
	sms.ns = {}
	for i, v in pairs (ns) do
		sms.ns[i] = ns[i]
	end
	
	for i = 1, map_width do
		map[i] = {}
		for j = 1, map_height do
			local rnd_in = weighted_random (ns) -- random index of n
--			print(ns[1])
			if rnd_in then
				ns[rnd_in] = ns[rnd_in] - 1
				map[i][j] = rnd_in - 1
			else
				map[i][j] = 0
			end
		end
	end
	
	return map
end

sms.neighbours = {
	{i=-1,j=-1},	{i=0,j=-1},	{i=1,j=-1},
	{i=-1,j= 0},				{i=1,j= 0},
	{i=-1,j= 1},	{i=0,j= 1},	{i=1,j= 1}}

function sms.get_n_neighbours (map, i, j, n_agent) -- n_agent is number of agent
	local p, f = 0, 0 -- partner, foreign
	for k, neighbour in pairs(sms.neighbours) do
		local i1, j1 = i+neighbour.i, j+neighbour.j
		if map[i1] and map[i1][j1] and map[i1][j1] > 0 then
			if map[i1][j1] == n_agent then
				p = p + 1
			else
				f = f + 1
			end
		end
	end
	
	return p, f
end

sms.rules = {min = 0.6}

return sms