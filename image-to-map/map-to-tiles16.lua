-- tiles16 is a system with 16 tiles:

local tiles16 = {}

local neighbors = {
	{x=0, y=-1}, -- 1
	{x=1, y=0}, -- 2
	{x=0, y=1}, -- 4
	{x=-1, y=0}, -- 8
}

local variations = {
	{0,0,0,0}, -- nothing around it
	{1,0,0,0}, -- one tile above
	{0,1,0,0}, -- one tile right
	{1,1,0,0}, -- tiles: right and above
	{0,0,1,0}, -- one tile below
	{1,0,1,0}, -- tiles: below, above
	{0,1,1,0}, -- tiles: below, right
	{1,1,1,0}, -- tiles: below, right, above
	{0,0,0,1}, -- one tile left
	{1,0,0,1}, -- tiles: left, above
	{0,1,0,1}, -- tiles: left, right
	{1,1,0,1}, -- tiles: left, rigt, above
	{0,0,1,1}, -- tiles: left, below
	{1,0,1,1}, -- tiles: left, below, above
	{0,1,1,1}, -- tiles: left, below, right
	{1,1,1,1}, -- tiles: left, below, right, above
}

-- convert to bools:
for i, variation in ipairs (variations) do
	for j = 1, 4 do
		variation[j] = (variation[j] == 1) and true or false
	end
end

function tiles16.newQuads (filename, width, height, shiftX, shiftY)
	local image = love.graphics.newImage(filename)
	width = width or image:getWidth()/16 -- 16 tiles in the row
	height = height or image:getHeight() -- 1 tile in the column
	shiftX, shiftY = shiftX or 0, shiftY or 0
	local quads = {}
	for i, variation in ipairs (variations) do
		local quad = love.graphics.newQuad(shiftX+(i-1)*width, shiftY, width, height, image)
		table.insert (quads, quad)
	end
	return quads, image
end

local function isValue (map, x, y, value, connected)
	if connected then
		y = (y-1)% (#map) + 1
		x = (x-1)% (#map[y]) + 1
	end
	return map[y] and map[y][x] and map[y][x] == value and true or false
end

local function getVariant (map, x, y, value)
	local sum = 1
	for i, n in ipairs (neighbors) do
		if isValue (map, x+n.x, y+n.y, value, true) then
			sum = sum + 2^(i-1)
		end
	end
	return sum
end

function tiles16.newGrid (map, value)
	local grid = {}
	for y = 1, #map do
		grid[y] = {}
		for x = 1, #map[y] do
			if map[y][x] == value then
				grid[y][x] = getVariant (map, x, y, value)
			else
				grid[y][x] = 0
			end
		end
	end
	return grid
end

return tiles16

