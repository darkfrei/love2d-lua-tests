-- points.lua
-- manages moving points along edges with multiple lanes, handling spawning, velocity updates, routefinding, and drawing
-- used by main.lua in the game loop

local diagram = require("diagram")
local utils = require("utils")

local points = {}

-- configuration constants
local spawnInterval = 1.6
local spawnTimer = 0
local maxSpeed = 60
local hardRadius = 20
local softRadius = 60
local minSpeed = 1
local pointIdCounter = 0
local laneWidth = 10
local distanceThreshold = 0.1

---- finds fastest route using dijkstra's algorithm
--function points.findShortestPath(startId, endId, )
--    local distances = {}
--    local previous = {}
--    local unvisited = {}
--    for _, node in pairs(diagram.nodes) do
--        distances[node.id] = math.huge
--        unvisited[node.id] = true
--    end
--    distances[startId] = 0
--    while next(unvisited) do
--        local currentId = nil
--        local minDist = math.huge
--        for id in pairs(unvisited) do
--            if distances[id] < minDist then
--                minDist = distances[id]
--                currentId = id
--            end
--        end
--        if currentId == nil then break end
--        if currentId == endId then break end
--        unvisited[currentId] = nil
--        local currentNode = diagram.nodes[currentId]
--        if currentNode.nextEdges then
--            for _, edge in ipairs(currentNode.nextEdges) do
--                if edge.nodeIndices and #edge.nodeIndices >= 2 then
--                    local neighborId = edge.nodeIndices[#edge.nodeIndices]
--                    if unvisited[neighborId] then
--                        local travelTime = utils.calculateEdgeTravelTime(edge, maxSpeed)
--                        local alt = distances[currentId] + travelTime
--                        if alt < distances[neighborId] then
--                            distances[neighborId] = alt
--                            previous[neighborId] = currentId
--                        end
--                    end
--                end
--            end
--        end
--    end
--    local route = {}
--    local current = endId
--    while current do
--        table.insert(route, 1, current)
--        current = previous[current]
--    end
--    if #route < 2 then
--        return {}, math.huge
--    end
--    return route, distances[endId]
--end

-- chooses initial lane based on turn direction
local function chooseInitialLane(point, edge, nextEdge)
	if not nextEdge then
		return 1
	end
	local turnDirection = diagram.getTurnDirection(edge, nextEdge)
	if turnDirection == "left" then
		return 1
	elseif turnDirection == "right" then
		return math.min(edge.lanes, 2)
	else
		return 1
	end
end

-- creates a new point
local function createPoint(edges, startNode, targetNodeId)
	pointIdCounter = pointIdCounter + 1
	local point = {
		id = pointIdCounter,
		edges = edges,
		currentEdgeIndex = 1,
		distanceTraveled = 0,
		x = startNode.x,
		y = startNode.y,
		speed = maxSpeed,
		effectiveSpeed = maxSpeed,
		lastDistanceTraveled = 0,
		lastLaneX = startNode.x,
		lastLaneY = startNode.y,
		status = "default",
		interactionLines = {},
		targetNodeId = targetNodeId,
		case = 0,
		lane = 1,
		laneX = startNode.x,
		laneY = startNode.y
	}
	if edges[1] then
		local laneLine = edges[1].laneLines and edges[1].laneLines[1]
		if laneLine and #laneLine >= 2 then
			point.laneX = laneLine[1]
			point.laneY = laneLine[2]
			point.lastLaneX = point.laneX
			point.lastLaneY = point.laneY
		end
		local nextEdge = point.currentEdgeIndex + 1 <= #point.edges and point.edges[point.currentEdgeIndex + 1] or nil
		point.lane = chooseInitialLane(point, edges[1], nextEdge)
	end
	return point
end

-- spawns a point for a specific route
local function spawnPointForRoute(startNodeId, targetNodeId)
	local route = utils.findShortestPath(startNodeId, targetNodeId, diagram)
	if not route or #route < 2 then
		return
	end
	local edges = diagram.buildEdgesWithTransitions(route)
	if not edges then
		return
	end
	local startNode = diagram.nodes[startNodeId]
	local point = createPoint(edges, startNode, targetNodeId)
	table.insert(points, point)
	utils.addPointToEdge(point, edges[1])
end

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
	local route = utils.findShortestPath(startNodeId, targetNodeId, diagram)
	if not route or #route < 2 then return false end
	local firstEdge = utils.findEdgeBetween(route[1], route[2], diagram.edges)
	if not firstEdge then return false end
	local pointsOnEdge = utils.getPointsOnEdgeLane(firstEdge, 1)
	for _, point in ipairs(pointsOnEdge) do
		if point.distanceTraveled < hardRadius then
			return false
		end
	end
	return true
end

-- spawns particles
local function spawnParticles(dt, routes)
	if updateSpawnTimer(dt) then
		for _, route in ipairs(routes) do
			if canSpawnPointForRoute(route.startId, route.targetId) then
				spawnPointForRoute(route.startId, route.targetId)
			end
		end
	end
end

-- collision behavior: same edge
local function behaviour1_sameEdge(thisP, edge, thisDistToEnd)
	local newSpeed = thisP.speed or maxSpeed
	local sameLanePoints = utils.getPointsOnEdgeLane(edge, thisP.lane)
	for _, otherP in ipairs(sameLanePoints) do
		if thisP ~= otherP then
			local distAlongEdge = math.abs(thisP.distanceTraveled - otherP.distanceTraveled)
			local dist2D = math.sqrt(utils.getDistanceSquared(thisP, otherP))
			if distAlongEdge < softRadius then
				local otherDistToEnd = edge.length - otherP.distanceTraveled
				if thisDistToEnd == otherDistToEnd then
					thisDistToEnd = thisDistToEnd + (0.5 - math.random()) / 10000
				end
				local hasPriority = thisDistToEnd < otherDistToEnd
				if hasPriority then
					local tempSpeed = utils.interpolateSpeed(distAlongEdge, hardRadius, softRadius, minSpeed, maxSpeed)
					otherP.speed = math.min(otherP.speed or maxSpeed, tempSpeed)
					otherP.status = "yielding"
					thisP.status = "priority"
					table.insert(otherP.interactionLines, {thisP.x, thisP.y, otherP.x, otherP.y})
				else
					local tempSpeed = utils.interpolateSpeed(distAlongEdge, hardRadius, softRadius, minSpeed, maxSpeed)
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

-- collision behavior: different edges
local function behaviour2_differentEdges(thisP, edge, thisDistToEnd)
	local newSpeed = thisP.speed or maxSpeed
	local endNodeId = edge.nodeIndices[#edge.nodeIndices]
	for _, otherEdge in pairs(diagram.edges) do
		if otherEdge ~= edge then
			local otherEndNodeId = otherEdge.nodeIndices[#otherEdge.nodeIndices]
			local otherStartNodeId = otherEdge.nodeIndices[1]
			if otherEndNodeId == endNodeId or otherStartNodeId == endNodeId then
				local otherPoints = utils.getPointsOnEdgeLane(otherEdge, thisP.lane)
				for _, otherP in ipairs(otherPoints) do
					if thisP ~= otherP then
						local dist2D = math.sqrt(utils.getDistanceSquared(thisP, otherP))
						if dist2D < softRadius then
							local otherDistToEnd = otherEdge.length - otherP.distanceTraveled
							local hasPriority = thisDistToEnd < otherDistToEnd
							if otherStartNodeId == endNodeId then
								hasPriority = thisDistToEnd > otherDistToEnd
							end
							if thisDistToEnd == otherDistToEnd then
								thisDistToEnd = thisDistToEnd + (0.5 - math.random()) / 10000
								hasPriority = thisDistToEnd < otherDistToEnd
							end
							if hasPriority then
								local tempSpeed = utils.interpolateSpeed(dist2D, hardRadius, softRadius, minSpeed, maxSpeed)
								otherP.speed = math.min(otherP.speed or maxSpeed, tempSpeed)
								otherP.status = "yielding"
								thisP.status = "priority"
								table.insert(otherP.interactionLines, {thisP.x, thisP.y, otherP.x, otherP.y})
							else
								local tempSpeed = utils.interpolateSpeed(dist2D, hardRadius, softRadius, minSpeed, maxSpeed)
								newSpeed = math.min(newSpeed, tempSpeed)
								thisP.status = "yielding"
								otherP.status = "priority"
								table.insert(thisP.interactionLines, {otherP.x, otherP.y, thisP.x, thisP.y})
							end
						end
					end
				end
			end
		end
	end
	if newSpeed < (thisP.speed or maxSpeed) then
		thisP.case = 2
		thisP.speed = newSpeed
	end
end

-- collision behavior: converging edges
local function behaviour3_convergingEdges(thisP, edge, thisDistToEnd)
	local newSpeed = thisP.speed or maxSpeed
	local endNodeId = edge.nodeIndices[#edge.nodeIndices]
	for _, otherEdge in pairs(diagram.edges) do
		if otherEdge ~= edge then
			local otherEndNodeId = otherEdge.nodeIndices[#otherEdge.nodeIndices]
			if otherEndNodeId == endNodeId then
				local otherPoints = utils.getPointsOnEdgeLane(otherEdge, thisP.lane)
				for _, otherP in ipairs(otherPoints) do
					if thisP ~= otherP then
						local dist2D = math.sqrt(utils.getDistanceSquared(thisP, otherP))
						if dist2D < softRadius then
							local otherDistToEnd = otherEdge.length - otherP.distanceTraveled
							local thisTimeToNode = thisDistToEnd / math.max(thisP.speed, minSpeed)
							local otherTimeToNode = otherDistToEnd / math.max(otherP.speed, minSpeed)
							local thisStopped = thisP.speed <= minSpeed
							local otherStopped = otherP.speed <= minSpeed
							local hasPriority
							if thisStopped and not otherStopped then
								hasPriority = false
							elseif otherStopped and not thisStopped then
								hasPriority = true
							else
								hasPriority = thisTimeToNode < otherTimeToNode
								if thisTimeToNode == otherTimeToNode then
									hasPriority = thisDistToEnd < otherDistToEnd
								end
							end
							if hasPriority then
								local tempSpeed = utils.interpolateSpeed(dist2D, hardRadius, softRadius, minSpeed, maxSpeed)
								otherP.speed = math.min(otherP.speed or maxSpeed, tempSpeed)
								otherP.status = "yielding"
								thisP.status = "priority"
								table.insert(otherP.interactionLines, {thisP.x, thisP.y, otherP.x, otherP.y})
							else
								local tempSpeed = utils.interpolateSpeed(dist2D, hardRadius, softRadius, minSpeed, maxSpeed)
								newSpeed = math.min(newSpeed, tempSpeed)
								thisP.status = "yielding"
								otherP.status = "priority"
								table.insert(thisP.interactionLines, {otherP.x, otherP.y, thisP.x, thisP.y})
							end
						end
					end
				end
			end
		end
	end
	if newSpeed < (thisP.speed or maxSpeed) then
		thisP.case = 3
		thisP.speed = newSpeed
	end
end

-- updates velocities
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
			behaviour1_sameEdge(point, edge, thisDistToEnd)
			behaviour2_differentEdges(point, edge, thisDistToEnd)
			behaviour3_convergingEdges(point, edge, thisDistToEnd)
		end
	end
end

-- initializes point state for movement
local function initializePointState(point)
	local edge = point.currentEdgeIndex and point.edges[point.currentEdgeIndex]
	local state = {
		prevDistanceTraveled = point.distanceTraveled,
		prevEdgeId = edge and edge.id or -1,
		prevLane = point.lane,
		t = 0,
		deltaX = 0,
		deltaY = 0,
		totalLength = edge and edge.length or 0
	}
	point.lastDistanceTraveled = point.distanceTraveled
	point.lastLaneX = point.laneX or point.x
	point.lastLaneY = point.laneY or point.y
	return state, edge
end

-- handles movement during transition
local function handleTransitionMovement(point, dt)
	local distanceDelta = point.speed * dt
	point.distanceTraveled = point.distanceTraveled + distanceDelta
	local curveLength = point.transitionCurve.length
	if point.distanceTraveled >= curveLength then
		utils.removePointFromEdge(point, point.edges[point.currentEdgeIndex])
		point.isTransitioning = false
		point.currentEdgeIndex = point.currentEdgeIndex + 1
		point.lane = point.nextLane
		point.laneX = point.transitionToX
		point.laneY = point.transitionToY
		point.distanceTraveled = point.transitionToT * point.nextEdge.length
		point.transitionCurve = nil
		point.nextEdge = nil
		point.nextLane = nil
		point.transitionToX = nil
		point.transitionToY = nil
		point.transitionToT = nil
		if point.currentEdgeIndex <= #point.edges then
			utils.addPointToEdge(point, point.edges[point.currentEdgeIndex])
		else
			point.remove = true
		end
		return
	end
	local t = curveLength > 0 and utils.clamp(point.distanceTraveled / curveLength, 0, 1) or 0
	local x, y = diagram.getTransitionPosition(point.transitionCurve.points, t)
	point.laneX = x
	point.laneY = y
end

-- handles movement along edges
local function handleEdgeMovement(point, edge, state, dt)
	if not edge then
		point.speed = 0
		point.effectiveSpeed = 0
		return
	end
	local distanceDelta = point.speed * dt
	point.distanceTraveled = point.distanceTraveled + distanceDelta
	if point.distanceTraveled >= state.totalLength then
		utils.removePointFromEdge(point, edge)
		local overshoot = point.distanceTraveled - state.totalLength
		point.distanceTraveled = overshoot
		local nextEdge = point.currentEdgeIndex + 1 <= #point.edges and point.edges[point.currentEdgeIndex + 1] or nil
		diagram.transitionThroughNode(point, edge, nextEdge, diagram.nodes[edge.nodeIndices[#edge.nodeIndices]])
		if not point.isTransitioning then
			point.currentEdgeIndex = point.currentEdgeIndex + 1
			if point.currentEdgeIndex <= #point.edges then
				nextEdge = point.edges[point.currentEdgeIndex]
				local nextNextEdge = point.currentEdgeIndex + 1 <= #point.edges and point.edges[point.currentEdgeIndex + 1] or nil
				point.lane = chooseInitialLane(point, nextEdge, nextNextEdge)
				utils.addPointToEdge(point, nextEdge)
			else
				point.remove = true
			end
		end
	end
	edge = point.edges[point.currentEdgeIndex]
	state.totalLength = edge and edge.length or state.totalLength
	if edge and not point.isTransitioning then
		state.t = state.totalLength > 0 and utils.clamp(point.distanceTraveled / state.totalLength, 0, 1) or 0
		local newLaneX, newLaneY = diagram.getLanePosition(edge, point.lane, state.t)
		point.laneX = newLaneX or point.laneX
		point.laneY = newLaneY or point.laneY
	end
end

-- updates position and effective speed
local function updatePositionAndSpeed(point, state, dt)
	point.x = point.laneX or point.x
	point.y = point.laneY or point.y
	state.deltaX = (point.laneX or point.x) - (point.lastLaneX or point.x)
	state.deltaY = (point.laneY or point.y) - (point.lastLaneY or point.y)
	point.effectiveSpeed = dt > 0 and math.sqrt(state.deltaX * state.deltaX + state.deltaY * state.deltaY) / dt or (point.speed or maxSpeed)
	point.effectiveSpeed = math.min(point.effectiveSpeed, maxSpeed)
end

-- moves particles along edges
local function moveParticles(dt)
	for _, point in ipairs(points) do
		if point.speed > 0 then
			local state, edge = initializePointState(point)
			if point.isTransitioning then
				handleTransitionMovement(point, dt)
			else
				handleEdgeMovement(point, edge, state, dt)
			end
			updatePositionAndSpeed(point, state, dt)
		else
			local state, edge = initializePointState(point)
			updatePositionAndSpeed(point, state, dt)
		end
	end
end

-- removes invalid points
local function removeNotValidPoints()
	for i = #points, 1, -1 do
		local point = points[i]
		if point.currentEdgeIndex == nil or point.currentEdgeIndex > #point.edges or point.remove then
			if point.currentEdgeIndex and point.edges[point.currentEdgeIndex] then
				utils.removePointFromEdge(point, point.edges[point.currentEdgeIndex])
			end
			table.remove(points, i)
		end
	end
end

-- initializes routes and edge lanes
function points.initialize(routes)
	for _, edge in pairs(diagram.edges) do
		edge.lanes = edge.lanes or 2
		edge.laneDestinations = edge.laneDestinations or {}
	end
	for _, route in ipairs(routes) do
		local path, distance = utils.computePath(route.startId, route.endId, points.findShortestPath, diagram)
		if path then
			route.path = path
			route.distance = distance
			route.edges = diagram.buildEdgesWithTransitions(path)
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
function points.update(dt, routes)
	spawnParticles(dt, routes)
	updateParticleVelocities(dt)
	moveParticles(dt)
	removeNotValidPoints()
	updateAvgSpeedOnEdges()
end

-- draws points, interaction lines, and speed indicators
function points.draw()
	local font = love.graphics.newFont(12)
	love.graphics.setFont(font)
	for _, point in ipairs(points) do
		love.graphics.setColor(utils.getColorFromStatus(point.status))
		love.graphics.circle("fill", point.x, point.y, 6)
		love.graphics.setColor(0, 0, 0)
		love.graphics.circle("line", point.x, point.y, 7)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(math.floor(point.effectiveSpeed), point.x + 10, point.y - 5)
	end
	love.graphics.setColor(0, 0, 0)
	love.graphics.setLineWidth(0.5)
	for _, point in ipairs(points) do
		for _, line in ipairs(point.interactionLines) do
			love.graphics.line(line)
		end
	end
	for _, point in ipairs(points) do
		love.graphics.print(point.id, point.x - 5, point.y + 6)
	end
end

return points