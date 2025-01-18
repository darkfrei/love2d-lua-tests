
local Preselect = {


	tx = 0, ty=0,
	tw = 0, th=0,
	type = nil, -- or 'spawner' or 'wall'
	spawnerSize = {tw=1, th=1}, -- in tiles
--	spawnerDirections = 
	flowOut = {direction=1},
	flowIn = {direction=1},

	selectedZone = nil, -- or entity
}

-- [initializes a new preselect object]
function Preselect:init(x, y, width, height, objectType)
	self.tx = x
	self.ty = y
	self.tw = width
	self.th = height
	self.type = objectType or 'spawner'
end

-- [updates the preselect position and adjusts geometry near screen edges]
function Preselect:update(cursorX, cursorY, screenWidth, screenHeight)
	self.tx = cursorX
	self.ty = cursorY

	-- adjust size and position if near edges
	if self.tx + self.tw > screenWidth then
		self.tx = screenWidth - self.tw
	end
	if self.ty + self.th > screenHeight then
		self.ty = screenHeight - self.th
	end
end

-- [confirms the preselect and saves it to the level table]
function Preselect:confirm(levelTable)
	local spawnerData = {
		x = self.tx,
		y = self.ty,
		width = self.tw,
		height = self.th,
		type = self.type,
		flowOut = self.flowOut,
		flowIn = self.flowIn,
	}
	table.insert(levelTable, spawnerData)
end

-- [creates a new entity based on the current preselect]
function Preselect:newEntity(isSpawner)
	local tx = self.temp and self.temp.tx or self.tx
	local ty = self.temp and self.temp.ty or self.ty
	local tw = self.temp and self.temp.tw or self.tw
	local th = self.temp and self.temp.th or self.th

	if isSpawner then
		return {
			tx = tx,
			ty = ty,
			tw = tw,
			th = th,
			zoneArt = 1,
			zoneColor = 1,
			type = 'spawner',
			left = true,
			selected = true,
		}
	else
		return {
			tx = tx,
			ty = ty,
			tw = tw,
			th = th,
			zoneArt = 1, -- number of texture in textureList table (data.lua)
			zoneColor = 1, -- number of color in colorList table (data.lua)
			type = 'wall',
			selected = true,
		}
	end
end

return Preselect