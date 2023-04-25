-- License CC0 (Creative Commons license) (c) darkfrei, 2023

love.window.setMode(512*2, 512)


function nearestColorIndex(r, g, b, palette)
	local firstIndex = 1
	local secondIndex = 1
	local distance = math.huge
	for index, color in ipairs(palette) do
		local dr = r - color[1]
		local dg = g - color[2]
		local db = b - color[3]
		local d = dr * dr + dg * dg + db * db
		if d < distance then
			secondIndex = firstIndex
			firstIndex = index
			distance = d
		end
	end
	return firstIndex, secondIndex
end

local ditherMatrix = {
	{0, 7, 3},
	{6, 5, 2},
	{4, 1, 8}
}

function interpolateColors (colorA, colorB, colorC)
	local dr1 = colorA[1]-colorC[1]
	local dg1 = colorA[2]-colorC[2]
	local db1 = colorA[3]-colorC[3]
	local dr2 = colorB[1]-colorC[1]
	local dg2 = colorB[2]-colorC[2]
	local db2 = colorB[3]-colorC[3]
	local len1 = math.sqrt(dr1*dr1+dg1*dg1+db1*db1)
	local len2 = math.sqrt(dr2*dr2+dg2*dg2+db2*db2)
	return (len1)/(len1+len2)
end


function dither3x3(path, palette)
	local imageData = love.image.newImageData(path)
	local width, height = imageData:getDimensions()
	for y = 1, height do
		for x = 1, width do
			local r, g, b = imageData:getPixel(x-1, y-1)
			local firstIndex, secondIndex, thirdIndex, fourthIndex = nearestColorIndex(r, g, b, palette)
			local first, second	= palette[firstIndex], palette[secondIndex]
			local ditherValue = ditherMatrix[(y-1)%3+1][(x-1)%3+1]
			
			local compareValue = 8*interpolateColors (first, second, {r, g, b})-1
			
			if ditherValue > compareValue then
				r, g, b = first[1], first[2], first[3]
			else
				r, g, b = second[1], second[2], second[3]
			end
			imageData:setPixel(x-1, y-1, r,g,b)
		end
	end
	return love.graphics.newImage(imageData)
end



function love.load()
	--[[
	local palette = {
		-- lenna palette
		{206/255,95/255,93/255},
		{230/255,133/255,128/255},
		{222/255,106/255,99/255},
		{195/255,127/255,120/255},
		{231/255,198/255,199/255},
		{96/255,23/255,62/255},
		{138/255,96/255,150/255},
		{227/255,93/255,105/255},
		{241/255,204/255,190/255},
		{237/255,182/255,167/255},
	}
	]]
	
	
	local palette = {
		{228/255,218/255,177/255},
		{197/255,97/255,81/255},
		{113/255,37/255,77/255},
		{101/255,145/255,153/255},
	}
	
	
	Image = dither3x3('lenna-512.png', palette)
	Image2 = love.graphics.newImage('lenna-512.png')
end

function love.draw()
	love.graphics.setColor (1,1,1)
	love.graphics.draw (Image)
	love.graphics.draw (Image2, 512, 0)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end
