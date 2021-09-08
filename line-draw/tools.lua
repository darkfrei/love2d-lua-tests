
tools = {}
tools.line = 
{
	name = "line",
	mousepressed = function ( x, y, button, istouch, presses )
		if grid_enabled then x,y = to_grid (x, y) end
		tool.line = {x, y}
	end,
	
	mousemoved = function ( x, y, dx, dy, istouch )
		
	end,
	
	mousereleased = function ( x, y, button, istouch, presses )
		if grid_enabled then x,y = to_grid (x, y) end
		local line = tool.line
		
		if not (line[#line-1] == x and line[#line] == y) then
			table.insert (line, x)
			table.insert (line, y)
		end
		if #line > 2 then
			table.insert (lines, line)
		end
		tool.line = nil
	end,
}

tools.free = 
{
	name = "free",
	gap = 20,
	mousepressed = function ( x, y, button, istouch, presses )
		if grid_enabled then x,y = to_grid (x, y) end
		tool.line = {x, y}
	end,
	
	mousemoved = function ( x, y, dx, dy, istouch )
		if tool.line then
			local gap = tool.gap
			local line = tool.line
			local lx, ly = line[#line-1], line[#line]
			if grid_enabled then 
				x,y = to_grid (x, y) 
--				lx, ly = to_grid (lx, ly) 
				gap = 2*grid_size
			end
			if (x-lx)^2+(y-ly)^2 >= tool.gap^2 then
				table.insert (line, x)
				table.insert (line, y)
			end
		end
	end,
	
	mousereleased = function ( x, y, button, istouch, presses )
		local line = tool.line
		if grid_enabled or line[#line-1] == x and line[#line] == y then 
		else
			table.insert (line, x)
			table.insert (line, y)
		end
		if #line > 2 then
			table.insert (lines, line)
		end
		tool.line = nil
	end,
}



tools.circle = 
{
	name = "circle",
	gap = 20,
	mousepressed = function ( x, y, button, istouch, presses )
		if grid_enabled then x,y = to_grid (x, y) end
		tool.line = {x, y}
	end,
	
	mousemoved = function ( x, y, dx, dy, istouch )
		if tool.line then
			local line = tool.line
			if grid_enabled then 
				x,y = to_grid (x, y)
			end
			line[3] = x
			line[4] = y
			local d = ((x-line[1])^2+(y-line[2])^2)^0.5
			tool.circle = {x=(line[1]+x)/2, y=(line[2]+y)/2, r=d/2}
		end
	end,
	
	get_circle_line = function (x, y, r, gap, clockwise)
		local line = {}
		local p = 2*math.pi*r
		local n_segments = math.ceil(p/gap)
		local angle = math.min(2*math.pi/n_segments, (30/180)*math.pi)
		n_segments = 2*math.pi / angle
		local sign = clockwise and -1 or 1
		for i = 0, n_segments do
			table.insert (line, x+r*math.cos(sign*i*angle))
			table.insert (line, y+r*math.sin(sign*i*angle))
		end
		return line
	end,
	
	mousereleased = function ( x, y, button, istouch, presses )
		local circle = tool.circle
--		if circle then
		local gap = tool.gap
		local line = tool.get_circle_line (circle.x, circle.y, circle.r, gap)
		table.insert (lines, line)
		tool.line = nil
		tool.circle = nil
--		end
	end,
}

function distPointToLine(px,py,x1,y1,x2,y2)
	local dx,dy = x2-x1,y2-y1
	local length = math.sqrt(dx*dx+dy*dy)
	dx,dy = dx/length,dy/length
	local p = dx*(px-x1)+dy*(py-y1)
	if p < 0 then
		dx,dy = px-x1,py-y1
		return math.sqrt(dx*dx+dy*dy)
	elseif p > length then
		dx,dy = px-x2,py-y2
		return math.sqrt(dx*dx+dy*dy)
	end
	return math.abs(dy*(px-x1)-dx*(py-y1))
end

tools.ggap = 0

tools.remove = 
{
	name = "remove",
	gap = 5,
	mousepressed = function ( x, y, button, istouch, presses )
		
	end,
	
	mousemoved = function ( x, y, dx, dy, istouch )
		local gap = tool.gap
		local i_line
		for i, line in pairs (lines) do
			local ax,ay = line[1], line[2]
			for j = 3, #line-1, 2 do
				local bx,by = line[j], line[j+1]
				local dist = distPointToLine(x,y,ax,ay,bx,by)
				if dist<gap then
					gap = dist
					i_line = i
				end
				ax, ay = bx, by
			end
		end
		if i_line then
			selected_line = i_line
		else
			selected_line = nil
		end
		tools.ggap = gap
	end,
	
	mousereleased = function ( x, y, button, istouch, presses )
		if selected_line then
			table.remove(lines, selected_line)
			selected_line = nil
		end
	end,
}


return tools