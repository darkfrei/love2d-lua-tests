local Voronoi = require("voronoi")

local diagram
local dragging = nil
local hovered = nil
local showDelaunay = false
local showUI = true

local showRecursive = false
local recursiveLeaves = {}
local recursiveLayers = {}   -- recursiveLayers[depth] = { {x=, y=, color=}, ... }, absolute coordinates
local recursiveMaxDepth = 8
local recursiveRootColor = { 0.5, 0.5, 0.5 }
-- weighted odds for how many sites subdivide each cell, at every level
-- including the root: mostly 2, sometimes 3, rarely 4
local recursiveCountWeights = { { count = 2, weight = 65 }, { count = 3, weight = 28 }, { count = 4, weight = 7 } }

local siteRadius = 8
local vertexRadius = 8
local edgeRadius = 6
local dragThreshold = 4


--- demo helpers: bounding box construction ---


local function convexHull(points)
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

local function randomBoundingPolygon()
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	local margin = math.min(width, height) * 0.05

	-- scale radii to each axis separately so the polygon fills most of the
	-- window on both wide and tall aspect ratios, not just a circle capped
	-- by the smaller dimension
	local maxRx = width / 2 - margin
	local maxRy = height / 2 - margin
	local rx = maxRx * (0.75 + math.random() * 0.25) -- 75% to 100% of available half-width
	local ry = maxRy * (0.75 + math.random() * 0.25) -- 75% to 100% of available half-height

	-- let the center drift within whatever room rx/ry left, so the polygon
	-- isn't glued to the exact same spot on every press, while still
	-- guaranteed to stay fully inside the window
	local cx = width / 2 + (math.random() * 2 - 1) * (maxRx - rx)
	local cy = height / 2 + (math.random() * 2 - 1) * (maxRy - ry)

	local pts = {}
	for _ = 1, 12 do
		local ang = math.random() * math.pi * 2
		local r = 0.85 + math.random() * 0.15 -- mild irregularity, not a perfect ellipse
		table.insert(pts, { x = cx + math.cos(ang) * rx * r, y = cy + math.sin(ang) * ry * r })
	end

	local hull = convexHull(pts)
	local polygon = {}
	for _, p in ipairs(hull) do
		table.insert(polygon, p.x)
		table.insert(polygon, p.y)
	end
	return polygon
end

local function polygonBoundsBox(polygon)
	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	for i = 1, #polygon, 2 do
		minX = math.min(minX, polygon[i])
		maxX = math.max(maxX, polygon[i])
		minY = math.min(minY, polygon[i + 1])
		maxY = math.max(maxY, polygon[i + 1])
	end
	return minX, minY, maxX, maxY
end

local function randomSiteInPolygon(polygon)
	local minX, minY, maxX, maxY = polygonBoundsBox(polygon)
	for _ = 1, 1000 do
		-- math.random(minX, maxX) alone returns an integer, which makes exact
		-- coordinate ties and exact collinear triples surprisingly likely
		-- with many sites; a sub-pixel fractional jitter avoids that
		-- (matches the original prototype's fix for the same problem)
		local x = math.random(minX, maxX) + math.random()
		local y = math.random(minY, maxY) + math.random()
		if Voronoi.pointInPolygon(x, y, polygon) then
			return x, y
		end
	end
	return (minX + maxX) / 2, (minY + maxY) / 2
end

local function randomColor()
	return { math.random() * 0.6 + 0.3, math.random() * 0.6 + 0.3, math.random() * 0.6 + 0.3 }
end

-- scales the default number of sites with the window area, so a small
-- window and a FullHD window both end up with a reasonably filled diagram
local function defaultSiteCount()
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	local count = math.floor(width * height / 40000)
	return math.max(20, math.min(count, 200))
end

local function populate(count)
	for _ = 1, count do
		local x, y = randomSiteInPolygon(diagram.boundingPolygon)
		local site = diagram:addSite(x, y)
		if site then site.color = randomColor() end
	end
end

-- area-weighted centroid of a flat {x1, y1, x2, y2, ...} polygon;
-- returns nil for a degenerate (near zero area) polygon
local function polygonCentroid(polygon)
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

-- one step of Lloyd's relaxation: move every site to the centroid of its
-- own Voronoi cell, then recompute the diagram
local function relaxSites()
	for _, site in ipairs(diagram.sites) do
		if site.valid and site.cell.valid and #site.cell.polygon >= 6 then
			local cx, cy = polygonCentroid(site.cell.polygon)
			if cx then
				site.x = cx
				site.y = cy
			end
		end
	end
	diagram:update()
end

-- Generates fixed, absolute-coordinate site positions for every level of
-- the recursive hierarchy. These positions never move by themselves once
-- generated; only an explicit reroll (key 8) replaces them. Only layer 1
-- gets a persistent color per site - deeper levels inherit their layer-1
-- ancestor's color, so recomputing the hierarchy every frame (e.g. while
-- dragging the outer polygon) never causes colors to flicker.
--
-- This actually walks down the tree at generation time (using a
-- throwaway Voronoi instance per branch, just to learn each branch's
-- current cell shapes) and places "sitesPerCell" points strictly inside
-- EVERY polygon it visits. This matters: if points were instead scattered
-- independently over the whole root polygon regardless of actual cell
-- shapes at that depth, plain bad luck could leave some cells (usually
-- small ones, or ones far from the root's centroid) with zero points at
-- the next level, so they would never subdivide further and would show
-- up as a flat, unsubdivided patch. Guaranteeing coverage per cell at
-- generation time avoids that, while the later recompute step still only
-- ever checks membership dynamically (see computeRecursiveLeaves below),
-- which is what keeps dragging safe.
local function generateRecursiveLayers(rootPolygon, maxDepth)
	local layers = {}

	for depth = 1, maxDepth do
		layers[depth] = {}
	end

	local estimatedCells = 1

	for depth = 1, maxDepth do
		local countPerCell = 2

		local r = math.random(100)

		if r > 93 then
			countPerCell = 4
		elseif r > 65 then
			countPerCell = 3
		end

		local pointCount = estimatedCells * countPerCell

		for _ = 1, pointCount do
			local x, y = randomSiteInPolygon(rootPolygon)

			local point = {
				x = x,
				y = y
			}

			if depth == 1 then
				point.color = randomColor()
			end

			table.insert(layers[depth], point)
		end

		estimatedCells = estimatedCells * countPerCell
	end

	return layers
end

-- Recomputes the whole hierarchy from scratch: the current root polygon
-- plus the fixed site coordinates in recursiveLayers. A site at layer N
-- is only ever considered to subdivide whichever layer-(N-1) cell it
-- geometrically falls inside RIGHT NOW - this uses the library's normal
-- site.valid / pointInPolygon check, nothing custom. This means dragging
-- the outer polygon (or, in principle, any upper-level site) never
-- corrupts anything: cells simply reshape around the fixed points, a
-- point that no longer falls inside any cell just stops contributing,
-- and a point that drifts into a different cell than before "belongs" to
-- that cell instead, automatically, on the very next recompute.
--
-- This works with zero changes to the library because a cell polygon of
-- a convex-bounded diagram is always itself convex (the intersection of
-- convex regions is convex), so it is always a valid boundingPolygon for
-- a fresh Voronoi.new(...) instance.
local function computeRecursiveLeaves(rootPolygon, layers)
	local leaves = {}

	local function recurse(polygon, depth, color)
		if depth > #layers then
			table.insert(leaves, { polygon = polygon, color = color or recursiveRootColor })
			return
		end

		local sub = Voronoi.new(polygon)
		local siteToPoint = {}
		for _, point in ipairs(layers[depth]) do
			local site = sub:addSite(point.x, point.y)
			if site then
				siteToPoint[site] = point
			end
		end
		sub:update()

		local recursedIntoAny = false
		for _, cell in ipairs(sub.cells) do
			if cell.valid and #cell.polygon >= 6 then
				recursedIntoAny = true
				local childColor = color
				if depth == 1 then
					local point = siteToPoint[cell.site]
					childColor = point and point.color or color
				end
				recurse(cell.polygon, depth + 1, childColor)
			end
		end

		if not recursedIntoAny then
			-- no site from this layer actually falls inside this polygon
			-- right now: keep it as a leaf instead of losing it
			table.insert(leaves, { polygon = polygon, color = color or recursiveRootColor })
		end
	end

	recurse(rootPolygon, 1, nil)
	return leaves
end

-- cheap: only recomputes from the existing (fixed) layer coordinates, so
-- this is safe to call every frame while dragging the outer polygon
local function regenerateRecursiveLeaves()
	recursiveLeaves = computeRecursiveLeaves(diagram.boundingPolygon, recursiveLayers)
end

-- expensive-ish (but still cheap in absolute terms): picks brand new
-- random coordinates and colors for every level, then recomputes
local function rerollRecursiveLayers()
	recursiveRootColor = randomColor()
	recursiveLayers = generateRecursiveLayers(diagram.boundingPolygon, recursiveMaxDepth)
	regenerateRecursiveLeaves()
end


--- demo helpers: picking and editing the bounding polygon ---


local function distanceSquared(x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	return dx * dx + dy * dy
end

local function polygonVertexCount(polygon)
	return #polygon / 2
end

local function getPolygonVertex(polygon, index)
	return polygon[index * 2 - 1], polygon[index * 2]
end

local function setPolygonVertex(polygon, index, x, y)
	polygon[index * 2 - 1] = x
	polygon[index * 2] = y
end

-- inserts a new vertex right after vertex "edgeIndex" (i.e. on the edge
-- between edgeIndex and edgeIndex + 1, wrapping around at the end)
local function insertPolygonVertex(polygon, edgeIndex, x, y)
	local pos = edgeIndex * 2 + 1
	table.insert(polygon, pos, x)
	table.insert(polygon, pos + 1, y)
end

-- removes a vertex, refusing to shrink the polygon below a triangle
local function removePolygonVertex(polygon, index)
	if polygonVertexCount(polygon) <= 3 then
		return false
	end
	local posX = index * 2 - 1
	table.remove(polygon, posX + 1) -- remove y first, then x
	table.remove(polygon, posX)
	return true
end

local function nearestSite(mx, my, radius)
	local nearest, nearestDist
	for _, site in ipairs(diagram.sites) do
		local d = distanceSquared(mx, my, site.x, site.y)
		if not nearestDist or d < nearestDist then
			nearestDist = d
			nearest = site
		end
	end
	if nearest and nearestDist < radius * radius then
		return nearest
	end
	return nil
end

local function nearestPolygonVertex(mx, my, polygon, radius)
	local count = polygonVertexCount(polygon)
	local bestIndex, bestDist
	for i = 1, count do
		local vx, vy = getPolygonVertex(polygon, i)
		local d = distanceSquared(mx, my, vx, vy)
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
local function nearestPolygonEdge(mx, my, polygon, radius)
	local count = polygonVertexCount(polygon)
	local bestIndex, bestDist, bestX, bestY
	for i = 1, count do
		local j = (i % count) + 1
		local x1, y1 = getPolygonVertex(polygon, i)
		local x2, y2 = getPolygonVertex(polygon, j)
		local dx, dy = x2 - x1, y2 - y1
		local lenSq = dx * dx + dy * dy
		local t = 0
		if lenSq > 0 then
			t = ((mx - x1) * dx + (my - y1) * dy) / lenSq
			t = math.max(0, math.min(1, t))
		end
		local px, py = x1 + t * dx, y1 + t * dy
		local d = distanceSquared(mx, my, px, py)
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

local function updateHover(x, y)
	hovered = nil

	local site = nearestSite(x, y, siteRadius)
	if site then
		hovered = { type = "site", site = site }
		return
	end

	local vertexIndex = nearestPolygonVertex(x, y, diagram.boundingPolygon, vertexRadius)
	if vertexIndex then
		hovered = { type = "vertex", index = vertexIndex }
		return
	end

	local edgeIndex = nearestPolygonEdge(x, y, diagram.boundingPolygon, edgeRadius)
	if edgeIndex then
		hovered = { type = "edge", index = edgeIndex }
	end
end


--- callbacks ---


function love.load()
	love.window.setTitle("Fortune's Voronoi - convex polygon demo")
	math.randomseed(os.time())

	diagram = Voronoi.new(randomBoundingPolygon())
	populate(defaultSiteCount())
	diagram:update()
end

function love.draw()
	love.graphics.clear(0.1, 0.1, 0.12)

	if showRecursive then
		for _, leaf in ipairs(recursiveLeaves) do
			love.graphics.setColor(leaf.color)
			love.graphics.polygon("fill", leaf.polygon)
		end
		love.graphics.setColor(0, 0, 0, 0.6)
		for _, leaf in ipairs(recursiveLeaves) do
			love.graphics.polygon("line", leaf.polygon)
		end
	else
		for _, cell in ipairs(diagram.cells) do
			if cell.valid and cell.site.color then
				love.graphics.setColor(cell.site.color)
				love.graphics.polygon("fill", cell.polygon)
			end
		end

		love.graphics.setColor(0, 0, 0, 0.6)
		for _, cell in ipairs(diagram.cells) do
			if cell.valid then
				love.graphics.polygon("line", cell.polygon)
			end
		end
	end

	love.graphics.setColor(1, 1, 1, 0.5)
	diagram:drawBoundingPolygon("line")

	if showDelaunay and not showRecursive then
		love.graphics.setColor(0.3, 0.9, 1, 0.8)
		diagram:drawDelaunay()
	end

	-- highlight the hovered or actively dragged polygon edge
	if hovered and hovered.type == "edge" then
		local count = polygonVertexCount(diagram.boundingPolygon)
		local i = hovered.index
		local j = (i % count) + 1
		local x1, y1 = getPolygonVertex(diagram.boundingPolygon, i)
		local x2, y2 = getPolygonVertex(diagram.boundingPolygon, j)
		love.graphics.setLineWidth(3)
		love.graphics.setColor(1, 0.8, 0.2, 1)
		love.graphics.line(x1, y1, x2, y2)
		love.graphics.setLineWidth(1)
	end

	-- polygon vertex handles
	love.graphics.setColor(1, 1, 1, 0.8)
	local vertexCount = polygonVertexCount(diagram.boundingPolygon)
	for i = 1, vertexCount do
		local vx, vy = getPolygonVertex(diagram.boundingPolygon, i)
		love.graphics.circle("fill", vx, vy, 3)
	end

	if not showRecursive then
		love.graphics.setColor(1, 1, 1)
		diagram:drawSites("fill", 3)
	end

	-- highlight the hovered or actively dragged site
	if hovered and hovered.type == "site" then
		love.graphics.setColor(1, 0.8, 0.2, 1)
		love.graphics.circle("line", hovered.site.x, hovered.site.y, 8)
	end

	-- highlight the hovered or actively dragged polygon vertex
	if hovered and hovered.type == "vertex" then
		local vx, vy = getPolygonVertex(diagram.boundingPolygon, hovered.index)
		love.graphics.setColor(1, 0.8, 0.2, 1)
		love.graphics.circle("line", vx, vy, 8)
	end

	-- "1" toggles only this instructions overlay; editing (handles,
	-- hover highlights, dragging) always stays fully functional and visible
	if showUI then
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(
			"Left click empty space: add site   Left drag: move site, vertex, or edge\n"
			.. "Short left click on edge: add vertex   Right click: delete site or vertex\n"
			.. "1: toggle this text   2: new polygon   3: new sites   4: clear sites\n"
			.. "5: relax sites (Lloyd)   6: toggle Delaunay overlay\n"
			.. "7: toggle recursive subdivision   8: reroll recursive subdivision"
			.. (showRecursive and ("   (depth " .. recursiveMaxDepth .. ", " .. #recursiveLeaves .. " cells)") or ""),
			10, 10
		)
	end
end

function love.mousepressed(x, y, button)
	if button == 1 then
		local site = nearestSite(x, y, siteRadius)
		if site then
			dragging = { type = "site", site = site }
			return
		end

		local vertexIndex = nearestPolygonVertex(x, y, diagram.boundingPolygon, vertexRadius)
		if vertexIndex then
			dragging = { type = "vertex", index = vertexIndex }
			return
		end

		local edgeIndex = nearestPolygonEdge(x, y, diagram.boundingPolygon, edgeRadius)
		if edgeIndex then
			dragging = { type = "edge", index = edgeIndex, startX = x, startY = y, moved = false }
			return
		end

		if not showRecursive and Voronoi.pointInPolygon(x, y, diagram.boundingPolygon) then
			local newSite = diagram:addSite(x, y)
			if newSite then
				newSite.color = randomColor()
				diagram:update()
			end
		end
	elseif button == 2 then
		local site = nearestSite(x, y, siteRadius)
		if site then
			for i, s in ipairs(diagram.sites) do
				if s == site then
					diagram:removeSiteByIndex(i)
					diagram:update()
					hovered = nil
					return
				end
			end
		end

		local vertexIndex = nearestPolygonVertex(x, y, diagram.boundingPolygon, vertexRadius)
		if vertexIndex then
			if removePolygonVertex(diagram.boundingPolygon, vertexIndex) then
				diagram:update()
				hovered = nil
				if showRecursive then
					regenerateRecursiveLeaves()
				end
			end
		end
	end
end

function love.mousereleased(x, y, button)
	if button ~= 1 or not dragging then return end

	if dragging.type == "edge" and not dragging.moved then
		-- the edge was clicked rather than dragged: place a new vertex
		local edgeIndex, px, py = nearestPolygonEdge(x, y, diagram.boundingPolygon, edgeRadius)
		if edgeIndex then
			insertPolygonVertex(diagram.boundingPolygon, edgeIndex, px, py)
			diagram:update()
		end
	end

	dragging = nil
	updateHover(x, y)
end

function love.mousemoved(x, y, dx, dy)
	if not dragging then
		updateHover(x, y)
		return
	end

	if dragging.type == "site" then
		dragging.site.x = x
		dragging.site.y = y
		diagram:update()
	elseif dragging.type == "vertex" then
		setPolygonVertex(diagram.boundingPolygon, dragging.index, x, y)
		diagram:update()
		if showRecursive then
			regenerateRecursiveLeaves()
		end
	elseif dragging.type == "edge" then
		local count = polygonVertexCount(diagram.boundingPolygon)
		local i = dragging.index
		local j = (i % count) + 1
		local x1, y1 = getPolygonVertex(diagram.boundingPolygon, i)
		local x2, y2 = getPolygonVertex(diagram.boundingPolygon, j)
		setPolygonVertex(diagram.boundingPolygon, i, x1 + dx, y1 + dy)
		setPolygonVertex(diagram.boundingPolygon, j, x2 + dx, y2 + dy)

		if not dragging.moved then
			local totalDX = x - dragging.startX
			local totalDY = y - dragging.startY
			if totalDX * totalDX + totalDY * totalDY > dragThreshold * dragThreshold then
				dragging.moved = true
			end
		end

		diagram:update()
		if showRecursive then
			regenerateRecursiveLeaves()
		end
	end
end

function love.keypressed(key)
	if key == "1" then
		showUI = not showUI
	elseif key == "2" then
		-- new bounding polygon, keep the existing sites
		diagram:setBoundingPolygon(randomBoundingPolygon())
		diagram:update()
		hovered = nil
		dragging = nil
		if showRecursive then
			-- same fixed layer coordinates, just recomputed against the
			-- new root shape - points outside it simply stop contributing
			regenerateRecursiveLeaves()
		end
	elseif key == "3" then
		-- new sites, keep the existing bounding polygon
		diagram:clearSites()
		populate(defaultSiteCount())
		diagram:update()
		hovered = nil
		dragging = nil
	elseif key == "4" then
		-- clear all sites
		diagram:clearSites()
		diagram:update()
		hovered = nil
		dragging = nil
	elseif key == "5" then
		-- relax sites: one step of Lloyd's algorithm
		relaxSites()
	elseif key == "6" then
		showDelaunay = not showDelaunay
	elseif key == "7" then
		-- toggle recursive subdivision mode: repeatedly treat each cell as
		-- a new bounding polygon for the next level's sites
		showRecursive = not showRecursive
		if showRecursive then
			diagram:clearSites()
			if #recursiveLayers == 0 then
				rerollRecursiveLayers()
			else
				-- reuse the existing fixed layer coordinates, recomputed
				-- against whatever the root polygon looks like right now
				regenerateRecursiveLeaves()
			end
		end
	elseif key == "8" then
		-- reroll: brand new random sites (and colors) at every level,
		-- keeping the current bounding polygon as the root
		showRecursive = true
		diagram:clearSites()
		rerollRecursiveLayers()
	end
end