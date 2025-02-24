
-- chain parameters
local totalSum = 400
local numSegments = 32
local segmentLength = totalSum / numSegments
local maxAngle = math.rad(15) -- maximum allowed rotation in radians

-- list of polyline points
local points = {}

-- fixed start point
local startPoint = {x = 400, y = 580}

-- target point (where we want to reach)
local targetPoint = {x = 600, y = 300}

-- end of the chain (may not reach target)
local endPoint = {x = 600, y = 300}

-- initialize points
for i = 0, numSegments do
	table.insert(points, {x = startPoint.x + i * segmentLength, y = startPoint.y})
end

-- function to calculate distance between two points
local function distanceP (p1, p2)
	return math.sqrt((p2.x - p1.x)^2 + (p2.y - p1.y)^2)
end

-- function to calculate angle between two points
local function angleBetweenP (p1, p2)
	return math.atan2(p2.y - p1.y, p2.x - p1.x)
end

function math.sign(v)
	if v > 0 then
		return 1
	elseif v < 0 then
		return -1
	else
		return 0
	end
end



-- function to clamp joint angle within limit
local function clampJointAngle (baseAngle, angleDiff)
	angleDiff = ((angleDiff-baseAngle) + math.pi) % (2 * math.pi) - math.pi
	local absAngle = math.min (maxAngle, math.abs (angleDiff))
	local resultAngle = baseAngle + math.sign(angleDiff) * absAngle
	return resultAngle
end


-- function to solve inverse kinematics using the fabrik algorithm
local function solveIK_FABRIK()
	-- forward pass (pull end point toward target)
	points[#points].x = targetPoint.x
	points[#points].y = targetPoint.y

	for i = #points - 1, 1, -1 do
		local p1, p2, p3 = points[i], points[i+1], points[i+2]
		local d = distanceP(p1, p2)
		local ratio = segmentLength / d

		-- adjust the position of the next segment
		p1.x = p2.x + (p1.x - p2.x) * ratio
		p1.y = p2.y + (p1.y - p2.y) * ratio

		if p3 then
			local a1 = angleBetweenP(p1, p2)
			local a2 = angleBetweenP(p2, p3)
			local a3 = clampJointAngle (a2, a1)
			p1.x = p2.x - segmentLength*math.cos (a3)
			p1.y = p2.y - segmentLength*math.sin (a3)
		end
	end

	-- backward pass (fix start point)
	points[1].x = startPoint.x
	points[1].y = startPoint.y

	-- propagate adjustments forward from the start point
	for i = 1, #points-1 do
		local p1, p2, p3 = points[i], points[i+1], points[i+2]

		local d = distanceP(p1, p2)
		local ratio = segmentLength / d

		-- adjust the position of the next segment
		p2.x = p1.x + (p2.x - p1.x) * ratio
		p2.y = p1.y + (p2.y - p1.y) * ratio

		if p3 then
			local a1 = angleBetweenP(p1, p2)
			local a2 = angleBetweenP(p2, p3)
			local a3 = clampJointAngle (a1, a2)
			p3.x = p2.x + math.cos(a3) * segmentLength
			p3.y = p2.y + math.sin(a3) * segmentLength
		end
	end

	-- update end point position
	endPoint.x = points[#points].x
	endPoint.y = points[#points].y
end


-- parameters for a lissajous curve trajectory
local a, b = 150, 150        -- amplitudes for the trajectory
local omegaX, omegaY = 1, 2   -- frequencies for the trajectory
local phase = 0             -- phase shift
local time = 0

-- update function, moving the target along a lissajous curve
function love.update(dt)
	time = time + dt
	targetPoint.x = 400 + a * math.sin(omegaX * time)
	targetPoint.y = 300 + b * math.sin(omegaY * time + phase)
	solveIK_FABRIK()
end

-- rendering function
function love.draw()
	-- solve ik
	solveIK_FABRIK()

	-- draw target point (mouse)
	love.graphics.setColor(0, 1, 0) -- green
	love.graphics.circle("fill", targetPoint.x, targetPoint.y, 5)

	-- draw lines and points
	for i = 1, #points - 1 do
		love.graphics.setColor(1, 1, 1) -- white
		love.graphics.line(points[i].x, points[i].y, points[i+1].x, points[i+1].y)
		love.graphics.circle("fill", points[i].x, points[i].y, 5)
	end

	-- draw end point
	love.graphics.circle("fill", endPoint.x, endPoint.y, 5)
end

-- mouse movement handler
--function love.mousemoved(x, y, dx, dy, istouch)
--	targetPoint.x = x
--	targetPoint.y = y
--	solveIK_FABRIK()
--end