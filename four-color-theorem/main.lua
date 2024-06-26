-- 2024-04-20, darkfrei
-- license: use it as you want

-- Function to connect nodes in the graph
local function connect(nodes, node_index, ...)
	local neighbors = {...}
	for _, neighbor_index in ipairs(neighbors) do
		-- Add neighbor connections for both nodes
		table.insert(nodes[node_index].ns, neighbor_index)
		table.insert(nodes[neighbor_index].ns, node_index)
	end
end


------------------------------------------------------------

-- Function to check if it's safe to assign a color to a node
local function isSafe(node_index, color, nodes)
	local node = nodes[node_index]
	-- Check if any neighbor has the same color
	for _, neighbor_index in ipairs(node.ns) do
		local neighbor_color = nodes[neighbor_index].color
		if neighbor_color and neighbor_color[1] == color[1] and neighbor_color[2] == color[2] and neighbor_color[3] == color[3] then
			return false
		end
	end
	return true
end

-- Recursive function to color the map using the four color theorem
local function fourColorTheoremRecursive(node_index, colors, nodes)
	-- Base case: All nodes colored
	if node_index > #nodes then
		return true
	end

	-- Try assigning colors to the current node
	for _, color in ipairs(colors) do
		if isSafe(node_index, color, nodes) then
			nodes[node_index].color = color
			-- Recur to color the next node
			if fourColorTheoremRecursive(node_index + 1, colors, nodes) then
				return true  -- Solution found
			end
			nodes[node_index].color = nil  -- Backtrack
		end
	end

	return false  -- No solution found
end

-- Main function to initiate coloring
local function fourColorTheorem(nodes, colors)
	-- Start coloring from the first node
	return fourColorTheoremRecursive(1, colors, nodes)
end

------------------------------------------------------------

-- Love2D load function
function love.load()
	-- Define the graph nodes
	nodes = {
		{x=100, y=100, ns = {}}	,
		{x=200, y=100, ns = {}}	,
		{x=100, y=200, ns = {}}	,
		{x=200, y=200, ns = {}}	,
		{x=300, y=200, ns = {}}	,
		{x=300, y=100, ns = {}}	,
		{x=400, y=100, ns = {}}	, -- 7
		{x=400, y=200, ns = {}}	,
		{x=400, y=300, ns = {}}	,
		{x=300, y=300, ns = {}}	,
		{x=200, y=300, ns = {}}	,
		{x=100, y=300, ns = {}}	,
		{x=100, y=500, ns = {}}	,
		{x=200, y=400, ns = {}}	, -- 14
		{x=300, y=400, ns = {}}	, -- 15
		{x=400, y=500, ns = {}}	,
		{x=250, y=500, ns = {}}	,
	}

	-- Connect the nodes
	connect (nodes, 1, 2)
	connect (nodes, 2, 3, 4)
	connect (nodes, 3, 4, 1, 12)
	connect (nodes, 5, 2, 4)
	connect (nodes, 6, 2, 5, 7)
	connect (nodes, 8, 5, 6, 7, 9, 10)
	connect (nodes, 11, 12, 3, 4, 5, 10)
	connect (nodes, 10, 5, 9)
	connect (nodes, 13, 12, 14)
	connect (nodes, 14, 12, 11, 10, 15)
	connect (nodes, 15, 9, 10)
	connect (nodes, 16, 15, 9)
	connect (nodes, 17, 13, 14, 15, 16)

	-- Define colors for the theorem
	colors = {{1, 0, 0}, {1, 1, 0}, {0, 1, 0}, {0, 0, 1}}
	
	-- Apply the four color theorem
	fourColorTheorem(nodes, colors)

end


function love.update(dt)

end

function drawNodes (nodes)
	-- Draw connections between nodes
	love.graphics.setColor(1, 1, 0)
	for i, node in ipairs(nodes) do
		for _, neighbor_index in ipairs(node.ns) do
			local neighbor = nodes[neighbor_index]
			love.graphics.line(node.x, node.y, neighbor.x, neighbor.y)
		end
	end

	-- Draw nodes as circles
	for i, node in ipairs(nodes) do
		love.graphics.setColor(node.color)
		love.graphics.circle('fill', node.x, node.y, 6)
	end

	-- Draw node numbers
	for i, node in ipairs(nodes) do
		love.graphics.setColor(0, 0, 0, 0.5)
		love.graphics.rectangle('fill', node.x + 	8, node.y - 8, 18, 14)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(tostring(i), node.x + 8, node.y - 8)
	end
end

function love.draw()
	drawNodes (nodes)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end
