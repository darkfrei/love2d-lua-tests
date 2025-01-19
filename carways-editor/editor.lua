-- editor.lua
-- [editor state implementation]

local ssl = require ('SafeSaveLoad')

local Editor = {}
--local Preselect = require ('editor-preselect')

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

--spawnerDirections: 1, 2, 3, 4, 6, 7, 8, 9 as NumPad:
Preselect.flowOutDirection = 8 -- [default size for spawner type preselect]
Preselect.flowInDirection = 2 -- [default size for spawner type preselect]
Preselect.selectedEntity = nil -- current entity in preselect

Editor.flowMax = 20


-- [updates spawner entity with the given parameters]
local function updateSpawnerEntity(entity)
--	print ('updateSpawnerEntity')
	-- [update entity's position and size]
	local tx, ty, tw, th = entity.tx, entity.ty, entity.tw, entity.th

	local flowOutDirection = entity.flowOutDirection
	local flowInDirection = entity.flowInDirection


	-- [calculate the center position for output and input]
	local outputTX = (tx + tw / 2)  -- keep in tiles, not pixels
	local outputTY = (ty + th / 2)

	local inputTX = (tx + tw / 2)
	local inputTY = (ty + th / 2)

	-- [initialize direction deltas]

	local outputDTX = 0
	local outputDTY = 0
	local inputDTX = 0
	local inputDTY = 0

	-- [determine the output position based on flowOutDirection]
	if flowOutDirection == 7 or flowOutDirection == 4 or flowOutDirection == 1 then
		-- [left side of entity]
		outputTX = tx + 0.5
		outputDTX = -1
	elseif flowOutDirection == 9 or flowOutDirection == 6 or flowOutDirection == 3 then
		-- [right side of entity]
		outputTX = tx + tw - 0.5
		outputDTX = 1
	end

	-- [determine the output position based on flowOutDirection]
	if flowOutDirection == 7 or flowOutDirection == 8 or flowOutDirection == 9 then
		-- [top side of entity]
		outputTY = ty + 0.5
		outputDTY = -1
	elseif flowOutDirection == 1 or flowOutDirection == 2 or flowOutDirection == 3 then
		-- [bottom side of entity]
		outputTY = ty + th - 0.5
		outputDTY = 1
	end

	-- [determine the input position based on flowInDirection]
	if flowInDirection == 7 or flowInDirection == 4 or flowInDirection == 1 then
		-- [left side]
		inputTX = tx + 0.5
		inputDTX = -1
	elseif flowInDirection == 9 or flowInDirection == 6 or flowInDirection == 3 then
		-- [right side]
		inputTX = tx + tw - 0.5
		inputDTX = 1
	end

	-- [determine the input position based on flowInDirection]
	if flowInDirection == 7 or flowInDirection == 8 or flowInDirection == 9 then
		-- [top side of entity]
		inputTY = ty + 0.5
		inputDTY = -1
	elseif flowInDirection == 1 or flowInDirection == 2 or flowInDirection == 3 then
		-- [bottom side of entity]
		inputTY = ty + th - 0.5
		inputDTY = 1
	end

	-- 
	if not (flowOutDirection == flowInDirection) then
		entity.flowOut.line = {outputTX, outputTY, outputTX+outputDTX, outputTY+outputDTY}
		entity.flowIn.line = {inputTX + inputDTX, inputTY+inputDTY, inputTX, inputTY}
	else
		local dx = 0.5
		local dy = 0.5
		if flowOutDirection == 1 then
			-- down left
			entity.flowOut.line = {outputTX+dx, outputTY+dy, 
				outputTX+outputDTX+dx, outputTY+outputDTY+dy}
			entity.flowIn.line = {inputTX-dx + inputDTX, inputTY+inputDTY-dy, 
				inputTX-dx, inputTY-dy}
		elseif flowOutDirection == 2 then
			-- down
			dy = 0
			entity.flowOut.line = {outputTX+dx, outputTY+dy, 
				outputTX+outputDTX+dx, outputTY+outputDTY+dy}
			entity.flowIn.line = {inputTX-dx + inputDTX, inputTY+inputDTY+dy, 
				inputTX-dx, inputTY+dy}
		elseif flowOutDirection == 3 then
--			down right
			dy = -dy
			entity.flowOut.line = {outputTX+dx, outputTY+dy, 
				outputTX+outputDTX+dx, outputTY+outputDTY+dy}
			entity.flowIn.line = {inputTX-dx + inputDTX, inputTY+inputDTY-dy, 
				inputTX-dx, inputTY-dy}

		elseif flowOutDirection == 4 then
			-- left
			dx = 0
			entity.flowOut.line = {outputTX+dx, outputTY+dy, 
				outputTX+outputDTX+dx, outputTY+outputDTY+dy}
			dy = -dy
			entity.flowIn.line = {inputTX+dx + inputDTX, inputTY+inputDTY+dy, 
				inputTX+dx, inputTY+dy}

		elseif flowOutDirection == 6 then
			-- right
			dx = 0
			entity.flowIn.line = {inputTX+dx + inputDTX, inputTY+inputDTY+dy, 
				inputTX+dx, inputTY+dy}
			dy = -dy
			entity.flowOut.line = {outputTX+dx, outputTY+dy, 
				outputTX+outputDTX+dx, outputTY+outputDTY+dy}

		elseif flowOutDirection == 7 then
			-- up left
			dx = -dx
			entity.flowOut.line = {outputTX+dx, outputTY+dy, 
				outputTX+outputDTX+dx, outputTY+outputDTY+dy}
			dx = -dx
			dy = -dy
			entity.flowIn.line = {inputTX+dx + inputDTX, inputTY+inputDTY+dy, 
				inputTX+dx, inputTY+dy}
		elseif flowOutDirection == 8 then
			-- up left
			dy = 0
			dx = -dx
			entity.flowOut.line = {outputTX+dx, outputTY+dy, 
				outputTX+outputDTX+dx, outputTY+outputDTY+dy}
			dx = -dx

			entity.flowIn.line = {inputTX+dx + inputDTX, inputTY+inputDTY+dy, 
				inputTX+dx, inputTY+dy}
		elseif flowOutDirection == 9 then
			-- up right
			entity.flowIn.line = {inputTX+dx + inputDTX, inputTY+inputDTY+dy, 
				inputTX+dx, inputTY+dy}
			dx = -dx
			dy = -dy
			entity.flowOut.line = {outputTX+dx, outputTY+dy, 
				outputTX+outputDTX+dx, outputTY+outputDTY+dy}
		end
	end

end


function Preselect:updatePreselectSpawnerZone()
--	print ('updatePreselectSpawnerZone')
	local entity = self.cursorEntity
	if entity and entity.type ~= 'spawner' then return end

	-- get preselect position and size
	local tx, ty = self.tx, self.ty -- preselect top left position
	local tw, th = self.size.tw, self.size.th  -- preselect size

	if not entity then
		entity = self.newEntity ('spawner')
		print ('new entity!')
		self.cursorEntity = entity
	end

	local gameTW = Game.tw-1 -- 32
	local gameTH = Game.th-1 -- 20

	if tx == 0 and ty == 0 then
		-- down-right
		entity.tx = 0
		entity.ty = 0
		entity.tw = 1
		entity.th = 1
		entity.flowOutDirection = 3 
		entity.flowInDirection = 3   -- down-right
		love.window.setTitle ('top left')
	elseif tx+tw > gameTW and ty == 0 then
		-- down-left
		entity.tx = gameTW
		entity.ty = 0
		entity.tw = 1
		entity.th = 1
		entity.flowOutDirection = 1
		entity.flowInDirection = 1   
	elseif ty == 0 then
		-- down
		entity.tx = tx
		entity.ty = 0
		entity.tw = 2
		entity.th = 1
		entity.flowOutDirection = 2 
		entity.flowInDirection = 2
	elseif tx == 0 and ty+th > gameTH then
		-- top right
		entity.tx = 0
		entity.ty = gameTH
		entity.tw = 1
		entity.th = 1
		entity.flowOutDirection = 9
		entity.flowInDirection = 9 
	elseif tx == 0 then
		-- right
		entity.tx = 0
		entity.ty = ty
		entity.tw = 1
		entity.th = 2
		entity.flowOutDirection = 6
		entity.flowInDirection = 6
	elseif tx+tw > gameTW and ty+th > gameTH then
		-- up left
		entity.tx = gameTW
		entity.ty = gameTH
		entity.tw = 1
		entity.th = 1
		entity.flowOutDirection = 7
		entity.flowInDirection = 7
	elseif tx+tw > gameTW then
		-- left
		entity.tx = gameTW
		entity.ty = ty
		entity.tw = 1
		entity.th = 2
		entity.flowOutDirection = 4
		entity.flowInDirection = 4
	elseif ty+th > gameTH then
		-- right
		entity.tx = tx
		entity.ty = gameTH
		entity.tw = 2
		entity.th = 1
		entity.flowOutDirection = 8
		entity.flowInDirection = 8
	else
		-- middle
		entity.tx = self.tx
		entity.ty = self.ty
		entity.tw = self.size.tw
		entity.th = self.size.th
		entity.flowOutDirection = self.flowOutDirection
		entity.flowInDirection = self.flowInDirection
	end

	updateSpawnerEntity (entity)
end

local function drawArrow(line)
	-- [extract the start and end points from the lines]
	if not line then return end

	-- [define the tile size for scaling]
	local tileSize = Game.tileSize

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
		if entity.ID then
			love.graphics.print (entity.ID, x, y)
		end
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

	if entity.ID then
		love.graphics.print (entity.ID, x, y)
	end

end


-- [renders the preselect area]
function Preselect:draw()
	if not self.tx or not self.ty 
	or not self.size.tw or not self.size.th then
		return -- nothing to draw if the necessary parameters are not set
	end

	local tileSize = 40
	local x = self.tx * tileSize
	local y = self.ty * tileSize
	local width = self.size.tw * tileSize
	local height = self.size.th * tileSize

	local entity = self.cursorEntity

	-- set color based on the type of preselect

	if entity then
		love.graphics.setLineWidth (3)
		drawEntity (entity)
		love.graphics.setColor(1, 1, 1, 1) -- white
		love.graphics.rectangle("line", x, y, width, height)
		love.graphics.print (entity.ID, x, y)
	else
		love.graphics.setLineWidth (1)
		love.graphics.setColor(1, 1, 1, 0.3) -- white with 30% transparency
		love.graphics.rectangle("fill", x, y, width, height)
		love.graphics.setColor(1, 1, 1, 1) -- white
		love.graphics.rectangle("line", x, y, width, height)	
	end
end

-- [sets the preselect type to 'wall', or unsets it if already set]
function Preselect:setWall()
	local entity = self.cursorEntity
	if entity and entity.type == 'wall' then
		self.cursorEntity = nil
		self.size = Preselect.nothingSize
	else
		self.size = self.wallSize
		self.cursorEntity = self:newEntity ('wall')
--		self.cursorEntity = {
--			type = 'wall',
--			tx = self.tx,
--			ty = self.ty,
--			tw = self.size.tw,
--			th = self.size.th,
--		}
	end
end

-- [sets the preselect type to 'spawner', or unsets it if already set]
function Preselect:setSpawner()
	local entity = self.cursorEntity

	if entity and entity.type == 'spawner' then
		-- [unset the preselect type if it is already 'spawner']
		self.cursorEntity = nil
		self.size = Preselect.nothingSize
	else
		-- [set the preselect type to 'spawner' and initialize properties]
		self.size = self.spawnerSize
		self.cursorEntity = self:newEntity ('spawner')
		Preselect:updatePreselectSpawnerZone()

	end
end


-- [increases or decreases the size of the preselect area]
function Preselect:increseSize(dw, dh)
	-- increase/decrease width, ensure it doesn't go below 1
	self.size.tw = math.max(1, self.size.tw + dw)
	-- increase/decrease height, ensure it doesn't go below 1
	self.size.th = math.max(1, self.size.th + dh)
	local entity = self.cursorEntity
	if entity then
		entity.tw = self.size.tw
		entity.th = self.size.th
	end
end

-- [creates a new entity based on the specified type]
function Preselect:newEntity(entityType)
	-- [initialize base entity properties]
	local entity = {
		tx = self.tx,              -- [top-left x position in tiles]
		ty = self.ty,              -- [top-left y position in tiles]
		tw = self.size.tw,         -- [width in tiles]
		th = self.size.th,         -- [height in tiles]
		type = entityType          -- [type of the entity, e.g., 'spawner']
	}

	-- [add type-specific properties]
	if entityType == 'spawner' then
		entity.flowOut = {}        -- [output flow configuration]
		entity.flowIn = {}         -- [input flow configuration]
		entity.flowOutDirection =  Preselect.flowOutDirection
		entity.flowInDirection =  Preselect.flowInDirection
--		entity.flowOut.direction = Preselect.flowOutDirection
--		entity.flowIn.direction = Preselect.flowInDirection
	end

	-- [return the newly created entity]
--	print ('new entity, type: '..entityType)
	currentLevel.entityID = currentLevel.entityID or 0
	currentLevel.entityID = currentLevel.entityID + 1
	entity.ID = currentLevel.entityID

	return entity
end

local function getHoveredEntity (tx, ty)
	for entityIndex, entity in ipairs(currentLevel.entities) do
		if tx >= entity.tx and ty >= entity.ty
		and tx < entity.tx + entity.tw and ty < entity.ty + entity.th then
			return entity
		end
	end
end

-- [handles tile click and updates preselect state]
function Preselect:tileClicked(tx, ty)
	-- [update preselect position]
	self.tx = tx
	self.ty = ty

--	print ('tileClicked', tx, ty, self.size.tw, self.size.th)

	-- [check for special cases or constraints]
	local gameTW = Game.tw -- total width in tiles
	local gameTH = Game.th -- total height in tiles

	-- [ensure preselect stays within bounds]
	if tx + self.size.tw > gameTW then
		self.tx = gameTW - self.size.tw
	end

	if ty + self.size.th > gameTH then
		self.ty = gameTH - self.size.th
	end

	-- [update entity linked to preselect, if any]
	local entity = self.cursorEntity

	if entity then
		local entityType = entity.type
		table.insert (currentLevel.entities, entity)
		self.selectedEntity = entity
		self.cursorEntity = self:newEntity (entityType)
		return
	elseif Preselect.selectedEntity then
		Preselect.selectedEntity = nil
	end
	local hoveredEntity = getHoveredEntity (tx, ty) 
	if hoveredEntity then
		Preselect.selectedEntity = hoveredEntity
	end

end


-- [updates preselect position and dimensions based on cursor movement]
function Preselect:cursormoved(tx, ty, dtx, dty)
	self.tx = tx
	self.ty = ty

	love.window.setTitle (tx..' '..ty)

	local entity = Preselect.cursorEntity
	if entity then
		entity.tx = tx
		entity.ty = ty
		if entity.type == 'spawner' then
			Preselect:updatePreselectSpawnerZone()
		else

		end
	end
end

-- end of Preselect
--serpent = require ('serpent')

local function loadLevel()
	local currentLevelIndex = WorldManager.progress.currentLevelIndex
	local filename = 'level-'..currentLevelIndex..'.dat'
	print ('loading level:', filename)
	local file = io.open(filename, 'r')
	if file then
		local str = file:read("*a")
		file:close()
		currentLevel = ssl.deserializeString(str)
		print ('currentLevel', currentLevel)
		if not currentLevel.entities then
			print ('####### no entities!')
			currentLevel.entities = {}
		else
			print ('####### amount entities:', #currentLevel.entities)
		end
		print("Level loaded successfully", currentLevel)
	else
		print("No saved level found")
	end
end

function Editor.enter()
	-- [initializes editor state]
	print("Editor state entered")
	loadLevel()

end

function Editor.update(dt)
	-- [updates editor logic]
end

local function getBackground ()
--	local w = 1280
--	local h = 800
	local ts = Game.tileSize -- 40
	local tw = Game.tw -- 30
	local th = Game.th -- 20

	local w = tw*ts
	local h = th*ts

	local backgroundCanvas = love.graphics.newCanvas (w, h)
	love.graphics.setCanvas (backgroundCanvas)

	love.graphics.setBackgroundColor(love.math.colorFromBytes( 130, 210, 255 ))

	love.graphics.setColor (love.math.colorFromBytes( 150, 220, 255 ))
	love.graphics.setLineStyle ('rough')
	love.graphics.setLineWidth (2)

--	for i = 0, 1280/40 do
--		local x = i * 40
--		love.graphics.line (x, 0, x, 800)
--	end
--	for j = 0, 800/40 do
--		local y = j * 40
--		love.graphics.line (0, y, 1280, y)
--	end

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

local backgroundImage = getBackground ()

Editor.mouseCursor = {tx=0, ty=0, tw=1, th=1} -- tiles

-- [renders a single wallZone object]
local function drawEntityTexture (entity)
	local ts = Game.tileSize -- 40
	local tx, ty = entity.tx, entity.ty
	local tw, th = entity.tw, entity.th

	local x, y = tx*ts, ty*ts


	local texture = Data.zoneArtList[entity.zoneArt]
	local color = Data.zoneColorList[entity.zoneColor]

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
	local ts = Game.tileSize

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

function Editor.draw()
	local ts = Game.tileSize
	-- background
	love.graphics.setColor (1,1,1)
	love.graphics.draw (backgroundImage)

	local selectedEntity = Preselect.selectedEntity
	for i, entity in ipairs (currentLevel.entities) do
		love.graphics.setLineWidth (1)
		if selectedEntity and selectedEntity == entity then
			love.graphics.setLineWidth (3)
		end
		drawEntity (entity)
		drawEntityTexture (entity)
	end

	Preselect:draw()

	-- draw arrows from selected entity

end

function Editor.exit()
	-- [cleans up editor state]
	print("Editor state exited")
end



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

--wip--
--wip--
--wip--
-- [deletes all flows related to the selected entity]
local function deleteSelectedZoneFlow(entity)
	if entity.type ~= 'spawner' then return end
	-- [loop through all entities and remove references to the deleted entity's ID in their flows]
	for _, otherEntity in ipairs(currentLevel.entities) do
		if otherEntity.type == 'spawner' then
			if otherEntity ~= entity then
				-- [remove outgoing flows to the deleted entity from other entities]
				for i = #otherEntity.flowOut, 1, -1 do
					if otherEntity.flowOut[i] == entity.ID then
						table.remove(otherEntity.flowOut, i)
					end
				end

				-- [remove incoming flows from the deleted entity to other entities]
				for i = #otherEntity.flowIn, 1, -1 do
					if otherEntity.flowIn[i] == entity.ID then
						table.remove(otherEntity.flowIn, i)
					end
				end
			end
		end
	end
end






-- [deletes the selected entity and its associated flows]
local function deleteSelectedZone()
	local selectedEntity = Preselect.selectedEntity
	local entities = currentLevel.entities

	if selectedEntity then
		-- [remove the selected entity from the list of entities]
		for i, entity in ipairs(entities) do
			if entity == selectedEntity then
				-- [delete the flows between the selected entity and others]
				deleteSelectedZoneFlow(selectedEntity)
				table.remove(entities, i)
				break
			end
		end
	end
end


local function swapZone ()
	local zone = Editor.selectedZone
	if zone and zone.type == 'spawner' then
		zone.left = not zone.left
		updateSpawnerZone (zone)
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
		updateSpawnerEntity (cursorEntity)

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
		updateSpawnerEntity (activeEntity)
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
		updateSpawnerEntity (cursorEntity)
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
		updateSpawnerEntity (activeEntity)
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
	if not zone then return end
	local zoneColor = zone.zoneColor
	zone.zoneColor = (zoneColor + 0) % #Data.zoneColorList + 1
end

local function saveLevel ()
	local index = currentLevel.index
	local str = ssl.serializeTable(currentLevel)
	local filename = 'level-'..index..'.dat'
	print ('save filename:', filename)
	local file = io.open(filename, 'w')
	if file then
		file:write(str)
		file:close()
		print("saved")
	else
		print("not saved")
	end
end



function Editor.keypressed(key, scancode)
	local isCtrl = love.keyboard.isDown ('lctrl', 'rctrl')
	local isShift = love.keyboard.isDown ('lshift', 'rshift')

	if key == 'w' then
		Preselect:setWall()
		return
	elseif key == 'z' then
		Preselect:setSpawner()
		return
	end

	-- [adjusts size based on keypad + or -]
	if key == "kp+" then
		if isCtrl then
			Preselect:increseSize(1, 0) -- increase size
		elseif isShift then
			Preselect:increseSize(0, 1) -- increase size
		else
			Preselect:increseSize(1, 1) -- increase size
		end
		return
	elseif key == "kp-" then
		if isCtrl then
			Preselect:increseSize(-1, 0) -- increase size
		elseif isShift then
			Preselect:increseSize(0, -1) -- increase size
		else
			Preselect:increseSize(-1, -1) -- increase size
		end
		return
	end


	if key == "s" then
		if isCtrl then
			saveLevel ()
			return
		end
	end


	if key == "i" then
		changeInputPosition ()
	elseif key == "o" then
		changeOutputPosition ()
	end

	if key == "delete" then
		deleteSelectedZone ()
	end
end

function Editor.mousepressed(x, y, button)
	-- [tile size]
	local tileSize = Game.tileSize -- 40

	-- [calculate tile-based cursor position]
	local tx = math.floor(x / tileSize)
	local ty = math.floor(y / tileSize)

	-- [ensure the coordinates are within valid range]
	local txMax, tyMax = Game.tw - 1, Game.th - 1

	-- [ignore clicks outside the valid range]
	if tx < 0 or ty < 0 or tx > txMax or ty > tyMax then
		-- GUI if exists
		return
	end

	Preselect:tileClicked(tx, ty)
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
		Preselect:cursormoved(tx, ty, dtx, dty)
	end
end


function Editor.wheelmoved(x, y)
	local tx, ty = Preselect.tx, Preselect.ty

	local selectedEntity = Preselect.selectedEntity
	local hoveredEntity = getHoveredEntity(tx, ty)

	if not selectedEntity or not hoveredEntity then return end
	if selectedEntity.type ~= 'spawner' or hoveredEntity.type ~= 'spawner' then return end

	local flowOut = selectedEntity.flowOut
	local flowIn = hoveredEntity.flowIn

	if y > 0 then
		-- add flow if not exceeding flowMax for both flowOut and flowIn
		if #flowOut < Editor.flowMax and #flowIn < Editor.flowMax then
			table.insert(flowOut, hoveredEntity.ID)
			table.insert(flowIn, selectedEntity.ID)
		end
	elseif y < 0 then
		-- remove flow
		for i, flowID in ipairs(flowOut) do
			if flowID == hoveredEntity.ID then
				table.remove(flowOut, i)
				break
			end
		end

		for i, flowID in ipairs(flowIn) do
			if flowID == selectedEntity.ID then
				table.remove(flowIn, i)
				break
			end
		end
	end
end


return Editor
