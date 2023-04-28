-- License CC0 (Creative Commons license) (c) darkfrei, 2023

local imageName = 'lenna-512.png'
--local imageName = 'ball.png'

local palettes = {}
local i = 0
for line in love.filesystem.lines("palettes.txt") do
	i = i + 1
	local palette = loadstring ("return " .. line)()
	table.insert (palettes, palette)
end
paletteID = 129

palette = palettes[paletteID]

local lennaPalette = {
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
table.insert (palettes, lennaPalette)

local nPal = {}
for r = 0, 3 do
	for g = 0, 3 do
		for b = 0, 3 do
			table.insert (nPal, {r/3, g/3, b/3})
		end
	end
end
palettes[128] = nPal

nPal = {}
for r = 0, 2 do
	for g = 0, 2 do
		for b = 0, 2 do
			table.insert (nPal, {r/2, g/2, b/2})
		end
	end
end
palettes[130] = nPal
palettes[131] = {{0,0,0}, {1,1,1}}
palettes[132] = {{0,0,0}, {0.5,0.5,0.5}, {1,1,1}}
palettes[133] = {{211/255, 219/255, 233/255}, {129/255, 154/255, 193/255}, {18/255,64/255, 138/255}, {153/255,123/255, 75/255}}

paletteID = 124
palette = palettes[paletteID]
love.window.setTitle ('palette ' .. paletteID .. ' ('..#palette..' colors)')

function nearestColorIndex(r, g, b, palette)
	local firstIndex = 1
	local secondIndex = 1
	local min1 = math.huge
	local min2 = math.huge
	for index, color in ipairs(palette) do
		local dr = r - color[1]
		local dg = g - color[2]
		local db = b - color[3]
		local value = dr*dr + dg*dg + db*db
		if value < min1 then
			min2 = min1
			min1 = value
			secondIndex = firstIndex
			firstIndex = index
		elseif value < min2 then
			secondIndex = index
			min2 = value
		end
	end
	return firstIndex, secondIndex
end

local ditherMatrix = {
	{0, 7, 3},
	{6, 5, 2},
	{4, 1, 8}
}

function projectPointOnLineSegment(aX, aY, aZ, bX, bY, bZ, cX, cY, cZ)
    local dx, dy, dz = bX - aX, bY - aY, bZ - aZ
    local len2 = (dx*dx + dy*dy + dz*dz)
		if len2 == 0 then
			return 0
		end
    local dot = (cX - aX)*dx + (cY - aY)*dy + (cZ - aZ)*dz
    local t = dot / len2^0.5
    return t
end

function getValue (x, y)
	local r, g, b = 0, 0, 0
	if x < imageData:getWidth() and y < imageData:getHeight()
	and x > 0 and y > 0 then
		r, g, b = imageData:getPixel(x-1, y-1)
	end
	local firstIndex, secondIndex = nearestColorIndex(r, g, b, palette)
	local first, second	= palette[firstIndex], palette[secondIndex]
	local ditherValue = ditherMatrix[(y-1)%3+1][(x-1)%3+1]

	local compareValue = -0.25+4.5*projectPointOnLineSegment(
		first[1], first[2], first[3], 
		second[1], second[2], second[3], 
		r,g,b)

	if firstIndex < secondIndex  then
		-- magic!
		ditherValue = 4-(ditherValue -4)
	end
	
	if (ditherValue > compareValue) then
		r, g, b = first[1], first[2], first[3]
	else
		r, g, b = second[1], second[2], second[3]
	end

	return r, g, b, ditherValue, compareValue
end

function dither3x3(path, palette)
	imageData = love.image.newImageData(path)
	local width, height = imageData:getDimensions()
	for y = 1, height do
		for x = 1, width do
			local r, g, b = getValue (x, y)
			imageData:setPixel(x-1, y-1, r,g,b)
		end
	end
	return love.graphics.newImage(imageData)
end

function love.load()
	Image = dither3x3(imageName, palette)
	Image2 = love.graphics.newImage(imageName)
	Width = Image2:getWidth()
	love.window.setMode(Width*2, Image2:getHeight())
end

function love.draw()
	love.graphics.setColor (1,1,1)
	love.graphics.draw (Image2)
	love.graphics.draw (Image, Width, 0)
	love.graphics.print ('press SPACE to change palette')
end

function love.keypressed(key, scancode, isrepeat)
	if key == "space" then
		paletteID = paletteID + 1
		if paletteID > #palettes then paletteID = 1 end
		
		palette = palettes[paletteID]
		love.window.setTitle ('palette ' .. paletteID .. ' ('..#palette..' colors)')
		Image = dither3x3(imageName, palette)
	elseif key == "escape" then
		love.event.quit()
	end
end
