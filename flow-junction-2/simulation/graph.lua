-- simulation/graph.lua
-- builds intersection graph from map (debug version, no goto)

local M = {}

local graph = {
	nodes = {},
	edges = {},
	wayMap = {},
	outWays = {},
	inWays = {}
}

-- helpers

local function isValidWay(way)
	return type(way) == "table"
	and way.nodeRefs
	and type(way.nodeRefs) == "table"
	and #way.nodeRefs >= 2
end

local function logSkip(i, reason, way)
	print("[graph] skipped way", i, "| reason:", reason, "| id:", way and way.id)
end

-- build

function M.build(map)

-- debug ways count
-- prints full way inspection for debugging

	graph.nodes  = map.nodes
	graph.edges  = {}
	graph.adj    = {}
	graph.inNodes  = {}
	graph.outNodes = {}

	local function add(a, b, wayId)
		graph.adj[a] = graph.adj[a] or {}
		table.insert(graph.adj[a], { to = b, wayId = wayId })
	end

	for _, way in ipairs(map.ways or {}) do
		local refs = way.nodeRefs
		if refs and #refs >= 2 then
			local from = refs[1]
			local to   = refs[#refs]

			graph.edges[#graph.edges + 1] = {
				from  = from,
				to    = to,
				wayId = way.id
			}
			add(from, to, way.id)

			-- mark entry nodes and exit nodes by type tag
			local t = way.tags and way.tags.type
			if t == "in" then
				graph.inNodes[from] = true -- first node is spawn point
			elseif t == "out" then
				graph.outNodes[to] = true -- last node is exit point
			end
		end
	end
end

-- api

function M.getGraph()
	return graph
end

function M.getNodes()
	return graph.nodes or {}
end

function M.getWay(wayId)
	return graph.wayMap[wayId]
end

function M.getOutgoing(nodeId)
	return graph.outWays[nodeId] or {}
end

function M.getIncoming(nodeId)
	return graph.inWays[nodeId] or {}
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