-- mapLoader.lua
-- all comments in code are in english and lowercase

local Tile = require("entities.tile")
local Scout = require("entities.scout")
local Village = require("entities.village")

local MapLoader = {}

function MapLoader.load(world, mapData)
	print ('MapLoader.load', 'loading map:')
	local entities = {}
	for _, tilePrototype in ipairs(mapData.tiles) do
		local q = tilePrototype.q
		local r = tilePrototype.r
		local typ = tilePrototype.typ
		local tile = Tile.new(world, q, r, typ)
		
		print ('MapLoader.load', '#'..tile.id)
		table.insert(entities, tile)
	end

	for _, objData in ipairs(mapData.objects) do
		local entity
		if objData.typ == "scout" then
			entity = Scout.new(world, objData.q, objData.r)
		elseif objData.typ == "village" then
			entity = Village.new(world, objData.q, objData.r)
		end

		if entity then
			table.insert(entities, entity)
		end
	end

	return entities
end

return MapLoader
