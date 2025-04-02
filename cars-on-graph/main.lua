-- load data from data.lua
local data = require("data")

-- global variables to store nodes and edges
local nodes = data.nodes
local edges = data.edges

-- heuristic function to estimate the distance between two nodes
local function heuristic(a, b)
	return math.sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
	-- return 0 -- uncomment this line to disable the heuristic (converts a* to dijkstra)
end

-- pathfinding algorithm
local function pathfinding(startId, goalId)
	local startNode = nodes[startId]
	local goalNode = nodes[goalId]

	if not startNode or not goalNode then
		error("start or goal node not found!")
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

	-- main pathfinding loop
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
			local sumGScore = gScore[current.id] + neighborData.cost

			if sumGScore < gScore[neighbor.id] then
				cameFrom[neighbor.id] = current
				gScore[neighbor.id] = sumGScore
				fScore[neighbor.id] = sumGScore + heuristic(neighbor, goalNode)

				-- add neighbor to the open set if it's not already there
				local inOpenSet = false
				for _, node in ipairs(openSet) do
					if node.id == neighbor.id then
						inOpenSet = true
						break
					end
				end
				if not inOpenSet then
					table.insert(openSet, neighbor)
				end
			end
		end
	end

	-- no path found
	return nil
end

-- global variable to store the path
local path = nil

-- main initialization
function love.load()
	-- find the path from node 76 to node 61
	path = pathfinding(76, 61)
	if path then
		local str = table.concat(path, ">")
		print("path found:", str)
		love.window.setTitle(str)
	else
		print("no path found!")
	end
end

-- main drawing loop
function love.draw()
	-- clear the screen
	love.graphics.setBackgroundColor(0.95, 0.95, 0.95) -- light gray background

	-- draw edges
	love.graphics.setColor(0.2, 0.2, 0.2) -- dark gray color for edges
	love.graphics.setLineWidth(2)
	for _, edge in pairs(edges) do
		local node1 = nodes[edge.nodes[1]]
		local node2 = nodes[edge.nodes[2]]
		if node1 and node2 then
			love.graphics.line(
				node1.x,
				node1.y,
				node2.x,
				node2.y
			)
		end
	end

	-- draw nodes
	love.graphics.setColor(0.2, 0.4, 0.9) -- blue color for nodes
	for _, node in pairs(nodes) do
		love.graphics.circle(
			"fill", -- filled circle
			node.x,
			node.y,
			5 -- radius of the circle
		)
	end

	-- draw the path (if found)
	if path then
		love.graphics.setColor(1, 0, 0) -- red color for the path
		love.graphics.setLineWidth(3)
		for i = 1, #path - 1 do
			local node1 = nodes[path[i]]
			local node2 = nodes[path[i + 1]]
			if node1 and node2 then
				love.graphics.line(node1.x, node1.y, node2.x, node2.y)
			end
		end
	end

	-- add labels to nodes
	love.graphics.setColor(0, 0, 0) -- black color for text
	for _, node in pairs(nodes) do
		love.graphics.print(
			tostring(node.id), -- node id
			node.x + 7, -- offset text to the right
			node.y - 2 -- offset text upwards
		)
	end
end