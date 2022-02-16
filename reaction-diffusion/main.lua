-- License CC0 (Creative Commons license) (c) darkfrei, 2022

function createMap (width, height)
	grid, ngrid = {}, {}
	
	-- everywhere b
	for x = 1, width do
		if not grid[x] then grid[x] = {} end
		if not ngrid[x] then ngrid[x] = {} end
		for y = 1, height do
			local a = 0
			local b = 1
			grid[x][y] = {a=a, b=b}
			ngrid[x][y] = {a=a, b=b}
		end
	end
	
	-- spot of a
	for x = width/2-11, width/2+11 do
		for y = height/2-10, height/2+10 do
			local a = 0.9+ 0.1*math.random()
			local b = 0
			grid[x][y] = {a=a, b=b}
		end
	end
	
	-- spot of a
	for x = width/4-11, width/4+11 do
		for y = height/4-20, height/4+10 do
			local a = 0.9+ 0.1*math.random()
			local b = 0
			grid[x][y] = {a=a, b=b}
		end
	end
end

function love.load()
	width, height = 1920, 1080
	
	love.window.setMode(width, height, {resizable=true, borderless=false})

	

	createMap (width, height)
	da = 1
	db = 0.5
	feed = 0.055
	k = 0.062
	
	getinfo = false
	
	n = 0
	points = {}
	pause = true
end


function getValue (x, y)
	x = (x-1)%width+1
	y = (y-1)%height+1
	return grid[x][y]
end

function laplaceA (x, y)
	local summ = 0
	summ =  getValue     (x, y).a * -1 +
			getValue   (x-1, y).a * 0.2 +
			getValue   (x+1, y).a * 0.2 +
			getValue   (x, y-1).a * 0.2 +
			getValue   (x, y+1).a * 0.2 +
			getValue (x+1, y+1).a * 0.05 +
			getValue (x-1, y+1).a * 0.05 +
			getValue (x+1, y-1).a * 0.05 +
			getValue (x-1, y-1).a * 0.05
	return summ
end

function laplaceB (x, y)
	local summ = 0
	summ =  getValue     (x, y).b * -1 +
			getValue   (x-1, y).b * 0.2 +
			getValue   (x+1, y).b * 0.2 +
			getValue   (x, y-1).b * 0.2 +
			getValue   (x, y+1).b * 0.2 +
			getValue (x+1, y+1).b * 0.05 +
			getValue (x-1, y+1).b * 0.05 +
			getValue (x+1, y-1).b * 0.05 +
			getValue (x-1, y-1).b * 0.05
	return summ
end


local function getColor (a, b)
	local color = math.abs(a - b)
--			high sigmoid:
--			https://www.desmos.com/calculator/sllolyvy2e
	local c = 0.45
	if color < c then color = 0
	elseif color > (1-c) then color = 1
	else 
		color = 0.5/(0.5-c)*color-4.5
		color = 3*color*color - 2*color*color*color
	end
	return color, color, color
end


 
function love.update(dt)
	dt = 1.1
	
	if not pause then
		points = {}
		for i = 1, 30 do
			n = n+1
			for x = 1, width do
				for y = 1, height do
					local cell = getValue (x, y)
					local a, b = cell.a, cell.b
					ngrid[x][y].a = a + (da*laplaceA(x, y)-a*b*b+feed*(1-a))*dt
					ngrid[x][y].b = b + (db*laplaceB(x, y)+a*b*b-(k+feed)*b)*dt
					
					if i == 30 then
						local r, g, b = getColor (a, b)
						local point = {x, y, r, g, b}
						table.insert (points, point)
					end
				end
			end
			grid, ngrid = ngrid, grid
		end
		
	end
	
end


function love.draw()
	local scale = 1
	love.graphics.setColor (1,1,1)
	love.graphics.points (points)
--	for x = 1, width do
--		for y = 1, height do
--			local cell = getValue (x, y)

			

--			love.graphics.setColor (color, color, color)
--			love.graphics.rectangle ('fill', (x-1)*scale, (y-1)*scale, scale, scale)
--		end
--	end
	
	if not pause then
		love.graphics.captureScreenshot( 'caprure_' .. string.format("%06d", n) .. '.png')
	else
		love.graphics.print("pause, press space", 10, 30)
	end

	
	if getinfo then 
		love.graphics.setColor (0,1,0)
		love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
		local x, y = love.mouse.getPosition()
		x = math.floor (x/scale)
		y = math.floor (y/scale)
		local value = getValue     (x, y)
		love.graphics.print(value.a .. '\n' ..value.b, x*scale, y*scale-50)
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "space" then
		pause = not pause
	elseif key == "i" then
		getinfo = not getinfo
	elseif key == "escape" then
		love.event.quit()
	end
end

function updatePoints ()
	points = {}
	for x = 1, width do
		for y = 1, height do
			local cell = getValue (x, y)
			local r, g, b = getColor (cell.a, cell.bb)
			local point = {x, y, r, g, b}
			table.insert (points, point)
		end
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	local s = math.random (20, 50)
	
	for i = x-s, x+s do
		for j = y-s, y+s do
			grid[i][j] = {a=1, b=0}
		end
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end