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

local function getHashPoint (x, y)
	local hashKey = string.format("%.2f:%.2f", x, y)
	return hashKey
end


-- add a single site to the diagram
function Voronoi:addSite(x, y)
	local siteHash = {}
	for i, site in ipairs (self.sites) do
		local x1, y1 = site.x, site.y
		local hashKey = getHashPoint (x1, y1)
		siteHash[hashKey] = true
	end
	
	if siteHash [getHashPoint (x, y)] then
		-- already there
		return
	end
	
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

--	print ('self.sites 2', self.sites)

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
				local vertex = {
					x=x, y=y, 
					edges = {},
					cells = {}, 
					id = #self.vertices+1}
				table.insert (vertex.cells, cell)
				table.insert (cell.vertices, vertex)
				table.insert (self.vertices, vertex)
				vertexHash[hashKey] = vertex
			end
		end
	end
end

-- normalize edge vertices to ensure consistent order
local function getEdgeHash(v1, v2)
	if v1.id < v2.id then  
		-- return the normalized key as a string in the format "smallerId:largerId"
		return string.format("%d:%d", v1.id, v2.id)
	else
		-- return the normalized key as a string in the format "smallerId:largerId"
		return string.format("%d:%d", v2.id, v1.id)
	end
end

-- update edges and their relationships with cells and vertices
function Voronoi:updateEdges()
	self.edges = {} -- clear the existing list of edges
	local edgeHash = {}  -- hash table to track unique edges

	-- iterate through all cells in the diagram
	for _, cell in ipairs(self.cells) do
		-- check if the cell is valid and has at least three vertices to form edges
		if cell.valid and #cell.vertices > 2 then
			-- iterate through all vertices of the cell to create edges
			for i = 1, #cell.vertices do
				local j = (i % #cell.vertices) + 1 -- wrap around to the first vertex to close the polygon
				local vertexA = cell.vertices[i]
				local vertexB = cell.vertices[j]

				-- generate a unique key for the edge based on the normalized vertex IDs
				local edgeKey = getEdgeHash(vertexA, vertexB)

				-- check if the edge already exists in the hash table
				if edgeHash[edgeKey] then
					local edge = edgeHash[edgeKey]

					-- link the current cell to the existing edge
					table.insert(edge.cells, cell)
					table.insert(cell.edges, edge) 
					
					table.insert(vertexA.edges, edge) 
					table.insert(vertexB.edges, edge) 
					
					
				else
					-- create a new edge and initialize its properties
					local edge = {
						v1 = vertexA,
						v2 = vertexB,
						cells = {} -- each edge belongs to one or more cells
					}

					-- add the edge to the global list of edges
					table.insert(self.edges, edge)

					-- link the edge to the current cell
					table.insert(edge.cells, cell)
					table.insert(cell.edges, edge)
					
					table.insert(vertexA.edges, edge) 
					table.insert(vertexB.edges, edge) 

					-- store the edge in the hash table using its unique key
					edgeHash[edgeKey] = edge
				end
			end
		end
	end

	-- print the total number of edges found
	print('found edges:', #self.edges)
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

--	print ('self.sites 1', self.sites)
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
			local i = 1
			local x2, y2 = cell.vertices[i].x,  cell.vertices[i].y
			love.graphics.setColor (1,0,0)
			love.graphics.line (x1, y1, x2, y2)

			i = #cell.vertices
			x2, y2 = cell.vertices[i].x,  cell.vertices[i].y
			love.graphics.setColor (0,0,1)
			love.graphics.line (x1, y1, x2, y2)

--			for i, v in ipairs (cell.vertices) do
--				local x2, y2 = v.x, v.y
--				love.graphics.line (x1, y1, x2, y2)
--			end
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

---------------------------
-- export edges as graph --
---------------------------

-- export the Voronoi diagram as a graph in Lua format and copy it to clipboard
function Voronoi:exportGraphToClipboard()
	-- prepare the Lua code as a string
	local output = "-- Voronoi Diagram Graph Export\n\n"

	-- nodes section
	output = output .. "nodes = {\n"
	for i, vertex in ipairs(self.vertices) do
		output = output .. string.format("    [%d] = {id = %d, x = %.2f, y = %.2f},\n", i, i, vertex.x, vertex.y)
	end
	output = output .. "}\n\n"

	-- edges section
	output = output .. "edges = {\n"
	for i, edge in ipairs(self.edges) do
		-- find the IDs of the vertices
		local v1Id, v2Id
		for j, vertex in ipairs(self.vertices) do
			if vertex == edge.v1 then v1Id = j end
			if vertex == edge.v2 then v2Id = j end
		end
		output = output .. string.format("    [%d] = {id = %d, nodes = {%d, %d}},\n", i, i, v1Id, v2Id)
	end
	output = output .. "}\n"

	-- copy the output to the clipboard
	love.system.setClipboardText(output)
	print("Graph exported successfully to clipboard.")
end

return Voronoi