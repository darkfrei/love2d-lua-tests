-- space camera module
local spaceCamera = {}

-- initialize camera
function spaceCamera.init()
	-- camera properties
	spaceCamera.x = 0
	spaceCamera.y = 0
	spaceCamera.speed = 500
	spaceCamera.velocityX = 0
	spaceCamera.velocityY = 0
	spaceCamera.acceleration = 10
	spaceCamera.friction = 0.9

	-- zoom properties
	spaceCamera.scale = 1
	spaceCamera.targetScale = 1
	spaceCamera.zoomFactor = 2^(1/4)
	spaceCamera.scaleSpeed = 0.1
	spaceCamera.zoomSpeed = 5
	spaceCamera.minScale = 0.5
	spaceCamera.maxScale = 2

	spaceCamera.windowWidth = love.graphics.getWidth()
	spaceCamera.windowHeight = love.graphics.getHeight()
end

-- clamp value helper
local function clamp(value, min, max)
	return math.max(min, math.min(max, value))
end

-- update camera position
function spaceCamera.update(dt)
	-- limit dt to prevent large jumps
	dt = math.min(dt, 1/60)

	-- smoothly interpolate scale toward target
	spaceCamera.scale = spaceCamera.scale + (spaceCamera.targetScale - spaceCamera.scale) * spaceCamera.zoomSpeed * dt

	-- handle input
	local targetVelocityX, targetVelocityY = 0, 0
	if love.keyboard.isDown("left") then
		targetVelocityX = -spaceCamera.speed
	elseif love.keyboard.isDown("right") then
		targetVelocityX = spaceCamera.speed
	end
	if love.keyboard.isDown("up") then
		targetVelocityY = -spaceCamera.speed
	elseif love.keyboard.isDown("down") then
		targetVelocityY = spaceCamera.speed
	end

	-- apply acceleration only if input is active
	if targetVelocityX ~= 0 then
		spaceCamera.velocityX = spaceCamera.velocityX + (targetVelocityX - spaceCamera.velocityX) * spaceCamera.acceleration * dt
	end
	if targetVelocityY ~= 0 then
		spaceCamera.velocityY = spaceCamera.velocityY + (targetVelocityY - spaceCamera.velocityY) * spaceCamera.acceleration * dt
	end

	-- apply friction only if no input
	if targetVelocityX == 0 then
		spaceCamera.velocityX = spaceCamera.velocityX * spaceCamera.friction
	end
	if targetVelocityY == 0 then
		spaceCamera.velocityY = spaceCamera.velocityY * spaceCamera.friction
	end

	-- clamp velocity to max speed
	spaceCamera.velocityX = clamp(spaceCamera.velocityX, -spaceCamera.speed, spaceCamera.speed)
	spaceCamera.velocityY = clamp(spaceCamera.velocityY, -spaceCamera.speed, spaceCamera.speed)

	if math.abs (spaceCamera.velocityX) + math.abs (spaceCamera.velocityY) > 1 then
		-- update camera position
		spaceCamera.x = spaceCamera.x + spaceCamera.velocityX * dt
		spaceCamera.y = spaceCamera.y + spaceCamera.velocityY * dt
	else
		spaceCamera.velocityX = 0
		spaceCamera.velocityY = 0
		spaceCamera.x = math.floor(spaceCamera.x + 0.5)
		spaceCamera.y = math.floor(spaceCamera.y + 0.5)
	end
end

-- apply camera transformation
function spaceCamera.applyTransform()
	love.graphics.push()
	love.graphics.translate(spaceCamera.windowWidth / 2, spaceCamera.windowHeight / 2)
	love.graphics.scale(spaceCamera.scale, spaceCamera.scale)
	love.graphics.translate(-spaceCamera.x, -spaceCamera.y)
end

-- remove camera transformation
function spaceCamera.removeTransform()
	love.graphics.pop()
end


---- handle mouse wheel movement for zooming
--function love.wheelmoved(x, y)
--	if y ~= 0 then
--		-- Only change targetScale, actual scale will interpolate smoothly
--		spaceCamera.targetScale = clamp(
--			spaceCamera.targetScale + y * spaceCamera.scaleSpeed,
--			spaceCamera.minScale,
--			spaceCamera.maxScale
--		)
----        print("zoom center: x=" .. spaceCamera.x .. ", y=" .. spaceCamera.y)
--	end
--end

-- handle mouse wheel movement for zooming
function love.wheelmoved(x, y)
	if y ~= 0 then
		local zoomFactor = spaceCamera.zoomFactor^y
		local newTargetScale = spaceCamera.targetScale * zoomFactor
		spaceCamera.targetScale = clamp(newTargetScale, spaceCamera.minScale, spaceCamera.maxScale)
--		print("zoom center: x=" .. spaceCamera.x .. ", y=" .. spaceCamera.y)
	end
end


-- draw mouse coordinates in world space
function spaceCamera.draw()
	-- get mouse position in screen coordinates
	local mx, my = love.mouse.getPosition()
	-- convert to world coordinates
	local worldX = (mx - spaceCamera.windowWidth / 2) / spaceCamera.scale + spaceCamera.x
	local worldY = (my - spaceCamera.windowHeight / 2) / spaceCamera.scale + spaceCamera.y
	-- draw coordinates in screen space (top-left corner)
	love.graphics.setColor(1, 1, 1, 1)
--  love.graphics.print(string.format("World: x=%.2f, y=%.2f", worldX, worldY), 10, 10)
end

return spaceCamera