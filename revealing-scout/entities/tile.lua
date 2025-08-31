-- entities/tile.lua
-- all comments in code are in english and lowercase

--local Assets = require("assets.loader")
local Entity = require("core.entity")
local MathUtils = require("utils.math")
local Assets = require("assets.loader")
local tileWidth, tileHeight = Assets.tileWidth, Assets.tileHeight

local Tile = {}

--local tileWidth = 256
--local tileHeight = 256

-- horizontal distance between hex centers
local hexX = tileWidth 
-- vertical distance between hex centers
local hexY = tileHeight 


-- create a new tile entity
function Tile.new(world, q, r, typ)
	-- create entity
	local tile = Entity.new(world)
--	print ('#'..tile.id, 'Tile.new(world, q, r, typ)', q, r, typ)

	-- add tile component with position and type
	tile:addComponent("tile", {
			q = q,
			r = r,
			typ = typ, 
			fog = true,
			})

	-- load image for renderable component
	local asset = Assets.tiles[typ] or Assets.tiles["empty"]

	local x, y = MathUtils.hexToPixel(q, r, tileWidth, tileHeight)
--	print ('tile x, y:' ,x,y)

	local ox = tileWidth / 2 + (asset.offsetX or 0)
	local oy = tileHeight / 2 + (asset.offsetY or 0)

	tile:addComponent("renderable", {
			image = asset.image,
			x = x,
			y = y,
			ox = ox,
			oy = oy,
		})

	return tile
end

return Tile
