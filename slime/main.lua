-- License CC0 (Creative Commons license) (c) darkfrei, 2021

local title = 'Slime!'

local slime = require ('slime')

function love.load()
	love.window.setTitle(title)
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	width, height = love.graphics.getDimensions( )


	grid_size = 160
--	screen = {x=1,y=0,w=math.floor(width/grid_size),h=math.floor(height/grid_size)}
--	print (screen.w, screen.h)
	map = {
		{0,0,0,0,0,0,0,0,0,0,0},
		{0,0,1,1,0,0,0,0,0,0,0},
		{0,0,0,0,1,0,0,1,0,1,1},
		{0,0,0,0,0,0,0,0,0,1,0},
		{0,0,0,0,0,1,0,0,1,0,0},
		{1,1,1,1,1,1,1,1,1,1,1},
		}
	
	
	
	slime.new(width/2, height/2, grid_size)
end

 
function love.update(dt)
	slime.update(dt, map, grid_size)
end


function love.draw()
	for j, is in pairs (map) do
		for i, v in pairs (is) do
			local c = 1-v
			love.graphics.setColor(c,c,c)
			love.graphics.rectangle('fill', (i-0.5)*grid_size, (j-0.5)*grid_size, grid_size, grid_size)
			love.graphics.setColor(0.5,0.5,0.5)
			love.graphics.rectangle('line', (i-0.5)*grid_size, (j-0.5)*grid_size, grid_size, grid_size)
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