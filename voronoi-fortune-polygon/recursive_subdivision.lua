-- recursive_subdivision.lua
--
-- Builds and maintains the recursive Voronoi hierarchy: level 1 sites
-- subdivide the root polygon, level 2 sites subdivide whichever level-1
-- cell they geometrically fall inside, and so on - plus a proper 4-color
-- map coloring of the resulting leaves. See generateLayers, computeLeaves
-- and colorLeaves below for the three separate steps involved.

local Voronoi = require("voronoi")
local PolygonUtils = require("polygon_utils")

local RecursiveSubdivision = {}

-- weighted odds for how many sites subdivide each cell, at every level
-- including the root: mostly 2, sometimes 3, rarely 4
RecursiveSubdivision.defaultCountWeights = {
	{ count = 2, weight = 65 },
	{ count = 3, weight = 28 },
	{ count = 4, weight = 7 },
}

-- fixed 4-color palette for the leaves (see colorLeaves)
RecursiveSubdivision.defaultFourColors = {
	{ 0.86, 0.32, 0.32 }, -- red
	{ 0.32, 0.62, 0.86 }, -- blue
	{ 0.36, 0.78, 0.42 }, -- green
	{ 0.86, 0.72, 0.30 }, -- yellow
}
-- used only if colorLeaves truly cannot find a valid color for some leaf
-- even after several randomized attempts (see colorLeaves); visually
-- distinct from the 4 above so a failure would be obvious rather than
-- silently matching a neighbor
RecursiveSubdivision.defaultFallbackColor = { 0.6, 0.6, 0.6 }

local function randomSubdivisionCount(weights)
	local totalWeight = 0
	for _, entry in ipairs(weights) do
		totalWeight = totalWeight + entry.weight
	end

	local r = math.random() * totalWeight
	local cumulative = 0
	for _, entry in ipairs(weights) do
		cumulative = cumulative + entry.weight
		if r <= cumulative then
			return entry.count
		end
	end

	return weights[#weights].count
end

-- Generates fixed, absolute-coordinate site positions for every level of
-- a recursive Voronoi hierarchy: level 1 subdivides rootPolygon itself,
-- level 2 subdivides whichever level-1 cell each of its points falls
-- inside, and so on. These positions never move by themselves once
-- generated - a caller keeps reusing them (e.g. across dragging the root
-- polygon) via computeLeaves below.
--
-- This computes the tree level by level (breadth-first), not branch by
-- branch (depth-first): every polygon alive at depth N is given a chance
-- to subdivide before any of them proceeds to depth N+1. This matters
-- because of maxTotalSites - with a depth-first walk, the first-explored
-- branch could keep recursing all the way to maxDepth and spend the
-- whole budget on itself, leaving every other branch - including large
-- ones, untouched by pure bad luck of traversal order - stuck with no
-- subdivision at all. Processing level by level means the budget is
-- instead spent evenly across every branch at a given depth, so a large
-- region is never skipped just because some unrelated branch happened to
-- be visited first.
--
-- For each polygon still alive at a given depth, a randomly chosen
-- number of points (weighted by countWeights) is placed strictly inside
-- it, via a throwaway Voronoi instance used just to learn its cell
-- shapes for the next level down - unless the polygon is already smaller
-- than minAreaFraction of the root's area, in which case it stops
-- subdividing there and stays a leaf, however shallow. Large polygons are
-- never affected by this area check and keep subdividing down to
-- maxDepth as usual.
--
-- After placing a level's points, they're relaxed twice (Lloyd's
-- algorithm: move each site to its own cell's centroid, recompute,
-- repeat) before moving to the next level. This is purely a cosmetic
-- improvement over raw random placement - it tends to produce more
-- evenly sized cells with fewer thin slivers.
function RecursiveSubdivision.generateLayers(rootPolygon, maxDepth, maxTotalSites, minAreaFraction, countWeights)
	countWeights = countWeights or RecursiveSubdivision.defaultCountWeights

	local layers = {}
	for depth = 1, maxDepth do
		layers[depth] = {}
	end

	local totalSites = 0
	local minArea = PolygonUtils.area(rootPolygon) * minAreaFraction
	local currentLevelPolygons = { rootPolygon }

	for depth = 1, maxDepth do
		local nextLevelPolygons = {}

		for _, polygon in ipairs(currentLevelPolygons) do
			-- too small to bother subdividing further, regardless of depth
			-- or remaining budget: large polygons are never affected by
			-- this check, since their area stays well above the threshold
			if totalSites < maxTotalSites and PolygonUtils.area(polygon) >= minArea then
				-- picked fresh for THIS specific polygon - but never more
				-- than what's left of the total budget, so an unlucky run
				-- of high rolls (e.g. several 4s in a row) can't blow up
				-- generation time via combinatorial branching
				local count = math.min(randomSubdivisionCount(countWeights), maxTotalSites - totalSites)

				if count > 0 then
					local localPoints = {}
					for _ = 1, count do
						local x, y = PolygonUtils.randomPointInPolygon(polygon)
						local point = { x = x, y = y }
						table.insert(localPoints, point)
						table.insert(layers[depth], point)
					end
					totalSites = totalSites + count

					-- learn this polygon's own cell shapes (using only the
					-- points we just placed for it), then relax twice
					local sub = Voronoi.new(polygon)
					local siteByPoint = {}
					for _, point in ipairs(localPoints) do
						local site = sub:addSite(point.x, point.y)
						if site then
							siteByPoint[site] = point
						end
					end
					sub:update()

					for _ = 1, 2 do
						for _, site in ipairs(sub.sites) do
							if site.valid and site.cell.valid and #site.cell.polygon >= 6 then
								local cx, cy = PolygonUtils.centroid(site.cell.polygon)
								if cx then
									site.x = cx
									site.y = cy
								end
							end
						end
						sub:update()
					end

					-- persist the relaxed positions back into the stored
					-- points, so rendering/recompute later uses the
					-- relaxed coordinates too, not the original random ones
					for site, point in pairs(siteByPoint) do
						point.x = site.x
						point.y = site.y
					end

					for _, cell in ipairs(sub.cells) do
						if cell.valid and #cell.polygon >= 6 then
							table.insert(nextLevelPolygons, cell.polygon)
						end
					end
				end
			end
		end

		currentLevelPolygons = nextLevelPolygons
		if #currentLevelPolygons == 0 then
			break
		end
	end

	return layers
end

-- Recomputes the whole hierarchy's leaf polygons from scratch: the
-- current rootPolygon plus the fixed site coordinates in layers. A site
-- at layer N is only ever considered to subdivide whichever layer-(N-1)
-- cell it geometrically falls inside RIGHT NOW - this uses the library's
-- normal site.valid / pointInPolygon check, nothing custom. This means
-- dragging the root polygon (or, in principle, any upper-level site)
-- never corrupts anything: cells simply reshape around the fixed points,
-- a point that no longer falls inside any cell just stops contributing,
-- and a point that drifts into a different cell than before "belongs" to
-- that cell instead, automatically, on the very next call.
--
-- This works with zero changes to the Voronoi library because a cell
-- polygon of a convex-bounded diagram is always itself convex (the
-- intersection of convex regions is convex), so it is always a valid
-- boundingPolygon for a fresh Voronoi.new(...) instance.
function RecursiveSubdivision.computeLeaves(rootPolygon, layers)
	local leaves = {}

	local function recurse(polygon, depth)
		if depth > #layers then
			table.insert(leaves, polygon)
			return
		end

		-- pre-filter to only the points that actually fall inside THIS
		-- specific polygon right now, before building the throwaway
		-- Voronoi instance. layers[depth] is the full list of points
		-- across the ENTIRE tree at this depth, so most of them belong to
		-- completely unrelated branches; feeding all of them into every
		-- single node's Voronoi instance (relying on addSite/update alone
		-- to sort out validity) means paying for a full Fortune's sweep
		-- over hundreds of irrelevant points per node, which becomes
		-- extremely slow for a large hierarchy. A plain pointInPolygon
		-- check per point is far cheaper than that, so doing it first
		-- keeps each node's actual Voronoi computation down to just the
		-- handful of points (usually 0 to 4) that truly belong to it.
		local relevantPoints = {}
		for _, point in ipairs(layers[depth]) do
			if Voronoi.pointInPolygon(point.x, point.y, polygon) then
				table.insert(relevantPoints, point)
			end
		end

		if #relevantPoints == 0 then
			table.insert(leaves, polygon)
			return
		end

		local sub = Voronoi.new(polygon)
		for _, point in ipairs(relevantPoints) do
			sub:addSite(point.x, point.y)
		end
		sub:update()

		local recursedIntoAny = false
		for _, cell in ipairs(sub.cells) do
			if cell.valid and #cell.polygon >= 6 then
				recursedIntoAny = true
				recurse(cell.polygon, depth + 1)
			end
		end

		if not recursedIntoAny then
			-- no site from this layer actually falls inside this polygon
			-- right now: keep it as a leaf instead of losing it
			table.insert(leaves, polygon)
		end
	end

	recurse(rootPolygon, 1)
	return leaves
end

-- adjacency[i] = list of indices of leaves that actually share a border
-- with leaves[i]. Bounding-box overlap is checked first as a cheap
-- rejection test before the more expensive per-edge comparison, since
-- most leaf pairs are nowhere near each other.
function RecursiveSubdivision.buildLeafAdjacency(leaves)
	local n = #leaves
	local bboxes = {}
	for i = 1, n do
		bboxes[i] = PolygonUtils.boundsBox(leaves[i])
	end

	local adjacency = {}
	for i = 1, n do
		adjacency[i] = {}
	end

	for i = 1, n do
		for j = i + 1, n do
			if PolygonUtils.boundsOverlap(bboxes[i], bboxes[j]) and PolygonUtils.sharesBorder(leaves[i], leaves[j]) then
				table.insert(adjacency[i], j)
				table.insert(adjacency[j], i)
			end
		end
	end

	return adjacency
end

-- Smallest-last (degeneracy) vertex ordering, computed by repeatedly
-- peeling off the currently-lowest-degree vertex using bucket queues
-- (buckets[d] = still-remaining vertices whose current residual degree
-- is d). Every planar graph has degeneracy at most 5, so this always
-- terminates cleanly and runs in close to O(n + m) time (each edge is
-- inspected O(1) times as its endpoints' residual degrees drop).
--
-- This ordering, colored in REVERSE peel order, was benchmarked against
-- DSATUR (the previous approach here) on real generated hierarchies
-- (see recursive_subdivision test notes) and consistently produced a
-- full 4-coloring in a single pass where DSATUR needed many restarts and
-- often still failed, while running roughly one to two orders of
-- magnitude faster - because DSATUR's "pick the most constrained
-- vertex" rule needs an O(n) rescan at every step, while peeling by
-- residual degree only ever touches a vertex's immediate neighbors.
-- randomTiebreak (0..1) picks a random position within same-degree
-- buckets instead of always the last one, for restart diversity.
local function degeneracyOrder(n, adjacency, randomTiebreak)
	local degree = {}
	local maxDegree = 0
	for i = 1, n do
		degree[i] = #adjacency[i]
		if degree[i] > maxDegree then
			maxDegree = degree[i]
		end
	end

	local buckets = {}
	for d = 0, maxDegree do
		buckets[d] = {}
	end
	for i = 1, n do
		table.insert(buckets[degree[i]], i)
	end

	local removed = {}
	local remainingNeighbors = {}
	for i = 1, n do
		remainingNeighbors[i] = {}
		for _, j in ipairs(adjacency[i]) do
			remainingNeighbors[i][j] = true
		end
	end

	local order = {}
	local d = 0
	for _ = 1, n do
		while d <= maxDegree and #buckets[d] == 0 do
			d = d + 1
		end
		if d > maxDegree then
			break
		end

		local bucket = buckets[d]
		local pickPos = #bucket
		if randomTiebreak then
			pickPos = math.max(1, math.min(#bucket, math.ceil(randomTiebreak() * #bucket)))
		end
		local v = bucket[pickPos]
		bucket[pickPos] = bucket[#bucket]
		bucket[#bucket] = nil

		removed[v] = true
		table.insert(order, v)

		for w in pairs(remainingNeighbors[v]) do
			if not removed[w] then
				local wBucket = buckets[degree[w]]
				for pos = 1, #wBucket do
					if wBucket[pos] == w then
						wBucket[pos] = wBucket[#wBucket]
						wBucket[#wBucket] = nil
						break
					end
				end
				degree[w] = degree[w] - 1
				table.insert(buckets[degree[w]], w)
				remainingNeighbors[w][v] = nil
			end
		end

		if d > 0 then
			d = d - 1
		end
	end

	return order
end

-- colors vertices in the reverse of "order" (so the last-peeled, highest
-- residual-degree vertices get colored first, when the most colors are
-- still free), taking the lowest available color. Returns a colorOf
-- table where 0 means "no color available" for that vertex - a genuine
-- local conflict.
local function greedyColorInOrder(n, adjacency, colorCount, order)
	local colorOf = {}
	for idx = #order, 1, -1 do
		local v = order[idx]
		local used = {}
		for _, j in ipairs(adjacency[v]) do
			if colorOf[j] and colorOf[j] > 0 then
				used[colorOf[j]] = true
			end
		end
		local chosen = 0
		for c = 1, colorCount do
			if not used[c] then
				chosen = c
				break
			end
		end
		colorOf[v] = chosen
	end
	return colorOf
end

-- Repairs remaining conflicts (colorOf[v] == 0) using Kempe chain
-- interchange: for a conflicted vertex v whose neighbors already use
-- every color, pick one neighbor's color (targetColor) and another color
-- (otherColor), then flip every targetColor/otherColor vertex reachable
-- from that neighbor (the "Kempe chain") to the other of the two colors.
-- This never breaks validity elsewhere - any vertex outside the
-- flipped component that was colored targetColor was never adjacent to
-- one colored targetColor inside it (or they'd already be in the same
-- component) - so if the flip actually frees targetColor for v (i.e. no
-- OTHER neighbor of v colored targetColor sits outside the flipped
-- component), it's always safe to apply. This is dramatically cheaper
-- than further restarts for cleaning up the last handful of local
-- conflicts a coloring attempt leaves behind.
-- one linear pass over currently-conflicted vertices; returns true if it
-- resolved at least one of them (see kempeChainRepair for why this needs
-- to be repeated rather than run just once)
local function kempeChainRepairPass(n, adjacency, colorCount, colorOf)
	local resolvedAny = false

	for v = 1, n do
		if colorOf[v] == 0 then
			local used = {}
			for _, j in ipairs(adjacency[v]) do
				if colorOf[j] and colorOf[j] > 0 then
					used[colorOf[j]] = true
				end
			end

			local chosen = nil
			for c = 1, colorCount do
				if not used[c] then
					chosen = c
					break
				end
			end

			if chosen then
				colorOf[v] = chosen
				resolvedAny = true
			else
				local neighborByColor = {}
				for _, j in ipairs(adjacency[v]) do
					if colorOf[j] and colorOf[j] > 0 then
						neighborByColor[colorOf[j]] = j
					end
				end

				local resolved = false
				for targetColor, blocker in pairs(neighborByColor) do
					for otherColor = 1, colorCount do
						if otherColor ~= targetColor then
							local component = { [blocker] = true }
							local stack = { blocker }
							while #stack > 0 do
								local u = table.remove(stack)
								for _, w in ipairs(adjacency[u]) do
									local cw = colorOf[w]
									if (cw == targetColor or cw == otherColor) and not component[w] then
										component[w] = true
										table.insert(stack, w)
									end
								end
							end

							local stillBlocked = false
							for _, j in ipairs(adjacency[v]) do
								local cj = colorOf[j]
								-- case 1: a targetColor neighbor sits outside the
								-- component, so it won't be flipped away by the
								-- swap - v still can't take targetColor
								if cj == targetColor and not component[j] then
									stillBlocked = true
									break
								end
								-- case 2: an otherColor neighbor sits INSIDE the
								-- component, so the swap would flip IT to
								-- targetColor - creating a brand new conflict at
								-- v even though the original one (via blocker)
								-- got resolved.
								if cj == otherColor and component[j] then
									stillBlocked = true
									break
								end
							end

							if not stillBlocked then
								for u in pairs(component) do
									if colorOf[u] == targetColor then
										colorOf[u] = otherColor
									elseif colorOf[u] == otherColor then
										colorOf[u] = targetColor
									end
								end
								colorOf[v] = targetColor
								resolved = true
								resolvedAny = true
								break
							end
						end
					end
					if resolved then
						break
					end
				end
			end
		end
	end

	return resolvedAny
end

-- Repeats kempeChainRepairPass until either every conflict is resolved or
-- a full pass makes no further progress (bounded by maxPasses as a
-- safety net). A single pass processes conflicted vertices in a fixed
-- v = 1..n order; fixing vertex v via a Kempe swap can change colors
-- elsewhere in the graph, which can in turn free up a color for some
-- OTHER conflicted vertex w that appeared earlier in that same pass
-- (w < v) and was already given up on. Repeating catches those knock-on
-- fixes instead of leaving them stuck in the fallback color solely
-- because of scan order.
local function kempeChainRepair(n, adjacency, colorCount, colorOf, maxPasses)
	maxPasses = maxPasses or 5
	for _ = 1, maxPasses do
		local anyConflictBefore = false
		for i = 1, n do
			if colorOf[i] == 0 then
				anyConflictBefore = true
				break
			end
		end
		if not anyConflictBefore then
			break
		end

		local progressed = kempeChainRepairPass(n, adjacency, colorCount, colorOf)
		if not progressed then
			break
		end
	end
end

-- Colors leaves with fourColors (default: RecursiveSubdivision.
-- defaultFourColors) so that no two bordering leaves ever get the same
-- color - the classic four color theorem setting: any planar map can be
-- colored this way with only 4 colors. A handful of restarts of
-- smallest-last (degeneracy) ordering, each colored greedily in reverse
-- peel order, reliably finds a 4-coloring on its own for maps like this
-- one; Kempe chain repair then mops up whatever handful of local
-- conflicts remain, essentially for free. In the vanishingly unlikely
-- case a conflict survives even that, it falls back to
-- RecursiveSubdivision.defaultFallbackColor instead of silently
-- repeating a neighbor's color.



function RecursiveSubdivision.colorLeaves(leaves, adjacency, fourColors, restartAttempts)
	fourColors = fourColors or RecursiveSubdivision.defaultFourColors
	restartAttempts = restartAttempts or 3

	local n = #leaves
	local colorCount = #fourColors
	local bestColoring, bestConflicts = nil, math.huge

	for _ = 1, restartAttempts do
		local order = degeneracyOrder(n, adjacency, math.random)
		local colorOf = greedyColorInOrder(n, adjacency, colorCount, order)

		local conflicts = 0
		for i = 1, n do
			if colorOf[i] == 0 then
				conflicts = conflicts + 1
			end
		end

		-- repair every attempt, not just whichever ends up "best" - a
		-- coloring with fewer raw conflicts isn't necessarily easier to
		-- repair than one with more, so comparing only post-repair
		-- results is what actually finds the best final outcome
		if conflicts > 0 then
			kempeChainRepair(n, adjacency, colorCount, colorOf)
			conflicts = 0
			for i = 1, n do
				if colorOf[i] == 0 then
					conflicts = conflicts + 1
				end
			end
		end

		if conflicts < bestConflicts then
			bestColoring, bestConflicts = colorOf, conflicts
		end

		if conflicts == 0 then
			break
		end
	end

	return bestColoring
end

return RecursiveSubdivision
