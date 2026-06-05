-- simulation/car-manager.lua
-- single authority for all cars
-- handles spawning, updating, rendering, routing and storage

local Car   = require("simulation.car")
local Graph = require("simulation.graph")
local Spawn = require("simulation.spawn")

local M = {}

local cars      = {}
local idCounter = 0

-- lifecycle
-- ---------------------------------------------------------

function M.setTickRate(rate)
	Car.setTickRate(rate)
end

function M.syncMap(map)
	Graph.build(map)
end

-- path builder
-- ---------------------------------------------------------

local BEZIER_STEPS = 24

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

	if curve == "bezier" and #pts == 4 then
		local out = {}
		for i = 0, BEZIER_STEPS do
			out[#out + 1] = cubicBezier(
				pts[1], pts[2], pts[3], pts[4],
				i / BEZIER_STEPS
			)
		end
		return out
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
	local wayIndex = {}
	for _, w in ipairs(level.ways) do
		wayIndex[w.id] = w
	end

	local pathPoints = {}
	local segments   = {}

	for i, wayId in ipairs(route) do
		local way = wayIndex[wayId]

		if way then
			local pts = sampleWay(way, level.nodes)

			if i > 1 and #pts > 0 and #pathPoints > 0 then
				local last = pathPoints[#pathPoints]
				if math.abs(last.x - pts[1].x) < 0.01
				and math.abs(last.y - pts[1].y) < 0.01 then
					table.remove(pts, 1)
				end
			end

			segments[#segments + 1] = {
				wayId  = wayId,
				length = computeLen(pts),
				points = pts,
			}

			for _, p in ipairs(pts) do
				pathPoints[#pathPoints + 1] = p
			end
		else
			-- way not found in level graph
		end
	end

	return pathPoints, segments
end

-- spawn
-- ---------------------------------------------------------

function M.spawnCar(map, tick)
	local route = Spawn.spawnRoute(map)

	if not route or #route == 0 then return end

	local pathPoints, segments = buildPath(route, map)

	if #pathPoints == 0 then return end

	idCounter = idCounter + 1

	local car = Car.new(
		idCounter,
		pathPoints,
		segments,
		route,
		nil,
		tick
	)

	cars[#cars + 1] = car
end

-- update
-- ---------------------------------------------------------

function M.update(worldTick, alpha)
	for i = #cars, 1, -1 do
		local c = cars[i]
		c:update(worldTick)
		if c:checkFinished(worldTick) then
			table.remove(cars, i)
		end
	end
end

-- draw
-- ---------------------------------------------------------

function M.draw(worldTick, alpha)
	for _, c in ipairs(cars) do
		c:draw(worldTick, alpha)
	end
end

-- query
-- ---------------------------------------------------------

function M.getLiveCars()
	return cars
end

function M.setTickRate(rate)
	Car.setTickRate(rate)
end

function M.clear()
	cars      = {}
	idCounter = 0
	Car.setTickRate(0.1)
end

return M