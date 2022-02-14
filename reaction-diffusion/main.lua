-- License CC0 (Creative Commons license) (c) darkfrei, 2022

function createMap (width, height)
	grid, ngrid = {}, {}
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
	for x = width/2-11, width/2+11 do
		for y = height/2-10, height/2+10 do
			local a = 0.9+ 0.1*math.random()
			local b = 0
			grid[x][y] = {a=a, b=b}
		end
	end
end

function love.load()

	love.window.setMode(1200, 1200, {resizable=true, borderless=false})

	width, height = 200, 200

	createMap (width, height)
	da = 1
	db = 0.5
	feed = 0.055
	k = 0.062
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
 
function love.update(dt)
	dt = 5*dt
	for i = 1, 10 do
		for x = 1, width do
			for y = 1, height do
				local cell = getValue (x, y)
				local a, b = cell.a, cell.b
				
				ngrid[x][y].a = a + (da*laplaceA(x, y)-a*b*b+feed*(1-a))*dt
				ngrid[x][y].b = b + (db*laplaceB(x, y)+a*b*b-(k+feed)*b)*dt
			end
		end
		grid, ngrid = ngrid, grid
	end
end


function love.draw()
	for x = 1, width do
		for y = 1, height do
			local cell = getValue (x, y)
			local a, b = cell.a, cell.b
			love.graphics.setColor (a,(a+b)/2,b)
			love.graphics.rectangle ('fill', (x-1)*6, (y-1)*6, 6, 6)
		end
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
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