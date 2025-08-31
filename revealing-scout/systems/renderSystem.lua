-- systems/renderSystem.lua
-- all comments in code are in english and lowercase

local System = require("core.system")
local RenderSystem = setmetatable({}, {__index = System})
local MathUtils = require("utils.math")
local Directions = require("utils.directions")
local Assets = require("assets.loader")
local tileWidth, tileHeight = Assets.tileWidth, Assets.tileHeight


-- update is not needed for basic rendering
function RenderSystem:update(world, dt)
	-- no update logic for static tiles
end

local function drawTiles(world)
	local entities = world:getEntitiesWithComponents({"tile", "renderable"})
	for entityID, entity in ipairs(entities) do
		local rend = entity.components.renderable
		local currentTile = entity.components.currentTile
		local tile = entity.components.tile

		if rend and rend.image then
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.draw(rend.image, rend.x, rend.y, 0, 1, 1, rend.ox, rend.oy)

			-- draw fog overlay if fog flag is true
			if tile.fog then
				local fogAsset = Assets.tiles.fog
				love.graphics.setColor(1,1,1,1)
				love.graphics.draw(fogAsset.image, rend.x, rend.y, 0, 1, 1, fogAsset.offsetX + fogAsset.image:getWidth()/2, fogAsset.offsetY + fogAsset.image:getHeight()/2)
			end

			love.graphics.setColor(1, 1, 1, 1) -- white
			love.graphics.print(
				"q=" .. tile.q .. " r=" .. tile.r,
				rend.x - rend.ox + 5,
				rend.y - rend.oy/2 + 5
			)
		end
	end
end


local function drawScoutOverlay(world)
	if world.moving then
		return
	end
	local scout 
	local entities = world:getEntitiesWithComponents({"scout"})
	for entityID, entity in ipairs(entities) do
		scout = entity
	end

	local currentTile = scout.components.currentTile
	local q = currentTile.q
	local r = currentTile.r
	local dir = scout.components.scout.direction
	local offsets = Directions.getOffsets(r)

	for offsetName, offset in pairs(offsets) do
		local dq = offset.dq
		local dr = offset.dr
		local nq = q + dq
		local nr = r + dr

		local x, y = MathUtils.hexToPixel(nq, nr, tileWidth, tileHeight)

		if offsetName == dir then
			love.graphics.setColor(0,1,0,0.5) -- зелёный
		else
			love.graphics.setColor(1,1,0,0.5) -- жёлтый
		end

		love.graphics.polygon("fill", MathUtils.getHexPolygon(x, y, tileWidth, tileHeight))
	end
end

-- draw all entities with renderable component
function RenderSystem:draw(world)
--    print('RenderSystem:draw(world)')
	local camera = world.camera
	love.graphics.push()
	love.graphics.translate(camera.x, camera.y)

	drawTiles(world)


	drawScoutOverlay(world)

	love.graphics.pop()
end

return RenderSystem
