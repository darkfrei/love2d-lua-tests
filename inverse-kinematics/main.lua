--  https://love2d.org/forums/viewtopic.php?p=262040#p262040

-- chain parameters
local totalSum = 400
local numSegments = 8
local segmentLength = totalSum / numSegments

-- list of polyline points
local points = {}

-- fixed start point
local startPoint = {x = 400, y = 580}

-- target point (where we want to reach)
local targetPoint = {x = 600, y = 300}

-- end of the chain (may not reach target)
local endPoint = {x = 600, y = 300}

--Lissajous
local a, b = 150, 150        -- amplitudes for the trajectory
local omegaX, omegaY = 1, 2   -- frequencies for the trajectory
local phase = 0             -- phase shift
local time = 0

-- initialize points
for i = 0, numSegments do
	table.insert(points, {x = startPoint.x + i * segmentLength, y = startPoint.y})
end

-- fabrik inverse kinematics function

-- function to calculate distance between two points
local function distance(x1, y1, x2, y2)
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- function to calculate angle between two points
local function angleBetween(x1, y1, x2, y2)
	return math.atan2(y2 - y1, x2 - x1)
end


local function solveIK_FABRIK()
	-- calculate distance to target
	local distToTarget = distance(startPoint.x, startPoint.y, targetPoint.x, targetPoint.y)

	-- if target is too far, move endPoint to the maximum possible distance
	if distToTarget > totalSum then
		local angle = angleBetween(startPoint.x, startPoint.y, targetPoint.x, targetPoint.y)
		endPoint.x = startPoint.x + math.cos(angle) * totalSum
		endPoint.y = startPoint.y + math.sin(angle) * totalSum
	else
		-- if target is within reach, set endPoint directly to targetPoint
		endPoint.x = targetPoint.x
		endPoint.y = targetPoint.y
	end

	-- move the last point to the endPoint position
	points[#points].x = endPoint.x
	points[#points].y = endPoint.y

	-- iterate from the last segment to the first, adjusting positions
	for i = #points - 1, 1, -1 do
		local d = distance(points[i].x, points[i].y, points[i+1].x, points[i+1].y)
		local angle = angleBetween(points[i+1].x, points[i+1].y, points[i].x, points[i].y)
		local ratio = segmentLength / d

		-- reposition the current point at the correct distance
		points[i].x = points[i+1].x + (points[i].x - points[i+1].x) * ratio
		points[i].y = points[i+1].y + (points[i].y - points[i+1].y) * ratio
	end

	-- ensure the first point remains fixed at startPoint
	points[1].x = startPoint.x
	points[1].y = startPoint.y

	-- iterate from the first segment to the last, adjusting positions
	for i = 1, #points-1 do
		local d = distance(points[i].x, points[i].y, points[i+1].x, points[i+1].y)
		local angle = angleBetween(points[i].x, points[i].y, points[i+1].x, points[i+1].y)
		local ratio = segmentLength / d

		points[i+1].x = points[i].x + math.cos(angle) * segmentLength
		points[i+1].y = points[i].y + math.sin(angle) * segmentLength
	end
end

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
