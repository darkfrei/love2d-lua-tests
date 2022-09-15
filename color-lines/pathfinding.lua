-- easy full pathfinding in Lua

-- local list = pf.getMovesList (map, x1, y1, x2, y2) -- 0 is walkable
-- local nodeMap, solutionFound = pf.getNodeMap (map, x1, y1, x2, y2)

local pf = {}

local dirs = {{x=0, y=-1}, {x=1, y=0}, {x=0, y=1}, {x=-1, y=0}}

local function isTileWalkable (map, x, y)
	return map[y] and map[y][x] and map[y][x] == 0
end



function pf.getNodeMap (map, x1, y1, x2, y2)
	-- fill nodeMap
	local nodeMap = {}
	for y = 1, #map do
		nodeMap[y] = nodeMap[y] or {}
		for x = 1, #map[1] do
			nodeMap[y][x] = false
		end
	end
	
	local nodeList = {}
	-- a is amount of moves from start
	local node = {x=x1, y=y1, a=0, iDir = math.random (4)}
	table.insert (nodeList, node)
	if not nodeMap[y1] then nodeMap[y1] = {} end
	nodeMap[y1][x1] = node
	local nNodes = 1
	local solutionFound = false
	
	while #nodeList > 0 do
		local node = nodeList[#nodeList] -- last node is faster
--		print ('nodeList', #nodeList, x1, y1)
		nodeList[#nodeList] = nil -- fast removing
		local a = node.a
		local iDir = node.iDir
		
		for i, dir in ipairs (dirs) do
			local x = node.x+dir.x
			local y = node.y+dir.y
			if isTileWalkable (map, x, y) then
				local da = 1
				if not (iDir == i) then
					da = 2
				end
				local node2 = nodeMap[y][x]
				if node2 then
					if (a+da) < node2.a then
						node2.a = a+da
						node2.iDir = i
						table.insert (nodeList, node2)
					end
				else
					local node2 = {x=x, y=y}
					node2.a = a+da
					node2.iDir = i
					nodeMap[y][x] = node2
					table.insert (nodeList, node2)
					nNodes = nNodes + 1
					
					if x == x2 and y == y2 then
						solutionFound = true
						print ('solved', a)
					end
				end
			end
		end
	end
	
	-- compress the nodeMap
	for y, xs in ipairs (nodeMap) do
		for x, node in ipairs (xs) do
			if node then
				nodeMap[y][x] = node.a
			end
		end
	end

	return nodeMap, solutionFound
end

function pf.printNodeMap (nodeMap)
--	show nodeMap
	for y = 1, #nodeMap do
		local str = ''
		for x = 1, #nodeMap[1] do
			local s = nodeMap[y][x] or " "
			str = str .. s .. '	'
		end
		print (str)
	end
end


function pf.getBackTrack (nodeMap, x1, y1, x2, y2)
	local node = {x=x2, y=y2}
	local nodes = {node}
	local n = 0
	while true do
		if (node.x == x1) and (node.y == y1) then 
--			print ('getBackTrack n', n, #nodes)
			return nodes 
		end
		local a, x, y
		for i, dir in ipairs (dirs) do
			local x2 = node.x+dir.x
			local y2 = node.y+dir.y
			local a2 = nodeMap[y2] and nodeMap[y2][x2]
--			print (tostring(a2))
			if a2 then
				if not a or a > a2 then
					x, y, a = x2, y2, a2
				end
			end
		end
--		print ('x:'..x, 'y:'..y)
		node = {x=x, y=y, a=a}
		table.insert (nodes, 1, node)
		n = n + 1
	end
end


function pf.getPath (map, x1, y1, x2, y2) -- 0 is walkable
	local nodeMap, solutionFound = pf.getNodeMap (map, x1, y1, x2, y2)
	pf.printNodeMap (nodeMap)
	print ('solutionFound', tostring (solutionFound))
	
	if solutionFound then
		-- path as positions
		local path = pf.getBackTrack (nodeMap, x1, y1, x2, y2)
		return path
	end
end

function pf.getMovesList (map, x1, y1, x2, y2) -- 0 is walkable
	local nodeMap, solutionFound = pf.getNodeMap (map, x1, y1, x2, y2)
	pf.printNodeMap (nodeMap)
	print ('solutionFound', tostring (solutionFound))
	
	if solutionFound then
		-- path as positions
		
		print ('getBackTrack')
		local path = pf.getBackTrack (nodeMap, x1, y1, x2, y2)
		
		local moves = {}
		for i = 1, #path-1 do
			local move = {x1=path[i].x, y1=path[i].y, x2=path[i+1].x, y2=path[i+1].y}
			table.insert (moves, move)
		end
		return moves -- list of tiles
	else
		print ('no getBackTrack')
	end
end

local function example ()
	local map = {
		{0, 1, 0, 1, 0, 1, 0, 1, 0,},
		{0, 0, 0, 0, 0, 0, 0, 0, 0,},
		{0, 0, 0, 1, 0, 1, 0, 0, 1,},
		{0, 1, 0, 1, 0, 1, 0, 0, 0,},
		{0, 1, 0, 1, 0, 0, 0, 0, 0,},
		{0, 1, 0, 0, 0, 1, 0, 0, 1,},
		{0, 0, 0, 1, 0, 1, 0, 1, 1,},
		{0, 1, 0, 0, 0, 0, 0, 1, 0,},
		{0, 1, 0, 1, 0, 1, 0, 0, 0,},
		}

	-- path as positions
	local path = pf.getPath (map, 1, 5, 9, 5)
	

	if path then 
		print ('#path', #path)
		for i, pos in ipairs (path) do
			print ('x:'..pos.x, 'y:'..pos.y)
		end
	end
end




--example ()

return pf

