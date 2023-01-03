-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local slope = {}

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

local function worldAddLine (self, lineSegment)
	local objLine = newObjLine (lineSegment)
	table.insert (self.objLines, objLine)
end

local function worldAddLines (self, line)
	for i = 1, #line-3, 2 do
		local lineSegment = {line[i], line[i+1], line[i+2], line[i+3]}
		worldAddLine (self, lineSegment)
	end
end


local function isRoughCollision(a, b)
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


local function worldCheck (self, item, goalX, goalY)
	local x, y = math.min (item.x, goalX), math.min (item.y, goalY)
	local w = item.w+math.max (item.x, goalX)-x
	local h = item.h+math.max (item.y, goalY)-y
	local cols = {}
	for i, objLine in ipairs (self.objLines) do
		if isRoughCollision(item, objLine) and isFineCollision(item, objLine) then
			-- collision
			table.insert(cols, objLine)
		end
	end
	
	local actualX, actualY = goalX, goalY
	
	return actualX, actualY, cols, #cols
end

local function worldUpdate (self, item, x2, y2, w2, h2)
	local x1, y1, w1, h1 = item.x, item.y, item.w, item.h
	w2,h2 = w2 or w1, h2 or h1
	if x1 ~= x2 or y1 ~= y2 or w1 ~= w2 or h1 ~= h2 then
		-- bump optimization here
	end
end

local function worldMove (self, item, goalX, goalY)
	local actualX, actualY, cols, len = self:check(item, goalX, goalY)
	self:update(item, actualX, actualY)
	return actualX, actualY, cols, len
end

function slope.newWorld ()
	local world = {}
	world.meter = 100 -- pixels / units per meter
	world.objLines = {}
	world.addLines = worldAddLines
	world.addLine = worldAddLine
	world.check = worldCheck
	world.move = worldMove
	world.update = worldUpdate -- todo: add bump optimization
	return world
end


return slope