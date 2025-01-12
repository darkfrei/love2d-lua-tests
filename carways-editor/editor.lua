-- editor.lua
-- [editor state implementation]

local ssl = require ('SafeSaveLoad')

local Editor = {}

local function loadLevel()
	local file = io.open("level_save.dat", "r")
	if file then
		local str = file:read("*a")
		file:close()
		currentLevel = ssl.deserializeString(str)
		print("Level loaded successfully")
	else
		print("No saved level found")
	end
end

function Editor.enter()
	-- [initializes editor state]
	print("Editor state entered")
	loadLevel()

	Editor.preselect = {
		tx=0, ty=0, 
		tw=2, th=2,
		entityType = 'spawner',
		temp = nil,
		
	}
	

end

function Editor.update(dt)
	-- [updates editor logic]
end

local function getBackground ()
	local w = 1280
	local h = 800
	local backgroundCanvas = love.graphics.newCanvas (w, h)
	love.graphics.setCanvas (backgroundCanvas)

--	love.graphics.setBackgroundColor(love.math.colorFromBytes( 10, 17, 40 ))
--	love.graphics.setBackgroundColor(love.math.colorFromBytes( 90, 200, 250 ))
	love.graphics.setBackgroundColor(love.math.colorFromBytes( 130, 210, 255 ))

--	love.graphics.setColor (love.math.colorFromBytes( 90, 200, 250 ))
--	love.graphics.setColor (love.math.colorFromBytes( 130, 210, 255 ))
	love.graphics.setColor (love.math.colorFromBytes( 150, 220, 255 ))
	love.graphics.setLineStyle ('rough')
	love.graphics.setLineWidth (2)
	for i = 0, 1280/40 do
		local x = i * 40
		love.graphics.line (x, 0, x, 800)
	end
	for j = 0, 800/40 do
		local y = j * 40
		love.graphics.line (0, y, 1280, y)
	end
	love.graphics.setCanvas ()
	return backgroundCanvas
end

local backgroundImage = getBackground ()

Editor.mouseCursor = {tx=0, ty=0, tw=1, th=1} -- tiles

-- [renders a single wallZone object]
local function drawZone (zone)
	local ts = Game.tileSize -- 40
	local tx, ty = zone.tx, zone.ty
	local tw, th = zone.tw, zone.th

	local x, y = tx*ts, ty*ts




	local texture = Data.zoneArtList[zone.zoneArt]
	local color = Data.zoneColorList[zone.zoneColor]

	-- [sets color for the wall]
	if color then
		love.graphics.setColor(color)
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

local function drawArrow(flow)
	-- [extract the start and end points from the lines]
	local startX, startY = flow.line[1], flow.line[2]
	local endX, endY = flow.line[3], flow.line[4]

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


		drawZone (zone)

		if selected then
			love.graphics.setColor (1,1,1)
			love.graphics.rectangle ('line', ts*tx, ts*ty, ts*tw, ts*th)
		end

		if zone.type == 'spawner' then
			love.graphics.setColor (0,0,0)
			love.graphics.setLineWidth (2)
			local flowOut = zone.flowOut
			if flowOut then
				drawArrow(flowOut)

				love.graphics.print (flowOut.amount, flowOut.textPosition.x, flowOut.textPosition.y)
			end

			local flowIn = zone.flowIn
			if flowIn then
				drawArrow(flowIn)

				love.graphics.print (flowIn.amount, flowIn.textPosition.x, flowIn.textPosition.y)
			end

		end
	end

	-- mouse
	drawPreselect ()

end

function Editor.exit()
	-- [cleans up editor state]
	print("Editor state exited")
end

--[[
local function createWallZone ()
	local tx, ty = Game.mouseLevelCursor.tx, Game.mouseLevelCursor.ty

	if Editor.selectedZone then
		Editor.selectedZone.selected = nil
		Editor.selectedZone = nil
	end

	local wallZone = {
		tx = tx,
		ty = ty,
		tw = 1,
		th = 1,
		zoneArt = 1, -- number of texture in textureList table (data.lua)
		zoneColor = 1, -- number of color in colorList table (data.lua)
		letter='W',
		type = 'wall',
	}
	Editor.selectedZone = wallZone
	wallZone.selected = true
	table.insert (currentLevel.walls, wallZone)
end
--]]

local function updateSpawnerZone (zone)
	if not (zone.type == 'spawner') then return end
	local ts = Game.tileSize
	local tx, ty = zone.tx, zone.ty
	local tw, th = zone.tw, zone.th
	local flowOut = zone.flowOut
	local flowIn = zone.flowIn
	

	if not flowOut then 
		flowOut = {
			direction = 1, 
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
			direction = 1, 
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

--[[
local function createSpawnZone ()
	local tx, ty = Game.mouseLevelCursor.tx, Game.mouseLevelCursor.ty
	local flow1, flow2

	if Editor.selectedZone then
		Editor.selectedZone.selected = nil
		Editor.selectedZone = nil
	end

	local spawnZone = {
		tx = tx,
		ty = ty,
		tw = 2,
		th = 2,
		zoneArt = 1,
		zoneColor = 1,
		letter='Z',
		type = 'spawner',
		flows = {},

		flowOut = {
			direction = 1, 
--			flows = {}, 
			amount=0,
			maxAmount = 20,
			point = {},
			lines = {},
			textPosition = {},
		},
		flowIn = {
			direction = 1, 
--			flows = {},
			amount=0,
			maxAmount = 20,
			point = {},
			lines = {},
			textPosition = {},
		},
		left = true,
	}

	updateSpawnerZone (spawnZone)

	Editor.selectedZone = spawnZone
	spawnZone.selected = true
	table.insert (currentLevel.spawners, spawnZone)
end
--]]

local function createEntity (isSpawner) -- bool
--	local tx, ty = Game.mouseLevelCursor.tx, Game.mouseLevelCursor.ty

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
--			letter='Z',
			type = 'spawner',
--			flows = {},

--			flowOut = {
--				direction = 1, 
--				amount=0,
--				maxAmount = 20,
--				point = {},
--				lines = {},
--				textPosition = {},
--			},
--			flowIn = {
--				direction = 1, 
--				amount=0,
--				maxAmount = 20,
--				point = {},
--				lines = {},
--				textPosition = {},
--			},
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

local function deleteSelectedZone ()
	if Editor.selectedZone then
		for i, zone in ipairs (currentLevel.entities) do
			if zone == Editor.selectedZone then
				table.remove (currentLevel.entities, i)
				Editor.selectedZone = nil
				return
			end
		end
--		for i, zone in ipairs (currentLevel.spawners) do
--			if zone == Editor.selectedZone then
--				table.remove (currentLevel.spawners, i)
--				Editor.selectedZone = nil
--				return
--			end
--		end
	end

end

local function swapZone ()
	local zone = Editor.selectedZone
	if zone and zone.type == 'spawner' then
		zone.left = not zone.left
		updateSpawnerZone (zone)
	end
end


local function changeInputPosition ()
	local zone = Editor.selectedZone
	if zone and zone.type == 'spawner' then
		zone.flowIn.direction = zone.flowIn.direction + 1
		updateSpawnerZone (zone)
	end
end

local function changeOutputPosition ()
	local zone = Editor.selectedZone
	if zone and zone.type == 'spawner' then
		zone.flowOut.direction = zone.flowOut.direction + 1
		updateSpawnerZone (zone)
	end
end

local function nextZoneArt ()
	local zone = Editor.selectedZone
	if not zone then return end
	local zoneArt = zone.zoneArt
	zone.zoneArt = (zoneArt + 0) % #Data.zoneArtList + 1
end

local function prevZoneArt ()
	local zone = Editor.selectedZone
	if not zone then return end
	local zoneArt = zone.zoneArt
	zone.zoneArt = (zoneArt - 2) % #Data.zoneArtList + 1
end


local function nextZoneColor ()
	local zone = Editor.selectedZone
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

-- utils.lua
local function mouseLevelCursorInsideZone (zone, dtx, dty)
--	local tx, ty = Game.mouseLevelCursor.tx, Game.mouseLevelCursor.ty
	local preselect = Editor.preselect
	local tx, ty = preselect.tx, preselect.ty
	dtx = dtx or 0
	dty = dty or 0
	if tx >= zone.tx and ty >=zone.ty
	and tx < zone.tx+zone.tw + dtx and ty < zone.ty+zone.th + dty then
		return true
	end
end





function Editor.mousepressed(x, y, button)
	-- [handles mouse press events]

	local preselect = Editor.preselect
	print ('preselect exists:'.. tostring(preselect))
	local tx, ty = preselect.tx, preselect.ty

	preselect.pressed = {tx=tx, ty=ty}




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
end

function Editor.mousereleased(x, y, button)
	-- [handles mouse release events]
	print(string.format("Mouse button %d released at (%d, %d)", button, x, y))
	local preselect = Editor.preselect
	preselect.pressed = nil
end

function Editor.mousemoved(x, y, dx, dy)
	-- [handles mouse movement events]
	local tileSize = 40
	local mtx = math.floor (x/tileSize)
	local mty = math.floor (y/tileSize)
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
end

local function getMouseSpawnerZone ()
	local tx, ty = Game.mouseLevelCursor.tx, Game.mouseLevelCursor.ty
	for i, zone in ipairs (currentLevel.spawners) do
		if tx >= zone.tx and ty >=zone.ty
		and tx < zone.tx+zone.tw and ty < zone.ty+zone.th then
			return zone
		end
	end
end

function Editor.wheelmoved (x, y)
	-- [handles mouse wheel events in the editor]
	local selectedZone = Editor.selectedZone
	if selectedZone and selectedZone.type == 'spawner' then
		local targetZone = getMouseSpawnerZone ()
		if targetZone then
			print ('selectedZone targetZone', y)
			local flowOut = selectedZone.flowOut
			local flowIn = targetZone.flowIn
			if y > 0 then
				if flowOut.amount < flowOut.maxAmount
				and flowIn.amount < flowIn.maxAmount then
					flowIn.amount = flowIn.amount + 1
					flowOut.amount = flowOut.amount + 1
					if not selectedZone.flows[targetZone] then
						selectedZone.flows[targetZone] = 0
					end
					selectedZone.flows[targetZone] = selectedZone.flows[targetZone] + 1
				end
			elseif y < 0 then
				if flowOut.amount > 0 -- maybe minAmount for map conntctions
				and flowIn.amount > 0 then
					flowIn.amount = flowIn.amount - 1
					flowOut.amount = flowOut.amount - 1
					if not selectedZone.flows[targetZone] then
						selectedZone.flows[targetZone] = 0
					end
					selectedZone.flows[targetZone] = selectedZone.flows[targetZone] - 1
				end
			end
		end
	end
	-- [clamp zoom level to prevent extreme scaling]

end

return Editor
