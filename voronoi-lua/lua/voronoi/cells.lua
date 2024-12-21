-- cells.lua
local cells = {}

local metatable = {
	__index = {
		-- method to add a vertex to the cell
		addVertex = function(self, vertex, needSort)
			table.insert(self.vertices, vertex)
			if needSort then
				-- immediately sort vertices by angle
				self:sortVerticesByAngle()
			end
		end,

		-- method to sort vertices around the site by angle
		sortVerticesByAngle = function(self)
			-- sort vertices in counter-clockwise order around the site
			table.sort(self.vertices, function(a, b)
					local angleA = math.atan2(a.y - self.site.y, a.x - self.site.x)
					local angleB = math.atan2(b.y - self.site.y, b.x - self.site.x)
					return angleA < angleB  -- sort by angle
				end)
		end
	}
}


local function newCell(site)
	local cell = {
		site = site,        -- reference to the site associated with the cell
		vertices = {},      -- vertices for the cell
		edges = {},         -- edges for the cell
		color = { 
			1 - math.random() ^ 2 - 0.1, 
			1 - math.random() ^ 2 - 0.1, 
			1 - math.random() ^ 2 + 0.1, 
		},  -- random color for visualization
		type = 'cell',      -- type is 'cell' for this object
		index = site.index,
	}

	-- set the metatable for the cell to include cellMethods
	setmetatable(cell, metatable)

	-- associate the cell with the site
	site.cell = cell

	return cell
end

function cells.new(sites)
	local cellList = {}  -- table to store all cell objects

	-- iterate through sites and create cells for each one
	for _, site in ipairs(sites) do
		local cell = newCell(site)
		table.insert(cellList, cell)
	end

	return cellList  -- return the list containing all cell objects
end

return cells
