-- diagram.lua
-- manages graph structure, pathfinding, and visualization
-- used by main.lua for initialization and drawing, points.lua for pathfinding

local diagram = {}

-- calculates Euclidean distance between two points
-- used in getEdgeLength, computeSegmentLengths, getMidpointOfLine
local function getLength(dx, dy)
	return math.sqrt(dx * dx + dy * dy)
end

-- generates line coordinates for an edge
-- used in initialize to set edge.line
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

-- calculates total length of an edge
-- used in initialize to set edge.length
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
-- used in initialize to set edge.segmentLengths and edge.segmentCumulative
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

-- finds midpoint and direction of an edge
-- used in getArrowLine to position arrows
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

-- generates arrow coordinates for edge direction
-- used in initialize to set edge.arrow
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

-- initializes nodes and edges with precomputed properties
-- called by main.lua in love.load
function diagram.initialize(newNodes, newEdges)
	diagram.nodes = newNodes
	diagram.edges = newEdges
	for _, node in pairs(diagram.nodes) do
		node.x = math.floor(node.x + 0.5)
		node.y = math.floor(node.y + 0.5)
	end
	for _, edge in pairs(diagram.edges) do
		edge.startNode = diagram.nodes[edge.nodeIndices[1]]
		edge.endNode = diagram.nodes[edge.nodeIndices[#edge.nodeIndices]]
		edge.line = getEdgeLine(diagram.nodes, edge)
		computeSegmentLengths(edge)
		edge.length = getEdgeLength(diagram.nodes, edge)
		edge.arrow = getArrowLine(diagram.nodes, edge)
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

-- draws graph edges, arrows, and nodes
-- called by main.lua in love.draw
function diagram.draw()
	for _, edge in pairs(diagram.edges) do
		love.graphics.setColor(0.2, 0.2, 0.2)
		love.graphics.setLineWidth(2)
		love.graphics.line(edge.line)
		if edge.arrow then
			love.graphics.setColor(1, 0, 0)
			love.graphics.line(edge.arrow)
		end
	end
	love.graphics.setColor(0.2, 0.4, 0.9)
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