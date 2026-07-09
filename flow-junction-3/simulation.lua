-- simulation.lua
-- scene context: physics steps, traffic ticks, path binding

local Camera     = require("core.camera")
local Renderer   = require("core.renderer")
local Map        = require("core.map")
local UIHub      = require("ui.ui")
local Tunel      = require("simulation.tunel")
local CarManager = require("simulation.car-manager")
local Counter    = require("simulation.counter")

local Simulation = {}

Simulation.camera = nil
Simulation.map    = nil
Simulation.ui     = nil
Simulation.app    = nil

Simulation.paused      = false
Simulation.showUI      = true
Simulation.spawnEnabled = true
Simulation.speed  = 1

Simulation.worldTick     = 1
Simulation.spawnInterval = 0.2
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

--	Simulation.spawnInterval = 0.5
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

	-- copy background image meta (image object is shared, not deep-copied)
	local m = editorMap.meta or {}
	Simulation.map.meta = {
		bgFile    = m.bgFile,
		bgImage   = m.bgImage,
		bgScale   = m.bgScale   or 1.0,
		bgOffsetX = m.bgOffsetX or 0,
		bgOffsetY = m.bgOffsetY or 0,
	}

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
						from  = w.tags.from  or nil,
						name  = w.tags.name  or nil,
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
	Counter.build(Simulation.map)

	Simulation.camera:fitAll(Simulation.map)
end

--
-- update
--

function Simulation.update(dt)
	Simulation._lastDt = dt

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
	if Simulation.spawnEnabled then
		while Simulation.spawnTimer >= Simulation.spawnInterval do
			Simulation.spawnTimer = Simulation.spawnTimer - Simulation.spawnInterval
			local ok = CarManager.spawnCar(Simulation.map, Simulation.worldTick)
			if not ok then
				Simulation.spawnTimer = 0
				break
			end
		end
	else
		Simulation.spawnTimer = 0
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

	Renderer.drawBgImage(Simulation.map)
	if Renderer.showGrid then Renderer.drawGrid(Simulation.camera) end
	if Renderer.showWays then
		Renderer.drawWays(Simulation.map)
		-- layer badges visible in simulation too
		Renderer.drawLayerBadges(Simulation.map)
	end

	Tunel.draw(
		Simulation.worldTick,
		Simulation.tickTimer / Simulation.tickInterval
	)

	CarManager.draw(
		Simulation.worldTick,
		Simulation.tickTimer / Simulation.tickInterval,
		Simulation._lastDt
	)

	Simulation.camera:pop()

	Simulation.drawStats()

	if Simulation.ui and Simulation.showUI then
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

local STATS_LH  = 18
local STATS_PAD = 10
local STATS_LCW = 60
local STATS_VCW = 60

local function drawStatsRow(ox, cy, label, val, highlight, w)
	if highlight then
		love.graphics.setColor(0.25, 0.35, 0.45, 0.7)
		love.graphics.rectangle("fill", ox + 2, cy - 1, w - 4, STATS_LH)
		love.graphics.setColor(1, 1, 1, 1)
	else
		love.graphics.setColor(0.8, 0.9, 1.0, 0.9)
	end
	love.graphics.print(label, ox + STATS_PAD, cy)
	if val then
		love.graphics.print(string.format("%.1f", val), ox + STATS_PAD + STATS_LCW, cy)
	end
	return cy + STATS_LH
end

local function drawStatsHeader(ox, cy, label)
	love.graphics.setColor(0.5, 0.7, 1.0, 1)
	love.graphics.print(label, ox + STATS_PAD, cy)
	love.graphics.print("/min", ox + STATS_PAD + STATS_LCW, cy)
	return cy + STATS_LH
end

function Simulation.drawStats()
	local simTime = Simulation.worldTick * Simulation.tickInterval
	local inRows, outRows, inTotal, outTotal = Counter.getStats(simTime)
	if #inRows == 0 and #outRows == 0 then return end

	local w     = STATS_LCW + STATS_VCW + STATS_PAD * 2
	local nRows = 2 + #inRows + 1 + 1 + 2 + #outRows + 1
	local h     = STATS_PAD * 2 + nRows * STATS_LH
	local ox    = love.graphics.getWidth() - w - 10
	local oy    = 10

	love.graphics.setColor(0, 0, 0, 0.6)
	love.graphics.rectangle("fill", ox, oy, w, h, 6, 6)
	love.graphics.setColor(0.4, 0.5, 0.6, 0.8)
	love.graphics.rectangle("line", ox, oy, w, h, 6, 6)

	local cy = oy + STATS_PAD

	cy = drawStatsHeader(ox, cy, "In")
	for _, r in ipairs(inRows) do
		cy = drawStatsRow(ox, cy, r.label, r.cpm, false, w)
	end
	cy = drawStatsRow(ox, cy, "Total", inTotal, true, w)

	cy = cy + STATS_LH

	cy = drawStatsHeader(ox, cy, "Out")
	for _, r in ipairs(outRows) do
		cy = drawStatsRow(ox, cy, r.label, r.cpm, false, w)
	end
	cy = drawStatsRow(ox, cy, "Total", outTotal, true, w)

	love.graphics.setColor(1, 1, 1, 1)
end

function Simulation.keypressed(key)
	if Simulation.ui and Simulation.ui:keypressed(key) then return end

	if key == "space" then
		Simulation.paused = not Simulation.paused
	elseif key == "n" then
		Simulation.showUI = not Simulation.showUI
	elseif key == "q" then
		Simulation.spawnEnabled = not Simulation.spawnEnabled
		print("spawn: " .. (Simulation.spawnEnabled and "on" or "off"))
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