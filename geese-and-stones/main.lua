function weighted_random (weights)
	local summ = 0
	for i, weight in pairs (weights) do
		summ = summ + weight
	end
	if summ == 0 then return end
	local value = math.random (summ)
	summ = 0
	for i, weight in pairs (weights) do
		summ = summ + weight
		if value <= summ then
			return i, weight
		end
	end
end

function love.load()
	width, height = love.graphics.getDimensions( )
	
	rez = 50
	map_width = math.floor(width/rez)
	map_height = math.floor(height/rez)
	
	map = {}
	
	for i=1, map_width do
		map[i]=map[i] or {}
		for j=1, map_width do
			map[i][j]=weighted_random ({80,1}) -- 1 or 2
		end
	end
	
	mouse = {x=0,y=0,map_x=0,map_y=0}
end


 
function love.update(dt)
	local mx, my = love.mouse.getPosition()
	mouse.map_x, mouse.map_y =math.ceil(mx/rez), math.ceil(my/rez)
	mouse.x, mouse.y = (mouse.map_x-0.5)*rez, (mouse.map_y-0.5)*rez
end


function love.draw()
	for i=1, map_width do
		for j=1, map_width do
			local value = map[i][j]
			if value == 2 then
				love.graphics.setColor(0.5,0.5,0)
				love.graphics.rectangle('fill',i*rez,j*rez,rez,rez)
			end
		end
	end
	love.graphics.setColor(0,0.5,0)
	love.graphics.line(0, mouse.y, width, mouse.y)
	love.graphics.line(mouse.x, 0, mouse.x, width)
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end