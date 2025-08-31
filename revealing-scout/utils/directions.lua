-- utils/directions.lua
-- all comments in code are in english and lowercase

local Directions = {}
-- local Directions = require("utils.directions")


-- offsets for pointy-top hexes grid
Directions.offsetsEvenR = {
    left          = { dq = -1, dr =  0 },
    right         = { dq =  1, dr =  0 },
    ["up-left"]   = { dq = -1, dr = -1 },
    ["up-right"]  = { dq =  0, dr = -1 },
    ["down-left"] = { dq = -1, dr =  1 },
    ["down-right"]= { dq =  0, dr =  1 }
}

Directions.offsetsOddR = {
    left          = { dq = -1, dr =  0 },
    right         = { dq =  1, dr =  0 },
    ["up-left"]   = { dq =  0, dr = -1 },
    ["up-right"]  = { dq =  1, dr = -1 },
    ["down-left"] = { dq =  0, dr =  1 },
    ["down-right"]= { dq =  1, dr =  1 }
}

-- helper to get correct neighbors depending on row parity
function Directions.getOffsets(r)
	if r % 2 == 0 then
		return Directions.offsetsEvenR
	else
		return Directions.offsetsOddR
	end
end


-- ordered list of directions (can be used for input mapping)
Directions.keyMap = {
	a = "left",
	w = "up-left",
	e = "up-right",
	d = "right",
	x = "down-right",
	z = "down-left",

	q = "rotation-ccw",
	r = "rotation-cw",
}

-- rotation map (ccw = counter-clockwise, cw = clockwise)
Directions.rotation = {
	left       = { ccw = "down-left", cw = "up-left" },
	["up-left"]= { ccw = "left",      cw = "up-right" },
	["up-right"]={ ccw = "up-left",   cw = "right" },
	right      = { ccw = "up-right",  cw = "down-right" },
	["down-right"]={ ccw = "right",   cw = "down-left" },
	["down-left"] = { ccw = "down-right", cw = "left" }
}

-- rotate direction clockwise or counter-clockwise
function Directions.rotateDirection(current, clockwise)
	local rot = Directions.rotation[current]
	if not rot then return current end
	if clockwise then
		return rot.cw
	else
		return rot.ccw
	end
end

return Directions
