-- truss/init.lua
-- library entry point
--
-- usage:
-- local truss = require("truss")
-- local world = truss.new() -- use default physics constants
-- local world = truss.new({ G = 300 }) -- override gravity only
--
-- returns:
-- module table with function:
-- truss.new(config?) -> world

local World = require("truss.world")

return {
	new = function(config)
		return World.new(config)
	end
}