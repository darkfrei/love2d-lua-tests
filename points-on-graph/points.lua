-- points.lua

local pathfinding = require("pathfinding")
local diagram = require("diagram")

-- create a new point with a given path
local function createPoint(startId, goalId, path)
	return {
		startId = startId,
		goalId = goalId,
		path = path,
		pathIndex = 1,
		progress = 0,
		speed = 50, -- current speed in pixels per second
		minSpeed = 5, -- minimum speed in pixels per second
		maxSpeed = 50, -- maximum speed in pixels per second
		vx = 0, -- velocity vector x-component
		vy = 0, -- velocity vector y-component
		currentEdgeId = nil, -- track the current edge id
		toRemove = false, -- flag to mark for removal
		isRepathing = math.random() < 0.5, -- flag to indicate if the point is repathing
		isGreen = false, -- flag to indicate if the path of the point should be green
		criticalPoint = nil, -- store the critical point that affects this point's speed
	}
end

-- compare two paths starting from the current node id
local function comparePaths(oldPath, newPath, currentNodeId)
	local startIndex1
	for i, nodeId in ipairs(oldPath) do
		if nodeId == currentNodeId then
			startIndex1 = i
			break
		end
	end

	for i, newId in ipairs(newPath) do
		local oldId = oldPath[i + startIndex1 - 1]
		if newId ~= oldId then
			return true
		end
	end

	return false -- paths are identical
end

-- calculate the segment length and direction
local function calculateSegment(currentNode, nextNode)
	local dx = nextNode.x - currentNode.x
	local dy = nextNode.y - currentNode.y
	local segmentLength = math.sqrt(dx * dx + dy * dy)
	return dx, dy, segmentLength
end

-- find the current edge id
local function findCurrentEdgeId(nodes, edges, point)
	local currentNode = nodes[point.path[point.pathIndex]]
	local nextNode = nodes[point.path[point.pathIndex + 1]]

	for _, neighbor in ipairs(currentNode.neighbors) do
		if neighbor.id == nextNode.id then
			return neighbor.edgeId
		end
	end
	return nil
end

-- increase dynamic cost of the current edge
local function updateDynamicCost(edges, point, edgeId)
	if edgeId and edgeId ~= point.currentEdgeId then
		edges[edgeId].dynamicCost = (edges[edgeId].dynamicCost or 0) + 1
		point.currentEdgeId = edgeId
	end
end

-- decrease dynamic cost of the previous edge
local function decreaseDynamicCost(edges, point)
	if point.currentEdgeId then
		edges[point.currentEdgeId].dynamicCost = math.max((edges[point.currentEdgeId].dynamicCost or 0) - 1, 0)
		point.currentEdgeId = nil
	end
end

-- attempt to repath the point
local function attemptRepath(nodes, edges, point)
	local currentId = point.path[point.pathIndex]
	local newPath = pathfinding(nodes, edges, currentId, point.goalId)
	if newPath then
		if comparePaths(point.path, newPath, currentId) then
			point.isGreen = true
			point.path = newPath
			point.pathIndex = 1
		else
			point.isGreen = false
		end
	end
end

-- check if the point has reached the end of its path
local function checkEndOfPath(point)
	if point.pathIndex >= #point.path then
		point.toRemove = true
	end
end

-- update all moving points
local function updatePoints(movingPoints, nodes, edges, dt)
	local minDist = 20 -- minimum distance to start slowing down

	-- first cycle: pdate velocity (vx, vy) based on surrounding points
	for _, point in ipairs(movingPoints) do
		if point.pathIndex < #point.path then
			-- get nodes for the current segment
			local currentNode = diagram.getNodeById(point.path[point.pathIndex])
			local nextNode = diagram.getNodeById(point.path[point.pathIndex + 1])
			local dx, dy, segmentLength = calculateSegment(currentNode, nextNode)

			-- default speed is the maximum speed
			local adjustedSpeed = point.speed
			point.criticalPoint = nil -- reset the critical point

			-- check for other points ahead and adjust speed if necessary
			for _, otherPoint in ipairs(movingPoints) do
				if point ~= otherPoint and otherPoint.pathIndex < #otherPoint.path then
					if point.pathIndex == otherPoint.pathIndex then
						local otherCurrentNode = diagram.getNodeById(otherPoint.path[otherPoint.pathIndex])
						local otherNextNode = diagram.getNodeById(otherPoint.path[otherPoint.pathIndex + 1])

						-- calculate the position of the other point along the segment
						local otherX = otherCurrentNode.x + (otherNextNode.x - otherCurrentNode.x) * otherPoint.progress
						local otherY = otherCurrentNode.y + (otherNextNode.y - otherCurrentNode.y) * otherPoint.progress

						-- calculate the vector from the current point to the other point
						local dxToOther = otherX - point.x
						local dyToOther = otherY - point.y
						local distanceToOtherPoint = math.sqrt(dxToOther^2 + dyToOther^2)

						-- check if the other point is ahead (dot product > 0)
						local dotProduct = dx * dxToOther + dy * dyToOther
						if dotProduct > 0 and distanceToOtherPoint < minDist then
							-- reduce speed proportionally to the distance
							adjustedSpeed = math.max(point.speed * (distanceToOtherPoint / minDist), point.minSpeed)
							point.criticalPoint = {x = otherX, y = otherY} -- mark the critical point
						end
					end
				end
			end

			-- update velocity components
			point.vx = (dx / segmentLength) * adjustedSpeed
			point.vy = (dy / segmentLength) * adjustedSpeed
		end
	end

	-- second cycle: Move points along their paths
	for _, point in ipairs(movingPoints) do
		if point.pathIndex < #point.path then
			-- get nodes for the current segment
			local currentNode = diagram.getNodeById(point.path[point.pathIndex])
			local nextNode = diagram.getNodeById(point.path[point.pathIndex + 1])
			local dx, dy, segmentLength = calculateSegment(currentNode, nextNode)

			-- update progress along the segment using velocity
			point.progress = point.progress + ((math.abs(point.vx) + math.abs(point.vy)) * dt) / segmentLength

			-- update the point's position
			point.x = currentNode.x + dx * point.progress
			point.y = currentNode.y + dy * point.progress

			-- find the current edge id
			local edgeId = findCurrentEdgeId(diagram.getNodes(), diagram.getEdges(), point)

			-- increase dynamic cost of the current edge
			updateDynamicCost(diagram.getEdges(), point, edgeId)

			-- move to the next segment if progress exceeds 1
			if point.progress >= 1 then
				point.pathIndex = point.pathIndex + 1
				point.progress = 0

				-- decrease dynamic cost of the previous edge
				decreaseDynamicCost(diagram.getEdges(), point)

				-- attempt to repath if necessary
				if point.isRepathing and point.pathIndex < #point.path then
					attemptRepath(diagram.getNodes(), diagram.getEdges(), point)
				end

				-- check if the end of the path is reached
				checkEndOfPath(point)
			end
		end
	end

	-- remove points that have reached the end of their path
	for i = #movingPoints, 1, -1 do
		local point = movingPoints[i]
		if point.toRemove then
			table.remove(movingPoints, i)
		end
	end
end

-- draw all moving points
local function drawPoints(movingPoints)
	for _, point in ipairs(movingPoints) do
		if point.pathIndex < #point.path then
			-- set color based on whether the point is repathing
			if point.isRepathing then
				love.graphics.setColor(0, 1, 0) -- green color for repathing points
			else
				love.graphics.setColor(1, 0.5, 0) -- orange color for normal points
			end
			love.graphics.circle("fill", point.x, point.y, 7) -- slightly larger radius for better visibility

			-- draw a black outline around the point for contrast
			love.graphics.setColor(0, 0, 0) -- black color for the outline
			love.graphics.circle("line", point.x, point.y, 7)

			-- draw the critical point if it exists
			if point.criticalPoint then
				love.graphics.setLineWidth(4)
				love.graphics.setColor(0, 0, 0)
				love.graphics.line(point.x, point.y, point.criticalPoint.x, point.criticalPoint.y)
				love.graphics.setLineWidth(2)
				love.graphics.setColor(1, 1, 0)
				love.graphics.line(point.x, point.y, point.criticalPoint.x, point.criticalPoint.y)
			end
		end
	end
end

return {
	createPoint = createPoint,
	updatePoints = updatePoints,
	drawPoints = drawPoints
}