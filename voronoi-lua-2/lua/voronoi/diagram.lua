-- diagram.lua

print ('loaded', ...)

-- lua/voronoi/diagram.lua

local diagram = {}
diagram.__index = diagram  -- set the __index for the metatable

-- creates a new diagram
-- initializes cells and edges for the diagram
function diagram.new()
	local self = setmetatable({}, diagram)  -- create a new object and set the metatable
	self.sites = {}  -- stores the Voronoi sites
	self.cells = {}  -- stores the Voronoi cells
	self.edges = {}  -- stores the Voronoi edges
	self.boundary = {} -- stores polygon boundary (edges of the polygon)
	self.polygonVertices = {} -- stores polygon vertices for rendering
	
	self.renderinArcs = {} -- wip
	return self
end

-- adds a polygon as a boundary to the Voronoi diagram
-- [polygon] — a table of vertices defining the polygon boundary
function diagram:addPolygon(polygon)
	-- [logic to add polygon as boundary]
	self.boundary = polygon  -- store the polygon boundary
	self.polygonVertices = {}
	
	-- find the leftmost and rightmost points in the polygon
-- find the leftmost and rightmost points in the polygon
	local leftPoint, rightPoint = self:getLeftAndRightPoints(polygon)

	-- store the leftmost and rightmost points
	self.leftSide = leftPoint
	self.rightSide = rightPoint
	
	print ('leftPoint: '.. leftPoint , 'rightPoint: ' .. rightPoint)
	
	
	for i, p in ipairs (polygon) do
		table.insert (self.polygonVertices, p.x)
		table.insert (self.polygonVertices, p.y)
	end
end

-- finds the leftmost and rightmost points in the polygon
-- [polygon] — a table of vertices defining the polygon boundary
function diagram:getLeftAndRightPoints(polygon)
	local minX, maxX = math.huge, -math.huge

	-- iterate through the polygon vertices
	for _, p in ipairs(polygon) do
		-- update the leftmost and rightmost points
		if p.x < minX then
			minX = p.x
		end
		if p.x > maxX then
			maxX = p.x
		end
	end

	-- return the leftmost and rightmost points
	return minX, maxX
end

----------------

function diagram:addSite(site)
	local cell = {site = site}
	site.cell = cell
	
	table.insert (self.sites, site)
	table.insert (self.cells, cell)
	
end

-- method to reset the diagram
function diagram:reset()
	self.cells = {}
	self.edges = {}
end

-- method to finalize the edges (e.g., extend to infinity or close them)
function diagram:finalizeEdges()
	-- [wip] logic to finalize edges (e.g., extend to infinity or close them)
end

-- method to update the diagram
-- updates the diagram's cells and edges during the sweep
function diagram:update(beachline, sweepLineY)
	-- [wip] logic to update cells based on the current beachline
	for _, cell in ipairs(self.cells) do
		-- [wip] update the cell properties (e.g., update boundaries)
	end

	-- update edges based on the beachline
	for _, edge in ipairs(self.edges) do
		-- [wip] update edges based on the current state of the beachline and sweepLineY
	end

	-- finalize the edges if necessary
	self:finalizeEdges()
end




return diagram
