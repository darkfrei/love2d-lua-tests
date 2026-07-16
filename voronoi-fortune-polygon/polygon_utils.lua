-- polygon_utils.lua
--
-- Pure polygon/geometry helpers with no dependency on any global demo
-- state (diagram, love.graphics, etc.), aside from Voronoi.pointInPolygon
-- for random point sampling. Every function takes a flat {x1, y1, x2,
-- y2, ...} polygon (or plain coordinates) and returns plain values.

local Voronoi = require("voronoi")

local PolygonUtils = {}

function PolygonUtils.distanceSquared(x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	return dx * dx + dy * dy
end

function PolygonUtils.vertexCount(polygon)
	return #polygon / 2
end

function PolygonUtils.getVertex(polygon, index)
	return polygon[index * 2 - 1], polygon[index * 2]
end

function PolygonUtils.setVertex(polygon, index, x, y)
	polygon[index * 2 - 1] = x
	polygon[index * 2] = y
end

-- inserts a new vertex right after vertex "edgeIndex" (i.e. on the edge
-- between edgeIndex and edgeIndex + 1, wrapping around at the end)
function PolygonUtils.insertVertex(polygon, edgeIndex, x, y)
	local pos = edgeIndex * 2 + 1
	table.insert(polygon, pos, x)
	table.insert(polygon, pos + 1, y)
end

-- removes a vertex, refusing to shrink the polygon below a triangle
function PolygonUtils.removeVertex(polygon, index)
	if PolygonUtils.vertexCount(polygon) <= 3 then
		return false
	end
	local posX = index * 2 - 1
	table.remove(polygon, posX + 1) -- remove y first, then x
	table.remove(polygon, posX)
	return true
end

function PolygonUtils.nearestVertex(mx, my, polygon, radius)
	local count = PolygonUtils.vertexCount(polygon)
	local bestIndex, bestDist
	for i = 1, count do
		local vx, vy = PolygonUtils.getVertex(polygon, i)
		local d = PolygonUtils.distanceSquared(mx, my, vx, vy)
		if not bestDist or d < bestDist then
			bestDist = d
			bestIndex = i
		end
	end
	if bestIndex and bestDist < radius * radius then
		return bestIndex
	end
	return nil
end

-- finds the polygon edge closest to a point; returns the edge index
-- (edge i goes from vertex i to vertex i+1, wrapping around) plus the
-- closest point on that edge, useful both for hit-testing and for
-- placing a new vertex when the edge is clicked
function PolygonUtils.nearestEdge(mx, my, polygon, radius)
	local count = PolygonUtils.vertexCount(polygon)
	local bestIndex, bestDist, bestX, bestY
	for i = 1, count do
		local j = (i % count) + 1
		local x1, y1 = PolygonUtils.getVertex(polygon, i)
		local x2, y2 = PolygonUtils.getVertex(polygon, j)
		local dx, dy = x2 - x1, y2 - y1
		local lenSq = dx * dx + dy * dy
		local t = 0
		if lenSq > 0 then
			t = ((mx - x1) * dx + (my - y1) * dy) / lenSq
			t = math.max(0, math.min(1, t))
		end
		local px, py = x1 + t * dx, y1 + t * dy
		local d = PolygonUtils.distanceSquared(mx, my, px, py)
		if not bestDist or d < bestDist then
			bestDist = d
			bestIndex = i
			bestX, bestY = px, py
		end
	end
	if bestIndex and bestDist < radius * radius then
		return bestIndex, bestX, bestY
	end
	return nil
end

-- area-weighted centroid of a flat {x1, y1, x2, y2, ...} polygon;
-- returns nil for a degenerate (near zero area) polygon
function PolygonUtils.centroid(polygon)
	local count = #polygon / 2
	local areaSum, cx, cy = 0, 0, 0
	for i = 1, count do
		local j = (i % count) + 1
		local x1, y1 = polygon[i * 2 - 1], polygon[i * 2]
		local x2, y2 = polygon[j * 2 - 1], polygon[j * 2]
		local cross = x1 * y2 - x2 * y1
		areaSum = areaSum + cross
		cx = cx + (x1 + x2) * cross
		cy = cy + (y1 + y2) * cross
	end
	if math.abs(areaSum) < 1e-9 then
		return nil
	end
	local area = areaSum / 2
	return cx / (6 * area), cy / (6 * area)
end

function PolygonUtils.area(polygon)
	local count = #polygon / 2
	local areaSum = 0
	for i = 1, count do
		local j = (i % count) + 1
		local x1, y1 = polygon[i * 2 - 1], polygon[i * 2]
		local x2, y2 = polygon[j * 2 - 1], polygon[j * 2]
		areaSum = areaSum + (x1 * y2 - x2 * y1)
	end
	return math.abs(areaSum) / 2
end

-- axis-aligned bounding box as 4 separate values
function PolygonUtils.bounds(polygon)
	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	for i = 1, #polygon, 2 do
		local x, y = polygon[i], polygon[i + 1]
		if x < minX then minX = x end
		if x > maxX then maxX = x end
		if y < minY then minY = y end
		if y > maxY then maxY = y end
	end
	return minX, minY, maxX, maxY
end

-- same, as a {minX=, minY=, maxX=, maxY=} table - convenient for
-- pairwise overlap checks (see boundsOverlap)
function PolygonUtils.boundsBox(polygon)
	local minX, minY, maxX, maxY = PolygonUtils.bounds(polygon)
	return { minX = minX, minY = minY, maxX = maxX, maxY = maxY }
end

function PolygonUtils.boundsOverlap(a, b, epsilon)
	epsilon = epsilon or 0.1
	return a.minX <= b.maxX + epsilon and b.minX <= a.maxX + epsilon
		and a.minY <= b.maxY + epsilon and b.minY <= a.maxY + epsilon
end

-- length of the overlap between two collinear segments, or 0 if they
-- aren't collinear (within a small pixel tolerance) or don't overlap.
-- Checking overlap length rather than exact shared endpoints matters for
-- detecting a shared border between two polygons subdivided to different
-- depths on either side (a "T-junction"): one long edge on one side can
-- face several shorter edges on the other, so vertex-for-vertex matching
-- would miss them. The tolerances are tight (well under a pixel) because
-- these edges normally come from exact geometric clipping, not noisy
-- measurements - a looser tolerance mostly just risks false positives
-- between polygons that merely pass close to each other without truly
-- sharing a border.
function PolygonUtils.collinearOverlapLength(x1, y1, x2, y2, x3, y3, x4, y4)
	local dx, dy = x2 - x1, y2 - y1
	local len = math.sqrt(dx * dx + dy * dy)
	if len < 1e-9 then return 0 end
	local ux, uy = dx / len, dy / len

	local function perpDist(px, py)
		return math.abs((px - x1) * uy - (py - y1) * ux)
	end
	if perpDist(x3, y3) > 0.1 or perpDist(x4, y4) > 0.1 then
		return 0
	end

	local function proj(px, py)
		return (px - x1) * ux + (py - y1) * uy
	end
	local b1, b2 = proj(x3, y3), proj(x4, y4)
	if b1 > b2 then b1, b2 = b2, b1 end

	return math.max(0, math.min(len, b2) - math.max(0, b1))
end

-- true if two polygons share a border of positive length, checking
-- every pair of edges for a collinear overlap (see above) - correctly
-- detects shared borders across "T-junctions"
function PolygonUtils.sharesBorder(a, b)
	local countA = #a / 2
	local countB = #b / 2
	for i = 1, countA do
		local j = (i % countA) + 1
		local x1, y1 = a[i * 2 - 1], a[i * 2]
		local x2, y2 = a[j * 2 - 1], a[j * 2]
		for k = 1, countB do
			local l = (k % countB) + 1
			local x3, y3 = b[k * 2 - 1], b[k * 2]
			local x4, y4 = b[l * 2 - 1], b[l * 2]
			if PolygonUtils.collinearOverlapLength(x1, y1, x2, y2, x3, y3, x4, y4) > 1 then
				return true
			end
		end
	end
	return false
end

function PolygonUtils.convexHull(points)
	table.sort(points, function(a, b)
			if a.x == b.x then return a.y < b.y end
			return a.x < b.x
		end)

	local function cross(o, a, b)
		return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x)
	end

	local lower = {}
	for _, p in ipairs(points) do
		while #lower >= 2 and cross(lower[#lower - 1], lower[#lower], p) <= 0 do
			table.remove(lower)
		end
		table.insert(lower, p)
	end

	local upper = {}
	for i = #points, 1, -1 do
		local p = points[i]
		while #upper >= 2 and cross(upper[#upper - 1], upper[#upper], p) <= 0 do
			table.remove(upper)
		end
		table.insert(upper, p)
	end

	table.remove(lower)
	table.remove(upper)

	local hull = {}
	for _, p in ipairs(lower) do table.insert(hull, p) end
	for _, p in ipairs(upper) do table.insert(hull, p) end
	return hull
end

-- rejection-samples a random point strictly inside a convex polygon
function PolygonUtils.randomPointInPolygon(polygon)
	local minX, minY, maxX, maxY = PolygonUtils.bounds(polygon)
	-- math.random(m, n) requires integer bounds on Lua 5.3+ (LOVE2D's
	-- bundled Lua 5.1/LuaJIT is more lenient, but polygon coordinates are
	-- often fractional at deeper recursion levels, e.g. after centroid
	-- relaxation, so floor/ceil explicitly rather than relying on that)
	local loX, hiX = math.floor(minX), math.ceil(maxX)
	local loY, hiY = math.floor(minY), math.ceil(maxY)
	for _ = 1, 200 do
		-- math.random(loX, hiX) alone returns an integer, which makes
		-- exact coordinate ties and exact collinear triples surprisingly
		-- likely with many sites; a sub-pixel fractional jitter avoids
		-- that (matches the original prototype's fix for the same problem)
		local x = math.random(loX, hiX) + math.random()
		local y = math.random(loY, hiY) + math.random()
		if Voronoi.pointInPolygon(x, y, polygon) then
			return x, y
		end
	end
	return (minX + maxX) / 2, (minY + maxY) / 2
end

return PolygonUtils
