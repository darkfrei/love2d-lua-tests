local diagram = {}

local speedThresholds = {
    {threshold = 45, fillColor = {0.16, 0.86, 0.625}, outlineColor = {0.08, 0.625, 0.4}}, -- high speed: teal
    {threshold = 30, fillColor = {1, 0.8, 0.3}, outlineColor = {0.94, 0.75, 0.625}}, -- medium speed: yellow
    {threshold = 15, fillColor = {0.94, 0.3, 0.27}, outlineColor = {0.6, 0.23, 0.23}},   -- low speed: red
    {threshold = 0,  fillColor = {0.66, 0.16, 0.16}, outlineColor = {0.4, 0.12, 0}}    -- very low speed: dark red
}

-- configuration constants
local laneWidth = 10  -- pixels between lanes for visualization

-- assigns random number of lanes (1, 2, or 3) to an edge
local function assignRandomLanes(edge)
    return edge.lanes or math.random(1, 3)
end

-- calculates Euclidean distance between two points
local function getLength(dx, dy)
    return math.sqrt(dx * dx + dy * dy)
end

-- generates line coordinates for an edge
local function getEdgeLine(nodes, edge)
    local line = {}
    for _, nodeIndex in ipairs(edge.nodeIndices) do
        local node = nodes[nodeIndex]
        table.insert(line, node.x)
        table.insert(line, node.y)
    end
    if #edge.nodeIndices == 2 then
        return line
    elseif #edge.nodeIndices == 3 then
        local curve = love.math.newBezierCurve(line)
        local line2 = {}
        local amount = 8 -- Reduced from 16 to avoid dense points
        for i = 0, amount do
            local x, y = curve:evaluate(i / amount)
            table.insert(line2, x)
            table.insert(line2, y)
        end
        return line2
    end
    return line
end

-- calculates total length of an edge
local function getEdgeLength(nodes, edge)
    local length = 0
    local line = edge.line
    for i = 1, #line - 2, 2 do
        local x1, y1 = line[i], line[i + 1]
        local x2, y2 = line[i + 2], line[i + 3]
        length = length + getLength(x2 - x1, y2 - y1)
    end
    return length
end

-- computes lengths of edge segments
local function computeSegmentLengths(edge)
    local line = edge.line
    local lengths = {}
    local total = 0
    local cumulative = {}
    for i = 1, #line - 2, 2 do
        local x1, y1 = line[i], line[i + 1]
        local x2, y2 = line[i + 2], line[i + 3]
        local len = getLength(x2 - x1, y2 - y1)
        lengths[#lengths + 1] = len
        total = total + len
        cumulative[#cumulative + 1] = total
    end
    edge.segmentLengths = lengths
    edge.segmentCumulative = cumulative
end

-- finds midpoint and direction of an edge
local function getMidpointOfLine(nodes, edge)
    local totalLength = edge.length
    local midpointDist = totalLength / 2
    local currentDist = 0
    local midX, midY, nx, ny
    local line = edge.line
    for i = 1, #line - 2, 2 do
        local x1, y1 = line[i], line[i + 1]
        local x2, y2 = line[i + 2], line[i + 3]
        local segmentLength = getLength(x2 - x1, y2 - y1)
        if currentDist + segmentLength >= midpointDist then
            local remainingDist = midpointDist - currentDist
            local t = remainingDist / segmentLength
            midX = x1 + t * (x2 - x1)
            midY = y1 + t * (y2 - y1)
            local dx = x2 - x1
            local dy = y2 - y1
            local len = getLength(dx, dy)
            nx = len > 0 and dx / len or 0
            ny = len > 0 and dy / len or 0
            break
        end
        currentDist = currentDist + segmentLength
    end
    return midX or line[1], midY or line[2], nx or 0, ny or 0
end

-- generates arrow coordinates for edge direction
local function getArrowLine(nodes, edge)
    local midX, midY, nx, ny = getMidpointOfLine(nodes, edge)
    local arrowSize = 10
    local arrowAngle = math.pi / 6
    local x2 = midX + 0.5 * arrowSize * nx
    local y2 = midY + 0.5 * arrowSize * ny
    local x1 = x2 - arrowSize * (nx * math.cos(arrowAngle) - ny * math.sin(arrowAngle))
    local y1 = y2 - arrowSize * (ny * math.cos(arrowAngle) + nx * math.sin(arrowAngle))
    local x3 = x2 - arrowSize * (nx * math.cos(-arrowAngle) - ny * math.sin(-arrowAngle))
    local y3 = y2 - arrowSize * (ny * math.cos(-arrowAngle) + nx * math.sin(-arrowAngle))
    return {x1, y1, x2, y2, x3, y3}
end

-- gets interpolated position on an edge for a given lane and progress
function diagram.getLanePosition(edge, lane, targetLane, laneChangeProgress, t)
    local laneLine = edge.laneLines and edge.laneLines[lane] or edge.line
    if not laneLine or #laneLine < 2 then
        return edge.line[1] or 0, edge.line[2] or 0
    end
    local targetLaneLine = targetLane and edge.laneLines and edge.laneLines[targetLane] or laneLine
    local numSegments = math.max(1, math.floor((#laneLine - 2) / 2))
    local segmentLength = edge.length / numSegments
    local segmentIndex = math.floor(t * numSegments)
    local segmentT = (t * numSegments) - segmentIndex
    segmentIndex = math.max(0, math.min(segmentIndex, numSegments - 1))
    local i = segmentIndex * 2 + 1
    local x1, y1 = laneLine[i], laneLine[i + 1]
    local x2, y2 = laneLine[i + 2] or x1, laneLine[i + 3] or y1
    local tx1, ty1 = targetLaneLine[i] or x1, targetLaneLine[i + 1] or y1
    local tx2, ty2 = targetLaneLine[i + 2] or tx1, targetLaneLine[i + 3] or ty1
    local x = x1 + (x2 - x1) * segmentT
    local y = y1 + (y2 - y1) * segmentT
    local tx = tx1 + (tx2 - tx1) * segmentT
    local ty = ty1 + (ty2 - ty1) * segmentT
    if targetLane and laneChangeProgress > 0 and lane ~= targetLane then
        x = x + (tx - x) * laneChangeProgress
        y = y + (ty - y) * laneChangeProgress
    end
    return x, y
end

-- initializes nodes and edges with precomputed properties
function diagram.initialize(newNodes, newEdges)
    diagram.nodes = newNodes
    diagram.edges = newEdges
    for _, node in pairs(diagram.nodes) do
        if node.x and node.y then
            node.x = math.floor(node.x + 0.5)
            node.y = math.floor(node.y + 0.5)
        else
            print("warning: node " .. (node.id or "unknown") .. " has missing x or y, setting to 0")
            node.x = node.x or 0
            node.y = node.y or 0
        end
        node.nextEdges = node.nextEdges or {}
        node.prevEdges = node.prevEdges or {}
    end
    for _, edge in pairs(diagram.edges) do
        edge.startNode = diagram.nodes[edge.nodeIndices[1]]
        edge.endNode = diagram.nodes[edge.nodeIndices[#edge.nodeIndices]]
        edge.line = getEdgeLine(diagram.nodes, edge)
        computeSegmentLengths(edge)
        edge.length = getEdgeLength(diagram.nodes, edge)
        edge.arrow = getArrowLine(diagram.nodes, edge)
        edge.lanes = edge.lanes or assignRandomLanes(edge)
        if edge.lanes < 1 or edge.lanes > 3 then
            print("warning: edge " .. edge.id .. " has invalid lanes (" .. edge.lanes .. "), setting to 2")
            edge.lanes = 2
        end
        table.insert(edge.startNode.nextEdges, edge)
        table.insert(edge.endNode.prevEdges, edge)

        -- calculate lane lines with vertex-based normals
        edge.laneLines = edge.laneLines or {}
        for lane = 1, edge.lanes do
            local offset = (lane - (edge.lanes + 1) / 2) * laneWidth
            local laneLine = {}
            local vertices = {}
            local normals = {}

            -- collect unique vertices from edge.line
            for i = 1, #edge.line, 2 do
                table.insert(vertices, {x = edge.line[i], y = edge.line[i + 1]})
            end

            -- calculate segment normals
            for i = 1, #vertices - 1 do
                local x1, y1 = vertices[i].x, vertices[i].y
                local x2, y2 = vertices[i + 1].x, vertices[i + 1].y
                local dx = x2 - x1
                local dy = y2 - y1
                local len = math.sqrt(dx * dx + dy * dy)
                if len > 0 then
                    local nx = -dy / len
                    local ny = dx / len
                    table.insert(normals, {nx = nx, ny = ny})
                else
                    table.insert(normals, normals[#normals] or {nx = 0, ny = 0})
                end
            end

            -- average normals at vertices
            local vertexNormals = {}
            for i = 1, #vertices do
                if i == 1 then
                    vertexNormals[1] = normals[1] or {nx = 0, ny = 0}
                elseif i == #vertices then
                    vertexNormals[i] = normals[#normals] or {nx = 0, ny = 0}
                else
                    local prev = normals[i - 1] or {nx = 0, ny = 0}
                    local next = normals[i] or {nx = 0, ny = 0}
                    local nx = (prev.nx + next.nx) / 2
                    local ny = (prev.ny + next.ny) / 2
                    local len = math.sqrt(nx * nx + ny * ny)
                    if len > 0 then
                        nx = nx / len
                        ny = ny / len
                    else
                        nx, ny = 0, 0
                    end
                    vertexNormals[i] = {nx = nx, ny = ny}
                end
            end

            -- generate laneLine using vertex normals
            for i = 1, #vertices do
                local x, y = vertices[i].x, vertices[i].y
                local n = vertexNormals[i]
                table.insert(laneLine, x + n.nx * offset)
                table.insert(laneLine, y + n.ny * offset)
            end

            -- clean duplicates in laneLine
            local cleanedLaneLine = {laneLine[1], laneLine[2]}
            for i = 3, #laneLine, 2 do
                if laneLine[i] ~= laneLine[i-2] or laneLine[i+1] ~= laneLine[i-1] then
                    table.insert(cleanedLaneLine, laneLine[i])
                    table.insert(cleanedLaneLine, laneLine[i+1])
                end
            end
            edge.laneLines[lane] = cleanedLaneLine
        end
    end
end

-- draws graph edges, lanes, arrows, and nodes
function diagram.draw()
    local laneWidth2 = 6
    for _, edge in pairs(diagram.edges) do
        local avgSpeed = edge.avgSpeed or 60
        local lanes = edge.lanes or 2
        local width1 = 2 + laneWidth * lanes
        local fillColor, outlineColor
        for _, speed in ipairs(speedThresholds) do
            if avgSpeed > speed.threshold then
                fillColor = speed.fillColor
                outlineColor = speed.outlineColor
                break
            end
        end
        love.graphics.setColor(outlineColor)
        love.graphics.setLineWidth(width1)
        love.graphics.line(edge.line)
    end

    for _, edge in pairs(diagram.edges) do
        local avgSpeed = edge.avgSpeed or 60
        local lanes = edge.lanes or 2
        local fillColor
        for _, speed in ipairs(speedThresholds) do
            if avgSpeed > speed.threshold then
                fillColor = speed.fillColor
                break
            end
        end
        love.graphics.setColor(fillColor)
        love.graphics.setLineWidth(laneWidth2)
        for lane = 1, lanes do
            local laneLine = edge.laneLines[lane]
            if laneLine and #laneLine >= 4 then
                love.graphics.line(laneLine)
            end
        end
    end

    for _, edge in pairs(diagram.edges) do
        if edge.arrow then
            love.graphics.setColor(0, 0, 0)
            love.graphics.setLineWidth(2)
            love.graphics.line(edge.arrow)
        end
    end

    love.graphics.setColor(0.2, 0.4, 0.9)
    love.graphics.setLineWidth(2)
    for _, node in pairs(diagram.nodes) do
        if node.nextEdges then
            love.graphics.circle("fill", node.x, node.y, 5)
        end
        if node.prevEdges then
            love.graphics.circle("line", node.x, node.y, 3)
        end
    end
    for _, node in pairs(diagram.nodes) do
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", node.x, node.y, 2)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(tostring(node.id), node.x + 6, node.y - 3)
        love.graphics.print(tostring(node.id), node.x + 8, node.y - 3)
        love.graphics.print(tostring(node.id), node.x + 6, node.y - 1)
        love.graphics.print(tostring(node.id), node.x + 8, node.y - 1)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(tostring(node.id), node.x + 7, node.y - 2)
    end
end

return diagram