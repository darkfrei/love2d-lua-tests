local railways = {}



-- normalization and multiplication
local function normul (x, y, offset) 
	local d = (x*x+y*y)^0.5
	offset = offset or 1
	return offset*x/d, offset*y/d
end

local function get_parallel_segment (x1, y1, x2, y2, offset)
	local dx, dy = x2-x1, y2-y1
	local vnormx, vnormy = normul (dx, dy, offset) -- normalization and multiplication
	local nx, ny = vnormy, -vnormx
	local px1, py1 = x1+nx, y1+ny
	local px2, py2 = x2+nx, y2+ny
	return px1, py1, px2, py2
end

local function is_loop (line)
	return line[1] == line[#line-1] and line[2] == line[#line]
end

-- Find the intersection point of two lines
local function get_intersection (x1, y1, x2, y2, x3, y3, x4, y4, unlimited, gap) -- start end start end
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
local function get_offset_polyline (line, offset, reversed)
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

local function getLineLenght (line)
	local length = 0
	local x1, y1, x2, y2, dx, dy, sector_length = line[1],line[2]
	for i=3, #line-1, 2 do
		x2, y2 = line[i],line[i+1]
		dx, dy = x2-x1, y2-y1
		length = length + (dx*dx+dy*dy)^0.5
		x1, y1 = x2, y2
	end
	return length
end

local function get_points_along_line (line, gap)
	local points = {}
	local tangents = {}
	local rest = gap/2 -- rest is gap to start point on this section
	
	local lineLenght = getLineLenght (line)
	
	local n = math.floor((lineLenght-gap)/gap+0.5)
	local gap2 = (lineLenght-gap)/n
	
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
--				rest = rest + gap
				rest = rest + gap2
			end
		else -- no point in this distance
		end
		-- the tail for the next 
		rest = rest-sector_length
		x1, y1 = x2, y2
		if #points/2 > n then 
			break
		end
	end
	print ('rest', rest, n, lineLenght)
	return points, tangents
end

local function smooth_vectors (vs) 
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


local function get_crosstie_lines (line, gap, width)
	
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


function railways.drawRails (crossTieCanvas, railway_canvas, line) -- love2d polyline
	print ('getRails', table.concat(line, ','))
	
	local rail_width = 26
	local rail_thickness = 2
--	local rail_color = {0.6,0.8,0.8}
	local rail_color = {0,0,0}
	
	local crosstie_width = 40
	local crosstie_distance = 16
	local crosstie_thickness = 5
--	local crosstie_color = {0.8,0.8,0.3}
	local crosstie_color = {137/255,97/255,60/255}

	local left_rail_line = get_offset_polyline (line, rail_width/2)
	local right_rail_line = get_offset_polyline (line, -rail_width/2)
	
	local crosstie_lines = get_crosstie_lines(line, crosstie_distance, crosstie_width)
	
	
--	local railway_canvas = love.graphics.newCanvas()
	love.graphics.setCanvas(crossTieCanvas)
		love.graphics.setColor (crosstie_color)
		love.graphics.setLineWidth (crosstie_thickness)
		for i, line in pairs (crosstie_lines) do
			love.graphics.line(line)
		end
	
	love.graphics.setCanvas(railway_canvas)
		love.graphics.setColor (rail_color)
		love.graphics.setLineWidth (rail_thickness)
		love.graphics.line(left_rail_line)
		love.graphics.line(right_rail_line)
	
--		love.graphics.setColor (1,1,1, 0.5)
--		love.graphics.setLineWidth (2)
--		love.graphics.line(line)
		
--		love.graphics.setColor (1,1,1)
--		love.graphics.setPointSize(3)
--		love.graphics.points(points)
	love.graphics.setCanvas()
	
--	return railway_canvas
end


return railways