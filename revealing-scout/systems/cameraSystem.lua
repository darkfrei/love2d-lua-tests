-- systems/cameraSystem.lua
-- all comments in code are in english and lowercase

local System = require("core.system")

local CameraSystem = setmetatable({}, { __index = System })

local function lerp(a, b, t) return a + (b - a) * t end

function CameraSystem:update(world, dt)
	-- require camera
	if not world.camera then return end
	local camera = world.camera

	-- find player-controlled scout with renderable
	local scout
	local entities = world:getEntitiesWithComponents({ "scout", "renderable" })
	for _, e in ipairs(entities) do
		if e.components.scout and e.components.scout.playerControlled then
			scout = e
			break
		end
	end
	if not scout then return end

	-- desired camera translation that centers the scout on screen
	local rend = scout.components.renderable
	if not (rend and rend.x and rend.y) then return end

	local winW, winH = love.graphics.getWidth(), love.graphics.getHeight()
	local desiredX = (winW * 0.5) - rend.x
	local desiredY = (winH * 0.5) - rend.y

	-- when world is not moving, release the camera (keep last position)
	if not world.moving then
		-- clear turn-lock state so next move starts easing from current position
		if camera._turnLock then
			camera._turnLock = false
			camera._startX, camera._startY = nil, nil
		end
		return
	end

	-- world is moving: handle 2 phases
	local dur = world.turnDuration or 1
	local tt  = math.max(0, math.min((world.turnTimer or 0) / dur, 1)) -- normalized 0..1

	-- on movement start, remember where camera was (for ease-in from that point)
	if not camera._turnLock then
		camera._turnLock = true
		camera._startX = camera.x or 0
		camera._startY = camera.y or 0
	end

	-- phase 1: first quarter of the turn -> smooth approach to target center
	if tt < 0.25 then
		local p = tt / 0.25 -- 0..1 over the first quarter
		-- optional ease-out for a nicer feel (comment out if you want linear)
		-- p = 1 - (1 - p) * (1 - p) * (1 - p)
		camera.x = lerp(camera._startX, desiredX, p)
		camera.y = lerp(camera._startY, desiredY, p)
	else
		-- phase 2: lock camera center exactly on the scout for the rest of the turn
		camera.x = desiredX
		camera.y = desiredY
	end
end

return CameraSystem
