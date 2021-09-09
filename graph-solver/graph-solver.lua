-- (c) darkfrei, 2021
-- graph solver

local gs = {}

--dijkstra
gs.dijkstra = require ('dijkstra')

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

--function get_lines_length (lines)
--	local length = 0
--	for i, line in pairs (lines) do
--		length = length + get_line_length (line)
--	end
--	return length
--end

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
	path.x1, path.y1 = line[1], line[2]
	path.x2, path.y2 = line[#line-1], line[#line]
	path.color = {0.5+0.5*math.random(),0.5+0.5*math.random(),0.5+0.5*math.random()}
	path.arrow_line, path.x_text, path.y_text, path.text_angle = get_arrow_line (path.line)
	return path
end


function get_node_number (node_points, x, y)
	for i = 1, #node_points-1, 2 do
		if node_points[i]==x and node_points[i+1]==y then
			return math.floor((i+1)/2) -- converts 1, 3, 5, 7 to 1, 2, 3, 4
		end
	end
	return 0
end

---------------------------------------------------------------------

function gs.create_node_points (lines) -- lines is as array of lines
	local node_points = {} -- all line node_points, as points
	for i, line in pairs (lines) do
		-- first and last poits in line
		local x1, y1 = line[1], line[2]
		if not is_point_in_list (x1, y1, node_points) then
			table.insert (node_points, x1) table.insert (node_points, y1)
		end
		local x2, y2 = line[#line-1], line[#line]
		if not is_point_in_list (x2, y2, node_points) then
			table.insert (node_points, x2) table.insert (node_points, y2)
		end
	end
	
-- 	node_points is a table in format of points:
--	node_points = {x1,y1, x2,y2, x3,y3}
	return node_points
end

function gs.create_paths (lines, node_points) -- lines is as array of lines
	local paths = {} -- path is a holder for path line

	for i, line in pairs (lines) do
		paths[#paths+1] = process_new_paths (lines, line)
	end
	
	for index, path in pairs (paths) do
		path.index = index
		path.from = get_node_number (node_points, path.x1, path.y1)
		path.to = get_node_number (node_points, path.x2, path.y2)
		path.length = math.floor(get_line_length (path.line)+0.5)
		path.average_speed = 1
		path.cost = path.average_speed/path.average_speed

--		path.next_paths = get_next_paths (paths, path.x2, path.y2)
--		path.prev_paths = get_prev_paths (paths, path.x1, path.y1)
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

function get_node_value (x, y, node_points)
	for i = 1, #node_points-2, 3 do
		if node_points[i] == x and node_points[i+1] == y then
			return node_points[i+2]
		end
	end
end

function set_node_value (x, y, node_points, value)
	for i = 1, #node_points-2, 3 do
		if node_points[i] == x and node_points[i+1] == y then
			node_points[i+2] = value
		end
	end
end

function gs.get_trace (paths, node_points, x1, y1, x2, y2, n_source) -- paths, source, target
--	local ps = get_starting_paths (paths, x1, y1) -- paths from start
	local value = 0
	local nodes = {}
	local start_node_number = get_node_number (node_points, x1, y1)
--	print ('start_node_number', start_node_number)
	local end_node_number = get_node_number (node_points, x2, y2)
--	print ('start_node_number', start_node_number, 'end_node_number', end_node_number)
	
	nodes[start_node_number] = {cost=0, str_nodes=""..start_node_number}
	local sh_lines = dijkstra (paths, nodes, start_node_number, end_node_number, n_source)
	
	
	local shline = {}
	if #sh_lines>0 then
		-- copy first point
		shline[1], shline[2] = sh_lines[1][1], sh_lines[1][2]
		for i, line in pairs (sh_lines) do
--			print ('line', i, #line)
			for j = 3, #line do -- copy all points except first
				table.insert (shline, line[j])
			end
		end
	end
--	print ('#shline', #shline)
	return {line=shline}
end


return gs