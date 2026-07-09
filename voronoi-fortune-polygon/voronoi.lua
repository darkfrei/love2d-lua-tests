--[[
	Voronoi diagram library (Fortune's sweep-line + half-plane clipping)

	Design:
	- Fortune's algorithm is used ONLY to find the Delaunay neighbor graph
	  (who borders whom) in O(n log n). No edge geometry is tracked during
	  the sweep - we don't need it, because...
	- ...the actual cell shape is computed afterwards by clipping the
	  bounding polygon against the perpendicular bisector of each site and
	  its neighbors (Sutherland-Hodgman half-plane clipping). This works
	  for ANY convex bounding polygon, not just rectangles.
	- If Fortune's finds no neighbors for some site (should be rare -
	  isolated site, degenerate input), a safety-net fallback clips
	  against every other valid site instead.

	Limitations:
	- boundingPolygon must be convex (checked, warns if not).
	- Sites with identical x coordinates are nudged by a tiny epsilon
	  internally to keep the sweep well-defined; this does not affect
	  the coordinates you get back, only internal tie-breaking.
]]

local Voronoi = {}
Voronoi.__index = Voronoi

local defaultBoundingPolygon = {50, 50, 750, 50, 750, 550, 50, 550}

----------------------------------------
------------- geometry utils -----------
----------------------------------------

local function clipByHalfPlane(polygon, pointA, pointB)
	local tx = pointB.y - pointA.y
	local ty = pointA.x - pointB.x
	local length = math.sqrt(tx^2 + ty^2)
	tx = tx / length
	ty = ty / length

	local clippedPolygon = {}

	for i = 1, #polygon - 1, 2 do
		local j = ((i + 1) % #polygon) + 1
		local x1, y1 = polygon[i], polygon[i + 1]
		local x2, y2 = polygon[j], polygon[j + 1]
		local side1 = (x1 - pointA.x) * tx + (y1 - pointA.y) * ty
		local side2 = (x2 - pointA.x) * tx + (y2 - pointA.y) * ty

		if side1 <= 0 then
			table.insert(clippedPolygon, x1)
			table.insert(clippedPolygon, y1)
		end

		if side1 * side2 < 0 then
			local t = side1 / (side1 - side2)
			local ix = x1 + t * (x2 - x1)
			local iy = y1 + t * (y2 - y1)
			table.insert(clippedPolygon, ix)
			table.insert(clippedPolygon, iy)
		end
	end

	return clippedPolygon
end

local function pointInPolygon(x, y, polygon)
	local inside = false
	for i = 1, #polygon - 1, 2 do
		local j = ((i + 1) % #polygon) + 1
		local x1, y1 = polygon[i], polygon[i + 1]
		local x2, y2 = polygon[j], polygon[j + 1]
		local isBetweenY = ((y1 > y) ~= (y2 > y))
		local isLeftX = (x < (x2 - x1) * (y - y1) / (y2 - y1) + x1)
		if isBetweenY and isLeftX then
			inside = not inside
		end
	end
	return inside
end

local function isConvex(polygon)
	local n = #polygon / 2
	if n < 3 then return false end
	local sign = 0
	for i = 0, n - 1 do
		local x1, y1 = polygon[i * 2 + 1], polygon[i * 2 + 2]
		local i2 = (i + 1) % n
		local x2, y2 = polygon[i2 * 2 + 1], polygon[i2 * 2 + 2]
		local i3 = (i + 2) % n
		local x3, y3 = polygon[i3 * 2 + 1], polygon[i3 * 2 + 2]
		local cross = (x2 - x1) * (y3 - y2) - (y2 - y1) * (x3 - x2)
		if cross ~= 0 then
			local s = cross > 0 and 1 or -1
			if sign == 0 then
				sign = s
			elseif sign ~= s then
				return false
			end
		end
	end
	return true
end

local function squaredLength(x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	return dx * dx + dy * dy
end

local function pointToLineDistance(px, py, x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	if dx == 0 and dy == 0 then
		return math.sqrt((px - x1) ^ 2 + (py - y1) ^ 2)
	end
	local t = ((px - x1) * dx + (py - y1) * dy) / (dx * dx + dy * dy)
	t = math.max(0, math.min(1, t))
	local closestX = x1 + t * dx
	local closestY = y1 + t * dy
	return math.sqrt((px - closestX) ^ 2 + (py - closestY) ^ 2)
end

----------------------------------------
--------- min-heap (priority queue) -----
----------------------------------------

local Heap = {}
Heap.__index = Heap

function Heap.new()
	return setmetatable({ data = {} }, Heap)
end

function Heap:push(item, priority)
	local data = self.data
	data[#data + 1] = { priority = priority, item = item }
	local i = #data
	while i > 1 do
		local parent = math.floor(i / 2)
		if data[parent].priority > data[i].priority then
			data[parent], data[i] = data[i], data[parent]
			i = parent
		else
			break
		end
	end
end

function Heap:pop()
	local data = self.data
	local n = #data
	if n == 0 then return nil end
	local top = data[1]
	data[1] = data[n]
	data[n] = nil
	n = n - 1
	local i = 1
	while true do
		local l, r = 2 * i, 2 * i + 1
		local smallest = i
		if l <= n and data[l].priority < data[smallest].priority then smallest = l end
		if r <= n and data[r].priority < data[smallest].priority then smallest = r end
		if smallest == i then break end
		data[i], data[smallest] = data[smallest], data[i]
		i = smallest
	end
	return top.item, top.priority
end

function Heap:isEmpty()
	return #self.data == 0
end

----------------------------------------
-- Fortune's sweep: topology only ------
-- returns list of {a=site, b=site} pairs
----------------------------------------

local function newArc(shadowPoint)
	return {
		x = shadowPoint.x,
		y = shadowPoint.y,
		site = shadowPoint.site,
		prev = nil,
		next = nil,
		event = nil,
	}
end

local function blInsertAfter(beachline, node, shadowPoint)
	local newNode = newArc(shadowPoint)
	newNode.prev = node
	newNode.next = node.next
	node.next = newNode
	if node == beachline.last then
		beachline.last = newNode
	else
		newNode.next.prev = newNode
	end
	return newNode
end

local function blInsertAtStart(beachline, shadowPoint)
	local newNode = newArc(shadowPoint)
	newNode.next = beachline.first
	if not beachline.first then
		beachline.first = newNode
		beachline.last = newNode
	else
		beachline.first.prev = newNode
		beachline.first = newNode
	end
	return newNode
end

local function blInsertAtEnd(beachline, shadowPoint)
	local newNode = newArc(shadowPoint)
	newNode.prev = beachline.last
	if not beachline.last then
		beachline.first = newNode
		beachline.last = newNode
	else
		beachline.last.next = newNode
		beachline.last = newNode
	end
	return newNode
end

local function blDelete(beachline, node)
	if node == beachline.first then
		beachline.first = node.next
	else
		node.prev.next = node.next
	end
	if node == beachline.last then
		beachline.last = node.prev
	else
		node.next.prev = node.prev
	end
end

local function intersection(p0, p1, l)
	local res = {}
	local p = { x = p0.x, y = p0.y }

	if p0.x == p1.x then
		res.y = (p0.y + p1.y) / 2
	elseif p1.x == l then
		res.y = p1.y
	elseif p0.x == l then
		res.y = p0.y
		p = p1
	else
		local z0 = 2 * (p0.x - l)
		local z1 = 2 * (p1.x - l)
		local a = 1 / z0 - 1 / z1
		local b = -2 * (p0.y / z0 - p1.y / z1)
		local c = (p0.y * p0.y + p0.x * p0.x - l * l) / z0 - (p1.y * p1.y + p1.x * p1.x - l * l) / z1
		res.y = (-b - math.sqrt(b * b - 4 * a * c)) / (2 * a)
	end

	res.x = (p.x * p.x + (p.y - res.y) * (p.y - res.y) - l * l) / (2 * p.x - 2 * l)
	return res
end

local function intersect(point, arc)
	if arc.x == point.x then return false end

	local a, b
	if arc.prev then a = intersection(arc.prev, arc, point.x).y end
	if arc.next then b = intersection(arc, arc.next, point.x).y end

	if (not arc.prev or a <= point.y) and (not arc.next or point.y <= b) then
		local resY = point.y
		local resX = (arc.x * arc.x + (arc.y - resY) * (arc.y - resY) - point.x * point.x) / (2 * arc.x - 2 * point.x)
		return { x = resX, y = resY }
	end
	return false
end

local function checkCircleEvent(events, arc, x0)
	if arc.event and arc.event.x ~= x0 then
		arc.event.valid = false
	end
	arc.event = nil

	if not arc.prev or not arc.next then return end

	local a, b, c = arc.prev, arc, arc.next
	if (b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y) >= 0 then return end

	local A = b.x - a.x
	local B = b.y - a.y
	local C = c.x - a.x
	local D = c.y - a.y
	local E = A * (a.x + b.x) + B * (a.y + b.y)
	local F = C * (a.x + c.x) + D * (a.y + c.y)
	local G = 2 * (A * (c.y - b.y) - B * (c.x - b.x))

	if math.abs(G) < 1e-9 then return end -- (near-)collinear, no reliable circle event

	local ox = (D * E - B * F) / G
	local oy = (A * F - C * E) / G
	local x = ox + math.sqrt((a.x - ox) ^ 2 + (a.y - oy) ^ 2)

	if x > x0 then
		local event = { x = ox, y = oy, arc = arc, valid = true, isCircle = true }
		arc.event = event
		events:push(event, x)
	end
end

local function processPoint(beachline, events, pairsOut, point)
	if not beachline.first then
		blInsertAtStart(beachline, point)
		return
	end

	local arc = beachline.first
	while arc do
		local z = intersect(point, arc)
		if z then
			if not (arc.next and intersect(point, arc.next)) then
				blInsertAfter(beachline, arc, arc) -- duplicate arc's site
			else
				return
			end

			pairsOut[#pairsOut + 1] = { a = point.site, b = arc.site }

			blInsertAfter(beachline, arc, point)

			checkCircleEvent(events, arc, point.x)
			checkCircleEvent(events, arc.next, point.x)
			checkCircleEvent(events, arc.next.next, point.x)
			return
		end
		arc = arc.next
	end

	-- point's height never intersected any arc: borders the current last arc
	local previousLast = beachline.last
	blInsertAtEnd(beachline, point)
	if previousLast then
		pairsOut[#pairsOut + 1] = { a = point.site, b = previousLast.site }
	end
end

local function processEvent(beachline, events, pairsOut, event)
	if not event.valid then return end
	local arc = event.arc

	blDelete(beachline, arc)

	if arc.prev and arc.next then
		pairsOut[#pairsOut + 1] = { a = arc.prev.site, b = arc.next.site }
	end

	if arc.prev then checkCircleEvent(events, arc.prev, event.x) end
	if arc.next then checkCircleEvent(events, arc.next, event.x) end
end

local function computeDelaunayNeighbors(shadowPoints)
	if #shadowPoints < 2 then return {} end

	local beachline = { first = nil, last = nil }
	local events = Heap.new()
	local pairsOut = {}

	for _, p in ipairs(shadowPoints) do
		events:push(p, p.x)
	end

	while not events:isEmpty() do
		local item, x = events:pop()
		if item.isCircle then
			processEvent(beachline, events, pairsOut, item)
		else
			processPoint(beachline, events, pairsOut, item)
		end
	end

	return pairsOut
end

local function buildShadowPoints(validSites)
	local EPS = 1e-6
	local shadow = {}
	local usedX = {}
	for i, site in ipairs(validSites) do
		local x = site.x
		while usedX[x] do
			x = x + EPS
		end
		usedX[x] = true
		shadow[i] = { x = x, y = site.y, site = site }
	end
	return shadow
end

----------------------------------------
--------------- Voronoi ----------------
----------------------------------------

function Voronoi.new(boundingPolygon)
	local diagram = setmetatable({
			sites = {},
			cells = {},
			vertices = {},
			edges = {},
			delaunayEdges = {},
			lastFallbackCount = 0,
			boundingPolygon = defaultBoundingPolygon,
			}, Voronoi)

	if boundingPolygon then
		diagram:setBoundingPolygon(boundingPolygon)
	end

	return diagram
end

function Voronoi:setBoundingPolygon(polygon)
	if type(polygon) ~= "table" or #polygon < 6 or #polygon % 2 ~= 0 then
		error("bounding polygon must be a flat {x1,y1,x2,y2,...} table with at least 3 vertices")
	end
	if not isConvex(polygon) then
		print("Voronoi: warning - bounding polygon is not convex; results are only guaranteed for convex polygons")
	end
	self.boundingPolygon = polygon
end

function Voronoi:addSite(x, y)
	for _, site in ipairs(self.sites) do
		if site.x == x and site.y == y then
			return nil -- duplicate coordinates, ignored
		end
	end

	local site = { x = x, y = y, valid = pointInPolygon(x, y, self.boundingPolygon) }
	local cell = { site = site, polygon = {}, vertices = {}, edges = {} }
	site.cell = cell

	table.insert(self.sites, site)
	table.insert(self.cells, cell)
	return site
end

function Voronoi:addSites(list)
	for _, p in ipairs(list) do
		self:addSite(p.x, p.y)
	end
end

function Voronoi:removeSiteByIndex(index)
	if index >= 1 and index <= #self.sites then
		table.remove(self.sites, index)
		table.remove(self.cells, index)
	else
		error("invalid site index")
	end
end

function Voronoi:removeLastSite()
	if #self.sites > 0 then
		table.remove(self.sites)
		table.remove(self.cells)
	end
end

function Voronoi:clearSites()
	self.sites = {}
	self.cells = {}
end

function Voronoi:updateSiteValids()
	for _, site in ipairs(self.sites) do
		site.valid = pointInPolygon(site.x, site.y, self.boundingPolygon)
	end
end

function Voronoi:updateVertices()
	self.vertices = {}
	local vertexHash = {}

	for _, cell in ipairs(self.cells) do
		cell.vertices = {}
		local cellPolygon = cell.valid and cell.polygon or {}
		for j = 1, #cellPolygon - 1, 2 do
			local x, y = cellPolygon[j], cellPolygon[j + 1]
			local hashKey = string.format("%.2f:%.2f", x, y)
			if vertexHash[hashKey] then
				local vertex = vertexHash[hashKey]
				table.insert(vertex.cells, cell)
				table.insert(cell.vertices, vertex)
			else
				local vertex = {
					x = x, y = y,
					edges = {},
					cells = {},
					id = #self.vertices + 1,
				}
				table.insert(vertex.cells, cell)
				table.insert(cell.vertices, vertex)
				table.insert(self.vertices, vertex)
				vertexHash[hashKey] = vertex
			end
		end
	end
end

local function getEdgeHash(v1, v2)
	if v1.id < v2.id then
		return string.format("%d:%d", v1.id, v2.id)
	else
		return string.format("%d:%d", v2.id, v1.id)
	end
end

function Voronoi:updateEdges()
	self.edges = {}
	local edgeHash = {}

	for _, cell in ipairs(self.cells) do
		if cell.valid and #cell.vertices > 2 then
			for i = 1, #cell.vertices do
				local j = (i % #cell.vertices) + 1
				local vertexA = cell.vertices[i]
				local vertexB = cell.vertices[j]
				local edgeKey = getEdgeHash(vertexA, vertexB)

				if edgeHash[edgeKey] then
					local edge = edgeHash[edgeKey]
					table.insert(edge.cells, cell)
					table.insert(cell.edges, edge)
					table.insert(vertexA.edges, edge)
					table.insert(vertexB.edges, edge)
				else
					local edge = { v1 = vertexA, v2 = vertexB, cells = {} }
					table.insert(self.edges, edge)
					table.insert(edge.cells, cell)
					table.insert(cell.edges, edge)
					table.insert(vertexA.edges, edge)
					table.insert(vertexB.edges, edge)
					edgeHash[edgeKey] = edge
				end
			end
		end
	end
end

function Voronoi:update()
	self:updateSiteValids()

	local validSites = {}
	for _, site in ipairs(self.sites) do
		if site.valid then validSites[#validSites + 1] = site end
	end

	local neighborsOf = {}
	for _, site in ipairs(validSites) do
		neighborsOf[site] = {}
	end

	if #validSites >= 2 then
		local shadowPoints = buildShadowPoints(validSites)
		local pairs_ = computeDelaunayNeighbors(shadowPoints)
		for _, pair in ipairs(pairs_) do
			neighborsOf[pair.a][pair.b] = true
			neighborsOf[pair.b][pair.a] = true
		end
	end

	local fallbackCount = 0

	for _, site in ipairs(self.sites) do
		local cell = site.cell
		if not site.valid then
			cell.valid = false
			cell.polygon = {}
		else
			local neighbors = neighborsOf[site]

			if next(neighbors) == nil and #validSites > 1 then
				-- safety-net fallback: Fortune's pass found no neighbors
				-- (this should be rare; if it fires often, it usually means
				-- several sites are exactly collinear, which silently skips
				-- the circle event that would have found the true neighbor -
				-- see the epsilon check in checkCircleEvent). Track how often
				-- it fires via diagram.lastFallbackCount so this is easy to
				-- diagnose instead of only visible as stray Delaunay edges.
				fallbackCount = fallbackCount + 1
				for _, other in ipairs(validSites) do
					if other ~= site then neighbors[other] = true end
				end
			end

			local cellPolygon = { unpack(self.boundingPolygon) }
			local isValid = true

			for other in pairs(neighbors) do
				local midX = (site.x + other.x) / 2
				local midY = (site.y + other.y) / 2
				local pointA = { x = midX, y = midY }
				local pointB = { x = midX + site.y - other.y, y = midY + other.x - site.x }
				cellPolygon = clipByHalfPlane(cellPolygon, pointA, pointB)
				if #cellPolygon < 6 then
					isValid = false
					break
				end
			end

			cell.valid = isValid
			cell.polygon = cellPolygon
		end
	end

	self.lastFallbackCount = fallbackCount

	self:updateVertices()
	self:updateEdges()

	-- Build the site adjacency graph shown as the "Delaunay overlay":
	-- two sites are only connected here if their cells actually share a
	-- border edge inside the bounding polygon (edge.cells has both of
	-- them), NOT merely because they are Delaunay neighbors on the
	-- infinite plane. Two sites can be true infinite-plane Delaunay
	-- neighbors while the entire bisector between them lies outside the
	-- bounding polygon (a third site's cell fully separates them
	-- everywhere inside the polygon); in that case they do not actually
	-- border each other in this diagram and must not be shown as
	-- connected, even though they were used as clipping neighbors above.
	local delaunayEdges = {}
	local visitedPairs = {}
	for _, edge in ipairs(self.edges) do
		local cells = edge.cells
		for i = 1, #cells do
			for j = i + 1, #cells do
				local siteA = cells[i].site
				local siteB = cells[j].site
				local alreadyAdded = (visitedPairs[siteA] and visitedPairs[siteA][siteB])
				or (visitedPairs[siteB] and visitedPairs[siteB][siteA])
				if not alreadyAdded then
					delaunayEdges[#delaunayEdges + 1] = { a = siteA, b = siteB }
					visitedPairs[siteA] = visitedPairs[siteA] or {}
					visitedPairs[siteA][siteB] = true
				end
			end
		end
	end
	self.delaunayEdges = delaunayEdges
end

----------------------------------------
----------------- extra -----------------
----------------------------------------

function Voronoi:getCell(mx, my)
	for i, cell in ipairs(self.cells) do
		if cell.valid and pointInPolygon(mx, my, cell.polygon) then
			return i, cell
		end
	end
	return nil
end

function Voronoi:getVertex(mx, my)
	local lambdaSquared = 10 ^ 2
	for i, vertex in ipairs(self.vertices) do
		if squaredLength(mx, my, vertex.x, vertex.y) < lambdaSquared then
			return i, vertex
		end
	end
	return nil
end

function Voronoi:getEdge(mx, my)
	local lambda = 5
	for i, edge in ipairs(self.edges) do
		local dist = pointToLineDistance(mx, my, edge.v1.x, edge.v1.y, edge.v2.x, edge.v2.y)
		if dist < lambda then
			return i, edge
		end
	end
	return nil
end

----------------------------------------
------------------ draw -----------------
----------------------------------------

function Voronoi:drawBoundingPolygon(mode)
	mode = mode or "line"
	love.graphics.polygon(mode, self.boundingPolygon)
end

function Voronoi:drawSite(index, mode, radius)
	radius = radius or 5
	local site = self.sites[index]
	if not site then return end

	mode = mode or "fill"
	love.graphics.circle(mode, site.x, site.y, radius)
end

function Voronoi:drawSites(mode, radius)
	mode = mode or "fill"
	radius = radius or 5

	for _, site in ipairs(self.sites) do
		if site.valid then
			love.graphics.circle(mode, site.x, site.y, radius)
		else
			love.graphics.circle("line", site.x, site.y, radius)
		end
	end
end

function Voronoi:drawCell(index, mode)
	local cell = self.cells[index]
	if not cell then return end

	mode = mode or "fill"
	if cell.valid then
		love.graphics.polygon(mode, cell.polygon)
	end
end

function Voronoi:drawCells(mode)
	mode = mode or "line"
	for _, cell in ipairs(self.cells) do
		if cell.valid then
			love.graphics.polygon(mode, cell.polygon)
		end
	end
end

function Voronoi:drawVertices(mode, radius)
	mode = mode or "fill"
	radius = radius or 5
	for _, vertex in ipairs(self.vertices) do
		love.graphics.circle(mode, vertex.x, vertex.y, radius)
	end
end

-- draws lines between sites whose cells actually border each other inside
-- the bounding polygon (see delaunayEdges in Voronoi:update)
function Voronoi:drawDelaunay()
	for _, edge in ipairs(self.delaunayEdges) do
		love.graphics.line(edge.a.x, edge.a.y, edge.b.x, edge.b.y)
	end
end

----------------------------------------
------------ export as graph ------------
----------------------------------------

function Voronoi:exportGraphToClipboard()
	local output = "-- Voronoi Diagram Graph Export\n\n"

	output = output .. "nodes = {\n"
	for i, vertex in ipairs(self.vertices) do
		output = output .. string.format("    [%d] = {id = %d, x = %.2f, y = %.2f},\n", i, i, vertex.x, vertex.y)
	end
	output = output .. "}\n\n"

	output = output .. "edges = {\n"
	for i, edge in ipairs(self.edges) do
		local v1Id, v2Id
		for j, vertex in ipairs(self.vertices) do
			if vertex == edge.v1 then v1Id = j end
			if vertex == edge.v2 then v2Id = j end
		end
		output = output .. string.format("    [%d] = {id = %d, nodes = {%d, %d}},\n", i, i, v1Id, v2Id)
	end
	output = output .. "}\n"

	love.system.setClipboardText(output)
	print("Graph exported successfully to clipboard.")
end

----------------------------------------
------------- static utils --------------
----------------------------------------

Voronoi.pointInPolygon = pointInPolygon
Voronoi.isConvex = isConvex

return Voronoi