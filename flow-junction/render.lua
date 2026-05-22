-- render.lua
--
-- simple level renderer
--
-- api:
--   M.draw(level)
--
-- level format:
--   level.nodes[id] = { x, y }
--
--   level.ways = {
--       {
--           id = "...",
--           nodeRefs = { ... },
--           tags = {
--               curve = "linear" | "bezier"
--           }
--       }
--   }
--
-- features:
--   - linear way rendering
--   - quadratic bezier rendering
--   - cubic bezier rendering
--   - control polygon visualization
--   - node id visualization

local M = {}

-- bezier subdivision count
local STEPS = 24

-- quadratic bezier interpolation
--
-- p0:
--   start point
--
-- p1:
--   control point
--
-- p2:
--   end point
local function quadratic(p0, p1, p2, t)
	local u = 1 - t

	return {
		x = u * u * p0.x
		+ 2 * u * t * p1.x
		+ t * t * p2.x,

		y = u * u * p0.y
		+ 2 * u * t * p1.y
		+ t * t * p2.y,
	}
end

-- cubic bezier interpolation
--
-- p0:
--   start point
--
-- p1/p2:
--   control points
--
-- p3:
--   end point
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

-- samples a bezier curve into a polyline
--
-- supported layouts:
--   3 points -> quadratic
--   4 points -> cubic
local function sampleBezier(points)
	local out = {}

	if #points == 3 then
		for i = 0, STEPS do
			local t = i / STEPS

			out[#out + 1] = quadratic(
				points[1],
				points[2],
				points[3],
				t
			)
		end

	elseif #points == 4 then
		for i = 0, STEPS do
			local t = i / STEPS

			out[#out + 1] = cubic(
				points[1],
				points[2],
				points[3],
				points[4],
				t
			)
		end
	end

	return out
end

-- draws connected line segments
local function drawLine(points, r, g, b)
	if #points < 2 then
		return
	end

	love.graphics.setColor(r, g, b)

	for i = 1, #points - 1 do
		local a = points[i]
		local bPoint = points[i + 1]

		love.graphics.line(
			a.x, a.y,
			bPoint.x, bPoint.y
		)
	end
end

-- draws bezier control polygon and handles
local function drawHandles(points)
	-- control polygon
	love.graphics.setColor(1, 0.5, 0.1, 0.9)

	for i = 1, #points - 1 do
		local a = points[i]
		local b = points[i + 1]

		love.graphics.line(
			a.x, a.y,
			b.x, b.y
		)
	end

	-- control points
	for i, p in ipairs(points) do
		love.graphics.setColor(1, 0.7, 0.2)
		love.graphics.circle("fill", p.x, p.y, 4)

		-- local node index inside the way
		love.graphics.setColor(1, 1, 1, 0.7)
		love.graphics.print(tostring(i), p.x + 6, p.y + 6)
	end
end

-- resolves node ids into node objects
local function resolvePoints(nodeRefs, nodes)
	local points = {}

	for _, id in ipairs(nodeRefs) do
		local node = nodes[id]

		if node then
			points[#points + 1] = node
		end
	end

	return points
end

function M.draw(level)
	love.graphics.clear(0.08, 0.10, 0.12)

	-- draw ways
	for _, way in ipairs(level.ways) do
		local points = resolvePoints(
			way.nodeRefs,
			level.nodes
		)

		local curve =
		way.tags
		and way.tags.curve

		-- simple polyline
		if curve == "linear" then
			drawLine(points, 0.9, 0.9, 0.9)

			-- sampled bezier
		elseif curve == "bezier" then
			local sampled = sampleBezier(points)

			drawLine(sampled, 0.2, 0.8, 1.0)
			drawHandles(points)
		end
	end

	-- draw all global nodes
	for id, node in pairs(level.nodes) do
		love.graphics.setColor(1, 1, 1, 0.5)
		love.graphics.circle(
			"fill",
			node.x,
			node.y,
			3
		)

		-- global node id
		love.graphics.setColor(1, 1, 1, 0.6)

		love.graphics.print(
			tostring(id),
			node.x + 12,
			node.y + 20
		)
	end
end

return M