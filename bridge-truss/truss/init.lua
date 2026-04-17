-- truss/init.lua
-- Library entry point.
--
-- Usage:
-- local Truss = require("truss")
-- local world = Truss.new() -- default physics constants
-- local world = Truss.new({ G=300 }) -- override gravity only
--
-- Returns a module table with a single function:
-- Truss.new(config?) -> World

local World = require("truss.world")

return {
	new = function(config)
		return World.new(config)
	end
}
