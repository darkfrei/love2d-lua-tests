-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local slope = {}

local function isIntersection (x1, y1, x2, y2, x3, y3, x4, y4)
-- line segments AB: x1, y1, x2, y2 and CD: x3, y3, x4, y4
	local abx, aby = (x2-x1), (y2-y1) -- main vector ab
	local acx, acy = (x3-x1), (y3-y1) -- vector ac
	local adx, ady = (x4-x1), (y4-y1) -- vector ad
	local u = (abx*acy - aby*acx)*(abx*ady - aby*adx)
	if u > 0 then return false end
	local bcx, bcy = (x3-x2), (y3-y2) -- vector bc 
	local dcx, dcy = (x3-x4), (y3-y4) -- main vector dc (vector ac is above)
	local v = (dcx*acy - dcy*acx)*(dcx*bcy - dcy*bcx)
	if v > 0 then return false end
	return true
end

local function getMovingBoundungBox (x, y, w, h, tx, ty)
--	tx, ty - target position
	local x1 = math.min (x, tx)
	local y1 = math.min (y, ty)
	local x2 = math.max (x, tx)
	local y2 = math.max (y, ty)
	return x1, y1, x2-x1+w, y2-y1+h
end

local function getLineBoundungBox (line)
	local x1, y1 = line[1], line[2]
	local x2, y2 = line[1], line[2]
	for i = 3, #line-1, 2 do
		local x = line [i]
		local y = line [i+1]
		if x1 > x then x1 = x end
		if y1 > y then y1 = y end
		if x2 < x then x2 = x end
		if y2 < y then y2 = y end
	end
	for i = 1, #line-1, 2 do
		line [i] = line [i] - x1
		line [i+1] = line [i+1] - y1
	end
	return x1, y1, x2-x1, y2-y1 -- x, y, w, h
end

local function worldAddLines (self, line)
	for i = 1, #line-3, 2 do
		local lineSegment = {line[i], line[i+1], line[i+2], line[i+3]}
		local x, y, w, h = getLineBoundungBox (lineSegment)
		local objLine = {
			line = lineSegment,
			x=x, y=y, w=w, h=h,
			vx = 0, vy = 0,
		}
		table.insert (self.objLines, objLine)
	end
end


local function isRoughCollision(a, b)
  return a.x < b.x+b.w and a.y < b.y+b.h and 
         b.x < a.x+a.w and b.y < a.y+a.h
end

local function psm (ax, ay, bx, by) -- pseudoScalarMutiplication
	return ax*by-ay*bx
end

local function isFineCollision(ps, objLine) -- points
  local line = objLine.line
	local x, y = objLine.x, objLine.y
	local x1, y1 = x+line[1], y+line[2]
	local x2, y2 = x+line[3], y+line[4]
	
	local v1 = psm (x2-x1, y2-y1, ps[1].x-x1, ps[1].y-y1)
	local v2 = psm (x2-x1, y2-y1, ps[2].x-x1, ps[2].y-y1)
	local v3 = psm (x2-x1, y2-y1, ps[3].x-x1, ps[3].y-y1)
	local v4 = psm (x2-x1, y2-y1, ps[4].x-x1, ps[4].y-y1)
	if math.min (v1, v2, v3, v4) > 0 then
		-- no collision
	elseif math.max (v1, v2, v3, v4) < 0 then
		-- no collision
	else
		return true, v1, v2, v3, v4 -- collision
	end
end

local function worldMove (self, obj, tX, tY)
	-- world, object, target position
	-- 
	print ('obj.x, obj.y, obj.w, obj.h, tX, tY', obj.x, obj.y, obj.w, obj.h, tX, tY)
	local ax, ay, aw, ah = getMovingBoundungBox (obj.x, obj.y, obj.w, obj.h, tX, tY)
	print ('ax, ay, aw, ah', ax, ay, aw, ah)
	local movingObj = {x=ax, y=ay, w=aw, h=ah, dx=tX-obj.x, dy=tY-obj.y}
	
	local points = {{x=ax, y=ay}, {x=ax+aw, y=ay}, {x=ax+aw, y=ay+ah}, {x=ax, y=ay+ah}}
	local cols = {} 
	local len = 0
	for i, objLine in ipairs (self.objLines) do
		if isRoughCollision(obj, objLine) then
			objLine.rough = true
			local fineCol, v1, v2, v3, v4 = isFineCollision(points, objLine)
			if fineCol then
				objLine.fine = true
				objLine.values = {v1, v2, v3, v4}
			else
				objLine.fine = false
			end
		else
			objLine.rough = false
			objLine.fine = false
		end
	end
	return tX, tY
end

function slope.newWorld ()
	local world = {}
	world.meter = 100 -- pixels / units per meter
	world.objLines = {}
	world.addLines = worldAddLines
	world.move = worldMove
	return world
end


return slope