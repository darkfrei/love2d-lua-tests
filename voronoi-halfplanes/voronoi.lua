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
	}
	setmetatable(diagram, self)
	table.insert(Voronoi.diagrams, diagram)
	return diagram
end

-- add a single site to the diagram
function Voronoi:addSite(x, y)
	local isValid = pointInPolygon(x, y, self.boundingPolygon)
	local site = {x=x, y=y, valid = isValid}

	local cell = {site = site, polygon = {}}
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


return Voronoi