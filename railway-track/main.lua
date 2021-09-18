-- License CC0 (Creative Commons license) (c) darkfrei, 2021


-- normalization and multiplication
function normul (x, y, offset) 
	local d = (x*x+y*y)^0.5
	offset = offset or 1
	return offset*x/d, offset*y/d
end

function get_parallel_segment (x1, y1, x2, y2, offset)
	local dx, dy = x2-x1, y2-y1
	local vnormx, vnormy = normul (dx, dy, offset) -- normalization and multiplication
	local nx, ny = vnormy, -vnormx
	local px1, py1 = x1+nx, y1+ny
	local px2, py2 = x2+nx, y2+ny
	return px1, py1, px2, py2
end

function is_loop (line)
	return line[1] == line[#line-1] and line[2] == line[#line]
end

-- Find the intersection point of two lines
function get_intersection (x1, y1, x2, y2, x3, y3, x4, y4, unlimited, gap) -- start end start end
--	from line-following
	local d = (x1-x2)*(y3-y4)-(y1-y2)*(x3-x4)
	if d == 0 then return end
	local a, b = x1*y2-y1*x2, x3*y4-y3*x4
	local x = (a*(x3-x4) - b*(x1-x2))/d
	local y = (a*(y3-y4) - b*(y1-y2))/d
	if unlimited then return x, y end
	gap = gap or 0
	if x-gap <= math.max(x1, x2) and x+gap >= math.min(x1, x2) and
		x-gap <= math.max(x3, x4) and x+gap >= math.min(x3, x4) then
		return x, y
	end
end

-- Offsets the given polyline (line) by offset (offset)
function get_offset_polyline (line, offset, reversed)
	local offset_polyline = {}
	local loop = is_loop (line)
	if reversed then
		line = reverse_line (line)
	end
	if #line == 4 then
		local x1, y1 = line[1], line[2]
		local x2, y2 = line[3], line[4]
		local px1, py1, px2, py2 = get_parallel_segment (x1, y1, x2, y2, offset)
		offset_polyline = {px1, py1, px2, py2}
	elseif not loop then
		local x1, y1, x2, y2 = line[1], line[2], line[3], line[4]
		local px1, py1, px2, py2 = get_parallel_segment (x1, y1, x2, y2, offset)
		table.insert (offset_polyline, px1)
		table.insert (offset_polyline, py1)
		for i = 5, #line-1, 2 do
			local x3, y3 = line[i], line[i+1]
			local px3, py3, px4, py4 = get_parallel_segment (x2, y2, x3, y3, offset)
			local x, y = get_intersection (px1, py1, px2, py2, px3, py3, px4, py4, false, 4)
			table.insert (offset_polyline, x)
			table.insert (offset_polyline, y)
			x1, y1, x2, y2 = x2, y2, x3, y3
			px1, py1, px2, py2 = px3, py3, px4, py4
		end
		table.insert (offset_polyline, px2)
		table.insert (offset_polyline, py2)
	else -- loop
		local x1, y1, x2, y2 = line[#line-5], line[#line-4], line[#line-3], line[#line-2]
		local px1, py1, px2, py2 = get_parallel_segment (x1, y1, x2, y2, offset)
--		for i = 1, #line-1, 2 do
		for i = 1, #line-1, 2 do
			local x3, y3 = line[i], line[i+1]
			local px3, py3, px4, py4 = get_parallel_segment (x2, y2, x3, y3, offset)
			local x, y = get_intersection (px1, py1, px2, py2, px3, py3, px4, py4, false, 4)
			table.insert (offset_polyline, x)
			table.insert (offset_polyline, y)
			x1, y1, x2, y2 = x2, y2, x3, y3
			px1, py1, px2, py2 = px3, py3, px4, py4
		end
	end
	if #offset_polyline > 3 then
		return offset_polyline
	end
end

function get_points_along_line (line, gap)
	local points = {}
	local tangents = {}
	local rest = gap/2 -- rest is gap to start point on this section
	local x1, y1, x2, y2, dx, dy = line[1],line[2]
	for i=3, #line-1, 2 do
		x2, y2 = line[i],line[i+1]
		dx, dy = x2-x1, y2-y1
		local sector_length = (dx*dx+dy*dy)^0.5
		if sector_length > rest then
			-- rest is always shorter than gap; sector is shorter than rest (or gap)
			dx, dy = dx/sector_length, dy/sector_length
			while sector_length > rest do
				local x, y = x1+rest*dx, y1+rest*dy
				table.insert (points, x)
				table.insert (points, y)
				table.insert (tangents, dx)
				table.insert (tangents, dy)
				rest = rest + gap
			end
		else -- no point in this distance
		end
		-- the tail for the next 
		rest = rest-sector_length
		x1, y1 = x2, y2
	end
	return points, tangents
end

function smooth_vectors (vs) 
	local svs = {vs[1], vs[2]} -- smooth line
	for i = 3, #vs-3, 2 do
		local x = 0.6*vs[i]  +0.2*vs[i+2]+0.2*vs[i-2]
		local y = 0.6*vs[i+1]+0.2*vs[i+3]+0.2*vs[i-1]
		local d = (x*x+y*y)^0.5
		table.insert (svs, x/d)
		table.insert (svs, y/d)
	end
	table.insert (svs, vs[#vs-1])
	table.insert (svs, vs[#vs])
	return svs
end


function get_crosstie_lines (line, gap, width)
	local points, tangents = get_points_along_line (line, gap)
	
	--smooth tangents:
	tangents = smooth_vectors (tangents)
	
	local crosstie_lines = {}
	for i = 1, #points-1, 2 do
		local x, y, dx, dy = points[i],points[i+1],tangents[i],tangents[i+1]
		local x1, y1 = x+width*dy/2, y-width*dx/2
		local x2, y2 = x-width*dy/2, y+width*dx/2
		table.insert(crosstie_lines, {x1, y1, x2, y2})
	end
	return crosstie_lines
end


function love.load()
	line = {
	0,266,22,256,44,246,67,234,88,222,107,210,
	124,196,141,181,157,164,173,147,188,130,
	203,114,218,98,236,83,254,71,274,62,295,57,
	318,56,340,60,360,67,375,79,381,95,378,113,
	368,132,355,150,343,168,331,185,322,203,
	317,220,319,234,330,243,347,246,368,243,
	390,236,412,224,434,213,455,207,477,207,
	496,216,508,231,511,249,505,267,492,282,
	474,296,455,307,435,315,413,321,390,324,
	368,325,344,326,320,327,295,329,270,333,
	246,340,224,348,203,360,184,375,167,393,
	155,412,149,432,151,451,162,466,179,478,
	198,487,217,494,236,502,256,509,277,514,
	299,518,324,521,349,523,374,524,398,524,
	422,524,446,524,470,524,493,523,515,522,
	537,519,557,513,573,504,581,493,576,483,
	562,476,544,472,525,469,504,468,484,466,
	465,463,448,457,434,446,423,431,414,416,
	401,405,384,402,366,405,347,410,328,416,
	310,418,295,413,285,403,285,389,294,377,
	309,368,327,363,347,360,369,358,393,357,
	416,357,440,358,462,361,483,366,505,371,
	528,375,552,375,576,373,600,366,623,357,
	642,346,658,333,668,317,669,299,663,279,
	651,260,635,243,618,230,600,218,581,207,
	562,195,544,183,527,169,513,155,503,137,
	497,118,496,99,500,81,512,67,528,59,548,56,
	568,58,588,63,608,72,626,83,644,96,661,110,
	675,126,688,144,700,164,709,185,716,205,
	722,225,726,245,728,266,726,286,722,307,
	716,327,708,346,700,366,692,386,685,407,
	680,429,677,450,673,470,666,490,656,509,
	642,525,626,538,607,548,587,554,565,558,
	543,561,521,563,498,567,476,573,452,581,
	424,589,391,595}

	
	width, height = love.graphics.getDimensions( )
	
	local rail_width = 16
	local rail_thickness = 2
	local rail_color = {0.6,0.8,0.8}
	
	local crosstie_width = 25
	local crosstie_distance = 10
	local crosstie_thickness = 3
	local crosstie_color = {0.8,0.8,0.3}

	local left_rail_line = get_offset_polyline (line, rail_width/2)
	local right_rail_line = get_offset_polyline (line, -rail_width/2)
	
--	local points = get_points_along_line(line, crosstie_distance)
	local crosstie_lines = get_crosstie_lines(line, crosstie_distance, crosstie_width)
	
	
	railway_canvas = love.graphics.newCanvas()
	love.graphics.setCanvas(railway_canvas)
		love.graphics.setColor (crosstie_color)
		love.graphics.setLineWidth (crosstie_thickness)
		for i, line in pairs (crosstie_lines) do
			love.graphics.line(line)
		end
	
		love.graphics.setColor (rail_color)
		love.graphics.setLineWidth (rail_thickness)
		love.graphics.line(left_rail_line)
		love.graphics.line(right_rail_line)
	
		love.graphics.setColor (1,1,1, 0.5)
		love.graphics.setLineWidth (2)
		love.graphics.line(line)
		
--		love.graphics.setColor (1,1,1)
--		love.graphics.setPointSize(3)
--		love.graphics.points(points)
	love.graphics.setCanvas()
end

 
function love.update(dt)
	
end





function love.draw()
	love.graphics.setColor(1,1,1)
	love.graphics.draw(railway_canvas)
end


function love.mousemoved( x, y, dx, dy, istouch )
	
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end
