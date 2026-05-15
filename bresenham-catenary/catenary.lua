-- catenary.lua
-- stable catenary solver — no metatable version

local Catenary = {}

-- constants
local DEFAULT_STEPS     = 16
local EXP_LIMIT         = 20
local MIN_A             = 1e-6
local MIN_SINH          = 1e-12
local DIST_EPSILON      = 1e-6
local MAX_A_LIMIT       = 1e9
local SOLVER_ITERATIONS = 80
local MAX_EXPAND_GUARD  = 64

-- math helpers
local function cosh(x)
	if x > EXP_LIMIT then return 0.5 * math.exp(x) end
	if x < -EXP_LIMIT then return 0.5 * math.exp(-x) end
	return (math.exp(x) + math.exp(-x)) * 0.5
end

local function sinh(x)
	if x > EXP_LIMIT then return 0.5 * math.exp(x) end
	if x < -EXP_LIMIT then return -0.5 * math.exp(-x) end
	return (math.exp(x) - math.exp(-x)) * 0.5
end

local function asinh(x)
	return math.log(x + math.sqrt(x * x + 1))
end

local function isFinite(v)
	return type(v) == "number" and v == v and v ~= math.huge and v ~= -math.huge
end

-- fallback: straight line
local function buildStraightLine(x1, y1, x2, y2, steps)
	local points = {}
	local dx = x2 - x1
	local dy = y2 - y1

	for i = 0, steps do
		local t = i / steps
		points[#points + 1] = { x = x1 + dx * t, y = y1 + dy * t }
	end

	return points
end

-- fallback: vertical rope
local function buildVerticalFallback(x1, y1, x2, y2, length, steps)
	local points = {}
	local centerX = x1
	local centerY = (y1 + y2) * 0.5 + length * 0.5

	for i = 0, steps do
		local t = i / steps
		local x, y

		if t < 0.5 then
			local k = t * 2
			x = x1 + (centerX - x1) * k
			y = y1 + (centerY - y1) * k
		else
			local k = (t - 0.5) * 2
			x = centerX + (x2 - centerX) * k
			y = centerY + (y2 - centerY) * k
		end

		points[#points + 1] = { x = x, y = y }
	end

	return points
end

-- solver
local function solveA(dx, dy, length)
	local distance = math.sqrt(dx * dx + dy * dy)
	if length <= distance then
		return nil
	end

	local horizontalDistance = math.abs(dx)
	local target = math.sqrt(math.max(0, length * length - dy * dy))

	local function equation(a)
		local u = horizontalDistance / (2 * a)
		local val = 2 * a * sinh(u) - target
		if not isFinite(val) then return 1e9 end
		return val
	end

	local minA = math.max(horizontalDistance * MIN_A, MIN_A)
	local maxA = math.max(horizontalDistance, target, 10)

	local guard = 0
	while equation(maxA) > 0 do
		maxA = maxA * 2
		guard = guard + 1

		if maxA > MAX_A_LIMIT or guard > MAX_EXPAND_GUARD then
			return nil
		end
	end

	for _ = 1, SOLVER_ITERATIONS do
		local mid = 0.5 * (minA + maxA)

		if equation(mid) > 0 then
			minA = mid
		else
			maxA = mid
		end
	end

	return 0.5 * (minA + maxA)
end

-- polyline API
local function buildPolyline(x1, y1, x2, y2, length)
	local steps = DEFAULT_STEPS
	local dx = x2 - x1
	local dy = y2 - y1
	local distance = math.sqrt(dx * dx + dy * dy)

	-- too short → straight
	if length <= distance + DIST_EPSILON then
		return buildStraightLine(x1, y1, x2, y2, steps)
	end

	-- vertical
	if math.abs(dx) < DIST_EPSILON then
		return buildVerticalFallback(x1, y1, x2, y2, length, steps)
	end

	local a = solveA(dx, dy, length)
	if not a then
		return buildStraightLine(x1, y1, x2, y2, steps)
	end

	local s = sinh(dx / (2 * a))
	if math.abs(s) < MIN_SINH then
		s = (s >= 0) and MIN_SINH or -MIN_SINH
	end

	local shift = a * asinh(-dy / (2 * a * s))
	local x0 = (x1 + x2) * 0.5 - shift
	local c = y1 + a * cosh((x1 - x0) / a)

	local points = {}

	for i = 0, steps do
		local t = i / steps
		local x = x1 + dx * t
		local u = (x - x0) / a
		local y = -a * cosh(u) + c

		if isFinite(y) then
			points[#points + 1] = { x = x, y = y }
		end
	end

	if #points < 2 then
		return buildStraightLine(x1, y1, x2, y2, steps)
	end

	return points
end

-- explicit API (IMPORTANT FIX: no metatable)
function Catenary.buildPolyline(x1, y1, x2, y2, length)
	return buildPolyline(x1, y1, x2, y2, length)
end

function Catenary.buildFunction(x1, y1, x2, y2, length)
	local dx = x2 - x1
	local dy = y2 - y1
	local distance = math.sqrt(dx * dx + dy * dy)

	-- straight
	if length <= distance * (1 + DIST_EPSILON) then
		return function(x)
			if math.abs(dx) < 1e-12 then return y1 end
			return y1 + dy * (x - x1) / dx
		end, x1, y1
	end

	-- vertical
	if math.abs(dx) < DIST_EPSILON then
		local midY = (y1 + y2) * 0.5 + length * 0.5
		return function() return midY end, x1, midY
	end

	local a = solveA(dx, dy, length)
	if not a then
		return function(x)
			if math.abs(dx) < 1e-12 then return y1 end
			return y1 + dy * (x - x1) / dx
		end, x1, y1
	end

	local s = sinh(dx / (2 * a))
	if math.abs(s) < MIN_SINH then
		s = (s >= 0) and MIN_SINH or -MIN_SINH
	end

	local shift = a * asinh(-dy / (2 * a * s))
	local x0 = (x1 + x2) * 0.5 - shift
	local c = y1 + a * cosh((x1 - x0) / a)

	local nadirX = x0
	local nadirY = c - a

	local function f(x)
		local u = (x - x0) / a
		local y = -a * cosh(u) + c
		if not isFinite(y) then
			return (y1 + y2) * 0.5
		end
		return y
	end

	return f, nadirX, nadirY
end

return Catenary