-- slope.lua for lua 5.3
-- rectangle-to-line collision detection

local function newObjLine (line)
	local x1, y1, x2, y2 = line[1], line[2], line[3], line[4] -- two points of love line
	local x, y = math.min (x1, x2), math.min (y1, y2)
	local w, h = math.max (x1, x2) - x, math.max (y1, y2) - y
	local objLine = {
		line = {x1-x, y1-y, x2-x, y2-y},
		x=x, y=y, w=w, h=h -- bounding box of the line's object
	}
	return objLine
end

local function isRoughCollision(a, b) -- a and b are objects with x, y, w, h as bounding boxes
  return a.x < b.x+b.w and a.y < b.y+b.h and 
         b.x < a.x+a.w and b.y < a.y+a.h
end

local function psm (ax, ay, bx, by) -- pseudoScalarMutiplication
	return ax*by-ay*bx
end

local function isFineCollision(obj, objLine)
	local line = objLine.line
	local x, y = objLine.x, objLine.y
-- points of line:
	local x1, y1 = x+line[1], y+line[2]
	local x2, y2 = x+line[3], y+line[4]
-- 4 vertices of rectangle:
	local p1x, p1y = obj.x, obj.y
	local p2x, p2y = obj.x+obj.w, obj.y
	local p3x, p3y = obj.x+obj.w, obj.y+obj.h
	local p4x, p4y = obj.x, obj.y+obj.h

	local v1 = psm (x2-x1, y2-y1, p1x-x1, p1y-y1)
	local v2 = psm (x2-x1, y2-y1, p2x-x1, p2y-y1)
	local v3 = psm (x2-x1, y2-y1, p3x-x1, p3y-y1)
	local v4 = psm (x2-x1, y2-y1, p4x-x1, p4y-y1)

	if math.min (v1, v2, v3, v4) > 0 then -- all positive
		-- no collision
	elseif math.max (v1, v2, v3, v4) < 0 then -- all negative
		-- no collision
	else
		return true -- collision
	end
end

-- example:

local line = {100, 200, 300, 100}
local rectangle = {x=200, y=140, w=20, h=20}
local objLine = newObjLine (line)
if isRoughCollision(rectangle, objLine) and isFineCollision(rectangle, objLine) then
	print ('collision')
else
	print ('no collision')
end