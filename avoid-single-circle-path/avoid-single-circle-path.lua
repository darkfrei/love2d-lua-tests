-- https://github.com/darkfrei/love2d-lua-tests/tree/main/avoid-single-circle-path
-- 2025-07-12
local M = {}

-- calculate distance between two points
local function distance(point1, point2)
	local dx = point2.x - point1.x
	local dy = point2.y - point1.y
	return math.sqrt(dx*dx + dy*dy)
end

-- check if segment intersects a circle
local function segmentCircleIntersection(point1, point2, circle)
	local dx = point2.x - point1.x
	local dy = point2.y - point1.y
	local a = dx*dx + dy*dy
	local b = 2*(dx*(point1.x - circle.x) + dy*(point1.y - circle.y))
	local c = (point1.x - circle.x)^2 + (point1.y - circle.y)^2 - circle.radius^2
	local discriminant = b*b - 4*a*c

	if discriminant < 0 then return false end

	local t1 = (-b - math.sqrt(discriminant))/(2*a)
	local t2 = (-b + math.sqrt(discriminant))/(2*a)

	return (t1 >= 0 and t1 <= 1) or (t2 >= 0 and t2 <= 1)
end

-- calculate tangent points from point to circle
local function calculateTangentPoints(point, circle)
	local dx = point.x - circle.x
	local dy = point.y - circle.y
	local distSq = dx*dx + dy*dy
	local radiusSq = circle.radius*circle.radius

	if distSq <= radiusSq then return {} end

	local invDist = 1/math.sqrt(distSq)
	dx = dx * invDist
	dy = dy * invDist

	local a = radiusSq * invDist
	local b = circle.radius * math.sqrt(distSq - radiusSq) * invDist

	return {
		{x = circle.x + a*dx - b*dy, y = circle.y + a*dy + b*dx}, -- left tangent
		{x = circle.x + a*dx + b*dy, y = circle.y + a*dy - b*dx}  -- right tangent
	}
end

-- calculate path length and components
local function calculatePath(start, goal, circle, startTangent, goalTangent)
	-- calculate arc angle between tangents
	local angle1 = math.atan2(startTangent.y - circle.y, startTangent.x - circle.x)
	local angle2 = math.atan2(goalTangent.y - circle.y, goalTangent.x - circle.x)
	local arcAngle = angle2 - angle1

	-- normalize arc angle
	if arcAngle < 0 then arcAngle = arcAngle + 2*math.pi end
	if arcAngle > math.pi then arcAngle = arcAngle - 2*math.pi end

	return {
		path = {
			{type = "segment", points = {start, startTangent}},
			{type = "arc", center = circle, radius = circle.radius, 
				startAngle = angle1, endAngle = angle1 + arcAngle},
			{type = "segment", points = {goalTangent, goal}}
		},
		length = distance(start, startTangent) + circle.radius * math.abs(arcAngle) + distance(goalTangent, goal)
	}
end

-- main function to find path around single circle
function M.getPath(start, goal, circle)
	-- first check if circle is actually in the way
	if not segmentCircleIntersection(start, goal, circle) then
		return {
			{type = "segment", points = {start, goal}},
			length = distance(start, goal)
		}
	end

	local startTangents = calculateTangentPoints(start, circle)
	local goalTangents = calculateTangentPoints(goal, circle)

	if #startTangents < 2 or #goalTangents < 2 then 
		return {
			{type = "segment", points = {start, goal}},
			length = distance(start, goal)
		}
	end

	-- calculate both possible paths (left-right and right-left)
	local paths = {
		calculatePath(start, goal, circle, startTangents[1], goalTangents[2]), -- left-right
		calculatePath(start, goal, circle, startTangents[2], goalTangents[1])  -- right-left
	}

	-- return shortest path
	return paths[1].length < paths[2].length and paths[1].path or paths[2].path
end

function M.drawPath(path)
	for _, segment in ipairs(path) do
		if segment.type == "segment" then
			-- draw straight segment
			love.graphics.line(
				segment.points[1].x, segment.points[1].y,
				segment.points[2].x, segment.points[2].y
			)
		elseif segment.type == "arc" then
			-- draw smooth arc
			local drawmode = 'line'
			local arctype = 'open'
			local center = segment.center
			local radius = segment.radius
			local angle1 = segment.startAngle
			local angle2 = segment.endAngle
			
			love.graphics.arc( drawmode, arctype, center.x, center.y, radius, angle1, angle2)
		end
	end
end

return M