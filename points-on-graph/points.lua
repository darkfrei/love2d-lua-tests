local pathfinding = require("pathfinding")
local diagram = require("diagram")

-- create a new point with a given path
local function createPoint(startId, goalId, path)
	local node = diagram.getNodeById(startId)
	local point = {
		startId = startId,
		goalId = goalId,
		path = path,
		pathIndex = 1,
		progress = 0,
		speed = 60, -- current speed in pixels per second
		minSpeed = -10, -- minimum speed in pixels per second
		maxSpeed = 60, -- maximum speed in pixels per second
		x = node.x,
		y = node.y,
		vx = 0, -- velocity vector x-component
		vy = 0, -- velocity vector y-component
		currentEdgeId = nil, -- track the current edge id
		toRemove = false, -- flag to mark for removal
		isRepathing = math.random() < 0.5, -- flag to indicate if the point is repathing
		isGreen = false, -- flag to indicate if the path of the point should be green
		criticalPoint = nil, -- store the point causing speed adjustment
		criticalDistance = nil, -- store the distance to the critical point
	}
	point.currentNode = diagram.getNodeById(point.path[point.pathIndex])
	point.nextNode = diagram.getNodeById(point.path[point.pathIndex + 1])
	return point
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
	for _, neighbor in ipairs(point.currentNode.neighbors) do
		if neighbor.id == point.nextNode.id then
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
			-- update currentNode and nextNode after repathing
			point.currentNode = diagram.getNodeById(point.path[point.pathIndex])
			point.nextNode = diagram.getNodeById(point.path[point.pathIndex + 1])
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

-- calculate position of a point along its segment
local function calculatePointPosition(point)
	local dx, dy, segmentLength = calculateSegment(point.currentNode, point.nextNode)
	local x = point.currentNode.x + dx * point.progress
	local y = point.currentNode.y + dy * point.progress
	return x, y, dx, dy, segmentLength
end

-- check if two points are on the same or adjacent segments
local function arePointsRelated(point, otherPoint)
	local pointCurrentId = point.path[point.pathIndex]
	local pointNextId = point.path[point.pathIndex + 1]
	local otherCurrentId = otherPoint.path[otherPoint.pathIndex]
	local otherNextId = otherPoint.path[otherPoint.pathIndex + 1]

	local isSameSegment = pointCurrentId == otherCurrentId and pointNextId == otherNextId
	local isNextSegment = pointNextId == otherCurrentId

	return isSameSegment or isNextSegment
end

-- adjust speed to avoid collision with another point
local function adjustSpeedForCollision(point, otherPoint, pointX, pointY, dx, dy, minDist)
	local otherDx, otherDy, otherSegmentLength = calculateSegment(otherPoint.currentNode, otherPoint.nextNode)

	-- calculate the other point's position
	local otherX = otherPoint.currentNode.x + otherDx * otherPoint.progress
	local otherY = otherPoint.currentNode.y + otherDy * otherPoint.progress

	-- calculate vector from point to other point
	local dxToOther = otherX - pointX
	local dyToOther = otherY - pointY
	local distanceToOther = math.sqrt(dxToOther * dxToOther + dyToOther * dyToOther)

	-- check if the other point is within range
	if distanceToOther < minDist then
		-- calculate dot product to determine if other point is ahead
		local dotProduct = dx * dxToOther + dy * dyToOther
		if dotProduct > 0 then -- other point is ahead in the direction of movement
			-- calculate relative velocity (speed difference along the path)
			local pointSpeed = math.sqrt(point.vx * point.vx + point.vy * point.vy)
			local otherSpeed = math.sqrt(otherPoint.vx * otherPoint.vx + otherPoint.vy * otherPoint.vy)
			local relativeSpeed = pointSpeed - otherSpeed

			-- adjust speed if point is catching up or too close
			if relativeSpeed > 0 or distanceToOther < minDist * 0.5 then
				-- adjust speed to maintain distance, considering other point's speed
				local safeSpeed = otherSpeed + (distanceToOther / minDist) * (point.maxSpeed - otherSpeed)
				local adjustedSpeed = math.max(math.min(safeSpeed, point.maxSpeed), point.minSpeed)
				point.criticalPoint = {x = otherX, y = otherY} -- mark the critical point
				return adjustedSpeed
			end
		end
	end
	return nil -- no adjustment needed
end

-- update velocity components based on adjusted speed
local function updateVelocity(point, dx, dy, segmentLength, adjustedSpeed)
	if segmentLength > 0 then
		point.vx = (dx / segmentLength) * adjustedSpeed
		point.vy = (dy / segmentLength) * adjustedSpeed
		point.speed = adjustedSpeed -- update point.speed to reflect the adjusted speed
	else
		point.vx, point.vy = 0, 0 -- avoid division by zero
		point.speed = 0 -- set speed to 0 if segment length is zero
	end
end

-------------------------------


-- calculate velocity components based on current speed and direction
local function getVelocity(point)
	local dx, dy, segmentLength = calculateSegment(point.currentNode, point.nextNode)
	if segmentLength > 0 then
		return (dx / segmentLength) * point.speed, (dy / segmentLength) * point.speed
	else
		return 0, 0 -- avoid division by zero
	end
end

-- calculate distance from a point to its nextNode
local function distanceToNextNode(point)
	local dx = point.nextNode.x - point.x
	local dy = point.nextNode.y - point.y
	return math.sqrt(dx * dx + dy * dy)
end

-- initialize speeds and velocities for all points
local function initializeVelocities(movingPoints)
	for _, point in ipairs(movingPoints) do
		if point.pathIndex < #point.path then
			point.speed = point.maxSpeed
			point.vx, point.vy = getVelocity(point)
			point.criticalPoint = nil -- reset critical point
			point.criticalDistance = nil -- reset critical distance
		end
	end
end

-- adjust speeds for points approaching a shared nextNode
local function adjustForSharedNode(movingPoints, minDist)
	for i = 1, #movingPoints do
		local pointA = movingPoints[i]
--		if pointA.pathIndex < #pointA.path then
		for j = i + 1, #movingPoints do
			local pointB = movingPoints[j]
--				if pointB.pathIndex < #pointB.path then
			-- check if points approach the same nextNode from different edges
			if pointA.nextNode.id == pointB.nextNode.id and pointA.currentNode.id ~= pointB.currentNode.id then
				-- calculate distances to the shared nextNode
				local distA = distanceToNextNode(pointA)
				local distB = distanceToNextNode(pointB)

				-- calculate distance between points
				local dx = pointB.x - pointA.x
				local dy = pointB.y - pointA.y
				local distance = math.sqrt(dx * dx + dy * dy)

				-- adjust speeds if points are too close
				if distance < minDist then
					if distA < distB then
						-- pointA is closer, speed it up
						pointA.speed = pointA.maxSpeed
						pointA.vx, pointA.vy = getVelocity(pointA)
						-- pointB is farther, slow it down
						pointB.speed = pointB.minSpeed
						pointB.vx, pointB.vy = getVelocity(pointB)
						pointA.criticalPoint = pointB
						pointA.criticalDistance = distance
					else
						-- pointB is closer, speed it up
						pointB.speed = pointB.maxSpeed
						pointB.vx, pointB.vy = getVelocity(pointB)
						-- pointA is farther, slow it down
						pointA.speed = pointA.minSpeed
						pointA.vx, pointA.vy = getVelocity(pointA)
						pointB.criticalPoint = pointA
						pointB.criticalDistance = distance
					end
				end
			end
--				end
--			end
		end
	end
end

-- avoid collisions for points on the same or adjacent segments
local function avoidCollisions(movingPoints, minDist)
	for _, pointA in ipairs(movingPoints) do
--		if pointA.pathIndex < #pointA.path then
		for _, pointB in ipairs(movingPoints) do
--				if pointA ~= pointB and pointB.pathIndex < #pointB.path then
			if pointA ~= pointB then
				-- check if points are on related segments
				if arePointsRelated(pointA, pointB) then
					-- calculate distance between points
					local dx = pointB.x - pointA.x
					local dy = pointB.y - pointA.y
					local distance = math.sqrt(dx * dx + dy * dy)

					-- adjust speed if points are too close
					if distance < minDist then
						-- check if pointA is moving towards pointB
						local dotProduct = pointA.vx * dx + pointA.vy * dy
						if dotProduct > 0 then
							-- smoothly reduce speed of pointA
							local speedReductionFactor = 4*(minDist - distance) / minDist
							speedReductionFactor = math.max(0, math.min(1, speedReductionFactor))
--							local newSpeed = pointA.minSpeed + (pointA.maxSpeed - pointA.minSpeed) * (1 - speedReductionFactor)
							local newSpeed = pointA.minSpeed + (pointA.maxSpeed - pointA.minSpeed) * (1 - speedReductionFactor)
							pointA.speed = math.min (pointA.speed, newSpeed)
							-- keep speed within bounds
--								pointA.speed = math.max(pointA.minSpeed, math.min(pointA.speed, pointA.maxSpeed))
							-- update velocity components
							pointA.vx, pointA.vy = getVelocity(pointA)
							-- mark critical point and distance
							pointA.criticalPoint = pointB
							pointA.criticalDistance = distance
						end
					end
				end
			end
		end
--		end
	end
end

-- update velocities of all moving points based on collision avoidance
local function updateVelocities(movingPoints, minDist)
	-- initialize velocities with maximum speed
	initializeVelocities(movingPoints)

	-- adjust speeds for points nearing a shared node
	adjustForSharedNode(movingPoints, minDist)

	-- handle collision avoidance on segments
	avoidCollisions(movingPoints, minDist)
end

--[[
-- move all points along their paths and handle path updates
local function movePoints(movingPoints, dt)
	for _, point in ipairs(movingPoints) do
		if point.pathIndex < #point.path then
			-- get segment data
			local dx, dy, segmentLength = calculateSegment(point.currentNode, point.nextNode)

			-- update progress along the segment using velocity
			point.progress = point.progress + ((math.abs(point.vx) + math.abs(point.vy)) * dt) / segmentLength
--			point.progress = point.progress + (point.speed * dt) / segmentLength

			-- update the point's position
--			point.x = point.currentNode.x + dx * point.progress
--			point.y = point.currentNode.y + dy * point.progress
			point.x = point.x + point.vx * dt
			point.y = point.y + point.vy * dt

			-- find the current edge id
			local edgeId = findCurrentEdgeId(diagram.getNodes(), diagram.getEdges(), point)

			-- increase dynamic cost of the current edge
			updateDynamicCost(diagram.getEdges(), point, edgeId)

			-- move to the next segment if progress exceeds 1
			if point.progress >= 1 then
				point.pathIndex = point.pathIndex + 1
				point.progress = 0

				-- update currentNode and nextNode
				if point.pathIndex < #point.path then
					point.currentNode = point.nextNode
					point.nextNode = diagram.getNodeById(point.path[point.pathIndex + 1])
				end

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
--]]

-- move all points along their paths and handle path updates
local function movePoints(movingPoints, dt)
	for _, point in ipairs(movingPoints) do
		if point.pathIndex < #point.path then
			-- get segment data
			local dx, dy, segmentLength = calculateSegment(point.currentNode, point.nextNode)

			-- update position using velocity components
			point.x = point.x + point.vx * dt
			point.y = point.y + point.vy * dt

			-- calculate progress based on new position
			local newDx = point.x - point.currentNode.x
			local newDy = point.y - point.currentNode.y
			local progress = math.sqrt(newDx * newDx + newDy * newDy) / segmentLength

			-- find the current edge id
			local edgeId = findCurrentEdgeId(diagram.getNodes(), diagram.getEdges(), point)

			-- increase dynamic cost of the current edge
			updateDynamicCost(diagram.getEdges(), point, edgeId)

			-- move to the next segment if progress exceeds 1
			if progress >= 1 then
				point.pathIndex = point.pathIndex + 1
				point.x = point.nextNode.x -- snap to next node
				point.y = point.nextNode.y -- snap to next node

				-- update currentNode and nextNode
				if point.pathIndex < #point.path then
					point.currentNode = point.nextNode
					point.nextNode = diagram.getNodeById(point.path[point.pathIndex + 1])
				end

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

-- update all moving points
local function updatePoints(movingPoints, nodes, edges, dt)
	local minDist = 20 -- minimum distance to start slowing down

	-- update velocities based on collision avoidance
	updateVelocities(movingPoints, minDist)

	-- move points along their paths
	movePoints(movingPoints, dt)
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

--				if point.criticalDistance then
--					local str = string.format('%.1f', point.criticalDistance)
--					love.graphics.setColor(0, 0, 0)
--					love.graphics.print (str, point.x+2, point.y+2)
--					love.graphics.print (str, point.x+1, point.y+1)
--					love.graphics.setColor(1, 1, 1)
--					love.graphics.print (str, point.x, point.y)
--				end

			end

		end
	end
end

return {
	createPoint = createPoint,
	updatePoints = updatePoints,
	drawPoints = drawPoints
}