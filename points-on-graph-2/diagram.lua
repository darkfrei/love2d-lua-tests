local nodes = {}
local edges = {}

local function getLength(dx, dy)
	return math.sqrt(dx * dx + dy * dy)
end

local function getEdgeLine(nodes, edge)
	local line = {}
	for i, nodeIndex in ipairs(edge.nodeIndices) do
		local node = nodes[nodeIndex]
		table.insert(line, node.x)
		table.insert(line, node.y)
	end
	if #edge.nodeIndices == 2 then
		return line
	elseif #edge.nodeIndices == 3 then
		local curve = love.math.newBezierCurve(line)
		local line2 = {}
		local amount = 8 
		for i = 0, amount do
			local x, y = curve:evaluate(i / amount)
			table.insert(line2, x)
			table.insert(line2, y)
		end
		return line2
	end
	return line
end

local function getEdgeLength(nodes, edge)
	local length = 0
	local line = edge.line
	for i = 1, #line - 2, 2 do
		local x1, y1 = line[i], line[i + 1]
		local x2, y2 = line[i + 2], line[i + 3]
		local dl = getLength(x2 - x1, y2 - y1)
		length = length + dl
	end
	return length
end

local function computeSegmentLengths(edge)
	local line = edge.line
	local lengths = {}
	local total = 0
	local cumulative = {}

	for i = 1, #line - 2, 2 do
		local dx = line[i + 2] - line[i]
		local dy = line[i + 3] - line[i + 1]
		local len = getLength(dx, dy)
		lengths[#lengths + 1] = len
		total = total + len
		cumulative[#cumulative + 1] = total
	end

	edge.segmentLengths = lengths
	edge.segmentCumulative = cumulative
end

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
			nx = dx / len
			ny = dy / len
			break
		end
		currentDist = currentDist + segmentLength
	end

	return midX, midY, nx, ny
end

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

local function initialize(newNodes, newEdges)
	nodes = newNodes
	edges = newEdges

	for _, node in pairs(nodes) do
		node.x = math.floor(node.x + 0.5)
		node.y = math.floor(node.y + 0.5)
	end

	for _, edge in pairs(edges) do
		edge.startNode = nodes[edge.nodeIndices[1]]
		edge.endNode = nodes[edge.nodeIndices[#edge.nodeIndices]]
		edge.line = getEdgeLine(nodes, edge)
		computeSegmentLengths(edge)
		edge.length = getEdgeLength(nodes, edge)
		edge.arrow = getArrowLine(nodes, edge)

		if edge.startNode.nextEdges then
			table.insert(edge.startNode.nextEdges, edge)
		else
			edge.startNode.nextEdges = {edge}            
		end
		if edge.endNode.prevEdges then
			table.insert(edge.endNode.prevEdges, edge)
		else
			edge.endNode.prevEdges = {edge}
		end
	end
end

local function draw()
	for _, edge in pairs(edges) do
		love.graphics.setColor(0.2, 0.2, 0.2)
		love.graphics.setLineWidth(2)
		love.graphics.line(edge.line)
		if edge.arrow then
			love.graphics.setColor(1, 0, 0)
			love.graphics.line(edge.arrow)
		end
	end

	love.graphics.setColor(0.2, 0.4, 0.9)
	for _, node in pairs(nodes) do
		if node.nextEdges then
			love.graphics.circle("fill", node.x, node.y, 5)
		end
		if node.prevEdges then
			love.graphics.circle("line", node.x, node.y, 3)
		end
	end

	for _, node in pairs(nodes) do
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

local function findShortestPath(startId, endId)
	local distances = {}
	local previous = {}
	local unvisited = {}
	local congestionFactor = 50

	for _, node in pairs(nodes) do
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
			print("No path found to " .. endId)
			break
		end
		if currentId == endId then break end

		unvisited[currentId] = nil
		local currentNode = nodes[currentId]

		if currentNode.nextEdges then
			for _, edge in ipairs(currentNode.nextEdges) do
				local neighborId = edge.endNode.id
				if unvisited[neighborId] then
					local numPoints = edge.points and #edge.points or 0
					local congestionPenalty = numPoints * congestionFactor
					local alt = distances[currentId] + edge.length + congestionPenalty
--					print("Edge " .. currentId .. "->" .. neighborId .. ": length=" .. edge.length .. ", points=" .. numPoints .. ", penalty=" .. congestionPenalty .. ", total=" .. alt)
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

	if #path > 1 then
--		print("Path from " .. startId .. " to " .. endId .. ": " .. table.concat(path, " -> "))
	else
		print("No valid path from " .. startId .. " to " .. endId)
	end

	return path, distances[endId]
end

return {
	nodes = nodes, 
	edges = edges,
	initialize = initialize,
	draw = draw,
	findShortestPath = findShortestPath,
}