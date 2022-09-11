-- easy full pathfinding in Lua

local pf = {}

local dirs = {{x=0, y=-1}, {x=1, y=0}, {x=0, y=1}, {x=-1, y=0}}

local function isTileWalkable (map, x, y)
	return map[y] and map[y][x] and map[y][x] == 0
end



function pf.getNodeMap (map, x1, y1, x2, y2)
	-- refill nodeMap
	local nodeMap = {}
	for y = 1, #map do
		nodeMap[y] = nodeMap[y] or {}
		for x = 1, #map[1] do
			nodeMap[y][x] = nodeMap[y][x] or false
		end
	end
	
	local nodeList = {}
	local node = {x=x1, y=y1, a=0, iDir = math.random (4)}
	table.insert (nodeList, node)
	if not nodeMap[y1] then nodeMap[y1] = {} end
	nodeMap[y1][x1] = node
	local nNodes = 1
	local solutionFound = false
	
	while #nodeList > 0 do
		local node = nodeList[#nodeList] -- last node is faster
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
--					if not nodeMap[y] then nodeMap[y] = {} end
					nodeMap[y][x] = node2
					table.insert (nodeList, node2)
					nNodes = nNodes + 1
					
					if x == x2 and y == y2 then
						solutionFound = true
					end
				end
			end
		end
	end

	return nodeMap, solutionFound
end

local function printNodeMap (map, nodeMap)
--	show nodeMap
	for y = 1, #map do
		local str = ''
		for x = 1, #map[1] do
			local s = nodeMap[y][x] and nodeMap[y][x].a or " "
			str = str .. s .. '	'
		end
		print (str)
	end
end


local function getBackTrack (nodeMap, x1, y1, x2, y2)
	local node = {x=x2, y=y2}
	local nodes = {node}
	local n = 0
	while true do
		if (node.x == x1) and (node.y == y1) then 
			print ('getBackTrack n', n, #nodes)
			return nodes 
		end
		local neighbourNodes = {}
		local a
		local node3
		for i, dir in ipairs (dirs) do
			local x = node.x+dir.x
			local y = node.y+dir.y
			local node2 = nodeMap[y] and nodeMap[y][x]
			if node2 and (not a or a > node2.a) then
				a = node2.a
				node3 = node2
			end
		end
		
		node = node3
		table.insert (nodes, 1, node)
		n = n + 1
	end
end


function pf.getPath (map, x1, y1, x2, y2) -- 0 is walkable
	local nodeMap, solutionFound = pf.getNodeMap (map, x1, y1, x2, y2)
	printNodeMap (map, nodeMap)
	print ('solutionFound', tostring (solutionFound))
	
	if solutionFound then
		return getBackTrack (nodeMap, x1, y1, x2, y2)
	end
end

local function example ()
	local map = {
		{0, 1, 0, 1, 0, 1, 0, 1, 0,},
		{0, 0, 0, 0, 0, 0, 0, 0, 0,},
		{0, 1, 0, 1, 0, 1, 0, 1, 1,},
		{0, 0, 0, 1, 0, 1, 0, 1, 0,},
		{0, 1, 0, 1, 0, 0, 0, 1, 1,},
		{0, 1, 0, 0, 0, 1, 0, 0, 1,},
		{0, 1, 0, 1, 0, 1, 0, 1, 1,},
		{0, 1, 0, 0, 0, 0, 0, 0, 0,},
		{0, 1, 0, 1, 0, 1, 0, 0, 0,},
		}

	local path = pf.getPath (map, 1, 1, 9, 9)

	if path then 
		for i, pos in ipairs (path) do
			print ('x:'..pos.x, 'y:'..pos.y)
		end
	end
end

example ()

return pf

