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

local function visit(maze, x, y)
	local directions = {{0, -1, "up"}, {0, 1, "down"}, {-1, 0, "left"}, {1, 0, "right"}}
	for _, dir in ipairs(shuffle (directions)) do
		local nx, ny = x + dir[1], y + dir[2]
		local exist = maze[ny] and maze[ny][nx]
		if exist and not (maze[ny][nx].visited) then
			local sideName = dir[3]
			maze[y][x][sideName] = false
			local oppositeSide = opposite (sideName)
			maze[ny][nx][oppositeSide] = false
			maze[ny][nx].visited = true
			visit(maze, nx, ny)
		end
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
			if cell.right then	love.graphics.line (x,   y-1, x,   y) end
			if cell.left 	then	love.graphics.line (x-1, y-1, x-1, y) end
			if cell.up 		then	love.graphics.line (x-1, y-1, x, y-1) end
			if cell.down 	then	love.graphics.line (x-1, y,   x,   y) end
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
