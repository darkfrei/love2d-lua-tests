-- simulation/routing.lua
-- Dijkstra over node graph; returns list of way array-indices

local Graph = require("simulation.graph")

local M = {}

function M.find(startNode, endNode)
	local g     = Graph.getGraph()
	local adj   = g.adj   or {}
	local nodes = Graph.getNodes()

	local dist    = {}
	local prev    = {}
	local visited = {}

	for id in pairs(nodes) do
		dist[id] = math.huge
	end
	dist[startNode] = 0

	for _ = 1, 10000 do
		-- pick unvisited node with minimum dist
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
				prev[edge.to] = { node = current, wayIdx = edge.wayIdx }
			end
		end
	end

	if not prev[endNode] then
		return {}
	end

	local route = {}
	local n = endNode
	while prev[n] do
		table.insert(route, 1, prev[n].wayIdx)
		n = prev[n].node
	end

	return route
end

return M