--	pixel wave function collapse
--	License CC0 (Creative Commons license) (c) darkfrei, 2022

--	the code parses the given image and creates new images

-- color: {0, 127, 255}, RGB;
-- color index: 1, number of color in the list of colors;
-- tile: {2, 1, 4, 2, index = 1} - list of neigbour colors,
-- tile.index is a index of color in central pixel of tile.
-- pTiles: list of possible tiles in this cell;
-- pColors: list of possible colors (central pixel) in this cell;
-- by #pColors==1 the color is collapsed, but the tile of cell is not collapsed;
-- cell: {x=x,y=y,pTiles=pTiles,pColors=pColors},
-- 


local pwfc = {}

local N1 = {
	{ 0,-1}, { 1, 0}, { 0, 1}, {-1, 0}, -- top right down left
}
local N2 = {
	{ 0,-1}, { 1, 0}, { 0, 1}, {-1, 0}, -- top right down left
	{ 1,-1}, { 1, 1}, {-1, 1}, {-1,-1}, -- tr br bl tl
}

local NeigbourCells = N2


local function isValueInList (value, list)
	for i, v in ipairs (list) do
		if v == value then 
			return true
		end
	end
	return false
end


--local function getVSymmetryCellsList (cellsList)
--	local newCellsList = {}
--	for i, cell in ipairs (cellsList) do
--		table.insert (newCellsList, {cell[1], -cell[2]})
--	end
--	return newCellsList
--end

--local function getHSymmetryCellsList (cellsList)
--	local newCellsList = {}
--	for i, cell in ipairs (cellsList) do
--		table.insert (newCellsList, {-cell[1], cell[2]})
--	end
--	return newCellsList
--end

--local function getRotatedCellsList (cellsList)
--	local newCellsList = {}
--	for i, cell in ipairs (cellsList) do
--		table.insert (newCellsList, {cell[2], -cell[1]})
--	end
--	return newCellsList
--end

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
--	     self:getColorIndex (r, g, b, false)
	-- red, green, blue
	
	if not r then 
		return "void" -- the pixel out of image
	end
	
	-- range01 - bool, range must be corrected to range [0, 255]
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

function pwfc:getCell (x, y)
	-- cell is a tile by the position y, x
	-- map is a new generated map
	local map = self.map
	local cell
	if map[y] then
		cell = map[y][x]
	end
	return cell
end

function pwfc:getTile (x, y)
	-- tile is a element of possible tiles
	-- read tile from source map
	local map = self.sourceMap
	local tile = {}
	tile.index = map[y][x] -- tile.index is index of color
	for i, neigCell in ipairs (NeigbourCells) do
		-- x1, y1 - relative position of neighbour cell
		local x1, y1 = neigCell[1], neigCell[2]
		local index = map[y+y1][x+x1] -- also index of color
		table.insert (tile, index)
	end
	
	return tile
	--[[
	tile = {
		1,3,2,4,2,2,2,1, -- neigbour's indices
		index = 2}
	--]]
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
			local tile = self:getTile (x, y)
			local tileIndex = tile.index -- index of main color
-- ruleTiles is a list of tiles for this color
			local ruleTiles = rules[tileIndex]
			if not ruleTiles then
				ruleTiles = {}
				rules[tileIndex] = ruleTiles
			end
			if not isTileInRules (tile, ruleTiles) then
				print (tile.index, table.concat(tile, ','))
				table.insert(tiles, tile)
				table.insert(ruleTiles, tile)
			end
		end
	end
	print ("#tiles: ".. #tiles)
	self.rules = rules
	self.tiles = tiles
end

function table.copy (tabl)
--	return {unpack (t)}
	local newTabl = {}
	for i, v in pairs (tabl) do
		newTabl[i] = v
	end
	return newTabl
end

function table.insertUnique (list, value)
	if not isValueInList(value, list) then
		table.insert (list, value)
	end
end

local function filterColors (cell)
	-- tile was removed, update list of possible colors
	-- other tiles cannot be removed
	local pColors = {}
	for i, pTile in ipairs (cell.pTiles) do
		if not isValueInList (pTile.index, pColors) then
			table.insert (pColors, pTile.index)
		end
	end
	cell.pColors = pColors
end

--local function filterTiles (cell)
--	-- color was removed, update list of possible tiles
--	-- other colors cannot be removed
--	local pColors = cell.pColors
--	for i = #cell.pTiles, 1, -1 do -- backwards
--		local pTile = cell.pTiles[i]
--		if not isValueInList (pTile.index, pColors) then
--			table.remove (cell.pTiles, i)
--		end
--	end
--end

function pwfc:deleteOneTileFromCell (cell)
	local pTiles = cell.pTiles
	if #pTiles > 1 then
		table.remove (pTiles, math.random(#pTiles))
--		filterColors (cell)
	end
end

function pwfc:deleteOneColorFromCell (cell)
	local pColors = cell.pColors
	if #pColors > 1 then
		table.remove (pColors, math.random(#pColors))
--		filterTiles (cell)
	end
end



function pwfc:reload ()
	self.map = {}
	local h = self.h
	local w = self.w
	-- fill map with cells with all tiles
	for y = 1, h do
		self.map[y] = {}
		for x = 1, w do
			local pTiles = table.copy(self.tiles)
			local cell = {
				x = x,
				y = y,
				pTiles = pTiles, -- possible tiles
				pColors = {}, -- possible colors
			}
			filterColors (cell)
			self.map[y][x] = cell
		end
	end
	-- one cell has one tiles less
	local a = math.random (w) -- just skip one number, sorry
	local x, y = math.random (w), math.random (h)
--	y = h-1
	local cell = self:getCell(x, y)
	
	self.solved = false
	self:collapseOneTile ()
end
	
	
function pwfc:load (path, w, h)
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
	
	-- new generated map w wide and h height
	self.w = w
	self.h = h

	self:reload ()
end


function pwfc:collapseOneTile ()
	local w, h = self.w, self.h
	local x, y = math.random(w), math.random(h)
	local cell = self:getCell(x, y)
	local colorIndex = cell.pColors[math.random(#cell.pColors)]
	cell.pColors = {colorIndex}
	
end


function pwfc:findLowestEntropy ()
	local map = self.map
	local w, h = self.w, self.h
	local lowestValue = nil
	local lowestCellList = {}
	for y = 1, h do
		for x = 1, w do
			local cell = self:getCell(x, y)
			local p = cell.pTiles
--			local p = cell.pColors
			if #p > 1 then
				if not lowestValue or (#p < lowestValue) then
					-- new best value
					lowestValue = #p
					lowestCellList = {cell}
				elseif (#p == lowestValue) then
					-- same best value, insert candidate
					table.insert (lowestCellList, cell)
				else
					-- entropy is higher than the best one
				end
			end
		end
	end
	local r = math.random (#lowestCellList)
--	print ('lowestValue:'..lowestValue)
	return lowestCellList[r], lowestValue
end


local function checkTiles (cellA, cellB, iNeigbour)
	-- remove not possible tiles from neigbour's pTiles
	local nRemovedTiles = 0
	for i = #cellB.pTiles, 1, -1 do
		local tile = cellB.pTiles[i]
		local colorIndex = tile[iNeigbour]
		if not isValueInList (colorIndex, cellA.pColors) then
			table.remove(cellB.pTiles, i)
			nRemovedTiles = nRemovedTiles + 1
		end
	end
	return nRemovedTiles
end

local function checkColors (cellA, cellB, iNeigbour)
-- check which colors the neighbour cellB 
-- can have cellA as neigbour color
-- other colors are not valid and must be deleted
	local nRemovedColors = 0
	local validColors = {} -- an niegbour in cellB
	local tileList = cellB.pTiles
	for i, tile in ipairs (tileList) do
		local colorIndex = tile[iNeigbour]
		table.insertUnique (validColors, colorIndex)
	end
	for i = #cellA.pColors, 1, -1 do
		local color = cellA.pColors[i]
		if not isValueInList (color, validColors) then
			table.remove (cellA.pColors, i)
			nRemovedColors = nRemovedColors + 1
		end
	end
	return nRemovedColors
end

function pwfc:solveCell (cellA)
	local nRemovedTiles = 0
	local nRemovedColors = 0
	local rules = self.rules
	local x, y = cellA.x, cellA.y
	-- tileOptions: new tile options for THIS cell
	local tileOptions = table.copy (cellA.pTiles)
	for iNeigbour = 1, #NeigbourCells do
		local dx, dy = NeigbourCells[iNeigbour][1], NeigbourCells[iNeigbour][2]
		local cellB = self:getCell(x-dx, y-dy)
		if cellB then
			nRemovedColors = nRemovedColors 
				+ checkColors (cellA, cellB, iNeigbour)
			
			nRemovedTiles = nRemovedTiles 
				+ checkTiles (cellA, cellB, iNeigbour)

--			nRemovedColors = nRemovedColors 
--				+ checkColors (cellA, cellB, iNeigbour)
		end
	end
	return nRemovedTiles, nRemovedColors
end

function pwfc:updateOnce ()
	
	local nRemovedTiles = 0
	local nRemovedColors = 0
	for y = 1, self.h do
		for x = 1, self.w do
			local cellA = self:getCell(x, y)
			-- pTiles or pColors?
			if #cellA.pTiles > 1 then
--			if #cellA.pColors > 1 then
				-- not collapsed
				local nRT, nRC = pwfc:solveCell (cellA)
				nRemovedTiles = nRemovedTiles + nRT
				nRemovedColors = nRemovedColors + nRC
			else
				-- collapsed
			end
		end
	end
--	print ('nRemovedTiles:'..nRemovedTiles)
	return nRemovedTiles, nRemovedColors
end


function pwfc:solveToProgress ()
	for i = 1, 100 do
		local nRemovedTiles, nRemovedColors = self:updateOnce ()
		if (nRemovedTiles == 0) and (nRemovedColors == 0) then
			local cell = self:findLowestEntropy ()
			if not cell then 
--				self.solved = true
				return 
			end -- no not collapsed cells
			self:deleteOneTileFromCell (cell)
--			self:deleteOneColorFromCell (cell)
--			return
		elseif nRemovedColors > 0 and nRemovedTiles > 0 then
			return
		elseif nRemovedColors > 0 then
			return
		end
	end
end

function pwfc:update ()
	self:solveToProgress ()
	
	local nRestTiles = - (self.w * self.h)
	for y = 1, self.h do
		for x = 1, self.w do
			local cell = self:getCell(x,y)
			nRestTiles = nRestTiles + #cell.pTiles
		end
	end
	self.nRestTiles = nRestTiles
end

---------------------------------------------------------------
-- update
---------------------------------------------------------------
-- draw
---------------------------------------------------------------

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

function pwfc:drawRules (px, py, psize)
	local px0 = px
	py = py - 4*psize
--	local w = love.graphics.getWidth()
	local w = 650
	
	for i, tileset in ipairs (self.rules) do
--		print (i, #tileset)
		px = px0
		py = py + 4*psize
		for j, tile in ipairs (tileset) do
			local x = px + psize
			local y = py + psize
			if px > w + 2*psize and not (j == #tileset) then
				px = px0
				py = py + 4*psize
			else
				px = px + 4*psize
			end
			local index = tile.index
			oldSetColor(self.colors[index])
			love.graphics.rectangle('fill', x, y, psize, psize)		
			for i, cell in ipairs (NeigbourCells) do
				local x1, y1 = psize*cell[1], psize*cell[2]
				local colorIndex = tile[i]
				oldSetColor(self.colors[colorIndex])
				love.graphics.rectangle('fill', x+x1, y+y1, psize, psize)
			end
		end
		
	end
	return py + 4*psize
end


function pwfc:drawMapCollapsedCells (px, py, psize)
	love.graphics.setColor(1,1,1)
	local maxY = #self.map
	local maxX = #self.map[1]
	for y = 1, maxY do
		for x = 1, maxX do
			local cell = self:getCell (x, y)
			if #cell.pColors == 1 then
				-- collapsed
				local colorIndex = cell.pColors[1]
				local color = self.colors[colorIndex]
				oldSetColor (color)
				love.graphics.rectangle ('fill', 
					px+(x-1)*psize, 
					py+(y-1)*psize, 
					psize, psize)
			elseif #cell.pColors == 0 then
				love.graphics.setColor(1,0,1)
				love.graphics.rectangle ('fill', 
					px+(x-1)*psize, 
					py+(y-1)*psize, 
					psize, psize)
			else
				-- mixed color
				local r, g, b, n = 0,0,0,0
				local colors = self.colors
				for i, colorIndex in ipairs (cell.pColors) do
					n=n+1
					r=r+colors[colorIndex][1]
					g=g+colors[colorIndex][2]
					b=b+colors[colorIndex][3]
				end
				r, g, b = r/n, g/n, b/n
				oldSetColor ({r,g,b})
				
				love.graphics.rectangle ('fill', 
					px+(x-1)*psize, 
					py+(y-1)*psize, 
					psize, psize)
				
			-- outline
				love.graphics.setColor(0.5,0.5,0.5)
				love.graphics.rectangle ('line', 
					(px+(x-1)*psize)+0.5, 
					(py+(y-1)*psize)+0.5, 
					psize-1, psize-1)
			end
		end
	end
end

function pwfc:drawMapNumbers (px, py, psize)
	love.graphics.setColor(1,1,1)
	local maxY = #self.map
	local maxX = #self.map[1]
	local font = love.graphics.getFont( )
	local h = font:getHeight( )
	for y = 1, maxY do
		for x = 1, maxX do
			local cell = self:getCell (x, y)
			local str = #cell.pTiles ..'/' .. #cell.pColors
			local w = font:getWidth( str )
--			love.graphics.print (amount, px+(x-1)*psize, py+(y-1)*psize)
--			love.graphics.rectangle ('line', 
--				px+(x-1)*psize, 
--				py+(y-1)*psize, 
--				psize, psize)
			love.graphics.print(str, 
				px+(x-1)*psize+psize/2, 
				py+(y-1)*psize+psize/2, 0, 1, 1, w/2, h/2)
--			local r, g, b = oldSetColor (r, g, b)
		end
	end
end
	
function pwfc:draw ()
	-- draw possible tiles
--	self:drawTiles (10, 10, 10)
	-- draw all rules (sorted by the middle type)
--	self:drawRules (10, 10, 10)
	
	-- draw amount off possible tiles
	local px, py, psize = 10, 10, 15
	self:drawMapCollapsedCells (px, py, psize)
	if (not self.solved) and psize > 30 then
		self:drawMapNumbers (px, py, psize)
	end
	love.graphics.setColor(1,1,1)
	love.graphics.print (self.nRestTiles, 0, 400)
	
end



function pwfc:keypressed (key, scancode, isrepeat)
--	local w, h = self.w, self.h
	-- one cell has one tiles less
--	local x, y = math.random (w), math.random (h)
	
--	self:solveToProgress ()
	self:reload ()
end



return pwfc