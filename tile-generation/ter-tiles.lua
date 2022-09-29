

-- something like terraria tiles

local LG = love.graphics


-- neighbour positions as directions
local dirs = {
{x= 0, y=-1}, -- top
{x= 1, y=-1}, -- top-right
{x= 1, y= 0}, -- right
{x= 1, y= 1}, -- bottom-right
{x= 0, y= 1},
{x=-1, y= 1},
{x=-1, y= 0},
{x=-1, y=-1},
} 

local tileConnections = {
-- 0 - not defined
-- 1 - black outline
-- 2 - for ore connection
-- 3 - mud connection
--   1 -- up
--       1 -- right
--           1 -- down
--               1 -- left

-- 1:
	{2,2,2,2,2,2,2,2}, 
	{2,1,2,1,2,1,2,1},
-- 3:	
	{1,0,2,0,2,0,2,0}, -- up
	{2,0,1,0,2,0,2,0}, -- right
	{2,0,2,0,1,0,2,0}, -- down
	{2,0,2,0,2,0,1,0}, -- left
-- 7:	
	{1,0,1,0,2,0,1,0}, -- not down
	{1,0,1,0,1,0,2,0}, -- not left
	{2,0,1,0,1,0,1,0}, -- not up
	{1,0,2,0,1,0,1,0}, -- not right
-- 11:	
	{1,0,1,0,2,0,2,0}, -- up right
	{2,0,1,0,1,0,2,0}, -- down right 
	{2,0,2,0,1,0,1,0}, -- down left
	{1,0,2,0,2,0,1,0}, -- up left
-- 15:	
	{1,0,2,0,1,0,2,0}, -- left-right
	{2,0,1,0,2,0,1,0}, -- up-down
	{1,0,1,0,1,0,1,0}, -- separeted
}

local image = LG.newImage("ter-tiles.png")
image:setFilter("nearest")

local tiles = {}
-- air tile, just for test
tiles[80] = {typ = 0, quad=LG.newQuad(10, 712, 8, 8, image), con = {0,0,0,0,0,0,0,0}}

-- green tiles
for i = 1, 17 do -- vertical shift key
	local x = 10
	-- y: 1, 10, 19, 28
	local y = (i-1)*9+1
	local quad = LG.newQuad(x, y, 8, 8, image)
	local tile = {typ = 1, quad=quad, con = tileConnections[i]}
	tiles[i] = tile
end

local TT = {}
TT.tiles = tiles
TT.image = image

function TT.load (map)
	-- map has tiles as numbers:
	-- 0 for air; 
	-- 1 for ground
	for y, xs in ipairs (map) do
		for x, tile in ipairs (xs) do
			if tile == 0 then
				map[y][x] = tiles[80]
--			elseif tile == 1 then
			else
				map[y][x] = tiles[2]
			end
		end
	end
	
	-- now tiles are tables
--	for y, xs in ipairs (map) do
--		for x, tile in ipairs (xs) do
--			local neigbours = {}
--			for i, dir in ipairs (dirs) do
--				local x1 = x + dir.x
--				local y1 = y + dir.y
				
--				local tileExists = map[y1] and map[y1][x1] and true or false
--			end
--		end
--	end
end


return TT

