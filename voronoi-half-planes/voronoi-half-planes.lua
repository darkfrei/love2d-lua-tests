-- voronoi half planes
-- license cc0-1.0, darkfrei 2023

-- make it global:
HalfPlanesLib = require ('libs.half-planes')

local VoronoiHP = {
	cells = {},
	width = 100,
	height = 100,
}

function VoronoiHP:newToroidalPlane(width, height)
-- function for creating a Voronoi diagram on a toroidal (wrapped) plane in Lua

	local diagram = {
		toroidal = true,
		width = width,
		height = height,
--		sites = {}, -- origin voronoi points
--		vertices = {}, -- three (or more) cells intersection
--		edges = {}, -- -- two cells intersection
		cells = {}, -- convex polygons
	}

	-- Set the metatable for the new object to 'self'.
	setmetatable(diagram, self)

	-- Define '__index' for the object to use 'self'.
	self.__index = self

	-- Return the newly created object.
	return diagram
end


local voronoiCell = {}
function voronoiCell:new(site)
	local cell = {
		site = site, -- The site (point) associated with this cell.
		vertices = {}, -- Vertices of the cell.
		edges = {}, -- Edges of the cell.
		polygon = {} -- Polygon vertices for rendering.
	}

	setmetatable(cell, self)
	self.__index = self
	return cell
end


function VoronoiHP:addSite(x, y)
	-- Create a new site with the given coordinates (x, y).
	local site = {x = x, y = y}

	-- Create a Voronoi cell for the site.
	local cell = voronoiCell:new(site)

	-- Add the cell to the diagram's cells.
	table.insert(self.cells, cell)
end

local function getHalfPlane (cellSite, otherSite)
	local x = (cellSite.x + otherSite.x)/2
	local y = (cellSite.y + otherSite.y)/2
	local dx =(cellSite.x - otherSite.x)
	local dy =(cellSite.y - otherSite.y)
	if math.abs(dx) > 0 or math.abs(dy) > 0 then
		local halfPlane = HalfPlanesLib:new({x=x, y=y}, dx, dy)
		return halfPlane
	end
end

local function updateCell(cell, sitePoints)
	local cellSite = cell.site

	local i = 1
	local imax = #sitePoints

	cell.vertices = {}

--	print ('#sitePoints', #sitePoints)

	for index, site in ipairs (sitePoints) do
		local halfPlane = getHalfPlane (cellSite, site)
		if halfPlane then
			local validVertices = 0
			for otherIndex, otherSite in ipairs (sitePoints) do
				local otherHalfPlane = getHalfPlane (cellSite, otherSite)
				if otherHalfPlane then
					local vertex = halfPlane:getIntersectionPoint(otherHalfPlane)
					if vertex then
--						print ('vertex', vertex.x, vertex.y)
						local valid = true
						for cutIndex, cutSite in ipairs (sitePoints) do
							if not (cutIndex == index or cutIndex == otherIndex) then
								local cutHalfPlane = getHalfPlane (cellSite, cutSite)
								if cutHalfPlane then
--									print ('cutHalfPlane exists')
									if not cutHalfPlane:contains(vertex) then

										valid = false
--										break
									end
								end
							end
						end
						if valid then
--							print ('index, otherIndex', index, otherIndex)
							table.insert (cell.vertices, vertex)
							validVertices = validVertices + 1
							if validVertices == 2 then
--								break
							end
						end
					end
				end
			end
		end
	end

	-- sort

	for i, vertex in ipairs (cell.vertices) do
		local dx = cellSite.x-vertex.x
		local dy = cellSite.y-vertex.y
		vertex.angle = math.atan2 (dy, dx)
	end



	table.sort(cell.vertices, function(a, b)
			return a.angle < b.angle
		end)

	for i = #cell.vertices, 2, -1 do
		local v1 = cell.vertices[i-1]
		local v2 = cell.vertices[i]
		if math.abs (v2.angle - v1.angle) < 1e-10 then
--			print ('vertex removed')
			table.remove (cell.vertices, i)
		end
	end
	
	for i = 1, #cell.vertices do
		local vertex = cell.vertices[i]
--		print (i, 'vertex', vertex.x, vertex.y, vertex.angle)
	end
end

function VoronoiHP:updateVertices()
	-- Clear the existing vertices.

	for index, cell in ipairs (self.cells) do
		cell.index = index
	end


	local width, height = self.width, self.height

	-- adding virtual sites; without cells
	self.virtualSites = {}
	local sitePoints = {}
	for i = -1, 1 do
		for j = -1, 1 do
			local tx, ty = i*width, j*height
			for index, cell in ipairs (self.cells) do
				local x = tx + cell.site.x
				local y = ty + cell.site.y
				local sitePoint = {x=x, y=y, cell=cell}
				table.insert (sitePoints, sitePoint)
				if not (i == 0 and j == 0) then
--					print ('virtual site', x, y)
					table.insert (self.virtualSites, x)
					table.insert (self.virtualSites, y)
				end
			end
		end
	end

	for i, cell in ipairs (self.cells) do
--		print ('cell', i, cell.site.x, cell.site.y)

		updateCell(cell, sitePoints)

--		print ('#cell.vertices', #cell.vertices)
		cell.polygon = {}
		for j, vertex in ipairs (cell.vertices) do
			table.insert (cell.polygon, vertex.x)
			table.insert (cell.polygon, vertex.y)
		end

--		print ('#cell.polygon', #cell.polygon)
	end

	-- temp points as half distance and direction
	--	for index, site in ipairs (sitePoints) do
	--		local tempPoints = {}
	--		for index2, cell2 in ipairs (sitePoints) do
	--			if not (index == index2) then
	--				local point = cell2.site
	--				table.insert (tempPoints, {
	--						x = point.x/2 + site.x/2 + kw*width/2,
	--						y = point.y/2 + site.y/2 + kh*height/2,
	--						dx = point.x-site.x + kw*width*2,
	--						dy = point.y-site.y + kh*height*2,
	--						cells = {cell, cell2},
	--					})
	--			end
	--		end
	--	end

	--	local cutpoints = {}

	--	--	for i = 1, #tempPoints do
	--	--		local point = tempPoints[i]

	--	local halfPlane = HalfPlanesLib:new(point, point.dx, point.dy)

	--	for j = 1, #tempPoints do
	--		if not (i == j) then
	--			local point2 = tempPoints[j]
	--			local halfPlane2 = HalfPlanesLib:new(point2, point2.dx, point2.dy)

	--			local cutPoint = halfPlane:getIntersectionPoint(halfPlane2)

	--			local valid = true
	--			if cutPoint then
	--				for k = 1, #tempPoints do
	--					if not (i == k) and not (j == k) then
	--						local point3 = tempPoints[k] 
	--						local halfPlane3 = HalfPlanesLib:new(point3, point3.dx, point3.dy)
	--						if halfPlane3:contains(cutPoint) then
	--							valid = false
	--							break
	--						end
	--					end
	--				end


	--				if valid then
	--					cutPoint.halfPlaneA = halfPlane
	--					cutPoint.halfPlaneB = halfPlane2
	--					table.insert (cutpoints, cutPoint)
	--				end
	--			end
	--		end
	--	end
	--end


	--	cell.debugPoints = {}
	--	cell.debugHalfPlanes = {}
	--	cell.debugNearSites = {}
	--	for i = 1, #cutpoints do
	--		local point = cutpoints[i]
	--		table.insert (cell.debugPoints, point.x)
	--		table.insert (cell.debugPoints, point.y)
	--	end
	--	for i = 1, #tempPoints do
	--		local point = tempPoints[i]
	--		table.insert (cell.debugHalfPlanes, HalfPlanesLib:new({x=point.x, y=point.y}, point.x-site.x, point.y-site.y, {1,0,0}))

	--		--			table.insert (cell.debugNearSites, site.x)
	--		--			table.insert (cell.debugNearSites, site.y)
	--	end
end


return VoronoiHP