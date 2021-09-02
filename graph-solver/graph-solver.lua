-- (c) darkfrei, 2021
-- graph solver

local gs = {}

--function get_lines_from_node (lines, x, y)
--	local lines_from_node = {}
--	for i, line in pairs (lines) do
--		if line[1]==x and line[2]==y then
--			table.insert (lines_from_node, line)
--		end
--	end
--	return lines_from_node
--end

--function get_lines_to_node (lines, x, y)
--	local lines_to_node = {}
--	for i, line in pairs (lines) do
--		if line[#line-1]==x and line[#line]==y then
--			table.insert (lines_to_node, line)
--		end
--	end
--	return lines_to_node
--end

--function is_starting_node (node)
--	if 	(node.starting == 1 and node.ending == 0)
--	or 	(node.starting >= 1 and node.ending > 1)
--	or 	(node.starting > 1) then
--		return true
--	else return false end
--end

function is_point_in_list (x, y, list)
	for i = 1, #list-1, 2 do
		if x == list[i] and y == list[i+1] then
			return true
		end
	end
	return false
end


function get_starting_ending_lines (lines, x, y)
--	print ('lines 10: '..#lines)
	local lines_from_node = {}
	local lines_to_node = {}
	for i, line in pairs (lines) do
--		print ('line 20: '..#line)
--		print ('line 30: '..#line[1])
--		print ('x and y', line[1], x, line[2], y)
		if line[1]==x and line[2]==y then
			table.insert (lines_from_node, line)
		end
		if line[#line-1]==x and line[#line]==y then
			table.insert (lines_to_node, line)
		end
	end
	return lines_from_node, lines_to_node
end

function deep_process_road_lines (lines, road_lines)
	local line = road_lines[#road_lines]
	local x, y = line[#line-1], line[#line] -- last
	local lines_from_node, lines_to_node = get_starting_ending_lines (lines, x, y)
	local amount_from, amount_to = #lines_from_node, #lines_to_node
	if (amount_to == 1) and (amount_from == 1) then
		table.insert (road_lines, lines_from_node[1])
		deep_process_road_lines (lines, road_lines)
	end
end

function get_length (x1,y1, x2,y2)
	return ((x2-x1)^2+(y2-y1)^2)^0.5
end

function get_line_length (line)
	local length = 0
	for i = 1, #line-3, 2 do
		length = length + get_length (line[i],line[i+1],line[i+2],line[i+3])
	end
	return length
end

function get_lines_length (lines)
	local length = 0
	for i, line in pairs (lines) do
		length = length + get_line_length (line)
	end
	return length
end

function get_first_and_last_point_of_lines (lines)
	local x1, y1 = lines[1][1], lines[1][2]
	local line = lines[#lines] -- last line
	local x2, y2 = line[#line-1], line[#line]
	return x1, y1, x2, y2
end

function process_new_roads (roads, lines, x, y)
	local lines_from_node, lines_to_node = get_starting_ending_lines (lines, x, y)
	local amount_from, amount_to = #lines_from_node, #lines_to_node
--	print('amount_from: '..amount_from, amount_to..' amount_to: '..amount_to)
	if (amount_to == 0) or (amount_to > 1)or (amount_from > 1) then
		for i, line in pairs (lines_from_node) do
			local road_lines = {line}
			deep_process_road_lines (lines, road_lines)
			local road = {lines = road_lines}
			road.length = get_lines_length (road.lines)
			
			road.x1, road.y1, road.x2, road.y2 = get_first_and_last_point_of_lines (road.lines)
			table.insert(roads, road)
		end
	end
end

function get_next_roads (roads, x, y)
	local list = {}
	for road_index, road in pairs (roads) do
--		print ('next: ', x, road.x1, y, road.y1)
		if x == road.x1 and y == road.y1 then
--			print ('next: '..road_index)
			table.insert(list, road_index)
		end
	end
	if #list >0 then return list end
end

function get_prev_roads (roads, x, y)
	local list = {}
	for road_index, road in pairs (roads) do
		if x == road.x2 and y == road.y2 then
--			print ('prev: '..road_index)
			table.insert(list, road_index)
		end
	end
	if #list >0 then return list end
end


function gs.create_nodes (lines) -- lines is as array of lines
	local nodes = {} -- all line nodes, as points
	for i, line in pairs (lines) do
		-- first and last poits in line
		local x1, y1 = line[1], line[2]
		
		if not is_point_in_list (x1, y1, nodes) then
			table.insert (nodes, x1) table.insert (nodes, y1)
		end
		local x2, y2 = line[#line-1], line[#line]
		if not is_point_in_list (x2, y2, nodes) then
			table.insert (nodes, x2) table.insert (nodes, y2)
		end
	end
	return nodes
end

function get_arrow (lines)
	local arrow_lines = {}
	local l, w = 8, 6
	for i, line in pairs (lines) do
		local x1, y1, x2, y2 = line[#line-3],line[#line-2],line[#line-1],line[#line]
		
		local vx, vy = normul (x2-x1, y2-y1, 1)
		local x, y = (x1+x2)/2, (y1+y2)/2
		local arrow_line = {x-l*vx-vy*w, y-l*vy+vx*w, x+l*vx, y+l*vy, x-l*vx+vy*w, y-l*vy-vx*w}
		arrow_lines[i] = arrow_line
	end
	return arrow_lines
end

function gs.create_roads (lines) -- lines is as array of lines
	local nodes = {} -- all line nodes, as points
	for i, line in pairs (lines) do
		-- first and last poits in line
		local x1, y1, x2, y2 = line[1], line[2], line[#line-1], line[#line]
		if not is_point_in_list (x1, y1, nodes) then
			table.insert (nodes, x1) table.insert (nodes, y1)
		end
		if not is_point_in_list (x2, y2, nodes) then
			table.insert (nodes, x2) table.insert (nodes, y2)
		end
	end
	
	local roads = {} -- the serie of connected lines
	for i = 1, #nodes-1, 2 do
		local x, y = nodes[i], nodes[i+1]
		process_new_roads (roads, lines, x, y)
	end
	for index, road in pairs (roads) do
--		print ('road index: '..index)
		road.index = index
		road.next_roads = get_next_roads (roads, road.x2, road.y2)
		road.prev_roads = get_prev_roads (roads, road.x1, road.y1)
		road.color = {0.5+0.5*math.random(),0.5+0.5*math.random(),0.5+0.5*math.random(), 0.8}
		road.arrow_lines = get_arrow (road.lines)
	end
	
	
--	return nodes
	return roads
end


return gs