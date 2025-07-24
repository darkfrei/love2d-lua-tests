-- circle-pathfinder.lua
-- https://github.com/darkfrei/love2d-lua-tests/tree/main/circle-tangent-path
local pathfinder = {}

-- calculate distance between two points
local function distance(point1, point2)
	local dx = point2.x - point1.x
	local dy = point2.y - point1.y
	return math.sqrt(dx*dx + dy*dy)
end

local function getLineLength(line)
	local x1, y1, x2, y2 = line[1], line[2], line[3], line[4]
	local dx = x2 - x1
	local dy = y2 - y1
	return math.sqrt(dx*dx + dy*dy)
end

local function normalizeAngle(a)
	return (a + math.pi) % (2 * math.pi) - math.pi
end

local function getArcLength(arc)
	local delta = arc.angle2 - arc.angle1
	return math.abs(delta) * arc.radius
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

-- check if line intersects any circle except optional excluded ones
local function anyLineCircleIntersection(line, circles, exceptCircle, exceptCircle2)
	for _, circle in ipairs(circles) do
		if (exceptCircle and circle == exceptCircle) or (exceptCircle2 and circle == exceptCircle2) then
			-- skip excluded circles
		elseif isLineCircleIntersection(line, circle) then
			return true
		end
	end
	return false
end

-- calculate right or left tangent from a point to a circle
local function calculatePointToCircleTangent(point, circle, isRight)
	local dx = point.x - circle.x
	local dy = point.y - circle.y
	local distSq = dx*dx + dy*dy
	local radiusSq = circle.radius*circle.radius

	if distSq <= radiusSq then return nil end

	local invDist = 1/math.sqrt(distSq)
	dx = dx * invDist
	dy = dy * invDist

	local a = radiusSq * invDist
	local b = circle.radius * math.sqrt(distSq - radiusSq) * invDist
	local sign = isRight and 1 or -1

	local p = {
		x = circle.x + a*dx + b*dy*sign,
		y = circle.y + a*dy - b*dx*sign
	}

	return p
end

-- calculate external tangent line between two circles
local function calculateCircleCircleTangentLine(fromCircle, fromRight, toCircle, toRight)
	local x1, y1, r1 = fromCircle.x, fromCircle.y, fromCircle.radius
	local x2, y2, r2 = toCircle.x, toCircle.y, toCircle.radius

	local dx = x2 - x1
	local dy = y2 - y1
	local dist = math.sqrt(dx*dx + dy*dy)

	if dist < math.abs(r1 - r2) or dist < r1 + r2 or (dist == 0 and r1 == r2) then
		return nil
	end

	local r1_sign = fromRight and 1 or -1
	local r2_sign = toRight and 1 or -1

	local theta = math.asin((-r1 * r1_sign + r2 * r2_sign) / dist)
	local alpha = math.atan2(dy, dx)

	local angle1 = alpha + theta + r1_sign * math.pi/2
	local angle2 = alpha + theta + r2_sign * math.pi/2

	local q = {
		x = x1 + r1 * math.cos(angle1),
		y = y1 + r1 * math.sin(angle1)
	}
	local p = {
		x = x2 + r2 * math.cos(angle2),
		y = y2 + r2 * math.sin(angle2)
	}

	return q, p
end

-- create a point node
local function newPointNode(point, id)
	return {
		x = point.x,
		y = point.y,
		id = id
	}
end

-- check if a point is inside any circle
local function isPointInAnyCircle(point, circles)
	for _, circle in ipairs(circles) do
		if distance(point, circle) < circle.radius then
			return true
		end
	end
	return false
end

-- create a line segment from two points
local function newLine(p1, p2)
	return {p1.x, p1.y, p2.x, p2.y}
end

-- try a direct path from start to goal
local function getSimpleSolution(startNode, goalNode, circles)
	local line = newLine(startNode, goalNode)
	local length = distance(startNode, goalNode)
	local simplePath = {
		fromNode = startNode,
		toNode = goalNode,
		id = startNode.id .. '-' .. goalNode.id,
		line = line,
		length = length
	}

	local isCollision = anyLineCircleIntersection(line, circles)
	table.insert(pathfinder.globalTangentLines, line)
	if not isCollision or isPointInAnyCircle(startNode, circles) or isPointInAnyCircle(goalNode, circles) then
		return {simplePath}, length
	end
	return nil
end

-- create an arc segment on a circle
local function newArc(circle, pointP, pointQ, fromRight)
	local angle1 = math.atan2(pointP.y - circle.y, pointP.x - circle.x)
	local angle2 = math.atan2(pointQ.y - circle.y, pointQ.x - circle.x)

	angle1 = normalizeAngle(angle1)
	angle2 = normalizeAngle(angle2)

	local deltaAngle = math.abs(angle2 - angle1)
	if deltaAngle > math.pi then
		deltaAngle = 2 * math.pi - deltaAngle
		if fromRight then
			angle1 = angle1 + 2 * math.pi
		else
			angle2 = angle2 + 2 * math.pi
		end
	elseif fromRight then
		angle1, angle2 = angle2, angle1
		deltaAngle = math.abs(angle2 - angle1)
		if deltaAngle > math.pi then
			deltaAngle = 2 * math.pi - deltaAngle
			angle2 = angle2 + 2 * math.pi
		end
	end

	local length = deltaAngle * circle.radius

	return {
		x = circle.x,
		y = circle.y,
		radius = circle.radius,
		angle1 = angle1,
		angle2 = angle2,
		length = length,
		pointP = pointP,
	}
end

-- generate initial queue of edges from start point to circles
local function getStartQueue(startNode, circles)
	local queue = {}
	local trueFalseArray = {true, false}
	for id, toCircle in ipairs(circles) do
		for _, isRight in ipairs(trueFalseArray) do
			local edgeId = startNode.id .. '-' .. (isRight and 'R' or 'L') .. toCircle.id
			local tangentP = calculatePointToCircleTangent(startNode, toCircle, isRight)
			if tangentP then
				local line = newLine(startNode, tangentP)
				local isCollision = anyLineCircleIntersection(line, circles, toCircle)
				if not isCollision then
					local segment = {line = line, arc = nil, id = edgeId}
					local path = {segment}
					local totalLength = distance(startNode, tangentP)
					local edge = {
						id = edgeId,
						fromNode = startNode,
						toNode = toCircle,
						isRight = isRight,
						path = path,
						totalLength = totalLength,
						pointP = tangentP,
						stringID = edgeId
					}
					table.insert(queue, edge)
					table.insert(pathfinder.globalTangentLines, line)
				end
			end
		end
	end
	return queue
end

-- finds intersection points of two circles
local function findCircleIntersections(circle1, circle2)
	local x1, y1, r1 = circle1.x, circle1.y, circle1.radius
	local x2, y2, r2 = circle2.x, circle2.y, circle2.radius

	local dx = x2 - x1
	local dy = y2 - y1
	local distSq = dx*dx + dy*dy
	local dist = math.sqrt(distSq)

	if dist > r1 + r2 or dist < math.abs(r1 - r2) then
		return {}
	end

	if dist == 0 and r1 == r2 then
		return nil
	end

	local a = (r1*r1 - r2*r2 + distSq) / (2 * dist)
	local h = math.sqrt(r1*r1 - a*a)

	local xm = x1 + a * dx / dist
	local ym = y1 + a * dy / dist

	local xs1 = xm + h * dy / dist
	local ys1 = ym - h * dx / dist

	if dist == r1 + r2 or dist == math.abs(r1 - r2) then
		return {{x = xs1, y = ys1}}
	end

	local xs2 = xm - h * dy / dist
	local ys2 = ym + h * dx / dist

	return {
		{x = xs1, y = ys1},
		{x = xs2, y = ys2}
	}
end

-- check if an arc intersects a circle
local function isArcCircleIntersection(arc, circle, fromRight)
	local intersections = findCircleIntersections(arc, circle)
	if not intersections or #intersections == 0 then
		return false
	end
	for _, point in ipairs(intersections) do
		local angle = math.atan2(point.y - arc.y, point.x - arc.x)
		local da1 = normalizeAngle(angle - arc.angle1)
		local da2 = normalizeAngle(arc.angle2 - angle)
		if fromRight then
			da1, da2 = da2, da1
		end
		if da1 >= 0 and da2 >= 0 then
			return true
		end
	end
	local function isPointInCircle(px, py, circle)
		local dx = px - circle.x
		local dy = py - circle.y
		return dx*dx + dy*dy <= circle.radius*circle.radius
	end
	local p1 = {x = arc.x + arc.radius * math.cos(arc.angle1), y = arc.y + arc.radius * math.sin(arc.angle1)}
	local p2 = {x = arc.x + arc.radius * math.cos(arc.angle2), y = arc.y + arc.radius * math.sin(arc.angle2)}
	local p1Inside = isPointInCircle(p1.x, p1.y, circle)
	local p2Inside = isPointInCircle(p2.x, p2.y, circle)
	if p1Inside or p2Inside then
		return true
	end
	return false
end

-- check if arc intersects any circle except optional excluded ones
local function anyArcCircleIntersection(arc, circles, exceptCircle, exceptCircle2, fromRight)
	for _, circle in ipairs(circles) do
		if (exceptCircle and circle == exceptCircle) or (exceptCircle2 and circle == exceptCircle2) then
			-- skip excluded circles
		elseif isArcCircleIntersection(arc, circle, fromRight) then
			return true
		end
	end
	return false
end

local function sortMetaPaths(metapaths)
	table.sort(metapaths, function(a, b)
			return a.totalLength < b.totalLength
		end)
end

-- create arc and check for collisions
local function createArc(fromCircle, pointP, tangentQ, fromRight, prevEdge, fromNode, toNodeId, circles, toCircle)
	local arc = newArc(fromCircle, pointP, tangentQ, fromRight)
	local isRight1 = prevEdge and prevEdge.isRight
	local prevIDpref = prevEdge and (isRight1 and 'R' or 'L') or ''
	arc.id = prevIDpref .. fromNode.id .. '-' .. (fromRight and 'R' or 'L') .. fromCircle.id .. '-' .. toNodeId
	local arcCollision = anyArcCircleIntersection(arc, circles, fromCircle, toNodeId == 'goal' and nil or toCircle, fromRight)
	arc.collision = arcCollision
	if arcCollision then
		return nil
	end
	return arc
end

-- add edge to queue
local function addEdgeToQueue(fromCircle, toNode, line, arc, edgeId, path, totalLength, stringID, queue, globalTangentLines, edge, toRight, pointP)
	local segment = {line = line, arc = arc, id = edgeId}
	local newPath = {unpack(path)}
	table.insert(newPath, segment)
	local newEdge = {
		id = edgeId,
		fromNode = fromCircle,
		toNode = toNode,
		isRight = toNode.id ~= 'goal' and toRight or nil,
		path = newPath,
		totalLength = totalLength,
		pointP = toNode.id ~= 'goal' and pointP or nil,
		prevEdge = edge,
		stringID = stringID
	}
	table.insert(queue, newEdge)
	table.insert(globalTangentLines, line)
end

-- process edge to goal
local function processToGoal(edge, fromCircle, fromRight, goalNode, circles, queue, globalTangentLines)
	local tangentQ = calculatePointToCircleTangent(goalNode, fromCircle, not fromRight)
	if not tangentQ then
		return
	end
	if not edge.pointP then
		return
	end
	local goalLine = newLine(tangentQ, goalNode)
	local isCollision = anyLineCircleIntersection(goalLine, circles, fromCircle)
	if isCollision then
		return
	end
	local edgeId = edge.stringID .. '-' .. goalNode.id
	local pointP = edge.pointP
	local arc = createArc(fromCircle, pointP, tangentQ, fromRight, edge.prevEdge, edge.fromNode, goalNode.id, circles, nil)
	if arc then
		local lineLength = distance(tangentQ, goalNode)
		local arcLength = arc.length
		local totalLength = edge.totalLength + lineLength + arcLength
		addEdgeToQueue(fromCircle, goalNode, goalLine, arc, edgeId, edge.path, totalLength, edge.stringID .. '-' .. goalNode.id, queue, globalTangentLines, edge, nil, pointP)
	end
end

-- process edges to other circles
local function processToCircles(edge, fromCircle, fromRight, circles, queue, edgeHash, globalTangentLines)
	local trueFalseArray = {true, false}
	for _, toCircle in ipairs(circles) do
		if fromCircle ~= toCircle then
			for _, toRight in ipairs(trueFalseArray) do
				local tangentQ, tangentP = calculateCircleCircleTangentLine(fromCircle, fromRight, toCircle, toRight)
				if tangentQ then
					local line = newLine(tangentQ, tangentP)
					local isCollision = anyLineCircleIntersection(line, circles, fromCircle, toCircle)
					if not isCollision then
						local edgeId = (fromRight and 'R' or 'L') .. fromCircle.id .. '-' .. (toRight and 'R' or 'L') .. toCircle.id
						if not edgeHash[edgeId] then
							edgeHash[edgeId] = true
							local pointP = edge.pointP
							local arc = createArc(fromCircle, pointP, tangentQ, fromRight, edge.prevEdge, edge.fromNode, (toRight and 'R' or 'L') .. toCircle.id, circles, toCircle)
							if arc then
								local lineLength = distance(tangentQ, tangentP)
								local arcLength = arc.length
								local totalLength = edge.totalLength + arcLength + lineLength
								addEdgeToQueue(fromCircle, toCircle, line, arc, edgeId, edge.path, totalLength, edge.stringID .. '-' .. (toRight and 'R' or 'L') .. toCircle.id, queue, globalTangentLines, edge, toRight, tangentP)
							end
						end
					end
				end
			end
		end
	end
end

-- find the shortest path from start to goal avoiding circles
function pathfinder.getShortestPath(startPoint, goalPoint, circles)
	pathfinder.globalTangentLines = {}

	local startNode = newPointNode(startPoint, "start")
	local goalNode = newPointNode(goalPoint, "goal")
	for id, circle in ipairs(circles) do
		circle.id = id
	end
	local simplePath, length = getSimpleSolution(startNode, goalNode, circles)
	if simplePath then 
		return simplePath, length
	end

	local queue = getStartQueue(startNode, circles)
	local metaPaths = {}
	local metaPath = nil
	local shortestLength = math.huge
	local edgeHash = {}

	while #queue > 0 do
		local minIndex, minLength = 1, queue[1].totalLength
		for i = 2, #queue do
			if queue[i].totalLength < minLength then
				minIndex, minLength = i, queue[i].totalLength
			end
		end
		local edge = table.remove(queue, minIndex)
		local toNode = edge.toNode

		if toNode == goalNode then
			table.insert(metaPaths, {path = edge.path, totalLength = edge.totalLength, stringID = edge.stringID})
			if edge.totalLength <= shortestLength then
				shortestLength = edge.totalLength
				metaPath = edge
			end
		else
			local fromCircle = edge.toNode
			local fromRight = edge.isRight
			processToGoal(edge, fromCircle, fromRight, goalNode, circles, queue, pathfinder.globalTangentLines)
			processToCircles(edge, fromCircle, fromRight, circles, queue, edgeHash, pathfinder.globalTangentLines)
		end
	end

--	local bestPath = metaPaths[1]
--	if bestPath then
		return metaPath.path, metaPath.totalLength
--	end
--	return nil
end

pathfinder.globalTangentLines = {}

return pathfinder