-- qframe.lua
-- module for 8-patch style frame rendering in love2d
-- all internal comments are in english and lowercase

local qframe = {}
qframe.__index = qframe

-- caches
local cacheFrames = {}       -- frame images (8-patch)
local cacheBackgrounds = {}  -- background images

---------------------------------------------------------
-- helper: load frame image (8-patch) with caching
---------------------------------------------------------
local function loadFrameImage(filename)
	if cacheFrames[filename] then
		return cacheFrames[filename].image, cacheFrames[filename].imgData
	end
	local image = love.graphics.newImage(filename)
	image:setFilter("nearest", "nearest")
	local imgData = love.image.newImageData(filename)
	cacheFrames[filename] = {image = image, imgData = imgData}
	return image, imgData
end

---------------------------------------------------------
-- helper: load background image with caching
---------------------------------------------------------
local function loadBackgroundImage(filename)
	if cacheBackgrounds[filename] then
		return cacheBackgrounds[filename]
	end
	local image = love.graphics.newImage(filename)
--	image:setFilter("nearest", "nearest")
	cacheBackgrounds[filename] = image
	return image
end

---------------------------------------------------------
-- helper: extract subtiles from image
---------------------------------------------------------
local function getQTiles(imgData)
	local width, height = imgData:getWidth(), imgData:getHeight()
	local visited, tiles = {}, {}

	local kr, kg, kb = imgData:getPixel(0, 0) -- key color (background)

	local function floodFill(x, y)
		local rect = {xMin = x, yMin = y, xMax = x, yMax = y}
		local stack = {{x = x, y = y}}

		while #stack > 0 do
			local pos = table.remove(stack)
			local px, py = pos.x, pos.y

			if px >= 0 and px < width and py >= 0 and py < height and not visited[py * width + px] then
				local r, g, b = imgData:getPixel(px, py)
				if not (r == kr and g == kg and b == kb) then
					visited[py * width + px] = true
					rect.xMin = math.min(rect.xMin, px)
					rect.yMin = math.min(rect.yMin, py)
					rect.xMax = math.max(rect.xMax, px)
					rect.yMax = math.max(rect.yMax, py)

					table.insert(stack, {x = px + 1, y = py})
					table.insert(stack, {x = px - 1, y = py})
					table.insert(stack, {x = px, y = py + 1})
					table.insert(stack, {x = px, y = py - 1})
				else
					visited[py * width + px] = true
				end
			end
		end

		rect.x = rect.xMin
		rect.y = rect.yMin
		rect.w = rect.xMax - rect.xMin + 1
		rect.h = rect.yMax - rect.yMin + 1
		return rect
	end

	for y = 0, height - 1 do
		for x = 0, width - 1 do
			if not visited[y * width + x] then
				local r, g, b = imgData:getPixel(x, y)
				if not (r == kr and g == kg and b == kb) then
					local rect = floodFill(x, y)
					table.insert(tiles, rect)
				else
					visited[y * width + x] = true
				end
			end
		end
	end

	local minX, minY, maxX, maxY = width, height, 0, 0
	for _, t in ipairs(tiles) do
		minX = math.min(minX, t.xMin)
		minY = math.min(minY, t.yMin)
		maxX = math.max(maxX, t.xMax)
		maxY = math.max(maxY, t.yMax)
	end

	for _, t in ipairs(tiles) do
		t.tags = {}
		if t.xMin == minX then t.tags.left = true end
		if t.xMax == maxX then t.tags.right = true end
		if t.yMin == minY then t.tags.top = true end
		if t.yMax == maxY then t.tags.bottom = true end

		if t.tags.top and t.tags.left then
			t.name = "topLeft"
		elseif t.tags.top and t.tags.right then
			t.name = "topRight"
		elseif t.tags.bottom and t.tags.left then
			t.name = "bottomLeft"
		elseif t.tags.bottom and t.tags.right then
			t.name = "bottomRight"
		elseif t.tags.top then
			t.name = "top"
		elseif t.tags.bottom then
			t.name = "bottom"
		elseif t.tags.left then
			t.name = "left"
		elseif t.tags.right then
			t.name = "right"
		end
	end

	local qtiles = {}
	for _, tile in ipairs(tiles) do
		qtiles[tile.name] = tile
	end

	return qtiles
end




---------------------------------------------------------
-- constructor
---------------------------------------------------------
function qframe.new(filename, x, y)
--	local image = love.graphics.newImage(filename)
--	local imgData = love.image.newImageData(filename)
	local image, imgData = loadFrameImage(filename)
--	image:setFilter("nearest", "nearest")

	local qtiles = getQTiles(imgData)
	local newFrame = {
		image = image,
--			imgData = imgData,
		qtiles = qtiles,
		width = 0,
		height = 0,
		background = nil,
		padding = {top = 0, right = 0, bottom = 0, left = 0},
		x = 0,
		y = 0,
	}

	local self = setmetatable(newFrame, qframe)

	for _, t in pairs(qtiles) do
		t.quad = love.graphics.newQuad(t.x, t.y, t.w, t.h, imgData:getWidth(), imgData:getHeight())
	end

	return self
end

function qframe:setPosition(x, y)
--	print ('qframe:setPosition', x, y)
	self.x = x or self.x
	self.y = y or self.y
--	print ('qframe:setPosition', self.x, self.y)
end

function qframe:getPosition()
--	print ('qframe:getPosition', self.x, self.y)
	return self.x, self.y
end



---------------------------------------------------------
-- background image loader
---------------------------------------------------------
function qframe:setBackgroud(filename, fitToFrame)
--	self.background = love.graphics.newImage(filename)
	self.background = loadBackgroundImage(filename)
--	self.background:setFilter("nearest", "nearest")

	local bw, bh = self.background:getWidth(), self.background:getHeight()
--	print ('qframe:setBackgroud', 'background', bw, bh)
	local totalW = bw + self.padding.left + self.padding.right
	local totalH = bh + self.padding.top + self.padding.bottom
--	print ('qframe:setBackgroud', 'totalW, totalH', totalW, totalH)

	if fitToFrame then
		self:setSize(totalW, totalH)
	end
end


---------------------------------------------------------
-- set padding around the background (in pixels)
---------------------------------------------------------
function qframe:setBackgroudPadding(padding)

	local top = padding.top or 0
	local right = padding.right or 0
	local bottom = padding.bottom or 0
	local left = padding.left or 0
--	print ('qframe:setBackgroudPadding')
--	print ('top', top)
--	print ('right', right)
--	print ('left', left)
--	print ('left', left)
	self.padding.top = top
	self.padding.right = right
	self.padding.bottom = bottom
	self.padding.left = left

	-- recalculate frame size if background exists
	if self.background then
		local bw, bh = self.background:getWidth(), self.background:getHeight()

		-- frame becomes larger than background by padding values
		local totalW = bw + self.padding.left + self.padding.right
		local totalH = bh + self.padding.top + self.padding.bottom

		self:setSize(totalW, totalH)
	end


end

---------------------------------------------------------
-- resizing logic
---------------------------------------------------------
function qframe:setSize(width, height)
	self.width = width
	self.height = height
	local qtiles = self.qtiles
	local tl, tr = qtiles.topLeft, qtiles.topRight
	local bl, br = qtiles.bottomLeft, qtiles.bottomRight
	local top, bottom = qtiles.top, qtiles.bottom
	local left, right = qtiles.left, qtiles.right

	if not (tl and tr and bl and br) then return end

	tl.renderX, tl.renderY = 0, 0
	tr.renderX, tr.renderY = width - tr.w, 0
	bl.renderX, bl.renderY = 0, height - bl.h
	br.renderX, br.renderY = width - br.w, height - br.h

	if top then
		top.renderX, top.renderY = tl.w, 0
		top.scaledWidth = (width - tl.w - tr.w) / top.w
	end
	if bottom then
		bottom.renderX, bottom.renderY = bl.w, height - bottom.h
		bottom.scaledWidth = (width - bl.w - br.w) / bottom.w
	end
	if left then
		left.renderX, left.renderY = 0, tl.h
		left.scaledHeight = (height - tl.h - bl.h) / left.h
	end
	if right then
		right.renderX, right.renderY = width - right.w, tr.h
		right.scaledHeight = (height - tr.h - br.h) / right.h
	end
end

function qframe:setWidth(newWidth, keepProportion)
	if keepProportion and self.width > 0 then
		local ratio = newWidth / self.width
		self:setSize(newWidth, self.height * ratio)
	else
		self:setSize(newWidth, self.height)
	end
end

function qframe:setHeight(newHeight, keepProportion)
	if keepProportion and self.height > 0 then
		local ratio = newHeight / self.height
		self:setSize(self.width * ratio, newHeight)
	else
		self:setSize(self.width, newHeight)
	end
end

function qframe:updateBackground()
	-- if no background set, do nothing
	if not self.background then return end

	-- calculate drawable area for background (inside the frame)
	local innerWidth = self.width - (self.padding.left + self.padding.right)
	local innerHeight = self.height - (self.padding.top + self.padding.bottom)

	-- prevent negative or zero sizes
	if innerWidth <= 0 or innerHeight <= 0 then return end

	-- compute scale factors
	self.bgScaleX = innerWidth / self.background:getWidth()
	self.bgScaleY = innerHeight / self.background:getHeight()
end


---------------------------------------------------------
-- drawing
---------------------------------------------------------
function qframe:drawFrame(x, y)
	love.graphics.push()
	love.graphics.translate(x, y)

	local image = self.image
	local q = self.qtiles

	local function drawTile(t, sx, sy)
		if t then
			love.graphics.draw(image, t.quad, t.renderX, t.renderY, 0, sx or 1, sy or 1)
		end
	end

	drawTile(q.topLeft)
	drawTile(q.topRight)
	drawTile(q.bottomLeft)
	drawTile(q.bottomRight)
	drawTile(q.top, q.top and q.top.scaledWidth or 1, 1)
	drawTile(q.bottom, q.bottom and q.bottom.scaledWidth or 1, 1)
	drawTile(q.left, 1, q.left and q.left.scaledHeight or 1)
	drawTile(q.right, 1, q.right and q.right.scaledHeight or 1)

	love.graphics.pop()
end

function qframe:draw(x, y)
	x = x or self.x
	y = y or self.y
--	print (x, y)
	-- draw background first
	if self.background then
		love.graphics.draw(
			self.background,
			x + self.padding.left,
			y + self.padding.top,
			0,
			self.bgScaleX,
			self.bgScaleY
		)
	end

	self:drawFrame(x, y)
end


return qframe
