-- simulation/routing.lua
-- shortest path over way graph fixed

local Graph = require("simulation.graph")

local M = {}

local function buildWayGraph()
	local g = Graph.getGraph()

	local adj = {}

	for _, e in ipairs(g.edges) do
		adj[e.wayId] = adj[e.wayId] or {}

		for _, e2 in ipairs(g.edges) do
			if e.to == e2.from then
				table.insert(adj[e.wayId], {
						to = e2.wayId,
						cost = 1
					})
			end
		end
	end

	return adj
end

function M.find(startNode, endNode)
	local g = Graph.getGraph()
	local adj = g.adj or {}
	local nodes = Graph.getNodes()

-- start node end node debug

	local dist  = {}
	local prev  = {}
	local visited = {}

	for id in pairs(nodes) do
		dist[id] = math.huge
	end
	dist[startNode] = 0

	for _ = 1, 10000 do
		-- find unvisited node with minimum distance
		local current, best = nil, math.huge
		for id in pairs(nodes) do
			if not visited[id] and dist[id] < best then
				best    = dist[id]
				current = id
			end
		end

		if not current then break end
		if current == endNode then break end

		visited[current] = true

		for _, edge in ipairs(adj[current] or {}) do
			local alt = dist[current] + 1
			if alt < (dist[edge.to] or math.huge) then
				dist[edge.to] = alt
				prev[edge.to] = { node = current, wayId = edge.wayId }
			end
		end
	end

	if not prev[endNode] then
-- no path found
		return {}
	end

	-- build route
	local route = {}
	local n = endNode
	while prev[n] do
		table.insert(route, 1, prev[n].wayId)
		n = prev[n].node
	end

-- route size debug
	return route
end

return M