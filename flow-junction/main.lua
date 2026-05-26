-- main.lua
--
-- bootstrap and world tick simulation
-- initializes rendering, conflict zones and deterministic traffic spawning

local level  = require("example")
local render = require("render")
local car    = require("car")
local tunel  = require("tunel")

-- window configuration -----------------------------------------------------

local WINDOW_WIDTH  = 1920
local WINDOW_HEIGHT = 1080

-- discrete world timing ----------------------------------------------------

local WORLD_TICK_RATE = 0.1

local worldTick = 0
local tickTimer = 0

-- car spawning -------------------------------------------------------------

-- 1 second = 10 ticks
local SPAWN_TICK_INTERVAL = 10

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

	-- build conflict zones once during startup
	tunel.build(level)

	-- synchronize global tick duration with car planner
	car.setTickRate(WORLD_TICK_RATE)
end

function love.update(dt)
	tickTimer = tickTimer + dt

	-- advance discrete simulation ticks
	while tickTimer >= WORLD_TICK_RATE do
		worldTick = worldTick + 1
		tickTimer = tickTimer - WORLD_TICK_RATE

		-- spawn one new car every fixed interval
		if worldTick % SPAWN_TICK_INTERVAL == 0 then
			car.spawnCar(level, worldTick)
		end

		-- remove outdated schedule entries
		tunel.cleanPassedTicks(worldTick)
	end

	local alpha = tickTimer / WORLD_TICK_RATE

	car.update(
		dt,
		level,
		worldTick,
		alpha
	)
end

function love.keypressed(key)
	if key == "space" then
		local liveCars = car.getLiveCars()

		-- apply delayed arrival offset to all upcoming cars
		for _, c in ipairs(liveCars) do
			if c.appliedDelta == 0
			and not c.done
			and c.tunnelEntryTick
			and worldTick < c.tunnelEntryTick then
				c:adjustArrival(10)
			end
		end
	end
end

function love.draw()
	-- interpolation factor for smooth rendering
	local alpha = tickTimer / WORLD_TICK_RATE

	-- draw static road geometry
	render.draw(level)

	-- draw cars and tunnel visualization
	car.draw()

	-- debug information ----------------------------------------------------

	local carsInTunnelNow = tunel.getCarsAtTick(worldTick)

	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.print(
		"current world tick: " .. worldTick,
		20,
		20
	)

	love.graphics.print(
		"active cars inside tunnel register: " .. #carsInTunnelNow,
		20,
		40
	)

	love.graphics.print(
		"press space to apply +10 tick arrival delay",
		20,
		60
	)
end