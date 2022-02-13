-- License CC0 (Creative Commons license) (c) darkfrei, 2022

levels = {}

for i = 1, 6 do
	local level = love.filesystem.load ('levels/level-'..i..'.lua')
	table.insert (levels, level)
end

function loadLevel ()
	if not levels[nLevel] then
		nLevel = 1
	end
	
	local newLevel = levels[nLevel]()
	level = {points={}}
	local width, height = love.graphics.getDimensions( )
	for i = 1, #newLevel, 2 do
		local x = newLevel[i] * width
		local y = newLevel[i+1] * height
		local point = {x=x, y=y, r=20}
		table.insert (level.points, point)
	end
end

function love.load()
	nLevel = 1
	loadLevel ()
end

function love.update(dt)
	
end

function love.draw()
	love.graphics.print ('level: '..nLevel, 0, 0)
	love.graphics.print ('points: '..#level.points, 0, 20)
	for i, point in ipairs (level.points) do
		love.graphics.circle ('line', point.x, point.y, point.r)
	end
	
	if level.done then
		love.graphics.print ('done! Press any key', 0, 40)
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	for i, point in ipairs (level.points) do
		local dx, dy = math.abs(x-point.x), math.abs(y-point.y)
		if dx < point.r and dy < point.r then
			local dist = (dx*dx+dy*dy)^0.5
			if dist <= point.r then
				table.remove (level.points, i)
				if #level.points == 0 then
					level.done = true
				end
			end
		end
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
	
	if level.done then
		nLevel = nLevel + 1
		loadLevel ()
	end
end
