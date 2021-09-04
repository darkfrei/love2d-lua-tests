-- (c) darkfrei, 2021
-- graph solver

local gs = {}

function is_point_in_list (x, y, list)
	for i = 1, #list-1, 2 do
		if x == list[i] and y == list[i+1] then
			return true
		end
	end
	return false
end

function get_starting_ending_lines (lines, x, y)
	local lines_from_node = {}
	local lines_to_node = {}
	for i, line in pairs (lines) do
		if line[1]==x and line[2]==y then
			table.insert (lines_from_node, line)
		end
		if line[#line-1]==x and line[#line]==y then
			table.insert (lines_to_node, line)
		end
	end
	return lines_from_node, lines_to_node
end

function deep_process_path_lines (lines, path_lines)
	local line = path_lines[#path_lines]
	local x, y = line[#line-1], line[#line] -- last
	local lines_from_node, lines_to_node = get_starting_ending_lines (lines, x, y)
	local amount_from, amount_to = #lines_from_node, #lines_to_node
	if (amount_to == 1) and (amount_from == 1) then
		table.insert (path_lines, lines_from_node[1])
		deep_process_path_lines (lines, path_lines)
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

function get_arrow_line (line)
	local arrow_lines = {}
	local l, w = 12, 3 -- arrow lenght, width
	local x1, y1, x2, y2 = line[#line-3],line[#line-2],line[#line-1],line[#line]
	local vx, vy = normul (x2-x1, y2-y1, 1)
--	local x, y = (x1+x2)/2, (y1+y2)/2
	local x, y = x2-2*l*vx, y2-2*l*vy
	
	local arrow_line = {x-l*vx-vy*w, y-l*vy+vx*w, x+l*vx, y+l*vy, x-l*vx+vy*w, y-l*vy-vx*w}
	local x_text, y_text = 0.75*x1+0.25*x2, 0.75*y1+0.25*y2
	x_text, y_text = math.floor(x_text-l*vx-vy*w), math.floor(y_text-l*vy+vx*w)
	local text_angle = math.atan2(vy, vx)
	return arrow_line, x_text, y_text, text_angle
end

function process_new_paths (lines, line)
	local path = {}
	path.line = line
	path.length = math.floor(get_line_length (line)+0.5)
	path.x1, path.y1 = line[1], line[2]
	path.x2, path.y2 = line[#line-1], line[#line]
	path.color = {0.5+0.5*math.random(),0.5+0.5*math.random(),0.5+0.5*math.random()}
	path.arrow_line, path.x_text, path.y_text, path.text_angle = get_arrow_line (path.line)
	return path
end

function get_next_paths (paths, x, y)
	local list = {}
	for path_index, path in pairs (paths) do
		if x == path.x1 and y == path.y1 then
			table.insert(list, path_index)
		end
	end
	if #list >0 then return list end
end

function get_prev_paths (paths, x, y)
	local list = {}
	for path_index, path in pairs (paths) do
		if x == path.x2 and y == path.y2 then
			table.insert(list, path_index)
		end
	end
	if #list >0 then return list end
end

function get_node_number (nodes, x, y)
	for i = 1, #nodes-1, 2 do
		if nodes[i]==x and nodes[i+1]==y then
--			return math.floor((i-1)/2+1) -- converts 1, 3, 5, 7 to 1, 2, 3, 4
			return math.floor((i+1)/2) -- converts 1, 3, 5, 7 to 1, 2, 3, 4
		end
	end
end

---------------------------------------------------------------------

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

function gs.create_paths (lines, nodes) -- lines is as array of lines
	local paths = {} -- path is a holder for path line

	for i, line in pairs (lines) do
		paths[#paths+1] = process_new_paths (lines, line)
	end
	
	for index, path in pairs (paths) do
		path.index = index
		path.n1_node = get_node_number (nodes, path.x1, path.y1)
		path.n2_node = get_node_number (nodes, path.x2, path.y2)
		path.next_paths = get_next_paths (paths, path.x2, path.y2)
		path.prev_paths = get_prev_paths (paths, path.x1, path.y1)
	end
	return paths
end

---------------------------------------------------------------------

function get_starting_paths (paths, x, y)
	local paths_from_node = {}
	for i, path in pairs (paths) do
		if path.x1==x and path.y1==y then
			table.insert (paths_from_node, path)
		end
	end
	return paths_from_node
end



function deep_tracing (sh_paths, paths, ps)
	for i, p in pairs (ps) do
		local x2, y2 = p.x2, p.y2
		get_starting_paths (paths, x2, y2)
	end
end

function get_node_value (x, y, nodes)
	for i = 1, #nodes-2, 3 do
		if nodes[i] == x and nodes[i+1] == y then
			return nodes[i+2]
		end
	end
end

function set_node_value (x, y, nodes, value)
	for i = 1, #nodes-2, 3 do
		if nodes[i] == x and nodes[i+1] == y then
			nodes[i+2] = value
		end
	end
end

function gs.get_trace (paths, x1, y1, x2, y2) -- paths, source, target
	local ps = get_starting_paths (paths, x1, y1) -- paths from start
	
	
	local sh_paths = {} -- shortest paths
	
	local value = 0
	local nodes = {x1, y1, value}
	
	for i, p in pairs (ps) do
		local x, y= p.x2, y2
		local value2 = get_node_value (x, y, nodes)
		if not value2 then
			set_node_value (x, y, nodes, value+p.length)
		elseif value+p.length < value2 then
			set_node_value (x, y, nodes, value+p.length)
		end
	end
	
	
	local line = {}
	if #sh_paths>0 then
		-- copy first point
		line[1], line[2] = sh_paths[1].line[1], sh_paths[1].line[2]
		for i, path in pairs (sh_paths) do
			local path_line = path.line
			for j = 3, #path_line do -- copy all points except first
				table.insert (line, path_line[j])
			end
		end
	end
	
	return line
end


return gs