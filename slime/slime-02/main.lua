local slime = require ('slime')
local camera = require ('camera')

local title = 'Slime!'

function love.load()
	love.window.setTitle(title)
--	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
--	if ddheight > 1080 then
--		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
--	else
--		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
--	end
	width, height = love.graphics.getDimensions( )

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

	grid_size = math.floor (math.min (width/(#map[1]+1), (height/(#map+1))))
	grid_size = 100
	
	
	slime_size = 1/8
--	slime.new(width/2, height/2, grid_size)
--	slime.new(grid_size*math.floor((#map[1]+1)/2), grid_size*math.floor((#map+1)/2), grid_size, slime_size)
	slime.new(grid_size*(math.floor(width/4/grid_size)), grid_size*math.floor((#map+1)/2), grid_size, slime_size)
end

 
function love.update(dt)
	if dt > 1/50 then
		dt = 1/50
	end
	slime.update(dt, map, grid_size)
	camera.update(dt, slime.x)
end


function love.draw()
	love.graphics.translate(-camera.x, 0)
	
	for j, is in pairs (map) do
		for i, v in pairs (is) do
			local c = 1-v
			love.graphics.setColor(c,c,c)
			love.graphics.rectangle('fill', (i-0.5)*grid_size, (j-0.5)*grid_size, grid_size, grid_size)
			love.graphics.setColor(0.5,0.5,0.5)
			love.graphics.rectangle('line', (i-0.5)*grid_size, (j-0.5)*grid_size, grid_size, grid_size)
			
			if is_tile_wall (i, j)then
				love.graphics.setColor(1,1,1)
				local a = 1*slime_size
				if not (is_tile_wall (i, j-1) or is_tile_wall (i-1, j) or is_tile_wall (i-1, j-1)) then
					love.graphics.line ((i-0.5)*grid_size, (j+(-0.5+a))*grid_size, (i+(-0.5+a))*grid_size, (j-0.5)*grid_size)
				end
				
				if not (is_tile_wall (i, j+1) or is_tile_wall (i-1, j) or is_tile_wall (i-1, j+1)) then
					love.graphics.line ((i-0.5)*grid_size, (j+(0.5-a))*grid_size, (i+(-0.5+a))*grid_size, (j+0.5)*grid_size)
				end
				
				if not (is_tile_wall (i, j-1) or is_tile_wall (i+1, j) or is_tile_wall (i+1, j-1)) then
					love.graphics.line ((i+0.5)*grid_size, (j+(-0.5+a))*grid_size, (i+(0.5-a))*grid_size, (j-0.5)*grid_size)
				end
				
				if not (is_tile_wall (i, j+1) or is_tile_wall (i+1, j) or is_tile_wall (i+1, j+1)) then
					love.graphics.line ((i+0.5)*grid_size, (j+(0.5-a))*grid_size, (i+(0.5-a))*grid_size, (j+0.5)*grid_size)
				end
				
			end
		end
	end
	
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