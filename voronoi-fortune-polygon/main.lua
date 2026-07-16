local Voronoi = require("voronoi")
local PolygonUtils = require("polygon_utils")
local RecursiveSubdivision = require("recursive_subdivision")

local diagram
local dragging = nil
local hovered = nil
local showDelaunay = false
local showUI = true

local showRecursive = false
local recursiveLeaves = {}       -- flat list of leaf polygons
local recursiveLeafColors = {}   -- recursiveLeafColors[i] = color index (1-4) for recursiveLeaves[i]
local recursiveLayers = {}       -- recursiveLayers[depth] = { {x=, y=}, ... }, absolute coordinates
local recursiveMaxDepth = 8
local recursiveMaxTotalSites = 3000    -- hard cap on total sites across the whole hierarchy
local recursiveMinAreaFraction = 0.001 -- cells smaller than this fraction of the root's area stop subdividing

local siteRadius = 8
local vertexRadius = 8
local edgeRadius = 6
local dragThreshold = 4


--- demo helpers ---


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

	local hull = PolygonUtils.convexHull(pts)
	local polygon = {}
	for _, p in ipairs(hull) do
		table.insert(polygon, p.x)
		table.insert(polygon, p.y)
	end
	return polygon
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
		local x, y = PolygonUtils.randomPointInPolygon(diagram.boundingPolygon)
		local site = diagram:addSite(x, y)
		if site then site.color = randomColor() end
	end
end

-- one step of Lloyd's relaxation: move every site to the centroid of its
-- own Voronoi cell, then recompute the diagram
local function relaxSites()
	for _, site in ipairs(diagram.sites) do
		if site.valid and site.cell.valid and #site.cell.polygon >= 6 then
			local cx, cy = PolygonUtils.centroid(site.cell.polygon)
			if cx then
				site.x = cx
				site.y = cy
			end
		end
	end
	diagram:update()
end


--- recursive subdivision state ---


-- cheap: only recomputes leaf polygons from the existing (fixed) layer
-- coordinates, so this is safe to call every frame while dragging the
-- outer polygon
local function regenerateRecursiveLeaves()
	recursiveLeaves = RecursiveSubdivision.computeLeaves(diagram.boundingPolygon, recursiveLayers)
end

-- heavier: rebuilds adjacency and re-solves the 4-coloring from scratch.
-- Only called on explicit triggers (reroll, toggling the mode on, a new
-- root polygon, or releasing a drag) rather than on every single drag
-- frame, since it's meaningfully more expensive than
-- regenerateRecursiveLeaves and the leaf boundaries barely change between
-- one drag frame and the next anyway.
local function recolorRecursiveLeaves()
	local adjacency = RecursiveSubdivision.buildLeafAdjacency(recursiveLeaves)
	recursiveLeafColors = RecursiveSubdivision.colorLeaves(recursiveLeaves, adjacency)
end

-- expensive-ish (but still cheap in absolute terms): picks brand new
-- random coordinates for every level, then recomputes leaves and colors
local function rerollRecursiveLayers()
	recursiveLayers = RecursiveSubdivision.generateLayers(
		diagram.boundingPolygon, recursiveMaxDepth, recursiveMaxTotalSites, recursiveMinAreaFraction
	)
	regenerateRecursiveLeaves()
	recolorRecursiveLeaves()
end


--- demo helpers: picking hover/drag targets ---


local function nearestSite(mx, my, radius)
	local nearest, nearestDist
	for _, site in ipairs(diagram.sites) do
		local d = PolygonUtils.distanceSquared(mx, my, site.x, site.y)
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

local function updateHover(x, y)
	hovered = nil

	local site = nearestSite(x, y, siteRadius)
	if site then
		hovered = { type = "site", site = site }
		return
	end

	local vertexIndex = PolygonUtils.nearestVertex(x, y, diagram.boundingPolygon, vertexRadius)
	if vertexIndex then
		hovered = { type = "vertex", index = vertexIndex }
		return
	end

	local edgeIndex = PolygonUtils.nearestEdge(x, y, diagram.boundingPolygon, edgeRadius)
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
		for i, polygon in ipairs(recursiveLeaves) do
			local colorIndex = recursiveLeafColors[i]
			local color = (colorIndex and colorIndex > 0)
				and RecursiveSubdivision.defaultFourColors[colorIndex]
				or RecursiveSubdivision.defaultFallbackColor
			love.graphics.setColor(color)
			love.graphics.polygon("fill", polygon)
		end
		love.graphics.setColor(0, 0, 0, 0.6)
		for _, polygon in ipairs(recursiveLeaves) do
			love.graphics.polygon("line", polygon)
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
		local count = PolygonUtils.vertexCount(diagram.boundingPolygon)
		local i = hovered.index
		local j = (i % count) + 1
		local x1, y1 = PolygonUtils.getVertex(diagram.boundingPolygon, i)
		local x2, y2 = PolygonUtils.getVertex(diagram.boundingPolygon, j)
		love.graphics.setLineWidth(3)
		love.graphics.setColor(1, 0.8, 0.2, 1)
		love.graphics.line(x1, y1, x2, y2)
		love.graphics.setLineWidth(1)
	end

	-- polygon vertex handles
	love.graphics.setColor(1, 1, 1, 0.8)
	local vertexCount = PolygonUtils.vertexCount(diagram.boundingPolygon)
	for i = 1, vertexCount do
		local vx, vy = PolygonUtils.getVertex(diagram.boundingPolygon, i)
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
		local vx, vy = PolygonUtils.getVertex(diagram.boundingPolygon, hovered.index)
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

		local vertexIndex = PolygonUtils.nearestVertex(x, y, diagram.boundingPolygon, vertexRadius)
		if vertexIndex then
			dragging = { type = "vertex", index = vertexIndex }
			return
		end

		local edgeIndex = PolygonUtils.nearestEdge(x, y, diagram.boundingPolygon, edgeRadius)
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

		local vertexIndex = PolygonUtils.nearestVertex(x, y, diagram.boundingPolygon, vertexRadius)
		if vertexIndex then
			if PolygonUtils.removeVertex(diagram.boundingPolygon, vertexIndex) then
				diagram:update()
				hovered = nil
				if showRecursive then
					regenerateRecursiveLeaves()
					recolorRecursiveLeaves()
				end
			end
		end
	end
end

function love.mousereleased(x, y, button)
	if button ~= 1 or not dragging then return end

	local wasDraggingPolygon = dragging.type == "vertex" or dragging.type == "edge"

	if dragging.type == "edge" and not dragging.moved then
		-- the edge was clicked rather than dragged: place a new vertex
		local edgeIndex, px, py = PolygonUtils.nearestEdge(x, y, diagram.boundingPolygon, edgeRadius)
		if edgeIndex then
			PolygonUtils.insertVertex(diagram.boundingPolygon, edgeIndex, px, py)
			diagram:update()
		end
	end

	if showRecursive and wasDraggingPolygon then
		-- leaf boundaries were kept live-updated during the drag itself
		-- (see mousemoved below); now that it's over, solve the
		-- 4-coloring once, rather than on every single drag frame
		recolorRecursiveLeaves()
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
		PolygonUtils.setVertex(diagram.boundingPolygon, dragging.index, x, y)
		diagram:update()
		if showRecursive then
			regenerateRecursiveLeaves()
		end
	elseif dragging.type == "edge" then
		local count = PolygonUtils.vertexCount(diagram.boundingPolygon)
		local i = dragging.index
		local j = (i % count) + 1
		local x1, y1 = PolygonUtils.getVertex(diagram.boundingPolygon, i)
		local x2, y2 = PolygonUtils.getVertex(diagram.boundingPolygon, j)
		PolygonUtils.setVertex(diagram.boundingPolygon, i, x1 + dx, y1 + dy)
		PolygonUtils.setVertex(diagram.boundingPolygon, j, x2 + dx, y2 + dy)

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
			recolorRecursiveLeaves()
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
				recolorRecursiveLeaves()
			end
		end
	elseif key == "8" then
		-- reroll: brand new random sites at every level, keeping the
		-- current bounding polygon as the root
		showRecursive = true
		diagram:clearSites()
		rerollRecursiveLayers()
	end
end
