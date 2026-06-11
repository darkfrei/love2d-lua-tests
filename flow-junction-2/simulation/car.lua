-- simulation/car.lua
-- car entity with space-time conflict avoidance

local Tunel = require("simulation.tunel")

local Car = {}
Car.__index = Car

-- constants for car movement and simulation timing

local RADIUS     = 20
local MAX_SPEED  = 200    -- pixels per second
local MIN_SPEED  = 150     -- pixels per second
local MAX_ACCEL  = 60     -- pixels per second per second
local MAX_BRAKE  = 60    -- pixels per second per second
local TICK_RATE  = 0.1    -- will be overwritten via setTickRate
local SAFE_DIST2 = (RADIUS * 2 + 2) ^ 2

function Car.setTickRate(rate)
	TICK_RATE = rate
end

local COLORS = {
	{ 1.00, 0.35, 0.25 },
	{ 0.25, 0.85, 0.45 },
	{ 0.30, 0.55, 1.00 },
	{ 1.00, 0.85, 0.20 },
	{ 0.85, 0.35, 1.00 },
	{ 0.15, 0.85, 0.95 },
	{ 1.00, 0.55, 0.10 },
	{ 0.60, 0.90, 0.20 },
	{ 1.00, 0.40, 0.70 },
	{ 0.40, 0.25, 0.95 },
}
local colorIndex = 0

-- zone check

local function checkPointInZones(x, y)
	local zones = Tunel.getZones()
	for _, verts in ipairs(zones) do
		local inside = false
		local n = #verts / 2
		local j = n
		for i = 1, n do
			local xi = verts[i * 2 - 1]
			local yi = verts[i * 2]
			local xj = verts[j * 2 - 1]
			local yj = verts[j * 2]
			if ((yi > y) ~= (yj > y))
			and (x < (xj - xi) * (y - yi) / (yj - yi + 1e-12) + xi) then
				inside = not inside
			end
			j = i
		end
		if inside then return true end
	end
	return false
end

-- bezier sampling for curve path handling

local function cubicBezier(p0, p1, p2, p3, t)
	local u = 1 - t
	return {
		x = u^3*p0.x + 3*u^2*t*p1.x + 3*u*t^2*p2.x + t^3*p3.x,
		y = u^3*p0.y + 3*u^2*t*p1.y + 3*u*t^2*p2.y + t^3*p3.y,
	}
end

local BEZIER_STEPS = 24

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
			out[#out + 1] = cubicBezier(pts[1], pts[2], pts[3], pts[4], i / BEZIER_STEPS)
		end
		return out
	else
		return pts
	end
end

-- constructor

function Car.new(id, pathPoints, segments, route, color, spawnTick, layer)

	local dists = { 0 }
	for i = 2, #pathPoints do
		local dx = pathPoints[i].x - pathPoints[i - 1].x
		local dy = pathPoints[i].y - pathPoints[i - 1].y
		dists[i] = dists[i - 1] + math.sqrt(dx * dx + dy * dy)
	end

	colorIndex = (colorIndex % #COLORS) + 1

	local self = setmetatable({
			id              = id,
			pathPoints      = pathPoints,
			segments        = segments,
			route           = route,
			dists           = dists,
			total           = dists[#dists] or 0,
			realSpawnTick   = spawnTick,
			spawnTick       = spawnTick,
			endTick         = spawnTick,
			done            = false,
			color           = COLORS[colorIndex],
			trajectory      = {},
			spawnDelayTicks = 0,
			layer           = layer or 0,
			}, Car)

	self:bakeTrajectory()
	return self
end

-- geometry

function Car:getPosAtDist(d)
	local path  = self.pathPoints
	local dists = self.dists
	local n     = #path

	if n == 0 then return nil end
	if n == 1 then return path[1] end

	d = math.max(0, math.min(d, self.total))

	for i = 2, n do
		if dists[i] >= d then
			local segLen = dists[i] - dists[i - 1]
			if segLen < 1e-6 then return path[i] end
			local frac = (d - dists[i - 1]) / segLen
			return {
				x = path[i - 1].x + (path[i].x - path[i - 1].x) * frac,
				y = path[i - 1].y + (path[i].y - path[i - 1].y) * frac,
			}
		end
	end

	return path[n]
end

function Car:getPosAtTick(tick)
	return self.trajectory[tick]
end

function Car:getPos(worldTick, alpha)
	if not worldTick then return nil end
	alpha = alpha or 0

	local p = self:getPosAtTick(worldTick)
	local nx = self:getPosAtTick(worldTick + 1)

	if not p then return nil end
	if not nx then return p end

	return {
		x = p.x + (nx.x - p.x) * alpha,
		y = p.y + (nx.y - p.y) * alpha,
	}
end

-- conflict detection

function Car:scanTunnelSegments()
	local segments    = {}
	local step        = MAX_SPEED * TICK_RATE
	local currentDist = 0
	local segStart    = 0

	local pStart       = self:getPosAtDist(0)
	local prevInTunnel = pStart and checkPointInZones(pStart.x, pStart.y) or false

	while currentDist < self.total do
		currentDist = math.min(currentDist + step, self.total)
		local p = self:getPosAtDist(currentDist)

		if p then
			local inTunnel = checkPointInZones(p.x, p.y)

			if inTunnel ~= prevInTunnel or currentDist >= self.total then
				segments[#segments + 1] = {
					inTunnel  = prevInTunnel,
					startDist = segStart,
					endDist   = currentDist,
					length    = currentDist - segStart,
				}
				segStart     = currentDist
				prevInTunnel = inTunnel
			end
		end
	end

	return segments
end

function Car:hasTunnelConflict(startTick, startDist, endDist)
	local tick    = startTick
	local simDist = startDist

	while simDist < endDist do
		local pos = self:getPosAtDist(simDist)
		if not pos then return true end

		if Tunel.isSlotOccupied(tick, self, pos) then
			return true
		end

		simDist = simDist + MAX_SPEED * TICK_RATE
		tick    = tick + 1
	end

	return false
end

function Car:hasLeadingCarConflict(tick, pos)
	local allCars = require("simulation.car-manager").getLiveCars()

	for _, other in ipairs(allCars) do
		-- cars on different layers are physically separated, skip
		if other ~= self and (other.layer or 0) == (self.layer or 0) then
			local otherPos = other:getPosAtTick(tick)
			if otherPos then
				local dx = otherPos.x - pos.x
				local dy = otherPos.y - pos.y
				if dx*dx + dy*dy < SAFE_DIST2 then
					return true
				end
			end
		end
	end

	return false
end

-- smooth speed profile helpers

-- builds position samples over time for a segment using a cosine speed profile
local function buildSmoothSegment(car, startDist, segLength, startTick, nominalSteps, requiredSteps)
	local result = {}

	if requiredSteps <= nominalSteps then
		-- constant max speed, no interpolation needed
		for step = 0, requiredSteps - 1 do
			local dist = math.min(
				startDist + step * MAX_SPEED * TICK_RATE,
				startDist + segLength
			)
			local pos = car:getPosAtDist(dist)
			if pos then
				result[startTick + step] = pos
			end
		end
	else
		-- stretched movement using cosine speed profile
		local T    = requiredSteps * TICK_RATE
		local vAvg = segLength / T

		local A = math.min(MAX_SPEED - vAvg, vAvg - MIN_SPEED)
		A = math.max(A, 0)

		local function distAtStep(s)
			local t = s * TICK_RATE
			return vAvg * t + (A * T) / (2 * math.pi) * math.sin((2 * math.pi * t) / T)
		end

		for step = 0, requiredSteps - 1 do
			local dist = math.min(startDist + distAtStep(step), startDist + segLength)
			local pos  = car:getPosAtDist(dist)
			if pos then
				result[startTick + step] = pos
			end
		end
	end

	return result
end

-- trajectory baking

function Car:bakeTrajectory()
	-- cars on elevated or underground layers have no conflict zones with ground traffic
	-- skip the entire tunnel scheduling and go straight to simple trajectory
	if (self.layer or 0) ~= 0 then
		self:buildSimpleTrajectory()
		return
	end

	local MAX_ATTEMPTS = 300

	for attempt = 1, MAX_ATTEMPTS do

		local tunSegments = self:scanTunnelSegments()

		if #tunSegments == 0 then
			self:buildSimpleTrajectory()
			return
		end

		local currentTick    = self.realSpawnTick + self.spawnDelayTicks
		self.spawnTick       = currentTick
		local tempTrajectory = {}
		local failed         = false
		local extraDelay     = 0

		for idx, seg in ipairs(tunSegments) do

			if failed then break end

			if seg.inTunnel then

				if self:hasTunnelConflict(currentTick, seg.startDist, seg.endDist) then
					extraDelay = 2
					failed     = true
					break
				end

				local steps = math.max(1, math.ceil(seg.length / (MAX_SPEED * TICK_RATE)))
				local pts   = buildSmoothSegment(self, seg.startDist, seg.length, currentTick, steps, steps)

				for tick, pos in pairs(pts) do
					if self:hasLeadingCarConflict(tick, pos) then
						extraDelay = 2
						failed     = true
						break
					end
					tempTrajectory[tick] = pos
				end

				if not failed then
					currentTick = currentTick + steps
				end

			else
				local nextTunnel    = tunSegments[idx + 1]
				local nominalSteps  = math.max(1, math.ceil(seg.length / (MAX_SPEED * TICK_RATE)))
				local requiredSteps = nominalSteps

				if nextTunnel and nextTunnel.inTunnel then
					local arrivalTick = currentTick + nominalSteps
					local wait = 0

					while wait < 500 do
						if not self:hasTunnelConflict(
							arrivalTick + wait,
							nextTunnel.startDist,
							nextTunnel.endDist
							) then break end
						wait = wait + 2
					end

					requiredSteps = nominalSteps + wait
				end

				local maxPossibleSteps = math.ceil(seg.length / (MIN_SPEED * TICK_RATE))

				if requiredSteps > maxPossibleSteps then
					extraDelay = requiredSteps - maxPossibleSteps
					failed     = true
					break
				end

				local pts = buildSmoothSegment(
					self, seg.startDist, seg.length,
					currentTick, nominalSteps, requiredSteps
				)

				for tick, pos in pairs(pts) do
					if self:hasLeadingCarConflict(tick, pos) then
						extraDelay = 2
						failed     = true
						break
					end
					tempTrajectory[tick] = pos
				end

				if not failed then
					currentTick = currentTick + requiredSteps
				end
			end
		end

		if not failed then
			self.trajectory = tempTrajectory
			self.endTick    = currentTick

			for t, p in pairs(self.trajectory) do
				if checkPointInZones(p.x, p.y) then
					Tunel.registerCarAtTick(t, self)
				end
			end
			return
		end

		self.spawnDelayTicks = self.spawnDelayTicks + extraDelay
	end

	self:buildSimpleTrajectory()
end

function Car:buildSimpleTrajectory()
	local totalTicks = math.ceil(self.total / (MAX_SPEED * TICK_RATE))
	for i = 0, totalTicks do
		local dist = math.min(i * MAX_SPEED * TICK_RATE, self.total)
		local pos  = self:getPosAtDist(dist)
		if pos then
			self.trajectory[self.realSpawnTick + i] = pos
		end
	end
	self.endTick = self.realSpawnTick + totalTicks
end

function Car:update(worldTick)
	local p = self:getPosAtTick(worldTick)
	if not p then return end
	self.x = p.x
	self.y = p.y
end

function Car:checkFinished(worldTick)
	if self.done then return true end
	if worldTick >= self.endTick then
		self.done = true
		return true
	end
	return false
end

function Car:draw(worldTick, alpha)
	local p = self:getPos(worldTick, alpha)
	if not p then return end

	love.graphics.setColor(self.color[1], self.color[2], self.color[3])
	love.graphics.circle("fill", p.x, p.y, RADIUS)

	love.graphics.setColor(1, 1, 1, 0.9)
	love.graphics.setLineWidth(1.5)
	love.graphics.circle("line", p.x, p.y, RADIUS)

	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.circle("fill", p.x, p.y, 8)
end

return Car