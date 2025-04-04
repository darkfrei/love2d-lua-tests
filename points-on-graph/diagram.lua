-- diagram.lua

-- internal data storage for nodes and edges
local nodes = {}
local edges = {}

-- initialize the diagram with nodes and edges
local function initialize(newNodes, newEdges)
	-- store the nodes and edges locally
	nodes = newNodes
	edges = newEdges

	-- round the coordinates of nodes to the nearest integer
	for _, node in pairs(nodes) do
		node.x = math.floor(node.x + 0.5)
		node.y = math.floor(node.y + 0.5)
		node.neighbors = {} -- initialize neighbors table for each node
	end

	-- calculate edge lengths and build neighbor relationships
	for _, edge in pairs(edges) do
		local totalLength = 0
		edge.segments = {} -- store segments of the polyline edge
		edge.line = {} -- store the line coordinates for drawing

		-- iterate through all node pairs in the edge to calculate its length and build the line
		for i = 1, #edge.nodes - 1 do
			local node1Id = edge.nodes[i]
			local node2Id = edge.nodes[i + 1]
			local node1 = nodes[node1Id]
			local node2 = nodes[node2Id]
			local segmentLength = math.sqrt((node1.x - node2.x)^2 + (node1.y - node2.y)^2)

			-- store segment information
			table.insert(edge.segments, {
					from = node1Id,
					to = node2Id,
					length = segmentLength
				})

			-- accumulate total length
			totalLength = totalLength + segmentLength

			-- add coordinates to the line
			if i == 1 then
				table.insert(edge.line, node1.x)
				table.insert(edge.line, node1.y)
			end
			table.insert(edge.line, node2.x)
			table.insert(edge.line, node2.y)

			-- build neighbor relationships
			table.insert(nodes[node1Id].neighbors, {id = node2Id, length = segmentLength, edgeId = edge.id})
			table.insert(nodes[node2Id].neighbors, {id = node1Id, length = segmentLength, edgeId = edge.id})
		end

		-- store total length and dynamic cost
		edge.length = totalLength
		edge.dynamicCost = 0

		-- calculate the midpoint of the edge for labeling
		local firstNode = nodes[edge.nodes[1]]
		local lastNode = nodes[edge.nodes[#edge.nodes]]
		edge.x = (firstNode.x + lastNode.x) / 2
		edge.y = (firstNode.y + lastNode.y) / 2
	end
end

-- get all nodes
local function getNodes()
	return nodes
end

-- get all edges
local function getEdges()
	return edges
end

-- get a specific node by id
local function getNodeById(id)
	return nodes[id]
end

-- get a specific edge by id
local function getEdgeById(id)
	return edges[id]
end

-- get neighbors of a specific node
local function getNeighbors(nodeId)
	local node = nodes[nodeId]
	if not node then
		error("Node with id " .. nodeId .. " not found!")
	end
	return node.neighbors
end

-- calculate the distance between two nodes
local function calculateDistance(node1, node2)
	return math.sqrt((node1.x - node2.x)^2 + (node1.y - node2.y)^2)
end

-- check if an edge exists between two nodes
local function edgeExists(node1Id, node2Id)
	local node1 = nodes[node1Id]
	if not node1 then
		return false
	end
	for _, neighbor in ipairs(node1.neighbors) do
		if neighbor.id == node2Id then
			return true
		end
	end
	return false
end

-- draw the diagram (edges, nodes, and labels)
local function draw()
	-- draw edges
	love.graphics.setColor(0.2, 0.2, 0.2) -- dark gray color for edges
	love.graphics.setLineWidth(2)
	for _, edge in pairs(edges) do
		love.graphics.line(edge.line)
	end

	-- draw nodes
	love.graphics.setColor(0.2, 0.4, 0.9) -- blue color for nodes
	for _, node in pairs(nodes) do
		love.graphics.circle("fill", node.x, node.y, 5) -- radius of the circle
	end

	-- add labels to nodes
	love.graphics.setColor(0, 0, 0) -- black color for text
	for _, node in pairs(nodes) do
		love.graphics.print(tostring(node.id), node.x + 7, node.y - 2)
	end

	-- add labels to edges
	for _, edge in pairs(edges) do
		love.graphics.print(tostring(edge.dynamicCost), edge.x + 7, edge.y - 2)
	end
end

-- export the API
return {
	initialize = initialize,
	getNodes = getNodes,
	getEdges = getEdges,
	getNodeById = getNodeById,
	getEdgeById = getEdgeById,
	getNeighbors = getNeighbors,
	calculateDistance = calculateDistance,
	edgeExists = edgeExists,
	draw = draw,
}