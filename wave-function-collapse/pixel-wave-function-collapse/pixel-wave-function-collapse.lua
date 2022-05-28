--	pixel wave function collapse
--	License CC0 (Creative Commons license) (c) darkfrei, 2022

--	the code parses the given image and creates new images


local pwfc = {}

local N1 = {
	{ 0,-1}, { 1, 0}, { 0, 1}, {-1, 0}, -- top right down left
}
local N2 = {
	{ 0,-1}, { 1, 0}, { 0, 1}, {-1, 0}, -- top right down left
	{ 1,-1}, { 1, 1}, {-1, 1}, {-1,-1}, -- tr br bl tl
}

local NeigbourCells = N2



local function getVSymmetryCellsList (cellsList)
	local newCellsList = {}
	for i, cell in ipairs (cellsList) do
		table.insert (newCellsList, {cell[1], -cell[2]})
	end
	return newCellsList
end

local function getHSymmetryCellsList (cellsList)
	local newCellsList = {}
	for i, cell in ipairs (cellsList) do
		table.insert (newCellsList, {-cell[1], cell[2]})
	end
	return newCellsList
end

local function getRotatedCellsList (cellsList)
	local newCellsList = {}
	for i, cell in ipairs (cellsList) do
		table.insert (newCellsList, {cell[2], -cell[1]})
	end
	return newCellsList
end

function pwfc:loadSourceImage (path)
	local info = love.filesystem.getInfo( path )
	if info then
		return love.graphics.newImage( path )
	end
end

local function isColorInList (r, g, b, list)
	for i, color in ipairs (list) do
		if  (r == color[1]) 
		and (g == color[2]) 
		and (b == color[3]) then
			return true 
		end
	end
	return false
end

function pwfc:getColorIndex (r, g, b, range01)
	-- red, green, blue
	
	if not r then 
		return "void" -- the pixel out of image
	end
	
	-- range01 - bool, range must be corrected 
	if range01 then
		r, g, b = love.math.colorToBytes( r, g, b)
	end
	self.colorMap[r] = self.colorMap[r] or {}
	self.colorMap[r][g] = self.colorMap[r][g] or {}
	local index = self.colorMap[r][g][b]
	if index then return index end
	
	-- new color
	print ('color ', r, g, b)
	table.insert (self.colors, {r, g, b})
	index = #self.colors
	self.colorMap[r][g][b] = index
	return index
end



function pwfc:getPixel (imageData, x, y, hConnected, vConnected)
	-- x and y are in range [1, width], [1, height]
	-- but texture has range [0, width-1], [0, height-1]
	local width, height = imageData:getDimensions()
	x, y = x-1, y-1
	if hConnected then x = x%width end
	if vConnected then y = y%height end
	if x < 0 or x >= width or y < 0 or y >= height then
		return -- out of range of the texture
	end
	local r, g, b = imageData:getPixel(x, y)
--	return love.math.colorToBytes(r, g, b)
	return r, g, b
end


local function getTile (map, x, y)
	local tile = {}
	tile.index = map[y][x]
	for i, neigCell in ipairs (NeigbourCells) do
		-- x1, y1 - relative position of neighbour cell
		local x1, y1 = neigCell[1], neigCell[2]
		local index = map[y+y1][x+x1]
		table.insert (tile, index)
	end
	return tile
end

local function isSameList (listA, listB)
	if #listA ~= #listB then return false end
	for i = 1, #listA do
		if not (listA[i] == listB[i]) then
			return false
		end
	end
	return true
end

local function isTileInRules (tile, tiles)
	for i, t in ipairs(tiles) do
		if isSameList (t, tile) then
			return true
		end
	end
	return false
end

function pwfc:createRules (imageData, hConnected, vConnected)
--	rules actually are allowed "tiles" that was found on the example
--	bool hConnected for connection between left and right sides
--	bool vConnected for connection between top and bottom sides

	-- creating map and indices of colors 
	local width, height = imageData:getDimensions()
	self.colors = {}
	self.colorMap = {}
	local sourceMap = {}
	for y = 1, height do
		sourceMap[y] = {}
		for x = 1, width do
			local r, g, b = imageData:getPixel(x-1, y-1)
			sourceMap[y][x] = self:getColorIndex (r, g, b, true)
		end
	end
	self.sourceMap = sourceMap 
	print ('total colors: ' .. #self.colors)
	
	-- rules are unique tiles
	-- 
	
	local rules = {}
	local tiles = {} -- list of tiles
	
	local ymin, ymax = 2, height-1
	local xmin, xmax = 2, width-1
	
	if vConnected then ymin, ymax = ymin-1, ymax+1 end
	if hConnected then xmin, xmax = xmin-1, xmax+1 end
	
	for y = ymin, ymax do
		for x = xmin, xmax do
			local tile = getTile (sourceMap, x, y)
			local tileIndex = tile.index -- index of main color
			local rules2 = rules[tileIndex]
			if not rules2 then
				rules2 = {}
				rules[tileIndex] = rules2
			end
			if not isTileInRules (tile, rules2) then
				print (tile.index, table.concat(tile, ','))
				table.insert(tiles, tile)
				table.insert(rules2, tile)
			end
		end
	end
	self.rules = rules
	self.tiles = tiles
end


function pwfc:load (path)
	local sourceImage = self:loadSourceImage (path)
	self.sourceImage = sourceImage
	
	local sourceImageData = love.image.newImageData( path )
	self.sourceImageData = sourceImageData
	
	-- is right side connected to left side?
	self.hConnected = false
	
	-- is top side connected to bottom side?
	self.vConnected = false
	
	
	self.hMirrored = false -- left to right symmetry
	self.vMirrored = false -- up to down symmetry
	
	self.respectBorders = false -- border pixels have their border place
	
	self:createRules (sourceImageData)
	
	-- new generated map
	self.map = {}
	
end






function pwfc:update ()

end

local function oldSetColor (t, g, b)
	if type(t) == "table" then
		local r = t[1] or t.r
		local g = t[2] or t.g
		local b = t[3] or t.b
		r = r /255
		g = g /255
		b = b /255
		love.graphics.setColor( r, g, b)
	end
end

function pwfc:drawTiles (px, py, psize)
	local px0 = px
--	local w = love.graphics.getWidth()
	local w = 300
	for i, tile in ipairs (self.tiles) do
		local x = px + psize
		local y = py + psize
		local index = tile.index
		oldSetColor(self.colors[index])
		love.graphics.rectangle('fill', x, y, psize, psize)		
		for i, cell in ipairs (NeigbourCells) do
			local x1, y1 = psize*cell[1], psize*cell[2]
			local colorIndex = tile[i]
			oldSetColor(self.colors[colorIndex])
			love.graphics.rectangle('fill', x+x1, y+y1, psize, psize)
		end
		px = px + 4*psize
		if px >= w then
			px = px0
			py = py + 4*psize
		end
	end
	return py + 4*psize
end
	
function pwfc:draw ()
	pwfc:drawTiles (10, 10, 10)
end

return pwfc