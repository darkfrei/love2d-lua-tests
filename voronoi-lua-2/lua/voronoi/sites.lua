-- sites.lua
local sites = {}
local utils = require("lua.voronoi.utils")

local counter = utils.createCounter()

function sites.new(siteCoordinates, boundingPolygon)
	local siteList = {}

	for i = 1, #siteCoordinates, 2 do
		local x = siteCoordinates[i]
		local y = siteCoordinates[i + 1]

		-- check if the point is within the bounding polygon
		if utils.isPointInPolygon(x, y, boundingPolygon) then
			local site = {
				x = x,      -- x coordinate
				y = y,      -- y coordinate
				index = counter(), -- unique index for each site
				type = 'site', -- type identifier
			}
			table.insert(siteList, site)
		end
	end

	utils.sortSites(siteList)
	return siteList
end

return sites
