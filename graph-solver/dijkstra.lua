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

	local k = 0
	while #queue > 0 and k<1000 do
		table.sort(queue, compare_cost) -- last in first out
		local c = take_last (queue)
		n_node = c.to
		local from_node, to_node = nodes[c.from], nodes[c.to]
		local summ = from_node.cost + c.cost -- old node cost plus cost of connection
		local bool = true
		if not to_node then
--			print ('added', 'from '..c.from..' cost:'..from_node.cost, 'to: '..c.to..' cost: '..summ) 
			nodes[c.to] = {cost = summ, 
				str_nodes=from_node.str_nodes..'-'..n_node,
				str_cons=from_node.str_cons and from_node.str_cons..'-'..c.index or c.index,
				}
		elseif to_node.cost > summ then
--			print ('changed', 'from '..c.from..' cost:'..from_node.cost,
--				'to: '..c.to..' cost: '..summ..' (was:'..to_node.cost..')') 
			to_node.cost = summ
		else
			bool = false
		end
		if bool then
			add_nodes_to_queue(queue, graph, n_node)
		end
		k=k+1
	end
--	print ('k',k)
	local e = nodes[end_node] -- end node
	if e then
		local n_cons = strsplit (e.str_cons, "-") -- table with numbers of all connections
		if n_cons and #n_cons >0 then
			local lines = {}
			for i, n_con in ipairs (n_cons) do
				local c = graph[n_con]
				if c then
					table.insert(lines, c.line)
				else
--					print ('no n_con', n_con)
				end
			end
			return lines
		else
--			print ('no n_cons')
			return {}
		end
	else
--		print ('no lines')
		return {}
	end
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


return dijkstra