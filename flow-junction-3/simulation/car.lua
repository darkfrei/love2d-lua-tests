-- simulation/car.lua
-- car entity with space-time conflict avoidance

local Tunel = require("simulation.tunel")

-- lazy require to avoid circular dependency (car-manager requires car)
local _carManager
local function getCarManager()
	if not _carManager then
		_carManager = require("simulation.car-manager")
	end
	return _carManager
end

local Car = {}
Car.__index = Car

-- constants for car movement and simulation timing

local RADIUS     = 20
local MAX_SPEED  = 120    -- pixels per second
local MIN_SPEED  = 80     -- pixels per second
local MAX_ACCEL  = 60     -- pixels per second per second
local MAX_BRAKE  = 60    -- pixels per second per second
local TICK_RATE  = 0.1    -- will be overwritten via setTickRate
local SAFE_DIST2 = (RADIUS * 2 + 2) ^ 2

local SPRITE_SCALE_FACTOR = 0.5

-- optional sprite: car_base.png + car_mask.png in project root
-- if missing, falls back to rectangle + arrow
local _spriteBase, _spriteMask, _spriteOX, _spriteOY, _spriteScale
do
	local ok, base = pcall(love.graphics.newImage, "car_base.png")
	if ok then
		local ok2, mask = pcall(love.graphics.newImage, "car_mask.png")
		if ok2 then
			_spriteBase  = base
			_spriteMask  = mask
			_spriteOX    = base:getWidth()  / 2
			_spriteOY    = base:getHeight() / 2
			_spriteScale = (RADIUS * 2) / base:getWidth()
		else
			print("[car] mask load failed: " .. tostring(mask))
		end
	else
		print("[car] base load failed: " .. tostring(base))
	end
end

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

local function sampleWay(way, nodes)
	local pts = {}
	for _, id in ipairs(way.nodeRefs) do
		local node = nodes[id]
		if node then pts[#pts + 1] = node end
	end

	local curve = way.tags and way.tags.curve or "linear"

	if curve == "bezier" and #pts == 4 then
		local steps = math.max(4, math.ceil(bezierControlLen(pts) / SIM_PX_PER_STEP))
		local out   = {}
		for i = 0, steps do
			out[#out + 1] = cubicBezier(pts[1], pts[2], pts[3], pts[4], i / steps)
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
	local allCars = getCarManager().getLiveCars()
	local myLayer = self.layer or 0
	-- coarse search radius slightly larger than the safe distance,
	-- used as a cheap bounding-box rejection before the exact distance check
	local searchR = math.sqrt(SAFE_DIST2)

	for _, other in ipairs(allCars) do
		-- cars on different layers are physically separated, skip
		if other ~= self and (other.layer or 0) == myLayer then
			local otherPos = other:getPosAtTick(tick)
			if otherPos then
				local dx = otherPos.x - pos.x
				-- cheap axis-aligned rejection before computing dy/sqrt
				if dx > -searchR and dx < searchR then
					local dy = otherPos.y - pos.y
					if dy > -searchR and dy < searchR then
						if dx*dx + dy*dy < SAFE_DIST2 then
							return true
						end
					end
				end
			end
		end
	end

	return false
end

-- smooth speed profile helpers

local function buildSmoothSegment(car, startDist, segLength, startTick, nominalSteps, requiredSteps)
	local result = {}

	if requiredSteps <= nominalSteps then
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
	if worldTick >= self.endTick - 1 then
		self.done = true
		return true
	end
	return false
end

function Car:draw(worldTick, alpha, dt)
	local p = self:getPos(worldTick, alpha)
	if not p then return end

	-- immediate heading from the current tick's neighbouring samples
	local function headingAt(tick)
		local a = self:getPosAtTick(tick)
		local b = self:getPosAtTick(tick + 1)
		if a and b and (a.x ~= b.x or a.y ~= b.y) then
			return math.atan2(b.y - a.y, b.x - a.x) + math.pi / 2
		end
		local pa = self:getPosAtTick(tick - 1)
		if a and pa and (a.x ~= pa.x or a.y ~= pa.y) then
			return math.atan2(a.y - pa.y, a.x - pa.x) + math.pi / 2
		end
		return nil
	end

	local a0 = headingAt(worldTick)
	local a1 = headingAt(worldTick + 1)

	local rawAngle
	if a0 and a1 then
		local diff = a1 - a0
		diff = diff - math.floor((diff + math.pi) / (2 * math.pi)) * (2 * math.pi)
		rawAngle = a0 + diff * (alpha or 0)
	elseif a0 then
		rawAngle = a0
	elseif a1 then
		rawAngle = a1
	else
		rawAngle = self._drawAngle or 0
	end

	-- steering lag: smooth the displayed angle toward the raw target instead of
	-- snapping to it, so direction changes feel slightly delayed rather than
	-- instant or anticipated. Falls back to a fixed per-frame smoothing factor
	-- if dt isn't supplied by the caller.
	local STEER_SMOOTH_TIME = 0.12  -- seconds to close ~63% of the angle gap
	local frameDt = dt or (1 / 60)

	if self._drawAngle == nil then
		self._drawAngle = rawAngle
	else
		local diff = rawAngle - self._drawAngle
		diff = diff - math.floor((diff + math.pi) / (2 * math.pi)) * (2 * math.pi)
		local k = 1 - math.exp(-frameDt / STEER_SMOOTH_TIME)
		self._drawAngle = self._drawAngle + diff * k
	end

	local angle = self._drawAngle


	if _spriteBase then
		local cr, cg, cb = self.color[1], self.color[2], self.color[3]
		local s = _spriteScale * SPRITE_SCALE_FACTOR
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(_spriteBase, p.x, p.y, angle, s, s, _spriteOX, _spriteOY)
		love.graphics.setColor(cr, cg, cb, 1)
		love.graphics.draw(_spriteMask, p.x, p.y, angle, s, s, _spriteOX, _spriteOY)
	else
		local hw, hh = RADIUS * 0.7, RADIUS
		love.graphics.push()
		love.graphics.translate(p.x, p.y)
		love.graphics.rotate(angle)
		love.graphics.setColor(self.color[1], self.color[2], self.color[3])
		love.graphics.rectangle("fill", -hw, -hh, hw * 2, hh * 2, 3, 3)
		love.graphics.setColor(1, 1, 1, 0.85)
		love.graphics.setLineWidth(1.5)
		love.graphics.rectangle("line", -hw, -hh, hw * 2, hh * 2, 3, 3)
		love.graphics.polygon("fill",
			0, -hh + 4,
			-hw * 0.5, -hh * 0.35,
			hw * 0.5, -hh * 0.35
		)
		love.graphics.pop()
		love.graphics.setColor(1, 1, 1, 1)
	end
end

return Car