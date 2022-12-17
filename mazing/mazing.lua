-- mazing, lua lib for  mazes
-- 2022-12-17 v. 0.1

-- Copyright 2022 darkfrei

-- MIT License:
-- Permission is hereby granted, free of charge, to any person obtaining 
-- a copy of this software and associated documentation files (the "Software"), 
-- to deal in the Software without restriction, including without limitation 
-- the rights to use, copy, modify, merge, publish, distribute, sublicense, 
-- and/or sell copies of the Software, and to permit persons to whom 
-- the Software is furnished to do so, subject to the following conditions:
 
-- The above copyright notice and this permission notice shall be included 
-- in all copies or substantial portions of the Software.
 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
-- OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
-- DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
-- OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

-- https://opensource.org/licenses/MIT

----------------------------------------
-- shortings:
--local random = love.math.random
local random = math.random
local insert = table.insert
----------------------------------------
-- settings
MAXCELLSIZE = 3
----------------------------------------

local mazing = {}

local function isBusy (grid, x, y, w, h)
	for x1 = x, x+w-1 do
		for y1 = y, y+h-1 do
			if grid[y1] and grid[y1][x1] and grid[y1][x1].busy then
				return true
			elseif not (grid[y1] and grid[y1][x1]) then
				return true -- out of map
			end
		end
	end
	return false
end

local function setBusy (grid, x, y, w, h)
	for x1 = x, x+w-1 do
		for y1 = y, y+h-1 do
			if grid[y1] and grid[y1][x1] then
				grid[y1][x1].busy = true
			end
		end
	end
end

local function tryCreateCell (grid, x, y)
  if isBusy (grid, x, y, 1, 1) then
		return -- no place for cell 1x1
	end
	
	local w = random (2, MAXCELLSIZE)
	local h = random (2, MAXCELLSIZE)
	
	-- chech if some
	while isBusy (grid, x, y, w, h) do
		if w > 1 and h > 1 then
			if random (w+h) <= w then
				w = w - 1 -- high probability by big w
			else
				h = h - 1 -- high probability by big h
			end
		elseif w > 1 then
			w = w - 1
		elseif h > 1 then
			h = h - 1
		end
	end
	local cell = {x=x,y=y,w=w,h=h}
	setBusy (grid, x, y, w, h)
	
	return cell
  
end

function mazing.createCells (mazeWidth, mazeHeight)
	local grid = {}
	local cposs = {} -- potencial cell positions
	
	-- fill tiles
	for y = 1, mazeHeight do
		grid[y] = {}
		for x = 1, mazeWidth do
			local cpos = {x=x,y=y}
			-- mixed array:
			insert (cposs, random(#cposs), cpos)
			grid[y][x] = {busy = false}
		end
	end
	
	local cells = {}
	for i, cpos in ipairs (cposs) do
		local cell = tryCreateCell (grid, cpos.x, cpos.y)
		table.insert (cells, cell)
--		print ('#cells: ' .. #cells)
	end
	
	return cells
end

function mazing.newMaze (mazeWidth, mazeHeight)
	local cells = mazing.createCells (mazeWidth, mazeHeight)
	
	

end

return mazing