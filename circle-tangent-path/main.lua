-- main.lua for love2d

-- calculate distance between two points
local function distance(point1, point2)
	local dx = point2.x - point1.x
	local dy = point2.y - point1.y
	return math.sqrt(dx*dx + dy*dy)
end

-- calculate right tangent from point to circle
local function calculateRightTangentPoint(point, circle, isLeft)
	local dx = point.x - circle.x
	local dy = point.y - circle.y
	local distSq = dx*dx + dy*dy
	local radiusSq = circle.radius*circle.radius

	if distSq <= radiusSq then return nil end

	local invDist = 1/math.sqrt(distSq)
	dx = dx * invDist
	dy = dy * invDist

	local a = radiusSq * invDist
	local b = circle.radius * math.sqrt(distSq - radiusSq) * invDist
	local sign = isLeft and -1 or 1

	return {
		x = circle.x + a*dx + b*dy*sign, 
		y = circle.y + a*dy - b*dx*sign
	}
end

-- check if segment intersects a circle
local function segmentCircleIntersection(x1, y1, x2, y2, cx, cy, cr)
	-- local x1, y1 = point1.x, point1.y
	-- local x2, y2 = point2.x, point2.y
	-- local cx, cy, cr = circle.x, circle.y, circle.radius
	local dx, dy = x2 - x1, y2 - y1
	local dx2, dy2 = cx - x1, cy - y1

	local a = dx*dx + dy*dy
	local b = 2*(dx*(x1 - cx) + dy*(y1 - cy))
	local c = dx2^2 + dy2^2 - cr^2
	local discriminant = b*b - 4*a*c

	if discriminant < 0 then return false end

	local t1 = (-b - math.sqrt(discriminant))/(2*a)
	local t2 = (-b + math.sqrt(discriminant))/(2*a)

	return (t1 >= 0 and t1 <= 1) or (t2 >= 0 and t2 <= 1)
end

-- check if line intersects any circle except specified
local function anyLineCircleIntersection(line, circles, exceptCircle)
	local x1, y1, x2, y2 = line[1], line[2], line[3], line[4]
	for i, circle in ipairs (circles) do
		if exceptCircle and circle == exceptCircle then
			-- skip
		else
			local cx, cy, cr = circle.x, circle.y, circle.radius
			if segmentCircleIntersection(x1, y1, x2, y2, cx, cy, cr) then
				return true
			end
		end
	end
	return false
end

-- check if arc on current circle from current point to next point intersects other circles
local function arcIntersectsCircle(currentCircle, currentPoint, nextRightTangent, circles)
	-- calculate angles for current point and next point relative to circle center
	local cx, cy = currentCircle.x, currentCircle.y
	local startAngle = math.atan2(currentPoint.y - cy, currentPoint.x - cx)
	local endAngle = math.atan2(nextRightTangent.y - cy, nextRightTangent.x - cx)

	-- determine shortest arc (clockwise or counter-clockwise)
	local deltaAngle = endAngle - startAngle
	if deltaAngle > math.pi then
		deltaAngle = deltaAngle - 2 * math.pi
	elseif deltaAngle < -math.pi then
		deltaAngle = deltaAngle + 2 * math.pi
	end

	local isClockwise = deltaAngle < 0
	local absDeltaAngle = math.abs(deltaAngle)
	local start, finish = startAngle, endAngle
	if isClockwise then
		start, finish = endAngle, startAngle
	end

	-- check each other circle
	for _, otherCircle in ipairs(circles) do
		if otherCircle ~= currentCircle then
			local ox, oy = otherCircle.x, otherCircle.y
			local r1, r2 = currentCircle.radius, otherCircle.radius

			-- distance between circle centers
			local dist = math.sqrt((ox - cx)^2 + (oy - cy)^2)

			-- skip if centers are too far for intersection
			if dist > r1 + r2 then
				goto continue
			end

			-- angle from current circle center to other circle center
			local centerAngle = math.atan2(oy - cy, ox - cx)

			-- normalize angle relative to start angle
			local relAngle = centerAngle - start
			if relAngle > math.pi then
				relAngle = relAngle - 2 * math.pi
			elseif relAngle < -math.pi then
				relAngle = relAngle + 2 * math.pi
			end

			-- check if other circle center lies within arc sector
			if isClockwise then
				if relAngle >= -absDeltaAngle and relAngle <= 0 then
					-- check if center is close enough for intersection
					if dist <= r1 + r2 then
						return true
					end
				end
			else
				if relAngle >= 0 and relAngle <= absDeltaAngle then
					if dist <= r1 + r2 then
						return true
					end
				end
			end
		end
		::continue::
	end

	return false
end

-- calculate external tangent line between two circles (right-to-right or other combinations)
local function calculateCircleCircleTangentLine(currentCircle, nextCircle, isLeft1, isLeft2)
	local x1, y1, r1 = currentCircle.x, currentCircle.y, currentCircle.radius
	local x2, y2, r2 = nextCircle.x, nextCircle.y, nextCircle.radius

	-- distance between circle centers
	local dx = x2 - x1
	local dy = y2 - y1
	local dist = math.sqrt(dx*dx + dy*dy)

	-- check if circles intersect or coincide
	if dist < math.abs(r1 - r2) then
		return nil -- internal intersection
	elseif dist < r1 + r2 then
		return nil -- external intersection
	elseif dist == 0 and r1 == r2 then
		return nil -- circles coincide
	end

	-- for external tangent, radii have same sign
	local r1_sign = isLeft1 and -1 or 1
	local r2_sign = isLeft2 and -1 or 1
	local r1_adj = r1 * r1_sign
	local r2_adj = r2 * r2_sign

	-- calculate tangent angle
	local theta = math.asin((r1_adj - r2_adj) / dist)
	local alpha = math.atan2(dy, dx)

	-- angle for tangent point on first circle
	local angle1 = alpha + theta + (isLeft1 and math.pi/2 or -math.pi/2)
	local angle2 = alpha + theta + (isLeft2 and math.pi/2 or -math.pi/2)

	-- tangent points Q (on current circle) and P (on next circle)
	local Q = {
		x = x1 + r1 * math.cos(angle1),
		y = y1 + r1 * math.sin(angle1)
	}
	local P = {
		x = x2 + r2 * math.cos(angle2),
		y = y2 + r2 * math.sin(angle2)
	}

	return Q, P
end

-- create arc segment on circle between two tangent points
-- parameters:
--   currentCircle - circle {x, y, radius}
--   pointP - start tangent point {x, y}
--   pointQ - end tangent point {x, y}
--   isLeft - arc direction (true for counter-clockwise, false for clockwise)
-- returns:
--   table with arc data or nil if points are not on circle
local function isOnCircle(point, circle)
	local cx, cy, r = circle.x, circle.y, circle.radius
	local dx = point.x - cx
	local dy = point.y - cy
	return math.abs(dx*dx + dy*dy - r*r) < 1e-6
end

local function createArcSegment(currentCircle, pointP, pointQ, isLeft)
	local cx, cy, r = currentCircle.x, currentCircle.y, currentCircle.radius

	-- check if points lie on circle (with 1e-6 tolerance)
	-- if not (isOnCircle(pointP, currentCircle) and isOnCircle(pointQ, currentCircle)) then
	-- 	return nil -- one of the points is not on circle
	-- end

	-- calculate angles for points P and Q
	local startAngle = math.atan2(pointP.y - cy, pointP.x - cx)
	local endAngle = math.atan2(pointQ.y - cy, pointQ.x - cx)

	-- adjust angles for correct arc direction
	if isLeft then
		-- counter-clockwise arc
		if endAngle < startAngle then
			endAngle = endAngle + 2 * math.pi
		end
	else
		-- clockwise arc
		if startAngle < endAngle then
			startAngle = startAngle + 2 * math.pi
		end
	end

	-- calculate arc length
	local deltaAngle = endAngle - startAngle
	local arcLength = math.abs(deltaAngle) * r

	local arc = {
		type = "arc",
		arc = {
			x = cx,
			y = cy,
			radius = r,
			angle1 = startAngle,
			angle2 = endAngle,
			length = arcLength,
			direction = isLeft and "counter-clockwise" or "clockwise"
		},
		fromPoint = {x = pointP.x, y = pointP.y},
		toPoint = {x = pointQ.x, y = pointQ.y}
	}

	return arc
end

-- extend path from current circle to goal or other circles
local function extendPath(currentPath, minLength, currentCircle, isCurrentRight, goalNode, circles, queue, visited)
	local lastSegment = currentPath[#currentPath]
	local pointP = lastSegment.toPoint
	local isLeft = not isCurrentRight
	local initialQueueSize = #queue

	-- path to goal
	local pointQ = calculateRightTangentPoint(goalNode.point, currentCircle, isCurrentRight)
	if pointQ then
		local line = {pointQ.x, pointQ.y, goalNode.point.x, goalNode.point.y}
		table.insert(globalTangentLines, line)
		local goalSegment = {
			fromCircle = currentCircle,
			to = goalNode,
			id = (isCurrentRight and 'PR' or 'PL') .. currentCircle.id .. '-goal',
			type = 'tangent',
			line = line,
			length = distance(pointQ, goalNode.point),
			fromPoint = pointQ,
			toPoint = goalNode.point,
			isEndRight = isCurrentRight
		}
		if not anyLineCircleIntersection(goalSegment.line, circles, currentCircle) then
			local arcSegment = createArcSegment(currentCircle, pointP, pointQ, isLeft)
			if arcSegment and not arcIntersectsCircle(currentCircle, pointP, pointQ, circles) then
				local newPath = {unpack(currentPath)}
				table.insert(newPath, arcSegment)
				table.insert(newPath, goalSegment)
				local totalLength = minLength + arcSegment.arc.length + goalSegment.length
				table.insert(queue, {
						path = newPath,
						totalLength = totalLength,
						endCircle = nil,
						isEndRight = nil
					})
				print('added segment: ', goalSegment.id)
				print('found goal! #newPath', #newPath, 'segment: ', goalSegment.id)
			end
		end
	end

	-- paths to other circles
	for _, nextCircle in ipairs(circles) do
		if nextCircle ~= currentCircle then
			for _, nextIsRight in ipairs({true, false}) do
				local pointQ, pointPNext = calculateCircleCircleTangentLine(currentCircle, nextCircle, isLeft, not nextIsRight)
				if pointQ and pointPNext then
					local line = {pointQ.x, pointQ.y, pointPNext.x, pointPNext.y}
					table.insert(globalTangentLines, line)
					local nextCircleNode = {
						circle = nextCircle,
						isRight = nextIsRight,
						id = (nextIsRight and 'PR' or 'PL') .. nextCircle.id
					}
					local segment = {
						fromCircle = currentCircle,
						to = nextCircleNode,
						id = (isCurrentRight and 'PR' or 'PL') .. currentCircle.id .. '-' .. nextCircleNode.id,
						type = 'tangent',
						line = line,
						length = distance(pointQ, pointPNext),
						fromPoint = pointQ,
						toPoint = pointPNext,
						isEndRight = nextIsRight
					}
					if not anyLineCircleIntersection(segment.line, circles, nextCircle) then
						local arcSegment = createArcSegment(currentCircle, pointP, pointQ, isLeft)
						if arcSegment and not arcIntersectsCircle(currentCircle, pointP, pointQ, circles) then
							local newPath = {unpack(currentPath)}
							table.insert(newPath, arcSegment)
							table.insert(newPath, segment)
							local totalLength = minLength + arcSegment.arc.length + segment.length
							local visitedKey = nextCircle.id .. (nextIsRight and '-PR' or '-PL')
							if not visited[visitedKey] then
								table.insert(queue, {
										path = newPath,
										totalLength = totalLength,
										endCircle = nextCircle,
										isEndRight = nextIsRight
									})
								visited[visitedKey] = true
								print('added segment: ', segment.id)
							end
						end
					end
				end
			end
		end
	end
	print('created ' .. (#queue - initialQueueSize) .. ' new paths from ', (isCurrentRight and 'PR' or 'PL') .. currentCircle.id)
end

-- dynamically build path graph and return shortest path
local function buildGraph(startPoint, goalPoint, circles)
	globalTangentLines = {}
	local startId = "start"
	local startNode = {
		point = startPoint,
		id = startId
	}
	local goalId = "goal"
	local goalNode = {
		point = goalPoint,
		id = goalId
	}

	-- table to track visited circle and direction combinations
	local visited = {}

	-- simple direct path from start to goal
	local simplePath = {
		from = startNode,
		to = goalNode,
		id = startId .. '-goal',
		type = 'tangent',
		line = {startPoint.x, startPoint.y, goalPoint.x, goalPoint.y},
		length = distance(startPoint, goalPoint),
		fromPoint = startPoint,
		toPoint = goalPoint
	}

	if not anyLineCircleIntersection(simplePath.line, circles) then
		return {simplePath}
	end

	local queue = {}
	-- first iteration: paths from start to right and left tangents of circles
	for id, circle in ipairs(circles) do
		circle.id = id
		for _, isRight in ipairs({true, false}) do
			local tangentP = calculateRightTangentPoint(startPoint, circle, not isRight)
			if tangentP then
				local line = {startPoint.x, startPoint.y, tangentP.x, tangentP.y}
				table.insert(globalTangentLines, line)
				local circleNode = {
					circle = circle,
					isRight = isRight,
					id = (isRight and 'PR' or 'PL') .. circle.id
				}
				local segment = {
					from = startNode,
					to = circleNode,
					id = startId .. '-' .. circleNode.id,
					type = 'tangent',
					line = line,
					length = distance(startPoint, tangentP),
					fromPoint = startPoint,
					toPoint = tangentP,
					isEndRight = isRight
				}
				if not anyLineCircleIntersection(segment.line, circles, circle) then
					local visitedKey = circle.id .. (isRight and '-PR' or '-PL')
					table.insert(queue, {
							path = {segment},
							totalLength = segment.length,
							endCircle = circle,
							isEndRight = isRight
						})
					visited[visitedKey] = true
					print('added start segment: ', segment.id)
				end
			end
		end
	end
	print('created ' .. #queue .. ' tangents from start')

	local bestPath = nil
	local iteration = 0
	while #queue > 0 do
		iteration = iteration + 1
		print('iteration ' .. iteration .. ':')
		local minIndex, minLength = 1, queue[1].totalLength
		for i = 2, #queue do
			if queue[i].totalLength < minLength then
				minIndex, minLength = i, queue[i].totalLength
			end
		end

		local currentElement = table.remove(queue, minIndex)
		local currentPath = currentElement.path
		local lastSegment = currentPath[#currentPath]
		local currentNode = lastSegment.to

		if currentNode.id == goalId then
			bestPath = currentPath
			break
		end

		extendPath(currentPath, minLength, currentNode.circle, currentNode.isRight, goalNode, circles, queue, visited)
	end

	return bestPath
end

-- initialize game state
function love.load()
	-- fixed circles for testing
	circles = {
		{
			x = 200,
			y = 300,
			radius = 100
		},
		{
			x = 500,
			y = 350,
			radius = 100
		},
	}

	startPoint = {x = 100, y = 100}
	goalPoint = {x = 700, y = 500}

	shortestPath = buildGraph (startPoint, goalPoint, circles)
end

-- update goal point on mouse movement
function love.mousemoved(x, y)
	goalPoint.x = x
	goalPoint.y = y
	 shortestPath = buildGraph (startPoint, goalPoint, circles)
end

-- draw game elements
function love.draw()
	love.graphics.setLineWidth(1)

	-- draw all tangent lines
	love.graphics.setColor(1, 1, 1)
	for _, line in ipairs (globalTangentLines) do
		love.graphics.line(line)
	end

	love.graphics.setLineWidth(2)

	-- draw circles
	love.graphics.setColor(1, 1, 1)
	for _, c in ipairs(circles) do
		love.graphics.circle('line', c.x, c.y, c.radius)
	end

	-- draw start and goal points
	love.graphics.setPointSize(8)
	love.graphics.setColor(1, 0, 0)
	love.graphics.points(startPoint.x, startPoint.y)
	love.graphics.points(goalPoint.x, goalPoint.y)

	-- draw shortest path
	love.graphics.setColor(0, 1, 0)
	if shortestPath and #shortestPath > 0 then
		for _, segment in ipairs(shortestPath) do
			if segment.line then
				love.graphics.line(segment.line)
			elseif segment.arc then
				local arc = segment.arc
				love.graphics.arc('line', 'open', arc.x, arc.y,
					arc.radius, arc.angle1, arc.angle2)
			end
		end
	end
end