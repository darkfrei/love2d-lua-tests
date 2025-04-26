-- points.lua
-- manages moving points along edges with multiple lanes, handling spawning, velocity updates, pathfinding, and drawing
-- used by main.lua in the game loop

local diagram = require("diagram")
--local data = require("data")



local points = {}

-- configuration constants
local spawnInterval = 0.8
local spawnTimer = 0
local maxSpeed = 60
local hardRadius = 15
local softRadius = 50 -- increased to reduce speed spikes
local minSpeed = 1
local pointIdCounter = 0
local laneWidth = 10  -- pixels between lanes for visualization (synced with diagram.lua)
local densityThreshold = 5  -- number of points on a lane to consider it overloaded
local laneChangeSpeed = 2  -- speed of lane change (progress per second)
local minTransitionDuration = 0.1  -- minimum transition duration (seconds)
local maxTransitionDuration = 0.5  -- maximum transition duration (seconds)
local distanceThreshold = 0.1  -- threshold for zero distance (pixels)

-- test route for spawning (since data.routes doesn't exist)
local testRoute = {startNodeId = 64, targetNodeId = 21}

-- calculates travel time for an edge
local function calculateEdgeTravelTime(edge)
	return edge.length / maxSpeed
end

function math.clamp (x, min, max)
	return math.max(min, math.min(max, x))
end



-- finds fastest path using Dijkstra's algorithm
function points.findShortestPath(startId, endId)
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
				local neighborId = edge.endNode.id
				if unvisited[neighborId] then
					local travelTime = calculateEdgeTravelTime(edge)
					local alt = distances[currentId] + travelTime
					if alt < distances[neighborId] then
						distances[neighborId] = alt
						previous[neighborId] = currentId
					end
				end
			end
		end
	end
	local path = {}
	local current = endId
	while current do
		table.insert(path, 1, current)
		current = previous[current]
	end
	if #path < 2 then
		-- print("no path from " .. startId .. " to " .. endId)
	end
	return path, distances[endId]
end

-- finds an edge between two nodes
local function findEdgeBetween(fromId, toId)
	for _, edge in pairs(diagram.edges) do
		if edge.nodeIndices[1] == fromId and edge.nodeIndices[#edge.nodeIndices] == toId then
			return edge
		end
	end
	return nil
end

-- gets points on specific edge and lane
local function getPointsOnEdgeLane(edge, lane)
	local result = {}
	for _, point in ipairs(points) do
		if point.edges[point.currentEdgeIndex] == edge and point.lane == lane then
			table.insert(result, point)
		end
	end
	return result
end

-- adds a point to an edge’s points list
local function addPointToEdge(point, edge)
	if not edge.points then edge.points = {} end
	table.insert(edge.points, point)
end

-- removes a point from an edge’s points list
local function removePointFromEdge(point, edge)
	if edge.points then
		for i, p in ipairs(edge.points) do
			if p == point then
				table.remove(edge.points, i)
				break
			end
		end
	end
end

-- converts a node path to a list of edges
local function buildEdgesFromPath(path)
	local edges = {}
	for i = 1, #path - 1 do
		local edge = findEdgeBetween(path[i], path[i + 1])
		if edge then
			table.insert(edges, edge)
		else
			return nil
		end
	end
	return edges
end

-- chooses optimal lane based on route, speed, and density
local function chooseLane(point, edge)
	local lanes = edge.lanes or 2
	local nextEdgeId = point.currentEdgeIndex + 1 <= #point.edges and point.edges[point.currentEdgeIndex + 1].id or nil
	local bestLane = 1
	local minDensity = math.huge
	for lane = 1, lanes do
		local validLane = true
		if nextEdgeId and edge.laneDestinations and edge.laneDestinations[lane] then
			validLane = false
			for _, destId in ipairs(edge.laneDestinations[lane]) do
				if destId == nextEdgeId then
					validLane = true
					break
				end
			end
		end
		if validLane then
			local pointsOnLane = getPointsOnEdgeLane(edge, lane)
			local density = #pointsOnLane
			if density < minDensity then
				minDensity = density
				bestLane = lane
			elseif density == minDensity and point.speed > maxSpeed * 0.8 then
				bestLane = math.min(bestLane, lane)
			end
		end
	end
	return bestLane
end

-- finds closest lane on next edge to current position
local function findClosestLane(edge, currentX, currentY)
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

-- finds closest point on a lane to a given position
local function findClosestPointOnLane(edge, lane, targetX, targetY)
	local laneLine = edge.laneLines[lane]
	if not laneLine or #laneLine < 4 then
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

-- checks if lane change is safe
local function canChangeLane(point, edge, targetLane)
	local pointsOnTargetLane = getPointsOnEdgeLane(edge, targetLane)
	for _, otherP in ipairs(pointsOnTargetLane) do
		if otherP ~= point and math.abs(otherP.distanceTraveled - point.distanceTraveled) < hardRadius then
			return false
		end
	end
	return true
end

-- creates a new point with lane assignment
local function createPoint(edges, startNode, targetNodeId)
	pointIdCounter = pointIdCounter + 1
	local point = {
		id = pointIdCounter,
		edges = edges,
		currentEdgeIndex = 1,
		distanceTraveled = math.random() / 10000,
		x = startNode.x,
		y = startNode.y,
		speed = maxSpeed,
		effectiveSpeed = maxSpeed,
		lastDistanceTraveled = 0,
		lastTransitionProgress = 0,
		lastLaneX = startNode.x,
		lastLaneY = startNode.y,
		status = "default",
		interactionLines = {},
		targetNodeId = targetNodeId,
		case = 0,
		lane = 1, -- single lane
		isTransitioning = false,
		transitionProgress = 0,
		transitionDuration = 0.2,
		transitionFromX = 0,
		transitionFromY = 0,
		transitionToX = 0,
		transitionToY = 0,
		laneX = startNode.x,
		laneY = startNode.y,
		transitionToT = 0
	}
	if edges[1] then
		local laneLine = edges[1].laneLines and edges[1].laneLines[1]
		if laneLine and #laneLine >= 2 then
			point.laneX = laneLine[1]
			point.laneY = laneLine[2]
			point.lastLaneX = point.laneX
			point.lastLaneY = point.laneY
		end
	end
	return point
end

-- spawns a point for a specific route
local function spawnPointForRoute(startNodeId, targetNodeId)
	local path = points.findShortestPath(startNodeId, targetNodeId)
	if not path or #path < 2 then
		print(string.format("spawn failed: no path from %d to %d", startNodeId, targetNodeId))
		return
	end
	local edges = buildEdgesFromPath(path)
	if not edges then
		print(string.format("spawn failed: no edges from %d to %d", startNodeId, targetNodeId))
		return
	end
	local startNode = diagram.nodes[startNodeId]
	local point = createPoint(edges, startNode, targetNodeId)
	table.insert(points, point)
	addPointToEdge(point, edges[1])
	print(string.format("spawned point %d from node %d to %d", point.id, startNodeId, targetNodeId))
end

--print = function () end

-- updates spawn timer
local function updateSpawnTimer(dt)
	spawnTimer = spawnTimer + dt
	if spawnTimer >= spawnInterval then
		spawnTimer = spawnTimer - spawnInterval
		return true
	end
	return false
end

-- checks if can spawn point for route
local function canSpawnPointForRoute(startNodeId, targetNodeId)
	local path = points.findShortestPath(startNodeId, targetNodeId)
	if not path or #path < 2 then return false end
	local firstEdge = findEdgeBetween(path[1], path[2])
	if not firstEdge then return false end
	local pointsOnEdge = getPointsOnEdgeLane(firstEdge, 1)
	for _, point in ipairs(pointsOnEdge) do
		if point.distanceTraveled < hardRadius then
			return false
		end
	end
	return true
end

-- spawns particles
local function spawnParticles(dt, paths)
	if updateSpawnTimer(dt) then
		-- use test route since data.routes doesn't exist
		if canSpawnPointForRoute(testRoute.startNodeId, testRoute.targetNodeId) then
			spawnPointForRoute(testRoute.startNodeId, testRoute.targetNodeId)
		end
	end
end

-- calculates distance squared
local function getDistanceSquared(p1, p2)
	local dx = p2.x - p1.x
	local dy = p2.y - p1.y
	return dx * dx + dy * dy
end

-- interpolates speed
local function interpolateSpeed(dist, hardRadius, softRadius, minSpeed, maxSpeed)
	if dist < hardRadius then return minSpeed end
	local f = (dist - hardRadius) / (softRadius - hardRadius)
	return minSpeed + (maxSpeed - minSpeed) * math.max(0, f)
end

-- behaviour 1: collisions on same edge (single lane)
local function behaviour1_sameEdge(thisP, edge, thisDistToEnd, logMessages)
	local newSpeed = thisP.speed or maxSpeed
	local sameLanePoints = getPointsOnEdgeLane(edge, 1) -- single lane
	for _, otherP in ipairs(sameLanePoints) do
		if thisP ~= otherP then
			local distAlongEdge = math.abs(thisP.distanceTraveled - otherP.distanceTraveled)
			local dist2D = math.sqrt(getDistanceSquared(thisP, otherP))
			if distAlongEdge < softRadius then
				local otherDistToEnd = edge.length - otherP.distanceTraveled
				if thisDistToEnd == otherDistToEnd then
					thisDistToEnd = thisDistToEnd + (0.5 - math.random()) / 10000
				end
				local hasPriority = thisDistToEnd < otherDistToEnd
				if edge.id == 28 then
					--	print(string.format("edge28: point %d, other %d, distAlongEdge: %.2f, dist2D: %.2f, distToEnd: %.2f, otherDistToEnd: %.2f, hasPriority: %s",

				end
				if hasPriority then
					local tempSpeed = interpolateSpeed(distAlongEdge, hardRadius, softRadius, minSpeed, maxSpeed)
					otherP.speed = math.min(otherP.speed or maxSpeed, tempSpeed)
					otherP.status = "yielding"
					thisP.status = "priority"
					table.insert(otherP.interactionLines, {thisP.x, thisP.y, otherP.x, otherP.y})

				else
					local tempSpeed = interpolateSpeed(distAlongEdge, hardRadius, softRadius, minSpeed, maxSpeed)
					newSpeed = math.min(newSpeed, tempSpeed)
					thisP.status = "yielding"
					otherP.status = "priority"
					table.insert(thisP.interactionLines, {otherP.x, otherP.y, thisP.x, thisP.y})

				end

			end
		end
	end
	if newSpeed < (thisP.speed or maxSpeed) then
		thisP.case = 1
		thisP.speed = newSpeed

	end
end

-- handles lane changes based on lane overload
local function updateLaneChanges(point, edge)
	if point.desiredLane and point.desiredLane ~= point.lane then
		if canChangeLane(point, edge, point.desiredLane) then
			point.laneChangeProgress = point.laneChangeProgress + laneChangeSpeed * love.timer.getDelta()
			if point.laneChangeProgress >= 1 then
				point.lane = point.desiredLane
				point.desiredLane = nil
				point.laneChangeProgress = 0
			end
		else
			point.status = "waiting"
		end
	else
		local currentLanePoints = getPointsOnEdgeLane(edge, point.lane)
		local currentDensity = #currentLanePoints
		if currentDensity > densityThreshold then
			local lanes = edge.lanes or 2
			local bestLane = point.lane
			local minDensity = currentDensity
			for lane = 1, lanes do
				if lane ~= point.lane then
					local pointsOnLane = getPointsOnEdgeLane(edge, lane)
					local density = #pointsOnLane
					local validLane = true
					local nextEdgeId = point.currentEdgeIndex + 1 <= #point.edges and point.edges[point.currentEdgeIndex + 1].id or nil
					if nextEdgeId and edge.laneDestinations and edge.laneDestinations[lane] then
						validLane = false
						for _, destId in ipairs(edge.laneDestinations[lane]) do
							if destId == nextEdgeId then
								validLane = true
								break
							end
						end
					end
					if validLane and density < minDensity then
						minDensity = density
						bestLane = lane
					end
				end
			end
			if bestLane ~= point.lane then
				point.desiredLane = bestLane
				point.laneChangeProgress = 0
			end
		end
	end
end

-- updates velocities and lanes
local function updateParticleVelocities(dt)
	for _, point in ipairs(points) do
		point.speed = maxSpeed
		point.status = "default"
		point.interactionLines = {}
	end
	for _, point in ipairs(points) do
		local edge = point.edges[point.currentEdgeIndex]
		if edge then
			local thisDistToEnd = edge.length - point.distanceTraveled
			behaviour1_sameEdge(point, edge, thisDistToEnd, {})
			if not point.isTransitioning then
				updateLaneChanges(point, edge)
			end
		end
	end
end

-- computes shortest path
local function computePath(startId, endId)
	local path, distance = points.findShortestPath(startId, endId)
	if #path < 2 then
		return nil, nil
	end
	return path, distance
end



local function processNextEdge(point, currentEdge)
	local nextEdges = currentEdge.endNode.nextEdges
	print(string.format("point %d at node %d, checking next edges: %d available", point.id, currentEdge.endNode.id, #nextEdges))
	if #nextEdges == 0 then
		-- End of path: stop the point
		point.speed = 0
		point.effectiveSpeed = 0
		point.currentEdgeIndex = nil -- Invalidate edge
		print(string.format("point %d reached end of path at node %d", point.id, currentEdge.endNode.id))
		return
	end
	local nextEdge = nextEdges[math.random(#nextEdges)]
	point.currentEdgeIndex = point.currentEdgeIndex + 1
	if point.currentEdgeIndex > #point.edges then
		table.insert(point.edges, nextEdge)
	else
		point.edges[point.currentEdgeIndex] = nextEdge
	end
	point.distanceTraveled = point.distanceTraveled - currentEdge.length
	point.lane = 1 -- Reset to lane 1 for simplicity
	point.desiredLane = nil
	point.laneChangeProgress = 0
	print(string.format("point %d transitioned to edge %d from node %d to node %d", point.id, nextEdge.id, nextEdge.startNode.id, nextEdge.endNode.id))
end

-- moves points along edges
local function moveParticles(dt)
	for i, point in ipairs(points) do
		local edge = point.currentEdgeIndex and point.edges[point.currentEdgeIndex]
		local t, deltaX, deltaY = 0, 0, 0
		if point.speed > 0 and edge then
			point.lastDistanceTraveled = point.distanceTraveled
			point.lastTransitionProgress = point.transitionProgress
			point.lastLaneX = point.laneX or point.x
			point.lastLaneY = point.laneY or point.y
			if point.isTransitioning then
				point.transitionProgress = point.transitionProgress + dt / point.transitionDuration
				if point.transitionProgress >= 1 then
					point.isTransitioning = false
					point.transitionProgress = 0
					point.distanceTraveled = point.transitionToT * edge.length
					point.laneX = point.transitionToX
					point.laneY = point.transitionToY
					point.x = point.laneX
					point.y = point.laneY
				end
				point.x = point.transitionFromX + (point.transitionToX - point.transitionFromX) * point.transitionProgress
				point.y = point.transitionFromY + (point.transitionToY - point.transitionFromY) * point.transitionProgress
				point.laneX = point.x
				point.laneY = point.y
				local deltaProgress = point.transitionProgress - point.lastTransitionProgress
				local transitionDistance = math.sqrt((point.transitionToX - point.transitionFromX)^2 + (point.transitionToY - point.transitionFromY)^2)
				point.effectiveSpeed = deltaProgress > 0 and (deltaProgress * transitionDistance) / dt or (point.speed or maxSpeed)
				point.effectiveSpeed = math.min(point.effectiveSpeed, maxSpeed)
				t = point.transitionToT * point.transitionProgress
				deltaX = point.laneX - point.lastLaneX
				deltaY = point.laneY - point.lastLaneY
			else
				point.distanceTraveled = point.distanceTraveled + (point.speed or maxSpeed) * dt
				local totalLength = edge.length
				if point.distanceTraveled >= totalLength then
					processNextEdge(point, edge)
					edge = point.currentEdgeIndex and point.edges[point.currentEdgeIndex]
					totalLength = edge and edge.length or totalLength
					point.distanceTraveled = edge and math.min(point.distanceTraveled, totalLength) or point.distanceTraveled
				end
				if edge then
					t = totalLength > 0 and math.clamp(point.distanceTraveled / totalLength, 0, 1) or 0
					local newLaneX, newLaneY = diagram.getLanePosition(edge, point.lane, point.desiredLane, point.laneChangeProgress, t)
					if newLaneX == nil or newLaneY == nil then

						newLaneX = point.x
						newLaneY = point.y
					end
					point.laneX = newLaneX
					point.laneY = newLaneY
					point.x = point.laneX
					point.y = point.laneY
					deltaX = (point.laneX or point.x) - (point.lastLaneX or point.x)
					deltaY = (point.laneY or point.y) - (point.lastLaneY or point.y)
					point.effectiveSpeed = dt > 0 and math.sqrt(deltaX * deltaX + deltaY * deltaY) / dt or (point.speed or maxSpeed)
					point.effectiveSpeed = math.min(point.effectiveSpeed, maxSpeed)
				else
					point.speed = 0
					point.effectiveSpeed = 0
					t = 0
					deltaX = 0
					deltaY = 0
				end
			end
			if edge and edge.id == 28 then
				local laneLinesStr = edge.laneLines and edge.laneLines[1] and table.concat(edge.laneLines[1], ", ") or "none"
				local laneLinesPoints = edge.laneLines and edge.laneLines[1] and (#edge.laneLines[1] / 2) or 0
				local duplicates = 0
				if edge.laneLines and edge.laneLines[1] then
					local ll = edge.laneLines[1]
					for i = 3, #ll - 3, 2 do
						if ll[i] == ll[i-2] and ll[i+1] == ll[i-1] then
							duplicates = duplicates + 1
						end
					end
					if duplicates > 0 then
						print(string.format("Warning: edge %d has %d duplicate points in laneLines", edge.id, duplicates))
					end
				end

			end
		else
			point.effectiveSpeed = 0
			if edge and edge.id == 28 then
				t = edge.length > 0 and math.clamp(point.distanceTraveled / edge.length, 0, 1) or 0
				deltaX = 0
				deltaY = 0
				print(string.format("edge28: point %d stopped, lane: %d, distanceTraveled: %.2f, t: %.4f, effectiveSpeed: %.2f, speed: %.2f",
						point.id, point.lane, point.distanceTraveled, t, point.effectiveSpeed or 0, point.speed or maxSpeed))
			end
		end
	end
end

-- removes invalid points
local function removeNotValidPoints()
	for i = #points, 1, -1 do
		local point = points[i]
		if point.currentEdgeIndex == nil or point.currentEdgeIndex > #point.edges or point.remove then
			if point.currentEdgeIndex and point.edges[point.currentEdgeIndex] then
				removePointFromEdge(point, point.edges[point.currentEdgeIndex])
			end
			print(string.format("removing point %d: currentEdgeIndex=%s, edges=%d, remove=%s",
					point.id, tostring(point.currentEdgeIndex), #point.edges, tostring(point.remove)))
			table.remove(points, i)
		end
	end
end

-- initializes routes and edge lanes
function points.initialize(paths)
--	points.list = points
	for _, edge in pairs(diagram.edges) do
		edge.lanes = edge.lanes or 2
		edge.laneDestinations = edge.laneDestinations or {}
	end
	for _, route in ipairs(paths) do
		local path, distance = points.findShortestPath(route.startId, route.endId)
		if path then
			route.path = path
			route.distance = distance
			route.edges = buildEdgesFromPath(path)
		else
			route.path = {route.startId}
			route.edges = {}
		end
	end
end

-- updates average speed on edges
local function updateAvgSpeedOnEdges()
	for _, edge in pairs(diagram.edges) do
		local avgSpeed = maxSpeed
		if edge.points and #edge.points > 0 then
			local totalSpeed = 0
			for _, point in ipairs(edge.points) do
				totalSpeed = totalSpeed + point.speed
			end
			avgSpeed = totalSpeed / #edge.points
		end
		edge.avgSpeed = edge.avgSpeed and (0.01 * avgSpeed + 0.99 * edge.avgSpeed) or avgSpeed
	end
end

-- updates simulation
function points.update(dt, paths)
	spawnParticles(dt, paths)
	updateParticleVelocities(dt)
	moveParticles(dt)
	removeNotValidPoints()
	updateAvgSpeedOnEdges()
end

-- gets point color
local function getColorFromStatus(status)
	if status == "yielding" then return {1, 0, 0}
	elseif status == "priority" then return {0, 1, 0}
	elseif status == "waiting" then return {1, 1, 0}
	else return {1, 1, 1} end
end

-- draws points, interaction lines, and speed indicators
function points.draw()
	-- set font for speed text
	local font = love.graphics.newFont(12)
	love.graphics.setFont(font)
	for _, point in ipairs(points) do
		-- draw point
		love.graphics.setColor(getColorFromStatus(point.status))
		love.graphics.circle("fill", point.x, point.y, 6)
		love.graphics.setColor(0, 0, 0)
		love.graphics.circle("line", point.x, point.y, 7)
		-- draw effective speed text
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(math.floor(point.effectiveSpeed), point.x + 10, point.y - 5)
		-- highlight edge 28
		if point.edges[point.currentEdgeIndex].id == 28 then
			love.graphics.setColor(1, 0, 1)
			love.graphics.circle("line", point.x, point.y, 20)
		end
	end
	-- draw interaction lines
	love.graphics.setColor(0, 0, 0)
	love.graphics.setLineWidth(1)
	for _, point in ipairs(points) do
		for _, line in ipairs(point.interactionLines) do
			love.graphics.line(line)
		end
	end
end

--points.initialize = initialize
--points.update = update
--points.draw = draw

return points