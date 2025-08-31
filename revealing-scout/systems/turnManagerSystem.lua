-- systems/turnManagerSystem.lua
-- all comments in code are in english and lowercase

-- disabled, not ready

local System = require("core.system")
local MathUtils = require("utils.math")
local Assets = require("assets.loader")

local TurnManagerSystem = System.new()
TurnManagerSystem.timer = 0
TurnManagerSystem.day = 1
TurnManagerSystem.listeners = {}

-- register listener for end turn event
function TurnManagerSystem:registerListener(listener)
	table.insert(self.listeners, listener)
end

-- notify listeners when turn ends
function TurnManagerSystem:notifyListeners(world)
	for _, listener in ipairs(self.listeners) do
		if listener.updateEvent then
			listener:updateEvent(world)
		end
	end
end

-- update is called every frame
function TurnManagerSystem:update(world, dt)
	self.timer = self.timer + dt
	if self.timer >= 1 then
		self.timer = self.timer - 1
		self.day = self.day + 1

		-- move all units with nextTile
		local entities = world:getEntitiesWithComponents({"unit", "currentTile"})
		for _, entity in ipairs(entities) do
			local nextTile = entity.components.nextTile
			if nextTile then
				-- move to new tile
				local currentTile = entity.components.currentTile
				currentTile.q = nextTile.q
				currentTile.r = nextTile.r

				-- update renderable x,y
				local render = entity.components.renderable
				if render then
					local x, y = MathUtils.hexToPixel(nextTile.q, nextTile.r, Assets.tileWidth, Assets.tileHeight)
					render.x = x
					render.y = y
				end

				-- clear nextTile after move
				entity.components.nextTile = nil
			end
		end

		-- notify all listeners about end of turn
		self:notifyListeners(world)
	end
end

return TurnManagerSystem
