-- points.lua
local diagram = require("diagram")
local data = require("data")

local points = {}

local spawnInterval = 0.8
local spawnTimer = 0
local maxSpeed = 60  -- maximum speed for points
local hardRadius = 15 -- points stop if closer than this in Case 2, yield in Case 1/3
local softRadius = 30 -- points start yielding within this distance
local minSpeed = 5   -- minimum speed for Case 1 and Case 3 to prevent full stops
local pointIdCounter = 0  -- counter for assigning unique point IDs

--print = function () end

-- helper function to find an edge between two nodes
local function findEdgeBetween(fromId, toId)
	for _, edge in pairs(data.edges) do
		if edge.nodeIndices[1] == fromId and edge.nodeIndices[#edge.nodeIndices] == toId then
			return edge
		end
	end
	return nil
end

-- calculate distance between two points
local function getDistance(p1, p2)
	local dx = p2.x - p1.x
	local dy = p2.y - p1.y
	return math.sqrt(dx * dx + dy * dy)
end

-- iterator for unique pairs
local function uniquePairs(t)
	local i = 0
	local j = 1
	return function()
		j = j + 1
		if j > #t then
			i = i + 1
			j = i + 1
		end
		if i < #t then
			return t[i], t[j]
		end
	end
end

-- add point to edge
local function addPointToEdge(point, edge)
	if not edge.points then
		edge.points = {}
	end
	table.insert(edge.points, point)
end

-- remove point from edge
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

-- get all points on a specific edge
local function getPointsOnEdge(edge)
	return edge.points or {}
end

-- get points on next edges within softRadius
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

-- get points on previous edges within softRadius
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

-- spawn new points based on timer and paths
--local function spawnParticles(dt, paths)
--	spawnTimer = spawnTimer + dt
--	if spawnTimer >= spawnInterval then
--		spawnTimer = spawnTimer - spawnInterval
--		for _, route in ipairs(paths) do
--			if #route.edges > 0 then
--				local startNode = data.nodes[route.path[1]]
--				pointIdCounter = pointIdCounter + 1
--				local point = {
--					id = pointIdCounter,   -- unique ID for each point
--					edges = route.edges,
--					currentEdgeIndex = 1,
--					nextEdgeIndex = 2,
--					distanceTraveled = 0,
--					x = startNode.x,
--					y = startNode.y,
--					maxSpeed = maxSpeed,
--					speed = maxSpeed,
--					hardRadius = hardRadius,
--					softRadius = softRadius,
--					color = {1, 1, 1},  -- default: white
--					interactionLines = {}
--				}
--				table.insert(points, point)
--				addPointToEdge(point, route.edges[1])
--			end
--		end
--	end
--end

--local function spawnParticles(dt, paths)
--	-- spawn new points periodically
--	spawnTimer = spawnTimer + dt
--	if spawnTimer >= spawnInterval then
--		spawnTimer = spawnTimer - spawnInterval
--		for _, route in ipairs(paths) do
--			-- compute fresh path for new point
--			local path, distance = diagram.findShortestPath(route.startId, route.endId)
--			if #path < 2 then
--				print("no valid path for route " .. route.startId .. "->" .. route.endId)
--			else
--				-- build edges from path
--				local edges = {}
--				for j = 1, #path - 1 do
--					local edge = findEdgeBetween(path[j], path[j + 1])
--					if edge then
--						table.insert(edges, edge)
--					else
--						print("no edge from " .. path[j] .. " to " .. path[j + 1])
--						edges = {}
--						break
--					end
--				end
--				if #edges == 0 then
--					print("no valid edges for route " .. route.startId .. "->" .. route.endId)
--				else
--					-- create new point
--					local startNode = data.nodes[path[1]]
--					pointIdCounter = pointIdCounter + 1
--					local point = {
--						id = pointIdCounter,
--						edges = edges,
--						currentEdgeIndex = 1,
--						nextEdgeIndex = 2,
--						distanceTraveled = 0,
--						x = startNode.x,
--						y = startNode.y,
--						maxSpeed = maxSpeed,
--						speed = maxSpeed,
--						hardRadius = hardRadius,
--						softRadius = softRadius,
--						color = {1, 1, 1},
--						interactionLines = {},
--						endNodeId = route.endId  -- store destination for recalculation
--					}
--					table.insert(points, point)
--					addPointToEdge(point, edges[1])
----                    print("spawned point " .. point.id .. " on edge " .. edges[1].nodeIndices[1] .. "->" .. edges[1].nodeIndices[#edges[1].nodeIndices] .. ", path: " .. table.concat(path, " -> "))
--				end
--			end
--		end
--	end
--end

local function buildEdgesFromPath(path)
    -- build edges from path nodes
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

local function createPoint(edges, startNode, endNodeId)
    -- create new point with initial properties
    pointIdCounter = pointIdCounter + 1
    local point = {
        id = pointIdCounter,
        edges = edges,
        currentEdgeIndex = 1,
        nextEdgeIndex = 2,
        distanceTraveled = 0,
        x = startNode.x,
        y = startNode.y,
        maxSpeed = maxSpeed,
        speed = maxSpeed,
        hardRadius = hardRadius,
        softRadius = softRadius,
        color = {1, 1, 1},
        interactionLines = {},
        endNodeId = endNodeId
    }
    return point
end

local function spawnParticles(dt, paths)
    -- spawn new points periodically
    spawnTimer = spawnTimer + dt
    if spawnTimer >= spawnInterval then
        spawnTimer = spawnTimer - spawnInterval
        for _, route in ipairs(paths) do
            -- get path and edges
--            local path, _ = computePath(route.startId, route.endId)
            local path, distance = diagram.findShortestPath(route.startId, route.endId)
            if not path then
                -- skip if no valid path
            else
                local edges = buildEdgesFromPath(path)
                if #edges > 0 then
                    -- create and add point
                    local startNode = data.nodes[path[1]]
                    local point = createPoint(edges, startNode, route.endId)
                    table.insert(points, point)
                    addPointToEdge(point, edges[1])
                    -- print("spawned point " .. point.id .. " on edge " .. edges[1].nodeIndices[1] .. "->" .. edges[1].nodeIndices[#edges[1].nodeIndices] .. ", path: " .. table.concat(path, " -> "))
                end
            end
        end
    end
end

-- update velocities of all points with priority logic
local function updateParticleVelocities(dt)
	-- reset states
	for _, p in ipairs(points) do
		p.speed = p.maxSpeed
		p.color = {1, 1, 1}  -- default: white
		p.interactionLines = {}
	end

	-- process interactions
	for _, thisP in ipairs(points) do
		local edge = thisP.edges[thisP.currentEdgeIndex]
		if edge then
			local thisDistToEnd = edge.length - thisP.distanceTraveled
			local logMessages = {}
			local newSpeed = thisP.maxSpeed  -- track the highest possible speed

			if thisP.id == 3 or thisP.id == 4 or thisP.id == 8 or thisP.id == 9 or thisP.id == 13 or thisP.id == 14 then
				table.insert(logMessages, string.format("Point %d at edge %d, distToEnd %.2f, speed %.2f", thisP.id, thisP.currentEdgeIndex, thisDistToEnd, thisP.speed))
			end

			-- Case 1: Points on the same edge
			local sameEdgePoints = getPointsOnEdge(edge)
			for _, otherP in ipairs(sameEdgePoints) do
				if thisP ~= otherP then
					local dist = getDistance(thisP, otherP)
					local otherDistToEnd = edge.length - otherP.distanceTraveled
					if dist < thisP.softRadius then
						local hasPriority = thisDistToEnd < otherDistToEnd
						if not hasPriority then
							-- thisP yields
							local tempSpeed
							if dist < thisP.hardRadius then
								tempSpeed = minSpeed
							else
								local f = (dist - thisP.hardRadius) / (thisP.softRadius - thisP.hardRadius)
								tempSpeed = minSpeed + (thisP.maxSpeed - minSpeed) * math.max(0, f)
							end
							newSpeed = math.min(newSpeed, tempSpeed)
							thisP.color = {1, 0, 0}  -- red: yields
							otherP.color = {0, 1, 0}  -- green: passes
							table.insert(thisP.interactionLines, {otherP.x, otherP.y, thisP.x, thisP.y, 1.0, 0.5, 0.0})
							if thisP.id == 3 or thisP.id == 4 or thisP.id == 8 or thisP.id == 9 or thisP.id == 13 or thisP.id == 14 then
								table.insert(logMessages, string.format("Sees point %d on same edge, dist %.2f, I'm farther (%.2f > %.2f), yielding, new speed %.2f", 
										otherP.id, dist, thisDistToEnd, otherDistToEnd, tempSpeed))
							end
						else
							-- otherP yields
							local tempSpeed
							if dist < otherP.hardRadius then
								tempSpeed = minSpeed
							else
								local f = (dist - otherP.hardRadius) / (otherP.softRadius - otherP.hardRadius)
								tempSpeed = minSpeed + (otherP.maxSpeed - minSpeed) * math.max(0, f)
							end
							otherP.speed = math.min(otherP.speed, tempSpeed)
							otherP.color = {1, 0, 0}  -- red: yields
							thisP.color = {0, 1, 0}   -- green: passes
							table.insert(otherP.interactionLines, {thisP.x, thisP.y, otherP.x, otherP.y, 1.0, 0.5, 0.0})
							if thisP.id == 3 or thisP.id == 4 or thisP.id == 8 or thisP.id == 9 or thisP.id == 13 or thisP.id == 14 then
								table.insert(logMessages, string.format("Sees point %d on same edge, dist %.2f, I'm closer (%.2f < %.2f), proceeding, speed %.2f", 
										otherP.id, dist, thisDistToEnd, otherDistToEnd, newSpeed))
							end
						end
					end
				end
			end

			-- Case 2: Points on next edges within softRadius
			local nextEdgePoints = getNextEdgesWithinRadius(thisP, edge)
			for _, otherP in ipairs(nextEdgePoints) do
				local dist = getDistance(thisP, otherP)
				if dist < thisP.softRadius then
					-- thisP yields to otherP
					local tempSpeed
					if dist < thisP.hardRadius then
						tempSpeed = 0  -- stop completely
					else
						local f = (dist - thisP.hardRadius) / (thisP.softRadius - thisP.hardRadius)
						tempSpeed = thisP.maxSpeed * math.max(0, f)  -- no minSpeed, slows to 0 at hardRadius
					end
					newSpeed = math.min(newSpeed, tempSpeed)
					thisP.color = {1, 0, 0}  -- red: yields
					otherP.color = {0, 1, 0}  -- green: passes
					table.insert(thisP.interactionLines, {otherP.x, otherP.y, thisP.x, thisP.y, 1.0, 0.5, 0.0})
					if thisP.id == 3 or thisP.id == 4 or thisP.id == 8 or thisP.id == 9 or thisP.id == 13 or thisP.id == 14 then
						table.insert(logMessages, string.format("Sees point %d on next edge, dist %.2f, yielding, new speed %.2f", 
								otherP.id, dist, tempSpeed))
					end
				end
			end

			-- Case 3: Points on previous edges of next edges
			if thisP.nextEdgeIndex <= #thisP.edges then
				local nextEdge = thisP.edges[thisP.nextEdgeIndex]
				local prevEdgePoints = getPrevEdgesWithinRadius(thisP, nextEdge)
				for _, otherP in ipairs(prevEdgePoints) do
					local otherEdge = otherP.edges[otherP.currentEdgeIndex]
					local otherDistToEnd = otherEdge.length - otherP.distanceTraveled
					-- Skip if already handled in Case 1
					if otherEdge ~= edge then
						if thisDistToEnd < thisP.softRadius and otherDistToEnd < otherP.softRadius then
							local hasPriority = thisDistToEnd < otherDistToEnd
							if not hasPriority then
								-- thisP yields
								local dist = getDistance(thisP, otherP)
								local tempSpeed
								if dist < thisP.hardRadius then
									tempSpeed = minSpeed
								else
									local f = (dist - thisP.hardRadius) / (thisP.softRadius - thisP.hardRadius)
									tempSpeed = minSpeed + (thisP.maxSpeed - minSpeed) * math.max(0, f)
								end
								newSpeed = math.min(newSpeed, tempSpeed)
								thisP.color = {1, 0, 0}  -- red: yields
								otherP.color = {0, 1, 0} -- green: passes
								table.insert(thisP.interactionLines, {otherP.x, otherP.y, thisP.x, thisP.y, 1.0, 0.5, 0.0})
								if thisP.id == 3 or thisP.id == 4 or thisP.id == 8 or thisP.id == 9 or thisP.id == 13 or thisP.id == 14 then
									table.insert(logMessages, string.format("Sees point %d on prev edge of next, dist %.2f, I'm farther (%.2f > %.2f), yielding, new speed %.2f", 
											otherP.id, dist, thisDistToEnd, otherDistToEnd, tempSpeed))
								end
							else
								-- otherP yields
								local dist = getDistance(thisP, otherP)
								local tempSpeed
								if dist < otherP.hardRadius then
									tempSpeed = minSpeed
								else
									local f = (dist - otherP.hardRadius) / (otherP.softRadius - otherP.hardRadius)
									tempSpeed = minSpeed + (otherP.maxSpeed - minSpeed) * math.max(0, f)
								end
								otherP.speed = math.min(otherP.speed, tempSpeed)
								otherP.color = {1, 0, 0}  -- red: yields
								thisP.color = {0, 1, 0}  -- green: passes
								table.insert(otherP.interactionLines, {thisP.x, thisP.y, otherP.x, otherP.y, 1.0, 0.5, 0.0})
								if thisP.id == 3 or thisP.id == 4 or thisP.id == 8 or thisP.id == 9 or thisP.id == 13 or thisP.id == 14 then
									table.insert(logMessages, string.format("Sees point %d on prev edge of next, dist %.2f, I'm closer (%.2f < %.2f), proceeding, speed %.2f", 
											otherP.id, dist, thisDistToEnd, otherDistToEnd, newSpeed))
								end
							end
						end
					end
				end
			end

			-- Apply the final speed
			thisP.speed = newSpeed

			-- Print thoughts for points 3, 4, 8, 9, 13, 14
			if thisP.id == 3 or thisP.id == 4 or thisP.id == 8 or thisP.id == 9 or thisP.id == 13 or thisP.id == 14 then
				if #logMessages == 1 then
					table.insert(logMessages, string.format("Point %d: No interactions, moving freely", thisP.id))
				end
				for _, msg in ipairs(logMessages) do
--					print(msg)
				end
			end
		end
	end
end

-- move points based on their current velocities
local function moveParticles(dt)
	for i, p in ipairs(points) do
		if p.speed > 0 then
			p.distanceTraveled = p.distanceTraveled + p.speed * dt

			local edge = p.edges[p.currentEdgeIndex]
			local totalLength = edge.length
			local line = edge.line
			local totalSegments = (#line / 2) - 1

			if p.distanceTraveled >= totalLength then
				p.distanceTraveled = 0
				removePointFromEdge(p, edge)
				p.currentEdgeIndex = p.currentEdgeIndex + 1
				p.nextEdgeIndex = p.currentEdgeIndex + 1
				if p.currentEdgeIndex <= #p.edges then
					local nextEdge = p.edges[p.currentEdgeIndex]
					p.x = nextEdge.line[1]
					p.y = nextEdge.line[2]
					p.speed = p.maxSpeed  -- Reset speed after transition
					addPointToEdge(p, nextEdge)
					-- Log transition for tracked points
					if p.id == 3 or p.id == 4 or p.id == 8 or p.id == 9 or p.id == 13 or p.id == 14 then
						--print(string.format("Point %d transitioned to edge %d", p.id, p.currentEdgeIndex))
					end
				end
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

-- remove points that have reached the end of their path
local function removeNotValidPoints()
	for i = #points, 1, -1 do
		local point = points[i]
		if point.currentEdgeIndex > #point.edges then
			removePointFromEdge(point, point.edges[#point.edges])
			table.remove(points, i)
			if point.id == 3 or point.id == 4 or point.id == 8 or point.id == 9 or point.id == 13 or point.id == 14 then
				--print(string.format("Point %d removed (reached end of path)", point.id))
			end
		end
	end
end

function points.initialize(paths)
	-- calculate shortest paths and edges for all pairs
	for _, route in ipairs(paths) do
		local path, distance = diagram.findShortestPath(route.startId, route.endId)
		if path then
			route.path = path
			route.distance = distance
			route.edges = {}
			for j = 1, #path - 1 do
				local edge = findEdgeBetween(path[j], path[j + 1])
				if edge then
					table.insert(route.edges, edge)
				else
					--print('no direct edge from ' .. path[j] .. ' to ' .. path[j + 1])
				end
			end
		else
			--print('no path found from ' .. route.startId .. ' to ' .. route.endId)
			route.path = {route.startId}
			route.edges = {}
		end
	end
end

function points.update(dt, paths)
	spawnParticles(dt, paths)
	updateParticleVelocities(dt)
	moveParticles(dt)
	removeNotValidPoints()
end

function points.draw()
	for _, p in ipairs(points) do
		-- draw point
		love.graphics.setColor(p.color)
		love.graphics.circle('fill', p.x, p.y, 4)
		love.graphics.setColor(0,0,0)
		love.graphics.circle('line', p.x, p.y, 5)

		-- draw interaction lines
		for _, line in ipairs(p.interactionLines) do
			local x1, y1, x2, y2, r, g, b = unpack(line)
			love.graphics.setColor(r, g, b)
			love.graphics.setLineWidth(2)
			love.graphics.line(x1, y1, x2, y2)
		end

		-- draw point ID in black
		love.graphics.setColor(0, 0, 0)  -- black color
		love.graphics.print(tostring(p.id), p.x + 6, p.y - 3)
	end
end

return points