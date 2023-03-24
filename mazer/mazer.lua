-- mazer.lua
-- tool to create mazes

-- cc0 (no license)
-- darkfrei 2023

local mazer = {}

local function shuffle (list)
	-- backward iteration from last to second element:
	for i = #list, 2, -1 do
		-- choose one of elements:
		local j = love.math.random(i) -- between 1 to i (both inclusive)
		-- replace both elements each other:
		list[i], list[j] = list[j], list[i]
	end
	return list
end

local oppositeTable = {
	up = "down",
	down = "up",
	left = "right",
	right = "left",
}

local function opposite (sideName)
	return oppositeTable[sideName]
end

local sideNames = {
	up={dx=0, dy=-1}, 
	down={dx=0, dy=1}, 
	left={dx=-1, dy=0}, 
	right={dx=1, dy=0}, 
}

local connectCell, visit

function connectCell (maze, x, y, sideName, deep)
	local dx, dy = sideNames[sideName].dx, sideNames[sideName].dy
	local exist = maze[y+dy] and maze[y+dy][x+dx]
	if not exist or (maze[y+dy][x+dx].visited) then
		return
	end
	
	maze[y][x][sideName] = false
	local oppositeSide = opposite (sideName)
	maze[y+dy][x+dx][oppositeSide] = false
	maze[y+dy][x+dx].visited = true
	if deep then
		return visit(maze, x+dx, y+dy)
	end
end

function visit(maze, x, y)
	local directions = {"up", "down", "left", "right"}
	for _, sideName in ipairs(shuffle (directions)) do
		connectCell (maze, x, y, sideName, true)
	end
end

function mazer.generateMaze(width, height, startX, startY)
	local maze = {}
	for y = 1, height do
		maze[y] = {}
		for x = 1, width do
			local cell = {up=true, down=true, left=true, right=true, visited = false}
			maze[y][x] = cell
		end
	end
	
	-- connect second to first:
	connectCell (maze, 2, 1, "left", false)
	startX = startX or love.math.random(width)
	startY = startY or love.math.random(height)
	maze[startY][startX].visited = true
	visit(maze, startX, startY)

	for y, xs in ipairs (maze) do
		for x, cell in ipairs (xs) do
			cell.visited = nil
		end
	end
	
	return maze
end

local function removeWallFromGrid (grid, x1, y1, x2, y2, wall)
	for gy = y1, y2 do
		for gx = x1, x2 do
			grid[gy][gx] = not wall
		end
	end
end

function mazer.createGrid (maze, wallSize, cellSize)
--	wallSize = 2
--	cellSize = 4
	local stepSize = wallSize + cellSize -- 6
	local h = wallSize + #maze*stepSize
	local w = wallSize + #maze[1]*stepSize
	
	local wall = true
	
	local grid = {}
	for gy = 1, h do
		grid[gy] = {}
		for gx = 1, w do
			grid[gy][gx] = wall
		end
	end
	
	for y, xs in ipairs (maze) do
		local gy1 = 1 + (y-1)*stepSize
		local gy2 = gy1 + stepSize + wallSize - 1
		for x, cell in ipairs (xs) do
			local gx1 = 1 + (x-1)*stepSize
			local gx2 = gx1 + stepSize + wallSize - 1
			
			removeWallFromGrid (grid, gx1 + wallSize, gy1 + wallSize, gx2-wallSize, gy2-wallSize, wall)
			
			if not cell.right then
				removeWallFromGrid (grid, gx1 + stepSize, gy1 + wallSize, gx2, gy2-wallSize, wall)
--				for gy = gy1 + wallSize, gy2-wallSize do
--					for gx = gx1 + stepSize, gx2 do
--						grid[gy][gx] = not wall
--					end
--				end
			end
			if not cell.left then
				removeWallFromGrid (grid, gx1, gy1 + wallSize, gx2-stepSize, gy2-wallSize, wall)
			end
			if not cell.up then
				removeWallFromGrid (grid, gx1+wallSize, gy1, gx2-wallSize, gy2-stepSize, wall)
			end
			if not cell.down then
				removeWallFromGrid (grid, gx1+wallSize, gy1+stepSize, gx2-wallSize, gy2, wall)
			end

		end
	end
	return grid
end

function mazer.drawMaze (maze)
	for y, xs in ipairs (maze) do
		for x, cell in ipairs (xs) do
			if cell.right then	love.graphics.line (x,	 y-1, x,	 y) end
			if cell.left 	then	love.graphics.line (x-1, y-1, x-1, y) end
			if cell.up 		then	love.graphics.line (x-1, y-1, x, y-1) end
			if cell.down 	then	love.graphics.line (x-1, y,	 x,	 y) end
		end
	end
end

function mazer.drawGrid (grid, gridSize, mode)
	gridSize = gridSize or 16
	mode = mode or 'fill'
	for y, xs in ipairs (grid) do
		for x, bool in ipairs (xs) do
			if bool then
				love.graphics.rectangle (mode, (x-1)*gridSize, (y-1)*gridSize, gridSize, gridSize)
			end
		end
	end
end

return mazer
