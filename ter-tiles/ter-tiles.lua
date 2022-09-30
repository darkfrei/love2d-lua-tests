

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
-- 2:
	{2,1,2,2,2,2,2,2}, 
	{2,2,2,1,2,2,2,2}, 
	{2,2,2,2,2,1,2,2}, 
	{2,2,2,2,2,2,2,1}, 
-- 6:
	{2,1,2,2,2,2,2,1}, 
	{2,1,2,1,2,2,2,2}, 
	{2,2,2,1,2,1,2,2}, 
	{2,2,2,2,2,1,2,1},  
--10:	
	{2,1,2,2,2,1,2,2},
	{2,2,2,1,2,2,2,1},
	
	{2,1,2,1,2,1,2,1},
-- 13:	
	{1,0,2,0,2,0,2,0}, -- up
	{2,0,1,0,2,0,2,0}, -- right
	{2,0,2,0,1,0,2,0}, -- down
	{2,0,2,0,2,0,1,0}, -- left
-- 17:	
	{1,0,2,1,2,2,2,0},
	{2,0,1,0,2,1,2,1},
	{2,2,2,0,1,0,2,1},
	{2,1,2,1,2,0,1,0},
-- 21
	{1,0,2,2,2,1,2,0},
	{2,0,1,0,2,2,2,1},
	{2,1,2,0,1,0,2,2},
	{2,2,2,1,2,0,1,0},
-- 25:
	{1,0,1,0,2,0,1,0}, -- not down
	{1,0,1,0,1,0,2,0}, -- not left
	{2,0,1,0,1,0,1,0}, -- not up
	{1,0,2,0,1,0,1,0}, -- not right
-- 29:	
	{1,0,1,0,2,0,2,0}, -- up right
	{2,0,1,0,1,0,2,0}, -- down right 
	{2,0,2,0,1,0,1,0}, -- down left
	{1,0,2,0,2,0,1,0}, -- up left
-- 33:	
	{1,0,1,0,2,1,2,0}, -- up right dot
	{2,0,1,0,1,0,2,1}, -- down right dot
	{2,1,2,0,1,0,1,0}, -- down left dot
	{1,0,2,1,2,0,1,0}, -- up left dot
-- 37:
	{1,0,2,0,1,0,2,0}, -- left-right
	{2,0,1,0,2,0,1,0}, -- up-down
	{1,0,1,0,1,0,1,0}, -- separeted
}
print ('#tileConnections', #tileConnections)

local image = LG.newImage("ter-tiles.png")
image:setFilter("nearest")

local tiles = {}
-- air tile, just for test
local air = {i=84, typ = 0, quad=LG.newQuad(10, 748, 8, 8, image), con = {0,0,0,0,0,0,0,0}}
tiles[84] = air

-- green tiles
function regenerateSprites()
	
	for i = 1, #tileConnections do -- vertical shift key
		local j = love.math.random (6)
		local x = (j)*9+1
		-- y: 1, 10, 19, 28
		local y = (i-1)*9+1
		local quad = LG.newQuad(x, y, 8, 8, image)
		local tile = {i=i, typ = 1, quad=quad, con = tileConnections[i]}
		tiles[i] = tile
	end
end
regenerateSprites()

local TT = {}
TT.tiles = tiles
TT.image = image

local function getBetterTile (neighbours, typ)
	local best_i
	local bestSum
	for i, sprite in pairs (tileConnections) do
		local sum = 0
		for j = 1, #sprite do
--			print (j, neighbours[j], sprite[j])
			if neighbours[j] == 0 or sprite[j] == 0 then
				sum = sum + 10
			elseif neighbours[j] == sprite[j] then
				sum = sum + 11
			end
		end
		if not bestSum or bestSum < sum then
			bestSum = sum
			best_i = i
		end
--		print (i, bestSum)
	end
	
	return best_i
end

function TT.load (map)
	-- map has tiles as numbers:
	-- 0 for air; 
	-- 1 for ground
	for y, xs in ipairs (map) do
		for x, tile in ipairs (xs) do
			if tile == 0 then
				map[y][x] = air
--			elseif tile == 1 then
			else
				map[y][x] = tiles[6]
			end
		end
	end
	
	-- now tiles are tables
	for y, xs in ipairs (map) do
		for x, tile in ipairs (xs) do
			local typ = tile.typ
			local neighbours = {}
			if not (map[y][x].typ == 0) then
				for i, dir in ipairs (dirs) do
					local x1 = x + dir.x
					local y1 = y + dir.y
					
					local tileExists = map[y1] and map[y1][x1] and true or false
					if tileExists then
						
						if map[y1][x1].typ == typ then
							table.insert (neighbours, 2)
						else
							table.insert (neighbours, 1)
						end
					else
--						table.insert (neighbours, 0)
						table.insert (neighbours, 2)
					end
				end
				
				-- find better tile
				local betterTile = getBetterTile (neighbours, typ)
				
				if betterTile and tiles[betterTile] then
					map[y][x] = tiles[betterTile]
				else
					print ('betterTile not exists ', betterTile)
					
				end
			end
		end
	end
end


return TT

