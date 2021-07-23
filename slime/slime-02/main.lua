local slime = require ('slime')
local graphics = require ('graphics')
local fov = require ('fov')
local camera = require ('camera')

local title = 'Slime!'

-- map[j][i] -- y, x

function love.load()
	love.window.setTitle(title)

	love.window.setMode(1920, 1080, {resizable=true, borderless=false})

	width, height = love.graphics.getDimensions( )
	camera.create (width, height)

	map = {
		{0,0,0,0,0,0,0,0,0,0,1},
		{0,1,1,0,0,0,0,0,0,0,0},
		{0,0,0,1,0,0,1,0,1,1,0},
		{0,1,1,1,1,0,0,1,1,0,0},
		{0,0,0,0,0,0,0,0,0,0,0},
		{1,0,0,1,0,0,0,0,1,1,0},
		{1,1,1,1,1,1,0,0,1,1,0},
		{1,1,1,1,0,1,0,0,0,0,0},
		{1,0,0,0,0,0,0,1,0,1,0},
		{1,1,0,1,0,1,0,0,0,0,0},
		}
	seen = {}
--	grid_size = math.floor (math.min (width/(#map[1]+1), (height/(#map+1))))
	grid_size = 96
	
	
	--slime_size = 1/8

	slime.new(grid_size*(math.floor(width/4/grid_size)), grid_size*math.floor((#map+1)/2))
	
	map_max_i = 0
end

function tile_exists (i, j)
	return map and map[j] and map[j][i]
end

function add_map ()
	local i3 = math.floor((slime.x+1.5*width)/grid_size+0.5)
	if i3 > map_max_i then
--		map_max_i = i3
		map_max_i = map_max_i + 1
		local j3 = math.random (#map)
--		map[j3][i3] = 0
		local i, j = i3, j3
		for n = 1, 100 do
			local ks = {}
			-- if left not exists
			if not tile_exists (i-1, j) then
				table.insert(ks, {i=i-1, j=j})
			elseif map[j] and map[j][i-1] and map[j][i-1] == 0 then -- free cell
				return
			end
			-- if line exists, but not tile
			if map[j-1] and not tile_exists (i, j-1) then
				table.insert(ks, {i=i, j=j-1})
			end
			if map[j+1] and not tile_exists (i, j+1) then
				table.insert(ks, {i=i, j=j+1})
			end
			local nk = math.random(#ks)
			local k = ks[nk]
			if k then
				i, j = k.i, k.j
				map[j][i] = 0
			end
		end
	end
end

 
function love.update(dt)
	if dt > 1/50 then
		dt = 1/50
	end
	slime.update(dt, map, grid_size)
	camera.update(dt, slime.x, slime.y)
	
	add_map ()
end


function love.draw()
	love.graphics.push()
	love.graphics.translate(-camera.x, -camera.y)
	
	local i1, i2 = math.floor((camera.x)/grid_size+0.5), math.floor((camera.x+camera.w)/grid_size+0.5)
	local j1, j2 = math.floor((camera.y)/grid_size+0.5), math.floor((camera.y+camera.h)/grid_size+0.5)
	
	local i, j = math.floor((slime.y)/grid_size+0.5), math.floor((slime.x)/grid_size+0.5)
	local view = fov.marching (map, seen, i, j, 10)
	
	graphics.draw_map (i1, j1, i2, j2, view, seen)
	
	
	slime.draw()
	
	love.graphics.pop()
	love.graphics.setColor(0,1,0)
	love.graphics.printf (#map,0,0, 300)
end

function love.keypressed(key, scancode, isrepeat)
	slime.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end

function love.mousereleased( x, y, button, istouch, presses )
--	slime.mousereleased( x, y, button, istouch, presses )

end