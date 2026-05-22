-- car.lua
--
-- simple traffic car system
--
-- api:
--   M.update(dt, level)
--       updates spawn timer and all active cars
--
--   M.draw()
--       draws all active cars
--
-- level requirements:
--   level.nodes[id] = { x = number, y = number }
--
--   level.ways = {
--       {
--           id = "WAY-ID",
--           nodeRefs = { ... },
--           tags = {
--               curve = "linear" | "bezier"
--           }
--       }
--   }
--
-- route flow:
--   route -> sampled path -> car movement along arc length
--
-- notes:
--   - bezier ways must contain exactly 4 control points
--   - movement speed is measured in pixels per second
--   - paths are pre-sampled into point lists for simplicity

local M = {}

-- 
-- bezier math
-- 

-- cubic bezier interpolation
--
-- p0/p1/p2/p3:
--   control points
--
-- t:
--   normalized parameter [0..1]
--
-- returns:
--   interpolated point { x, y }
local function cubic(p0, p1, p2, p3, t)
	local u = 1 - t

	return {
		x = u^3 * p0.x
		+ 3 * u^2 * t * p1.x
		+ 3 * u * t^2 * p2.x
		+ t^3 * p3.x,

		y = u^3 * p0.y
		+ 3 * u^2 * t * p1.y
		+ 3 * u * t^2 * p2.y
		+ t^3 * p3.y,
	}
end

-- 
-- path building
-- 

-- number of generated samples per bezier segment
local STEPS = 24

-- converts a single way into a sampled point list
--
-- supported curves:
--   linear
--   bezier
local function sampleWay(way, nodes)
	local pts = {}

	-- resolve node ids into actual node objects
	for _, id in ipairs(way.nodeRefs) do
		local node = nodes[id]

		if node then
			pts[#pts + 1] = node
		end
	end

	local out = {}

	-- straight polyline
	if way.tags.curve == "linear" then
		for _, p in ipairs(pts) do
			out[#out + 1] = p
		end

		-- cubic bezier
	elseif way.tags.curve == "bezier" and #pts == 4 then
		for i = 0, STEPS do
			out[#out + 1] = cubic(
				pts[1],
				pts[2],
				pts[3],
				pts[4],
				i / STEPS
			)
		end
	end

	return out
end

-- builds a continuous sampled path from multiple way ids
--
-- shared connection nodes are skipped to avoid duplicates
local function buildPath(wayIds, level)
	-- build quick lookup table
	local wayMap = {}

	for _, way in ipairs(level.ways) do
		wayMap[way.id] = way
	end

	local path = {}

	for i, wayId in ipairs(wayIds) do
		local way = wayMap[wayId]

		if way then
			local seg = sampleWay(way, level.nodes)

			-- skip first point for all segments except first
			-- prevents duplicate joint nodes
			local from = (i == 1) and 1 or 2

			for j = from, #seg do
				path[#path + 1] = seg[j]
			end
		end
	end

	return path
end

-- 
-- routes
-- 
--
-- route structure:
--   ENTRY -> MIDDLE -> EXIT
--
-- straight:
--   N-IN -> N-MID -> N-OUT
--
-- turns:
--   N-IN -> N-E -> W-OUT
--   etc.
--
-- naming:
--   N/S/E/W = direction
--   IN      = entry lane
--   OUT     = exit lane
--   MID     = straight crossing lane

local ROUTES = {
	-- straight
	{ "N-IN", "N-MID", "N-OUT" },
	{ "S-IN", "S-MID", "S-OUT" },
	{ "E-IN", "E-MID", "E-OUT" },
	{ "W-IN", "W-MID", "W-OUT" },

	-- right turns
	{ "N-IN", "N-E", "W-OUT" },
	{ "E-IN", "E-S", "N-OUT" },
	{ "S-IN", "S-W", "E-OUT" },
	{ "W-IN", "W-N", "S-OUT" },

	-- left turns
	{ "N-IN", "N-W", "E-OUT" },
	{ "E-IN", "E-N", "S-OUT" },
	{ "S-IN", "S-E", "W-OUT" },
	{ "W-IN", "W-S", "N-OUT" },
}

-- 
-- visuals
-- 

local COLORS = {
	{ 1.00, 0.35, 0.25 },
	{ 0.25, 0.85, 0.45 },
	{ 0.30, 0.55, 1.00 },
	{ 1.00, 0.85, 0.20 },
	{ 0.85, 0.35, 1.00 },
}

-- 
-- car class
-- 

local Car = {}
Car.__index = Car

-- creates a new car instance
--
-- path:
--   sampled path point array
--
-- color:
--   rgb table
function Car.new(path, color)
	-- cumulative arc lengths
	--
	-- dists[i]:
	--   total distance from path start to point i
	local dists = { 0 }

	for i = 2, #path do
		local dx = path[i].x - path[i - 1].x
		local dy = path[i].y - path[i - 1].y

		dists[i] = dists[i - 1] + math.sqrt(dx * dx + dy * dy)
	end

	return setmetatable({
			path  = path,
			dists = dists,

			total = dists[#dists] or 0,
			dist  = 0,

			speed = 60,
			done  = false,

			color = color,
			}, Car)
end

-- advances car along the path
function Car:update(dt)
	if self.done then
		return
	end

	self.dist = self.dist + self.speed * dt

	if self.dist >= self.total then
		self.dist = self.total
		self.done = true
	end
end

-- returns interpolated position on path
function Car:getPos()
	local path  = self.path
	local dists = self.dists
	local dist  = self.dist

	local n = #path

	if n == 0 then
		return nil
	end

	if n == 1 then
		return path[1]
	end

	-- find segment containing current distance
	for i = 2, n do
		if dists[i] >= dist then
			local segLen = dists[i] - dists[i - 1]

			-- degenerate segment
			if segLen < 1e-6 then
				return path[i]
			end

			local frac = (dist - dists[i - 1]) / segLen

			local a = path[i - 1]
			local b = path[i]

			return {
				x = a.x + (b.x - a.x) * frac,
				y = a.y + (b.y - a.y) * frac,
			}
		end
	end

	return path[n]
end

-- draws the car
function Car:draw()
	local p = self:getPos()

	if not p then
		return
	end

	-- body
	love.graphics.setColor(
		self.color[1],
		self.color[2],
		self.color[3]
	)

	love.graphics.circle("fill", p.x, p.y, 7)

	-- center detail
	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.circle("fill", p.x, p.y, 3)
end

-- 
-- module state
-- 

local cars = {}

local spawnTimer = 0
local SPAWN_INT  = 0.7

math.randomseed(os.time())

-- 
-- spawning
-- 

local function spawnCar(level)
	local route = ROUTES[math.random(#ROUTES)]

	local path = buildPath(route, level)

	if #path == 0 then
		return
	end

	local color = COLORS[math.random(#COLORS)]

	cars[#cars + 1] = Car.new(path, color)
end

-- 
-- public api
-- 

function M.update(dt, level)
	-- periodic spawning
	spawnTimer = spawnTimer + dt

	if spawnTimer >= SPAWN_INT then
		spawnTimer = spawnTimer - SPAWN_INT
		spawnCar(level)
	end

	-- update all cars
	for i = #cars, 1, -1 do
		local car = cars[i]

		car:update(dt)

		-- remove completed cars
		if car.done then
			table.remove(cars, i)
		end
	end
end

function M.draw()
	for _, car in ipairs(cars) do
		car:draw()
	end
end

return M