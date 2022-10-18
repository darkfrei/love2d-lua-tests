-- poisson-disc-sampling

-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local width, height = love.graphics.getDimensions( )
local w, h = 20, 15
local tileSize = math.floor(math.min (width/w, height/h))
local tileRadius = tileSize*math.sqrt(2)/2
print ('tileSize', tileSize)
local point = {x=tileSize*w/2+tileSize/2, y=tileSize*h/2}
local points = {point}

local gridMap = {}
showMode = {value = 1, circles = true, points = true, grid = true, squares = true}

love.graphics.setPointSize( 2 )


local function tryCreateCircle (gx, gy)
	if gridMap[gy] and gridMap[gy][gx] then
		-- impossible to create on busy grid tile
		return false
	end
	local x = (gx+math.random())*tileSize
	local y = (gy+math.random())*tileSize
	for j = -2, 2 do
		for i = -2, 2 do
			if not (i == 0 and j == 0) then
				if gridMap[gy+j] and gridMap[gy+j][gx+i] then
					local dx = x-gridMap[gy+j][gx+i].x
					local dy = y-gridMap[gy+j][gx+i].y
					if dx*dx+dy*dy < tileRadius*tileRadius then
						-- collision
						return false
					end
				end
			end
		end
	end
	-- new point!
	local point = {x=x, y=y}
	gridMap[gy] = gridMap[gy] or {}
	gridMap[gy][gx] = point
	table.insert (points, point)
	return true
end

local amount = 0
for j = -2, 2 do
	for i = -2, 2 do
		if not (i == 0 and j == 0) then
			-- not same cell
			local gx = math.floor(point.x/tileSize) + i
			local gy = math.floor(point.y/tileSize) + j
			for k = 1, 30 do
				-- trying to create new circle
				if tryCreateCircle (gx, gy) then
					-- created
					amount = amount + 1
					print ('break on ', k)
					break
				end
			end
		end
	end
end
print ('created new points: ', amount)

function love.load()
	

	
end

 
function love.update(dt)
	
end


function love.draw()
	-- draw grid
	if showMode.grid then
		love.graphics.setColor (0.5,0.5,0.5)
		for i = 1, w-1 do
			love.graphics.line (i*tileSize, 0, i*tileSize, h*tileSize)
		end
		for j = 1, h-1 do
			love.graphics.line (0, j*tileSize,  w*tileSize, j*tileSize)
		end
	end
	
	-- draw squares
	
	if showMode.squares then
		
		for i, point in ipairs (points) do
			local gx = math.floor(point.x/tileSize)
			local gy = math.floor(point.y/tileSize)
			if (gx+gy) %2 == 0 then 
				love.graphics.setColor (0.5,0.5,0.5)
			else
				love.graphics.setColor (0.4,0.4,0.4)
			end
			love.graphics.rectangle ('fill', gx*tileSize, gy*tileSize, tileSize, tileSize)
		end
	end
	-- draw circles
	if showMode.circles then
		love.graphics.setColor (1,1,1)
		for i, point in ipairs (points) do
			love.graphics.circle ('line', point.x, point.y, tileRadius)
		end
	end
	
	-- draw points
	if showMode.points then
		love.graphics.setColor (1,1,1)
		for i, point in ipairs (points) do
			love.graphics.points (point.x, point.y)
		end
	end
	love.graphics.setColor (1,1,1)
	love.graphics.print (showMode.value..'\nPress Space to change view\nPress G for grid')
end

function love.keypressed(key, scancode, isrepeat)
	if key == "space" then
		showMode.value = showMode.value + 1
		
		showMode.points = (showMode.value%2 == 0) and true or false
		showMode.circles = (showMode.value%3 == 0) and true or false
		showMode.squares = (showMode.value%5 == 0) and true or false
	elseif key == "g" then
		showMode.grid = not showMode.grid
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