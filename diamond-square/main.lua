-- License CC0 (Creative Commons license) (c) darkfrei, 2021

get_color = require ('sea-mountain-colors')

function load ()
	width, height = love.graphics.getDimensions( )
	
	map = {}
	
	map_size = 2^map_n + 1 -- 1025
	chunk_size = map_size - 1
	roughness = 2
	
	local corners = {{i=1,j=1}, {i=map_size,j=1}, {i=map_size,j=map_size}, {i=1,j=map_size}}
	
	for _, corner in pairs (corners) do
		local i, j = corner.i, corner.j
		local value = math.random ()
		value = 0.5-0.5*math.cos(value*math.pi)
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
	
	
	map_n = 2
	load ()
end


update = {}

function get_value (i, j)
	if map[i] and map[i][j] then
		return map[i][j]
	end
end


function get_random (min, max)
	local r = 4*(math.random ()-0.5)^3 + 0.5
--	https://www.desmos.com/calculator/toxjtsovev
	return min + r*(max-min)
end

function get_square_value (i, j, half)
	local value = 0
	local n = 0
	local min, max
	for _, corner in pairs ({{i=i, j=j}, {i=i+chunk_size, j=j}, {i=i, j=j+chunk_size}, {i=i+chunk_size, j=j+chunk_size}}) do
		local v = get_value (corner.i, corner.j)
		if v then
			min = min and math.min (min, v) or v
			max = max and math.max (max, v) or v
			value = value + v
			n = n + 1
		end
	end
	return value/n, min, max
end


update.square = function ()
	local half = chunk_size/2
	for i = 1, map_size-1, chunk_size do
		for j = 1, map_size-1, chunk_size do
			local value, min, max = get_square_value (i, j, half)
			map[i+half] = map[i+half] or {}
			map[i+half][j+half] = get_random (min, max)
		end
	end
	
	state = states.diamond
end


function get_diamond_value (i, j, half)
	local value = 0
	local n = 0
	local min, max
	for _, corner in pairs ({{i=i, j=j-half}, {i=i+half, j=j}, {i=i, j=j+half}, {i=i-half, j=j}}) do
		local v = get_value (corner.i, corner.j)
		if v then
			min = min and math.min (min, v) or v
			max = max and math.max (max, v) or v
			value = value + v
			n = n + 1
		end
	end
	return value/n, min, max
end

update.diamond = function ()
	local half = chunk_size/2
	for i = 1, map_size, half do
--		for j = 1, map_size-1, chunk_size do
		for j = (i+half)%chunk_size, map_size, chunk_size do
--			print ('i: '..i .. ' j:'.. j)
--			if (i + j)%half == 0 then
				local value, min, max = get_diamond_value (i, j, half)
				map[i] = map[i] or {}
				map[i][j] = get_random (min, max)
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
		if buffer > 0.1 then
			buffer = buffer - 0.1
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
				
				if c > 1 then 
					c = 1
				elseif c < 0 then
					c = 0
				end
				love.graphics.setColor(get_color(c^2))
				
				if rez > 1 then
					love.graphics.rectangle("fill", rez*i, rez*j, rez, rez)
				else
					love.graphics.points(i, j)
				end
				

				if map_n < 5 then
					if c < 0.75 then
						love.graphics.setColor(1,1,1)
					else
						love.graphics.setColor(0,0,0)
					end
					love.graphics.print(math.floor(c*100), rez*i, rez*j)
				end
			end
		end
	end
end

function ser (tabl)
	local str = string.char (10) .. "{"
	for i, v in pairs (tabl) do
		if type (v) == "table" then
			str = str
			str = str ..ser (v)
--			str = str .. string.char (10)
		elseif type (v) == "number" then
			str = str .. math.floor(v*255)
		else
			str = str .. v
		end
		str = str .. ','
	end
	return str .. "}"
end

function love.keypressed(key, scancode, isrepeat)
	if key == "space" then
		pause = not pause
	elseif key == "w" then
		map_n = map_n + 1
		load ()
	elseif key == "r" then
		load ()
	elseif key == "s" then
		map_n = math.max(1, map_n - 1)
		load ()
	elseif key == "k" then
--		love.filesystem.write( "test.lua", table.show(map, "loadedhero"))
--		love.filesystem.write( "test.lua", "a")
--		love.filesystem.write( "test.lua", "b")
		love.filesystem.write( "map-"..map_size..".lua", "return	" .. ser (map))
	elseif key == "f11" then
		fullscreen = not fullscreen
		love.window.setFullscreen( fullscreen )
		
	elseif key == "escape" then
		love.event.quit()
	end
end