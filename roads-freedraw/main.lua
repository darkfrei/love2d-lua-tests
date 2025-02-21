local currentDraw = nil
local minDist = 60
local draws = {}


-- function to calculate distance between two points
local function getDist (x1, y1, x2, y2)
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- function to calculate square of distance between two points (to avoid sqrt calculation)
local function getSquareDist (x1, y1, x2, y2)
	return(x2 - x1)^2 + (y2 - y1)^2
end

local function getPointSegmentDistSq(px, py, x1, y1, x2, y2)
	local vx, vy = x2 - x1, y2 - y1
	local wx, wy = px - x1, py - y1
	local t = (wx * vx + wy * vy) / (vx * vx + vy * vy)
	t = math.max(0, math.min(1, t))
	local projX, projY = x1 + t * vx, y1 + t * vy
	return getSquareDist(px, py, projX, projY)
end

-- function to find the nearest segment
local function getNearestSegment(x, y)
--	local minDistSq = math.huge
	local minDistSq = (minDist/2)^2
	local nearestSeg = nil

	-- iterate through all the lines
	for _, draw in ipairs(draws) do
		for i = 1, #draw.line - 3, 2 do
			local x1, y1 = draw.line[i], draw.line[i + 1]
			local x2, y2 = draw.line[i + 2], draw.line[i + 3]

			local distSq = getPointSegmentDistSq(x, y, x1, y1, x2, y2)

			-- check if the segment is closer
			if distSq < minDistSq then
				minDistSq = distSq
				nearestSeg = {x1, y1 ,x2, y2}
			end
		end
	end

	return nearestSeg
end

-- function to calculate the cosine of the angle between two vectors
local function getCosineOfAngle(x1, y1, x2, y2, x3, y3)
	local v1x, v1y = x2 - x1, y2 - y1
	local v2x, v2y = x3 - x2, y3 - y2

	local len1 = math.sqrt(v1x * v1x + v1y * v1y)
	local len2 = math.sqrt(v2x * v2x + v2y * v2y)

	if len1 == 0 or len2 == 0 then return 1 end

	local dot = v1x * v2x + v1y * v2y
	local cosTheta = dot / (len1 * len2)

	return cosTheta
end

-- function to choose the best point based on the cosine of the angle
local function getBestConnectionPoint(x, y, lastX, lastY)
	if not debugSegment then return nil, nil end
	local x1, y1 = debugSegment[1], debugSegment[2]
	local x2, y2 = debugSegment[3], debugSegment[4]

	-- calculate the cosine of angle for both possible connections
	local cos1 = getCosineOfAngle(lastX, lastY, x, y, x1, y1)
	local cos2 = getCosineOfAngle(lastX, lastY, x, y, x2, y2)

	-- check if both angles are too large
	if cos1 < 0.866 and cos2 < 0.866 then -- 30 degrees
		return nil, nil -- neither is suitable
	end

	-- return the point with the smallest angle
	if cos1 > cos2 then
		return x1, y1
	else
		return x2, y2
	end
end

-- function to calculate the angle between two vectors
local function getAngleBetweenVectors(x1, y1, x2, y2, x3, y3)
	local v1x, v1y = x2 - x1, y2 - y1
	local v2x, v2y = x3 - x2, y3 - y2

	local len1 = math.sqrt(v1x * v1x + v1y * v1y)
	local len2 = math.sqrt(v2x * v2x + v2y * v2y)

	if len1 == 0 or len2 == 0 then return 180, 0 end

	local dot = v1x * v2x + v1y * v2y
	local cosTheta = dot / (len1 * len2)

	local angle = math.deg(math.acos(math.max(-1, math.min(1, cosTheta))))

	-- calculate the sign using the cross product
	local crossProduct = v1x * v2y - v1y * v2x
	local sign = crossProduct > 0 and 1 or (crossProduct < 0 and -1 or 0)
--	print (sign)

	return angle, sign
end

-- function to calculate the link angle
local function getLinkAngle(currentDraw, x, y)
	-- calculate angle between the current position and the new position
	local lastX, lastY = currentDraw.line[#currentDraw.line - 3], currentDraw.line[#currentDraw.line - 2]
	if not lastX then return end
	local angle, sign = getAngleBetweenVectors(lastX, lastY, currentDraw.x, currentDraw.y, x, y)

	-- determine the sign of the angle for direction
--	print (angle, sign)
	if angle > 30 then
--		print (anle, sign)
		return angle, sign
	end
end


-- function to calculate the angle between two points
local function getAngleBetweenPoints(x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	return math.atan2(dy, dx)
end


-- function to limit the angle to 30 degrees and get the new position based on the sign
local function getLimitedAnglePoint(currentDraw, x, y, linkAngle, sign)
	-- limit the angle to 30 degrees
	local maxAngle = 30
	local angleRad = math.rad(maxAngle) * sign


	-- calculate the direction vector of the previous segment
	local prevX = currentDraw.line[#currentDraw.line - 3]
	local prevY = currentDraw.line[#currentDraw.line - 2]

	if not prevX then return end
--	local dxPrev = currentDraw.x - prevX
--	local dyPrev = currentDraw.y - prevY


	local prevAngle = getAngleBetweenPoints(prevX, prevY, currentDraw.x, currentDraw.y)


	-- calculate the direction vector of the new segment
	local dx = x - currentDraw.x
	local dy = y - currentDraw.y
	local len = math.sqrt(dx * dx + dy * dy)

	local newAngle = prevAngle + angleRad

	-- calculate the new direction using the limited angle
	local newDx = math.cos(newAngle) * len
	local newDy = math.sin(newAngle) * len

	-- calculate the new position
	local newX = currentDraw.x + newDx
	local newY = currentDraw.y + newDy

	return newX, newY
end




function love.mousepressed (mx, my)
	local nearSegment = getNearestSegment(mx, my)
	if nearSegment then
		local x1, y1 = nearSegment[1], nearSegment[2]
		local x2, y2 = nearSegment[3], nearSegment[4]
		local v1 = getSquareDist (x1, y1, mx, my)
		local v2 = getSquareDist (x2, y2, mx, my)
		if v1 < v2 then
			mx, my = x1, y1
		else
			mx, my = x2, y2
		end
	end
	currentDraw = {
		x=mx,
		y=my,
		line = {mx, my},
		nextX = mx,
		nextY = my
	}
end

-- limit the distance between points
local function limitDistance(cx, cy, mx, my, minDist)
	local dx, dy = mx - cx, my - cy
	local dist = math.sqrt(dx * dx + dy * dy)

	if dist > minDist then
		local k = minDist / dist
		return cx + dx * k, cy + dy * k
	end
	return mx, my
end

-- limit the angle relative to the previous segment
local function limitAngle(prevX, prevY, cx, cy, mx, my, maxAngle)
	if not prevX or not prevY then return mx, my end

	local prevDx, prevDy = cx - prevX, cy - prevY
	local newDx, newDy = mx - cx, my - cy

	local prevAngle = math.atan2(prevDy, prevDx)
	local newAngle = math.atan2(newDy, newDx)
	local angleDiff = math.deg(newAngle - prevAngle)

	-- normalize to [-180, 180]
	angleDiff = (angleDiff + 180) % 360 - 180

	if angleDiff > maxAngle then
		newAngle = prevAngle + math.rad(maxAngle)
	elseif angleDiff < -maxAngle then
		newAngle = prevAngle - math.rad(maxAngle)
	else
		return mx, my
	end

	local dist = math.sqrt(newDx * newDx + newDy * newDy)
	return cx + math.cos(newAngle) * dist, cy + math.sin(newAngle) * dist
end

-- snap to the nearest node
local function snapToNode(mx, my)
	local nodeX, nodeY = getBestConnectionPoint(mx, my)
	if nodeX and nodeY then
		return nodeX, nodeY
	end
	return mx, my
end


-- store the new point in the line
local function storePoint(line, x, y)
	table.insert(line, x)
	table.insert(line, y)
end



-- function to handle mouse movements
function love.mousemoved(mx, my, mdx, mdy) 
	debugSegment = getNearestSegment(mx, my)
	
	if currentDraw then

		local prevX = currentDraw.line[#currentDraw.line - 3]
		local prevY = currentDraw.line[#currentDraw.line - 2]

		local dx = (mx - currentDraw.x)
		local dy = (my - currentDraw.y)
		local direction = math.atan2 (dy, dx)
		local dist = getDist (currentDraw.x, currentDraw.y, mx, my)


		if dist > minDist then 
			local k = minDist  / dist
			dist = minDist
			dx = k * dx
			dy = k * dy
			mx = currentDraw.x + dx
			my = currentDraw.y + dy
			print ('new mx, my', mx, my)
		end


		-- check if there is a previous segment
		if prevX and prevY then
			local prevDx, prevDy = currentDraw.x - prevX, currentDraw.y - prevY
			local prevAngle = math.atan2(prevDy, prevDx)
			local newAngle = math.atan2(dy, dx)
			local angleDiff = math.deg(newAngle - prevAngle)

			-- normalize angle difference to [-180, 180]
			if angleDiff > 180 then
				angleDiff = angleDiff - 360
			elseif angleDiff < -180 then
				angleDiff = angleDiff + 360
			end

			-- limit to ±30 degrees
			if angleDiff > 30 then
				newAngle = prevAngle + math.rad(30)
			elseif angleDiff < -30 then
				newAngle = prevAngle - math.rad(30)
			end

			-- recalculate new mx, my with limited angle
			local newDx = math.cos(newAngle) * dist
			local newDy = math.sin(newAngle) * dist
			mx, my = currentDraw.x + newDx, currentDraw.y + newDy
		end

		-- update the current position
		if dist == minDist then
			currentDraw.x = mx
			currentDraw.y = my

			table.insert(currentDraw.line, mx)
			table.insert(currentDraw.line, my)
		end

		currentDraw.nextX = mx
		currentDraw.nextY = my

		-- get the nearest segment for connection
		

		-- get the best connection point
		local connectX, connectY = getBestConnectionPoint(mx, my, currentDraw.x, currentDraw.y)

		if connectX then
			currentDraw.nextX = connectX
			currentDraw.nextY = connectY
		end
	end
end

function love.mousereleased(x, y, button)
	if currentDraw then
		table.insert(currentDraw.line, currentDraw.nextX)
		table.insert(currentDraw.line, currentDraw.nextY)
		if #currentDraw.line > 3 then
			table.insert (draws, currentDraw)
		end
		currentDraw = nil
		debugSegment = nil
	end
end


function love.draw()

	for _, draw in ipairs (draws) do
		love.graphics.setLineWidth (2)
		love.graphics.setColor(1, 1, 1)
		love.graphics.line(draw.line)
		for j = 1, #draw.line-1, 2 do
			love.graphics.circle('line', draw.line[j], draw.line[j + 1], 3)
		end

		love.graphics.setLineWidth (4)
		love.graphics.line(draw.line[#draw.line-3], draw.line[#draw.line-2], draw.line[#draw.line-1], draw.line[#draw.line])
	end



	if currentDraw then
		if #currentDraw.line > 2 then
			love.graphics.setLineWidth (2)
			love.graphics.setColor(1, 1, 0)
			love.graphics.line(currentDraw.line)

		end

		love.graphics.setLineWidth (3)
		love.graphics.setColor(0, 1, 1)
		love.graphics.line(currentDraw.x, currentDraw.y, currentDraw.nextX, currentDraw.nextY)
	end


	if debugSegment then
		love.graphics.setLineWidth (3)
		love.graphics.setColor(1, 0, 0)
		love.graphics.line(debugSegment)
	end
end


function love.keypressed(key)
	if key == "tab" then
		draws = {}
		debugSegment = nil
	end
	if key == "z" then
		table.remove (draws)
	end
end