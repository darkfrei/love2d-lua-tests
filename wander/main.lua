local settings = require("settings")
local FlowField = require("flowfield")
local Wander = require("wander")
local Vehicle = require("vehicle")
local Trail = require("trail")
local World = require("world")

local flowField
local wanderState
local vehicle
local trail
local sessionRng
local simulationTime = 0
local showField = settings.debug.showField
local activeSeed = 0
local currentWanderInfo = nil

local seedCounter = 0
local baseSeed = os.time() * 1000

local function nextSeed()
	seedCounter = seedCounter + 1
	return baseSeed + seedCounter
end

local function atan2(y, x)
	if math.atan2 then
		return math.atan2(y, x)
	end

	if x > 0 then
		return math.atan(y / x)
	elseif x < 0 and y >= 0 then
		return math.atan(y / x) + math.pi
	elseif x < 0 and y < 0 then
		return math.atan(y / x) - math.pi
	elseif x == 0 and y > 0 then
		return math.pi * 0.5
	elseif x == 0 and y < 0 then
		return -math.pi * 0.5
	end

	return 0
end

local function normalize(x, y)
	local length = math.sqrt(x * x + y * y)
	if length < 1e-7 then
		return 1, 0
	end
	return x / length, y / length
end

local function clampLength(x, y, maxLength)
	local length = math.sqrt(x * x + y * y)
	if length > maxLength then
		local scale = maxLength / length
		return x * scale, y * scale
	end
	return x, y
end

local function buildScene(seed)
	activeSeed = seed
	flowField = FlowField.new(settings, seed)
	wanderState = Wander.new(settings, seed + 1)
	trail = Trail.new(settings)
	sessionRng = love.math.newRandomGenerator(seed + 2)
	vehicle = Vehicle.new(settings)
	simulationTime = 0
	currentWanderInfo = nil

	local margin = settings.vehicle.spawnMargin
	local x = sessionRng:random(margin, settings.world.width - margin)
	local y = sessionRng:random(margin, settings.world.height - margin)
	local angle = sessionRng:random() * math.pi * 2

	Vehicle.reset(vehicle, x, y, angle, settings)
end

local function respawnVehicle()
	local margin = settings.vehicle.spawnMargin
	local x = sessionRng:random(margin, settings.world.width - margin)
	local y = sessionRng:random(margin, settings.world.height - margin)
	local angle = sessionRng:random() * math.pi * 2

	Vehicle.reset(vehicle, x, y, angle, settings)
	Wander.reset(wanderState, nextSeed())
	Trail.clear(trail)
end

local function drawFlowFieldGrid()
	local spacing = settings.flowField.gridSpacing
	local halfLength = spacing * settings.flowField.arrowScale

	love.graphics.setLineWidth(1)

	for cx = spacing * 0.5, settings.world.width, spacing do
		for cy = spacing * 0.5, settings.world.height, spacing do
			local vx, vy = FlowField.sampleVector(flowField, cx, cy)
			local tint = vy * 0.5 + 0.5

			love.graphics.setColor(0.08 + 0.28 * tint, 0.30 + 0.30 * tint, 0.60 + 0.22 * tint, 0.30)
			love.graphics.line(
				cx - vx * halfLength,
				cy - vy * halfLength,
				cx + vx * halfLength,
				cy + vy * halfLength
			)

			love.graphics.setColor(0.25 + 0.28 * tint, 0.46 + 0.22 * tint, 0.88, 0.36)
			love.graphics.circle("fill", cx + vx * halfLength, cy + vy * halfLength, 1.9)
		end
	end
end

local function drawVehicleBody()
	local bodyAngle = atan2(vehicle.vy, vehicle.vx)

	love.graphics.push()
	love.graphics.translate(vehicle.x, vehicle.y)
	love.graphics.rotate(bodyAngle)

	love.graphics.setColor(0, 0, 0, 0.32)
	love.graphics.polygon("fill", 20, 2, -10, 11, -6, 2, -10, -7)

	love.graphics.setColor(0.20, 0.86, 0.44, 1)
	love.graphics.polygon("fill", 20, 0, -10, 10, -6, 0, -10, -10)

	love.graphics.setColor(0.78, 1.0, 0.80, 0.90)
	love.graphics.setLineWidth(1.2)
	love.graphics.polygon("line", 20, 0, -10, 10, -6, 0, -10, -10)

	love.graphics.setColor(1, 1, 1, 0.52)
	love.graphics.circle("fill", 10, 0, 2.5)

	love.graphics.pop()
end

local function drawWanderGuide()
	if not currentWanderInfo then
		return
	end

	local worldWidth = settings.world.width
	local worldHeight = settings.world.height

	local centerX = World.wrap(vehicle.x + currentWanderInfo.centerOffsetX, worldWidth)
	local centerY = World.wrap(vehicle.y + currentWanderInfo.centerOffsetY, worldHeight)
	local targetX = World.wrap(vehicle.x + currentWanderInfo.targetOffsetX, worldWidth)
	local targetY = World.wrap(vehicle.y + currentWanderInfo.targetOffsetY, worldHeight)

	love.graphics.setLineWidth(1)

	love.graphics.setColor(1, 1, 0.55, 0.23)
	World.drawWrappedLine(vehicle.x, vehicle.y, centerX, centerY, worldWidth, worldHeight)

	love.graphics.setColor(1, 1, 0.38, 0.21)
	love.graphics.circle("line", centerX, centerY, settings.wander.radius)

	love.graphics.setColor(1, 1, 0.38, 0.42)
	love.graphics.circle("fill", centerX, centerY, 2.5)

	local flowVx, flowVy = FlowField.sampleVector(flowField, vehicle.x, vehicle.y)
	local flowLength = settings.wander.radius * 0.80
	local flowEndX = centerX + flowVx * flowLength
	local flowEndY = centerY + flowVy * flowLength

	love.graphics.setColor(0.28, 0.68, 1.0, 0.62)
	love.graphics.setLineWidth(1.5)
	World.drawWrappedLine(centerX, centerY, flowEndX, flowEndY, worldWidth, worldHeight)
	love.graphics.circle("fill", World.wrap(flowEndX, worldWidth), World.wrap(flowEndY, worldHeight), 4)

	love.graphics.setColor(1, 0.50, 0.07, 0.92)
	World.drawWrappedLine(centerX, centerY, targetX, targetY, worldWidth, worldHeight)

	love.graphics.setColor(1, 0.17, 0.03, 1)
	love.graphics.circle("fill", targetX, targetY, 6)

	love.graphics.setColor(1, 1, 1, 0.68)
	love.graphics.setLineWidth(1)
	love.graphics.circle("line", targetX, targetY, 6)
end

local function drawHud()
	local speed = Vehicle.speed(vehicle)

	love.graphics.setColor(0, 0, 0, 0.50)
	love.graphics.rectangle("fill", 12, 32, 262, 54, 5, 5)

	love.graphics.setColor(1, 1, 1, 0.38)
	love.graphics.print(
		string.format(
			"Wander + Perlin flow field   speed %.0f px/s   seed %d   [f] field %s   [n] new noise   [r] reset vehicle   [esc] quit",
			speed,
			activeSeed,
			showField and "on" or "off"
		),
		18,
		14
	)
end

function love.load()
	love.window.setMode(
		settings.window.width,
		settings.window.height,
		{
			fullscreen = settings.window.fullscreen,
			resizable = settings.window.resizable,
			vsync = settings.window.vsync,
		}
	)

	love.window.setTitle(settings.window.title)
	love.graphics.setBackgroundColor(
		settings.background[1],
		settings.background[2],
		settings.background[3],
		settings.background[4]
	)
	love.graphics.setLineStyle("smooth")

	buildScene(nextSeed())
end

local function update (dt)
	dt = math.min(dt, settings.simulation.maxDt)

	simulationTime = simulationTime + dt
	FlowField.update(flowField, dt)

	local flowAngle = FlowField.sampleAngle(flowField, vehicle.x, vehicle.y)
	local wanderInfo = Wander.update(wanderState, vehicle, flowAngle, dt, settings)

	local desiredX, desiredY = normalize(wanderInfo.targetOffsetX, wanderInfo.targetOffsetY)
	local desiredVx = desiredX * settings.vehicle.maxSpeed
	local desiredVy = desiredY * settings.vehicle.maxSpeed

	local steerX = desiredVx - vehicle.vx
	local steerY = desiredVy - vehicle.vy
	steerX, steerY = clampLength(steerX, steerY, settings.vehicle.maxForce)

	local prevX, prevY = vehicle.x, vehicle.y
	Vehicle.integrate(vehicle, steerX, steerY, dt, settings)
	Trail.addSegment(trail, prevX, prevY, vehicle.x, vehicle.y)

	currentWanderInfo = wanderInfo
end

function love.update(dt)
	update (dt)

	if love.keyboard.isDown ('space') then
		for i = 1, 100 do update (1/60)
			update (dt)
		end
	end
end

function love.draw()
	love.graphics.clear(
		settings.background[1],
		settings.background[2],
		settings.background[3],
		settings.background[4]
	)

	if showField then
		drawFlowFieldGrid()
	end

	Trail.draw(trail)
	drawWanderGuide()
	drawVehicleBody()
--	drawHud()
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
		return
	end

	if key == "f" then
		showField = not showField
	elseif key == "n" then
		buildScene(nextSeed())
	elseif key == "r" then
		respawnVehicle()
	end
end