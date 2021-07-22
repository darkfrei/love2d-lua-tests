local slime = require ('slime')
local graphics = require ('graphics')
local fov = require ('fov')
local camera = require ('camera')

local title = 'Slime!'

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

--	grid_size = math.floor (math.min (width/(#map[1]+1), (height/(#map+1))))
	grid_size = 96
	
	
	--slime_size = 1/8

	slime.new(grid_size*(math.floor(width/4/grid_size)), grid_size*math.floor((#map+1)/2))
end

 
function love.update(dt)
	if dt > 1/50 then
		dt = 1/50
	end
	slime.update(dt, map, grid_size)
	camera.update(dt, slime.x, slime.y)
end


function love.draw()
	love.graphics.translate(-camera.x, -camera.y)
	
	local i1, i2 = math.floor((camera.x)/grid_size+0.5), math.floor((camera.x+camera.w)/grid_size+0.5)
	local j1, j2 = math.floor((camera.y)/grid_size+0.5), math.floor((camera.y+camera.h)/grid_size+0.5)
	graphics.draw_map (i1, j1, i2, j2)
	
	
	slime.draw()
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