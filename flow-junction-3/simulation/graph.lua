-- simulation/graph.lua
-- builds intersection graph from map ways
-- uses array index as way key to avoid duplicate-id collisions

local M = {}

local graph = {
	nodes    = {},
	edges    = {},
	adj      = {},
	inNodes  = {},
	outNodes = {},
}

local function isValidWay(way)
	return type(way) == "table"
		and way.nodeRefs
		and type(way.nodeRefs) == "table"
		and #way.nodeRefs >= 2
end

function M.build(map)
	graph.nodes    = map.nodes
	graph.edges    = {}
	graph.adj      = {}
	graph.inNodes  = {}
	graph.outNodes = {}

	local function addEdge(from, to, wayIdx)
		graph.adj[from] = graph.adj[from] or {}
		table.insert(graph.adj[from], { to = to, wayIdx = wayIdx })
	end

	for idx, way in ipairs(map.ways or {}) do
		if isValidWay(way) then
			local refs = way.nodeRefs
			local from = refs[1]
			local to   = refs[#refs]

			graph.edges[#graph.edges + 1] = {
				from   = from,
				to     = to,
				wayIdx = idx,   -- array index, always unique
			}
			addEdge(from, to, idx)

			local t = way.tags and way.tags.type
			if t == "in" then
				graph.inNodes[from] = true
			elseif t == "out" then
				graph.outNodes[to] = true
			end
		end
	end
end

function M.getGraph()
	return graph
end

function M.getNodes()
	return graph.nodes or {}
end

function M.getEdges()
	return graph.edges or {}
end

function M.getInNodes()
	return graph.inNodes or {}
end

function M.getOutNodes()
	return graph.outNodes or {}
end

return M