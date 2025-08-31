-- systems/fogSystem.lua
-- all comments in code are in english and lowercase

local System = require("core.system")
local Directions = require("utils.directions")

local FogSystem = setmetatable({}, {__index = System})

-- external call when turn ends
function FogSystem:updateEvent(world, scout)
	if scout and scout.components.currentTile then
		local q = scout.components.currentTile.q
		local r = scout.components.currentTile.r
		self:reveal(world, q, r, 1)
	end
end

-- reveal fog around q,r with given radius
function FogSystem:reveal(world, q, r, radius)
	local tiles = world:getEntitiesWithComponents({"tile"})
	local offsets = Directions.getOffsets(r)

	for _, tile in ipairs(tiles) do
		local t = tile.components.tile
		if t.q == q and t.r == r then
			t.fog = false
		end
		for _, off in pairs(offsets) do
			if t.q == q + off.q and t.r == r + off.r then
				t.fog = false
			end
		end
	end
end

return FogSystem
