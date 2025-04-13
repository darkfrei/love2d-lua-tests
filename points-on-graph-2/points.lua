-- points.lua
-- manages moving points along edges, handling spawning, velocity updates, path recalculation, and drawing.
-- used by main.lua in the game loop.

local diagram = require("diagram")
local data = require("data")

local points = {}

-- configuration constants
local spawnInterval = 0.8  -- seconds between spawning new points
local spawnTimer = 0       -- tracks time since last spawn
local maxSpeed = 60        -- maximum point speed (pixels per second)
local hardRadius = 15      -- distance for stopping/yielding in collision cases
local softRadius = 30      -- distance for starting to yield in collision cases
local minSpeed = 5         -- minimum speed to prevent full stops in cases 1 and 3
local pointIdCounter = 0   -- counter for unique point IDs
local congestionFactor = 10  -- penalty multiplier for edge density

-- calculates Euclidean distance between two points
-- used in updateParticleVelocities for collision detection
local function getDistance(p1, p2)
	local dx = p2.x - p1.x
	local dy = p2.y - p1.y
	return math.sqrt(dx * dx + dy * dy)
end

-- finds shortest path using Dijkstra with density-based penalties
-- called by points.lua in spawnParticles and processNextEdge
function points.findShortestPath(startId, endId)
	local distances = {}
	local previous = {}
	local unvisited = {}
	local densityThreshold = 0.5 / softRadius
	local maxDensity = 0.5 / hardRadius
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
		if currentId == nil then
			print("no path found to " .. endId)
			break
		end
		if currentId == endId then break end
		unvisited[currentId] = nil
		local currentNode = diagram.nodes[currentId]
		if currentNode.nextEdges then
			for _, edge in ipairs(currentNode.nextEdges) do
				local neighborId = edge.endNode.id
				if unvisited[neighborId] then
					local numPoints = edge.points and #edge.points or 0
					local density = numPoints / edge.length
					local congestionPenalty = 0
					if numPoints > 2 and density >= densityThreshold then
						local densityRatio = (density - densityThreshold) / (maxDensity - densityThreshold)
						congestionPenalty = 1 + 99 * densityRatio * densityRatio * congestionFactor
					end
					local alt = distances[currentId] + edge.length + congestionPenalty
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
		print("no valid path from " .. startId .. " to " .. endId)
	end
	return path, distances[endId]
end

-- finds an edge connecting two nodes by their IDs
-- used in buildEdgesFromPath for path-to-edge conversion
local function findEdgeBetween(fromId, toId)
	for _, edge in pairs(data.edges) do
		if edge.nodeIndices[1] == fromId and edge.nodeIndices[#edge.nodeIndices] == toId then
			return edge
		end
	end
	return nil
end

-- gets all points currently on a specific edge
-- used in updateParticleVelocities for same-edge collision checks
local function getPointsOnEdge(edge)
	return edge.points or {}
end

-- gets points on next edges within softRadius from a point
-- used in updateParticleVelocities for case 2 collision logic
local function getNextEdgesWithinRadius(point, edge)
	local result = {}
	local endNode = data.nodes[edge.nodeIndices[#edge.nodeIndices]]
	if endNode.nextEdges then
		for _, nextEdge in ipairs(endNode.nextEdges) do
			local pointsOnEdge = getPointsOnEdge(nextEdge)
			for _, p in ipairs(pointsOnEdge) do
				if p ~= point and getDistance(point, p) <= softRadius then
					table.insert(result, p)
				end
			end
		end
	end
	return result
end

-- gets points on previous edges within softRadius from a point
-- used in updateParticleVelocities for case 3 collision logic
local function getPrevEdgesWithinRadius(point, edge)
	local result = {}
	local startNode = data.nodes[edge.nodeIndices[1]]
	if startNode.prevEdges then
		for _, prevEdge in ipairs(startNode.prevEdges) do
			local pointsOnEdge = getPointsOnEdge(prevEdge)
			for _, p in ipairs(pointsOnEdge) do
				if p ~= point and getDistance(point, p) <= softRadius then
					table.insert(result, p)
				end
			end
		end
	end
	return result
end

-- adds a point to an edge’s points list
-- used in spawnParticles, processNextEdge, and createPoint
local function addPointToEdge(point, edge)
	if not edge.points then
		edge.points = {}
	end
	table.insert(edge.points, point)
end

-- removes a point from an edge’s points list
-- used in processNextEdge and removeNotValidPoints
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
-- used in spawnParticles, processNextEdge, and points.initialize
local function buildEdgesFromPath(path)
	local edges = {}
	for j = 1, #path - 1 do
		local edge = findEdgeBetween(path[j], path[j + 1])
		if edge then
			table.insert(edges, edge)
		else
			print("no edge from " .. path[j] .. " to " .. path[j + 1])
			return {}
		end
	end
	if #edges == 0 then
		print("no valid edges for path")
	end
	return edges
end

-- creates a new point with initial properties
-- used in spawnParticles to initialize points
local function createPoint(edges, startNode, endNodeId)
	pointIdCounter = pointIdCounter + 1
	local point = {
		id = pointIdCounter,
		edges = edges,
		currentEdgeIndex = 1,
		nextEdgeIndex = 2,
		distanceTraveled = 0+math.random ()/10000,
		x = startNode.x,
		y = startNode.y,
		maxSpeed = maxSpeed,
		speed = maxSpeed,
		hardRadius = hardRadius,
		softRadius = softRadius,
		color = {1, 1, 1},  -- white by default
		interactionLines = {},  -- lines for collision visualization
		endNodeId = endNodeId
	}
	return point
end

-- spawns new points periodically for each route
-- called by points.update to add points to the simulation
local function spawnParticles(dt, paths)
	spawnTimer = spawnTimer + dt
	if spawnTimer >= spawnInterval then
		spawnTimer = spawnTimer - spawnInterval
		for _, route in ipairs(paths) do
			local path, _ = points.findShortestPath(route.startId, route.endId)
			if path then
				local edges = buildEdgesFromPath(path)
				if #edges > 0 then
					local startNode = data.nodes[path[1]]
					local point = createPoint(edges, startNode, route.endId)
					table.insert(points, point)
					addPointToEdge(point, edges[1])
				end
			end
		end
	end
end

-- updates point velocities based on collision logic
-- called by points.update to handle interactions
local function updateParticleVelocities(dt)
	-- reset point states
	for _, p in ipairs(points) do
		p.speed = p.maxSpeed
		p.color = {1, 1, 1}
		p.interactionLines = {}
	end

	-- process interactions for each point
	for _, thisP in ipairs(points) do
		local edge = thisP.edges[thisP.currentEdgeIndex]
		if edge then
			local thisDistToEnd = edge.length - thisP.distanceTraveled
			local newSpeed = thisP.maxSpeed
			local logMessages = {}

			if thisP.id == 3 or thisP.id == 4 or thisP.id == 8 or thisP.id == 9 or thisP.id == 13 or thisP.id == 14 then
				table.insert(logMessages, string.format("point %d at edge %d, distToEnd %.2f, speed %.2f", thisP.id, thisP.currentEdgeIndex, thisDistToEnd, thisP.speed))
			end

			-- case 1: points on the same edge
			local sameEdgePoints = getPointsOnEdge(edge)
			for _, otherP in ipairs(sameEdgePoints) do
				if thisP ~= otherP then
					local dist = getDistance(thisP, otherP)
					local otherDistToEnd = edge.length - otherP.distanceTraveled
					if dist < thisP.softRadius then
						local hasPriority = thisDistToEnd < otherDistToEnd
						if not hasPriority then
							local tempSpeed
							if dist < thisP.hardRadius then
								tempSpeed = minSpeed
							else
								local f = (dist - thisP.hardRadius) / (thisP.softRadius - thisP.hardRadius)
								tempSpeed = minSpeed + (thisP.maxSpeed - minSpeed) * math.max(0, f)
							end
							newSpeed = math.min(newSpeed, tempSpeed)
							thisP.color = {1, 0, 0}
							otherP.color = {0, 1, 0}
							table.insert(thisP.interactionLines, {otherP.x, otherP.y, thisP.x, thisP.y, 1.0, 0.5, 0.0})
							if thisP.id == 3 or thisP.id == 4 or thisP.id == 8 or thisP.id == 9 or thisP.id == 13 or thisP.id == 14 then
								table.insert(logMessages, string.format("sees point %d on same edge, dist %.2f, I'm farther (%.2f > %.2f), yielding, new speed %.2f", 
										otherP.id, dist, thisDistToEnd, otherDistToEnd, tempSpeed))
							end
						else
							local tempSpeed
							if dist < otherP.hardRadius then
								tempSpeed = minSpeed
							else
								local f = (dist - otherP.hardRadius) / (otherP.softRadius - otherP.hardRadius)
								tempSpeed = minSpeed + (otherP.maxSpeed - minSpeed) * math.max(0, f)
							end
							otherP.speed = math.min(otherP.speed, tempSpeed)
							otherP.color = {1, 0, 0}
							thisP.color = {0, 1, 0}
							table.insert(otherP.interactionLines, {thisP.x, thisP.y, otherP.x, otherP.y, 1.0, 0.5, 0.0})
							if thisP.id == 3 or thisP.id == 4 or thisP.id == 8 or thisP.id == 9 or thisP.id == 13 or thisP.id == 14 then
								table.insert(logMessages, string.format("sees point %d on same edge, dist %.2f, I'm closer (%.2f < %.2f), proceeding, speed %.2f", 
										otherP.id, dist, thisDistToEnd, otherDistToEnd, newSpeed))
							end
						end
					end
				end
			end

			-- case 2: points on next edges
			local nextEdgePoints = getNextEdgesWithinRadius(thisP, edge)
			for _, otherP in ipairs(nextEdgePoints) do
				local dist = getDistance(thisP, otherP)
				if dist < thisP.softRadius then
					local tempSpeed
					if dist < thisP.hardRadius then
						tempSpeed = 0
					else
						local f = (dist - thisP.hardRadius) / (thisP.softRadius - thisP.hardRadius)
						tempSpeed = thisP.maxSpeed * math.max(0, f)
					end
					newSpeed = math.min(newSpeed, tempSpeed)
					thisP.color = {1, 0, 0}
					otherP.color = {0, 1, 0}
					table.insert(thisP.interactionLines, {otherP.x, otherP.y, thisP.x, thisP.y, 1.0, 0.5, 0.0})
					if thisP.id == 3 or thisP.id == 4 or thisP.id == 8 or thisP.id == 9 or thisP.id == 13 or thisP.id == 14 then
						table.insert(logMessages, string.format("sees point %d on next edge, dist %.2f, yielding, new speed %.2f", 
								otherP.id, dist, tempSpeed))
					end
				end
			end

			-- case 3: points on previous edges of next edge
			if thisP.nextEdgeIndex <= #thisP.edges then
				local nextEdge = thisP.edges[thisP.nextEdgeIndex]
				local prevEdgePoints = getPrevEdgesWithinRadius(thisP, nextEdge)
				for _, otherP in ipairs(prevEdgePoints) do
					local otherEdge = otherP.edges[otherP.currentEdgeIndex]
					local otherDistToEnd = otherEdge.length - otherP.distanceTraveled
					if otherEdge ~= edge then
						if thisDistToEnd < thisP.softRadius and otherDistToEnd < otherP.softRadius then
							local hasPriority = thisDistToEnd < otherDistToEnd
							if not hasPriority then
								local dist = getDistance(thisP, otherP)
								local tempSpeed
								if dist < thisP.hardRadius then
									tempSpeed = minSpeed
								else
									local f = (dist - thisP.hardRadius) / (thisP.softRadius - thisP.hardRadius)
									tempSpeed = minSpeed + (thisP.maxSpeed - minSpeed) * math.max(0, f)
								end
								newSpeed = math.min(newSpeed, tempSpeed)
								thisP.color = {1, 0, 0}
								otherP.color = {0, 1, 0}
								table.insert(thisP.interactionLines, {otherP.x, otherP.y, thisP.x, thisP.y, 1.0, 0.5, 0.0})
								if thisP.id == 3 or thisP.id == 4 or thisP.id == 8 or thisP.id == 9 or thisP.id == 13 or thisP.id == 14 then
									table.insert(logMessages, string.format("sees point %d on prev edge of next, dist %.2f, I'm farther (%.2f > %.2f), yielding, new speed %.2f", 
											otherP.id, dist, thisDistToEnd, otherDistToEnd, tempSpeed))
								end
							else
								local dist = getDistance(thisP, otherP)
								local tempSpeed
								if dist < otherP.hardRadius then
									tempSpeed = minSpeed
								else
									local f = (dist - otherP.hardRadius) / (otherP.softRadius - otherP.hardRadius)
									tempSpeed = minSpeed + (otherP.maxSpeed - minSpeed) * math.max(0, f)
								end
								otherP.speed = math.min(otherP.speed, tempSpeed)
								otherP.color = {1, 0, 0}
								thisP.color = {0, 1, 0}
								table.insert(otherP.interactionLines, {thisP.x, thisP.y, otherP.x, otherP.y, 1.0, 0.5, 0.0})
								if thisP.id == 3 or thisP.id == 4 or thisP.id == 8 or thisP.id == 9 or thisP.id == 13 or thisP.id == 14 then
									table.insert(logMessages, string.format("sees point %d on prev edge of next, dist %.2f, I'm closer (%.2f < %.2f), proceeding, speed %.2f", 
											otherP.id, dist, thisDistToEnd, otherDistToEnd, newSpeed))
								end
							end
						end
					end
				end
			end

			thisP.speed = newSpeed

			if thisP.id == 3 or thisP.id == 4 or thisP.id == 8 or thisP.id == 9 or thisP.id == 13 or thisP.id == 14 then
				if #logMessages == 1 then
					table.insert(logMessages, string.format("point %d: no interactions, moving freely", thisP.id))
				end
				for _, msg in ipairs(logMessages) do
					-- print(msg)
				end
			end
		end
	end
end

-- computes shortest path between two nodes
-- used in spawnParticles and processNextEdge for pathfinding
local function computePath(startId, endId)
	local path, distance = points.findShortestPath(startId, endId)
	if #path < 2 then
		print("no valid path for route " .. startId .. "->" .. endId)
		return nil, nil
	end
	return path, distance
end

-- handles point transition to next edge with path recalculation
-- called by moveParticles when a point reaches an edge’s end
local function processNextEdge(point, edge)
	point.distanceTraveled = 0
	removePointFromEdge(point, edge)
	point.currentEdgeIndex = point.currentEdgeIndex + 1
	point.nextEdgeIndex = point.currentEdgeIndex + 1

	if point.currentEdgeIndex <= #point.edges then
		-- store next edge ID for comparison
		local oldEdgeId = point.edges[point.currentEdgeIndex].id or
		(point.edges[point.currentEdgeIndex].nodeIndices[1] .. "->" ..
			point.edges[point.currentEdgeIndex].nodeIndices[#point.edges[point.currentEdgeIndex].nodeIndices])

		-- recompute path to avoid congested edges
		local currentNodeId = edge.nodeIndices[#edge.nodeIndices]
		local path, _ = computePath(currentNodeId, point.endNodeId)
		if not path then
			print("point " .. point.id .. ": no path from " .. currentNodeId .. " to " .. point.endNodeId .. ", removing")
			point.remove = true
		else
			local newEdges = buildEdgesFromPath(path)
			if #newEdges > 0 then
				-- compare with new edge ID
				local newEdgeId = newEdges[1].id or
				(newEdges[1].nodeIndices[1] .. "->" ..
					newEdges[1].nodeIndices[#newEdges[1].nodeIndices])
				if oldEdgeId ~= newEdgeId then
--					print("point " .. point.id .. ": next edge changed from " .. oldEdgeId .. " to " .. newEdgeId)
				end

				-- update point with new path
				point.edges = newEdges
				point.currentEdgeIndex = 1
				point.nextEdgeIndex = 2
				local nextEdge = point.edges[1]
				point.x = nextEdge.line[1]
				point.y = nextEdge.line[2]
				point.speed = point.maxSpeed
				addPointToEdge(point, nextEdge)
			else
				print("point " .. point.id .. ": no valid edges from " .. currentNodeId .. " to " .. point.endNodeId .. ", removing")
				point.remove = true
			end
		end
	else
		point.remove = true
		-- print("point " .. point.id .. " reached destination")
	end
end

-- moves points along edges based on their speed
-- called by points.update to update point positions
local function moveParticles(dt)
	for i, p in ipairs(points) do
		if p.speed > 0 then
			p.distanceTraveled = p.distanceTraveled + p.speed * dt
			local edge = p.edges[p.currentEdgeIndex]
			local totalLength = edge.length
			local line = edge.line
			local totalSegments = (#line / 2) - 1

			if p.distanceTraveled >= totalLength then
				processNextEdge(p, edge)
			else
				local dist = p.distanceTraveled
				for seg = 1, totalSegments do
					local i1 = (seg - 1) * 2 + 1
					local x1, y1 = line[i1], line[i1 + 1]
					local x2, y2 = line[i1 + 2], line[i1 + 3]
					local segLen = math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
					if dist < segLen then
						local t = dist / segLen
						p.x = x1 + (x2 - x1) * t
						p.y = y1 + (y2 - y1) * t
						break
					else
						dist = dist - segLen
					end
				end
			end
		end
	end
end

-- removes points that have finished their paths
-- called by points.update to clean up completed points
local function removeNotValidPoints()
	for i = #points, 1, -1 do
		local point = points[i]
		if point.currentEdgeIndex > #point.edges or point.remove then
			if point.edges[point.currentEdgeIndex] then
				removePointFromEdge(point, point.edges[point.currentEdgeIndex])
			end
			table.remove(points, i)

		end
	end
end

-- initializes routes with paths and edges
-- called by main.lua during love.load
function points.initialize(paths)
	for _, route in ipairs(paths) do
		local path, distance = points.findShortestPath(route.startId, route.endId)
		if path then
			route.path = path
			route.distance = distance
			route.edges = buildEdgesFromPath(path)
		else
			print("no path found from " .. route.startId .. " to " .. route.endId)
			route.path = {route.startId}
			route.edges = {}
		end
	end
end

-- updates simulation state
-- called by main.lua in love.update
function points.update(dt, paths)
	spawnParticles(dt, paths)
	updateParticleVelocities(dt)
	moveParticles(dt)
	removeNotValidPoints()
end

-- draws points and interaction lines
-- called by main.lua in love.draw
function points.draw()
	for _, p in ipairs(points) do
		local x = math.floor (p.x+0.5)
		local y = math.floor (p.y+0.5)
		love.graphics.setColor(p.color)
		love.graphics.circle("fill", p.x, p.y, 4)
		love.graphics.setColor(0, 0, 0)
		love.graphics.circle("line", p.x, p.y, 5)
		for _, line in ipairs(p.interactionLines) do
			local x1, y1, x2, y2, r, g, b = unpack(line)
			love.graphics.setColor(r, g, b)
			love.graphics.setLineWidth(2)
			love.graphics.line(x1, y1, x2, y2)
		end
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(tostring(p.id), x + 6, y - 2)
		love.graphics.print(tostring(p.id), x + 6, y - 4)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(tostring(p.id), x + 6, y - 3)
	end
end

return points