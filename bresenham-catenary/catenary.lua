-- catenary.lua
-- pure lua catenary curve solver

local Catenary = {}

-- exponential clamp threshold
local EXP_LIMIT = 20

-- minimum sinh result to avoid instability
local MIN_SINH = 1e-12

-- distance epsilon
local DIST_EPSILON = 1e-6

-- max solver bound
local MAX_A_LIMIT = 1e9

-- solver iterations
local SOLVER_ITERATIONS = 80

-- hyperbolic cosine
local function cosh(x)
	if x > EXP_LIMIT then
		return 0.5 * math.exp(x)
	elseif x < -EXP_LIMIT then
		return 0.5 * math.exp(-x)
	end
	return (math.exp(x) + math.exp(-x)) * 0.5
end

-- hyperbolic sine
local function sinh(x)
	if x > EXP_LIMIT then
		return 0.5 * math.exp(x)
	elseif x < -EXP_LIMIT then
		return -0.5 * math.exp(-x)
	end
	return (math.exp(x) - math.exp(-x)) * 0.5
end

-- inverse sinh
local function asinh(x)
	return math.log(x + math.sqrt(x * x + 1))
end

-- solver for parameter a
local function solveA(dx, dy, length)
	local distance = math.sqrt(dx * dx + dy * dy)

	if length <= distance then
		return nil
	end

	local horizontal = math.abs(dx)
	local target = math.sqrt(math.max(0, length * length - dy * dy))

	local function eq(a)
		local u = horizontal / (2 * a)
		return 2 * a * sinh(u) - target
	end

	local minA = math.max(horizontal * 1e-6, 1e-6)
	local maxA = math.max(horizontal, target, 10)

	while eq(maxA) > 0 do
		maxA = maxA * 2
		if maxA > MAX_A_LIMIT then
			return nil
		end
	end

	for _ = 1, SOLVER_ITERATIONS do
		local mid = 0.5 * (minA + maxA)

		if eq(mid) > 0 then
			minA = mid
		else
			maxA = mid
		end
	end

	return 0.5 * (minA + maxA)
end

-- MAIN ADDITION: function builder
function Catenary.buildFunction(x1, y1, x2, y2, length)
	local dx = x2 - x1
	local dy = y2 - y1

	local distance = math.sqrt(dx * dx + dy * dy)

	-- degenerate → straight line function
	if length <= distance + DIST_EPSILON then
		return function(x)
			local t = (x - x1) / dx
			return y1 + (y2 - y1) * t
		end
	end

	-- vertical fallback
	if math.abs(dx) < DIST_EPSILON then
		return function()
			return (y1 + y2) * 0.5 + length * 0.25
		end
	end

	local a = solveA(dx, dy, length)

	-- fallback
	if not a then
		return function(x)
			local t = (x - x1) / dx
			return y1 + (y2 - y1) * t
		end
	end

	local s = sinh(dx / (2 * a))
	if math.abs(s) < MIN_SINH then
		s = (s >= 0) and MIN_SINH or -MIN_SINH
	end

	local shift = a * asinh(-dy / (2 * a * s))
	local x0 = (x1 + x2) * 0.5 - shift
	local c = y1 + a * cosh((x1 - x0) / a)

	return function(x)
		local u = (x - x0) / a
		return -a * cosh(u) + c
	end
end

return Catenary