-- License CC0 (Creative Commons license) (c) darkfrei, 2023


-- just require it:
-- local getCanvas = require ('generate-subtiles')
-- local canvas = getCanvas()
-- save to file:
-- canvas:newImageData():encode("png","sprites-47.png")



local function drawPoints (a,b,c,d, x,y, subtileSize)
-- 		edges
--		love.graphics.setColor (1,1,1)
		local points = {}
		if a then
			table.insert (points, x)
			table.insert (points, y)
		end
		if b then
			table.insert (points, x+subtileSize-1)
			table.insert (points, y)
		end
		if c then
			table.insert (points, x+subtileSize-1)
			table.insert (points, y+subtileSize-1)
		end
		if d then
			table.insert (points, x)
			table.insert (points, y+subtileSize-1)
		end
		love.graphics.points(points)
end

local function drawLines (ab,bc,cd,da, x,y, subtileSize)
	if ab then
		love.graphics.line (x, y, x+subtileSize-1, y)
	end
	if bc then 
		love.graphics.line (x+subtileSize-1, y, x+subtileSize-1, y+subtileSize-1)
	end
	if cd then 
		love.graphics.line (x+subtileSize-1, y+subtileSize-1, x, y+subtileSize-1)
	end
	if da then
		love.graphics.line (x, y+subtileSize-1, x, y)
	end
end

local function boolsToNumber (a,b,c,d, ab,bc,cd,da)
	local n = 0
	if a then n = n + 1 end
	if b then n = n + 2 end
	if c then n = n + 2^2 end
	if d then n = n + 2^3 end
	
	if ab then n = n + 2^4 end
	if bc then n = n + 2^5 end
	if cd then n = n + 2^6 end
	if da then n = n + 2^7 end
	
	return n
end

-- main function:
local function getCanvas()
	local nTiles = 47 -- constant
	local inLines = true
	
	local nCols = 3
	local nRows = math.ceil(nTiles/nCols)
	
	if inLines then
		nCols = 16
		nRows = math.ceil(nTiles/nCols)
	end
--	nCols, nRows
	local subtileSize = 8 -- pixels in tile
	local dpiscale = 1 -- subpixels per pixel; just for higher dpi
	local canvasWidth = nCols*(subtileSize+1)+1
	local canvasHeight = nRows*(subtileSize+1)+1
	local canvas = love.graphics.newCanvas (canvasWidth, canvasHeight, {dpiscale = dpiscale})
	
	canvas:setFilter("linear", "nearest")
	love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(1)
	love.graphics.setCanvas(canvas)
	love.graphics.rectangle ("fill",0,0, canvasWidth, canvasHeight)
	love.graphics.setPointSize (1)
	local n = 0
	
	local variationMap = {}
	local variationsList = {
		  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15,
		 19, 23, 27, 31, 38, 39, 46, 47, 55, 63, 76, 77, 78, 79, 95, 110,
		111,127,137,139,141,143,155,159,175,191,205,207,223,239,255
		}
--	for i = 0, 255 do
	for _, i in ipairs (variationsList) do
		print (i, #variationsList)
		local a = not(i%2 == 0)
		local b = not(math.floor(i/2)%2 == 0)
		local c = not(math.floor(i/4)%2 == 0)
		local d = not(math.floor(i/8)%2 == 0)
		local ab = not((math.floor(i/16)%2 == 0))  and a and b
		local bc = not((math.floor(i/32)%2 == 0)) and b and c
		local cd = not((math.floor(i/64)%2 == 0)) and c and d
		local da = not((math.floor(i/128)%2 == 0)) and d and a
		
--		nCols, nRows

		local x = 1.5 + math.floor (n/nRows)*(subtileSize+1)
		local y = (n-nRows)%nRows*(subtileSize+1)+1.5
		
		if inLines then
			x = (n-nCols)%nCols*(subtileSize+1)+1.5
			y = 1.5 + math.floor (n/nCols)*(subtileSize+1)
		end
		
		-- outline
		love.graphics.setColor (1,0,1)
		love.graphics.rectangle ('line', x-1, y-1, subtileSize+1,subtileSize+1)
		
--		-- background
		love.graphics.setColor (0.55,0.55,0.55)
		love.graphics.rectangle ('fill', x-0.5, y-0.5, subtileSize,subtileSize)

-- 		sides and corners:
		love.graphics.setColor (0.75, 0.75, 0.75)
		local variations = {
			{ab, bc, cd, da},
			{ab, bc, cd},
			{ab, bc, da},
			{ab, cd, da},
			{bc, cd, da},
			{ab, bc},
			{ab, da},
			{cd, da},
			{bc, cd},
			{ab, cd},{bc, da},
			{ab},{bc},{cd},{da},
			{false},
		}
		
		for j, variant in ipairs (variations) do
			local alltrue = true
--			for k, bool in ipairs (variant) do
--				if not bool then
--					alltrue = false
--					break
--				end
--			end
			local name = boolsToNumber (a,b,c,d, ab,bc,cd,da)
			if alltrue and not variationMap[name] then
				-- drawing tiles with lines
				drawLines (ab,bc,cd,da, x,y, subtileSize)
				drawPoints (a,b,c,d, x,y, subtileSize)
				n = n+1
				variationMap[name] = true
				print (a, b, c, d, ab, bc, cd, da)
				break
			elseif i < 16 then
				-- drawing tiles without lines
				drawPoints (a,b,c,d, x,y, subtileSize)
				n = n+1
				break
			end
		end
	end
	
	-- disable canvas:
	love.graphics.setCanvas()
	return canvas
end


return getCanvas