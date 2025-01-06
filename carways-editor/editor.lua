-- editor.lua
-- [editor state implementation]

local Editor = {}

function Editor.enter()
	-- [initializes editor state]
	print("Editor state entered")
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


function Editor.draw()
	local ts = Game.tileSize
	-- background
	love.graphics.setColor (1,1,1)
	love.graphics.draw (backgroundImage)

	--walls
	love.graphics.setColor (1,1,0)
	love.graphics.setLineWidth (2)
	for i, wallZone in ipairs (currentLevel.walls) do
		local tx, ty = wallZone.tx, wallZone.ty
		local tw, th = wallZone.tw, wallZone.th
		local selected = wallZone.selected
		if selected then
			love.graphics.setLineWidth (3)
		else
			love.graphics.setLineWidth (1)
		end

		love.graphics.rectangle ('line', ts*tx, ts*ty, ts*tw, ts*th)

		love.graphics.print (wallZone.letter, ts*tx, ts*ty)
	end

	--spawners


	for i, spawnerZone in ipairs (currentLevel.spawners) do
		love.graphics.setColor (0,1,0)
--		love.graphics.setLineWidth (2)
		local tx, ty = spawnerZone.tx, spawnerZone.ty
		local tw, th = spawnerZone.tw, spawnerZone.th
		local selected = spawnerZone.selected
		if selected then
			love.graphics.setLineWidth (3)
		else
			love.graphics.setLineWidth (1)
		end

		love.graphics.rectangle ('line', ts*tx, ts*ty, ts*tw, ts*th)

		love.graphics.setColor (0,0,0)
		love.graphics.setLineWidth (2)
		local flowOut = spawnerZone.flowOut
		love.graphics.circle ('fill', flowOut.point.x, flowOut.point.y, 4)

		for i, line in ipairs (flowOut.lines) do
			love.graphics.line (line)
		end

		love.graphics.print (flowOut.amount, flowOut.textPosition.x, flowOut.textPosition.y)

		local flowIn = spawnerZone.flowIn
		love.graphics.circle ('fill', flowIn.point.x, flowIn.point.y, 4)

		for i, line in ipairs (flowIn.lines) do
			love.graphics.line (line)
		end
		love.graphics.print (flowIn.amount, flowIn.textPosition.x, flowIn.textPosition.y)

--		love.graphics.print (spawnerZone.letter, ts*tx, ts*ty)
	end

	-- mouse
	love.graphics.setColor (1,1,1)
	local tx, ty = Game.mouseLevelCursor.tx, Game.mouseLevelCursor.ty
	local tw, th = Game.mouseLevelCursor.tw, Game.mouseLevelCursor.th
	love.graphics.setLineWidth (1)
	love.graphics.rectangle ('line', ts*tx, ts*ty, ts*tw, ts*th)
end

function Editor.exit()
	-- [cleans up editor state]
	print("Editor state exited")
end


local function createWallZone ()
	local tx, ty = Game.mouseLevelCursor.tx, Game.mouseLevelCursor.ty

	if Editor.selectedZone then
		Editor.selectedZone.selected = false
		Editor.selectedZone = nil
	end

	local wallZone = {
		tx = tx,
		ty = ty,
		tw = 1,
		th = 1,
		zoneArt = 1,
		zoneColor = 1,
		letter='W',
		type = 'wall',
	}
	Editor.selectedZone = wallZone
	wallZone.selected = true
	table.insert (currentLevel.walls, wallZone)
end

local function updateSpawnerZone (zone)
	local ts = Game.tileSize
	local tx, ty = zone.tx, zone.ty
	local tw, th = zone.tw, zone.th
	local flowOut = zone.flowOut
	local flowIn = zone.flowIn

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
			flowOut.point = {x=x1, y=y}
			flowOut.lines = {
				{x1, y, x1, y-ts},
				{x1-5, y-ts+10, x1, y-ts, x1+5, y-ts+10},
			}
			flowOut.textPosition = {x=x1-5, y=y+5}

			-- in
			flowIn.point = {x=x2, y=y-ts}
			flowIn.lines = {
				{x2, y-ts, x2, y},
				{x2-5, y-10, x2, y, x2+5, y-10},
			}
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
			flowOut.point = {x = x, y = y1}
			flowOut.lines = {
				{x, y1, x + ts, y1},
				{x + ts - 10, y1 - 5, x + ts, y1, x + ts - 10, y1 + 5},
			}
			flowOut.textPosition = {x = x - 5, y = y1 + 5}

			-- in
			flowIn.point = {x = x + ts, y = y2}
			flowIn.lines = {
				{x + ts, y2, x, y2},
				{x + 10, y2 - 5, x, y2, x + 10, y2 + 5},
			}
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
			flowOut.point = {x = x1, y = y}
			flowOut.lines = {
				{x1, y, x1, y + ts},
				{x1 - 5, y + ts - 10, x1, y + ts, x1 + 5, y + ts - 10},
			}
			flowOut.textPosition = {x = x1 - 5, y = y - 20}

			-- in
			flowIn.point = {x = x2, y = y + ts}
			flowIn.lines = {
				{x2, y + ts, x2, y},
				{x2 - 5, y + 10, x2, y, x2 + 5, y + 10},
			}
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
			flowOut.point = {x = x, y = y1}
			flowOut.lines = {
				{x, y1, x - ts, y1},
				{x - ts + 10, y1 - 5, x - ts, y1, x - ts + 10, y1 + 5},
			}
			flowOut.textPosition = {x = x - 5, y = y1 + 5}

			-- in
			flowIn.point = {x = x - ts, y = y2}
			flowIn.lines = {
				{x - ts, y2, x, y2},
				{x - 10, y2 - 5, x, y2, x - 10, y2 + 5},
			}
			flowIn.textPosition = {x = x - 5, y = y2 + 5}


		end
	else
		-- not same direction

		if flowOut.direction == 1 then
			local x = ts*(tx+tw/2)
			local y = ts*(ty+0.5)
			flowOut.point = {x=x, y=y}
			flowOut.lines = {
				{x, y, x, y-ts},
				{x-5, y-ts+10, x, y-ts, x+5, y-ts+10},
			}
			flowOut.textPosition = {x=x-5, y=y+5}
		elseif flowOut.direction == 2 then
			-- right
			local x = ts*(tx+tw-0.5)
			local y = ts*(ty+th/2)
			flowOut.point = {x=x, y=y}
			flowOut.lines = {
				{x, y, x+ts, y},
				{x+ts-10, y-5, x+ts, y, x+ts-10, y+5},
			}
			flowOut.textPosition = {x=x-5, y=y+5}
		elseif flowOut.direction == 3 then
			local x = ts*(tx+tw/2)
			local y = ts*(ty+th-0.5)
			flowOut.point = {x=x, y=y}
			flowOut.lines = {
				{x, y, x, y+ts},
				{x-5, y+ts-10, x, y+ts, x+5, y+ts-10},
			}
			flowOut.textPosition = {x=x-5, y=y-20}
		elseif flowOut.direction == 4 then
			-- left
			local x = ts*(tx+0.5)
			local y = ts*(ty+th/2)
			flowOut.point = {x=x, y=y}
			flowOut.lines = {
				{x, y, x+tw-ts, y},
				{x-ts+10, y-5, x-ts, y, x-ts+10, y+5},
			}
			flowOut.textPosition = {x=x-5, y=y+5}
		end

		if flowIn.direction == 1 then
			local x = ts*(tx+tw/2)
			local y = ts*(ty+0.5)
			flowIn.point = {x=x, y=y-ts}
			flowIn.lines = {
				{x, y-ts, x, y},   
				{x-5, y-10, x, y, x+5, y-10},
			}
			flowIn.textPosition = {x=x-5, y=y+5}

			---- errors:
		elseif flowIn.direction == 2 then -- right
			local x = ts * (tx + tw - 0.5)
			local y = ts * (ty + th / 2)
			flowIn.point = { x = x + ts, y = y }
			flowIn.lines = {
				{ x + ts, y, x, y },
				{ x + 10, y - 5, x, y, x + 10, y + 5 },
			}
			flowIn.textPosition = {x=x-5, y=y+5}
		elseif flowIn.direction == 3 then -- 
			local x = ts * (tx + tw / 2)
			local y = ts * (ty + th - 0.5)
			flowIn.point = { x = x, y = y + ts }
			flowIn.lines = {
				{ x, y + ts, x, y },
				{ x - 5, y + 10, x, y, x + 5, y + 10 },
			}
			flowIn.textPosition = { x = x - 5, y = y - 20 }
		elseif flowIn.direction == 4 then -- 
			local x = ts * (tx + 0.5)
			local y = ts * (ty + th / 2)
			flowIn.point = { x = x - ts, y = y }
			flowIn.lines = {
				{ x - ts, y, x, y },
				{ x - 10, y - 5, x, y, x - 10, y + 5 },
			}
			flowIn.textPosition = { x = x - 5, y = y + 5 }
		end

	end

end

local function createSpawnZone ()
	local tx, ty = Game.mouseLevelCursor.tx, Game.mouseLevelCursor.ty
	local flow1, flow2

	if Editor.selectedZone then
		Editor.selectedZone.selected = false
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

local function deleteSelectedZone ()
	if Editor.selectedZone then
		for i, zone in ipairs (currentLevel.walls) do
			if zone == Editor.selectedZone then
				table.remove (currentLevel.walls, i)
				Editor.selectedZone = nil
				return
			end
		end
		for i, zone in ipairs (currentLevel.spawners) do
			if zone == Editor.selectedZone then
				table.remove (currentLevel.spawners, i)
				Editor.selectedZone = nil
				return
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

function Editor.keypressed(key, scancode)
	print ('keypressed', key, scancode)
	local mousePressed = love.mouse.isDown (1)
	print ('mousePressed', tostring (mousePressed))
	if key == "w" then
		createWallZone ()
	elseif key == "z" then
		createSpawnZone ()
	elseif key == "delete" then
		deleteSelectedZone ()
	elseif key == "b" then
		swapZone () -- left side or right side
	elseif key == "i" then
		changeInputPosition ()
	elseif key == "o" then
		changeOutputPosition ()

	end	
--	if key == "escape" then
--		print("Exiting editor mode...")
--		love.event.quit()
--	elseif key == "space" then
--		print("Space key pressed!")
--	else
--		print("Key pressed: " .. key)
--	end
end

-- utils.lua
local function mouseLevelCursorInsideZone (zone, dtx, dty)
	local tx, ty = Game.mouseLevelCursor.tx, Game.mouseLevelCursor.ty
	dtx = dtx or 0
	dty = dty or 0
	if tx >= zone.tx and ty >=zone.ty
	and tx < zone.tx+zone.tw + dtx and ty < zone.ty+zone.th + dty then
		return true
	end
end





function Editor.mousepressed(x, y, button)
	-- [handles mouse press events]

	local mouseLevelCursor = Game.mouseLevelCursor
	local tx, ty = mouseLevelCursor.tx, mouseLevelCursor.ty

	mouseLevelCursor.pressed = {tx=tx, ty=ty}



	local shiftPressed = love.keyboard.isDown('lshift', 'rshift')
	print ('shiftPressed', tostring (shiftPressed))
	if not shiftPressed then
		if Editor.selectedZone then
			Editor.selectedZone.selected = false
			Editor.selectedZone = nil
		end

		local zone
		for i, wallZone in ipairs (currentLevel.walls) do
			if mouseLevelCursorInsideZone (wallZone) then
				wallZone.selected = true
				zone = wallZone
				break
			else
				wallZone.selected = false
			end
		end
		for i, spawnerZone in ipairs (currentLevel.spawners) do
			if mouseLevelCursorInsideZone (spawnerZone) then
				spawnerZone.selected = true
				zone = spawnerZone
				break
			else
				spawnerZone.selected = false
			end
		end
		if zone then
			Editor.selectedZone = zone
		else
			Editor.selectedZone = nil
		end
	end
end

function Editor.mousereleased(x, y, button)
	-- [handles mouse release events]
	print(string.format("Mouse button %d released at (%d, %d)", button, x, y))
	local mouseLevelCursor = Game.mouseLevelCursor
	mouseLevelCursor.pressed = nil
end

function Editor.mousemoved(x, y, dx, dy)
	-- [handles mouse movement events]
	local tileSize = 40
	local mtx = math.floor (x/tileSize)
	local mty = math.floor (y/tileSize)
	local mouseLevelCursor = Game.mouseLevelCursor
	mouseLevelCursor.tx = mtx
	mouseLevelCursor.ty = mty

	local mousePressed = mouseLevelCursor.pressed
	local isShiftDown = love.keyboard.isDown ('lshift', 'rshift')
	local zone = Editor.selectedZone
	local zoneHovered = zone and mouseLevelCursorInsideZone (zone, dtx, dty)

	if zone and mousePressed then
		local dtx = mtx - mousePressed.tx
		local dty = mty - mousePressed.ty
		love.window.setTitle (dtx..' '..dty)
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
