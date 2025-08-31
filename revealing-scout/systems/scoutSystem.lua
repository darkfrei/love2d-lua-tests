-- systems/scoutSystem.lua
-- all comments in code are in english and lowercase

local System = require("core.system")
local MathUtils = require("utils.math")
local Directions = require("utils.directions")

local ScoutSystem = setmetatable({}, {__index = System})

function ScoutSystem:update(world, dt)
	local entities = world:getEntitiesWithComponents({"scout", "currentTile", "renderable"})

	for _, scout in ipairs(entities) do
		local sComp = scout.components.scout
		local pos = scout.components.currentTile
		local rend = scout.components.renderable

		if sComp.moving then
			sComp.moveTimer = sComp.moveTimer + dt
			local t = math.min(sComp.moveTimer / sComp.moveDuration, 1)

			local startX, startY = MathUtils.hexToPixel(pos.q, pos.r, 256, 256)
			local targetX, targetY = MathUtils.hexToPixel(sComp.targetQ, sComp.targetR, 256, 256)

			rend.x = (1-t) * startX + t * targetX
			rend.y = (1-t) * startY + t * targetY

			-- проверяем завершение движения
			if t >= 1 then
				pos.q = sComp.targetQ
				pos.r = sComp.targetR
				sComp.moving = false
				sComp.targetQ = nil
				sComp.targetR = nil
				sComp.moveTimer = 0
			end
		else
			rend.x, rend.y = MathUtils.hexToPixel(pos.q, pos.r, 256, 256)
		end
	end
end

return ScoutSystem
