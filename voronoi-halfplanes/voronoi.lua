-- voronoi lua

local Voronoi = {}
Voronoi.__index = Voronoi

-- default bounding polygon (rectangle)
local defaultBoundingPolygon = {50, 50, 750, 50, 750, 550, 50, 550}

-- initialize a table to store all diagrams
Voronoi.diagrams = {}


---------------------
------- utils -------
---------------------

-- function to clip a polygon with a half-plane given with points A and B
local function clipByHalfPlane(polygon, pointA, pointB)
	local tx = pointB.y - pointA.y
	local ty = pointA.x - pointB.x
	local length = math.sqrt(tx^2 + ty^2)
	tx = tx / length
	ty = ty / length

	local clippedPolygon = {}

	-- iterate through the edges of the polygon
	for i = 1, #polygon-1, 2 do
		local j = ((i+1) % #polygon)+1
		local x1, y1 = polygon[i], polygon[i + 1]
		local x2, y2 = polygon[j], polygon[j + 1]
		local side1 = (x1 - pointA.x) * tx + (y1 - pointA.y) * ty
		local side2 = (x2 - pointA.x) * tx + (y2 - pointA.y) * ty

		if (side1 <= 0) then
			table.insert(clippedPolygon, x1)
			table.insert(clippedPolygon, y1)
		end

		-- add intersection points between edges and the plane
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

-- check if a point is inside a polygon using the ray-casting algorithm
local function pointInPolygon(x, y, polygon)
	local inside = false
	for i = 1, #polygon-1, 2 do
		local j = ((i+1) % #polygon)+1
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

------------------------------
------------ main ------------
------------------------------

-- create a new voronoi diagram object
function Voronoi:newDiagram()
	local diagram = {
		sites = {},  -- list of sites in the diagram
		boundingPolygon = defaultBoundingPolygon,
		cells = {}, -- list of voronoi cells
		vertices = {},
		edges = {},
	}
	setmetatable(diagram, self)
	table.insert(Voronoi.diagrams, diagram)
	return diagram
end

-- add a single site to the diagram
function Voronoi:addSite(x, y)
	local isValid = pointInPolygon(x, y, self.boundingPolygon)
	local site = {x=x, y=y, valid = isValid}

	local cell = {
		site = site, 
		polygon = {},
		vertices = {},
		edges = {},
	}
	site.cell = cell
	table.insert (self.sites, site) -- adding to diagram
	table.insert (self.cells, cell) -- adding to diagram
end

function Voronoi:addSites(sites)
	for i, site in ipairs (sites) do
		local x = site.x
		local y = site.y
		self:addSite(x, y)
	end
end

-- remove a site by index
function Voronoi:removeSiteByIndex(index)
	if index >= 1 and index <= #self.sites then
		table.remove(self.sites, index)
		table.remove(self.cells, index)
	else
		error("invalid site index")
	end
end

-- remove the last site added to the diagram
function Voronoi:removeLastSite ()
	if #self.sites > 0 then
		table.remove(self.sites)
		table.remove(self.cells)
	end
end

function Voronoi:updateSiteValids()
	-- update valids of sites
	for i, site in ipairs (self.sites) do
		site.valid = pointInPolygon(site.x, site.y, self.boundingPolygon)
	end
end

-- set a custom bounding polygon for the diagram
function Voronoi:setBoundingPolygon(polygon)
	if type(polygon) ~= "table" or #polygon < 6 then
		error("Invalid bounding polygon: must be a table with at least 3 vertices")
	end
	self.boundingPolygon = polygon

--	self:updateSiteValids()
end

function Voronoi:updateVertices ()
	self.vertices = {}
	local vertexHash = {}

	print ('self.sites 2', self.sites)

	for i, cell in ipairs (self.cells) do
		cell.vertices = {}
		local cellPolygon = cell.valid and cell.polygon or {}
		for j = 1, #cellPolygon-1, 2 do
			local x, y = cellPolygon[j], cellPolygon[j + 1]
			local hashKey = string.format("%.2f:%.2f", x, y)
			if vertexHash[hashKey] then
				local vertex = vertexHash[hashKey]
				table.insert (vertex.cells, cell)
				table.insert (cell.vertices, vertex)
			else
				local vertex = {x=x, y=y, cells = {}}
				table.insert (vertex.cells, cell)
				table.insert (cell.vertices, vertex)
				table.insert (self.vertices, vertex)
				vertexHash[hashKey] = vertex
			end
		end
	end
end


-- update edges and their relationships with cells and vertices
function Voronoi:updateEdges()
	self.edges = {} -- clear the existing list of edges

	-- iterate through all vertices
	for _, vertexA in ipairs(self.vertices) do
		-- iterate through all pairs of cells connected to the vertex
		for cellIndex1 = 1, #vertexA.cells - 1 do
			local cell1 = vertexA.cells[cellIndex1]
			for cellIndex2 = cellIndex1 + 1, #vertexA.cells do
				local cell2 = vertexA.cells[cellIndex2]

				-- find another vertex shared by both cells
				for indexVertex1, vertex1 in ipairs (cell1.vertices) do
					if not (vertexA == vertex1) then -- ensure it's not the same vertex
						for indexVertex2, vertex2 in ipairs (cell2.vertices) do
							if (vertex1 == vertex2) then -- check if the vertex is common to both cells
								local vertexB = vertex1
								-- create an edge connecting the two vertices
								local edge = {
									v1 = vertexA,
									v2 = vertexB,
									cells = {cell1, cell2}
								}
								-- link the edge to both cells
								table.insert (cell1.edges, edge)
								table.insert (cell2.edges, edge)
								-- add the edge to the global list of edges
								table.insert (self.edges, edge)
							end
						end
					end
				end
			end
		end
	end
end


-- generate voronoi cells by clipping polygons for each site
function Voronoi:update()
	self:updateSiteValids()

	for i, site in ipairs(self.sites) do
		local cell = site.cell
		-- start with the bounding polygon
		local cellPolygon = {unpack(self.boundingPolygon)}
		cell.valid = true
		for j, otherSite in ipairs(self.sites) do
			if i ~= j and (site.valid and otherSite.valid)then
				local midX = (site.x + otherSite.x) / 2
				local midY = (site.y + otherSite.y) / 2
				local pointA = {x = midX, y = midY}
				local pointB = {x = midX + site.y - otherSite.y, y = midY + otherSite.x - site.x}
				cellPolygon = clipByHalfPlane (cellPolygon, pointA, pointB)
				-- skip invalid polygons (too small to be meaningful)
				if #cellPolygon < 6 then
					cell.valid = false
					break 
				end
			end
		end

		-- update the cell's polygon and validity
		cell.valid = site.valid
		cell.polygon = cellPolygon
	end

	print ('self.sites 1', self.sites)
	self:updateVertices ()
	self:updateEdges()

end

-- utils --

local function squaredLength(x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	return dx * dx + dy * dy
end

local function pointToLineDistance(px, py, x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	if dx == 0 and dy == 0 then
		return math.sqrt((px - x1)^2 + (py - y1)^2)
	end
	local t = ((px - x1) * dx + (py - y1) * dy) / (dx * dx + dy * dy)
	t = math.max(0, math.min(1, t))
	local closestX = x1 + t * dx
	local closestY = y1 + t * dy
	return math.sqrt((px - closestX)^2 + (py - closestY)^2)
end


-------------
--- extra ---
-------------

-- get the voronoi cell that contains the given point
function Voronoi:getCell(mx, my)
	for i, cell in ipairs(self.cells) do
		if cell.valid and pointInPolygon(mx, my, cell.polygon) then
			return i, cell -- return the index and the cell polygon
		end
	end
	return nil -- return nil if the point is outside all cells
end


function Voronoi:getVertex(mx, my)
	local lambdaSquared = 10^2
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


-----------------
------ draw -----
-----------------

-- draw the bounding polygon
function Voronoi:drawBoundingPolygon(mode)
	mode = mode or 'line' -- default mode is 'line'
	love.graphics.polygon(mode, self.boundingPolygon)
end

-- draw a single site by index
function Voronoi:drawSite(index, mode, radius)
	radius = radius or 5 -- default radius is 5
	local site = self.sites[index]
	if not site then return end

	mode = mode or 'fill' -- default mode is 'fill'
	love.graphics.circle(mode, site.x, site.y, radius)
end

-- draw all sites in the diagram
function Voronoi:drawSites(mode, radius)
	mode = mode or 'fill' -- default mode is 'fill'
	radius = radius or 5 -- default radius is 5

	for _, site in ipairs(self.sites) do
		if site.valid then
			love.graphics.circle(mode, site.x, site.y, radius)
		else
			love.graphics.circle('line', site.x, site.y, radius) -- draw invalid sites as outlines
		end
	end
end

-- draw a single voronoi cell by index
function Voronoi:drawCell(index, mode)
	local cell = self.cells[index]
	if not cell then return end

	mode = mode or 'fill' -- default mode is 'fill'
	if cell.valid then
		love.graphics.polygon(mode, cell.polygon)

		if mode == 'line' and cell.vertices then
			local x1, y1 = cell.site.x, cell.site.y
			for i, v in ipairs (cell.vertices) do
				local x2, y2 = v.x, v.y
				love.graphics.line (x1, y1, x2, y2)
			end
		end
	end
end

-- draw all voronoi cells in the diagram
function Voronoi:drawCells(mode)
	mode = mode or 'line' -- default mode is 'line'

	for _, cell in ipairs(self.cells) do
		if cell.valid then
			love.graphics.polygon(mode, cell.polygon)
		end
	end
end

-- draw all vertices
function Voronoi:drawVertices(mode, radius)
	mode = mode or "fill" -- default mode is 'fill'
	radius = radius or 5  -- default radius is 5

	-- iterate through all vertices and draw them
	for _, vertex in pairs(self.vertices) do
		love.graphics.circle(mode, vertex.x, vertex.y, radius)
	end
end

return Voronoi