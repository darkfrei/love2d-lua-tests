-- circular obstacle pathfinding module
-- implements a* with lazy edge generation for circular obstacles

-- circle overlapping is not allowed;
-- start/goal overlapping is not allowed;


local pathfinding = {}

-- calculate distance between two points
local function distance(p1, p2)
	return math.sqrt((p2.x - p1.x)^2 + (p2.y - p1.y)^2)
end


-- find node with minimum f score in open list
local function getMinFNodeIndex (diagram)
	local openList = diagram.openList
	local minIndex = 1
	local minF = openList[minIndex].f

	for i, node in ipairs(openList) do
		if node.f < minF then
			minF = node.f
			minIndex = i
		end
	end

	return table.remove (openList, minIndex)
end


local function getSurfingLine(p1, p2)
	return {p1.x, p1.y, p2.x, p2.y}
end


-- check if a line intersects a circle
local function isLineCircleIntersection(line, circle)
	local x1, y1, x2, y2 = line[1], line[2], line[3], line[4]
	local cx, cy, r = circle.x, circle.y, circle.radius
	local dx, dy = x2 - x1, y2 - y1
	local fx, fy = cx - x1, cy - y1

	local lengthSquared = dx*dx + dy*dy
	if lengthSquared == 0 then
		local distSq = (x1 - cx)^2 + (y1 - cy)^2
		return distSq <= r * r
	end

	local t = (fx * dx + fy * dy) / lengthSquared
	t = math.max(0, math.min(1, t))

	local distSq = (x1 + t * dx - cx)^2 + (y1 + t * dy - cy)^2
	return distSq <= r * r
end

-- check if line intersects any circle except exceptCircle
local function isLineBlocked(line, circles, exceptCircle)
	-- line: segment {x1, y1, x2, y2} as array
	-- circles: list of circles {id, x, y, radius}
	-- exceptCircle: circle {id, x, y, radius} to exclude or nil
	-- returns: true if line intersects any circle (except exceptCircle), else false

	for _, circle in ipairs(circles) do
		-- skip exceptCircle
		if circle ~= exceptCircle then
			if isLineCircleIntersection(line, circle) then
				print(string.format("line (%.2f, %.2f)-(%.2f, %.2f) blocked by circle id=%d", 
						line[1], line[2], line[3], line[4], circle.id))
				return true
			end
		end
	end

	print(string.format("line (%.2f, %.2f)-(%.2f, %.2f) not blocked", 
			line[1], line[2], line[3], line[4]))
	return false
end

local function getDirectNode(diagram)
	local start = diagram.start
	local goal = diagram.goal
	local circles = diagram.circles
	-- start: starting point {x, y}
	-- goal: ending point {x, y}
	-- returns: node {from, to, type, length, line, g, h, f, from_node}
	local line = getSurfingLine(start, goal)
	local lineBlocked = isLineBlocked(line, circles)
	if lineBlocked then return end
	local directNode = {
		from = start, -- starting point of edge (start point)
		to = goal, -- ending point of edge (goal point)
		type = "surfing", -- edge type: direct line
		length = distance(start, goal), -- length: euclidean distance from start to goal
		line = line, -- line: {x1, y1, x2, y2} for intersection checks
		g = 0, -- g: prev cost from start to this node (0 for direct node)
		h = distance(start, goal), -- h: heuristic (euclidean distance from to to goal)
		f = distance(start, goal), -- f: total cost (g + h)
		from_node = nil -- from_node: parent node (nil for start)
	}
	return directNode
end


-- calculate right or left tangent from a point to a circle
-- returns tangent point (x,y) and angle (from -pi to pi), or nil if point is inside circle
local function calculatePointToCircleTangent(point, circle, isRight)
	local dx = point.x - circle.x
	local dy = point.y - circle.y
	local distSq = dx * dx + dy * dy
	local radiusSq = circle.radius * circle.radius

	-- early exit if point is inside or on the circle
	if distSq <= radiusSq then return nil end

	-- normalize direction vector
	local invDist = 1 / math.sqrt(distSq)
	dx = dx * invDist
	dy = dy * invDist

	-- calculate tangent point using orthogonal vector
	local a = radiusSq * invDist
	local b = circle.radius * math.sqrt(distSq - radiusSq) * invDist
	local sign = isRight and 1 or -1

	local px = circle.x + a * dx + b * dy * sign
	local py = circle.y + a * dy - b * dx * sign

	-- angle from point to tangent point (range -pi to pi)
	local angle = math.atan2(py - point.y, px - point.x)

	return { x = px, y = py }, angle
end





-- get node for tangent from point to circle
--local function getStartPointToCircleNode(point, circle, circles, isRight)
local function addStartPointToCircleNode(diagram, circle, isRight)
	local start = diagram.start
	local goal = diagram.goal
	local circles = diagram.circles
	local id = start.id..'-'..(isRight and 'R' or 'L')..circle.id

	local tangentPoint, angle = calculatePointToCircleTangent(start, circle, isRight)
	if not tangentPoint then
		print(string.format("no tangent: point (%.2f, %.2f) inside circle id=%d or invalid", 
				start.x, start.y, circle.id))
		return nil
	end

	-- check if path is blocked
	local line = getSurfingLine(start, tangentPoint)
	local lineBlocked = isLineBlocked(line, circles, circle) -- except current circle
	if lineBlocked then
		print(string.format("tangent from (%.2f, %.2f) to (%.2f, %.2f) on surfing edge %s blocked", 
				start.x, start.y, tangentPoint.x, tangentPoint.y, id))
		return nil
	end

	-- prepare hugging edge:
	-- the starting values for multiple arcs in new node for the next iterations
	-- now the end point of arc is unknown
	local arcVertex = {
		circle = circle,
		isRight = isRight,
		startAngle = angle}

	local length1 = distance(start, tangentPoint)
	local length2 = distance(tangentPoint, goal)


	-- create node
	local node = {
		id = id,
		from = start, -- starting point node
		to = arcVertex,
		type = "surfing", -- edge type: direct line to tangent point
		length = length1, -- length: euclidean distance from point to tangent
		line = line, -- line: {x1, y1, x2, y2}
		g = length1, -- g: cost from start to tangent point
		h = length2, -- h: heuristic (distance from tangent to goal)
		f = length1 + length2, -- f: total cost (g + h)
	}

	print(string.format(" [Tangent] %s: (%.2f,%.2f)→(%.2f,%.2f)@C%d-%s | f=%.2f",
			id, start.x, start.y, tangentPoint.x, tangentPoint.y, 
			circle.id, isRight and "R" or "L", node.f))

	table.insert(diagram.openList, node)
	table.insert(diagram.debugLines, line)
end




-- a* pathfinding algorithm with lazy edge generation
local function aStar(circles, start, goal)
	local diagram = {
		start = start,
		goal = goal,
		circles = circles,

		openList = {},
		debugLines = {},
		closedHash = {},  -- track visited nodes by id
		nodeCount = 0     -- count total processed nodes
	}

	-- check if current node reaches the goal directly
	local directNode = getDirectNode (diagram)
	if directNode then
		return {directNode}, diagram
	end

--	diagram.openList = {}
--	diagram.debugLines = {}

	for _, circle in ipairs(circles) do
		addStartPointToCircleNode (diagram, circle, true) -- right
		addStartPointToCircleNode (diagram, circle, false) -- left
	end

--	local closedHash  = {}

	print("#diagram.openList:", #diagram.openList)
	print("Starting A* algorithm")

	while #diagram.openList > 0 do
		local currentNode = getMinFNodeIndex (diagram)
		local currentId = currentNode.id

		if diagram.closedHash[currentId] then
			-- do nothing
		else
			diagram.closedHash[currentId] = true
			diagram.nodeCount = diagram.nodeCount + 1

			print(string.format("processing node %d: %s (f=%.2f)", 
					diagram.nodeCount, currentId, currentNode.f))

--			check goal condition
			if currentNode.type == "direct" then
				print(string.format("path found! nodes processed: %d", diagram.nodeCount))
				return reconstructPath(currentNode), diagram
			end

			-- expand node based on type
			local newNodes = {}
			if currentNode.type == "surfing" then
--				newNodes = generateHuggingEdges(diagram, currentNode)
			elseif currentNode.type == "hugging" then
				newNodes = generateExitEdges(diagram, currentNode)
			end

			-- add new nodes to open list
			for _, node in ipairs(newNodes) do
				if not diagram.closedHash[node.id] then
					table.insert(diagram.openList, node)
				end
			end


		end
	end

	print("no valid path found")
	return nil, diagram
end




-- circular obstacle pathfinding
function pathfinding.circularObstaclePathfinding(circles, start, goal)
	start.id = 'start'
	goal.id = 'goal'
	for id, circle in ipairs (circles) do
		circle.id = id
	end

--	print(string.format("no tangent: point (%.2f, %.2f) inside circle id=%d or invalid", 
--				start.x, start.y, circle.id))

	print(string.format("Starting pathfinding with start=(%.2f, %.2f), goal=(%.2f, %.2f), %d circles", 
			start.x, start.y, goal.x, goal.y, #circles))

	local path, edgeCache = aStar (circles, start, goal)
	print("Pathfinding completed")
	return path, edgeCache
end

return pathfinding