-- diagram.lua
-- manages the road network, including curved edges, lane geometry, and transitions

local diagram = {}
local utils = require("utils")

-- configuration constants
local maxSpeed = 60 -- pixels per second, synced with points.lua
local laneWidth = 16 -- width between lanes (pixels)
local bezierSegments = 16 -- number of segments for bezier curve approximation
local nodeRadius = 5 -- radius for node visualization
local dashLength = 1 -- length of dashed line segments (pixels)
local dashGap = 60 -- gap between dashed line segments (pixels)
local arrowSpacing = 0.25 -- spacing between arrows as fraction of lane length
local arrowLength = 8
local arrowWidth = 8
local retreatDistance = 30

-- finds fastest route using dijkstra's algorithm, considering lane and transition lengths
function diagram.findShortestPath(startId, endId)
    local distances = {}
    local previous = {}
    local unvisited = {}
    local startLane = 1
    for _, node in pairs(diagram.nodes) do
        for lane = 1, 2 do
            local key = node.id .. ":" .. lane
            distances[key] = math.huge
            unvisited[key] = true
        end
    end
    local startKey = startId .. ":" .. startLane
    distances[startKey] = 0
    while next(unvisited) do
        local currentKey = nil
        local minDist = math.huge
        for key in pairs(unvisited) do
            if distances[key] < minDist then
                minDist = distances[key]
                currentKey = key
            end
        end
        if currentKey == nil then break end
        local currentId, currentLane = currentKey:match("(%d+):(%d+)")
        currentId = tonumber(currentId)
        currentLane = tonumber(currentLane)
        if currentId == endId then break end
        unvisited[currentKey] = nil
        local currentNode = diagram.nodes[currentId]
        if currentNode.nextEdges then
            for _, edge in ipairs(currentNode.nextEdges) do
                if edge.nodeIndices and #edge.nodeIndices >= 2 then
                    local neighborId = edge.nodeIndices[#edge.nodeIndices]
                    for lane = 1, edge.lanes do
                        local neighborKey = neighborId .. ":" .. lane
                        if unvisited[neighborKey] then
                            local validLane = true
                            if edge.laneDestinations and edge.laneDestinations[currentLane] then
                                local nextEdge = nil
                                for _, e in ipairs(currentNode.nextEdges) do
                                    if e.id == edge.laneDestinations[currentLane][1] then
                                        nextEdge = e
                                        break
                                    end
                                end
                                if nextEdge then
                                    local turnDirection = diagram.getTurnDirection(edge, nextEdge)
                                    validLane = (turnDirection == "left" and lane == 1) or
                                                (turnDirection == "right" and lane == edge.lanes) or
                                                (turnDirection == "straight")
                                end
                            end
                            if validLane then
                                local edgeTravelTime = utils.calculateEdgeTravelTime({length = edge.laneLengths[lane] or edge.length}, 60)
                                local transitionLength = 0
                                for _, transition in ipairs(currentNode.transitionLines[currentLane] or {}) do
                                    if transition.inEdgeId == edge.id and transition.outEdgeId == edge.id then
                                        transitionLength = transition.length or 0
                                        break
                                    end
                                end
                                local alt = distances[currentKey] + edgeTravelTime + transitionLength / 60
                                if alt < distances[neighborKey] then
                                    distances[neighborKey] = alt
                                    previous[neighborKey] = {nodeId = currentId, lane = currentLane}
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    local route = {}
    local current = endId .. ":1"
    while current do
        local nodeId, lane = current:match("(%d+):(%d+)")
        nodeId = tonumber(nodeId)
        lane = tonumber(lane)
        table.insert(route, 1, {nodeId = nodeId, lane = lane})
        current = previous[current] and (previous[current].nodeId .. ":" .. previous[current].lane)
    end
    if #route < 2 then
        return {}, math.huge
    end
    return route, distances[endId .. ":1"]
end

---- converts a node route with lanes to a list of edges with lane assignments
--function diagram.buildEdgesFromPath(route)
--    local edges = {}
--    for i = 1, #route - 1 do
--        local current = route[i]
--        local next = route[i + 1]
--        local edge = utils.findEdgeBetween(current.nodeId, next.nodeId, diagram.edges)
--        if edge then
--            edge.assignedLane = current.lane
--            table.insert(edges, edge)
--        else
--            return nil
--        end
--    end
--    return edges
--end

-- validates edge node indices
local function validateEdge(edgeId, edge, nodes)
    if not edge.nodeIndices or type(edge.nodeIndices) ~= "table" or #edge.nodeIndices < 2 then
        return false
    end
    local startNode = nodes[edge.nodeIndices[1]]
    local endNode = nodes[edge.nodeIndices[#edge.nodeIndices]]
    if not startNode or not endNode then
        return false
    end
    return true, startNode, endNode
end

-- initializes basic edge properties
local function initEdgeProperties(edge, edgeId)
    edge.id = edgeId
    edge.lanes = edge.lanes or 2
    edge.points = edge.points or {}
    edge.laneLines = edge.laneLines or {}
    edge.dashLines = edge.dashLines or {}
    edge.arrowLines = edge.arrowLines or {}
    edge.laneDestinations = edge.laneDestinations or {}
    edge.laneLengths = edge.laneLengths or {}
end

-- creates edge polyline and calculates length
local function createEdgePolyline(edge, startNode, endNode)
    local dx = endNode.x - startNode.x
    local dy = endNode.y - startNode.y
    local x1, y1 = startNode.x, startNode.y
    local x2 = startNode.x + dx * 0.5 + dy * 0.2
    local y2 = startNode.y + dy * 0.5 - dx * 0.2
    local x3, y3 = endNode.x, endNode.y
    edge.line = utils.generateBezierPoints(x1, y1, x2, y2, x3, y3, bezierSegments)
    edge.length = 0
    for i = 1, #edge.line - 2, 2 do
        local x1, y1 = edge.line[i], edge.line[i + 1]
        local x2, y2 = edge.line[i + 2], edge.line[i + 3]
        edge.length = edge.length + utils.getLength(x2 - x1, y2 - y1)
    end
end

-- modifies laneLine to retreat from the end by distance, using edge.line for direction
local function retreatFromEnd(edgeLine, laneLine, distance, offset)
    local remaining = distance
    local i = #edgeLine - 1
    while i >= 3 and remaining > 0 do
        local x, y = edgeLine[i], edgeLine[i + 1]
        local prevX, prevY = edgeLine[i - 2], edgeLine[i - 1]
        local dx = x - prevX
        local dy = y - prevY
        local len = math.sqrt(dx * dx + dy * dy)
        if remaining <= len then
            local t = (len - remaining) / len
            local retX = prevX + t * dx
            local retY = prevY + t * dy
            if len > 0 then
                local perpX = -dy / len * offset
                local perpY = dx / len * offset
                laneLine[#laneLine - 1] = retX + perpX
                laneLine[#laneLine] = retY + perpY
            else
                laneLine[#laneLine - 1] = retX
                laneLine[#laneLine] = retY
            end
            return
        end
        remaining = remaining - len
        table.remove(laneLine, #laneLine)
        table.remove(laneLine, #laneLine)
        i = i - 2
    end
    if #laneLine >= 4 then
        laneLine[#laneLine - 1] = laneLine[#laneLine - 3]
        laneLine[#laneLine] = laneLine[#laneLine - 2]
    else
        laneLine[1] = laneLine[1] or 0
        laneLine[2] = laneLine[2] or 0
    end
end

-- modifies laneLine to retreat from the start by distance, using edgeLine for direction
local function retreatFromStart(edgeLine, laneLine, distance, offset)
    local remaining = distance
    local i = 1
    while i <= #edgeLine - 2 and remaining > 0 do
        local x, y = edgeLine[i], edgeLine[i + 1]
        local nextX, nextY = edgeLine[i + 2], edgeLine[i + 3]
        local dx = nextX - x
        local dy = nextY - y
        local len = math.sqrt(dx * dx + dy * dy)
        if remaining <= len then
            local t = remaining / len
            local retX = x + t * dx
            local retY = y + t * dy
            if len > 0 then
                local perpX = -dy / len * offset
                local perpY = dx / len * offset
                laneLine[1] = retX + perpX
                laneLine[2] = retY + perpY
            else
                laneLine[1] = retX
                laneLine[2] = retY
            end
            return
        end
        remaining = remaining - len
        table.remove(laneLine, 1)
        table.remove(laneLine, 1)
        i = i + 2
    end
    if #laneLine >= 4 then
        laneLine[1] = laneLine[3]
        laneLine[2] = laneLine[4]
    else
        laneLine[1] = laneLine[1] or 0
        laneLine[2] = laneLine[2] or 0
    end
end

-- generates lane lines for a specific lane with retreat at start and end
local function generateLaneLine(edge, lane)
    local offset = (lane - (edge.lanes + 1) / 2) * laneWidth
    local length = math.min(retreatDistance, edge.length / 3)
    local laneLine = utils.lineOffset(edge.line, offset)
    if #edge.line >= 4 then
        retreatFromEnd(edge.line, laneLine, length, offset)
        retreatFromStart(edge.line, laneLine, length, offset)
    end
    if #laneLine < 4 then
        laneLine = utils.lineOffset(edge.line, offset)
    end
    local laneLength = 0
    for i = 1, #laneLine - 2, 2 do
        local dx = laneLine[i + 2] - laneLine[i]
        local dy = laneLine[i + 3] - laneLine[i + 1]
        laneLength = laneLength + math.sqrt(dx * dx + dy * dy)
    end
    edge.laneLengths[lane] = laneLength
    return laneLine
end

-- generates dashed lines for a specific lane
local function generateDashLines(edge, lane, laneLines)
    local dashLines = {}
    local totalSegments = math.floor((#laneLines / 2) - 1)
    if totalSegments < 1 then
        return dashLines
    end
    local totalLength = edge.laneLengths[lane] or edge.length
    local dashDistance = dashLength + dashGap
    local t = 0
    while t < 1 do
        local normalizedT = t * totalLength / totalLength
        local segment = math.floor(normalizedT * totalSegments) + 1
        segment = math.min(segment, totalSegments)
        local segmentT = (normalizedT * totalSegments) % 1
        local i1 = (segment - 1) * 2 + 1
        local x1, y1 = laneLines[i1], laneLines[i1 + 1]
        local x2, y2 = laneLines[i1 + 2], laneLines[i1 + 3]
        local x = x1 + segmentT * (x2 - x1)
        local y = y1 + segmentT * (y2 - y1)
        local dx = x2 - x1
        local dy = y2 - y1
        local len = math.sqrt(dx * dx + dy * dy)
        if len > 0 then
            local dashT = math.min(t + (dashLength / totalLength), 1)
            local dashNormalizedT = dashT * totalLength / totalLength
            local dashSegment = math.floor(dashNormalizedT * totalSegments) + 1
            dashSegment = math.min(dashSegment, totalSegments)
            local dashSegmentT = (dashNormalizedT * totalSegments) % 1
            local dashX = x1 + dashSegmentT * (x2 - x1)
            local dashY = y1 + dashSegmentT * (y2 - y1)
            table.insert(dashLines, {x, y, dashX, dashY})
        end
        t = t + (dashDistance / totalLength)
    end
    return dashLines
end

-- generates arrow lines for a specific lane
local function generateArrowLines(edge, lane, laneLines)
    local arrowLines = {}
    local totalSegments = math.floor((#laneLines / 2) - 1)
    for _, arrowT in ipairs({0.25, 0.5, 0.75}) do
        local segment = math.floor(arrowT * totalSegments) + 1
        segment = math.min(segment, totalSegments)
        local segmentT = (arrowT * totalSegments) % 1
        local i1 = (segment - 1) * 2 + 1
        local x1, y1 = laneLines[i1], laneLines[i1 + 1]
        local x2, y2 = laneLines[i1 + 2], laneLines[i1 + 3]
        local x = x1 + segmentT * (x2 - x1)
        local y = y1 + segmentT * (y2 - y1)
        local dx = x2 - x1
        local dy = y2 - y1
        local len = math.sqrt(dx * dx + dy * dy)
        if len > 0 then
            local forwardX = dx / len * arrowLength
            local forwardY = dy / len * arrowLength
            local perpX = -dy / len * arrowWidth / 2
            local perpY = dx / len * arrowWidth / 2
            local x2 = x + forwardX
            local y2 = y + forwardY
            local x1 = x - forwardX / 2 + perpX
            local y1 = y - forwardY / 2 + perpY
            local x3 = x - forwardX / 2 - perpX
            local y3 = y - forwardY / 2 - perpY
            table.insert(arrowLines, {x1, y1, x2, y2, x3, y3})
        end
    end
    return arrowLines
end

-- generates lane lines, dashed lines, and arrow lines for an edge
local function generateLaneAndDashLines(edge)
    for laneIndex = 1, edge.lanes do
        if #edge.line >= 4 then
            edge.laneLines[laneIndex] = generateLaneLine(edge, laneIndex)
            if #edge.laneLines[laneIndex] >= 4 then
                edge.dashLines[laneIndex] = generateDashLines(edge, laneIndex, edge.laneLines[laneIndex])
                edge.arrowLines[laneIndex] = generateArrowLines(edge, laneIndex, edge.laneLines[laneIndex])
            else
                edge.dashLines[laneIndex] = {}
                edge.arrowLines[laneIndex] = {}
            end
        else
            edge.laneLines[laneIndex] = {}
            edge.dashLines[laneIndex] = {}
            edge.arrowLines[laneIndex] = {}
        end
    end
end

-- generates a quadratic bezier curve with control point at segment intersection
local function generateBezierTransition(inLane, outLane, nodeX, nodeY, inEdge, outEdge, nodeId, lane)
    local x1, y1 = inLane[#inLane - 1], inLane[#inLane]
    local x3, y3 = outLane[1], outLane[2]
    local x2, y2
    local intersection = utils.intersectInfiniteSegments(
        inLane[#inLane - 1], inLane[#inLane], inLane[#inLane - 3], inLane[#inLane - 2],
        outLane[1], outLane[2], outLane[3], outLane[4]
    )
    if intersection then
        x2, y2 = intersection[1], intersection[2]
        local dist1 = math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
        local dist2 = math.sqrt((x2 - x3)^2 + (y2 - y3)^2)
        local dist3 = math.sqrt((x1 - x3)^2 + (y1 - y3)^2)
        if dist1 > dist3 * 3 or dist2 > dist3 * 2 then
            x2, y2 = (x1 + x3) / 2, (y1 + y3) / 2
        end
    else
        x2, y2 = (x1 + x3) / 2, (y1 + y3) / 2
    end
    local curve = utils.generateBezierPoints(x1, y1, x2, y2, x3, y3, 8)
    local length = 0
    for i = 1, #curve - 2, 2 do
        local dx = curve[i + 2] - curve[i]
        local dy = curve[i + 3] - curve[i + 1]
        length = length + math.sqrt(dx * dx + dy * dy)
    end
    local transition = {
        points = curve,
        length = length,
        inEdgeId = inEdge.id,
        outEdgeId = outEdge.id
    }
    return transition
end

-- generates transition lines as quadratic bezier curves for nodes
local function generateTransitionLines(nodes, edges)
    for nodeId, node in pairs(nodes) do
        node.transitionLines = {}
        for lane = 1, 2 do
            node.transitionLines[lane] = {}
        end
        local incomingEdges = {}
        for _, edge in pairs(edges) do
            if edge.nodeIndices and edge.nodeIndices[#edge.nodeIndices] == nodeId then
                table.insert(incomingEdges, edge)
            end
        end
        for _, inEdge in ipairs(incomingEdges) do
            for _, outEdge in ipairs(node.nextEdges) do
                for lane = 1, math.min(inEdge.lanes, outEdge.lanes) do
                    local inLane = inEdge.laneLines[lane]
                    local outLane = outEdge.laneLines[lane]
                    if inLane and outLane and #inLane >= 4 and #outLane >= 4 then
                        local transition = generateBezierTransition(inLane, outLane, node.x, node.y, inEdge, outEdge, nodeId, lane)
                        table.insert(node.transitionLines[lane], transition)
                    end
                end
            end
        end
    end
end

-- initializes lane destinations based on next edges
local function initLaneDestinations(edge, endNode)
    if endNode and endNode.nextEdges then
        for lane = 1, edge.lanes do
            edge.laneDestinations[lane] = {}
        end
        for _, nextEdge in ipairs(endNode.nextEdges) do
            local turnDirection = diagram.getTurnDirection(edge, nextEdge)
            if turnDirection == "left" then
                table.insert(edge.laneDestinations[1], nextEdge.id)
            elseif turnDirection == "right" then
                table.insert(edge.laneDestinations[edge.lanes], nextEdge.id)
            else
                for lane = 1, edge.lanes do
                    table.insert(edge.laneDestinations[lane], nextEdge.id)
                end
            end
        end
    end
end

-- initializes nodes and edges with curved paths
function diagram.initialize(nodes, edges)
    diagram.nodes = nodes
    diagram.edges = edges
    
    for edgeId, edge in pairs(edges) do
        initEdgeProperties(edge, edgeId)
        local isValid, startNode, endNode = validateEdge(edgeId, edge, nodes)
        if not isValid then
            edge.length = 1
            edge.line = {startNode and startNode.x or 0, startNode and startNode.y or 0, endNode and endNode.x or 0, endNode and endNode.y or 0}
            edge.laneLines = {}
            edge.dashLines = {}
            edge.laneLengths = {}
        else
            createEdgePolyline(edge, startNode, endNode)
            generateLaneAndDashLines(edge)
            initLaneDestinations(edge, endNode)
        end
    end
    for nodeId, node in pairs(nodes) do
        node.nextEdges = {}
        for _, edge in pairs(edges) do
            if edge.nodeIndices and edge.nodeIndices[1] == nodeId then
                table.insert(node.nextEdges, edge)
            end
        end
    end
    generateTransitionLines(nodes, edges)
end

-- computes the turn direction from one edge to the next
function diagram.getTurnDirection(edge, nextEdge)
    if not edge or not nextEdge or not edge.nodeIndices or not nextEdge.nodeIndices then
        return "straight"
    end
    local startNode = diagram.nodes[edge.nodeIndices[1]]
    local endNode = diagram.nodes[edge.nodeIndices[#edge.nodeIndices]]
    local nextStartNode = diagram.nodes[nextEdge.nodeIndices[1]]
    local nextEndNode = diagram.nodes[nextEdge.nodeIndices[#nextEdge.nodeIndices]]
    if not startNode or not endNode or not nextStartNode or not nextEndNode then
        return "straight"
    end
    if endNode.id ~= nextStartNode.id then
        return "straight"
    end
    local dx1 = endNode.x - startNode.x
    local dy1 = endNode.y - startNode.y
    local dx2 = nextEndNode.x - nextStartNode.x
    local dy2 = nextEndNode.y - nextStartNode.y
    local angle = utils.getAngleBetweenVectors(dx1, dy1, dx2, dy2)
    if math.abs(angle) < math.pi / 6 then
        return "straight"
    elseif angle > 0 then
        return "left"
    else
        return "right"
    end
end

-- gets position on a lane at progress t
function diagram.getLanePosition(edge, lane, t)
    if not edge.laneLines or not edge.laneLines[lane] then
        return edge.line[1] or 0, edge.line[2] or 0
    end
    local laneLine = edge.laneLines[lane]
    local totalSegments = math.floor((#laneLine / 2) - 1)
    if totalSegments < 1 then
        return laneLine[1], laneLine[2]
    end
    local segment = math.floor(t * totalSegments) + 1
    segment = math.min(segment, totalSegments)
    local segmentT = (t * totalSegments) % 1
    local i1 = (segment - 1) * 2 + 1
    local x1, y1 = laneLine[i1], laneLine[i1 + 1]
    local x2, y2 = laneLine[i1 + 2], laneLine[i1 + 3]
    local x = x1 + segmentT * (x2 - x1)
    local y = y1 + segmentT * (y2 - y1)
    return x, y
end

-- gets position on a transition curve at progress t
function diagram.getTransitionPosition(curve, t)
    local totalSegments = math.floor((#curve / 2) - 1)
    if totalSegments < 1 then
        return curve[1] or 0, curve[2] or 0
    end
    local segment = math.floor(t * totalSegments) + 1
    segment = math.min(segment, totalSegments)
    local segmentT = (t * totalSegments) % 1
    local i1 = (segment - 1) * 2 + 1
    local x1, y1 = curve[i1], curve[i1 + 1]
    local x2, y2 = curve[i1 + 2], curve[i1 + 3]
    local x = x1 + segmentT * (x2 - x1)
    local y = y1 + segmentT * (y2 - y1)
    return x, y
end

-- handles transition through a node
function diagram.transitionThroughNode(point, currentEdge, nextEdge, node)
    if not nextEdge then
        point.currentEdgeIndex = point.currentEdgeIndex + 1
        return
    end
    local turnDirection = diagram.getTurnDirection(currentEdge, nextEdge)
    local requiredLane = turnDirection == "left" and 1 or (turnDirection == "right" and currentEdge.lanes or point.lane)
    if point.lane ~= requiredLane then
        return
    end
    local transitionCurve = nil
    if node.transitionLines and node.transitionLines[point.lane] then
        for _, curve in ipairs(node.transitionLines[point.lane]) do
            local curveStartX, curveStartY = curve.points[1], curve.points[2]
                local curveEndX, curveEndY = curve.points[#curve.points - 1], curve.points[#curve.points]
                local inLaneEndX, inLaneEndY = currentEdge.laneLines[point.lane][#currentEdge.laneLines[point.lane] - 1], currentEdge.laneLines[point.lane][#currentEdge.laneLines[point.lane]]
                local outLaneStartX, outLaneStartY = nextEdge.laneLines[point.lane][1], nextEdge.laneLines[point.lane][2]
                local distStart = math.sqrt((curveStartX - inLaneEndX)^2 + (curveStartY - inLaneEndY)^2)
                local distEnd = math.sqrt((curveEndX - outLaneStartX)^2 + (curveEndY - outLaneStartY)^2)
                if distStart < 1 and distEnd < 1 and curve.inEdgeId == currentEdge.id and curve.outEdgeId == nextEdge.id then
                    transitionCurve = curve
                    break
                end
            end
        end
    if not transitionCurve then
        utils.removePointFromEdge(point, currentEdge)
        local newLane = point.lane
        if newLane > nextEdge.lanes then
            newLane = nextEdge.lanes
        end
        local newLaneX, newLaneY, newT = utils.findClosestPointOnLane(nextEdge, newLane, point.laneX, point.laneY)
        if newT > 0 then
            point.distanceTraveled = newT * nextEdge.length
        else
            point.distanceTraveled = 0
        end
        point.lane = newLane
        point.desiredLane = nil
        point.laneChangeProgress = 0
        point.currentEdgeIndex = point.currentEdgeIndex + 1
        utils.addPointToEdge(point, nextEdge)
        point.laneX = newLaneX
        point.laneY = newLaneY
        return
    end
    local newLane = point.lane
    if newLane > nextEdge.lanes then
        newLane = nextEdge.lanes
    end
    local newLaneX, newLaneY, newT = utils.findClosestPointOnLane(nextEdge, newLane, transitionCurve.points[#transitionCurve.points - 1], transitionCurve.points[#transitionCurve.points])
    point.isTransitioning = true
    point.distanceTraveled = 0
    point.transitionCurve = transitionCurve
    point.nextEdge = nextEdge
    point.nextLane = newLane
    point.transitionToX = newLaneX
    point.transitionToY = newLaneY
    point.transitionToT = newT
end

-- draws the road network with curved edges and dashed lines with arrows
function diagram.draw()
    love.graphics.setColor(0.5, 0.5, 0.5)
    for _, edge in pairs(diagram.edges) do
        love.graphics.setLineWidth(laneWidth * edge.lanes)
        if edge.line and #edge.line >= 4 then
            love.graphics.line(edge.line)
        end
    end
    for _, edge in pairs(diagram.edges) do
        love.graphics.setLineWidth(0.5)
        for lane, laneLine in ipairs(edge.laneLines) do
            love.graphics.setColor(0.7, 0.7, 0.7)
            love.graphics.line(laneLine)
        end
        for lane, dashLine in ipairs(edge.dashLines) do
            if #dashLine > 0 then
                love.graphics.setColor(1, 1, 1, 0.75)
                love.graphics.setLineWidth(2)
                for _, segment in ipairs(dashLine) do
                    love.graphics.line(segment)
                end
            end
        end
        for lane, arrowLine in ipairs(edge.arrowLines) do
            if #arrowLine > 0 then
                love.graphics.setColor(1, 1, 1)
                love.graphics.setLineWidth(1)
                for _, segment in ipairs(arrowLine) do
                    love.graphics.line(segment)
                end
            end
        end
    end
    love.graphics.setColor(1, 1, 1)
    for id, node in pairs(diagram.nodes) do
        love.graphics.circle("fill", node.x, node.y, nodeRadius)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(id, node.x + 5, node.y + 5)
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.setLineWidth(1)
    love.graphics.setColor(0.8, 0.8, 0.7)
    for _, node in pairs(diagram.nodes) do
        for lane, transitions in ipairs(node.transitionLines) do
            for _, transition in ipairs(transitions) do
                love.graphics.line(transition.points)
            end
        end
    end
    love.graphics.setColor(0, 0, 0)
    love.graphics.setPointSize(2)
    for _, node in pairs(diagram.nodes) do
        for lane, transitions in ipairs(node.transitionLines) do
            for _, transition in ipairs(transitions) do
                love.graphics.points(transition.points)
            end
        end
    end
end

-- builds edges with transitions
function diagram.buildEdgesWithTransitions(route)
    local edges = {}
    for i = 1, #route - 1 do
        local currentNodeId = route[i]
        local nextNodeId = route[i + 1]
        local edge = utils.findEdgeBetween(currentNodeId, nextNodeId, diagram.edges)
        if not edge then
            return nil
        end
        table.insert(edges, edge)
    end
    return edges
end

return diagram