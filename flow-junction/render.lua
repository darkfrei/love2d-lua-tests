-- render.lua
--
-- draws static level geometry (roads + nodes)

local M = {}

-- =========================================================
-- bezier helpers
-- =========================================================

local function quadratic(p0, p1, p2, t)
	local u = 1 - t
	return {
		x = u*u*p0.x + 2*u*t*p1.x + t*t*p2.x,
		y = u*u*p0.y + 2*u*t*p1.y + t*t*p2.y
	}
end

local function cubic(p0, p1, p2, p3, t)
	local u = 1 - t
	return {
		x = u^3*p0.x + 3*u^2*t*p1.x + 3*u*t^2*p2.x + t^3*p3.x,
		y = u^3*p0.y + 3*u^2*t*p1.y + 3*u*t^2*p2.y + t^3*p3.y
	}
end

-- =========================================================
-- sampling
-- =========================================================

local function sampleBezier(pts)
	local out = {}

	if #pts == 3 then
		for i = 0, 24 do
			out[#out + 1] = quadratic(pts[1], pts[2], pts[3], i / 24)
		end
	elseif #pts == 4 then
		for i = 0, 24 do
			out[#out + 1] = cubic(pts[1], pts[2], pts[3], pts[4], i / 24)
		end
	end

	return out
end

local SAMPLE_STEP = 8

local function sampleWay(way, nodes)
	local pts = {}
	for _, id in ipairs(way.nodeRefs) do
		pts[#pts + 1] = nodes[id]
	end

	if way.tags.curve == "linear" then
		local out = {}
		for i = 1, #pts - 1 do
			local a = pts[i]
			local b = pts[i + 1]

			local dx = b.x - a.x
			local dy = b.y - a.y
			local len = math.sqrt(dx*dx + dy*dy)

			local steps = math.max(1, math.floor(len / SAMPLE_STEP))

			for j = 0, steps - 1 do
				local t = j / steps
				out[#out + 1] = { x = a.x + dx * t, y = a.y + dy * t }
			end
		end

		out[#out + 1] = pts[#pts]
		return out

	elseif way.tags.curve == "bezier" then
		return sampleBezier(pts)
	end

	return pts
end

-- =========================================================
-- drawing
-- =========================================================

local function drawLine(points, r, g, b)
	love.graphics.setColor(r, g, b)

	for i = 1, #points - 1 do
		love.graphics.line(
			points[i].x, points[i].y,
			points[i + 1].x, points[i + 1].y
		)
	end
end

local function drawHandles(pts)
	love.graphics.setColor(1, 0.5, 0.1, 0.9)

	for i = 1, #pts - 1 do
		love.graphics.line(
			pts[i].x, pts[i].y,
			pts[i + 1].x, pts[i + 1].y
		)
	end
end

function M.draw(level)
	for _, way in ipairs(level.ways) do
		local curve = way.tags and way.tags.curve

		local pts = {}
		for _, id in ipairs(way.nodeRefs) do
			pts[#pts + 1] = level.nodes[id]
		end

		if curve == "linear" then
			drawLine(pts, 0.9, 0.9, 0.9)

		elseif curve == "bezier" then
			local sampled = sampleBezier(pts)
			drawLine(sampled, 0.2, 0.8, 1.0)
			drawHandles(pts)
		end
	end

	for id, n in pairs(level.nodes) do
		love.graphics.setColor(1, 1, 1, 0.5)
		love.graphics.circle("fill", n.x, n.y, 3)

		love.graphics.setColor(1, 1, 1, 0.6)
		love.graphics.print(tostring(id), n.x + 10, n.y + 10)
	end
end

return M