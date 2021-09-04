-- (c) darkfrei, 2021
-- dijkstra algorithm
-- for graph solver


function compare3(a,b)
  return a[3] < b[3]
end

function dijkstra (graph, nodes, n_node)
	local queue = {}
	for i, c in pairs (graph) do -- c is connection: from, to, cost
		if c[1] == n_node then
			table.insert (queue, c)
		end
	end

	while #queue > 0 do
		table.sort(queue, compare3)
		local c = queue[1]
		table.remove(queue, 1)
		local summ = nodes[c[1]] + c[3]
		n_node = c[2]
		if not (nodes[n_node] and nodes[n_node] <= summ) then
			nodes[n_node] = summ
			print ('dijkstra', 'c: '..c[1]..'-'..c[2], 'summ: '..summ)
		end
		for i, c in pairs (graph) do -- c is connection: from, to, cost
			if c[1] == n_node then
				table.insert (queue, c)
			end
		end
	end
end

-----------------------------------------------------------
-- example: 
local graph = {
	{1, 5, 12}, -- node from, node to, cost
	{1, 2, 7},
	{1, 3, 9},
	{2, 3, 10},
	{2, 4, 15},
	{3, 4, 11},
	{4, 6, 6},
	{3, 5, 2},
	{5, 6, 9},
}

local nodes = {}
local n_node = 1 -- number of starting node
nodes[n_node] = 0 -- cost of starting node

dijkstra (graph, nodes, n_node)

for i, v in pairs (nodes) do
	print ('example',i,v)
end
-- end of example
-----------------------------------------------------------

-------------------------------------------------------------
---- example 2: 
--local graph2 = require ('oriented-graph')

--local nodes2 = {}
--local n_node2 = 1 -- number of starting node
--nodes2[n_node] = 0 -- cost of starting node

--dijkstra (graph2, nodes2, n_node2)
--for i, v in pairs (nodes2) do
--	print ('example 2',i,v)
--end
---- end of example
-------------------------------------------------------------

return dijkstra