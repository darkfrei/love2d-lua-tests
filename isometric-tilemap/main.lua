-- related https://love2d.org/forums/viewtopic.php?t=96314


local tileSize = 16
local scale = 5

local offsetX = 400/scale
local offsetY = 100/scale
local depthOffset = tileSize / 2 -1

local isoWidth = tileSize / 2
local isoHeight = tileSize / 4


map = { -- [z][y][x]
	{
		{5,3,3,2,3,3,3,2},
		{4,1,1,1,1,1,1,2},
		{4,1,1,1,1,1,1,2},
		{4,1,1,1,1,1,1,2},
		{2,1,1,1,1,1,1,2},
		{4,1,1,1,1,1,1,2},
		{4,1,1,1,1,1,1,2},
		{4,1,1,1,1,1,1,2},
		{4,1,1,1,1,1,1,2},
		{2,2,2,2,2,2,2,2},
	},
	{
		{0,0,0,2,0,0,0,2},
		{0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0},
		{4,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0},
		{2,0,0,0,0,0,0,0},
	},
	{
		{0,0,0,3,0,0,0,3},
		{0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0},
		{4,0,0,0,0,0,0,0},
	}
}

local function getQuads(tileset, spacingX, spacingY)
	local quads = {}
	local tilesetWidth = tileset:getWidth()
	local tilesetHeight = tileset:getHeight()

	print (tilesetWidth, tilesetHeight)

	for j = 0, (tilesetHeight / (tileSize + spacingY)) do
		for i = 0, (tilesetWidth / (tileSize + spacingX)) do
			local x = i * (tileSize + spacingX)
			local y = j * (tileSize + spacingY)

			local quad = love.graphics.newQuad(x, y, tileSize, tileSize, tilesetWidth, tilesetHeight)
			table.insert(quads, quad)

			print ('quad y:'..j..' x:'..i)
		end
	end
	return quads
end

function love.load()
	-- load tileset and generate quads
	tileset = love.graphics.newImage('tiles-16x16-s1-1.png')
	tileset:setFilter('nearest', 'nearest')
	quads = getQuads(tileset, 1, 1)
end

function love.draw()
	love.graphics.scale (scale)
	for z = 1, #map do
		for y = 1, #map[z] do
			for x = 1, #map[z][y] do
				local tile = map[z][y][x]
				if tile ~= 0 then
					local screenX = offsetX + (x - y) * isoWidth
					local screenY = offsetY + (x + y) * isoHeight - (z - 1) * depthOffset
					love.graphics.draw(tileset, quads[tile], screenX, screenY)
				end
			end
		end
	end
end
