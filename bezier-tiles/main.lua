-- License CC0 (Creative Commons license) (c) darkfrei, 2023

-- bezier tiles

tilemap = {
	{2,2,1,2,2},
	{2,2,2,1,2},
	{1,2,1,2,2},
	{1,2,1,1,2},
	}

local function isTile (map, x, y, value)
	if map[y] and map[y][x] and map[y][x] == value then
		return true
	end
	return false
end

size = 60

local function getBezier (x, y, x1,y1, x2,y2, x3,y3, x4,y4)
	local curve = love.math.newBezierCurve(
		(x-1+x1/2)*size, (y-1+y1/2)*size, 
		(x-1+x2/2)*size, (y-1+y2/2)*size, 
		(x-1+x3/2)*size, (y-1+y3/2)*size, 
		(x-1+x4/2)*size, (y-1+y4/2)*size)
	local line = curve:render()
	return line
end

local function getLine (x, y, x1,y1, x2,y2)
	return {(x-1+x1/2)*size, (y-1+y1/2)*size, (x-1+x2/2)*size, (y-1+y2/2)*size}
end

--neigbours
local neigbours = {{x=-1, y=-1}, {x=0, y=-1}, {x=1, y=-1}, {x=1, y=0}, {x=1, y=1}, {x=0, y=1}, {x=-1, y=1}, {x=-1, y=0}}


local function createLines (k0)
	lines = {}
	local k = 1-k0
	local k1 = 2-k
	for y, xs in ipairs (tilemap) do
		for x, value in ipairs (xs) do
			local bool = isTile (tilemap, x, y, value)
			local bools = {}
			for i, n in ipairs (neigbours) do
				local tempBool = isTile (tilemap, x+n.x, y+n.y, value)
				table.insert (bools, tempBool)
			end
			if bool then
				
	--			if (not bools[1]) and (not bools[2]) and (not bools[8]) or ((bools[1]) and (not bools[2]) and (not bools[8])) then
				if (not bools[2]) and (not bools[8]) then
					table.insert (lines, getBezier (x, y, 0,1, 0,k, k,0, 1,0))
				end
	--			if (not bools[2]) and (not bools[3]) and (not bools[4]) or ((not bools[2]) and (bools[3]) and (not bools[4])) then
				if (not bools[2]) and (not bools[4]) then
					table.insert (lines, getBezier (x, y, 1,0, k1,0, 2,k, 2,1))
				end
				
	--			if (not bools[4]) and (not bools[5]) and (not bools[6]) then
				if (not bools[4]) and (not bools[6]) then
					table.insert (lines, getBezier (x, y, 2,1, 2,k1, k1,2, 1,2))
				end	
	--			if (not bools[6]) and (not bools[7]) and (not bools[8]) then
				if (not bools[6]) and (not bools[8]) then
					table.insert (lines, getBezier (x, y, 1,2, k,2, 0,k1, 0,1))
				end
				
				-- top
				if not bools[2] then
					if bools[8] and not bools[1] then
						table.insert (lines, getLine (x, y, 0,0, 1,0))
					end
					if bools[4] and not bools[3] then
						table.insert (lines, getLine (x, y, 1,0, 2,0))
					end
				end
				
				-- right
				if not bools[4] then
					if bools[2] and not bools[3] then
						table.insert (lines, getLine (x, y, 2,0, 2,1))
					end
					if bools[6] and not bools[5] then
						table.insert (lines, getLine (x, y, 2,1, 2,2))
					end
				end
				
				-- bottom
				if not bools[6]then
					if bools[4] and not bools[5]  then
						table.insert (lines, getLine (x, y, 2,2, 1,2))
					end
					if bools[8] and not bools[7] then
						table.insert (lines, getLine (x, y, 1,2, 0,2))
					end
				end
				
				-- left
				if not bools[8] then
					if bools[6] and not bools[7] then
						table.insert (lines, getLine (x, y, 0,2, 0,1))
					end
					if bools[2] and not bools[1] then
						table.insert (lines, getLine (x, y, 0,1, 0,0))
					end
				end
				
			else
				if ((bools[1]) and (bools[2]) and (bools[8])) then
					table.insert (lines, getBezier (x, y, 0,1, 0,k, k,0, 1,0))
				end
				if (bools[2]) and (bools[3]) and (bools[4]) then
					table.insert (lines, getBezier (x, y, 1,0, k1,0, 2,k, 2,1))
				end
				
				if (bools[4]) and (bools[5]) and (bools[6]) then
					table.insert (lines, getBezier (x, y, 2,1, 2,k1, k1,2, 1,2))
				end	
				if (bools[6]) and (bools[7]) and (bools[8]) then
					table.insert (lines, getBezier (x, y, 1,2, k,2, 0,k1, 0,1))
				end
			end
		end
	end
end


--local k0 = math.sqrt(2) / 3
local n = 4 -- 90 degrees
-- k0 = 0.55228474983079 -- circle value for 90 degrees
local k0 = math.tan(math.pi/(2*n))*4/3 -- circle bezier

createLines (k0)


function love.load()
	
end

 
function love.update(dt)
	
end


function love.draw()
	love.graphics.translate (10,10)
	for i, line in ipairs (lines) do
		love.graphics.line(line)
	end
--	love.graphics.circle ('line', 5*160/2,160/2,160/2)
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
	if love.mouse.isDown(1) then
		local w = love.graphics.getWidth()
		createLines (4*x/w-1.5)
	end
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
		createLines (k0)
	elseif button == 2 then -- right mouse button
	end
end