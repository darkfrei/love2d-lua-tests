local BASE_LENGTH = 20
local BASE_ANGLE = math.rad(22.5)

-- calculates circumcircle for three points
local function getCircumcircle(p1, p2, p3)
	local x1, y1 = p1.x, p1.y
	local x2, y2 = p2.x, p2.y
	local x3, y3 = p3.x, p3.y

	local d = 2 * (x1*(y2-y3) + x2*(y3-y1) + x3*(y1-y2))
	if math.abs(d) < 0.0001 then return nil end

	local t1 = x1*x1 + y1*y1
	local t2 = x2*x2 + y2*y2
	local t3 = x3*x3 + y3*y3

	local cx = (t1*(y2-y3) + t2*(y3-y1) + t3*(y1-y2)) / d
	local cy = (t1*(x3-x2) + t2*(x1-x3) + t3*(x2-x1)) / d
	local radius = math.sqrt((x1-cx)^2 + (y1-cy)^2)

	return {x = cx, y = cy, radius = radius}
end


-- calculates turning circle for current position and angle
-- x, y: starting position
-- angle: current facing angle
-- turnDirection: 1 for clockwise, -1 for counter-clockwise
-- returns: circumcircle object
local function calculateBaseTurningCircle(x, y, angle, turnDirection)
	local p1 = {x = x, y = y}
	local angle2 = angle + turnDirection * BASE_ANGLE
	local p2 = {
		x = x + math.cos(angle2) * BASE_LENGTH,
		y = y + math.sin(angle2) * BASE_LENGTH
	}
	local angle3 = angle2 + turnDirection * BASE_ANGLE
	local p3 = {
		x = p2.x + math.cos(angle3) * BASE_LENGTH,
		y = p2.y + math.sin(angle3) * BASE_LENGTH
	}
	return getCircumcircle(p1, p2, p3)
end

-- calculates smallest difference between two angles
local function angleDifference(a, b)
	return (a - b + math.pi) % (2 * math.pi) - math.pi
end

local function calculateDistance(x1, y1, x2, y2)
	return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

-- calculates direction from one point to another
local function calculateDirection(fromX, fromY, toX, toY)
	return math.atan2(toY - fromY, toX - fromX)
end

---------------------------------------------------------------
-- end of utils
---------------------------------------------------------------

-- path object for vessel movement
local PolyPath = {}
PolyPath.__index = PolyPath

-- creates new path instance
-- returns: new PolyPath object
function PolyPath.new()
	local instance = {
		points = {},
		totalLength = 0
	}
	setmetatable(instance, PolyPath)
	return instance
end

function PolyPath:addPoint(x, y, angle, lenght)
	-- lenght is the distance to next point; now unknown
	local point = {x = x, y = y, angle = angle, lenght=lenght}
	table.insert(self.points, point)
	return point
end

-- calculates path from vessel to target
-- ship: vessel object with position and baseSpeed
-- returns: path object, reached (boolean)
function PolyPath:getPlannedPath(ship)

	local startX, startY = ship.x, ship.y
	local startAngle = ship.angle
	local targetX, targetY = ship.target.x, ship.target.y

	local path = PolyPath.new()
	local point = path:addPoint(startX, startY, startAngle)

	local x, y = startX, startY
	local angle = startAngle

	local targetAngle = calculateDirection(startX, startY, targetX, targetY)
	local turnDirection = angleDifference(targetAngle, angle) > 0 and 1 or -1
	local baseCircle = calculateBaseTurningCircle(x, y, angle, turnDirection)

	local totalLength = 0

	if baseCircle then
		path.circle = {
			x = baseCircle.x,
			y = baseCircle.y,
			radius = baseCircle.radius,
			direction = turnDirection
		}

		local initialDist = calculateDistance(baseCircle.x, baseCircle.y, targetX, targetY)
		if initialDist < baseCircle.radius then
			local turnAngle = calculateDirection(baseCircle.x, baseCircle.y, targetX, targetY)
			targetX = baseCircle.x + math.cos(turnAngle) * baseCircle.radius
			targetY = baseCircle.y + math.sin(turnAngle) * baseCircle.radius
		end
	end

	local iterations = 0

--	local maxIterations = 1000
	local maxIterations = ship.baseSpeed

	local distanceToTarget

	while iterations < maxIterations do
		iterations = iterations + 1
--		print ('iteration: '..iterations)

		distanceToTarget = calculateDistance(x, y, targetX, targetY)
		local directionToTarget = calculateDirection(x, y, targetX, targetY)
		local angleToTarget = angleDifference(directionToTarget, angle)

		if distanceToTarget <= BASE_LENGTH then
			point.length = distanceToTarget
			local point = path:addPoint(targetX, targetY, angle)

			path.totalLength = totalLength + distanceToTarget
			return path, true -- reached
		else
			totalLength = totalLength + BASE_LENGTH
			point.length = BASE_LENGTH
		end

		if math.abs(angleToTarget) > BASE_ANGLE then
			angle = angle + turnDirection * BASE_ANGLE
		else
			angle = directionToTarget
		end

		local newX = x + math.cos(angle) * BASE_LENGTH
		local newY = y + math.sin(angle) * BASE_LENGTH
--		print ()
		point = path:addPoint(newX, newY, angle)
		x, y = newX, newY
	end

	path.totalLength = totalLength

	return path, false -- not reached
end


-- gets position and angle at progress along path
-- t: progress (0-1) where 0=start, 1=end
-- returns: x, y, angle
function PolyPath:getPointAtProgress(t)
	if t < 0 then t = 0 end
	if t > 1 then t = 1 end

	local distance = t * self.totalLength
--	print ('distance', distance)

	local accumulatedDistance = 0

	for i = 1, #self.points - 1 do
		local p1 = self.points[i]
		local p2 = self.points[i + 1]
		local segmentLength = p1.length
		if accumulatedDistance + segmentLength >= distance then
			local segmentProgress = (distance - accumulatedDistance) / segmentLength
			local x = p1.x + segmentProgress * (p2.x - p1.x)
			local y = p1.y + segmentProgress * (p2.y - p1.y)
			local angleDiff = (p2.angle - p1.angle + math.pi) % (2 * math.pi) - math.pi
			local angle = p1.angle + segmentProgress * angleDiff
			return x, y, angle
		end
		accumulatedDistance = accumulatedDistance + segmentLength
	end

	local lastPoint = self.points[#self.points]
	return lastPoint.x, lastPoint.y, lastPoint.angle
end

-- renders path to screen
function PolyPath:draw (mode, radius)
	mode = mode or 'fill'
	radius = radius or 2
	local path = self
	for i = 2, #path.points do
		local p = path.points[i]
		love.graphics.circle(mode, p.x, p.y, radius)
	end
end

return PolyPath