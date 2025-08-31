-- utils/math.lua
-- all comments in code are in english and lowercase

local MathUtils = {}
-- local MathUtils = require("utils.math")

-- convert hex coordinates (q, r) to pixel coordinates
-- assumes flat-topped hex with tileWidth, tileHeight
function MathUtils.hexToPixel(q, r, tileWidth, tileHeight)
	-- horizontal distance between hex centers
	local x = q * tileWidth + (r % 2) * (tileWidth / 2)
	-- vertical distance between hex centers
	local y = r * tileHeight * 0.75
	return x, y
end


function MathUtils.getHexPolygon(x, y, tileWidth, tileHeight)
	local w = tileWidth / 2
	local h = tileHeight / 2
	local vertices = {
		x - w , y-h/2,
		x, y - h,
		x + w, y-h/2,
		x + w, y+h/2,
		x , y + h,
		x - w, y+h/2
	}
	return vertices
end

return MathUtils
