-- systems/movementSystem.lua
-- all comments in code are in english and lowercase

local System = require("core.system")
local MathUtils = require("utils.math")
local Assets = require("assets.loader")
local tileWidth, tileHeight = Assets.tileWidth, Assets.tileHeight

local MovementSystem = setmetatable({}, {__index = System})

-- update all entities with nextTile
function MovementSystem:update(world, dt)
--	 ('MovementSystem:update')
	if not world.moving then return end  -- nothing to move if world is idle

	-- increment turn timer
	world.turnTimer = world.turnTimer + dt
--	local moveDuration = world.turnDuration or 1  -- duration of one move in seconds
	local t = math.min(world.turnTimer, 1)
--	print ('t', t)

--	local tileWidth, tileHeight = 256, 256  -- for hexToPixel



	local entities = world:getEntitiesWithComponents({"currentTile", "nextTile"})

	if t == 1 then
		world.moving = false
		
		for entityID, entity in ipairs(entities) do
			local currentTile = entity.components.currentTile
			local nextTile = entity.components.nextTile
			currentTile.r = nextTile.r
			currentTile.q = nextTile.q
			entity.components.nextTile = nil
		end
		
		return
	end


	for entityID, entity in ipairs(entities) do
--		print (entityID, entity.id)
		local pos = entity.components.currentTile
		local rend = entity.components.renderable
		local nextTile = entity.components.nextTile

		if nextTile then

			-- compute start and target currentTiles in pixels
			local startX, startY = MathUtils.hexToPixel(pos.q, pos.r, tileWidth, tileHeight)
			local targetX, targetY = MathUtils.hexToPixel(nextTile.q, nextTile.r, tileWidth, tileHeight)

			-- linear interpolation
			rend.x = startX + (targetX - startX) * t
			rend.y = startY + (targetY - startY) * t
			
--			print ('rend.x, rend.y', rend.x, rend.y)

		end
	end

end

return MovementSystem
