-- editor-preselect.lua

-- Preselect
local Preselect = {}

-- Preselect
Preselect.type = nil -- can be 'spawner' or 'wall' or nil
--Preselect.type = 'spawner' -- can be 'spawner' or 'wall' or nil
Preselect.tx = 0 -- [X position of the preselect in grid coordinates]
Preselect.ty = 0 -- [Y position of the preselect in grid coordinates]

Preselect.nothingSize = {tw = 1, th = 1}
Preselect.wallSize = {tw = 1, th = 1}
Preselect.spawnerSize = {tw = 2, th = 2}

Preselect.size = {tw = 1, th = 1}
--Preselect.size = Preselect.nothingSize

--spawnerDirections: 1, 2, 3, 4, 6, 7, 8, 9 as NumPad:
Preselect.flowOutDirection = 8 -- [default size for spawner type preselect]
Preselect.flowInDirection = 2 -- [default size for spawner type preselect]
Preselect.selectedEntity = nil -- current entity in preselect

Preselect.isLeftHandTraffic = false


function Preselect.updatePreselectSpawnerZone()
--	print ('updatePreselectSpawnerZone')
	local entity = Preselect.cursorEntity

	if entity and entity.type ~= 'spawner' then return end

	-- get preselect position and size
	local tx, ty = Preselect.tx, Preselect.ty
	local tw, th = Preselect.size.tw, Preselect.size.th

	local tileSize = GameConfig.tileSize
	local gameTW = GameConfig.tileCountW-1 -- 32
	local gameTH = GameConfig.tileCountH-1 -- 20

-- entity position:
	local top = (ty == 0)
	local left = (tx == 0)
	local right = (tx + tw > gameTW)
	local bottom = (ty + th > gameTH)
	local topLeft = top and left
	local topRight = top and right
	local bottomLeft = bottom and left
	local bottomRight = bottom and right

--	print (top, left, right, bottom)

	local positionType = top and 'top' or bottom and 'bottom' or false

	positionType = positionType and left and positionType..'Left' 
	or left and 'left' 
	or positionType

	positionType = positionType and right and positionType..'Right' 
	or right and 'right' 
	or positionType 
	or 'common'

	--[[

	local positionData = {
		topRight = {tx=gameTW, ty=0, tw=1, th=1, flowDirections=1},
		topLeft = {tx=0, ty=0, tw=1, th=1, flowDirections=3},
		bottomRight = {tx=gameTW, ty=gameTH, tw=1, th=1, flowDirections=7},
		bottomLeft = {tx=0, ty=gameTH, tw=1, th=1, flowDirections=9},

		top = {tx=tx, ty=0, tw=2, th=1, flowDirections=2},
		left = {tx=0, ty=ty, tw=1, th=2, flowDirections=6},
		right = {tx=gameTW, ty=ty, tw=1, th=2, flowDirections=4},
		bottom = {tx=tx, ty=gameTH, tw=2, th=1, flowDirections=8},

		common = {tx=tx, ty=ty, tw=Preselect.size.tw, th=Preselect.size.th, 
			flowOutDirection = Preselect.flowOutDirection,
			flowInDirection = Preselect.flowInDirection
		},
	}

	local posData = positionData[positionType]

	for i, v in pairs (posData) do
		if i == 'flowDirections' then
			entity.flowOutDirection = v
			entity.flowInDirection = v
		else
			entity[i] = v
		end
	end
	
	--]]

	-- store the position in the entity
	entity.positionType = positionType


	Editor.updateSpawnerEntity (entity)
end





-- [renders the preselect area]
function Preselect.draw()
	if not Preselect.tx or not Preselect.ty 
	or not Preselect.size.tw or not Preselect.size.th then
		return -- nothing to draw if the necessary parameters are not set
	end

	local tileSize = 40
	local x = Preselect.tx * tileSize
	local y = Preselect.ty * tileSize
	local width = Preselect.size.tw * tileSize
	local height = Preselect.size.th * tileSize

	local entity = Preselect.cursorEntity

	-- set color based on the type of preselect

	if entity then
		love.graphics.setLineWidth (3)
		Editor.drawEntity (entity)
		love.graphics.setColor(1, 1, 1, 1) -- white
		love.graphics.rectangle("line", x, y, width, height)
		if entity.index then
			love.graphics.print (entity.index, x, y)
		end
	else
		love.graphics.setLineWidth (1)
		love.graphics.setColor(1, 1, 1, 0.3) -- white with 30% transparency
		love.graphics.rectangle("fill", x, y, width, height)
		love.graphics.setColor(1, 1, 1, 1) -- white
		love.graphics.rectangle("line", x, y, width, height)	
	end
end

-- [sets the preselect type to 'wall', or unsets it if already set]
function Preselect.setWall()
	local entity = Preselect.cursorEntity
	if entity and entity.type == 'wall' then
		Preselect.cursorEntity = nil
		Preselect.size = Preselect.nothingSize
	else
		Preselect.size = Preselect.wallSize
		Preselect.cursorEntity = Preselect.newEntity ('wall')
	end
end

-- [sets the preselect type to 'spawner', or unsets it if already set]
function Preselect.setSpawner()
	local entity = Preselect.cursorEntity

	if entity and entity.type == 'spawner' then
		-- unset the preselect type if it is already 'spawner'
		Preselect.cursorEntity = nil
		Preselect.size = Preselect.nothingSize
	else
		-- set the preselect type to 'spawner' and initialize properties
		Preselect.size = Preselect.spawnerSize
		Preselect.cursorEntity = Preselect.newEntity ('spawner')
		Preselect.updatePreselectSpawnerZone()
	end
end


-- [increases or decreases the size of the preselect area]
function Preselect.increaseSize(dw, dh)
	local activeEntity = Preselect.selectedEntity
	local cursorEntity = Preselect.cursorEntity

	print ('Preselect.increaseSize', dw, dh)
	if cursorEntity then
		Preselect.size.tw = math.max(1, Preselect.size.tw + dw)
		Preselect.size.th = math.max(1, Preselect.size.th + dh)
		cursorEntity.tw = Preselect.size.tw
		cursorEntity.th = Preselect.size.th

		-- update spawner entity
		if cursorEntity.type == 'spawner' then
			Editor.updateSpawnerEntity(cursorEntity)
		end
	elseif activeEntity then
		activeEntity.tw = math.max(1, activeEntity.tw + dw)
		activeEntity.th = math.max(1, activeEntity.th + dh)

		-- update spawner entity
		if activeEntity.type == 'spawner' then
			Editor.updateSpawnerEntity(activeEntity)
		end
	end
end



-- creates a new entity for the current level based on preselect settings
function Preselect.newEntity(entityType)
	local currentLevel = Editor.currentLevel
	local entity = Editor.newEntity (Preselect.tx, Preselect.ty, 
		Preselect.size.tw, Preselect.size.th, entityType)
	return entity
end



function Preselect.handleTileClick(tx, ty)
	local cursorEntity = Preselect.cursorEntity
	local entityType = cursorEntity.type
	Editor.addEntity (cursorEntity)
	Preselect.cursorEntity = Preselect.newEntity (entityType)
end


-- [updates preselect position and dimensions based on cursor movement]
function Preselect.cursormoved(tx, ty, dtx, dty)
	Preselect.tx = tx
	Preselect.ty = ty

	-- [check for special cases or constraints]
	local gameTW = GameConfig.tileCountW -- total width in tiles
	local gameTH = GameConfig.tileCountH -- total height in tiles

	-- [ensure preselect stays within bounds]
	if tx + Preselect.size.tw > gameTW then
		Preselect.tx = gameTW - Preselect.size.tw
	end

	if ty + Preselect.size.th > gameTH then
		Preselect.ty = gameTH - Preselect.size.th
	end

	local entity = Preselect.cursorEntity
	if entity then
		entity.tx = tx
		entity.ty = ty
		if entity.type == 'spawner' then
			Preselect.updatePreselectSpawnerZone()
		else
			-- wall
		end
	else
		-- not entity
	end
end

-- end of Preselect

return Preselect