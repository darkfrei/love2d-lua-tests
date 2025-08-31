-- systems/inputSystem.lua
-- all comments in code are in english and lowercase

local System = require("core.system")
local Directions = require("utils.directions")


local InputSystem = setmetatable({}, {__index = System})

local function cameraUpdate (world, dt)
	if love.keyboard.isDown("left", "right", "up", "down") then
		local camera = world.camera
		local speed = -camera.speed
		if love.keyboard.isDown("left") then
			camera.x = camera.x - speed * dt
		end
		if love.keyboard.isDown("right") then
			camera.x = camera.x + speed * dt
		end
		if love.keyboard.isDown("up") then
			camera.y = camera.y - speed * dt
		end
		if love.keyboard.isDown("down") then
			camera.y = camera.y + speed * dt
		end
--		print ('camera.x, camera.y', camera.x, camera.y)
	end
end

-- update camera based on keyboard input
function InputSystem:update(world, dt)
	local camera = world.camera
	cameraUpdate (world, dt)
end

-------------------------------------------
function InputSystem:keypressed(world, key, scancode)
	if world.moving then
		return
	end

	local command = Directions.keyMap[key]
	if not command then return end

--	print ("InputSystem:keypressed", key, scancode)
	-- find scout entity
	local scout
	local entities = world:getEntitiesWithComponents({"scout"})
	for _, entity in ipairs(entities) do
		scout = entity
	end
	if not scout then return end

--	local command = Directions.keyMap[key]
--	if not command then return end

	local currentDir = scout.components.scout.direction
	local pos = scout.components.currentTile
	local r = pos.r
	local offsets = Directions.getOffsets(r)
	local offset = offsets[command]

	if command == "rotation-ccw" then
		-- rotate counter-clockwise
		scout.components.scout.direction = Directions.rotateDirection(currentDir, false)
	elseif command == "rotation-cw" then
		-- rotate clockwise
		scout.components.scout.direction = Directions.rotateDirection(currentDir, true)
	elseif command ~= currentDir  then
		-- direct direction set
		scout.components.scout.direction = command

	else
			scout:addComponent("nextTile", {
		q = pos.q + offset.dq,
		r = pos.r + offset.dr,
		})
		world.moving = true
		world.turnTimer = 0
	end
end

return InputSystem
