-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function load ()
	map = {}
	
	map_size = 2^map_n + 1 -- 1025
	chunk_size = map_size - 1
	roughness = 2
	
	local corners = {{i=1,j=1}, {i=map_size,j=1}, {i=map_size,j=map_size}, {i=1,j=map_size}}
	
	for _, corner in pairs (corners) do
		local i, j = corner.i, corner.j
		local value = math.random ()
		map[i] = map[i] or {}
		map[i][j] = value
	end
	
	states = {square = 'square', diamond = 'diamond'}
	state = states.square
	
	pause = false
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
	
	map_n = 2
	load ()
end


update = {}

function get_value (i, j)
	if map[i] and map[i][j] then
		return map[i][j]
	end
end

function get_square_value (i, j, half)
	local value = 0
	local n = 0
	for _, corner in pairs ({{i=i, j=j}, {i=i+chunk_size, j=j}, {i=i, j=j+chunk_size}, {i=i+chunk_size, j=j+chunk_size}}) do
		local v = get_value (corner.i, corner.j)
		if v then
			value = value + v
			n = n + 1
		end
	end
	return value/n
end


update.square = function ()
	local half = chunk_size/2
	for i = 1, map_size-1, chunk_size do
		for j = 1, map_size-1, chunk_size do
			local value = get_square_value (i, j, half)
			map[i+half] = map[i+half] or {}
			map[i+half][j+half] = value + 1/4*(math.random ()-0.5)
		end
	end
	
	state = states.diamond
end


function get_diamond_value (i, j, half)
	local value = 0
	local n = 0
	for _, corner in pairs ({{i=i, j=j-half}, {i=i+half, j=j}, {i=i, j=j+half}, {i=i-half, j=j}}) do
		local v = get_value (corner.i, corner.j)
		if v then
			value = value + v
			n = n + 1
		end
	end
	return value/n
end

update.diamond = function ()
	local half = chunk_size/2
	for i = 1, map_size, half do
--		for j = 1, map_size-1, chunk_size do
		for j = (i+half)%chunk_size, map_size, chunk_size do
--			print ('i: '..i .. ' j:'.. j)
--			if (i + j)%half == 0 then
				local value = get_diamond_value (i, j, half)
				map[i] = map[i] or {}
				map[i][j] = value + 1/4*(math.random ()-0.5)
--			end
		end
	end
	
	chunk_size = chunk_size/2
	roughness = roughness/2
	if chunk_size <= 1 then pause = true end
	state = states.square
end
 
function love.update(dt)
	if not pause then
		buffer = buffer or 0
		if buffer > 1 then
			buffer = buffer - 2
		else
			buffer = buffer + dt
			return
		end
		update[state]()
	end
end

function get_power (value)
	local n = -1
		while value > 1 do
			n=n+1
			value = value/2
		end
	return n
end

function love.draw()
	love.graphics.setColor(1,1,1)
	love.graphics.print(chunk_size,0,0)
	love.graphics.print(map_n,0,20)
	
	local rez = height/(map_size+2)
--	print (rez .. ' '..get_power (rez))
	rez = 2^get_power (rez)
	if rez < 1 then rez = 1 end
	
	for i = 1, map_size do
		for j = 1, map_size do
			local c = map[i] and map[i][j] or nil
			if c then
				c = math.floor(c*100)/100
				if c > 1 then 
					c = 1
				elseif c < 0 then
					c = 0
				end
				love.graphics.setColor(c,c,c)
--				love.graphics.points(i, j)
				love.graphics.rectangle("fill", rez*i, rez*j, rez, rez)
				
				if c < 0.75 then
					love.graphics.setColor(1,1,1)
				else
					love.graphics.setColor(0,0,0)
				end
--				love.graphics.print(math.floor(c*100), rez*i, rez*j)
				if map_n < 6 then
					love.graphics.print(c*100, rez*i, rez*j)
				end
			end
		end
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "space" then
		pause = not pause
	elseif key == "w" then
		map_n = map_n + 1
		load ()
	elseif key == "s" then
		map_n = math.max(1, map_n - 1)
		load ()
	elseif key == "escape" then
		love.event.quit()
	end
end