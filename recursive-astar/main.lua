--main.lua

recursiveAstar = require ('rastar') -- recursive astar

local grid = {
	{0,0,1,0,1},
	{0,0,0,0,1},
	{0,1,1,1,0},
	{0,0,0,0,0},
	{0,0,1,0,0},
}

local start = {x=1,y=1}
local goal = {x=5,y=5}
local path = recursiveAstar(grid, start, goal, current, cache)
for i, tile in ipairs (path) do
	print (tile.x, tile.y)
end
--[[ result:
1	1
2	2
3	2
4	2
5	3
5	4
5	5
]]