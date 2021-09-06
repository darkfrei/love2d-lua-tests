-- (c) darkfrei, 2021
-- dijkstra algorithm
-- for graph solver

--local serpent = require ('serpent')

function compare_cost(a,b)
	return a.cost > b.cost -- last is smaller
end

function add_nodes_to_queue(queue, graph, n_node)
	for i, c in pairs (graph) do -- c is connection: from, to, cost
		if c.from == n_node then
			table.insert (queue, c)
		end
	end
end

function take_last (tabl)
	local v = tabl[#tabl]
	table.remove(tabl, #tabl)
	return v
end

function dijkstra (graph, nodes, n_node, end_node)
	local queue = {}
	add_nodes_to_queue(queue, graph, n_node)

	while #queue > 0 do
		table.sort(queue, compare_cost) -- last in first out
		local c = take_last (queue)
		n_node = c.to
		local from_node, to_node = nodes[c.from], nodes[c.to]
		local summ = from_node.cost + c.cost -- old node cost plus cost of connection
		
		if not to_node then
--			if bool then 
				print ('added', 'from '..c.from..' cost:'..from_node.cost, 'to: '..c.to..' cost: '..summ) 
--			end
			nodes[c.to] = {cost = summ, 
				str_nodes=from_node.str_nodes..'-'..n_node,
				str_cons=from_node.str_cons and from_node.str_cons..'-'..c.index or c.index,
				}
		elseif to_node.cost > summ then
--			if bool then -- always not more than summ
				print ('changed', 'from '..c.from..' cost:'..from_node.cost,
				'to: '..c.to..' cost: '..summ..' (was:'..to_node.cost..')') 
--			end
			to_node.cost = summ
		end
		add_nodes_to_queue(queue, graph, n_node)
	end
--	for i, v in pairs (nodes) do
--		print (i, end_node)
--		if v.to == end_node then
--			return strsplit (v.str_cons, "-")
--		end
--	end
	local e = nodes[end_node] -- end node
--	print ('str_cons', e.str_cons)
	local n_cons = strsplit (e.str_cons, "-") -- table with numbers of all connections
	local lines = {}
	for i, n_con in ipairs (n_cons) do
--		for j, c in pairs (graph) do
--			print ('j',j)
--			print (tostring(n_con==j), n_con, j)
--			print (tostring(n_con==j), type(n_con), type(j))
--		end
--		print ('n_con',n_con)
		local c = graph[n_con]
		if c then
			
--			print (serpent.block(c))
--			print (i, serpent.block(c.line))
			table.insert(lines, c.line)
		else
			print ('no n_con', n_con)
		end
	end
	return lines
end

function strsplit (str, sep)
	if str then
		if sep == nil then sep = "%s" end
		local tabl={}
		for s in string.gmatch(str, "([^"..sep.."]+)") do
			table.insert(tabl, tonumber(s))
		end
		return tabl
	end
end

--[[
-----------------------------------------------------------
-- example: 
local graph = {
	{from=1, to=3, cost=9}, -- index node from, index node to, cost
	{from=1, to=5, cost=12},
	{from=1, to=2, cost=7},
	{from=2, to=3, cost=10},
	{from=2, to=4, cost=15},
	{from=3, to=4, cost=11},
	{from=4, to=6, cost=6},
	{from=3, to=5, cost=2},
	{from=5, to=6, cost=9},
}

local nodes = {}
local n_node = 1 -- index of starting node
nodes[n_node] = {cost=0, str_nodes=""..n_node} -- cost of starting node

-- optional
for index, c in pairs (graph) do
	if not c.index then c.index=index end
end

dijkstra (graph, nodes, n_node, true)

for i, v in pairs (nodes) do
	print ('node '..i,v.cost, 'nodes: '..v.str_nodes, 'connections: '.. tostring(v.str_cons))
	local tabl_nodes =strsplit (v.str_nodes, "-")
	local tabl_cons =strsplit (v.str_cons, "-")
	print ('tabl_nodes', table.concat(tabl_nodes, ", "))
	if tabl_cons then
		print ('tabl_cons', table.concat(tabl_cons, ", "))
	end
end

-- prints:
--	added	from 1 cost:0	to: 2 cost: 7
--	added	from 1 cost:0	to: 3 cost: 9
--	added	from 3 cost:9	to: 5 cost: 11
--	added	from 5 cost:11	to: 6 cost: 20
--	added	from 3 cost:9	to: 4 cost: 20
--	example	1	0
--	example	2	7
--	example	3	9
--	example	4	20
--	example	5	11
--	example	6	20

-- end of example
-----------------------------------------------------------
]]--

return dijkstra