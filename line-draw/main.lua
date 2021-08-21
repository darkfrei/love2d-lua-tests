-- License CC0 (Creative Commons license) (c) darkfrei, 2021



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
		table.insert (line, x)
		table.insert (line, y)
		table.insert (lines, line)
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
		table.insert (lines, line)
		tool.line = nil
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

ggap = 0

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
		ggap = gap
	end,
	
	mousereleased = function ( x, y, button, istouch, presses )
		if selected_line then
			table.remove(lines, selected_line)
			selected_line = nil
		end
	end,
}

--tool = tools.line
tool = tools.free

grid_size = 20
--grid_enabled = true
grid_enabled = false

function to_grid (x, y)
	return math.floor(x/grid_size+0.5)*grid_size, math.floor(y/grid_size+0.5)*grid_size
end

function love.load()
	lines = {}
	
end

 
function love.update(dt)
	
end

function draw_grid ()
	love.graphics.setLineWidth (1)
	love.graphics.setColor(0.25,0.25,0.25)
	local width, height = love.graphics.getDimensions( )
	for x = grid_size, width-1, grid_size do
		love.graphics.line(x, 0, x, height)
	end
	for y = grid_size, height-1, grid_size do
		love.graphics.line(0, y, width, y)
	end
end

function love.draw()
	if grid_enabled then
		draw_grid ()
	end
	
	love.graphics.setColor(1,1,1)
	love.graphics.print ('tools: ', 0, 40)
	love.graphics.print ('press q to line ', 0, 60)
	love.graphics.print ('press w to free ', 0, 80)
	love.graphics.print ('press e to remove ', 0, 100)
	love.graphics.print (ggap, 150, 100)
	love.graphics.print ('press g for grid ', 0, 120)
	if tool then
		love.graphics.print ('tool: '..tool.name, 0, 140)
	else
		love.graphics.print ('no tool', 0, 120)
	end
	

	
	love.graphics.setLineWidth (3)
	
	for i, line in pairs (lines) do
		if selected_line and selected_line == i then
			love.graphics.setColor(1,0,0)
			love.graphics.line(line)
			love.graphics.print(#line/2, line[#line-1], line[#line])
		else
			love.graphics.setColor(1,1,1)
			love.graphics.line(line)
			love.graphics.print(#line/2, line[#line-1], line[#line])
		end
	end
	
	-- draw the tool line and last line point to mouse
	if tool and tool.line then
		love.graphics.setLineWidth (1)
		if #tool.line > 2 then
			love.graphics.line(tool.line)
		end
		local mx, my = love.mouse.getPosition()
		if grid_enabled then
			mx, my = to_grid (mx, my)
		end
		love.graphics.line(tool.line[#tool.line-1], tool.line[#tool.line], mx, my)
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "q" then
		if tool and tool == tools.line then
			tool = nil
		else 
			tool = tools.line
		end
	elseif key == "w" then
		if tool and tool == tools.free then
			tool = nil
		else 
			tool = tools.free
		end
	elseif key == "e" then
		if tool and tool == tools.remove then
			tool = nil
		else 
			tool = tools.remove
		end
	elseif key == "g" then
		grid_enabled = not grid_enabled
	elseif key == "escape" then
		love.event.quit()
	end
end


function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
		if tool then
			tool.mousepressed( x, y, button, istouch, presses )
		end
	elseif button == 2 then -- right mouse button
		
	elseif button == 3 then -- middle mouse button
		
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
	if tool then
		tool.mousemoved( x, y, dx, dy, istouch )
	end
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
		if tool then
			tool.mousereleased( x, y, button, istouch, presses )
		end
	elseif button == 2 then -- right mouse button
		
	elseif button == 3 then -- middle mouse button
		
	end
end