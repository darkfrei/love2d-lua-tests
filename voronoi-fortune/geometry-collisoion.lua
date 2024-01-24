-- circle to circle collision
function checkCircularCollision(x1, y1, r1, x2, y2, r2)
	local dx, dy, sr = x2 - x1, y2 - y1, r1 + r2
	return dx*dx + dy*dy < sr*sr
end

-- circle to rectangle collision
function checkCircleToRectangleCollision(cx, cy, cr, rectX, rectY, rectW, rectH)
	local nearestX = math.max(rectX, math.min(cx, rectX + rectW))
	local nearestY = math.max(rectY, math.min(cy, rectY + rectH))
	local dx, dy = math.abs(cx - nearestX), math.abs(cy - nearestY)
	if dx > cr or dy > cr then return false end
	return dx*dx + dy*dy < cr*cr
end

-- circle to polygon collision
function checkCircleToPolygonCollision(cx, cy, cr, poly)
	local function nearestPolygonPoint(cx, cy, x1, y1, dx, dy)
		local d = dx * dx + dy * dy
		if d == 0 then return x1, y1 end -- length of the segment was 0
		local t = ((cx - x1) * dx + (cy - y1) * dy) / d
		t = math.max(0, math.min(1, t))
		return x1 + t * dx, y1 + t * dy
	end

	local n = #poly
	local x1, y1 = poly[n - 1], poly[n]
	local x2, y2 = poly[1], poly[2]
	for i = 1, n-1, 2 do
		local nearestX, nearestY = nearestPolygonPoint(cx, cy, x1, y1, x2-x1, y2-y1)
		local dx, dy = cx - nearestX, cy - nearestY
		if dx*dx + dy*dy < cr*cr then
			return true  -- Collision detected
		end
		x1, y1, x2, y2 = x2, y2, poly[i+2], poly[i+3]
	end
	return false
end

function createCounter(startValue)
	local count = startValue or 0  -- Initial count

	-- The returned function is the actual counter function
	local function counter()
		-- adding 1 to the counter
		count = count + 1
		
		-- return count value
		return count
	end

	-- return generated function
	return counter
end
