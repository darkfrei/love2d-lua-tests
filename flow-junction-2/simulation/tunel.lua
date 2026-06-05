-- simulation/tunel.lua
-- discrete space-time conflict scheduler with spatial convex hulls

local M = {}

local RADIUS = 20
local CONFLICT_DIST = 2 * RADIUS + 2
local CONFLICT_DIST2 = CONFLICT_DIST * CONFLICT_DIST
local SAMPLE_STEP = 8
local SAFETY_DIST2 = (RADIUS * 2 + 2) ^ 2

local zones = {}
local schedule = {}

local function quadratic(p0, p1, p2, t)
	local u = 1 - t
	return {
		x = u * u * p0.x + 2 * u * t * p1.x + t * t * p2.x,
		y = u * u * p0.y + 2 * u * t * p1.y + t * t * p2.y
	}
end

local function cubic(p0, p1, p2, p3, t)
	local u = 1 - t
	return {
		x = u ^ 3 * p0.x + 3 * u ^ 2 * t * p1.x + 3 * u * t ^ 2 * p2.x + t ^ 3 * p3.x,
		y = u ^ 3 * p0.y + 3 * u ^ 2 * t * p1.y + 3 * u * t ^ 2 * p2.y + t ^ 3 * p3.y
	}
end

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

local function sampleWay(way, nodes)
	local pts = {}

	for _, id in ipairs(way.nodeRefs) do
		local n = nodes[id]
		if n then
			pts[#pts + 1] = n
		end
	end

	local curveType = way.tags and way.tags.curve or "linear"

	if curveType == "linear" then
		local out = {}

		for i = 1, #pts - 1 do
			local a = pts[i]
			local b = pts[i + 1]

			local dx = b.x - a.x
			local dy = b.y - a.y
			local len = math.sqrt(dx * dx + dy * dy)

			local steps = math.max(1, math.floor(len / SAMPLE_STEP))

			for j = 0, steps - 1 do
				out[#out + 1] = {
					x = a.x + dx * (j / steps),
					y = a.y + dy * (j / steps)
				}
			end
		end

		out[#out + 1] = pts[#pts]
		return out
	elseif curveType == "bezier" then
		return sampleBezier(pts)
	end

	return pts
end

local function cross(o, a, b)
	return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x)
end

local function convexHull(pts)
	local n = #pts
	if n <= 3 then
		return pts
	end

	table.sort(pts, function(a, b)
			return (a.x == b.x and a.y < b.y) or a.x < b.x
		end)

	local lower = {}
	for i = 1, n do
		while #lower >= 2 and cross(lower[#lower - 1], lower[#lower], pts[i]) <= 0 do
			table.remove(lower)
		end
		lower[#lower + 1] = pts[i]
	end

	local upper = {}
	for i = n, 1, -1 do
		while #upper >= 2 and cross(upper[#upper - 1], upper[#upper], pts[i]) <= 0 do
			table.remove(upper)
		end
		upper[#upper + 1] = pts[i]
	end

	table.remove(lower)
	table.remove(upper)

	for i = 1, #upper do
		lower[#lower + 1] = upper[i]
	end

	return lower
end

local function expandHull(hull, d)
	local n = #hull
	if n < 3 then
		return hull
	end

	local out = {}

	for i = 1, n do
		local a = hull[((i - 2 + n) % n) + 1]
		local b = hull[i]
		local c = hull[(i % n) + 1]

		local function norm(p, q)
			local dx = q.x - p.x
			local dy = q.y - p.y
			local l = math.sqrt(dx * dx + dy * dy)
			if l < 1e-9 then
				return 0, 0
			end
			return dy / l, -dx / l
		end

		local nx1, ny1 = norm(a, b)
		local nx2, ny2 = norm(b, c)

		local bx = nx1 + nx2
		local by = ny1 + ny2

		local dot = bx * nx2 + by * ny2

		if math.abs(dot) < 0.15 then
			out[i] = { x = b.x + nx1 * d, y = b.y + ny1 * d }
		else
			out[i] = { x = b.x + bx * d / dot, y = b.y + by * d / dot }
		end
	end

	return out
end

function M.getZones()
	return zones
end

-- added cleanup for simulation restart
function M.clear()
	schedule = {}
end

function M.cleanPassedTicks(currentWorldTick)
	for tick, _ in pairs(schedule) do
		if tick < currentWorldTick then
			schedule[tick] = nil
		end
	end
end

function M.registerCarAtTick(tick, car)
	if not schedule[tick] then
		schedule[tick] = {}
	end

	for _, c in ipairs(schedule[tick]) do
		if c == car then
			return
		end
	end

	table.insert(schedule[tick], car)
end

function M.unregisterCarEverywhere(car)
	for tick, carList in pairs(schedule) do
		for i = #carList, 1, -1 do
			if carList[i] == car then
				table.remove(carList, i)
			end
		end

		if #carList == 0 then
			schedule[tick] = nil
		end
	end
end

function M.getCarsAtTick(tick)
	return schedule[tick] or {}
end

function M.isSlotOccupied(tick, currentCar, currentPos)
	local carsAtTick = schedule[tick]
	if not carsAtTick then
		return false
	end

	for _, other in ipairs(carsAtTick) do
		if other ~= currentCar then
			local otherPos = other:getPosAtTick(tick)
			if otherPos then
				local dx = otherPos.x - currentPos.x
				local dy = otherPos.y - currentPos.y

				if dx * dx + dy * dy < SAFETY_DIST2 then
					return true
				end
			end
		end
	end

	return false
end

function M.build(level)
	schedule = {}

	local ways = {}

	for _, way in ipairs(level.ways) do
		ways[#ways + 1] = {
			id = way.id,
			pts = sampleWay(way, level.nodes)
		}
	end

	local raw = {}

	for i = 1, #ways do
		for j = i + 1, #ways do
			local w1 = ways[i]
			local w2 = ways[j]

			for _, pa in ipairs(w1.pts) do
				for _, pb in ipairs(w2.pts) do
					local dx = pb.x - pa.x
					local dy = pb.y - pa.y

					if dx * dx + dy * dy < CONFLICT_DIST2 then
						raw[#raw + 1] = {
							x = (pa.x + pb.x) * 0.5,
							y = (pa.y + pb.y) * 0.5
						}
					end
				end
			end
		end
	end

	local clusters = {}
	local used = {}
	local CLUSTER_R2 = (CONFLICT_DIST * 2) ^ 2

	for i = 1, #raw do
		if not used[i] then
			local cluster = { raw[i] }
			used[i] = true

			local changed = true
			while changed do
				changed = false

				for j = 1, #raw do
					if not used[j] then
						for _, c in ipairs(cluster) do
							local dx = raw[j].x - c.x
							local dy = raw[j].y - c.y

							if dx * dx + dy * dy < CLUSTER_R2 then
								cluster[#cluster + 1] = raw[j]
								used[j] = true
								changed = true
								break
							end
						end
					end
				end
			end

			clusters[#clusters + 1] = cluster
		end
	end

	local result = {}

	for _, cluster in ipairs(clusters) do
		local hull = convexHull(cluster)
		local verts = {}

		for _, p in ipairs(expandHull(hull, RADIUS + 4)) do
			verts[#verts + 1] = p.x
			verts[#verts + 1] = p.y
		end

		if #verts >= 6 then
			result[#result + 1] = verts
		end
	end

	zones = result
end

function M.draw(currentWorldTick, alpha)
	love.graphics.setLineWidth(1.5)

	for _, verts in ipairs(zones) do
		if #verts >= 6 then
			love.graphics.setColor(0.25, 0.28, 0.32, 0.3)
			love.graphics.polygon("fill", verts)
			love.graphics.setColor(0.25, 0.55, 1.0, 0.6)
			love.graphics.polygon("line", verts)
		end
	end

	if not currentWorldTick then
		return
	end

	for bookedTick, carList in pairs(schedule) do
		for _, car in ipairs(carList) do
			local posNow = car:getPosAtTick(bookedTick)
			local posNext = car:getPosAtTick(bookedTick + 1)

			if posNow then
				local x = posNow.x
				local y = posNow.y

				if bookedTick == currentWorldTick and posNext and alpha then
					x = posNow.x + (posNext.x - posNow.x) * alpha
					y = posNow.y + (posNext.y - posNow.y) * alpha
				end

				if bookedTick < currentWorldTick then
					love.graphics.setColor(car.color[1], car.color[2], car.color[3], 0.10)
				elseif bookedTick == currentWorldTick then
					love.graphics.setColor(1, 1, 1, 0.8)
				else
					love.graphics.setColor(car.color[1], car.color[2], car.color[3], 0.35)
				end

				love.graphics.circle("fill", x, y, 5)

				if bookedTick % 5 == 0 then
					love.graphics.setColor(1, 1, 1, 0.25)
					love.graphics.print(tostring(bookedTick), x + 8, y - 6)
				end
			end
		end
	end
end

return M