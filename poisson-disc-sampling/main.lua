-- poisson-disc-sampling

-- License CC0 (Creative Commons license) (c) darkfrei, 2022
-- https://youtu.be/SdPaPliAi7s

love.window.setMode( 1920, 1080)
love.window.setTitle( "poisson-disc-sampling-04.love" )


local width, height = love.graphics.getDimensions( )
local w, h = 20*5, 15*5
local tileSize = math.floor(math.min (width/w, height/h))
w = math.floor(width/tileSize)
h = math.floor(height/tileSize)
local tileRadius = tileSize*math.sqrt(2)
print ('tileSize', tileSize)
local point = {x=tileSize*w/2+tileSize/2, y=tileSize*h/2, connections = {}}
local points = {point}

local gridMap = {}
local gx = math.floor(point.x/tileSize)
local gy = math.floor(point.y/tileSize)
gridMap[gy]={}
gridMap[gy][gx]=point

showMode = {value = 1, circles = true, points = true, grid = false, squares = false, connections = true}

love.graphics.setPointSize( 4 )





local function tryCreateCircle (gx, gy)
--	print (gx, gy)
	if gridMap[gy] and gridMap[gy][gx] then
		-- impossible to create on busy grid tile
		return false
	end
	local x = (gx+math.random())*tileSize
	local y = (gy+math.random())*tileSize
	local notTooFar = false
	local connections = {}
	local shortestCon
	for j = -3, 3 do
		for i = -3, 3 do
			if not (i == 0 and j == 0) then
				if gridMap[gy+j] and gridMap[gy+j][gx+i] then
					local dx = x-gridMap[gy+j][gx+i].x
					local dy = y-gridMap[gy+j][gx+i].y
					if dx*dx+dy*dy < tileRadius*tileRadius then
						-- collision
						return false
					elseif (dx*dx+dy*dy) < 4*tileRadius*tileRadius then
--						print ('notTooFar')
						notTooFar = true
						table.insert (connections, {x, y, gridMap[gy+j][gx+i].x, gridMap[gy+j][gx+i].y, sqrdist = (dx*dx+dy*dy)})
					else
--						print ('TooFar', (dx*dx+dy*dy), 4*tileRadius*tileRadius)
					end
				end
			end
		end
	end
	
	if #connections > 2 then
		for i = 1, #connections-1 do
			local index = 1
			local longest = connections[index].sqrdist
			
			for j = 2, #connections do
				if longest < connections[j].sqrdist  then 
					index = j
					longest = connections[j].sqrdist
				end
			end
			-- remove longest
			table.remove (connections, index)
		end
	end
	
	
	
	if notTooFar then
		-- new point!
		local point = {x=x, y=y, connections=connections}
		gridMap[gy] = gridMap[gy] or {}
		gridMap[gy][gx] = point
		table.insert (points, point)
		return true
	else
		return false -- too far
	end
end

--[[
local seq3 = {}
for i = -3, 3 do
	for j = -3, 3 do
		if not (i == 0 and j == 0) then
			table.insert (seq2, "{x="..i..", y="..j.."}")
		end
	end
end
print (table.concat (seq3, ", "))
--]]

local function createNewPoints (x, y)
	local gx = math.floor(x/tileSize)
	local gy = math.floor(y/tileSize)
	local amount = 0
	local seq1 = {{x=0, y=-1}, {x=1, y=-1}, {x=1, y=0}, {x=1, y=1}, {x=0, y=1}, {x=-1, y=1}, {x=-1, y=0}, {x=-1, y=-1},}
	local seq3 = {{x=-3, y=-3}, {x=-3, y=-2}, {x=-3, y=-1}, {x=-3, y=0}, {x=-3, y=1}, {x=-3, y=2}, {x=-3, y=3}, {x=-2, y=-3}, {x=-2, y=-2}, {x=-2, y=-1}, {x=-2, y=0}, {x=-2, y=1}, {x=-2, y=2}, {x=-2, y=3}, {x=-1, y=-3}, {x=-1, y=-2}, {x=-1, y=-1}, {x=-1, y=0}, {x=-1, y=1}, {x=-1, y=2}, {x=-1, y=3}, {x=0, y=-3}, {x=0, y=-2}, {x=0, y=-1}, {x=0, y=1}, {x=0, y=2}, {x=0, y=3}, {x=1, y=-3}, {x=1, y=-2}, {x=1, y=-1}, {x=1, y=0}, {x=1, y=1}, {x=1, y=2}, {x=1, y=3}, {x=2, y=-3}, {x=2, y=-2}, {x=2, y=-1}, {x=2, y=0}, {x=2, y=1}, {x=2, y=2}, {x=2, y=3}, {x=3, y=-3}, {x=3, y=-2}, {x=3, y=-1}, {x=3, y=0}, {x=3, y=1}, {x=3, y=2}, {x=3, y=3}}
	for ii = 1, #seq3 do
		local dxy = table.remove (seq3, math.random (#seq3))
		local i = dxy.x
		local j = dxy.y
		for k = 1, 30 do
			-- trying to create new circle
			if tryCreateCircle (gx+i, gy+j) then
				-- created
				amount = amount + 1
--				print ('break on ', k)
				break
			end
		end
	end
end

--createNewPoints (point.x, point.y)

function love.load()
	

	
end

 
function love.update(dt)
	
end


function love.draw()
	
	-- draw grid
	if showMode.grid then
		love.graphics.setColor (0.5,0.5,0.5)
		for i = 1, w do
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
		love.graphics.setColor (0,0.4,0)
		for i, point in ipairs (points) do
			love.graphics.circle ('line', point.x, point.y, tileRadius)
		end
	end
	
	-- draw connections
	if showMode.connections then
		love.graphics.setColor (1,1,1)
		for i, point in ipairs (points) do
			for j, line in ipairs (point.connections) do
				love.graphics.line (line)
			end
		end
	end
	
	-- draw points
	if showMode.points then
		
		for i, point in ipairs (points) do
			
			if #point.connections == 0 then
				love.graphics.setColor (1,1,1)
			elseif #point.connections == 1 then
				love.graphics.setColor (0,1,0)
			elseif #point.connections == 2 then
				love.graphics.setColor (1,1,0)
			elseif #point.connections == 3 then
				love.graphics.setColor (1,0,0)
			else
				love.graphics.setColor (0,1,1)
			end
			love.graphics.points (point.x, point.y)
		end
	end
--	love.graphics.setColor (1,1,1)
--	love.graphics.print (showMode.value..'\nPress Space to change view\nPress G for grid')
end

function love.keypressed(key, scancode, isrepeat)
	if key == "space" then
		showMode.value = showMode.value + 1
		
		showMode.points = (showMode.value%2 == 0) and true or false
		showMode.circles = (showMode.value%3 == 0) and true or false
		showMode.squares = (showMode.value%5 == 0) and true or false
		showMode.connections = (showMode.value%7 == 0) and true or false
	elseif key == "s" then
		-- erasing
		local point = points[1]
		points = {point}
		gridMap ={}
		gridMap[gy]={}
		gridMap[gy][gx]=point
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
	createNewPoints (x, y)
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end