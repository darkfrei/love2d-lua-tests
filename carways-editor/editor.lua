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

-- [directional offsets for flow]
local directionOffsets = {
	[1] = {dx = -0.5, dy = 1},    -- down left
	[2] = {dx = 0, dy = 1},       -- down
	[3] = {dx = 0.5, dy = 1},     -- down right
	[4] = {dx = -1, dy = 0},      -- left
	[6] = {dx = 1, dy = 0},       -- right
	[7] = {dx = -0.5, dy = -1},   -- up left
	[8] = {dx = 0, dy = -1},      -- up
	[9] = {dx = 0.5, dy = -1},    -- up right
}

local function calculateFlow(direction, tx, ty, tw, th)
	local centerX, centerY = tx + tw / 2, ty + th / 2
	local offsets = directionOffsets[direction]

	local dx, dy = offsets.dx, offsets.dy
	local startX, startY = centerX + dx, centerY + dy
	local endX, endY = centerX + 2 * dx, centerY + 2 * dy

	return {startX, startY, endX, endY}
end

-- [updates spawner entity with the given parameters]
local function updateSpawnerEntity(entity)
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


--serpent = require ('serpent')

function Preselect:updatePreselectSpawnerZone()

	local entity = self.cursorEntity
	if entity and entity.type ~= 'spawner' then return end

	-- get preselect position and size
	local tx, ty = self.tx, self.ty -- preselect top left position
	local tw, th = self.size.tw, self.size.th  -- preselect size
--	print ('updatePreselectSpawnerZone', tx, ty, tw, th)


	if not entity then
		entity = self.newEntity ('spawner')
		print ('new entity!')
		self.cursorEntity = entity
	end

	local gameTW = Game.tw-1 -- 32
	local gameTH = Game.th-1 -- 20



	-- 
--	love.window.setTitle ('updatePreselectSpawnerZone '..tx..' '..ty)
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



--	print ('entity')
--	print (serpent.block (entity))
	updateSpawnerEntity (entity)
end




local function drawArrow(line)
	-- [extract the start and end points from the lines]
	if not line then return end

	local tileSize = 40

	local startX, startY = line[1]*tileSize, line[2]*tileSize
--	print (startX, startY)
	local endX, endY = line[3]*tileSize, line[4]*tileSize

	-- [draw the main line of the arrow]
	love.graphics.line(startX, startY, endX, endY)

	-- [calculate the direction vector for the arrow tip]
	local dx, dy = endX - startX, endY - startY
	local length = math.sqrt(dx^2 + dy^2)
	local unitX, unitY = dx / length, dy / length

	-- [determine arrow tip size and angles]
	local arrowSize = 10
	local perpX, perpY = -unitY, unitX -- perpendicular vector for the arrow wings
	local tip1X = endX - arrowSize * (unitX + perpX)
	local tip1Y = endY - arrowSize * (unitY + perpY)
	local tip2X = endX - arrowSize * (unitX - perpX)
	local tip2Y = endY - arrowSize * (unitY - perpY)

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
		love.graphics.setColor(1, 0, 0)  -- [red color for flow-out]
		love.graphics.line(
			flowOut.line[1]*tileSize, 
			flowOut.line[2]*tileSize, 
			flowOut.line[3]*tileSize, 
			flowOut.line[4]*tileSize
		)
		drawArrow(flowOut.line)
		local x = flowOut.line[1]*tileSize
		local y = flowOut.line[2]*tileSize
		local amount = #flowOut
		love.graphics.print (amount, x, y)
	end

	-- [draw the flow-in line]
	if flowIn and flowIn.line then
		love.graphics.setColor(0, 0, 1)  -- [blue color for flow-in]
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

--		self.entity = {
--			type = 'spawner',
--			tx = self.tx,
--			ty = self.ty,
--			tw = self.size.tw,
--			th = self.size.th,
--			flowOutDirection = Preselect.flowOutDirection,
--			flowInDirection = Preselect.flowInDirection,
--		}
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
	local file = io.open("level_save.dat", "r")
	if file then
		local str = file:read("*a")
		file:close()
		currentLevel = ssl.deserializeString(str)

		for i, entity in ipairs (currentLevel.entities) do
			if entity.type == 'spawner' then
				local tx = entity.tx
				local ty = entity.ty
				local tw = entity.tw
				local th = entity.th

--				print (serpent.block (entity))

				local flowOutDirection = entity.flowOutDirection
				local flowInDirection = entity.flowInDirection

--				updateSpawnerEntity(entity, tx, ty, tw, th, flowOutDirection, flowInDirection)
				updateSpawnerEntity(entity, tx, ty, tw, th, flowOutDirection, flowInDirection)
			end
		end
		print("Level loaded successfully")
	else
		print("No saved level found")
	end
end

function Editor.enter()
	-- [initializes editor state]
	print("Editor state entered")
	loadLevel()



--	Editor.preselect = {
--		tx=0, ty=0, 
--		tw=2, th=2,
--		entityType = 'spawner',
--		temp = nil,

--	}


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

	--[[
	for i, zone in ipairs (currentLevel.entities) do

--		love.graphics.setLineWidth (2)
		local tx, ty = zone.tx, zone.ty
		local tw, th = zone.tw, zone.th
		local selected = zone.selected
		if selected then
			love.graphics.setLineWidth (3)
		else
			love.graphics.setLineWidth (1)
		end


--		drawZone (zone)


		if selected then
			love.graphics.setColor (1,1,1)
			love.graphics.rectangle ('line', ts*tx, ts*ty, ts*tw, ts*th)
		end


		if zone.type == 'spawner' then
			love.graphics.setColor (0,0,0)
			love.graphics.setLineWidth (2)
			local flowOut = zone.flowOut
	if flowOut then
		drawArrow(flowOut.line)

--				love.graphics.print (flowOut.amount, flowOut.textPosition.x, flowOut.textPosition.y)
	end

	local flowIn = zone.flowIn
	if flowIn then
		drawArrow(flowIn.line)

		love.graphics.print (flowIn.amount, flowIn.textPosition.x, flowIn.textPosition.y)
	end

end

end
--]]

-- mouse
--	drawPreselect ()

	Preselect:draw()
end

function Editor.exit()
	-- [cleans up editor state]
	print("Editor state exited")
end


--[[
local function updateSpawnerZone (zone)
	if not (zone.type == 'spawner') then return end
	local ts = Game.tileSize
	local tx, ty = zone.tx, zone.ty
	local tw, th = zone.tw, zone.th
	local flowOut = zone.flowOut
	local flowIn = zone.flowIn


	if not flowOut then 
		flowOut = {
--			direction = 1, 
			amount=0,
			maxAmount = 20,
--			point = {},
			line = {},
			textPosition = {},
		}
		zone.flowOut = flowOut
	end
	if not flowIn then 
		flowIn = {
--			direction = 1, 
			amount=0,
			maxAmount = 20,
--			point = {},
			line = {},
			textPosition = {}, 
		}
		zone.flowIn = flowIn
	end

	flowOut.direction = (flowOut.direction -1)%4+1
	flowIn.direction = (flowIn.direction -1)%4+1

	if flowOut.direction == flowIn.direction then
		if flowOut.direction == 1 then -- top
			-- both top
			local x = ts*(tx+(tw)/2)
			local x1 = x-0.5*ts
			local x2 = x+0.5*ts
			if zone.left then
				x1, x2 = x2, x1
			end

			local y = ts*(ty+0.5)
			flowOut.line = {x1, y, x1, y-ts}
			flowOut.textPosition = {x=x1-5, y=y+5}

			-- in
			flowIn.line = {x2, y-ts, x2, y}
			flowIn.textPosition = {x=x2-5, y=y+5}


			----
		elseif flowOut.direction == 2 then -- right
			-- both right
			local y = ts * (ty + th / 2)
			local y1 = y - 0.5 * ts
			local y2 = y + 0.5 * ts
			if zone.left then
				y1, y2 = y2, y1
			end

			local x = ts * (tx + tw - 0.5)

			-- out
--			flowOut.point = {x = x, y = y1}
			flowOut.line = {x, y1, x + ts, y1}
			flowOut.textPosition = {x = x - 5, y = y1 + 5}

			-- in
--			flowIn.point = {x = x + ts, y = y2}
			flowIn.line = {x + ts, y2, x, y2}
			flowIn.textPosition = {x = x - 5, y = y2 + 5}

		elseif flowOut.direction == 3 then -- bottom
			-- both bottom
			local x = ts * (tx + tw / 2)
			local x1 = x + 0.5 * ts
			local x2 = x - 0.5 * ts
			if zone.left then
				x1, x2 = x2, x1
			end

			local y = ts * (ty + th - 0.5)

			-- out
--			flowOut.point = {x = x1, y = y}
			flowOut.line = {x1, y, x1, y + ts}
			flowOut.textPosition = {x = x1 - 5, y = y - 20}

			-- in
--			flowIn.point = {x = x2, y = y + ts}
			flowIn.line = {x2, y + ts, x2, y}

			flowIn.textPosition = {x = x2 - 5, y = y - 20}

		elseif flowOut.direction == 4 then -- left
			-- both left
			local y = ts * (ty + th / 2)
			local y1 = y - 0.5 * ts
			local y2 = y + 0.5 * ts
			if zone.left then
				y1, y2 = y2, y1
			end

			local x = ts * (tx + 0.5)

			-- out
--			flowOut.point = {x = x, y = y1}
			flowOut.line = {x, y1, x - ts, y1}
			flowOut.textPosition = {x = x - 5, y = y1 + 5}

			-- in
--			flowIn.point = {x = x - ts, y = y2}
			flowIn.line = {x - ts, y2, x, y2}
			flowIn.textPosition = {x = x - 5, y = y2 + 5}


		end
	else
		-- not same direction

		if flowOut.direction == 1 then
			local x = ts*(tx+tw/2)
			local y = ts*(ty+0.5)
--			flowOut.point = {x=x, y=y}
			flowOut.line = {x, y, x, y-ts}
			flowOut.textPosition = {x=x-5, y=y+5}
		elseif flowOut.direction == 2 then
			-- right
			local x = ts*(tx+tw-0.5)
			local y = ts*(ty+th/2)
--			flowOut.point = {x=x, y=y}
			flowOut.line = {x, y, x+ts, y}
			flowOut.textPosition = {x=x-5, y=y+5}
		elseif flowOut.direction == 3 then
			local x = ts*(tx+tw/2)
			local y = ts*(ty+th-0.5)
--			flowOut.point = {x=x, y=y}
			flowOut.line = {x, y, x, y+ts}
			flowOut.textPosition = {x=x-5, y=y-20}
		elseif flowOut.direction == 4 then
			-- left
			local x = ts*(tx+0.5)
			local y = ts*(ty+th/2)
--			flowOut.point = {x=x, y=y}
			flowOut.line = {x, y, x+tw-ts, y}
			flowOut.textPosition = {x=x-5, y=y+5}
		end

		if flowIn.direction == 1 then
			local x = ts*(tx+tw/2)
			local y = ts*(ty+0.5)
--			flowIn.point = {x=x, y=y-ts}
			flowIn.line = {x, y-ts, x, y}
			flowIn.textPosition = {x=x-5, y=y+5}

			---- errors:
		elseif flowIn.direction == 2 then
			local x = ts * (tx + tw - 0.5)
			local y = ts * (ty + th / 2)
--			flowIn.point = { x = x + ts, y = y }
			flowIn.line = { x + ts, y, x, y }
			flowIn.textPosition = {x=x-5, y=y+5}
		elseif flowIn.direction == 3 then
			local x = ts * (tx + tw / 2)
			local y = ts * (ty + th - 0.5)
--			flowIn.point = { x = x, y = y + ts }
			flowIn.line = { x, y + ts, x, y }
			flowIn.textPosition = { x = x - 5, y = y - 20 }
		elseif flowIn.direction == 4 then -- 
			local x = ts * (tx + 0.5)
			local y = ts * (ty + th / 2)
--			flowIn.point = { x = x - ts, y = y }
			flowIn.line = { x - ts, y, x, y }
			flowIn.textPosition = { x = x - 5, y = y + 5 }
		end

	end

end
--]]


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
--		table.insert (currentLevel.spawners, spawnZone)
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
	-- [loop through all entities and remove references to the deleted entity's ID in their flows]
	for _, otherEntity in ipairs(currentLevel.entities) do
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
	local zone = Editor.selectedZone
	if zone then
		zone.selected = nil
		Editor.selectedZone = nil
	end
	local str = ssl.serializeTable(currentLevel)
	local file = io.open("level_save.dat", "w")
	if file then
		file:write(str)
		file:close()
		print("saved")
	else
		print("not saved")
	end
end

local function setZoneAsWall (zone)
	if not (zone.type == 'wall') then
		print ('now zone is wall')
		zone.type = 'wall'
	end
end

local function setZoneAsSpawner (zone)
	if not (zone.type == 'spawner') then
		print ('now zone is spawner')
		zone.type = 'spawner'

	end
end



function Editor.keypressed(key, scancode)
	local isCtrl = love.keyboard.isDown ('lctrl')

	if key == 'w' then
		Preselect:setWall()
		return
	elseif key == 'z' then
		Preselect:setSpawner()
		return
	end

	-- [adjusts size based on keypad + or -]
	if key == "kp+" then
		Preselect:increseSize(1, 1) -- increase size
		return
	elseif key == "kp-" then
		Preselect:increseSize(-1, -1) -- decrease size
		return
	end

	if isCtrl then
		if key == "s" then
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
--[[
	print ('keypressed', key, scancode)
	local mousePressed = love.mouse.isDown (1)
	print ('mousePressed', tostring (mousePressed))
	local isShift = love.keyboard.isDown ('lshift')
	local isCtrl = love.keyboard.isDown ('lctrl')
	print (tostring (isShift), key, scancode)
	print (tostring (isCtrl), key, scancode)


	local zone = Editor.selectedZone
	if zone then
		print ()
		if key == "w" then
			setZoneAsWall (zone)
			return
		elseif key == "z" then
			setZoneAsSpawner (zone)
			updateSpawnerZone (zone)
			return
		end
	end

	if isCtrl then
		-- ctrl
		if key == "s" then
			saveLevel ()
		end

		-- end ctrl
	elseif isShift then
		-- shift


		-- end shift
	elseif key == "w" then
--		createWallZone ()
		Editor.preselect.entityType = 'wall'
		createEntity (false) -- not spawner
	elseif key == "z" then
--		createSpawnZone ()
		Editor.preselect.entityType = 'spawner'
		createEntity (true) -- spawner
	elseif key == "delete" then
		deleteSelectedZone ()
	elseif key == "b" then
		swapZone () -- left side or right side
	elseif key == "i" then
		changeInputPosition ()
	elseif key == "o" then
		changeOutputPosition ()
	elseif key == "s" then -- '<'
		nextZoneArt ()
	elseif key == "a" then -- '>'
		prevZoneArt ()
	elseif key == "c" then -- change color
		nextZoneColor ()
	elseif key == "kp+" then
		Editor.preselect.tw = Editor.preselect.tw + 1
		Editor.preselect.th = Editor.preselect.th + 1
	elseif key == "kp-" then
		Editor.preselect.tw = math.max(Editor.preselect.tw - 1, 1)
		Editor.preselect.th = math.max(Editor.preselect.th - 1, 1)

	end	

end
--]]

-- utils.lua






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
		return
	end


	-- [update the current tile and handle click]
--	Preselect.currentTile = {tx = tx, ty = ty}
	Preselect:tileClicked(tx, ty)
end


-- [handles mouse press events]

--	local preselect = Editor.preselect
--	print ('preselect exists:'.. tostring(preselect))
--	local tx, ty = preselect.tx, preselect.ty

--	preselect.pressed = {tx=tx, ty=ty}


--[[

	local shiftPressed = love.keyboard.isDown('lshift', 'rshift')
	print ('shiftPressed', tostring (shiftPressed))
	if shiftPressed then
		-- do nothing until moved
	else
		local wasSelected = Editor.selectedZone
		if Editor.selectedZone then
			Editor.selectedZone.selected = nil
			Editor.selectedZone = nil
		else
			wasSelected = false
		end

		local zone
		if not currentLevel.entities then currentLevel.entities = {} end
		for i, iZone in ipairs (currentLevel.entities) do
			if mouseLevelCursorInsideZone (iZone) then
				iZone.selected = true
				zone = iZone
				break
			else
--				iZone.selected = nil
			end
		end

		if zone then
			Editor.selectedZone = zone
		else
			if wasSelected then
				Editor.selectedZone = nil
			else
				-- on click create entitly
				print ('preselect.type: '..preselect.entityType)
				local isSpawner = (preselect.entityType == 'spawner')
				print ('on click, create entity, spawner: ' .. tostring (isSpawner))
				createEntity (isSpawner)
			end
		end
	end
	--]]
--end

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


--[[
	-- [handles mouse movement events]

	
	local preselect = Editor.preselect
	local tx, ty = preselect.tx, preselect.ty
	local tw, th = preselect.tw, preselect.th
	if preselect.tx == mtx and preselect.ty == mty then
		return
	elseif preselect.tx == mtx then
		preselect.ty = mty
	elseif preselect.ty == mty then
		preselect.tx = mtx
	else
		preselect.tx = mtx
		preselect.ty = mty
	end


	local mousePressed = preselect.pressed
	local isShiftDown = love.keyboard.isDown ('lshift', 'rshift')
	local zone = Editor.selectedZone
	local zoneHovered = zone and mouseLevelCursorInsideZone (zone, dtx, dty)
--	love.window.setTitle (tostring (zoneHovered))

	if zone and mousePressed then
		local dtx = mtx - mousePressed.tx
		local dty = mty - mousePressed.ty
--		love.window.setTitle (dtx..' '..dty)
		if isShiftDown then -- resize
--			
	local tw = math.max (1, zone.tw+dtx)
	local th = math.max (1, zone.th+dty)
	zone.tw = tw
	zone.th = th
	mousePressed.tx = mtx
	mousePressed.ty = mty
	updateSpawnerZone (zone) -- wip: must be checked if changed
else -- drag and drop
	zone.tx = zone.tx + dtx
	zone.ty = zone.ty + dty

	mousePressed.tx = mtx
	mousePressed.ty = mty
	updateSpawnerZone (zone) -- wip: must be checked if changed
end
return
else
local left = (mtx == 0)
local top = (mty == 0) 
local right = (mtx == 31) or (mtx + tw > 31)
local bottom = (mty == 19) or (mty + th > 19)

if top and (mtx + 1 >= 31) then right = true end
if right and (mty + 1 >= 19) then bottom = true end


if top then
	if left then
		preselect.type = 'topleft'
		preselect.temp = {tx=0, ty=0, tw=1, th=1}
	elseif right then 
		preselect.type = 'topright'
--				preselect.temp = {tw=1, th=1}
		preselect.temp = {tx=31, ty=0, tw=1, th=1}
	else 
		preselect.type = 'top'
		preselect.temp = {tw=math.max(2, tw), th=1}
	end
elseif bottom then
	if left then 
		preselect.type = 'bottomleft'
		preselect.temp = {tw=1, th=1}
	elseif right then 
		preselect.type = 'bottomright'
		preselect.temp = {tx=31, ty=19, tw=1, th=1}
	else 
		preselect.type = 'bottom'
		preselect.temp = {ty=19, tw=math.max(2, tw), th=1}
	end
elseif left then
	preselect.type = 'left'
	preselect.temp = {tw=1, th=math.max(2, th)}
elseif right then
	preselect.type = 'right'
	preselect.temp = {tx=31, tw=1, th=math.max(2, th)}
else

	preselect.type = 'common'
	preselect.temp = nil
end
love.window.setTitle ('preselect.type: '..preselect.type)
end


--	print(string.format("Mouse moved to (%d, %d) with delta (%d, %d)", x, y, dx, dy))

--]]
--end

local function getMouseSpawnerZone ()
	local tx, ty = Preselect.tx, Preselect.ty
	for i, zone in ipairs (currentLevel.spawners) do
		if tx >= zone.tx and ty >=zone.ty
		and tx < zone.tx+zone.tw and ty < zone.ty+zone.th then
			return zone
		end
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
