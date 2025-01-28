-- editor.lua
-- [editor state implementation]

-- todo:
-- F1 to show debug

local SafeSaveLoad = require ('SafeSaveLoad')

-- Editor
local Editor = {}
Editor.flowMax = 20

Editor.showDebugInfoF1 = false

-- Preselect
local Preselect = {}
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

--	if not entity then
--		entity = Preselect.newEntity ('spawner')
--		print ('new entity!')
--		Preselect.cursorEntity = entity
--	end

--	print ('Preselect.updatePreselectSpawnerZone', entity.index)

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





local function drawArrow(line)
	-- [extract the start and end points from the lines]
	if not line then return end

	-- [define the tile size for scaling]
	local tileSize = GameConfig.tileSize

	local startX, startY = line[1] * tileSize, line[2] * tileSize
	local endX, endY = line[3] * tileSize, line[4] * tileSize

	-- [draw the main line of the arrow]
	love.graphics.line(startX, startY, endX, endY)

	-- [calculate the direction vector for the arrow tip]
	local dx, dy = endX - startX, endY - startY
	local length = math.sqrt(dx^2 + dy^2)
	local unitX, unitY = dx / length, dy / length

	-- [determine arrow tip size and width]
	local arrowSize = 20 -- [length of the arrow tip]
	local arrowWidth = 10 -- [distance between the wings of the tip]

	-- [calculate perpendicular vector for the arrow wings]
	local perpX, perpY = -unitY * arrowWidth / 2, unitX * arrowWidth / 2

	-- [calculate the positions of the arrow tip points]
	local tip1X = endX - arrowSize * unitX + perpX
	local tip1Y = endY - arrowSize * unitY + perpY
	local tip2X = endX - arrowSize * unitX - perpX
	local tip2Y = endY - arrowSize * unitY - perpY

	-- [draw the arrowhead]
	love.graphics.polygon("fill", endX, endY, tip1X, tip1Y, tip2X, tip2Y)
end




local function drawEntity (entity)
	local tileSize = 40
	local x = entity.tx * tileSize
	local y = entity.ty * tileSize
	local width = entity.tw * tileSize
	local height = entity.th * tileSize


	if entity.type == "wall" then
		love.graphics.setColor(1, 0, 0, 0.5) -- red with 50% transparency
		love.graphics.rectangle("fill", x, y, width, height)
		love.graphics.setColor (1,1,1)
		love.graphics.rectangle("line", x, y, width, height)
		if entity.index then
			love.graphics.print (entity.index, x, y)
		end

		love.graphics.print (entity.tw, x, y+12)
		love.graphics.print (entity.th, x, y+12*2)

		return
	end

	-- spawner
	-- draw the rectangle
	love.graphics.setColor(0, 1, 0, 0.5) -- green with 50% transparency
	love.graphics.rectangle("fill", x, y, width, height)
	love.graphics.setColor (1,1,1)
	love.graphics.rectangle("line", x, y, width, height)

	-- todo: must be entity.flowOutRoadLine
	-- todo: must be entity.flowInRoadLine
	local flowOut = entity.flowOut
	local flowIn = entity.flowIn
--	print ('flowOut')
--	print (serpent.block (flowOut))

	-- [draw the flow-out line]
	if flowOut and flowOut.line then
		love.graphics.setColor(0, 0, 1)
		love.graphics.line(
			flowOut.line[1]*tileSize, 
			flowOut.line[2]*tileSize, 
			flowOut.line[3]*tileSize, 
			flowOut.line[4]*tileSize
		)
		drawArrow(flowOut.line)
		local x = flowOut.line[3]*tileSize
		local y = flowOut.line[4]*tileSize
		local amount = #flowOut
		love.graphics.print (amount, x, y)
	end

	-- [draw the flow-in line]
	if flowIn and flowIn.line then

		love.graphics.setColor(1, 0, 0)
--		love.graphics.line(flowIn.line)
		love.graphics.line(
			flowIn.line[1]*tileSize, 
			flowIn.line[2]*tileSize, 
			flowIn.line[3]*tileSize, 
			flowIn.line[4]*tileSize
		)
		drawArrow(flowIn.line)
		local x = flowIn.line[1]*tileSize
		local y = flowIn.line[2]*tileSize
		local amount = #flowIn
		love.graphics.print (amount, x, y)
	end

	if entity.index then
		love.graphics.print (entity.index, x, y)
	end

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
		drawEntity (entity)
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

-- creates a new entity with given properties
local function newEntity(tx, ty, tw, th, entityType)
	local entity = {
		tx = tx,               -- top-left x position in tiles
		ty = ty,               -- top-left y position in tiles
		tw = tw,               -- width in tiles
		th = th,               -- height in tiles
		type = entityType      -- type of the entity (e.g., 'spawner')
	}

	-- if the entity is a spawner, initialize flow configurations
	if entityType == 'spawner' then
		entity.flowOut = {}           -- output flow configuration
		entity.flowIn = {}            -- input flow configuration
		entity.flowOutDirection = Preselect.flowOutDirection
		entity.flowInDirection = Preselect.flowInDirection
	end

	return entity
end

-- creates a new entity for the current level based on preselect settings
function Preselect.newEntity(entityType)
	local currentLevel = Editor.currentLevel
	local entity = newEntity (Preselect.tx, Preselect.ty, 
		Preselect.size.tw, Preselect.size.th, entityType)
	return entity
end


function Editor.getHoveredEntity (tx, ty)
	local currentLevel = Editor.currentLevel
	for entityIndex, entity in ipairs(currentLevel.entities) do
		if tx >= entity.tx and ty >= entity.ty
		and tx < entity.tx + entity.tw and ty < entity.ty + entity.th then
			return entity
		end
	end
end





serpent = require ('serpent')


function Editor.createEntityOnLevel(entity, levelIndex)
	-- retrieves the level by its index
	local level = Editor.levels[levelIndex]
	local worldLevel = WorldManager.getWorldLevelByIndex (levelIndex)
	if not level and not worldLevel then
		error("Level with index " .. tostring(levelIndex) .. " does not exist")
	elseif not level then
		-- init level
		print ('Editor.createEntityOnLevel', 'level created')
		Editor.initLevel (levelIndex)
		level = Editor.levels[levelIndex]
	else
--		error ('Editor.createEntityOnLevel: no worldLevel index: '..levelIndex)
	end

	-- assigns a unique index to the entity
	local entityIndex = WorldManager.generateNewEntityIndex()
	entity.index = entityIndex

	-- adds the entity to the level's entity list
	table.insert(level.entities, entity)

	-- logs information about the created entity
	print("Entity created on level " .. levelIndex .. ":")
	print(serpent.block(entity))

	return entity -- returns the created entity
end



function Editor.setBackgroundActive ()
	Editor.backgroundImage = Editor.backgroundImageActive
end



function Editor.applyCommonFlowDirections (entity)
	local tx, ty, tw, th = entity.tx, entity.ty, entity.tw, entity.th
	local flowOutDirection = entity.flowOutDirection
	local flowInDirection = entity.flowInDirection


	local commonFlowConfigurations = {
		-- topLeft
		[7] = {tx1=0.5, ty1=0.5, tx2=-0.5, ty2=0.5, tx3=-1, ty3=-1},
		-- topRight
		[9] = {tx1=tw-0.5, ty1=0.5, tx2=-0.5, ty2=-0.5, tx3=1, ty3=-1},
		-- bottomRight
		[3] = {tx1=tw-0.5, ty1=th-0.5, tx2=0.5, ty2=-0.5, tx3=1, ty3=1},
		-- bottomLeft
		[1] = {tx1=0.5, ty1=th-0.5, tx2=0.5, ty2=0.5, tx3=-1, ty3=1},
		-- top
		[8] = {tx1=tw*0.5, ty1=0.5, tx2=-0.5, ty2=0, tx3=0, ty3=-1},
		-- right
		[6] = {tx1=tw-0.5, ty1=th*0.5, tx2=0, ty2=-0.5, tx3=1, ty3=0},
		-- bottom
		[2] = {tx1=tw*0.5, ty1=th-0.5, tx2=0.5, ty2=0, tx3=0, ty3=1},
		-- left
		[4] = {tx1=0.5, ty1=th*0.5, tx2=0, ty2=0.5, tx3=-1, ty3=0},
	}

	if flowOutDirection == flowInDirection then
		-- special case with left and right hand traffic
		local fc = commonFlowConfigurations[flowOutDirection]
		local isLeftHandTraffic = entity.isLeftHandTraffic and 1 or -1

		-- calculate the center of the entity flow points
		local txc = tx+fc.tx1
		local tyc = ty+fc.ty1

		-- determine whether to use left-hand or right-hand traffic
		local multiplier = entity.isLeftHandTraffic and 1 or -1

		-- calculate start / end line flow points
		local x2out = txc+fc.tx2*multiplier
		local y2out = tyc+fc.ty2*multiplier
		local x2in = txc-fc.tx2*multiplier
		local y2in = tyc-fc.ty2*multiplier

		-- calculate directions
		local x3 = fc.tx3
		local y3 = fc.ty3


		local lineOut = {x2out, y2out, x2out+x3, y2out+y3}
		local lineIn = {x2in+x3, y2in+y3, x2in, y2in}

		-- assign lines to entity
		entity.flowOut = {line = lineOut}
		entity.flowIn = {line = lineIn}
	else
		local fcOut = commonFlowConfigurations[flowOutDirection]


		local x2out = tx+fcOut.tx1
		local y2out = ty+fcOut.ty1
		local x3out = x2out + fcOut.tx3
		local y3out = y2out + fcOut.ty3
		local lineOut = {x2out, y2out, x3out, y3out}
		entity.flowOut = {line = lineOut}

--		print ('flowInDirection: '.. flowInDirection)
		local fcIn = commonFlowConfigurations[flowInDirection]
--		print ('in', fcIn.tx1, fcIn.ty1, fcIn.tx3, fcIn.ty3)
		local x2in = tx + fcIn.tx1
		local y2in = ty + fcIn.ty1
		local x3in = x2in + fcIn.tx3
		local y3in = y2in + fcIn.ty3
		print ('in', x2in, y2in, x3in, y3in)
		local lineIn = {x3in, y3in, x2in, y2in}
		entity.flowIn = {line = lineIn}
	end
end

function Editor.applyFlowDirections(entity)
	-- calculate flow directions for the entity

	if entity.type == 'wall' then return end

	local positionType = entity.positionType
	if positionType == "common" then
		Editor.applyCommonFlowDirections (entity)
		return
	end

	local flowConfiguration = UtilsData.flowConfigurations[positionType]
	local fc = flowConfiguration
	local tx, ty, tw, th = entity.tx, entity.ty, entity.tw, entity.th

	-- calculate the center of the entity flow points
	local txc = tx+fc.tx1
	local tyc = ty+fc.ty1

	-- determine whether to use left-hand or right-hand traffic
	local multiplier = entity.isLeftHandTraffic and 1 or -1

	-- calculate start / end line flow points
	local x2out = txc+fc.tx2*multiplier
	local y2out = tyc+fc.ty2*multiplier
	local x2in = txc-fc.tx2*multiplier
	local y2in = tyc-fc.ty2*multiplier

	-- calculate directions
	local x3 = fc.tx3
	local y3 = fc.ty3


	local lineOut = {x2out, y2out, x2out+x3, y2out+y3}
	local lineIn = {x2in+x3, y2in+y3, x2in, y2in}

	-- assign lines to entity
	entity.flowOut = {line = lineOut}
	entity.flowIn = {line = lineIn}
end

function Editor.applySize(entity)

	local positionType = entity.positionType
	if not positionType then error ('ERROR! no positionType in Editor.applySize') end
	if positionType == 'common' then return end
		
	local entityPosition = UtilsData.entityPositions[positionType]
	local sep = entityPosition

	entity.tw = sep.tw
	entity.th = sep.th

	local minX = 0
	local maxX = GameConfig.tileCountW - 1
	local minY = 0
	local maxY = GameConfig.tileCountH - 1

	if sep.tx == 'minX' then
		entity.tx = minX
	elseif sep.tx == 'maxX' then
		entity.tx = maxX
	end

	if sep.ty == 'minY' then
		entity.ty = minY
	elseif sep.ty == 'maxY' then
		entity.ty = maxY
	end
end

-- [updates spawner entity with the given parameters]
function Editor.updateSpawnerEntity(entity)
	if entity.type == 'wall' then return end

	Editor.applySize(entity)
	Editor.applyFlowDirections(entity)

end


function Editor.placeTwinEntities (levelIndex, entity)
	-- create the first entity on the specified level
	Editor.createEntityOnLevel(entity, levelIndex)

	local entityIndex = entity.index
	local positionType = entity.positionType

	-- debug information for the first entity
--	print('Editor.placeTwinEntities', 'Placed first of twin')
--	print('Editor.placeTwinEntities', 'LevelIndex: ' .. levelIndex .. ', EntityIndex: ' .. entityIndex .. ', PositionType: ' .. positionType)

	-- retrieve position attributes
	local entityPosition = UtilsData.entityPositions[positionType]

	-- get the neighboring level index based on the position type
	local worldLevel = WorldManager.getWorldLevelByIndex (levelIndex)
	local secondLevelIndex = worldLevel.neighbours[positionType]

	-- determine the opposite position type for the second entity
	local secondPositionType = UtilsData.extendedOffsetOpposites[positionType]
	
	-- calculate the second entity's position and size
	local tx = entity.tx
	local ty = entity.ty
	local tw = entity.tw
	local th = entity.th

	-- create the second entity at the same position as the first
	local secondEntity = newEntity (tx, ty, tw, th, 'spawner')
	
	secondEntity.positionType = secondPositionType
	Editor.applySize(secondEntity)
	Editor.applyFlowDirections (secondEntity)

	-- create the second entity on the specified level
	Editor.createEntityOnLevel(secondEntity, secondLevelIndex)

	-- link the twin entities
	secondEntity.twinIndex = entityIndex
	entity.twinIndex = secondEntity.index

--	print('Editor.placeTwinEntities', 'Placed second of twin at level ' .. secondLevelIndex .. ', tx: ' .. tx .. ', ty: ' .. ty)
--	print ('secondEntity.positionType: '..secondPositionType)

end

function Editor.addEntity (entity)

	local currentLevel = Editor.currentLevel
	local levelIndex = currentLevel.index

	WorldManager.setWorldLevelEnabled (levelIndex)
	Editor.setBackgroundActive ()

	local entityType = entity.type
	if entityType == 'wall' then
		Editor.createEntityOnLevel(entity, levelIndex)
		return
	end

	local positionType = entity.positionType
	if positionType == 'common' then
		Editor.createEntityOnLevel(entity, levelIndex)
		return
	end

	-- special cases!
--	the entity and the other side
	Editor.placeTwinEntities (levelIndex, entity)
end



-- [handles tile click and updates preselect state]
function Preselect.tileClicked(tx, ty)
	local currentLevel = Editor.currentLevel

	-- [update preselect position]
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

	-- [update entity linked to preselect, if any]
	local cursorEntity = Preselect.cursorEntity
	local selectedEntity = Preselect.selectedEntity

	if cursorEntity then
		-- [insert cursorEntity into the current level and prepare a new one]
		local entityType = cursorEntity.type
--		placeEntity (cursorEntity)
		Editor.addEntity (cursorEntity)

		Preselect.selectedEntity = cursorEntity

		Preselect.cursorEntity = Preselect.newEntity (entityType)

		Preselect.selectedEntity = nil
		return
	end


	if selectedEntity then
		-- [deselect the currently selected entity]
		Preselect.selectedEntity = nil
	end

	local hoveredEntity = Editor.getHoveredEntity (tx, ty) 
	if hoveredEntity then
		Preselect.selectedEntity = hoveredEntity
	end

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



-- initializes a new level with the given index
-- creates an empty table for entities in the new level
function Editor.initLevel(levelIndex)
	local newLevel = {}
	-- set the index for the level
	newLevel.index = levelIndex
	-- initialize an empty entities table
	newLevel.entities = {}

	Editor.levels[levelIndex] = newLevel
	-- return the new level structure
	return newLevel
end


local function loadLevel (index)
	-- constructs the filename for the level based on its index
	local filename = 'level-'..index..'.dat'
	local file = io.open(filename, 'r')

	if not file then
--		print('Warning: Level file not found: ' .. filename)
		return nil -- returns nil if the file does not exist
	end

	local levelData = file:read('*a')
	file:close()

	-- deserializes the level data
	local level = SafeSaveLoad.deserializeString(levelData)

	if not level then
		error ('loadLevel', 'Failed to deserialize level data from file: ' .. filename)
	elseif not level.entities then
		-- ensures the level has an entities table
		print('loadLevel', 'No entities found, initialized an empty table')
	end

	-- assigns the index to the level
	level.index = index

	return level
end


function Editor.getOrLoadLevel(levelIndex)
	-- attempts to retrieve the level from the loaded levels table
	local level = Editor.levels[levelIndex]
	if level then
		return level -- returns the level if it exists in memory
	end

	-- attempts to load the level from a file
	level = loadLevel(levelIndex)
	if level then
		Editor.levels[levelIndex] = level
		print('Level " .. levelIndex .. " loaded from file and added to Editor.levels')
		return level
	end

	-- creates a new level if it cannot be loaded
	level = Editor.initLevel(levelIndex)

	print('Editor.getOrLoadLevel', 'Level ' .. levelIndex .. ' created new')
	return level
end


function Editor.loadAllWorldLevels()
	-- loads all levels from world levels and adds them to Editor.levels
	local worldLevels = WorldManager.world.worldLevels

	Editor.levels = {}
	local amount = 0
	for _, worldLevel in ipairs(worldLevels) do
		local levelIndex = worldLevel.index
		-- load from file:
		local level = loadLevel(levelIndex) -- attempt to load the level by its index
		if level then
			Editor.levels[levelIndex] = level -- store the loaded level
			amount = amount + 1
--			print('Editor.loadAllWorldLevels', 'Level ' .. levelIndex .. ' loaded and added')
		else
--			print('Editor.loadAllWorldLevels', 'Level ' .. levelIndex .. ' could not be loaded')
		end
	end
	print ('Editor.loadAllWorldLevels', 'Amount loaded levels: '..amount)
end


function Editor.init()
	Editor.loadAllWorldLevels() -- load all levels into Editor.levels
	Editor.setLevel(1) -- set the first level
end

function Editor.enter()
	-- [initializes editor state]
	print("Editor state entered")
	Editor.init()
end

function Editor.update(dt)
	-- [updates editor logic]
end

local function getBackground (isActive) -- active worldLevel
	local ts = GameConfig.tileSize -- 40
	local tw = GameConfig.tileCountW -- 30
	local th = GameConfig.tileCountH -- 20

	local w = tw*ts
	local h = th*ts

	local backgroundCanvas = love.graphics.newCanvas (w, h)
	love.graphics.setCanvas (backgroundCanvas)

	local backgroundColor
	local backgroundLinesColor

	if isActive then
		backgroundColor = UtilsData.colorsBackgroundActive.backgroundColor
		backgroundLinesColor = UtilsData.colorsBackgroundActive.backgroundLinesColor
	else
		backgroundColor = UtilsData.colorsEditorBackgroundNotActive.backgroundColor
		backgroundLinesColor = UtilsData.colorsEditorBackgroundNotActive.backgroundLinesColor
	end

	love.graphics.setColor(backgroundColor)
	love.graphics.rectangle ('fill', 0, 0, w, h)

	love.graphics.setColor (backgroundLinesColor)
	love.graphics.setLineStyle ('rough')
	love.graphics.setLineWidth (2)

	for i = 0, tw do
		local x = i * ts
		love.graphics.line (x, 0, x, h)
	end
	for j = 0, th do
		local y = j * ts
		love.graphics.line (0, y, w, y)
	end

	love.graphics.setColor (love.math.colorFromBytes( 160, 230, 255 ))
	love.graphics.setLineWidth (3)
	love.graphics.rectangle ('line', 0,0, w, h)

	love.graphics.setCanvas ()
	return backgroundCanvas
end

Editor.backgroundImageActive = getBackground (true)
Editor.backgroundImageNotActive = getBackground (false)
Editor.backgroundImage = Editor.backgroundImageActive -- Editor.backgroundImageNotActive

Editor.mouseCursor = {tx=0, ty=0, tw=1, th=1} -- tiles

-- [renders a single wallZone object]
local function drawEntityTexture (entity)
	local ts = GameConfig.tileSize -- 40
	local tx, ty = entity.tx, entity.ty
	local tw, th = entity.tw, entity.th

	local x, y = tx*ts, ty*ts


	local texture = UtilsData.zoneArtList[entity.zoneArt]
	local color = UtilsData.zoneColorList[entity.zoneColor]

	-- [sets color for the wall]
	if color then
		love.graphics.setColor(color)
	else
		return
	end

	-- outline
	love.graphics.rectangle ('line', ts*tx, ts*ty, ts*tw, ts*th)


	-- [draws the texture of the wall]

	if texture and texture.f then
		local textureSize = texture.size -- 40 or 80
		local step = textureSize/ts -- 1 or 2
		local max_i = math.floor(tw/step)*step-1
		local max_j = math.floor(th/step)*step-1
		for i = 0, max_i, step do
			for j = 0, max_j, step do
				texture.f(x+i*ts, y+j*ts)
			end
		end
	end
end


local function drawPreselect ()
	local tileCountW = GameConfig.tileCountW
	local tileCountH = GameConfig.tileCountH
	local ts = GameConfig.tileSize

	local preselect = Editor.preselect
	local tx = preselect.temp and preselect.temp.tx or preselect.tx
	local ty = preselect.temp and preselect.temp.ty or preselect.ty
	local tw= preselect.temp and preselect.temp.tw or preselect.tw
	local th= preselect.temp and preselect.temp.th or preselect.th

	if preselect.entityType == 'spawner' then
		love.graphics.setColor (1,1,0)
	else
		love.graphics.setColor (1,1,1)
	end
	if preselect.type == 'common' then

	end
	love.graphics.setLineWidth (1)
	love.graphics.rectangle ('line', ts*tx, ts*ty, ts*tw, ts*th)
	love.graphics.line (ts*tx, ts*ty, ts*tx+ts*tw, ts*ty+ts*th)
	love.graphics.line (ts*tx, ts*ty+ts*th, ts*tx+ts*tw, ts*ty)
end

function Editor.drawDebugInfo()
	if not Editor.showDebugInfoF1 then return end

	local levelIndex = Editor.currentLevel and Editor.currentLevel.index or "None"

	local infoText = {
		"Debug Information:",
		"Preselect.isLeftHandTraffic: " .. tostring(Preselect.isLeftHandTraffic),

		"Current Level: " .. levelIndex,
		"Entities: " .. (#Editor.currentLevel.entities or 0),
	}
	if Preselect.selectedEntity then
		local e = Preselect.selectedEntity
		table.insert (infoText, "selectedEntity.isLeftHandTraffic: " .. tostring(e.isLeftHandTraffic))
		table.insert (infoText, "selectedEntity.flowOutDirection: " .. tostring(e.flowOutDirection))
		table.insert (infoText, "selectedEntity.flowInDirection: " .. tostring(e.flowInDirection))

		if e.twinIndex then
			table.insert (infoText, "selectedEntity.twinIndex: " .. tostring(e.twinIndex))
		end
	end

	local cursorEntity = Preselect.cursorEntity
	if cursorEntity then
		table.insert (infoText, "cursorEntity.type: " .. tostring(cursorEntity.type))
		table.insert (infoText, "cursorEntity.positionType: " .. tostring(cursorEntity.positionType))
		table.insert (infoText, "cursorEntity.flowOutDirection: " .. tostring(cursorEntity.flowOutDirection))
		table.insert (infoText, "cursorEntity.flowInDirection: " .. tostring(cursorEntity.flowInDirection))
	end


	love.graphics.setColor(0, 0, 0)

	-- draw the debug information line by line
	for i, line in ipairs(infoText) do
		love.graphics.print(line, 40, 40 + (i - 1) * 15)
	end
end


function Editor.draw()
	local ts = GameConfig.tileSize
	local currentLevel = Editor.currentLevel
	-- background
	love.graphics.setColor (1,1,1)
--	love.graphics.draw (backgroundImage)
	love.graphics.draw (Editor.backgroundImage)


	local selectedEntity = Preselect.selectedEntity
	for i, entity in ipairs (currentLevel.entities) do
		love.graphics.setLineWidth (1)
		if selectedEntity and selectedEntity == entity then
			love.graphics.setLineWidth (3)
		end
		drawEntity (entity)
		drawEntityTexture (entity)
	end

	Preselect.draw()

	-- draw neighbour levels
	-- wip
	-- wip
	-- wip
	if Editor.neighbours then
		for i, v in pairs (Editor.neighbours) do
			if v.text then
				love.graphics.print (v.text, v.x, v.y)
			end
		end
	end

	-- draw arrows from selected entity
	-- wip
	-- wip
	-- wip

	Editor.drawDebugInfo()
end

function Editor.exit()
	-- [cleans up editor state]
	print("Editor state exited")
end


--[[
local function createEntity (isSpawner) -- bool
	local preselect = Editor.preselect
	print ('createEntity', Editor.preselect)
	local tx = preselect.temp and preselect.temp.tx or preselect.tx
	local ty = preselect.temp and preselect.temp.ty or preselect.ty
	local tw = preselect.temp and preselect.temp.tw or preselect.tw
	local th = preselect.temp and preselect.temp.th or preselect.th


	if Editor.selectedZone then
		Editor.selectedZone.selected = nil
		Editor.selectedZone = nil
	end


	if isSpawner then
		local spawnZone = {
			tx = tx,
			ty = ty,
			tw = tw,
			th = th,
			zoneArt = 1,
			zoneColor = 1,
			type = 'spawner',
			left = true,
		}

		updateSpawnerZone (spawnZone)

		Editor.selectedZone = spawnZone
		spawnZone.selected = true
		table.insert (currentLevel.entities, spawnZone)
	else
		local wallZone = {
			tx = tx,
			ty = ty,
			tw = tw,
			th = th,
			zoneArt = 1, -- number of texture in textureList table (data.lua)
			zoneColor = 1, -- number of color in colorList table (data.lua)
--			letter='W',
			type = 'wall',
		}
		Editor.selectedZone = wallZone
		wallZone.selected = true
--		table.insert (currentLevel.walls, wallZone)
		table.insert (currentLevel.entities, wallZone)
	end
end
--]]


-- [removes all outgoing flows from an entity to the deleted entity]
local function removeOutgoingFlows(entity, targetEntityIndex)
	for i = #entity.flowOut, 1, -1 do
		if entity.flowOut[i] == targetEntityIndex then
			table.remove(entity.flowOut, i)
		end
	end
end

-- [removes all incoming flows from the deleted entity to other entities]
local function removeIncomingFlows(entity, targetEntityIndex)
	for i = #entity.flowIn, 1, -1 do
		if entity.flowIn[i] == targetEntityIndex then
			table.remove(entity.flowIn, i)
		end
	end
end

-- [deletes all flows related to the selected entity]
function Editor.deleteSelectedZoneFlow(entity)
	local currentLevel = Editor.currentLevel

	if entity.type ~= 'spawner' then return end

	-- [loop through all entities and remove references to the deleted entity's ID in their flows]
	for _, otherEntity in ipairs(currentLevel.entities) do
		if otherEntity.type == 'spawner' and otherEntity ~= entity then
			-- [remove outgoing and incoming flows from the other entity]
			removeOutgoingFlows(otherEntity, entity.index)
			removeIncomingFlows(otherEntity, entity.index)
		end
	end
end






-- [deletes the selected entity and its associated flows]
function Editor.deleteSelectedZone()
	local selectedEntity = Preselect.selectedEntity
	local currentLevel = Editor.currentLevel
	local entities = currentLevel.entities

	if selectedEntity then
		-- [remove the selected entity from the list of entities]
		for i, entity in ipairs(entities) do
			if entity == selectedEntity then
				-- [delete the flows between the selected entity and others]
				Editor.deleteSelectedZoneFlow(selectedEntity)
				table.remove(entities, i)
				break
			end
		end
	end
end

function Editor.toggleTrafficDirection ()
	-- toggle traffic direction based on the selected or cursor entity
	local activeEntity = Preselect.selectedEntity
	local cursorEntity = Preselect.cursorEntity

	if activeEntity and not cursorEntity then
		-- toggle traffic direction for the active entity
		activeEntity.isLeftHandTraffic = not activeEntity.isLeftHandTraffic

		Editor.applyFlowDirections(activeEntity)
	elseif cursorEntity and not activeEntity then
		-- toggle traffic direction for the cursor entity
		cursorEntity.isLeftHandTraffic = not cursorEntity.isLeftHandTraffic
	else
		-- toggle global traffic direction
		Preselect.isLeftHandTraffic = not Preselect.isLeftHandTraffic
	end


end




local function changeOutputPosition ()
	local activeEntity = Preselect.selectedEntity
	local cursorEntity = Preselect.cursorEntity

--		entity.flowOutDirection = 3 
--		entity.flowInDirection = 3   -

	if cursorEntity then
		local i = cursorEntity.flowOutDirection
		i = i + 1
		if i == 5 then 
			i = 6
		elseif i == 10 then 
			i = 1 
		end
		cursorEntity.flowOutDirection = i
		Preselect.flowOutDirection = i
		Editor.updateSpawnerEntity (cursorEntity)

	elseif activeEntity then
		local i = activeEntity.flowOutDirection
		i = i + 1
		if i == 5 then 
			i = 6
		elseif i == 10 then 
			i = 1 
		end
		activeEntity.flowOutDirection = i
		Preselect.flowOutDirection = i
		Editor.updateSpawnerEntity (activeEntity)
	end
end

local function changeInputPosition ()
	local activeEntity = Preselect.selectedEntity
	local cursorEntity = Preselect.cursorEntity

--		entity.flowOutDirection = 3 
--		entity.flowInDirection = 3   -

	if cursorEntity then
		local i = cursorEntity.flowInDirection
		i = i + 1
		if i == 5 then 
			i = 6
		elseif i == 10 then 
			i = 1 
		end
		cursorEntity.flowInDirection = i
		Preselect.flowInDirection = i
		Editor.updateSpawnerEntity (cursorEntity)
	elseif activeEntity then
		local i = activeEntity.flowInDirection
		i = i + 1
		if i == 5 then 
			i = 6
		elseif i == 10 then 
			i = 1 
		end
		activeEntity.flowInDirection = i
		Preselect.flowInDirection = i
		Editor.updateSpawnerEntity (activeEntity)
	end

end


local function nextZoneArt ()
	local activeEntity = Preselect.selectedEntity
--	local zone = Editor.selectedZone
--	if not zone then return end
--	local zoneArt = zone.zoneArt
--	zone.zoneArt = (zoneArt + 0) % #Data.zoneArtList + 1
end

local function prevZoneArt ()
	local activeEntity = Preselect.selectedEntity
	local cursorEntity = Preselect.cursorEntity
--	local zone = Editor.selectedZone
--	if not zone then return end
--	local zoneArt = zone.zoneArt
--	zone.zoneArt = (zoneArt - 2) % #Data.zoneArtList + 1
end


local function nextZoneColor ()
	local selectedEntity = Preselect.selectedEntity
--	if not zone then return end
--	local zoneColor = zone.zoneColor
--	zone.zoneColor = (zoneColor + 0) % #Data.zoneColorList + 1
end


function Editor.saveLevels()
-- iterate through all levels and save them
	for _, level in pairs(Editor.levels) do
		local index = level.index
		print ('Editor.saveLevels', 'save index: '..index)
		if level.entities and #level.entities > 0 then
			local filename = "level-" .. level.index .. ".dat"
			local data = SafeSaveLoad.serializeTable(level)

			-- write the data to the file
			local file = io.open(filename, "w")
			if file then
				file:write(data)
				file:close()
				print('Editor.saveLevels', 'Level ' .. index .. ' saved to ' .. filename)
			else
				print('Editor.saveLevels', 'Failed to save level ' .. index)
			end
		elseif level.entities and #level.entities == 0 then
			print('Editor.saveLevels', 'Not saved level: ' .. index ..' - no entities')
		elseif not level.entities then
			print('Editor.saveLevels', 'Not saved level: ' .. index ..' - no entities as table')
		else
			error ('Editor.saveLevels - cannot save')
		end
	end

	-- [reset preselect entities]
	Preselect.selectedEntity = nil
	Preselect.cursorEntity = nil
	Preselect.size = Preselect.nothingSize
end



function Editor.setLevel (levelIndex)
	-- retrieve game configuration values
	local ts = GameConfig.tileSize
	local tw = GameConfig.tileCountW
	local th = GameConfig.tileCountH

	-- get the world level by its index
	local worldLevel = WorldManager.getWorldLevelByIndex (levelIndex)


	-- set editor neighbours with positions and corresponding neighbour indices
	Editor.neighbours = {
		left = {text = worldLevel.neighbours.left, x=ts/2, y=ts*th/2},
		right = {text = worldLevel.neighbours.right, x=ts*tw-ts/2, y=ts*th/2},
		top = {text = worldLevel.neighbours.top, x=ts*tw/2, y=ts/2},
		bottom = {text = worldLevel.neighbours.bottom, x=ts*tw/2, y=ts*th-ts/2},
		topLeft = {text = worldLevel.neighbours.topLeft, x=ts/2, y=ts/2},
		topRight = {text = worldLevel.neighbours.topRight, x=ts*tw-ts/2, y=ts/2},
		bottomRight = {text = worldLevel.neighbours.bottomRight, x=ts*tw-ts/2, y=ts*th-ts/2},
		bottomLeft = {text = worldLevel.neighbours.bottomLeft, x=ts/2, y=ts*th-ts/2},
	}

	-- set background image based on the world level's enabled state
	if worldLevel.enabled then
		Editor.backgroundImage = Editor.backgroundImageActive
	else
		Editor.backgroundImage = Editor.backgroundImageNotActive
	end

--	local loadedLevel = loadLevel (index)
	local level = Editor.getOrLoadLevel(levelIndex)
	Editor.currentLevel = level

	-- store the level in the editor's levels table
	Editor.levels[levelIndex] = level
end


function Editor.changeLevel (key)
-- [get the current level index from the editor]
	local currentLevelIndex = Editor.currentLevel.index

	-- [change the world level based on the direction key]
	local worldLevel = WorldManager.changeLevel(currentLevelIndex, key)

	local index = worldLevel.index

	-- set the new level in the editor
	Editor.setLevel (index)
end

function Editor.moveEntity(entity, dtx, dty)
	-- update entity's position based on the given dx and dy
	entity.tx = entity.tx + dtx
	entity.ty = entity.ty + dty
	Editor.applyFlowDirections(entity)
end

-- [moves an entity based on the given key direction]
function Editor.changeEntityPosition(key)
	-- [fetch the current position and dimensions of the entity]
	local entity = Preselect.selectedEntity

	local offset = UtilsData.cardinalOffsets[key]
	local dtx = offset.dx
	local dty = offset.dy

	Editor.moveEntity(entity, dtx, dty)
end

function Editor.keypressed(key, scancode)
	local isCtrl = love.keyboard.isDown ('lctrl', 'rctrl')
	local isShift = love.keyboard.isDown ('lshift', 'rshift')

	if key == 'q' then
		-- set nothing
		Preselect.cursorEntity = nil
		Preselect.size = Preselect.nothingSize
	elseif key == 'w' then
		Preselect.setWall()
		return
	elseif key == 'z' then
		Preselect.setSpawner()
		return
	end

	-- [adjusts size based on keypad + or -]
	if key == "kp+" then
		if isCtrl then
			Preselect.increaseSize(1, 0) -- increase size
		elseif isShift then
			Preselect.increaseSize(0, 1) -- increase size
		else
			Preselect.increaseSize(1, 1) -- increase size
		end
		return
	elseif key == "kp-" then
		if isCtrl then
			Preselect.increaseSize(-1, 0) -- decrease  size
		elseif isShift then
			Preselect.increaseSize(0, -1) -- decrease  size
		else
			Preselect.increaseSize(-1, -1) -- decrease  size
		end
		return
	end

	-- save levels and world when ctrl+s is pressed
	if key == "s" then
		if isCtrl then
			Editor.saveLevels()
			WorldManager.saveWorld()
			print("Levels and world saved.")
			return
		end
	end

	-- change input/output positions
	if key == "i" then
		changeInputPosition ()
	elseif key == "o" then
		changeOutputPosition ()
	end

	-- delete selected zone
	if key == "delete" then
		Editor.deleteSelectedZone ()
	end

	-- toggle traffic direction (left or right)
	if key == "b" then
		Editor.toggleTrafficDirection ()
	end


	-- change level based on arrow keys
	if key == 'up' or key == 'right' or key == 'down' or key == 'left' then
		local entity = Preselect.selectedEntity
		if entity and (
			(entity.type == 'wall') 
			or (entity.positionType == 'common') 
			or ((entity.positionType == 'top' or entity.positionType == 'bottom') 
				and (key == 'left' or key == 'right'))
			or ((entity.positionType == 'left' or entity.positionType == 'right') 
				and (key == 'up' or key == 'down'))
			)
			then
			Editor.changeEntityPosition (key)
		else
			Editor.changeLevel (key)
		end
	end

	-- toggle debug info
	if key == 'f1' then
		Editor.showDebugInfoF1 = not Editor.showDebugInfoF1
	end

	-- test (apply common flow directions)
	if key == 'return' then -- enter
		local entity = Preselect.selectedEntity
		Editor.applyCommonFlowDirections (entity)
	end

--	print (key, scancode)
end

function Editor.mousepressed(x, y, button)
	-- [tile size]
	local tileSize = GameConfig.tileSize -- 40

	-- [calculate tile-based cursor position]
	local tx = math.floor(x / tileSize)
	local ty = math.floor(y / tileSize)

	-- [ensure the coordinates are within valid range]
	local txMax, tyMax = GameConfig.tileCountW - 1, GameConfig.tileCountH - 1

	-- [ignore clicks outside the valid range]
	if tx < 0 or ty < 0 or tx > txMax or ty > tyMax then
		-- GUI if exists
		return
	end

	Preselect.tileClicked(tx, ty)
end


function Editor.mousemoved(x, y, dx, dy)
	local tileSize = 40

	-- calculate tile-based cursor position
	local tx = math.floor(x / tileSize)
	local ty = math.floor(y / tileSize)

	-- calculate delta movement in tile coordinates
	local dtx = Preselect.tx - tx
	local dty = Preselect.ty - ty

	-- only update if the cursor has moved to a new tile
	if dtx ~= 0 or dty ~= 0 then
		Preselect.cursormoved(tx, ty, dtx, dty)
	end
end


function Editor.wheelmoved(x, y)
	local tx, ty = Preselect.tx, Preselect.ty

	local selectedEntity = Preselect.selectedEntity
	local hoveredEntity = Editor.getHoveredEntity(tx, ty)

	if not selectedEntity or not hoveredEntity then return end
	if selectedEntity.type ~= 'spawner' or hoveredEntity.type ~= 'spawner' then return end

	local flowOut = selectedEntity.flowOut
	local flowIn = hoveredEntity.flowIn

	if y > 0 then
		-- add flow if not exceeding flowMax for both flowOut and flowIn
		if #flowOut < Editor.flowMax and #flowIn < Editor.flowMax then
			table.insert(flowOut, hoveredEntity.index)
			table.insert(flowIn, selectedEntity.index)
		end
	elseif y < 0 then
		-- remove flow
		for i, flowID in ipairs(flowOut) do
			if flowID == hoveredEntity.index then
				table.remove(flowOut, i)
				break
			end
		end

		for i, flowID in ipairs(flowIn) do
			if flowID == selectedEntity.index then
				table.remove(flowIn, i)
				break
			end
		end
	end
end


return Editor
