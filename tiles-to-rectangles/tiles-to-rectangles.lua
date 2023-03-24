-- map tiles to rectangles

local function isRectangle (hashMap, x0, y0, w, h)
	for y = y0, y0+h-1 do
		for x = x0, x0+w-1 do
			if hashMap[y] then
				if not hashMap[y][x] then
					return false
				end
			else
				return false
			end
		end
	end
	return true
end

local function newRectangle (hashMap, x, y)
	local w, h = 1, 1
	while true do
		local right = isRectangle (hashMap, x+w, y, 1, h)
		local rightT = isRectangle (hashMap, x+w, y-1, 1, h+2)
		local down = isRectangle (hashMap, x, y+h, w, 1)
		local downT = isRectangle (hashMap, x-1, y+h, w+2, 1)
		local canDiag = right and down and hashMap[y+w][x+h]
		if canDiag then
			w, h = w+1, h+1
		elseif right and not rightT then
			w = w+1
		elseif down and not downT then
			h = h+1
		else
			for y0 = y, y+h-1 do
				for x0 = x, x+w-1 do
					hashMap[y0][x0] = false
				end
			end
			return {x=x, y=y, w=w, h=h}
		end
	end
end

local function getRectanglesFromMap (map, wallValue)
	local hashMap = {}
	for y = 1, #map do
		hashMap[y] = {}
		for x = 1, #map[y] do
			hashMap[y][x] = (map[y][x] == wallValue) -- true by 1
		end
	end
	
	local rectangles = {}
	for y = 1, #hashMap do
		for x = 1, #hashMap[y] do
			if hashMap[y][x] then
				local rectangle = newRectangle (hashMap, x, y)
				table.insert (rectangles, rectangle)
			end
		end
	end
	return rectangles
end



-- example
--[[
local map = {
	{0,1,1,1,0},
	{1,0,1,0,1},
	{1,1,0,1,1},
	{1,0,1,0,1},
	{0,1,1,1,0},
}

local rectangles = getRectanglesFromMap (map)
for i, r in ipairs (rectangles) do
	print (i, r.x, r.y, r.w, r.h)
end
--]]

return getRectanglesFromMap