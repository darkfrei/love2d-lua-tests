-- pathfinding.lua
-- circular obstacle pathfinding using A* with lazy edge generation
-- implements algorithm from https://redblobgames.github.io/circular-obstacle-pathfinding/

local pathfinding = {}

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================

-- calculate distance between two points
local function distance(p1, p2)
	return math.sqrt((p2.x - p1.x)^2 + (p2.y - p1.y)^2)
end

-- convert two points to line format for intersection checking
local function convertPointsToLine(p1, p2)
	return {p1.x, p1.y, p2.x, p2.y}
end

local function normalizeAngle(a)
	return (a + math.pi) % (2 * math.pi) - math.pi
end



-- ========================================
-- GEOMETRIC FUNCTIONS
-- ========================================


-- generate points for arc visualization
local function generateArcPoints(arcVertex)
	local circle = arcVertex.circle
	local startAngle = arcVertex.angle
	local endAngle = arcVertex.angle  -- will be updated during path reconstruction
	local isRight = arcVertex.isRight

	local points = {}
	local step = math.rad(5)  -- 5 degree steps
	local angleDiff = endAngle - startAngle

	-- adjust for direction
	if isRight and angleDiff > 0 then
		endAngle = endAngle - 2 * math.pi
	elseif not isRight and angleDiff < 0 then
		endAngle = endAngle + 2 * math.pi
	end

	-- calculate number of segments (minimum 3 points)
	local segments = math.max(2, math.ceil(math.abs(endAngle - startAngle) / step))
	local actualStep = (endAngle - startAngle) / segments

	-- generate points along arc
	for i = 0, segments do
		local angle = startAngle + i * actualStep
		table.insert(points, circle.x + circle.radius * math.cos(angle))
		table.insert(points, circle.y + circle.radius * math.sin(angle))
	end

	return points
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

-- check if line intersects any circle except excluded ones
local function isLineBlocked(line, circles, excludeCircle1, excludeCircle2)
	for _, circle in ipairs(circles) do
		if circle ~= excludeCircle1 and circle ~= excludeCircle2 then
			if isLineCircleIntersection(line, circle) then
				return true
			end
		end
	end
	return false
end

-- calculate tangent point and angle from a point to a circle
local function calculatePointToCircleTangent(point, circle, isRightTangent)
	local deltaX = point.x - circle.x
	local deltaY = point.y - circle.y
	local distanceSquared = deltaX * deltaX + deltaY * deltaY
	local radiusSquared = circle.radius * circle.radius

	-- check if point is inside or on the circle
	if distanceSquared <= radiusSquared then
		return nil
	end

	-- normalize direction vector
	local inverseDistance = 1 / math.sqrt(distanceSquared)
	local normalizedDeltaX = deltaX * inverseDistance
	local normalizedDeltaY = deltaY * inverseDistance

	-- calculate tangent point using orthogonal vector
	local tangentProjection = radiusSquared * inverseDistance
	local orthogonalComponent = circle.radius * math.sqrt(distanceSquared - radiusSquared) * inverseDistance
	local tangentSign = isRightTangent and 1 or -1

	local tangentX = circle.x + tangentProjection * normalizedDeltaX + orthogonalComponent * normalizedDeltaY * tangentSign
	local tangentY = circle.y + tangentProjection * normalizedDeltaY - orthogonalComponent * normalizedDeltaX * tangentSign

	local tangentPoint = {x = tangentX, y = tangentY}
	local tangentAngle = math.atan2(tangentY - circle.y, tangentX - circle.x)

	-- normalize angle based on tangent direction
	if isRightTangent then
		tangentAngle = tangentAngle % (2 * math.pi)
	else
		tangentAngle = (tangentAngle % (2 * math.pi)) - 2 * math.pi
	end

	return tangentPoint, tangentAngle
end

-- calculate external tangent line between two circles
local function calculateCircleToCircleTangent(fromCircle, fromRight, toCircle, toRight)
	local x1, y1, r1 = fromCircle.x, fromCircle.y, fromCircle.radius
	local x2, y2, r2 = toCircle.x, toCircle.y, toCircle.radius
	local dx, dy = x2 - x1, y2 - y1
	local dist = math.sqrt(dx*dx + dy*dy)

	-- check if tangent is possible
	if dist < math.abs(r1 - r2) or dist < r1 + r2 or (dist == 0 and r1 == r2) then
		return nil
	end

	local r1Sign = fromRight and 1 or -1
	local r2Sign = toRight and 1 or -1

	local theta = math.asin((-r1 * r1Sign + r2 * r2Sign) / dist)
	local alpha = math.atan2(dy, dx)

	local angle1 = alpha + theta + r1Sign * math.pi/2
	local angle2 = alpha + theta + r2Sign * math.pi/2

	angle1 = normalizeAngle(angle1)
	angle2 = normalizeAngle(angle2)

	local p1 = {
		x = x1 + r1 * math.cos(angle1),
		y = y1 + r1 * math.sin(angle1)
	}
	local p2 = {
		x = x2 + r2 * math.cos(angle2),
		y = y2 + r2 * math.sin(angle2)
	}

	return p1, p2, angle1, angle2
end


-- debug arc length calculation with detailed output
local function debugArcLength(fromAngle, toAngle, radius, isRightDirection, nodeId)
	if not nodeId then nodeId = "unknown" end

	print(string.format("=== ARC DEBUG for %s ===", nodeId))
	print(string.format("original angles: from=%.4f (%.1f°), to=%.4f (%.1f°)", 
			fromAngle, fromAngle * 180 / math.pi, toAngle, toAngle * 180 / math.pi))

	local angleDiff = toAngle - fromAngle
	print(string.format("raw angle difference: %.4f (%.1f°)", angleDiff, angleDiff * 180 / math.pi))

	-- calculate based on direction using your correct logic
	local adjustedToAngle = toAngle
	if isRightDirection then
		-- for right direction (clockwise movement)
		print("direction: RIGHT (clockwise)")
		if angleDiff > 0 then
			adjustedToAngle = toAngle - 2 * math.pi
			print("adjusting for clockwise: subtracting 2π from toAngle")
		else
			print("no adjustment needed for clockwise")
		end
	else
		-- for left direction (counter-clockwise movement)
		print("direction: LEFT (counter-clockwise)")  
		if angleDiff < 0 then
			adjustedToAngle = toAngle + 2 * math.pi
			print("adjusting for counter-clockwise: adding 2π to toAngle")
		else
			print("no adjustment needed for counter-clockwise")
		end
	end

	local finalAngleDiff = adjustedToAngle - fromAngle
	print(string.format("adjusted toAngle: %.4f (%.1f°)", adjustedToAngle, adjustedToAngle * 180 / math.pi))
	print(string.format("final angle difference: %.4f (%.1f°)", finalAngleDiff, finalAngleDiff * 180 / math.pi))

	local arcLength = math.abs(finalAngleDiff) * radius
	print(string.format("arc length: |%.4f| * %.2f = %.2f", finalAngleDiff, radius, arcLength))

	-- sanity checks
	if arcLength > 2 * math.pi * radius then
		print("WARNING: arc length > full circle circumference!")
	end

	if arcLength < 0.01 then
		print("WARNING: very small arc length, might be calculation error")
	end

	print("=== END ARC DEBUG ===")
	return arcLength
end

-- test the corrected debug function
local function testDebugFunction()
	print("TESTING CORRECTED DEBUG FUNCTION:")
	print()

	-- test cases that should work correctly now
	debugArcLength(0, math.pi/2, 10, true, "0° to 90° RIGHT")
	print()
	debugArcLength(0, math.pi/2, 10, false, "0° to 90° LEFT") 
	print()
	debugArcLength(math.pi/2, 0, 10, true, "90° to 0° RIGHT")
	print()
	debugArcLength(math.pi/2, 0, 10, false, "90° to 0° LEFT")
end
--testDebugFunction()

-- calculate arc length and normalize angles for consistent direction
local function calculateArcLength(fromAngle, toAngle, radius, isRightDirection, nodeId)
	local angle1 = fromAngle
	local angle2 = toAngle

	-- normalize both angles
	angle1 = normalizeAngle(angle1)
	angle2 = normalizeAngle(angle2)

	local deltaAngle = math.abs(angle2 - angle1)

	-- choose shortest arc
	if deltaAngle > math.pi then
		deltaAngle = 2 * math.pi - deltaAngle
		if isRightDirection then
			angle1 = angle1 + 2 * math.pi
		else
			angle2 = angle2 + 2 * math.pi
		end
	else
		if isRightDirection then
			-- swap for clockwise
			angle1, angle2 = angle2, angle1
			deltaAngle = math.abs(angle2 - angle1)
			if deltaAngle > math.pi then
				deltaAngle = 2 * math.pi - deltaAngle
				angle2 = angle2 + 2 * math.pi
			end
		end
	end

	local arcLength = deltaAngle * radius

	-- debug if needed
	if nodeId then
		print(string.format("arc for %s: %.2f (angle1=%.2f, angle2=%.2f)", nodeId, arcLength, angle1, angle2))
	end

	return arcLength
end

-- ========================================
-- NODE CREATION FUNCTIONS
-- ========================================

-- create arc vertex structure for surfing nodes
local function createArcVertex(circle, isRightTangent, angle, point)
	local arcVertex = {
		id = string.format("%s-%s", isRightTangent and "R" or "L", tostring(circle.id)),
		circle = circle,
		isRight = isRightTangent,
		angle = angle,
		point = point
	}
	return arcVertex
end

-- create direct node (path directly to goal)
local function createDirectNode(fromPoint, goal, costFromStart, parentNode, nodeId)
	local directDistance = distance(fromPoint, goal)
	local line = convertPointsToLine(fromPoint, goal)

	return {
		id = nodeId or "direct",
		from = fromPoint,
		to = goal,
		type = "direct",
		length = directDistance,
		line = line,
		costFromStart = costFromStart + directDistance,
		estimatedCostToGoal = 0,
		totalEstimatedCost = costFromStart + directDistance,
		parentNode = parentNode
	}
end

-- create surfing node (path to a point on circle)
local function createSurfingNode(fromPoint, arcVertex, costFromStart, parentNode, nodeId)
	local surfingDistance = distance(fromPoint, arcVertex.point)
	local line = convertPointsToLine(fromPoint, arcVertex.point)
	local heuristic = distance(arcVertex.point, diagram.goal)

	return {
		id = nodeId,
		from = fromPoint,
		to = arcVertex,
		type = "surfing",
		length = surfingDistance,
		line = line,
		costFromStart = costFromStart + surfingDistance,
		estimatedCostToGoal = heuristic,
		totalEstimatedCost = costFromStart + surfingDistance + heuristic,
		parentNode = parentNode,
		arcPoints = generateArcPoints(arcVertex),
	}
end

-- ========================================
-- A* ALGORITHM FUNCTIONS
-- ========================================

-- find node with minimum totalEstimatedCost in open list
local function selectBestNode(openList)
	if #openList == 0 then
		return nil
	end

	local minIndex = 1
	local minCost = openList[1].totalEstimatedCost

	for i = 2, #openList do
		if openList[i].totalEstimatedCost < minCost then
			minCost = openList[i].totalEstimatedCost
			minIndex = i
		end
	end

	return table.remove(openList, minIndex)
end

-- reconstruct path from goal node back to start
local function reconstructPath(goalNode)
	local path = {}
	local currentNode = goalNode

	while currentNode do
		table.insert(path, 1, currentNode)
		currentNode = currentNode.parentNode
	end

	return path
end

-- ========================================
-- EDGE GENERATION FUNCTIONS
-- ========================================

-- generate direct edge from current position to goal
local function generateDirectEdge(diagram, currentNode)
	local fromPoint

	-- determine starting point based on node type
	if currentNode.type == "surfing" then
		-- calculate exact point A on circle for direct path to goal
		local circle = currentNode.to.circle
		local isRight = currentNode.to.isRight
		local tangentPoint, _ = calculatePointToCircleTangent(diagram.goal, circle, not isRight)

		if not tangentPoint then
			return nil -- no tangent exists (shouldn't happen for valid paths)
		end

		fromPoint = tangentPoint
	else
		fromPoint = currentNode.from
	end

	-- create line to goal
	local line = convertPointsToLine(fromPoint, diagram.goal)

	-- check if path is blocked
	local excludeCircle = (currentNode.type == "surfing") and currentNode.to.circle or nil
	if isLineBlocked(line, diagram.circles, excludeCircle) then
		return nil
	end

	print(string.format("direct path: circle %s at A(%.2f,%.2f) -> goal (%.2f,%.2f)", 
			currentNode.to.circle.id, fromPoint.x, fromPoint.y, diagram.goal.x, diagram.goal.y))

	-- create direct node
	local nodeId = currentNode.id .. "-direct"
	return createDirectNode(fromPoint, diagram.goal, currentNode.costFromStart, currentNode, nodeId)
end

-- generate edge from current surfing node to another circle
local function generateCircleToCircleEdge(diagram, currentNode, targetCircle, targetRight)
	if currentNode.type ~= "surfing" then
		return nil
	end

	local currentArcVertex = currentNode.to
	local currentCircle = currentArcVertex.circle
	local currentRight = currentArcVertex.isRight
	local currentAngle = currentArcVertex.angle

	-- skip if trying to go to the same circle
	if currentCircle == targetCircle then
		return nil
	end

	-- calculate tangent between circles
	local p1, p2, angle1, angle2 = calculateCircleToCircleTangent(
		currentCircle, currentRight, targetCircle, targetRight)

	if not p1 then
		return nil -- no valid tangent
	end



	-- check if tangent line is blocked
	local tangentLine = convertPointsToLine(p1, p2)
	if isLineBlocked(tangentLine, diagram.circles, currentCircle, targetCircle) then
		return nil
	end

	-- calculate arc length on current circle
	local arcLength = calculateArcLength(currentAngle, angle1, currentCircle.radius, currentRight, nodeId)

	-- create arc vertex for target circle
	local targetArcVertex = createArcVertex(targetCircle, targetRight, angle2, p2)

	-- create surfing node
	local nodeId = string.format("%s-%s%s-%s%s", 
		currentNode.id,
		currentRight and "R" or "L", tostring(currentCircle.id),
		targetRight and "R" or "L", tostring(targetCircle.id))

	local totalCost = currentNode.costFromStart + arcLength + distance(p1, p2)
	local heuristic = distance(p2, diagram.goal)

	print(string.format("circle-to-circle tangent: circle %s at A(%.2f,%.2f) -> circle %s at B(%.2f,%.2f)", 
			currentCircle.id, p1.x, p1.y, targetCircle.id, p2.x, p2.y))

	return {
		id = nodeId,
		from = currentArcVertex.point,
		to = targetArcVertex,
		type = "surfing",
		length = arcLength + distance(p1, p2),
		line = tangentLine,
		arcPoints = generateArcPoints(targetArcVertex),  -- arc points for visualization
		costFromStart = totalCost,
		estimatedCostToGoal = heuristic,
		totalEstimatedCost = totalCost + heuristic,
		parentNode = currentNode,
		arcLength = arcLength,
		tangentLength = distance(p1, p2)
	}
end

-- ========================================
-- INITIALIZATION FUNCTIONS
-- ========================================

-- create initial diagram structure
local function initializeDiagram(circles, start, goal)
	return {
		circles = circles,
		start = start,
		goal = goal,
		openList = {},
		closedSet = {},
		debugLines = {},
		debugArcs = {},
		nodeCount = 0
	}
end

-- check for direct path from start to goal
local function checkDirectPath(diagram)
	local line = convertPointsToLine(diagram.start, diagram.goal)

	if not isLineBlocked(line, diagram.circles) then
		return createDirectNode(diagram.start, diagram.goal, 0, nil, "start-direct")
	end

	return nil
end

-- add initial surfing nodes for each circle
local function addInitialNodes(diagram)
	local addedCount = 0

	for _, circle in ipairs(diagram.circles) do
		-- try right tangent
		local rightPoint, rightAngle = calculatePointToCircleTangent(diagram.start, circle, true)
		if rightPoint then
			local line = convertPointsToLine(diagram.start, rightPoint)
			if not isLineBlocked(line, diagram.circles, circle) then
				local arcVertex = createArcVertex(circle, true, rightAngle, rightPoint)
				local nodeId = string.format("start-R%s", tostring(circle.id))
				local heuristic = distance(rightPoint, diagram.goal)
				local pathLength = distance(diagram.start, rightPoint)

				local node = {
					id = nodeId,
					from = diagram.start,
					to = arcVertex,
					type = "surfing",
					length = pathLength,
					line = line,
					costFromStart = pathLength,
					estimatedCostToGoal = heuristic,
					totalEstimatedCost = pathLength + heuristic,
					parentNode = nil
				}

				table.insert(diagram.openList, node)
				table.insert(diagram.debugLines, line)
				addedCount = addedCount + 1

				print(string.format("created initial surfing node %s: start (%.2f,%.2f) -> circle %s at B(%.2f,%.2f)", 
						nodeId, diagram.start.x, diagram.start.y, circle.id, rightPoint.x, rightPoint.y))
			end
		end

		-- try left tangent
		local leftPoint, leftAngle = calculatePointToCircleTangent(diagram.start, circle, false)
		if leftPoint then
			local line = convertPointsToLine(diagram.start, leftPoint)
			if not isLineBlocked(line, diagram.circles, circle) then
				local arcVertex = createArcVertex(circle, false, leftAngle, leftPoint)
				local nodeId = string.format("start-L%s", tostring(circle.id))
				local heuristic = distance(leftPoint, diagram.goal)
				local pathLength = distance(diagram.start, leftPoint)

				local node = {
					id = nodeId,
					from = diagram.start,
					to = arcVertex,
					type = "surfing",
					length = pathLength,
					line = line,
					costFromStart = pathLength,
					estimatedCostToGoal = heuristic,
					totalEstimatedCost = pathLength + heuristic,
					parentNode = nil
				}

				table.insert(diagram.openList, node)
				table.insert(diagram.debugLines, line)
				addedCount = addedCount + 1

				print(string.format("created initial surfing node %s: start (%.2f,%.2f) -> circle %s at B(%.2f,%.2f)", 
						nodeId, diagram.start.x, diagram.start.y, circle.id, leftPoint.x, leftPoint.y))
			end
		end
	end

	return addedCount
end

local function reconstructDetailedPath(goalNode)
	local pathSegments = {}
	local currentNode = goalNode

	-- move backwards from goal to start
	while currentNode do
		table.insert(pathSegments, 1, currentNode)
		currentNode = currentNode.parentNode
	end

	-- extract points in order: include both A and B points
	local pathPoints = {}

	for i, segment in ipairs(pathSegments) do
		-- start point of the segment
		if i == 1 then
			table.insert(pathPoints, segment.from)
		end

		-- end point of the segment
		if segment.type == "direct" then
			table.insert(pathPoints, segment.to)  -- goal point
		elseif segment.type == "surfing" then
			-- For initial surfing segment (point to circle)
			if i == 1 then
				table.insert(pathPoints, segment.to.point)  -- point B
			else
				-- For circle-to-circle segments
				if segment.pointA and segment.pointB then
					table.insert(pathPoints, segment.pointA)  -- point A
					table.insert(pathPoints, segment.pointB)  -- point B
				else
					table.insert(pathPoints, segment.to.point)  -- fallback
				end
			end
		end
	end

	return pathPoints
end

-- ========================================
-- VALIDATION FUNCTIONS
-- ========================================

-- validate input parameters
local function validateInput(circles, start, goal)
	if not circles or not start or not goal then
		return false, "Missing required parameters"
	end

	if not start.x or not start.y or not goal.x or not goal.y then
		return false, "Start and goal must have x,y coordinates"
	end

	-- check if start/goal are inside circles
	for _, circle in ipairs(circles) do
		if not circle.x or not circle.y or not circle.radius then
			return false, "Circles must have x, y, radius properties"
		end

		local startDist = distance(start, circle)
		if startDist <= circle.radius then
			return false, string.format("Start point inside circle %s", tostring(circle.id))
		end

		local goalDist = distance(goal, circle)
		if goalDist <= circle.radius then
			return false, string.format("Goal point inside circle %s", tostring(circle.id))
		end
	end

	return true, nil
end

-- ========================================
-- PUBLIC API
-- ========================================

-- main public pathfinding function
function pathfinding(circles, start, goal)
	-- assign IDs
	start.id = 'start'
	goal.id = 'goal'

	for index, circle in ipairs(circles) do
		if not circle.id then
			circle.id = tostring(index)
		end
	end

	print(string.format("starting pathfinding: start=(%.2f,%.2f), goal=(%.2f,%.2f), circles=%d", 
			start.x, start.y, goal.x, goal.y, #circles))

	-- validate input
	local isValid, errorMsg = validateInput(circles, start, goal)
	if not isValid then
		print("validation error: " .. errorMsg)
		return nil, nil
	end

	-- initialize
	local diagram = initializeDiagram(circles, start, goal)

	-- check for direct path
	local directNode = checkDirectPath(diagram)
	if directNode then
		table.insert(diagram.debugLines, directNode.line)
		print("pathfinding completed - direct path found")
		return {directNode}, diagram
	end

	-- add initial nodes
	local initialCount = addInitialNodes(diagram)
	print(string.format("added %d initial nodes to open list", initialCount))

	if initialCount == 0 then
		print("no valid initial paths found")
		return nil, diagram
	end

	-- main A* loop
	while #diagram.openList > 0 do
		local currentNode = selectBestNode(diagram.openList)
		if not currentNode then
			break
		end

		local nodeId = currentNode.id

		-- check if not already processed
		if not diagram.closedSet[nodeId] then
			-- mark as processed
			diagram.closedSet[nodeId] = true
			diagram.nodeCount = diagram.nodeCount + 1

			print(string.format("processing node %s (step %d)", nodeId, diagram.nodeCount))

			-- check if goal reached
			if currentNode.type == "direct" then
				print(string.format("path found! processed %d nodes", diagram.nodeCount))
				local pathNodes = reconstructPath(currentNode)
				local detailedPath = reconstructDetailedPath(currentNode)
				return reconstructPath(currentNode), diagram
			end

			-- expand current node
			if currentNode.type == "surfing" then
				-- try direct path to goal
				local directEdge = generateDirectEdge(diagram, currentNode)
				if directEdge then
					table.insert(diagram.openList, directEdge)
					table.insert(diagram.debugLines, directEdge.line)
				end

				-- try paths to other circles
				for _, targetCircle in ipairs(circles) do
					-- try right tangent
					local rightEdge = generateCircleToCircleEdge(diagram, currentNode, targetCircle, true)
					if rightEdge and not diagram.closedSet[rightEdge.id] then
						table.insert(diagram.openList, rightEdge)
						table.insert(diagram.debugLines, rightEdge.line)
					end

					-- try left tangent
					local leftEdge = generateCircleToCircleEdge(diagram, currentNode, targetCircle, false)
					if leftEdge and not diagram.closedSet[leftEdge.id] then
						table.insert(diagram.openList, leftEdge)
						table.insert(diagram.debugLines, leftEdge.line)
					end
				end
			end
		end
	end

	print("pathfinding completed - no path found")
	return nil, diagram
end

return pathfinding