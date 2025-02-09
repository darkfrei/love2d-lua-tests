-- editor.lua
-- [editor state implementation]

-- todo:
-- F1 to show debug

local SafeSaveLoad = require ('SafeSaveLoad')
local Preselect = require ('editor-preselect')

-- Editor
local Editor = {}
Editor.flowMax = 20

Editor.showDebugInfoF1 = false

Editor.entityColorIndex = 0

function Editor.getNextColorIndex ()
	-- update the entity color index cyclically
	Editor.entityColorIndex = Editor.entityColorIndex % #UtilsData.entityColorList + 1
	-- return the updated color index
	return Editor.entityColorIndex
end

function Editor.drawArrowOutline(line, size)
	-- check if the line is valid
	if not line then return end

	-- define the tile size for scaling
	local tileSize = GameConfig.tileSize

	-- calculate start and end points of the arrow based on tile positions
	local startX, startY = line[1] * tileSize, line[2] * tileSize
	local endX, endY = line[3] * tileSize, line[4] * tileSize

	-- calculate the direction vector for the arrow tip
	local dx, dy = endX - startX, endY - startY
	local length = math.sqrt(dx^2 + dy^2)
	local unitX, unitY = dx / length, dy / length
	local arrowSize = 10 + 2 * size  -- length of the arrow tip (default is 20)
	local adjustedEndX = endX - arrowSize * unitX
	local adjustedEndY = endY - arrowSize * unitY
	local width = size
	local ax, ay = startX, startY
	local adx, ady = -unitY * width / 2, unitX * width / 2
	
	local bx, by = endX - arrowSize * unitX, endY - arrowSize * unitY
	local arrowTipWidth = 4 + 2 * size
	
	local bdx, bdy = -unitY * arrowTipWidth / 2, unitX * arrowTipWidth / 2
	
	
	local cx, cy = endX, endY

	local vertices = {
		ax + adx, ay + ady, 
		bx + adx, by + ady, 
		bx + bdx, by + bdy, 
		cx, cy, 
		bx - bdx, by - bdy, 
		bx - adx, by - ady, 
		ax - adx, ay - ady, 
		}
	love.graphics.polygon("line", vertices)
	
	-- calculate the middle point of the arrow
	local midX = (startX + endX) / 2
	local midY = (startY + endY) / 2

	-- draw the size text near the middle of the arrow
	love.graphics.print(size*0.5, midX + 5, midY + 5)

end

function Editor.drawArrow(line, size)
	-- check if the line is valid
	if not line then return end

	size = size or 2

	-- define the tile size for scaling
	local tileSize = GameConfig.tileSize

	-- calculate start and end points of the arrow based on tile positions
	local startX, startY = line[1] * tileSize, line[2] * tileSize
	local endX, endY = line[3] * tileSize, line[4] * tileSize

	-- calculate the direction vector for the arrow tip
	local dx, dy = endX - startX, endY - startY
	local length = math.sqrt(dx^2 + dy^2)
	local unitX, unitY = dx / length, dy / length

	-- use the provided size to determine the arrow tip size and width
	local arrowSize = 10 + 2 * size  -- length of the arrow tip (default is 20)
	local arrowWidth = 4 + 2 * size  -- width of the arrow wings, adjusted based on size

	-- reduce the line length by the arrowSize to stop the line at the start of the arrow tip
	local adjustedEndX = endX - arrowSize * unitX
	local adjustedEndY = endY - arrowSize * unitY

	-- draw the main line of the arrow (from start to the adjusted end position)
	love.graphics.setLineWidth(size)
	love.graphics.line(startX, startY, adjustedEndX, adjustedEndY)

	-- calculate perpendicular vector for the arrow wings
	local perpX, perpY = -unitY * arrowWidth / 2, unitX * arrowWidth / 2

	-- calculate the positions of the arrow tip points
	local tip1X = endX - arrowSize * unitX + perpX
	local tip1Y = endY - arrowSize * unitY + perpY
	local tip2X = endX - arrowSize * unitX - perpX
	local tip2Y = endY - arrowSize * unitY - perpY

	-- draw the arrowhead
	love.graphics.polygon("fill", endX, endY, tip1X, tip1Y, tip2X, tip2Y)
end




function Editor.drawEntity (entity)
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

	if entity.entityColorIndex then
		local color = UtilsData.entityColorList[entity.entityColorIndex]
		love.graphics.setColor(color)
	else
		love.graphics.setColor(0, 1, 0, 0.5) -- green with 50% transparency
	end
	love.graphics.rectangle("fill", x, y, width, height)


	love.graphics.setColor (1,1,1)
	love.graphics.rectangle("line", x, y, width, height)

	local flowOut = entity.flowOut
	local flowIn = entity.flowIn

	-- [draw the flow-out line]
	if flowOut and flowOut.line then
		love.graphics.setColor(0, 0, 1, 0.5)
		love.graphics.line(
			flowOut.line[1]*tileSize, 
			flowOut.line[2]*tileSize, 
			flowOut.line[3]*tileSize, 
			flowOut.line[4]*tileSize
		)

		Editor.drawArrow(flowOut.line, 3)
		local x = flowOut.line[3]*tileSize
		local y = flowOut.line[4]*tileSize
		local amount = #flowOut
		love.graphics.print (amount, x, y)
	end

	-- [draw the flow-in line]
	if flowIn and flowIn.line then

		love.graphics.setColor(1, 0, 0)
		love.graphics.line(
			flowIn.line[1]*tileSize, 
			flowIn.line[2]*tileSize, 
			flowIn.line[3]*tileSize, 
			flowIn.line[4]*tileSize
		)
		Editor.drawArrow(flowIn.line, 3)
		local x = flowIn.line[1]*tileSize
		local y = flowIn.line[2]*tileSize
		local amount = #flowIn
		love.graphics.print (amount, x, y)
	end

	if entity.index then
		love.graphics.print (entity.index, x, y)
	end

end


-- creates a new entity with given properties
function Editor.newEntity (tx, ty, tw, th, entityType)
	local entityColorIndex = Editor.getNextColorIndex ()
	local entity = {
		tx = tx,               -- top-left x position in tiles
		ty = ty,               -- top-left y position in tiles
		tw = tw,               -- width in tiles
		th = th,               -- height in tiles
		type = entityType,      -- type of the entity (e.g., 'spawner')
		entityColorIndex = entityColorIndex,
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

function Editor.getHoveredEntity (tx, ty)
	local currentLevel = Editor.currentLevel
	for entityIndex, entity in ipairs(currentLevel.entities) do
		if tx >= entity.tx and ty >= entity.ty
		and tx < entity.tx + entity.tw and ty < entity.ty + entity.th then
			return entity
		end
	end
end





--serpent = require ('serpent')


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
--	print("Entity created on level " .. levelIndex .. ":")
--	print(serpent.block(entity))

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
--		print ('in', x2in, y2in, x3in, y3in)
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
	local sep = entityPosition -- (second) entity position

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
	local twinEntity = Editor.newEntity (tx, ty, tw, th, 'spawner')

	twinEntity.positionType = secondPositionType
	Editor.applySize(twinEntity)
	Editor.applyFlowDirections (twinEntity)

	-- create the second entity on the specified level
	Editor.createEntityOnLevel(twinEntity, secondLevelIndex)

	twinEntity.entityColorIndex = entity.entityColorIndex

	-- link the twin entities
	twinEntity.twinIndex = entityIndex
	entity.twinIndex = twinEntity.index


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



function Editor.getSpawnerPositionType (tx, ty, tw, th)
	-- 
	local gameTW = GameConfig.tileCountW-1 -- 32
	local gameTH = GameConfig.tileCountH-1 -- 20

	local top = (ty == 0)
	local left = (tx == 0)
	local right = (tx + tw > gameTW)
	local bottom = (ty + th > gameTH)
	local topLeft = top and left
	local topRight = top and right
	local bottomLeft = bottom and left
	local bottomRight = bottom and right

	local positionType = top and 'top' or bottom and 'bottom' or false

	positionType = positionType and left and positionType..'Left' 
	or left and 'left' or positionType

	positionType = positionType and right and positionType..'Right' 
	or right and 'right' or positionType or 'common'

	return positionType

end


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


function Editor.loadLevel (index)
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
	level = Editor.loadLevel(levelIndex)
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
		local level = Editor.loadLevel(levelIndex) -- attempt to load the level by its index
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
function Editor.drawEntityTexture (entity)
	local ts = GameConfig.tileSize -- 40
	local tx, ty = entity.tx, entity.ty
	local tw, th = entity.tw, entity.th

	local x, y = tx*ts, ty*ts

	local entityArtIndex = entity.entityArtIndex
	local texture = UtilsData.zoneArtList[entityArtIndex]

	love.graphics.setColor (1,1,1)

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

		table.insert (infoText, "selectedEntity.entityColorIndex: " .. tostring(e.entityColorIndex))

		-- entity.entityArtIndex
		table.insert (infoText, "selectedEntity.entityArtIndex: " .. tostring(e.entityArtIndex))
	end

	local cursorEntity = Preselect.cursorEntity
	if cursorEntity then
		local e = Preselect.cursorEntity
		table.insert (infoText, "cursorEntity.type: " .. tostring(e.type))
		table.insert (infoText, "cursorEntity.positionType: " .. tostring(e.positionType))
		table.insert (infoText, "cursorEntity.flowOutDirection: " .. tostring(e.flowOutDirection))
		table.insert (infoText, "cursorEntity.flowInDirection: " .. tostring(e.flowInDirection))

		table.insert (infoText, "cursorEntity.entityColorIndex: " .. tostring(e.entityColorIndex))

		-- entity.entityArtIndex
		table.insert (infoText, "cursorEntity.entityArtIndex: " .. tostring(e.entityArtIndex))


	end


	love.graphics.setColor(0, 0, 0)

	-- draw the debug information line by line
	for i, line in ipairs(infoText) do
		love.graphics.print(line, 40, 40 + (i - 1) * 15)
	end
end



function Editor.drawFlowArrows()
	-- get the selected entity
	local selectedEntity = Preselect.selectedEntity
	if not selectedEntity or selectedEntity.type ~= 'spawner' then
		return
	end

	if not Editor.overlayArrows then return end

	-- loop through overlay arrows and draw each one
	for i, overlayArrow in ipairs (Editor.overlayArrows) do
		local line = overlayArrow.line -- line in tiles
		local size = overlayArrow.size -- pixels
		local color = overlayArrow.color

		local c = 0.75
		love.graphics.setColor(0, 0, 0, c)
		love.graphics.setLineWidth (2)
		Editor.drawArrowOutline(line, size)

		love.graphics.setColor(color)
		love.graphics.setLineWidth (1)
		Editor.drawArrow(line, size)
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
		Editor.drawEntity (entity)

		love.graphics.setLineWidth (2)
		Editor.drawEntityTexture (entity)
	end

	Preselect.draw()

	if Editor.neighbours then
		for i, v in pairs (Editor.neighbours) do
			if v.text then
				love.graphics.print (v.text, v.x, v.y)
			end
		end
	end

	-- draw arrows from selected entity
	Editor.drawFlowArrows()

	Editor.drawDebugInfo()
end

function Editor.exit()
	-- [cleans up editor state]
	print("Editor state exited")
end


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
function Editor.onEntityDestroyedFlow(entity)
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




function Editor.getLevelEntity(entity)
	for _, level in pairs(Editor.levels) do
		for _, e in pairs(level.entities) do
			if e == entity then
				return level
			end
		end
	end
	return nil
end

function Editor.destroyEntity(entity)
	local level = Editor.getLevelEntity (entity)
	if not level then return nil end

	local entities = level.entities

	if entity then
		-- [remove the selected entity from the list of entities]
		for i, e in ipairs(entities) do
			if e == entity then
				-- [delete the flows between the selected entity and others]
				Editor.onEntityDestroyedFlow(e)
				table.remove(entities, i)
				return entity
			end
		end
	end
end

function Editor.onEntityDestroyed()
	local selectedEntity = Preselect.selectedEntity

	local entity = Editor.destroyEntity(selectedEntity)
	if entity and entity.twinIndex then
		local twinEntity = Editor.getEntityByIndex(entity.twinIndex)
		if twinEntity then
			Editor.destroyEntity(twinEntity)
		end
	end
	
--	Editor.updateOverlayArrows(selectedEntity)
	Editor.overlayArrows = {}
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


function Editor.updateTwinEntity (twinIndex, key, value)
	-- check if twinIndex exists
	if twinIndex then
		local twinEntity = Editor.getEntityByIndex(twinIndex)
		-- check if twinEntity exists
		if twinEntity then 
			-- update the twin entity with the given key and value
			twinEntity[key] = value
		end
	end
end

function Editor.nextZoneArt () -- <- A; -> S: S
	local activeEntity = Preselect.selectedEntity
--	local zone = Editor.selectedZone
--	if not zone then return end
--	local zoneArt = zone.zoneArt
--	zone.zoneArt = (zoneArt + 0) % #Data.zoneArtList + 1

	local selectedEntity = Preselect.selectedEntity
	local cursorEntity = Preselect.cursorEntity 
	local entity = selectedEntity
	if entity then 
		print ('Editor.nextZoneArt', 'selectedEntity')
	else
		entity = cursorEntity
		if entity then
			print ('Editor.nextZoneArt', 'cursorEntity')
		else
			print ('Editor.nextZoneArt', 'no entity')
			return 
		end
	end

	local zoneArtList = UtilsData.zoneArtList

	local entityArtIndex = entity.entityArtIndex

	if entityArtIndex then
		-- update entityArtIndex cyclically
		entityArtIndex = entityArtIndex % #zoneArtList + 1
	else
		-- set the first index
		entityArtIndex = 1	
	end

	entity.entityArtIndex = entityArtIndex

end

function Editor.prevZoneArt () -- <- A; -> S: A
	local activeEntity = Preselect.selectedEntity
	local cursorEntity = Preselect.cursorEntity
--	local zone = Editor.selectedZone
--	if not zone then return end
--	local zoneArt = zone.zoneArt
--	zone.zoneArt = (zoneArt - 2) % #Data.zoneArtList + 1
end



function Editor.entityNextColor () 
	-- press c to change
	print ('next color:')
	local selectedEntity = Preselect.selectedEntity
	local cursorEntity = Preselect.cursorEntity 
	local entity = selectedEntity
	if not entity then 
		entity = cursorEntity
		if not entity then

			return 
		end
	end

	local entityColorIndex = entity.entityColorIndex
	if entityColorIndex then
		-- update color index cyclically
		entityColorIndex = entityColorIndex % #UtilsData.entityColorList + 1
	else
		-- get the next color index from the editor
		entityColorIndex = Editor.getNextColorIndex ()		
	end
	print ('now color index: '.. entityColorIndex)
	entity.entityColorIndex = entityColorIndex

	-- get the twinIndex from the selected entity
	local twinIndex = entity.twinIndex
	-- update the twin entity with the new color index
	Editor.updateTwinEntity(twinIndex, 'entityColorIndex', entityColorIndex)
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

function Editor.getEntityByIndex(index)
	for _, level in pairs(Editor.levels) do
		for _, entity in pairs(level.entities) do
			if entity.index == index then
				return entity
			end
		end
	end
	return nil
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


	local twinIndex = entity.twinIndex
	if twinIndex then
		local twinEntity = Editor.getEntityByIndex(twinIndex)
		Editor.moveEntity(twinEntity, dtx, dty)
	end
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

	if key == "s" then -- no Ctrl: it was above
		print ('s pressed')
		Editor.nextZoneArt ()
	end

	-- change input/output positions
	if key == "i" then
		changeInputPosition ()
	elseif key == "o" then
		changeOutputPosition ()
	end

	-- delete selected zone
	if key == "delete" then
		Editor.onEntityDestroyed ()
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


	if key == 'c' then -- enter
		Editor.entityNextColor ()
	end

--	print (key, scancode)
end

function Editor.updateOverlayArrows(selectedEntity)
	-- clear existing arrows
	Editor.overlayArrows = {}

	-- check if selectedEntity is valid
	if not selectedEntity or #selectedEntity.flowOut == 0 then return end
	if selectedEntity.type ~= 'spawner' then return end

	local arrows = {}

	for i, flowOutIndex in ipairs(selectedEntity.flowOut) do
		local foundArrow = false
		for j, arrow in ipairs (arrows) do
			if arrow.index == flowOutIndex then
				foundArrow = arrow
				break
			end
		end
		if foundArrow then
			-- if arrow found, increment its amount, otherwise create a new arrow
			foundArrow.amount = foundArrow.amount + 1
		else
			local arrow = {index = flowOutIndex, amount = 1}
			table.insert (arrows, arrow)
		end
	end


	-- loop through the entities that have outgoing connections
	for _, arrowData in ipairs(arrows) do
		local targetEntity = Editor.getEntityByIndex(arrowData.index)

		if targetEntity then
			-- get the target entity's position and the selectedEntity's position
			local tx1 = selectedEntity.tx + selectedEntity.tw/2
			local ty1 = selectedEntity.ty + selectedEntity.th/2
			local tx2 = targetEntity.tx + targetEntity.tw/2
			local ty2 = targetEntity.ty + targetEntity.th/2
			local line = {tx1, ty1, tx2, ty2}

			-- calculate the size of the arrow based on the flow amount
			local size = math.max(2, arrowData.amount * 2)  -- ensure a minimum size of 2

			-- use target entity color for the arrow
			local colorIndex = targetEntity.entityColorIndex
			local color = UtilsData.entityColorList[colorIndex] or {1, 1, 1}
			color = {color[1], color[2], color[3], 0.5}

			-- create the overlay arrow object
			local overlayArrow = {
				line = line,
				size = size,
				color = color
			}

			-- add the new arrow to the overlay list
			table.insert(Editor.overlayArrows, overlayArrow)
		end
	end
end


function Editor.onTileClicked(tx, ty, button)

	if Preselect.cursorEntity then
		Preselect.handleTileClick(tx, ty)
	else
		local selectedEntity = Editor.getHoveredEntity (tx, ty) 
		Preselect.selectedEntity = selectedEntity

		if selectedEntity then 
			Editor.updateOverlayArrows (selectedEntity) -- sourceEntity
		end
	end

end

function Editor.isTileInBounds (tx, ty)
	local gameTW = GameConfig.tileCountW -- total width in tiles
	local gameTH = GameConfig.tileCountH -- total height in tiles
	if tx < 0 or tx >= gameTW then
		return false
	end

	if ty < 0 or  ty >= gameTH then
		return false
	end

	return true
end


function Editor.changeFlow(sourceEntity, targetEntity, direction)
	-- get the outgoing and incoming flow lists for both entities
	if  sourceEntity == targetEntity then return end
	local flowOut = sourceEntity.flowOut
	local flowIn = targetEntity.flowIn

	if direction > 0 then
		-- add flow if not exceeding flowMax for both flowOut and flowIn
		if #flowOut < Editor.flowMax and #flowIn < Editor.flowMax then
			-- add the target entity index to the source's flowOut
			table.insert(flowOut, targetEntity.index)
			-- add the source entity index to the target's flowIn
			table.insert(flowIn, sourceEntity.index)
		end

	elseif direction < 0 then -- remove flow if direction is negative
		-- find and remove the target entity from the source's flowOut
		for i, flowID in ipairs(flowOut) do
			if flowID == targetEntity.index then
				table.remove(flowOut, i)
				break
			end
		end

		-- find and remove the source entity from the target's flowIn
		for i, flowID in ipairs(flowIn) do
			if flowID == sourceEntity.index then
				table.remove(flowIn, i)
				break
			end
		end
	end

	-- update arrows after changing the flow
	Editor.updateOverlayArrows(sourceEntity)
end

function Editor.wheelmoved(x, y)
	local tx, ty = Preselect.tx, Preselect.ty

	local selectedEntity = Preselect.selectedEntity
	local hoveredEntity = Editor.getHoveredEntity(tx, ty)

	if not selectedEntity or not hoveredEntity then return end
	if selectedEntity.type ~= 'spawner' or hoveredEntity.type ~= 'spawner' then return end

	Editor.changeFlow (selectedEntity, hoveredEntity, y)
end

function Editor.mousepressed(x, y, button)
	-- [tile size]
	local tileSize = GameConfig.tileSize -- 40

	-- [calculate tile-based cursor position]
	local tx = math.floor(x / tileSize)
	local ty = math.floor(y / tileSize)

	-- [ensure the coordinates are within valid range]
	local txMax, tyMax = GameConfig.tileCountW - 1, GameConfig.tileCountH - 1

	if Editor.isTileInBounds (tx, ty) then
		Editor.onTileClicked(tx, ty, button)
	else
		-- GUI if exists
	end
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
--		Preselect.tx = tx
--		Preselect.ty = ty
		if Editor.isTileInBounds (tx, ty) then
			Preselect.cursormoved(tx, ty, dtx, dty)
		end
	end
end


return Editor
