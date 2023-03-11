
local function hex (number)
	return string.format("%02x", number)
end

local function hashColor (r, g, b, a)
	return hex (r) .. hex (g) .. hex (b) .. hex (a or 255)
end

--[[
local function newImageData (image)
	local canvas = love.graphics.newCanvas (image:getDimensions())
	love.graphics.setCanvas (canvas)
		love.graphics.setColor (1,1,1)
		love.graphics.draw (image)
	love.graphics.setCanvas ()
	return canvas:newImageData()
end
]]

local function addToPalette (paletteHash, hashIndex, palette, r, g, b, a)
	-- the color is not known before:
	local color = {r, g, b, a}
	table.insert(palette, color)
	local colorIndex = #palette
	paletteHash[hashIndex] = colorIndex
	return colorIndex
end

local function createPalette (imageData, paletteHash, palette)
	local width = imageData:getWidth()-1
	-- read the whole line for all colors:
	for x = 0, width do
		-- [r g b a] as color [0..1]
		local r, g, b, a = imageData:getPixel(x, 0)
		-- [rb gb bb ab] as byte color [0..255]
		local rb, gb, bb, ab = love.math.colorToBytes( r, g, b, a )
		-- just unique value for this color:
		local hashIndex = hashColor (rb, gb, bb, ab)
		
		if not paletteHash[hashIndex] then
			addToPalette (paletteHash, hashIndex, palette, r, g, b, a)
		end
	end
	print ('amount of colors in defined palette:', #palette)
end

local function imageToMap (filename, withPalette)
	local imageData = love.image.newImageData(filename)
	
	-- first is not value, but palette:
	local width = imageData:getWidth()
	local height = imageData:getHeight()
	
	-- a list of colors:
	local palette = {}
	
	-- hash table of colors
	local paletteHash = {}
	
	-- the result table as map[y][x]
	local map = {}
	
	-- value to start the imageData reading:
	local firstPosition = 0
	
	if withPalette then
		-- skip the 0th line
		firstPosition = 1
		
		-- the first line is a palette
		width, height = width-1, height-1

		-- fill the palette with first line
		-- except the pixel (0, 0)
		createPalette (imageData, paletteHash, palette)
	end
	print ('width:', width, 'height:', height)
	
	print ('y:', 1, height-firstPosition)
	print ('x:', 1, width-firstPosition)
	
	for y = 1, height do
		map[y] = {}
		local y0 = y-1+firstPosition -- 0-based position
		
		for x = 1, width do
			local x0 = x-1+firstPosition -- 0-based position
			-- [r g b a] as color [0..1]:
			local r, g, b, a = imageData:getPixel(x0, y0)
			-- [rb gb bb ab] as byte color [0..255]:
			local rb, gb, bb, ab = love.math.colorToBytes( r, g, b, a )
			-- just unique value for this color:
			local hashIndex = hashColor (rb, gb, bb, ab)
			
			if paletteHash[hashIndex] then
				-- taking color index from hash table:
				local colorIndex = paletteHash[hashIndex]
				-- write the number to the map:
				map[y][x] = colorIndex
			else
				if withPalette then
					print ('color '..hashIndex..' was not defined in the palette')
				end
				local colorIndex = addToPalette (paletteHash, hashIndex, palette, r, g, b, a)
				-- write the number to the map:
				map[y][x] = colorIndex
			end
		end
	end
	
	if withPalette then
		print ('Extended palette:' .. #palette .. ' colors')
	else
		print ('Palette: ' .. #palette .. ' colors')
	end
	for i, color in ipairs (palette) do
		print (i, '#'.. hex(color[1]*255) .. hex(color[2]*255) .. hex(color[3]*255) .. hex(color[4]*255))
	end
	
	print ('{ -- rows:'.. #map,'cols: ' .. #map[1])
	for y = 1, #map do
		print ('	{'..table.concat (map[y], ', ') .. '},')
	end
	print ('}')
	return map, palette
end

return imageToMap