-- Lua implementation of the A* algorithm as a recursive function

-- darkfrei 2023

local function isTileFree (grid, x, y)
	if grid[y] and grid[y][x] ~= nil then
		return grid[y][x] == 0
	end
	return false
end

local function getNeighbors(grid, current, goal)
	local neighbors = {}
	local x, y = current.x, current.y
	for dy = -1, 1 do
		for dx = -1, 1 do
			if dx ~= 0 or dy ~= 0 then
				local nx, ny = x + dx, y + dy
				if isTileFree (grid, x, y) then
					local neighbor = {x=nx, y=ny} -- new node
					if dx == 0 or dy == 0 then
						neighbor.g = current.g + 1
					else
						neighbor.g = current.g + 1.41
					end
					neighbor.h = math.sqrt((nx - goal.x) ^ 2 + (ny - goal.y) ^ 2)
					neighbor.f = neighbor.g + neighbor.h
					table.insert(neighbors, neighbor)
				end
			end
		end
	end
	return neighbors
end


local function recursiveAstar(grid, start, goal, current, cache)
	cache = cache or {}
	if not current then 
		current = {x=start.x, y=start.y, g=0}
	end
	if current.x == goal.x and current.y == goal.y then
		-- found, return the list of nodes
		return {current}
	end
	if cache[current.y] and cache[current.y][current.x] then
		-- already was here
		return nil
	end
	cache[current.y] = cache[current.y] or {}
	cache[current.y][current.x] = true
	local neighbors = getNeighbors(grid, current, goal)
	table.sort(neighbors, function(a, b) return a.f < b.f end)
	for i, neighbor in ipairs(neighbors) do
		local path = recursiveAstar(grid, start, goal, neighbor, cache)
		if path then
			table.insert(path, 1, current)
			return path
		end
	end
	return nil
end

return recursiveAstar
