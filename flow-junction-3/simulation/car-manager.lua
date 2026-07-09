-- simulation/car-manager.lua
-- single authority for all cars
-- handles spawning, updating, rendering, routing and storage

local Car   = require("simulation.car")
local Graph = require("simulation.graph")
local Spawn   = require("simulation.spawn")
local Counter = require("simulation.counter")

local M = {}

local cars      = {}
local idCounter = 0

-- lifecycle

local _tickRate = 0.1

function M.setTickRate(rate)
	_tickRate = rate
	Car.setTickRate(rate)
end

function M.syncMap(map)
	Graph.build(map)
end

-- path builder

-- pixels per simulation step: one sample per tick distance
local SIM_PX_PER_STEP = 12

local function bezierControlLen(pts)
	local len = 0
	for i = 2, #pts do
		local dx = pts[i].x - pts[i-1].x
		local dy = pts[i].y - pts[i-1].y
		len = len + math.sqrt(dx*dx + dy*dy)
	end
	return len
end

local function adaptiveSteps(pts)
	return math.max(4, math.ceil(bezierControlLen(pts) / SIM_PX_PER_STEP))
end

local function quadraticBezier(p0, p1, p2, t)
	local u = 1 - t
	return {
		x = u*u*p0.x + 2*u*t*p1.x + t*t*p2.x,
		y = u*u*p0.y + 2*u*t*p1.y + t*t*p2.y,
	}
end

local function cubicBezier(p0, p1, p2, p3, t)
	local u = 1 - t
	return {
		x = u^3*p0.x + 3*u^2*t*p1.x + 3*u*t^2*p2.x + t^3*p3.x,
		y = u^3*p0.y + 3*u^2*t*p1.y + 3*u*t^2*p2.y + t^3*p3.y,
	}
end

local function sampleWay(way, nodes)
	local pts = {}
	for _, id in ipairs(way.nodeRefs) do
		local node = nodes[id]
		if node then pts[#pts + 1] = node end
	end

	local curve = way.tags and way.tags.curve or "linear"

	if curve == "bezier" then
		local out   = {}
		local steps = adaptiveSteps(pts)
		if #pts == 3 then
			for i = 0, steps do
				out[#out + 1] = quadraticBezier(pts[1], pts[2], pts[3], i / steps)
			end
			return out
		elseif #pts == 4 then
			for i = 0, steps do
				out[#out + 1] = cubicBezier(pts[1], pts[2], pts[3], pts[4], i / steps)
			end
			return out
		end
	end

	return pts
end

local function computeLen(points)
	local len = 0
	for i = 2, #points do
		local dx = points[i].x - points[i - 1].x
		local dy = points[i].y - points[i - 1].y
		len = len + math.sqrt(dx * dx + dy * dy)
	end
	return len
end

local function buildPath(route, level)
	-- route is now a list of array indices into level.ways
	local pathPoints = {}
	local segments   = {}

	for i, wayIdx in ipairs(route) do
		local way = level.ways[wayIdx]

		if way then
			local pts = sampleWay(way, level.nodes)

			-- remove duplicate junction point shared with previous way
			if i > 1 and #pts > 0 and #pathPoints > 0 then
				local last = pathPoints[#pathPoints]
				if math.abs(last.x - pts[1].x) < 1.0
				and math.abs(last.y - pts[1].y) < 1.0 then
					table.remove(pts, 1)
				end
			end

			segments[#segments + 1] = {
				wayIdx = wayIdx,
				length = computeLen(pts),
				points = pts,
			}

			for _, p in ipairs(pts) do
				pathPoints[#pathPoints + 1] = p
			end
		end
	end

	return pathPoints, segments
end

-- spawn

function M.spawnCar(map, tick)
	local route = Spawn.spawnRoute(map)

	if not route or #route == 0 then return false end

	local pathPoints, segments = buildPath(route, map)

	if #pathPoints == 0 then return false end

	idCounter = idCounter + 1

	-- use max absolute layer across route for collision grouping
	-- so a car that passes over a bridge is treated as bridge traffic
	local firstWayLayer = 0
	for _, wayIdx in ipairs(route) do
		local w = map.ways[wayIdx]
		if w and w.tags then
			local l = math.abs(tonumber(w.tags.layer) or 0)
			if l > math.abs(firstWayLayer) then
				firstWayLayer = tonumber(w.tags.layer) or 0
			end
		end
	end

	local car = Car.new(
		idCounter,
		pathPoints,
		segments,
		route,
		nil,
		tick,
		firstWayLayer
	)

	cars[#cars + 1] = car
	if #route > 0 then Counter.onSpawn(route[1], tick * _tickRate) end
	return true
end

-- update

function M.update(worldTick, alpha)
	for i = #cars, 1, -1 do
		local c = cars[i]
		c:update(worldTick)
		if c:checkFinished(worldTick) then
			if c.route and #c.route > 0 then
				Counter.onDespawn(c.route[#c.route], worldTick * _tickRate)
			end
			table.remove(cars, i)
		end
	end
end

-- draw

function M.draw(worldTick, alpha, dt)
	for _, c in ipairs(cars) do
		c:draw(worldTick, alpha, dt)
	end
end

-- query

function M.getLiveCars()
	return cars
end

function M.clear()
	cars      = {}
	idCounter = 0
	Car.setTickRate(0.1)
end

return M