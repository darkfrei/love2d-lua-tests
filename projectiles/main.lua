function love.load()
	projectiles = {}
	width, height = love.graphics.getDimensions( )
	for i = 1, 100 do
		local projectile = {}
		projectile.x = math.random(width)
		projectile.y = math.random(height)
		projectile.vx = math.random(200)-100
		projectile.vy = math.random(200)-100
		table.insert(projectiles, projectile)
	end
	
--	max = 1
--	numbers = {}
--	for i = 1, width do
--		numbers[i] = 1
--	end
end

function love.update(dt)
	-- https://love2d.org/wiki/love.keyboard.isDown
	if love.keyboard.isDown("r") then
		for i, projectile in pairs (projectiles) do
			 -- vx and vy are horizontal and vertical velocities
			projectile.x = (projectile.x + dt*projectile.vx)%width
			projectile.y = (projectile.y + dt*projectile.vy)%height
		end
	end
	
--	for j = 1, width do
--		local i = math.random (width)
--		numbers[i] = numbers[i] + 1
--		if max < numbers[i] then
--			max = numbers[i]
--		end
--	end
end

function love.draw()
	love.graphics.setColor(1,1,1)
	for i, projectile in pairs (projectiles) do
		love.graphics.circle('fill', projectile.x, projectile.y, 5)
	end
	
	
--	for i = 1, width do
--		local value = numbers[i]/max
--		love.graphics.line(i, height, i, (1-value)*height)
--	end
end