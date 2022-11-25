-- License CC0 (Creative Commons license) (c) darkfrei, 2022


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

-- main function:
local function getCanvas()
	local subtileSize = 4 -- pixels in tile
	local dpiscale = 8 -- subpixels per pixel
	local canvasWidth = 7*(subtileSize+1)+1
	local canvasHeight = 16*(subtileSize+1)+1
	local canvas = love.graphics.newCanvas (canvasWidth, canvasHeight, {dpiscale = dpiscale})
	canvas:setFilter("linear", "nearest")
	love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(1)
	love.graphics.setCanvas(canvas)
	love.graphics.setPointSize (1)
	local n = 0
	for i = 0, 255 do
		local a = not(i%2 == 0)
		local b = not(math.floor(i/2)%2 == 0)
		local c = not(math.floor(i/4)%2 == 0)
		local d = not(math.floor(i/8)%2 == 0)
		local ab = not((math.floor(i/16)%2 == 0))  and a and b
		local bc = not((math.floor(i/32)%2 == 0)) and b and c
		local cd = not((math.floor(i/64)%2 == 0)) and c and d
		local da = not((math.floor(i/128)%2 == 0)) and d and a
		local x = 1.5 + math.floor ((n)/16)*(subtileSize+1)
		local y = (n-16)%16*(subtileSize+1)+1.5
		
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
			for k, bool in ipairs (variant) do
				if not bool then
					alltrue = false
					break
				end
			end
			if alltrue then
				drawLines (ab,bc,cd,da, x,y, subtileSize)
				drawPoints (a,b,c,d, x,y, subtileSize)
				n = n+1
				break
			elseif i < 16 then
				drawPoints (a,b,c,d, x,y, subtileSize)
				n = n+1
				break
			end
		end
	end
	love.graphics.setCanvas()
	return canvas
end


return getCanvas