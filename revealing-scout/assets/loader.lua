-- assets/loader.lua
-- all comments in code are in english and lowercase

local Assets = {}

--[[
local Assets = require("assets.loader")
local tileWidth, tileHeight = Assets.tileWidth, Assets.tileHeight
--]]


-- global tile size (for hex calculations and rendering)
Assets.tileWidth = 256
Assets.tileHeight = 256

--function Assets.load()
Assets.tiles = {
	empty = {
		image = love.graphics.newImage("assets/tilesets/empty.png"),
		offsetX = 0,
		offsetY = 0
	},
	grass = {
		image = love.graphics.newImage("assets/tilesets/grass-1.png"),
		offsetX = 0,
		offsetY = 0
	},
	forest = {
		image = love.graphics.newImage("assets/tilesets/forest-1.png"),
		offsetX = 0,
		offsetY = 0
	},
	village = {
		image = love.graphics.newImage("assets/tilesets/village-1.png"),
		offsetX = 0,
		offsetY = 0
	},
	
	fog = {
		image = love.graphics.newImage("assets/tilesets/fog-1.png"),
		offsetX = 0,
		offsetY = 0
	},
	
}

Assets.sprites = {
	scout = {
		image = love.graphics.newImage("assets/sprites/scout-1.png"),
		offsetX = 0,
		offsetY = 0
	},
	village = {
		image = love.graphics.newImage("assets/sprites/village-1.png"),
		offsetX = 0,
		offsetY = 0
	}
}

--	return Assets
--end

return Assets
