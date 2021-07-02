-- License CC0 (Creative Commons license) (c) darkfrei, 2021

local fov = require ('fov')

function love.load()
	local ww, wh = love.window.getDesktopDimensions( displayindex )
	love.window.setMode( ww/2, wh/2)
	
	width, height = love.graphics.getDimensions( )

	map = {}
	rez = 16
	max_i, max_j = math.floor(width/rez), math.floor(height/rez)
	for i = 1, max_i do
		map[i] = {}
		for j = 1, max_j do
			if math.random (10) == 1 then
				map[i][j] = 0 -- 0 is wall, black
			else
				map[i][j] = 1 -- 1 is space, white
			end
		end
	end
	
	player = {i=math.floor(max_i/2), j=math.floor(max_j/2)}
	radius = 30
end

 
function love.update(dt)
	
end


function love.draw()
	-- draw map
	for i, js in pairs (map) do
		for j, value in pairs (js) do
			local c = (value+1)/3
			love.graphics.setColor (c,c,c)
			love.graphics.rectangle('fill', rez*(i-1), rez*(j-1), rez, rez)
		end
	end
	
	-- get and draw fov
	local view = fov.marching (map, player.i, player.j, radius)
	for i, js in pairs (view) do
		for j, value in pairs (js) do
			local c = value and 1 or 0
			love.graphics.setColor (c,c,1-c)
			love.graphics.rectangle('fill', rez*(i-1), rez*(j-1), rez, rez)
			
			if map[i] and map[i][j] then
				map[i][j] = value and 2 or -1
			end
		end
	end
	
	-- draw player
	love.graphics.setColor (0,1,0)
	love.graphics.rectangle('fill', rez*(player.i-1), rez*(player.j-1), rez, rez)
	
	-- GUI
	love.graphics.setColor (1,1,1)
	love.graphics.print('press WASD to move green dot')
end

function love.keypressed(key, scancode, isrepeat)
	if key == "d" then
		player.i = player.i + 1
	elseif key == "s" then
		player.j = player.j + 1
	elseif key == "a" then
		player.i = player.i - 1
	elseif key == "w" then
		player.j = player.j - 1
	elseif key == "escape" then
		love.event.quit()
	end
end