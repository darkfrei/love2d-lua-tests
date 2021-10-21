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
	
--	for i = 0, 80 do
--		map[i]={}
--		map[i][1]=i
--	end
	
	tileSize = 20
	
	particles = {}
	
	maxThickness = 0
end

function get_direction (x,y)
	local directions = {{x=0,y=-1},{x=1,y=0},{x=0,y=1},{x=-1,y=0}}
	local value = map[x] and map[x][y] or false
	if not value then 
		if not map[x] then map[x]={} end
		if not map[x][y] then map[x][y]=1 end
		value = 0
	end
	for i = #directions, 1, -1 do
		local dir = directions[i]
		local xa, ya = x+dir.x, x+dir.x
		if map[xa] and map[xa][ya] then
			if map[xa][ya] >= value then
				table.remove(directions, i)
			end
		end
	end
--	print (#directions)
	return directions[math.random(#directions)]
end
 
function love.update(dt)
--	buffer = buffer or 0.1
--	if buffer < 0 then
--		buffer = 0.1
--	else
--		buffer = buffer-dt
--		return
--	end
	
	
	local new_particles = {}
	
	for i, particle in pairs (particles) do
		local power = particle.power - 1
		
		if power > 0 then
--			local dir = directions[math.random(#directions)]
			local x=math.floor(particle.x/tileSize)
			local y=math.floor(particle.y/tileSize)
			local dir = get_direction (x,y)
			if dir then
				x=x+dir.x
				y=y+dir.y
				particle.x, particle.y = x*tileSize, y*tileSize
				
				if math.random() < 0.1 then
					particle.power = power/2
--					table.insert (new_particles, createNewParticle (x,y, power/2))
					table.insert (new_particles, createNewParticle (particle.x, particle.y, power/2))
				end
				
				if math.random() < 0.8 then
--					y=math.floor(y/tileSize)
					if not map[x] then map[x] = {} end
					if not map[x][y] then 
						map[x][y] = 1
					else
						map[x][y] = map[x][y] + 1
						maxThickness = math.max (maxThickness, map[x][y])
					end
				end
			else
				map[x][y] = map[x][y] + 1
				
			end
		else
			particle.power = power
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

function get_color_from_gradient (t)
	if t<0.25 then
		return {(t)/0.25,0.25-t,0.25-t}
	elseif t<0.75 then
		return {1,(t-0.25)/0.55,0}
	elseif t>=1 then
		return {0,1,1}
	end
	
	return {1,1,(t-0.75)/0.25}
end

function love.draw()
	for x, ys in pairs (map) do
		for y, value in pairs (ys) do
--			if value then
				local c = value/maxThickness
--				c=1/16+15/16*c
--				love.graphics.setColor(c,c,c)
--				love.graphics.setColor(2*c,1-2*c,1)
				love.graphics.setColor(get_color_from_gradient (c))
				love.graphics.rectangle('fill', x*tileSize, y*tileSize,tileSize,tileSize)
--			end
		end
	end
	
	for i = 0, 80 do
		love.graphics.setColor(get_color_from_gradient (i/maxThickness))
		love.graphics.rectangle('fill', i*tileSize, 1*tileSize,tileSize,tileSize)
		love.graphics.print (i, i*tileSize,2*tileSize)
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
--		local power = math.random(100, 300)
		local power = 200
		table.insert (particles, createNewParticle (x,y, power))
	elseif button == 2 then -- right mouse button
		map={}
		maxThickness=0
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