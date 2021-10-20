-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function love.load()
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	width, height = love.graphics.getDimensions( )

	map = {} -- map[x][y]
	
	tileSize = 20
	
	particles = {}
	
	maxThickness = 0
end

 
function love.update(dt)
	local new_particles = {}
	for i, particle in pairs (particles) do
		local power = particle.power - 1
		particle.power = power
		if power > 0 then
			local x=particle.x+math.random(-1,1)*tileSize
			local y=particle.y+math.random(-1,1)*tileSize
			table.insert (new_particles, createNewParticle (x,y, power))
			particle.x, particle.y = x, y
			
			x=math.floor(x/tileSize)
			y=math.floor(y/tileSize)
			if not map[x] then map[x] = {} end
			if not map[x][y] then 
				map[x][y] = 1
			else
				map[x][y] = map[x][y] + 1
				maxThickness = math.max (maxThickness, map[x][y])
			end
		end
	end
	for i = #particles, 1, -1 do
		local particle = particles[i]
		if particle.power < 1 then
			-- fast removing:
			particles[i]=particles[#particles]
			particles[#particles] = nil
		end
	end
	
	for i, particle in pairs (new_particles) do
		table.insert (particles, particle)
	end
	
	
end


function love.draw()
	for x, ys in pairs (map) do
		for y, value in pairs (ys) do
--			if value then
				local c = value/maxThickness
				c=1/8+7/8*c
				love.graphics.setColor(c,c,c)
				love.graphics.rectangle('fill', x*tileSize, y*tileSize,tileSize,tileSize)
--			end
		end
	end
	
	love.graphics.setColor(0,1,0)
	for i, particle in pairs (particles) do
		local x = particle.x+1/4*tileSize
		local y = particle.y+1/4*tileSize
		love.graphics.rectangle('fill', x, y,tileSize/2,tileSize/2)
	end
	
	love.graphics.setColor(1,1,1)
	love.graphics.print (maxThickness, 32,32)
end

function createNewParticle (x,y,power)
	power = power or 10
	x=math.floor(x/tileSize)*tileSize
	y=math.floor(y/tileSize)*tileSize
	local particle = {x=x,y=y,power=power}
--	table.insert (particles, particle)
	return particle
end

function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
		table.insert (particles, createNewParticle (x,y))
	elseif button == 2 then -- right mouse button
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end