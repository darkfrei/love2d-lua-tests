-- simulation.lua
-- scene context: physics steps, traffic ticks, path binding

local Camera     = require("core.camera")
local Renderer   = require("core.renderer")
local Map        = require("core.map")
local UIHub      = require("ui.ui")
local Tunel      = require("simulation.tunel")
local CarManager = require("simulation.car-manager")

local Simulation = {}

Simulation.camera = nil
Simulation.map    = nil
Simulation.ui     = nil
Simulation.app    = nil

Simulation.paused = false
Simulation.speed  = 1

Simulation.worldTick     = 1
Simulation.spawnInterval = 0.1
Simulation.tickInterval  = 0.1
Simulation.tickTimer     = 0
Simulation.spawnTimer    = 0

Simulation.isDragging = false

--
-- load
--

function Simulation.load(appContext)
	Simulation.app    = appContext
	Simulation.camera = Camera.new()
	Simulation.map    = Map.new()
	Simulation.ui     = UIHub.new(Simulation, "simulation")

	Simulation.spawnInterval = 0.5
	Simulation.tickInterval  = 0.1
	Simulation.tickTimer     = 0
	Simulation.spawnTimer    = Simulation.spawnInterval
	Simulation.worldTick     = 1

	CarManager.clear()
end

--
-- map sync
--

function Simulation.syncMap(editorMap)

	-- copy nodes
	Simulation.map.nodes = {}
	for id, n in pairs(editorMap.nodes or {}) do
		Simulation.map.nodes[id] = { x = n.x, y = n.y }
	end

	-- copy ways, preserving all tags including layer
	Simulation.map.ways = {}

	for i, w in ipairs(editorMap.ways or {}) do
		if w then
			local hasRefs = w.nodeRefs and #w.nodeRefs > 0
			local hasTags = w.tags and w.tags.curve

			if hasRefs and hasTags then
				local refs = {}
				for _, r in ipairs(w.nodeRefs) do
					refs[#refs + 1] = r
				end

				Simulation.map.ways[#Simulation.map.ways + 1] = {
					id       = w.id or i,
					nodeRefs = refs,
					tags     = {
						curve = w.tags.curve,
						type  = w.tags.type  or nil,
						layer = tonumber(w.tags.layer) or 0,
					}
				}
			end
		end
	end

	-- rebuild tunnel system
	Tunel.build(Simulation.map)

	-- set tick rate for car system
	CarManager.setTickRate(Simulation.tickInterval)

	-- rebuild routing graph
	CarManager.syncMap(Simulation.map)

	Simulation.camera:fitAll(Simulation.map)
end

--
-- update
--

function Simulation.update(dt)

	if Simulation.ui then
		Simulation.ui:update(dt)
	end

	if Simulation.paused then return end

	local effectiveDt = dt * Simulation.speed
	Simulation.tickTimer  = Simulation.tickTimer  + effectiveDt
	Simulation.spawnTimer = Simulation.spawnTimer + effectiveDt

	-- world ticks
	while Simulation.tickTimer >= Simulation.tickInterval do
		Simulation.worldTick = Simulation.worldTick + 1
		Simulation.tickTimer = Simulation.tickTimer - Simulation.tickInterval
		Tunel.cleanPassedTicks(Simulation.worldTick)
	end

	-- car spawning
	while Simulation.spawnTimer >= Simulation.spawnInterval do
		Simulation.spawnTimer = Simulation.spawnTimer - Simulation.spawnInterval
		CarManager.spawnCar(Simulation.map, Simulation.worldTick)
	end

	local alpha = Simulation.tickTimer / Simulation.tickInterval
	CarManager.update(Simulation.worldTick, alpha)
end

--
-- draw
--

local function drawHUD()
	local cars = CarManager.getLiveCars()

	love.graphics.origin()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("cars: " .. tostring(#cars), 20, 20)
end

function Simulation.draw()
	Renderer.drawBackground()

	Simulation.camera:apply()

	Renderer.drawGrid(Simulation.camera)
	Renderer.drawWays(Simulation.map)
	-- layer badges visible in simulation too
	Renderer.drawLayerBadges(Simulation.map)

	Tunel.draw(
		Simulation.worldTick,
		Simulation.tickTimer / Simulation.tickInterval
	)

	CarManager.draw(
		Simulation.worldTick,
		Simulation.tickTimer / Simulation.tickInterval
	)

	Simulation.camera:pop()

	if Simulation.ui then
		Simulation.ui:draw()
	end

	drawHUD()
end

--
-- input
--

function Simulation.mousepressed(x, y, button)
	if Simulation.ui and Simulation.ui:mousepressed(x, y, button) then
		return
	end

	if button == 1 or button == 3 then
		Simulation.isDragging = true
	end
end

function Simulation.mousereleased(x, y, button)
	if Simulation.ui and Simulation.ui:mousereleased(x, y, button) then
		return
	end

	if button == 1 or button == 3 then
		Simulation.isDragging = false
	end
end

function Simulation.mousemoved(x, y, dx, dy)
	if Simulation.ui and Simulation.ui:mousemoved(x, y, dx, dy) then
		return
	end

	if Simulation.isDragging and Simulation.camera then
		local cam = Simulation.camera
		cam.x = cam.x - dx / cam.scale
		cam.y = cam.y - dy / cam.scale
	end
end

function Simulation.wheelmoved(x, y)
	if Simulation.ui and Simulation.ui:wheelmoved(x, y) then
		return
	end

	local mx, my = love.mouse.getPosition()

	if mx > 220 and Simulation.camera then
		Simulation.camera:zoom(y, mx, my)
	end
end

function Simulation.keypressed(key)
	if Simulation.ui and Simulation.ui:keypressed(key) then return end

	if key == "space" then
		Simulation.paused = not Simulation.paused
	end
end

--
-- state control
--

function Simulation.reset()
	Simulation.worldTick  = 1
	Simulation.tickTimer  = 0
	Simulation.spawnTimer = Simulation.spawnInterval
	Simulation.paused     = false
	CarManager.clear()
end

function Simulation.stop()
	Simulation.paused     = true
	Simulation.worldTick  = 1
	Simulation.tickTimer  = 0
	Simulation.spawnTimer = Simulation.spawnInterval
	CarManager.clear()
end

return Simulation