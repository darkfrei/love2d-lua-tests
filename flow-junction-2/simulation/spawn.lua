-- simulation/spawn.lua
-- route generation for vehicle spawning

local Graph = require("simulation.graph")
local Routing = require("simulation.routing")

local M = {}

local function pickRandom(t)
	local list = {}
	for k in pairs(t) do
		list[#list + 1] = k
	end
	if #list == 0 then return nil end
	return list[math.random(#list)]
end

function M.spawnRoute()
	local Graph = require("simulation.graph")
	local Routing = require("simulation.routing")

	local g = Graph.getGraph()

	local inList = {}
	local outList = {}

	for id in pairs(g.inNodes or {}) do
		inList[#inList + 1] = id
	end

	for id in pairs(g.outNodes or {}) do
		outList[#outList + 1] = id
	end

	-- spawn input and output node lists

	if #inList == 0 or #outList == 0 then
		-- no valid in or out nodes available
		return nil
	end

	local startNode = inList[math.random(#inList)]
	local endNode = outList[math.random(#outList)]

	-- selected start and end nodes for route

	return Routing.find(startNode, endNode)
end

return M