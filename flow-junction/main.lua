-- main.lua
--
-- bootstrap with 1-second (10-tick) spawn interval and visualization state handling

local level  = require("example")
local render = require("render")
local car    = require("car")
local tunel  = require("tunel")

-- window configuration
local WINDOW_WIDTH  = 1920
local WINDOW_HEIGHT = 1080

-- variables for discrete ticks
local WORLD_TICK_RATE = 0.1
local worldTick = 0
local tickTimer = 0

-- spawn interval constraint (1.0 second = 10 ticks)
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

	-- build conflict zones once on startup
	tunel.build(level)

	-- pass global tick rate duration into car module
	car.setTickRate(WORLD_TICK_RATE)
end

function love.update(dt)
	tickTimer = tickTimer + dt

	-- advance world ticks based on elapsed time
	while tickTimer >= WORLD_TICK_RATE do
		worldTick = worldTick + 1
		tickTimer = tickTimer - WORLD_TICK_RATE
		
		-- Генерируем новую машину строго каждые 10 тиков (ровно 1 секунда реального времени)
		if worldTick % SPAWN_TICK_INTERVAL == 0 then
			car.spawnCar(level, worldTick)
		end

		-- УБИРАЕМ ЗАПИСЬ: говорим туннелю стереть историю для всех прошедших тиков
		tunel.cleanPassedTicks(worldTick)
	end

	local alpha = tickTimer / WORLD_TICK_RATE
	car.update(dt, level, worldTick, alpha)
end

function love.keypressed(key)
	if key == "space" then
		local liveCars = car.getLiveCars()
		
		-- перебираем вообще все машины на экране
		for _, c in ipairs(liveCars) do
			-- если машина еще не подстраивалась и физически еще не в туннеле
			if c.appliedDelta == 0 and not c.done and c.tunnelEntryTick and worldTick < c.tunnelEntryTick then
				c:adjustArrival(10) -- задерживаем каждую на 10 тиков
			end
		end
	end
end

function love.draw()
	-- Вычисляем текущую альфу для плавного рендеринга
	local alpha = tickTimer / WORLD_TICK_RATE

	-- Рендерим статичную геометрию дорог
	render.draw(level)
	
	-- Менеджер машин теперь сам внутри себя вызывает tunel.draw, 
	-- но для надежности передаем актуальные тики в общую отрисовку
	car.draw()

	-- ВРЕМЕННЫЙ ТЕСТ: проверяем сколько машин СЕЙЧАС в туннеле по базе данных туннеля
	local carsInTunnelNow = tunel.getCarsAtTick(worldTick)
	
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("Current World Tick: " .. worldTick, 20, 20)
	love.graphics.print("Active cars inside tunnel register right now: " .. #carsInTunnelNow, 20, 40)
	love.graphics.print("Press SPACE to apply +10 ticks brake offset to upcoming cars", 20, 60)
end