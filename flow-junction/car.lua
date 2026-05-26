-- car.lua
-- Проактивный пространственно-временной планировщик.
-- Гарантирует строго положительную скорость движения, плавный профиль S-кривой
-- на открытых участках и монотонную константную MAX_SPEED внутри туннелей.

local M = {}

local tunel = require("tunel")

-- constants -----------------------------------------------------------------
local RADIUS    = 20
local MAX_SPEED = 60
local MIN_SPEED = 20   -- Безопасный предел: машина никогда не остановится и не поедет назад
local tickRate  = 0.1

local SAFE_FOLLOW_DIST = (RADIUS * 3) ^ 2   -- squared safe distance

-- helper functions ---------------------------------------------------------
local function cubic(p0, p1, p2, p3, t)
	local u = 1 - t
	return {
		x = u^3*p0.x + 3*u^2*t*p1.x + 3*u*t^2*p2.x + t^3*p3.x,
		y = u^3*p0.y + 3*u^2*t*p1.y + 3*u*t^2*p2.y + t^3*p3.y,
	}
end

local function computePathLength(points)
	local len = 0
	for i = 2, #points do
		local dx = points[i].x - points[i-1].x
		local dy = points[i].y - points[i-1].y
		len = len + math.sqrt(dx*dx + dy*dy)
	end
	return len
end

local STEPS = 24

local function sampleWay(way, nodes)
	local pts = {}
	for _, id in ipairs(way.nodeRefs) do
		local node = nodes[id]
		if node then pts[#pts + 1] = node end
	end

	local out = {}
	if way.tags.curve == "linear" then
		for _, p in ipairs(pts) do out[#out + 1] = p end
	elseif way.tags.curve == "bezier" and #pts == 4 then
		for i = 0, STEPS do
			out[#out + 1] = cubic(pts[1], pts[2], pts[3], pts[4], i / STEPS)
		end
	end
	return out
end

local function buildPathWithSegments(wayIds, level)
	local wayMap = {}
	for _, way in ipairs(level.ways) do
		wayMap[way.id] = way
	end

	local pathPoints = {}
	local segments = {}

	for i, wayId in ipairs(wayIds) do
		local way = wayMap[wayId]
		if way then
			local pts = sampleWay(way, level.nodes)

			if i > 1 and #pts > 0 and #pathPoints > 0 then
				local last = pathPoints[#pathPoints]
				local first = pts[1]
				if last.x == first.x and last.y == first.y then
					table.remove(pts, 1)
				end
			end

			local segLen = computePathLength(pts)

			table.insert(segments, {
					wayId = wayId,
					length = segLen,
					points = pts
				})

			for _, p in ipairs(pts) do
				pathPoints[#pathPoints + 1] = p
			end
		end
	end

	return pathPoints, segments
end

-- routes -------------------------------------------------------------------
local ROUTES = {
	{ "N-IN", "N-MID", "N-OUT" },
	{ "S-IN", "S-MID", "S-OUT" },
	{ "E-IN", "E-MID", "E-OUT" },
	{ "W-IN", "W-MID", "W-OUT" },
	{ "N-IN", "N-E", "W-OUT" },
	{ "E-IN", "E-S", "N-OUT" },
	{ "S-IN", "S-W", "E-OUT" },
	{ "W-IN", "W-N", "S-OUT" },
	{ "N-IN", "N-W", "E-OUT" },
	{ "E-IN", "E-N", "S-OUT" },
	{ "S-IN", "S-E", "W-OUT" },
	{ "W-IN", "W-S", "N-OUT" },
}

local COLORS = {
	{ 1.00, 0.35, 0.25 },
	{ 0.25, 0.85, 0.45 },
	{ 0.30, 0.55, 1.00 },
	{ 1.00, 0.85, 0.20 },
	{ 0.85, 0.35, 1.00 },
}

function M.checkPointInZones(x, y)
	local zones = tunel.getZones()
	for _, verts in ipairs(zones) do
		local inside = false
		local n = #verts / 2
		local j = n

		for i = 1, n do
			local xi = verts[i*2-1]
			local yi = verts[i*2]
			local xj = verts[j*2-1]
			local yj = verts[j*2]

			if ((yi > y) ~= (yj > y)) and
			(x < (xj - xi) * (y - yi) / (yj - yi + 1e-12) + xi) then
				inside = not inside
			end

			j = i
		end

		if inside then return true end
	end
	return false
end

-- car class ----------------------------------------------------------------
local Car = {}
Car.__index = Car

function Car.new(pathPoints, segments, wayIds, color, spawnTick)
	local dists = { 0 }
	for i = 2, #pathPoints do
		local dx = pathPoints[i].x - pathPoints[i-1].x
		local dy = pathPoints[i].y - pathPoints[i-1].y
		dists[i] = dists[i-1] + math.sqrt(dx*dx + dy*dy)
	end

	local car = setmetatable({
			pathPoints      = pathPoints,
			segments        = segments,
			wayIds          = wayIds,
			dists           = dists,
			total           = dists[#dists] or 0,

			realSpawnTick   = spawnTick,
			spawnTick       = spawnTick,
			endTick         = spawnTick,
			done            = false,
			color           = color,

			trajectory      = {},
			spawnDelayTicks = 0,
			}, Car)

	car:bakeTrajectory()
	return car
end

function Car:scanTunnelSegments()
	local segments = {}
	local step = 1.0
	local currentDist = 0
	local segStart = 0
	local prevInTunnel = false

	local pStart = self:getPosAtDist(0)
	if pStart then
		prevInTunnel = M.checkPointInZones(pStart.x, pStart.y)
	end

	while currentDist < self.total do
		currentDist = math.min(currentDist + step, self.total)
		local p = self:getPosAtDist(currentDist)

		if p then
			local inTunnel = M.checkPointInZones(p.x, p.y)
			if inTunnel ~= prevInTunnel or currentDist == self.total then
				table.insert(segments, {
						inTunnel = prevInTunnel,
						startDist = segStart,
						endDist = currentDist,
						length = currentDist - segStart
					})
				segStart = currentDist
				prevInTunnel = inTunnel
			end
		end
	end

	return segments
end

-- Проверка конфликтов на номинальной максимальной скорости
function Car:hasTunnelConflict(startTick, startDist, endDist)
	local tick = startTick
	local simDist = startDist

	while simDist <= endDist - 1e-6 do
		local pos = self:getPosAtDist(simDist)
		if not pos then return true end

		if tunel.isSlotOccupied(tick, self, pos) then
			return true
		end

		simDist = simDist + MAX_SPEED * tickRate
		tick = tick + 1
	end
	return false
end

-- Проверка на дистанцию до идущих впереди машин (избегание столкновений на хвосте)
function Car:hasLongitudinalConflictAtTick(tick, pos)
	for _, other in ipairs(M.getLiveCars()) do
		if other ~= self then
			local otherPos = other:getPosAtTick(tick)
			if otherPos then
				local dx = otherPos.x - pos.x
				local dy = otherPos.y - pos.y
				if dx*dx + dy*dy < SAFE_FOLLOW_DIST then
					return true
				end
			end
		end
	end
	return false
end

-- ============================================================================
-- Математически стабильное запекание траектории
-- ============================================================================

function Car:bakeTrajectory()
	local tunSegments = self:scanTunnelSegments()

	if #tunSegments == 0 then
		self:buildSimpleTrajectory()
		return
	end

	local safetyCounter = 0
	local maxIterations = 300

	while safetyCounter < maxIterations do
		safetyCounter = safetyCounter + 1
		local currentTick = self.realSpawnTick + self.spawnDelayTicks
		self.spawnTick = currentTick

		local tempTrajectory = {}
		local globalConflictFound = false

		for idx, seg in ipairs(tunSegments) do
			if globalConflictFound then break end

			if not seg.inTunnel then
				-- ОТКРЫТЫЙ УЧАСТОК: Планируем скорость на основе S-кривой перед туннелем
				local nextTunnel = tunSegments[idx + 1]
				local nominalDuration = math.ceil(seg.length / (MAX_SPEED * tickRate))
				local requiredDuration = nominalDuration

				if nextTunnel and nextTunnel.inTunnel then
					local arrivalAtTunnelTick = currentTick + nominalDuration
					local wait = 0
					-- Ищем безопасный временной зазор для въезда в туннель
					while wait < 1000 do
						if not self:hasTunnelConflict(arrivalAtTunnelTick + wait, nextTunnel.startDist, nextTunnel.endDist) then
							break
						end
						wait = wait + 2
					end
					requiredDuration = nominalDuration + wait
				end

				-- Какое максимальное время мы можем тянуть на этом участке без езды назад
				local maxPossibleDuration = math.ceil(seg.length / (MIN_SPEED * tickRate))

				if requiredDuration > maxPossibleDuration then
					-- Если тормозить уже некуда, сдвигаем весь спавн машины назад во времени
					local excessWait = requiredDuration - maxPossibleDuration
					self.spawnDelayTicks = self.spawnDelayTicks + excessWait
					globalConflictFound = true
					break
				end

				-- Расчет профиля просадки S-кривой
				local steps = requiredDuration
				local targetDip = 0
				if steps > nominalDuration and steps > 1 then
					local avgSpeed = (seg.length / tickRate) / steps
					targetDip = 2 * (MAX_SPEED - avgSpeed)
					if MAX_SPEED - targetDip < MIN_SPEED then
						targetDip = MAX_SPEED - MIN_SPEED
					end
				end

				-- Монотонная генерация координат без накопления ошибок округления
				local accumulatedDist = seg.startDist
				for step = 0, steps - 1 do
					local t_frac = step / (steps - 1 == 0 and 1 or steps - 1)
					local pos = self:getPosAtDist(accumulatedDist)

					-- Продольная проверка безопасности движения бампер-в-бампер
					if pos and self:hasLongitudinalConflictAtTick(currentTick, pos) then
						self.spawnDelayTicks = self.spawnDelayTicks + 2
						globalConflictFound = true
						break
					end

					if pos then tempTrajectory[currentTick] = pos end

					-- Формула скорости S-кривой: v(t) = Vmax - dip * sin(pi * t)^2
					local speedModifier = math.sin(math.pi * t_frac) ^ 2
					local currentSpeed = MAX_SPEED - (targetDip * speedModifier)

					accumulatedDist = accumulatedDist + currentSpeed * tickRate
					currentTick = currentTick + 1
				end

				if globalConflictFound then break end

				-- Жесткая фиксация на стыке сегмента
				local pos = self:getPosAtDist(seg.endDist)
				if pos then tempTrajectory[currentTick] = pos end

			else
				-- ВНУТРИ ТУННЕЛЯ: Скорость строго константная, максимальная и неизменная
				if self:hasTunnelConflict(currentTick, seg.startDist, seg.endDist) then
					self.spawnDelayTicks = self.spawnDelayTicks + 2
					globalConflictFound = true
					break
				end

				local simDist = seg.startDist
				while simDist < seg.endDist do
					local pos = self:getPosAtDist(simDist)

					if pos and self:hasLongitudinalConflictAtTick(currentTick, pos) then
						self.spawnDelayTicks = self.spawnDelayTicks + 2
						globalConflictFound = true
						break
					end

					if pos then tempTrajectory[currentTick] = pos end
					simDist = simDist + MAX_SPEED * tickRate
					currentTick = currentTick + 1
				end

				if globalConflictFound then break end

				local pos = self:getPosAtDist(seg.endDist)
				if pos then tempTrajectory[currentTick] = pos end
			end
		end

		if not globalConflictFound then
			-- Траектория без разрывов успешно построена!
			self.trajectory = tempTrajectory
			self.endTick = currentTick
			break
		end
	end

	-- Регистрация в общем расписании
	for t, p in pairs(self.trajectory) do
		if M.checkPointInZones(p.x, p.y) then
			tunel.registerCarAtTick(t, self)
		end
	end
end

function Car:buildSimpleTrajectory()
	local trajectory = {}
	local totalTicks = math.ceil(self.total / (MAX_SPEED * tickRate))

	for i = 0, totalTicks do
		local dist = math.min(i * MAX_SPEED * tickRate, self.total)
		local pos = self:getPosAtDist(dist)
		if pos then
			trajectory[self.realSpawnTick + i] = pos
		end
	end

	self.trajectory = trajectory
	self.endTick = self.realSpawnTick + totalTicks
end

-- ============================================================================
-- position lookup
-- ============================================================================

function Car:getPosAtDist(d)
	local path = self.pathPoints
	local dists = self.dists
	local n = #path

	if n == 0 then return nil end
	if n == 1 then return path[1] end

	d = math.max(0, math.min(d, self.total))

	for i = 2, n do
		if dists[i] >= d then
			local segLen = dists[i] - dists[i-1]
			if segLen < 1e-6 then return path[i] end

			local frac = (d - dists[i-1]) / segLen

			return {
				x = path[i-1].x + (path[i].x - path[i-1].x) * frac,
				y = path[i-1].y + (path[i].y - path[i-1].y) * frac,
			}
		end
	end

	return path[n]
end

function Car:getPosAtTick(tick)
	return self.trajectory[tick]
end

function Car:getPos(currentWorldTick, alpha)
	if currentWorldTick < self.spawnTick then return nil end

	local posNow  = self:getPosAtTick(currentWorldTick)
	local posNext = self:getPosAtTick(currentWorldTick + 1)

	if not posNow then return nil end
	if self.done or not posNext then return posNow end

	-- Безопасная линейная интерполяция между дискретными кадрами (тиками)
	return {
		x = posNow.x + (posNext.x - posNow.x) * alpha,
		y = posNow.y + (posNext.y - posNow.y) * alpha,
	}
end

function Car:checkFinished(currentWorldTick)
	if self.done then return true end
	if currentWorldTick >= self.endTick then
		self.done = true
		return true
	end
	return false
end

function Car:draw(currentWorldTick, alpha)
	local p = self:getPos(currentWorldTick, alpha)
	if not p then return end

	love.graphics.setColor(self.color[1], self.color[2], self.color[3])
	love.graphics.circle("fill", p.x, p.y, RADIUS)

	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.circle("fill", p.x, p.y, 8)
end

-- ============================================================================
-- module state
-- ============================================================================

local cars = {}
local currentTicks = 0
local currentAlpha = 0

function M.setTickRate(rate) tickRate = rate end

function M.spawnCar(level, currentWorldTick)
	local route = ROUTES[math.random(#ROUTES)]
	local pathPoints, segments = buildPathWithSegments(route, level)

	if #pathPoints == 0 then return end

	local color = COLORS[math.random(#COLORS)]
	cars[#cars + 1] = Car.new(pathPoints, segments, route, color, currentWorldTick)
end

function M.update(dt, level, worldTick, alpha)
	currentTicks = worldTick
	currentAlpha = alpha

	for i = #cars, 1, -1 do
		if cars[i]:checkFinished(worldTick) then
			tunel.unregisterCarEverywhere(cars[i])
			table.remove(cars, i)
		end
	end
end

function M.draw()
	tunel.draw(currentTicks, currentAlpha)

	for _, car in ipairs(cars) do
		car:draw(currentTicks, currentAlpha)
	end
end

function M.getLiveCars()
	return cars
end

return M