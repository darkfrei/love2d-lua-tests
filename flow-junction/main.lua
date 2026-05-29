-- main.lua
--
-- bootstrap and deterministic world tick simulation

local level  = require("example")
local render = require("render")
local car    = require("car")
local tunel  = require("tunel")

local paused  = false
local viewTick = 0

-- window configuration

local WINDOW_WIDTH  = 1920
local WINDOW_HEIGHT = 1080

-- discrete world timing

local WORLD_TICK_RATE = 0.5

local worldTick = 0
local tickTimer = 0

-- car spawning

local SPAWN_INTERVAL = 0.75
local spawnTimer = 0.0

function love.load()
	love.window.setMode(
		WINDOW_WIDTH,
		WINDOW_HEIGHT,
		{
			vsync = 1,
			resizable = false
		}
	)

	love.window.setTitle(
		"traffic intersection prototype"
	)

	love.graphics.setLineStyle("smooth")
	love.graphics.setLineJoin("none")

	love.graphics.setBackgroundColor(
		0.08,
		0.10,
		0.12
	)

	tunel.build(level)

	car.setTickRate(WORLD_TICK_RATE)
end

function love.update(dt)
	if paused then
		return
	end

	tickTimer = tickTimer + dt

	while tickTimer >= WORLD_TICK_RATE do
		worldTick  = worldTick + 1
		tickTimer  = tickTimer - WORLD_TICK_RATE
		spawnTimer = spawnTimer + WORLD_TICK_RATE

		while spawnTimer >= SPAWN_INTERVAL do
			car.spawnCar(level, worldTick)
			spawnTimer = spawnTimer - SPAWN_INTERVAL
		end

		tunel.cleanPassedTicks(worldTick)
	end

	car.update(
		dt,
		level,
		worldTick,
		tickTimer / WORLD_TICK_RATE
	)
end

function love.keypressed(key)
	if key == "space" then
		paused = not paused

		if paused then
			viewTick  = worldTick
			tickTimer = 0

			car.update(
				0,
				level,
				worldTick,
				0
			)
		end

	elseif key == "left" and paused then
		viewTick = viewTick - 1

	elseif key == "right" and paused then
		viewTick = viewTick + 1
	end
end

function love.draw()
	local displayTick  = paused and viewTick or worldTick
	local displayAlpha = paused and 0 or (tickTimer / WORLD_TICK_RATE)

	render.draw(level)
	car.draw(displayTick, displayAlpha)

	local carsInTunnelNow = tunel.getCarsAtTick(displayTick)

	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.print(
		"world tick: " .. worldTick,
		20,
		20
	)

	love.graphics.print(
		"view tick: " .. displayTick,
		20,
		40
	)

	love.graphics.print(
		"tunnel cars: " .. #carsInTunnelNow,
		20,
		60
	)

	if paused then
		love.graphics.setColor(1, 0.8, 0, 1)

		love.graphics.print(
			"paused  left/right = scrub",
			20,
			80
		)
	else
		love.graphics.setColor(0.55, 0.55, 0.55, 1)

		love.graphics.print(
			"space = pause",
			20,
			80
		)
	end
end