local function catenary(x1, y1, x2, y2, L, steps)
	steps = steps or 16

	local function cosh(x)
		if x > 20 then
			return 0.5 * math.exp(x)
		elseif x < -20 then
			return 0.5 * math.exp(-x)
		end
		return (math.exp(x) + math.exp(-x)) * 0.5
	end

	local function sinh(x)
		if x > 20 then
			return 0.5 * math.exp(x)
		elseif x < -20 then
			return -0.5 * math.exp(-x)
		end
		return (math.exp(x) - math.exp(-x)) * 0.5
	end

	local function asinh(x)
		return math.log(x + math.sqrt(x * x + 1))
	end

	local function solveA(dx, dy, L)
		local dist = math.sqrt(dx * dx + dy * dy)
		if L <= dist then return nil end

		local D = math.abs(dx)
		local T = math.sqrt(math.max(0, L * L - dy * dy))

		local function f(a)
			local u = D / (2 * a)
			return 2 * a * sinh(u) - T
		end

		local lo = math.max(D * 1e-6, 1e-6)
		local hi = math.max(D, T, 10)

		while f(hi) > 0 do
			hi = hi * 2
			if hi > 1e9 then return nil end
		end

		for _ = 1, 80 do
			local mid = 0.5 * (lo + hi)
			if f(mid) > 0 then lo = mid else hi = mid end
		end

		return 0.5 * (lo + hi)
	end

	local dx = x2 - x1
	local dy = y2 - y1
	local dist = math.sqrt(dx * dx + dy * dy)

	if L <= dist + 1e-6 then
		local points = {}
		for i = 0, steps do
			local t = i / steps
			points[#points + 1] = { x = x1 + dx * t, y = y1 + dy * t }
		end
		return { points = points }
	end

	if math.abs(dx) < 1e-6 then
		local points = {}
		local cx = x1
		local cy = (y1 + y2) * 0.5 + L * 0.5

		for i = 0, steps do
			local t = i / steps
			local x, y

			if t < 0.5 then
				local k = t * 2
				x = x1 + (cx - x1) * k
				y = y1 + (cy - y1) * k
			else
				local k = (t - 0.5) * 2
				x = cx + (x2 - cx) * k
				y = cy + (y2 - cy) * k
			end

			points[#points + 1] = { x = x, y = y }
		end

		return { points = points }
	end

	local a = solveA(dx, dy, L)
	if not a then
		local points = {}
		for i = 0, steps do
			local t = i / steps
			points[#points + 1] = { x = x1 + dx * t, y = y1 + dy * t }
		end
		return { points = points }
	end

	local s = sinh(dx / (2 * a))
	if math.abs(s) < 1e-12 then
		s = (s >= 0) and 1e-12 or -1e-12
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
		points[#points + 1] = { x = x, y = y }
	end

	return { points = points }
end

return catenary