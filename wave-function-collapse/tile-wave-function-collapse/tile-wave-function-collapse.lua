-- wave function collapse lua library
-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local wfc = {}

wfc.dim = 12 -- number of cells in the row/column
wfc.size = 64 -- pixels per one cell



function wfc:createCell(x, y)
	self.grid[y][x] = 
	{
		x=x, 
		y=y, 
		collapsed = false,
		options = {1,2,3,4,5},
		image = nil,
		
	}
end
	
	
function wfc:createGrid()
	self.grid = {}
	for y = 1, self.dim do
		self.grid[y] = {}
		for x = 1, self.dim do
			self:createCell(x, y)
		end
	end
end

function wfc:load (typ, size)
	self:createGrid()
	
end

-------------------

function wfc.newImage (typ)
	love.graphics.setLineStyle("rough")
	local size = wfc.size
	local lineColor = {0,0,0}
	local outlineColor = {0.2,0.2,0.2}
	local backgroundColor = {0.8,0.8,0.8}
	local lineWidth = math.floor(size/4)
	local canvas = love.graphics.newCanvas(size, size)
	love.graphics.setCanvas (canvas)
	love.graphics.setColor (backgroundColor)
	love.graphics.rectangle ('fill', 0, 0, size, size)
	love.graphics.setLineWidth(1)
	love.graphics.setColor (outlineColor)
	love.graphics.rectangle ('line', 0.5, 0.5, size-1, size-1)
	if typ == "blank" then
--		{0, 0, 0, 0} -- up, right, down, left
		-- ready, no lines, no connections
	elseif typ == "T" then -- T is as T
--		{0, 1, 1, 1} -- up, right, down, left
		love.graphics.setLineWidth(lineWidth)
		love.graphics.setColor (lineColor)
		love.graphics.line (0, size/2, size, size/2)
		love.graphics.line (size/2, size/2, size/2, size)
	elseif typ == "L" then -- L is as L
--		{1, 1, 0, 0} -- up, right, down, left
		love.graphics.setLineWidth(lineWidth)
		love.graphics.setColor (lineColor)
		love.graphics.line (size/2-(lineWidth/2-0.5), size/2, size, size/2)
		love.graphics.line (size/2, size/2+lineWidth/2-0.5, size/2, 0)
	elseif typ == "i" then -- i is the end
--		{0, 0, 1, 0} -- up, right, down, left
		love.graphics.setLineWidth(lineWidth)
		love.graphics.setColor (lineColor)
		love.graphics.line (size/2, size/2, size/2, size)
		love.graphics.circle('fill', size/2, size/2, lineWidth/2)
	end
	love.graphics.setCanvas ()
	return canvas
end

function wfc.newTile (img, edges)
	-- img is image or canvas
	-- edges is a list as {1,1,0,1}, 
	-- that has connections in order: up, right, down (zero), left
	local tile = {img = img, edges=edges}
	return tile
end

function wfc.newRotatedTile(tile)
	local shift = 1
	local newEdges = {}
	local len = #tile.edges -- just 4
	for i = 1, len do
        newEdges[i] = tile.edges[(i-1-shift)%len+1]
    end
	local img = createRotatedCanvas (tile.img)
	local newTile = {}
	newTile.edges = newEdges
	newTile.img = img
    return newTile
end

function wfc.newVFlippedTile(tile)
	local edges = tile.edges
	-- flip vertical
	local newEdges = {edges[3], edges[2], edges[1], edges[4]}
	local img = love.graphics.newCanvas(tile.img:getDimensions())
	love.graphics.setCanvas(img)
		love.graphics.setColor(1,1,1)
		love.graphics.draw(tile.img, 0, img:getHeight(), 0,1,-1)
	love.graphics.setCanvas()
	
	local newTile = {}
	newTile.edges = newEdges
	newTile.img = img
    return newTile
end


function wfc:getCell (x, y)
	x = (x-1)%self.dim + 1 -- torus topology
	y = (y-1)%self.dim + 1
	return self.grid[y][x]
end


function wfc:drawCollapsed (cell)
	love.graphics.setColor(1,1,1)
	
	love.graphics.draw(self.tiles[cell.index], (x-1)*Size, (y-1)*Size)
end
	
	
function wfc:draw ()
	local dim = self.dim
	local size = self.size
	local grid = self.grid
	for y = 1, self.dim do
		for x = 1, self.dim do
			local cell = grid[y][x]
			if cell.collapsed then
				self.drawCollapsed (cell)
			else
				love.graphics.setColor(0.5,0.5,0.5)
				love.graphics.rectangle('fill', (x-1)*size, (y-1)*size, size, size)
				love.graphics.setColor(0.3,0.3,0.3)
				love.graphics.rectangle('line', (x-1)*size, (y-1)*size, size, size)
				love.graphics.setColor(0,0,0)
				love.graphics.print (#cell.options, (x-1)*size, (y-1)*size)
				love.graphics.print ((table.concat(cell.options,' ')), (x-1)*size, (y-1)*size+14)
			end
			
		end
	end
end

function wfc:drawTiles ()
	love.graphics.setColor(1,1,1)
	local y = 0
	for i = 1, #self.tiles do
		local tile = self.tiles[i]
		local dy = tile.img:getHeight()
		love.graphics.draw(tile.img, 0, y)
		y = y + dy
	end
end


--------------------------------------------------------------------
--	special functions
--------------------------------------------------------------------


-- create same list
function copyList (listA)
	return {unpack(listA)}
end


-- is value in list
function isValueInList (value, list)
	for i, v in ipairs (list) do if v == value then return true end end 
end

-- merge list to list, but only it don't has this value
function listMergeUnique (listReceiver, listTransmitter)
	for i, value in ipairs (listTransmitter) do
		if not isValueInList (value, listReceiver) then
			table.insert(listReceiver, value)
		end
	end
end	

function checkValid (arr, validList) -- list, allow-filter list
	-- valid = {BLANK, RIGHT}
	-- arr = {BLANK, UP, RIGHT, DOWN, LEFT}
	-- result: removing UP, DOWN, LEFT from arr
	for i = #arr, 1, -1 do -- backward
		local element = arr[i]
		if not isValueInList (element, validList) then
			table.remove (arr, i)
		end
	end
end

function createRotatedCanvas (canvas)
	-- 90 degrees clockwise
	local newCanvas = love.graphics.newCanvas (canvas:getHeight(), canvas:getWidth())
	love.graphics.setCanvas(newCanvas)
		love.graphics.setColor(1,1,1)
		love.graphics.draw (canvas, canvas:getHeight(), 0, math.pi/2)
	love.graphics.setCanvas()
	return newCanvas
end

return wfc