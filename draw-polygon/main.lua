-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function love.load()

	love.window.setMode(1920+80, 1080+80, {resizable=true, borderless=true})
	width, height = love.graphics.getDimensions( )
	
	mouse = {x=0, y=0}
	translate = {x=40, y=40}
	
	polygons = {}
	line = nil
end

 
function love.update(dt)
	
end

function draw_grid (x0,y0,width,height)
--	love.graphics.setBackgroundColor(89/255,157/255,220/255) -- 599DDC
	love.graphics.setColor(89/255,157/255,220/255) -- 599DDC
	love.graphics.rectangle('fill', x0,y0,x0+width, y0+height)
	local grid_size = 40
	love.graphics.setLineWidth (1)
	love.graphics.setColor(1,1,1, 0.75)
--	local width, height = love.graphics.getDimensions( )
	for x = grid_size, width-1, grid_size do
		if x%120 == 0 then
			love.graphics.setColor(1,1,1, 0.5)
		else
			love.graphics.setColor(1,1,1, 0.25)
		end
		love.graphics.line(x, 0, x, height)
	end
	for y = grid_size, height-1, grid_size do
		if y%120 == 0 then
			love.graphics.setColor(1,1,1, 0.5)
		else
			love.graphics.setColor(1,1,1, 0.25)
		end
		love.graphics.line(0, y, width, y)
	end
end

function draw_mouse ()
	love.graphics.setLineWidth(2)
	local mx, my = mouse.x, mouse.y
	local text = mx..' '..my
	local font = love.graphics.getFont()
	local w = font:getWidth(text)
	local h = font:getHeight()
	
	love.graphics.setColor(1,1,1)
	love.graphics.circle('line', mx, my, 20)
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle('fill', mx, my-h, w, h)
	love.graphics.setColor(1,1,1)
	love.graphics.print(mx..' '..my,mx,my-h)
end

function draw_polygons ()
	for i, polygon in pairs (polygons) do
		love.graphics.setColor(0.7,0.7,0.7)
		if polygon.triangles then
			for j, triangle in ipairs(polygon.triangles) do
				love.graphics.polygon("fill", triangle)
			end
		else
			love.graphics.polygon("fill", polygon.polygon)
		end
		love.graphics.setColor(1,1,1)
		love.graphics.setLineWidth(3)
		love.graphics.polygon("line", polygon.polygon)
	end
end

function draw_line ()
	love.graphics.setLineWidth(3)
	if line and #line > 3 then
		love.graphics.setColor(1,1,1)
		love.graphics.line(line)
		if #line > 5 then
			love.graphics.line(line[#line-1], line[#line], line[1], line[2])
		end
	end
	love.graphics.setLineWidth(1)
	if line and #line > 3 then
		love.graphics.line(line[#line-1], line[#line], mouse.x, mouse.y, line[1], line[2])
	elseif line then
		love.graphics.line(line[1], line[2], mouse.x, mouse.y)
	end
end

function love.draw()
	love.graphics.translate(40,40)
	draw_grid (0,0,1920,960)
	draw_polygons ()
	draw_line ()
	draw_mouse ()
	
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	elseif key == "return" then
		if line then
			if love.math.isConvex( line ) then
				table.insert(polygons, {polygon = line})
			else -- concave
				table.insert(polygons, {polygon = line, triangles = love.math.triangulate(line)})
			end
			line = nil
		end
		
	elseif key == "space" then
		file = io.open("polygons.lua", "a") -- append mode
		io.output(file)
		io.write("-- polygons: ".. #polygons..'\n')
		for i, p in pairs (polygons) do
			
			io.write("-- verticles: ".. #p.polygon/2 ..'\n')
			io.write('{' ..table.concat(p.polygon,",")..'},'..'\n')
		end
		io.close(file)
	end
end

function round_mouse_position (grid_size)
	local mx = math.floor(love.mouse.getX()/grid_size+0.5)*grid_size-translate.x
	local my = math.floor(love.mouse.getY()/grid_size+0.5)*grid_size-translate.y
	return mx, my
end

function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
		if line then
			table.insert(line, mouse.x)
			table.insert(line, mouse.y)
		else
			line = {mouse.x, mouse.y}
		end
	elseif button == 2 then -- right mouse button
		if line and #line > 3 then
			table.remove(line, #line)
			table.remove(line, #line)
		elseif line then
			line = nil
		end
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
	mouse.x, mouse.y = round_mouse_position (40)
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end

