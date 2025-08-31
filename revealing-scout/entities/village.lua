-- entities/village.lua
-- all comments in code are in english and lowercase

local Entity = require("core.entity")
local MathUtils = require("utils.math")
local Assets = require("assets.loader")
local tileWidth, tileHeight = Assets.tileWidth, Assets.tileHeight

local Village = {}

-- create a new village entity
function Village.new(world, q, r)

	local village = Entity.new(world, "village")

	-- add currentTile component
	village:addComponent("currentTile", {q = q, r = r})

	-- load image for renderable component
	local asset = Assets.sprites["village"]
	village:addComponent("renderable", {
			image = asset.image,
			x = 0, -- will compute below
			y = 0,
			ox = asset.image:getWidth()/2 + (asset.offsetX or 0),
			oy = asset.image:getHeight()/2 + (asset.offsetY or 0),
		})

	-- compute initial x, y using same hex formula as tiles
	local x, y = MathUtils.hexToPixel(q, r, tileWidth, tileHeight)
	village.components.renderable.x = x
	village.components.renderable.y = y

	-- mark as building
	village:addComponent("building", {
			type = "village"
		})

	return village
end

return Village
