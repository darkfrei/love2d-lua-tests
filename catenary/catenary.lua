local Catenary = {}

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

-- solves catenary parameter a using bisection method
local function solveA(dx, dy, L)
	local dist = math.sqrt(dx * dx + dy * dy)

	if L <= dist then
		return nil
	end

	local D = math.abs(dx)
	local T = math.sqrt(L * L - dy * dy)

	local function f(a)
		local u = D / (2 * a)
		return 2 * a * sinh(u) - T
	end

	local lo = math.max(D * 1e-6, 1e-6)
	local hi = math.max(D, T, 10)

	while f(hi) > 0 do
		hi = hi * 2

		if hi > 1e9 then
			return nil
		end
	end

	for _ = 1, 80 do
		local mid = (lo + hi) * 0.5

		if f(mid) > 0 then
			lo = mid
		else
			hi = mid
		end
	end

	return (lo + hi) * 0.5
end

function Catenary.compute(x1, y1, x2, y2, L, steps)
	steps = steps or 120

	local dx = x2 - x1
	local dy = y2 - y1

	local dist = math.sqrt(dx * dx + dy * dy)

	local status = "ok"
	local msg = ""

	-- rope is fully taut, no sag possible
	if L <= dist + 1e-6 then
		status = "taut"
		msg = "chain is taut"

		local pts = {}

		for i = 0, steps do
			local t = i / steps

			pts[#pts + 1] = {
				x = x1 + dx * t,
				y = y1 + dy * t
			}
		end

		return {
			points = pts,
			status = status,
			msg = msg,
			a = nil
		}
	end

	-- vertical rope special case
	if math.abs(dx) < 1e-6 then
		status = "vertical"
		msg = "vertical rope"

		local pts = {}

		local cx = x1
		local cy = (y1 + y2) * 0.5 + L * 0.5

		for i = 0, steps do
			local t = i / steps

			local x
			local y

			if t < 0.5 then
				local k = t * 2
				x = x1 + (cx - x1) * k
				y = y1 + (cy - y1) * k
			else
				local k = (t - 0.5) * 2
				x = cx + (x2 - cx) * k
				y = cy + (y2 - cy) * k
			end

			pts[#pts + 1] = { x = x, y = y }
		end

		return {
			points = pts,
			status = status,
			msg = msg,
			a = nil
		}
	end

	local a = solveA(dx, dy, L)

	if not a then
		status = "failed"
		msg = "failed to solve catenary"

		local pts = {}

		for i = 0, steps do
			local t = i / steps

			pts[#pts + 1] = {
				x = x1 + dx * t,
				y = y1 + dy * t
			}
		end

		return {
			points = pts,
			status = status,
			msg = msg,
			a = nil
		}
	end

	local s = sinh(dx / (2 * a))

	if math.abs(s) < 1e-9 then
		s = s >= 0 and 1e-9 or -1e-9
	end

	local shift = a * asinh(-dy / (2 * a * s))
	local x0 = (x1 + x2) * 0.5 - shift
	local c = y1 + a * cosh((x1 - x0) / a)

	local pts = {}

	for i = 0, steps do
		local t = i / steps

		local x = x1 + dx * t
		local u = (x - x0) / a
		local y = -a * cosh(u) + c

		pts[#pts + 1] = { x = x, y = y }
	end

	return {
		points = pts,
		status = status,
		msg = msg,
		a = a
	}
end

function Catenary.draw(x1, y1, x2, y2, L, steps, width)
	local res = Catenary.compute(x1, y1, x2, y2, L, steps)

	if #res.points < 2 then
		return res
	end

	love.graphics.setLineWidth(width or 2)

	local flat = {}

	for i = 1, #res.points do
		flat[#flat + 1] = res.points[i].x
		flat[#flat + 1] = res.points[i].y
	end

	if res.status == "ok" then
		love.graphics.setColor(0.95, 0.65, 0.35)
	elseif res.status == "vertical" then
		love.graphics.setColor(0.4, 0.8, 1)
	else
		love.graphics.setColor(1, 0.3, 0.3)
	end

	love.graphics.line(flat)
	love.graphics.setLineWidth(1)

	return res
end

-- draws anchor points for debugging
function Catenary.drawAnchors(x1, y1, x2, y2)

	love.graphics.setColor(1, 1, 1)
	love.graphics.circle("fill", x1, y1, 5)
	
	love.graphics.setColor(1, 1, 0)
	love.graphics.circle("fill", x2, y2, 5)
end

return Catenary