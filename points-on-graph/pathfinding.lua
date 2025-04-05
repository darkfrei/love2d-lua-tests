-- pathfinding.lua

-- heuristic function to estimate the distance between two nodes
local function heuristic(a, b)
	return math.sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end

-- dynamic cost heuristic function to account for edge congestion
local function dynamicCostHeuristic(edge)
	-- increase the cost based on the dynamic cost of the edge
	-- the higher the dynamic cost, the less preferable the edge
	local congestionFactor = edge.dynamicCost * 200 / edge.length
	return congestionFactor
end

-- pathfinding algorithm (A*)
local function pathfinding(nodes, edges, startId, goalId)
	local startNode = nodes[startId]
	local goalNode = nodes[goalId]

	if not startNode or not goalNode then
		local str
		if not startNode then 
			str = str .. ' Not startNode '..startId
		end
		if not goalNode then 
			str = str .. ' Not goalNode '..goalId
		end
		error("start or goal node not found! ".. str)
	end

	-- initialize open set, closed set, gScore, and fScore
	local openSet = {startNode}
	local cameFrom = {}
	local gScore = {}
	local fScore = {}

	for _, node in pairs(nodes) do
		gScore[node.id] = math.huge
		fScore[node.id] = math.huge
	end

	gScore[startId] = 0
	fScore[startId] = heuristic(startNode, goalNode)

	-- main A* loop
	while #openSet > 0 do
		-- find the node with the lowest fScore in the open set
		local current = nil
		for _, node in ipairs(openSet) do
			if not current or fScore[node.id] < fScore[current.id] then
				current = node
			end
		end

		-- check if we reached the goal
		if current.id == goalId then
			-- reconstruct the path
			local path = {}
			local currentNode = current
			while currentNode do
				table.insert(path, 1, currentNode.id)
				currentNode = cameFrom[currentNode.id]
			end
			return path
		end

		-- remove current node from the open set
		for i, node in ipairs(openSet) do
			if node.id == current.id then
				table.remove(openSet, i)
				break
			end
		end

		-- process neighbors
		for _, neighborData in ipairs(current.neighbors) do
			local neighbor = nodes[neighborData.id]
--			local tentativeGScore = gScore[current.id] + neighborData.cost
			local edgeId = neighborData.edgeId
			local edge = edges[edgeId]

			local baseCost = neighborData.length -- segmentLength
			local dynamicCost = dynamicCostHeuristic(edge) -- calculate dynamic cost
--			local tentativeGScore = gScore[current.id] + dynamicCost
			local tentativeGScore = gScore[current.id] + edge.length + dynamicCost*4

			if tentativeGScore < gScore[neighbor.id] then
				cameFrom[neighbor.id] = current
				gScore[neighbor.id] = tentativeGScore
				fScore[neighbor.id] = tentativeGScore + heuristic(neighbor, goalNode)

				-- add neighbor to the open set if it's not already there
				local isInOpenSet = false
				for _, node in ipairs(openSet) do
					if node.id == neighbor.id then
						isInOpenSet = true
						break
					end
				end
				if not isInOpenSet then
					table.insert(openSet, neighbor)
				end
			end
		end
	end

	-- no path found
	return nil
end

return pathfinding