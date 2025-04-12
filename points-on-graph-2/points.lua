-- points.lua
local diagram = require("diagram")
local data = require("data")

local points = {}

local spawnInterval = 1
local spawnTimer = 0
local maxSpeed = 60  -- maximum speed for points
local hardRadius = 20 -- points yield if closer than this
local softRadius = 40 -- points start yielding and change color within this distance
local pointIdCounter = 0  -- counter for assigning unique point IDs

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
local function spawnParticles(dt, paths)
    spawnTimer = spawnTimer + dt
    if spawnTimer >= spawnInterval then
        spawnTimer = spawnTimer - spawnInterval
        for _, route in ipairs(paths) do
            if #route.edges > 0 then
                local startNode = data.nodes[route.path[1]]
                pointIdCounter = pointIdCounter + 1
                local point = {
                    id = pointIdCounter,   -- unique ID for each point
                    edges = route.edges,
                    currentEdgeIndex = 1,
                    nextEdgeIndex = 2,
                    distanceTraveled = 0,
                    x = startNode.x,
                    y = startNode.y,
                    maxSpeed = maxSpeed,
                    speed = maxSpeed,
                    hardRadius = hardRadius,
                    softRadius = softRadius,
                    color = {1, 1, 1},  -- default: white
                    interactionLines = {}
                }
                table.insert(points, point)
                addPointToEdge(point, route.edges[1])
            end
        end
    end
end

-- ascended

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

            if thisP.id == 1 or thisP.id == 4 then
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
                                tempSpeed = 0
                            else
                                local f = (dist - thisP.hardRadius) / (thisP.softRadius - thisP.hardRadius)
                                tempSpeed = thisP.maxSpeed * math.max(0, f)
                            end
                            newSpeed = math.min(newSpeed, tempSpeed)
                            thisP.color = {1, 0, 0}  -- red: yields
                            otherP.color = {0, 1, 0}  -- green: passes
                            table.insert(thisP.interactionLines, {otherP.x, otherP.y, thisP.x, thisP.y, 1.0, 0.5, 0.0})
                            if thisP.id == 1 or thisP.id == 4 then
                                table.insert(logMessages, string.format("Sees point %d on same edge, dist %.2f, I'm farther (%.2f > %.2f), yielding, new speed %.2f", 
                                    otherP.id, dist, thisDistToEnd, otherDistToEnd, tempSpeed))
                            end
                        else
                            -- otherP yields
                            local tempSpeed
                            if dist < otherP.hardRadius then
                                tempSpeed = 0
                            else
                                local f = (dist - otherP.hardRadius) / (otherP.softRadius - otherP.hardRadius)
                                tempSpeed = otherP.maxSpeed * math.max(0, f)
                            end
                            otherP.speed = math.min(otherP.speed, tempSpeed)
                            otherP.color = {1, 0, 0}  -- red: yields
                            thisP.color = {0, 1, 0}   -- green: passes
                            table.insert(otherP.interactionLines, {thisP.x, thisP.y, otherP.x, otherP.y, 1.0, 0.5, 0.0})
                            if thisP.id == 1 or thisP.id == 4 then
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
                if thisDistToEnd < thisP.softRadius then
                    local dist = getDistance(thisP, otherP)
                    -- otherP yields to thisP
                    local tempSpeed
                    if dist < otherP.hardRadius then
                        tempSpeed = 0
                    else
                        local f = (dist - otherP.hardRadius) / (otherP.softRadius - otherP.hardRadius)
                        tempSpeed = otherP.maxSpeed * math.max(0, f)
                    end
                    otherP.speed = math.min(otherP.speed, tempSpeed)
                    otherP.color = {1, 0, 0}  -- red: yields
                    thisP.color = {0, 1, 0}   -- green: passes
                    table.insert(otherP.interactionLines, {thisP.x, thisP.y, otherP.x, otherP.y, 1.0, 0.5, 0.0})
                    if thisP.id == 1 or thisP.id == 4 then
                        table.insert(logMessages, string.format("Sees point %d on next edge, dist %.2f, I'm near node (%.2f < %.2f), proceeding, speed %.2f", 
                            otherP.id, dist, thisDistToEnd, thisP.softRadius, newSpeed))
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
                        if thisDistToEnd < thisP.softRadius or otherDistToEnd < otherP.softRadius then
                            local hasPriority = thisDistToEnd < otherDistToEnd
                            if not hasPriority then
                                -- thisP yields
                                local dist = getDistance(thisP, otherP)
                                local tempSpeed
                                if dist < thisP.hardRadius then
                                    tempSpeed = 0
                                else
                                    local f = (dist - thisP.hardRadius) / (thisP.softRadius - thisP.hardRadius)
                                    tempSpeed = thisP.maxSpeed * math.max(0, f)
                                end
                                newSpeed = math.min(newSpeed, tempSpeed)
                                thisP.color = {1, 0, 0}  -- red: yields
                                otherP.color = {0, 1, 0} -- green: passes
                                table.insert(thisP.interactionLines, {otherP.x, otherP.y, thisP.x, thisP.y, 1.0, 0.5, 0.0})
                                if thisP.id == 1 or thisP.id == 4 then
                                    table.insert(logMessages, string.format("Sees point %d on prev edge of next, dist %.2f, I'm farther (%.2f > %.2f), yielding, new speed %.2f", 
                                        otherP.id, dist, thisDistToEnd, otherDistToEnd, tempSpeed))
                                end
                            else
                                -- otherP yields
                                local dist = getDistance(thisP, otherP)
                                local tempSpeed
                                if dist < otherP.hardRadius then
                                    tempSpeed = 0
                                else
                                    local f = (dist - otherP.hardRadius) / (otherP.softRadius - otherP.hardRadius)
                                    tempSpeed = otherP.maxSpeed * math.max(0, f)
                                end
                                otherP.speed = math.min(otherP.speed, tempSpeed)
                                otherP.color = {1, 0, 0}  -- red: yields
                                thisP.color = {0, 1, 0}  -- green: passes
                                table.insert(otherP.interactionLines, {thisP.x, thisP.y, otherP.x, otherP.y, 1.0, 0.5, 0.0})
                                if thisP.id == 1 or thisP.id == 4 then
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

            -- Print thoughts for points 1 and 4
            if thisP.id == 1 or thisP.id == 4 then
                if #logMessages == 1 then
                    table.insert(logMessages, string.format("Point %d: No interactions, moving freely", thisP.id))
                end
                for _, msg in ipairs(logMessages) do
                    print(msg)
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
                    addPointToEdge(p, nextEdge)
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
                    print('no direct edge from ' .. path[j] .. ' to ' .. path[j + 1])
                end
            end
        else
            print('no path found from ' .. route.startId .. ' to ' .. route.endId)
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