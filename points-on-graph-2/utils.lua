-- utils.lua
local utils = {}


-- Calculates the squared distance between two points
function utils.getDistanceSquared(p1, p2)
	local dx = p2.x - p1.x
	local dy = p2.y - p1.y
	return dx * dx + dy * dy
end

-- Calculates the Euclidean length of a vector
function utils.getLength(dx, dy)
	return math.sqrt(dx * dx + dy * dy)
end

-- Adds a point to an edge’s points list
function utils.addPointToEdge(point, edge)
	if not edge.points then edge.points = {} end
	table.insert(edge.points, point)
end

-- Removes a point from an edge’s points list
function utils.removePointFromEdge(point, edge)
	if edge.points then
		for i, p in ipairs(edge.points) do
			if p == point then
				table.remove(edge.points, i)
				break
			end
		end
	end
end

-- Finds an edge between two nodes
function utils.findEdgeBetween(fromId, toId, edges)
	for _, edge in pairs(edges) do
		if edge.nodeIndices[1] == fromId and edge.nodeIndices[#edge.nodeIndices] == toId then
			return edge
		end
	end
	return nil
end

-- Calculates travel time for an edge
function utils.calculateEdgeTravelTime(edge, maxSpeed)
	if not edge.length then
		local startNode = diagram.nodes[edge.nodeIndices[1]]
		local endNode = diagram.nodes[edge.nodeIndices[#edge.nodeIndices]]
		if startNode and endNode then
			local dx = endNode.x - startNode.x
			local dy = endNode.y - startNode.y
			edge.length = utils.getLength(dx, dy)
		else
			edge.length = 1 -- Default value
		end
	end
	return edge.length / maxSpeed
end

-- Finds the closest lane on the next edge to the current position
function utils.findClosestLane(edge, currentX, currentY)
	local lanes = edge.lanes or 2
	if lanes == 1 then
		return 1
	end
	local bestLane = 1
	local minDistance = math.huge
	for lane = 1, lanes do
		local laneLine = edge.laneLines[lane]
		if laneLine and #laneLine >= 2 then
			local x = laneLine[1]
			local y = laneLine[2]
			local dx = x - currentX
			local dy = y - currentY
			local distance = math.sqrt(dx * dx + dy * dy)
			if distance < minDistance then
				minDistance = distance
				bestLane = lane
			end
		end
	end
	return bestLane
end

-- Finds the closest point on a lane to a given position
function utils.findClosestPointOnLane(edge, lane, targetX, targetY)
	local laneLine = edge.laneLines[lane]
	if not laneLine then
		print ('no lane', tostring (lane))
		elseif #laneLine < 4 then
		return laneLine[1] or edge.line[1], laneLine[2] or edge.line[2], 0
	end
	local minDistance = math.huge
	local closestX, closestY, closestT = laneLine[1], laneLine[2], 0
	local totalSegments = (#laneLine / 2) - 1
	local totalLength = edge.length
	local segmentLength = totalLength / totalSegments
	for seg = 1, totalSegments do
		local i1 = (seg - 1) * 2 + 1
		local x1, y1 = laneLine[i1], laneLine[i1 + 1]
		local x2, y2 = laneLine[i1 + 2], laneLine[i1 + 3]
		local dx = x2 - x1
		local dy = y2 - y1
		local len = math.sqrt(dx * dx + dy * dy)
		if len > 0 then
			local t = ((targetX - x1) * dx + (targetY - y1) * dy) / (len * len)
			t = math.max(0, math.min(1, t))
			local projX = x1 + t * dx
			local projY = y1 + t * dy
			local distX = projX - targetX
			local distY = projY - targetY
			local distance = math.sqrt(distX * distX + distY * distY)
			if distance < minDistance then
				minDistance = distance
				closestX = projX
				closestY = projY
				closestT = ((seg - 1) + t) / totalSegments
			end
		end
	end
	return closestX, closestY, closestT
end

-- finds the shortest route between two nodes using dijkstra's algorithm
function utils.findShortestPath(startId, endId, diagram)
	local maxSpeed = 60
	local distances = {}
	local previous = {}
	local unvisited = {}
	for _, node in pairs(diagram.nodes) do
		distances[node.id] = math.huge
		unvisited[node.id] = true
	end
	distances[startId] = 0
	while next(unvisited) do
		local currentId = nil
		local minDist = math.huge
		for id in pairs(unvisited) do
			if distances[id] < minDist then
				minDist = distances[id]
				currentId = id
			end
		end
		if currentId == nil then break end
		if currentId == endId then break end
		unvisited[currentId] = nil
		local currentNode = diagram.nodes[currentId]
		if currentNode.nextEdges then
			for _, edge in ipairs(currentNode.nextEdges) do
				if edge.nodeIndices and #edge.nodeIndices >= 2 then
					local neighborId = edge.nodeIndices[#edge.nodeIndices]
					if unvisited[neighborId] then
						local travelTime = utils.calculateEdgeTravelTime(edge, maxSpeed)
						local alt = distances[currentId] + travelTime
						if alt < distances[neighborId] then
							distances[neighborId] = alt
							previous[neighborId] = currentId
						end
					end
				end
			end
		end
	end
	local route = {}
	local current = endId
	while current do
		table.insert(route, 1, current)
		current = previous[current]
	end
	return route, distances[endId]
end

function utils.clamp(x, min, max)
	return math.max(min, math.min(max, x))
end

-- gets points on specific edge and lane
function utils.getPointsOnEdgeLane(edge, lane)
	local result = {}
	for _, point in ipairs(edge.points) do
		if point.edges[point.currentEdgeIndex] == edge and point.lane == lane then
			table.insert(result, point)
		end
	end
	return result
end

utils.lineOffset = function(line, offset)
	local result = {}
	for i = 1, #line - 2, 2 do
		local x1, y1 = line[i], line[i + 1]
		local x2, y2 = line[i + 2], line[i + 3]
		local dx = x2 - x1
		local dy = y2 - y1
		local len = math.sqrt(dx * dx + dy * dy)
		if len > 0 then
			local perpX = -dy / len * offset
			local perpY = dx / len * offset
			table.insert(result, x1 + perpX)
			table.insert(result, y1 + perpY)
		else
			table.insert(result, x1)
			table.insert(result, y1)
		end
	end
	local x, y = line[#line - 1], line[#line]
	local prevX, prevY = line[#line - 3], line[#line - 2]
	local dx = x - prevX
	local dy = y - prevY
	local len = math.sqrt(dx * dx + dy * dy)
	if len > 0 then
		local perpX = -dy / len * offset
		local perpY = dx / len * offset
		table.insert(result, x + perpX)
		table.insert(result, y + perpY)
	else
		table.insert(result, x)
		table.insert(result, y)
	end
	return result
end


utils.intersectInfiniteSegments = function(x1, y1, x2, y2, x3, y3, x4, y4)
	local denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
	if math.abs(denom) < 1e-6 then
		return nil
	end
	local t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom
	local x = x1 + t * (x2 - x1)
	local y = y1 + t * (y2 - y1)
	return {x, y}
end

-- evaluates a quadratic bezier curve at t (0 to 1)
function utils.quadraticBezier(x1, y1, x2, y2, x3, y3, t)
	local u = 1 - t
	local x = u * u * x1 + 2 * u * t * x2 + t * t * x3
	local y = u * u * y1 + 2 * u * t * y2 + t * t * y3
	return x, y
end

-- generates points for a bezier curve
--function utils.generateBezierPoints (startNode, endNode, controlPoint, amount)
function utils.generateBezierPoints (x1, y1, x2, y2, x3, y3, amount)
	local points = {}
	for i = 0, amount do
		local t = i / amount
		local x, y = utils.quadraticBezier(x1, y1, x2, y2, x3, y3, t)
		table.insert(points, x)
		table.insert(points, y)
	end
	return points
end


-- normalizes an angle to [-pi, pi]
function utils.normalizeAngle(angle)
	while angle > math.pi do angle = angle - 2 * math.pi end
	while angle < -math.pi do angle = angle + 2 * math.pi end
	return angle
end

-- calculates angle between two vectors
function utils.getAngleBetweenVectors(dx1, dy1, dx2, dy2)
	local dot = dx1 * dx2 + dy1 * dy2
	local det = dx1 * dy2 - dy1 * dx2
	local angle = math.atan2(det, dot)
	return utils.normalizeAngle(angle)
end

-- converts a node route to a list of edges
--function utils.buildEdgesFromPath(route, edes)
--	local edges = {}
--	for i = 1, #route - 1 do
--		local edge = utils.findEdgeBetween(route[i], route[i + 1], edges)
--		if edge then
--			table.insert(edges, edge)
--		else
--			return nil
--		end
--	end
--	return edges
--end


-- interpolates speed
function utils.interpolateSpeed(dist, hardRadius, softRadius, minSpeed, maxSpeed)
	if dist < hardRadius then return minSpeed end
	local f = (dist - hardRadius) / (softRadius - hardRadius)
	return minSpeed + (maxSpeed - minSpeed) * math.max(0, f)
end



-- computes shortest route
function utils.computePath(startId, endId, points, diagram)
	local route, distance = utils.findShortestPath(startId, endId, diagram)
	if #route < 2 then
		return nil, nil
	end
	return route, distance
end

-- gets point color
function utils.getColorFromStatus(status)
	if status == "yielding" then return {1, 0, 0}
	elseif status == "priority" then return {0, 1, 0}
	else return {1, 1, 1} end
end

return utils