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
-- the path is ready!

local tileSize = 40

function love.draw ()
	
	love.graphics.translate (-tileSize, -tileSize)
	for y, xs in ipairs (grid) do
		for x, value in ipairs (xs) do
			if value == 0 then
				-- free
				love.graphics.setColor (0.45, 0.95, 0.45)
			else -- not free
				love.graphics.setColor (0.95, 0.45, 0.45)
			end
			love.graphics.rectangle ('fill', x*tileSize, y*tileSize, tileSize, tileSize)
		end
	end
	
	if path then
		local length = #path
		for i, tile in ipairs (path) do
			local c = 0.45 + ((length-i)/length)/2
			love.graphics.setColor (c,c,c*2)
			love.graphics.circle ('fill', (tile.x+0.5)*tileSize, (tile.y+0.5)*tileSize, tileSize/4)
			love.graphics.setColor (0,0,0)
			love.graphics.circle ('line', (tile.x+0.5)*tileSize, (tile.y+0.5)*tileSize, tileSize/4)
		end
	end
end

