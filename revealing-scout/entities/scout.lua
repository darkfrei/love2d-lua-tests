-- entities/scout.lua
-- all comments in code are in english and lowercase

--local Assets = require("assets.loader")
local Entity = require("core.entity")
local MathUtils = require("utils.math")
local Assets = require("assets.loader")
local Directions = require("utils.directions")

local tileWidth, tileHeight = Assets.tileWidth, Assets.tileHeight

local Scout = {}


-- create a new scout entity
function Scout.new(world, q, r)

	local scout = Entity.new(world, 'scout')

	-- add currentTile component
	scout:addComponent("currentTile", {q = q, r = r})

	-- load image for renderable component
	local asset = Assets.sprites["scout"]  -- убедись, что есть файл assets/sprites/scout.png
	scout:addComponent("renderable", {
			image = asset.image,
			x = 0, -- will compute below
			y = 0,
			ox = asset.image:getWidth()/2 + (asset.offsetX or 0),
			oy = asset.image:getHeight()/2 + (asset.offsetY or 0),
		})

	-- compute initial x, y using same hex formula as tiles
--	local tileWidth = 256
--	local tileHeight = 256

	local x, y = MathUtils.hexToPixel(q, r, tileWidth, tileHeight)

	scout.components.renderable.x = x
	scout.components.renderable.y = y

	scout:addComponent("unit", {
			direction = "right",  -- default
		})
	scout:addComponent("scout", {
			playerControlled = true,
		})

	-- clear fog under scout and neighboring tiles
	local offsets = Directions.getOffsets(r)
	for _, offset in pairs(offsets) do
		local nq = q + offset.dq
		local nr = r + offset.dr
		local neighbors = world:getEntitiesWithComponents({"tile"})
		for _, tile in ipairs(neighbors) do
			local t = tile.components.tile
			if t.q == nq and t.r == nr then
				t.fog = false
			end
		end
	end
	
	-- also clear fog on scout's own tile
	local tiles = world:getEntitiesWithComponents({"tile"})
	for _, tile in ipairs(tiles) do
		local t = tile.components.tile
		if t.q == q and t.r == r then
			t.fog = false
		end
	end


	return scout
end

return Scout
