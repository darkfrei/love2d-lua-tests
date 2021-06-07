-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function add_link (x,y, direction)
	local id = #chain + 1
	local cd = math.random (4)
	local new_direction = direction
	if cd == 1 then -- turn left
		new_direction = (direction + 3)%4
	elseif cd == 2 then -- turn right
		new_direction = (direction + 1)%4
	else -- not turn
	end
	if x <= 0 then 
		if direction == 3 and new_direction == 3 then 
			new_direction = ({0, 2})[math.random (2)]
		elseif (new_direction == 3) then
			new_direction = 1
		end
	elseif x >= map_width then
		if direction == 1 and new_direction == 1 then 
			new_direction = ({0, 2})[math.random (2)]
		elseif (new_direction == 1) then
			new_direction = 3
		end	
	end
	if y <= 0 then
		if direction == 0 and new_direction == 0 then 
			new_direction = ({1, 3})[math.random (2)]
		elseif (new_direction == 0) then
			new_direction = 2
		end
--		new_direction = 2
	elseif y >= map_height then
		if direction == 2 and new_direction == 2 then 
			new_direction = ({1, 3})[math.random (2)]
		elseif (new_direction == 2) then
--		elseif (new_direction == 2) then
			new_direction = 0
		end
--		new_direction = 0
	end

	
	table.insert (chain, {x=x,y=y,id=id, direction=new_direction})
	if not map[x] then map[x] = {} end
	map[x][y] = {x=x,y=y,id=id, direction=new_direction}
end

function love.load()
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	width, height = love.graphics.getDimensions( )
	rez = 2
	shift_y = 40
	map_width, map_height = math.floor(width/rez), math.floor((height-32)/rez)

	chain = {}
	map = {}
	
	
	
	local x, y = math.floor(0.1*map_width), math.floor(0.1*map_height)
	local direction = math.random (0, 3)
	add_link (x,y, direction)
	
	dpositions = {{x=0,y=-1},{x=1,y=0},{x=0,y=1},{x=-1,y=0}}
	
	canvas = love.graphics.newCanvas()
	pause = true
	db=0
end

function remove_links (x, y)
	local last_link = map[x][y]
	local last_id = last_link.id
	local vertices = {x*rez, shift_y+y*rez}
	for i = last_id+1, #chain do
		table.insert (vertices, chain[i].x*rez)
		table.insert (vertices, shift_y+chain[i].y*rez)
		map[chain[i].x][chain[i].y] = nil
		chain[i] = nil
	end
--	table.insert (vertices, x*rez)
--	table.insert (vertices, shift_y+y*rez)
	
	love.graphics.setCanvas(canvas)
--		love.graphics.setLineWidth( 1 )
--		love.graphics.setColor(0, 0, 0, 1/255)
		if db > 1000 then
			db = db - 1000
			love.graphics.setColor(0, 0, 0, 4/255)
			love.graphics.rectangle('fill', 0, shift_y, width, height-shift_y)
		else
			db = db+1
		end
		love.graphics.setColor(1, 1, 1, 64/255)
--		love.graphics.polygon( 'fill', vertices )
		local triangles = love.math.triangulate(vertices)
		for i, triangle in pairs (triangles) do
			love.graphics.polygon( 'fill', triangle)
		end
		if show_outline then
			love.graphics.setColor(1, 1, 0, 1)
			love.graphics.polygon('line', vertices)
		end
	love.graphics.setCanvas()
end
 
function love.update(dt)
--	buffer = buffer or dt
--	if buffer > 0.2 then
--		buffer = buffer-0.2
--	else
--		buffer = buffer + dt
--		return
--	end
	if pause then return end
	
	for i = 1, 100 do
		local link = chain[#chain]
		local direction = link.direction
		local d_position = dpositions[direction+1]
		local x, y = link.x + d_position.x, link.y + d_position.y
		if not (map[x] and map[x][y]) then
			add_link (x,y, link.direction)
		else
			remove_links (x, y)
		end
	end
end


function love.draw()
	love.graphics.setColor(1,1,1)
	love.graphics.draw(canvas)
	love.graphics.print('map_width: '..map_width..' map_height: '..map_height)
	love.graphics.rectangle('line', 0,shift_y,rez*map_width, rez*map_height)
	love.graphics.setLineWidth( 3 )

	love.graphics.setColor(0, 1, 0)
	for i = 1, #chain-1 do
		love.graphics.line(rez*chain[i].x,shift_y+rez*chain[i].y,rez*chain[i+1].x,shift_y+rez*chain[i+1].y)
	end
	love.graphics.circle('fill', rez*chain[#chain].x,shift_y+rez*chain[#chain].y, 3)
	love.graphics.setLineWidth(1)
end

function love.keypressed(key, scancode, isrepeat)
	if key == "space" then
		pause = not pause
	elseif key == "escape" then
		love.event.quit()
	end
end