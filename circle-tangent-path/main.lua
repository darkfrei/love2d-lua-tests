-- main.lua for love2d

-- calculate distance between two points
local function distance(point1, point2)
	local dx = point2.x - point1.x
	local dy = point2.y - point1.y
	return math.sqrt(dx*dx + dy*dy)
end



-------------------------------------------------------------------------------------------


local function isLineCircleIntersection(line, circle)
	local x1, y1, x2, y2 = line[1], line[2], line[3], line[4] -- two points of line
	local cx, cy, r = circle.x, circle.y, circle.radius -- circle parameters
	local dx, dy = x2 - x1, y2 - y1
	local fx, fy = cx - x1, cy - y1

	local lengthSquared = dx*dx + dy*dy
	if lengthSquared == 0 then
		local distSq = (x1 - cx)^2 + (y1 - cy)^2
		return distSq <= r * r
	end

	local t = (fx * dx + fy * dy) / lengthSquared
	t = math.max(0, math.min(1, t)) -- clamp t to [0, 1]

	local distSq = (x1 + t * dx - cx)^2 + (y1 + t * dy - cy)^2
	return distSq <= r * r
end


-- checks if line intersects any circle except optional excluded one
local function anyLineCircleIntersection(line, circles, exceptCircle, exceptCircle2)
--	print ('line', line[1], line[2], line[3], line[4])

	for i, circle in ipairs(circles) do
--		print ('circle'..circle.id, circle.x, circle.y, circle.radius)
		-- skip excluded circle if specified
		if (exceptCircle and circle == exceptCircle) then
--			print ('circle exception', exceptCircle.id)
		elseif (exceptCircle2 and circle == exceptCircle2) then
--			print ('circle exception 2', exceptCircle2.id)
		elseif isLineCircleIntersection(line, circle) then
--			print ('found collision')
			return true  -- true: intersection found
		else 

--			print ('no collision with circle '.. circle.id)
		end
	end
--	print ('anyLineCircleIntersection:', 'collision not found')
	return false  -- false: no intersections found
end



-- calculate right tangent from point to circle
local function calculatePointToCircleTangent(point, circle, isRight)
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
	local sign = isRight and 1 or -1

	local p = {
		x = circle.x + a*dx + b*dy*sign, 
		y = circle.y + a*dy - b*dx*sign
	}

	return p
end

---- check if segment intersects a circle
--local function segmentCircleIntersection(segment, circle)
--	local line = segment.line
--	local x1, y1 = line[1], line[2]
--	local x2, y2 = line[3], line[4]
--	local cx, cy, cr = circle.x, circle.y, circle.radius
--	local dx, dy = x2 - x1, y2 - y1
--	local dx2, dy2 = cx - x1, cy - y1

--	local a = dx*dx + dy*dy
--	local b = 2*(dx*(x1 - cx) + dy*(y1 - cy))
--	local c = dx2^2 + dy2^2 - cr^2
--	local discriminant = b*b - 4*a*c

--	if discriminant < 0 then return false end

--	local t1 = (-b - math.sqrt(discriminant))/(2*a)
--	local t2 = (-b + math.sqrt(discriminant))/(2*a)

--	return (t1 >= 0 and t1 <= 1) or (t2 >= 0 and t2 <= 1)
--end




---- check if line intersects any circle except specified
--local function anySegmentCircleIntersection(segment, circles, exceptCircle)
----	local line = segment.line
--	local segmentId = segment.id
----	local x1, y1, x2, y2 = line[1], line[2], line[3], line[4]
--	for i, circle in ipairs (circles) do
--		if exceptCircle and circle == exceptCircle then
--			-- skip
--		else
----			local cx, cy, cr = circle.x, circle.y, circle.radius
--			local circleId = circle.id
--			if segmentCircleIntersection(segment, circle) then
----				print ('circle id: '.. circleId .. ' on the way  of segment: '.. segmentId )
--				return true
--			end
--		end
--	end
----	print ('anySegmentCircleIntersection', segment.id .. ' has no collisions')
--	return false
--end

---- check if arc on current circle from current point to next point intersects other circles
--local function arcIntersectsCircle(currentCircle, currentPoint, nextRightTangent, circles)
--	-- calculate angles for current point and next point relative to circle center
--	local cx, cy = currentCircle.x, currentCircle.y
--	local startAngle = math.atan2(currentPoint.y - cy, currentPoint.x - cx)
--	local endAngle = math.atan2(nextRightTangent.y - cy, nextRightTangent.x - cx)

--	-- determine shortest arc (clockwise or counter-clockwise)
--	local deltaAngle = endAngle - startAngle
--	if deltaAngle > math.pi then
--		deltaAngle = deltaAngle - 2 * math.pi
--	elseif deltaAngle < -math.pi then
--		deltaAngle = deltaAngle + 2 * math.pi
--	end

--	local isClockwise = deltaAngle < 0
--	local absDeltaAngle = math.abs(deltaAngle)
--	local start, finish = startAngle, endAngle
--	if isClockwise then
--		start, finish = endAngle, startAngle
--	end

--	-- check each other circle
--	for _, otherCircle in ipairs(circles) do
--		if otherCircle ~= currentCircle then
--			local ox, oy = otherCircle.x, otherCircle.y
--			local r1, r2 = currentCircle.radius, otherCircle.radius

--			-- distance between circle centers
--			local dist = math.sqrt((ox - cx)^2 + (oy - cy)^2)

--			-- skip if centers are too far for intersection
--			if dist > r1 + r2 then
--				goto continue
--			end

--			-- angle from current circle center to other circle center
--			local centerAngle = math.atan2(oy - cy, ox - cx)

--			-- normalize angle relative to start angle
--			local relAngle = centerAngle - start
--			if relAngle > math.pi then
--				relAngle = relAngle - 2 * math.pi
--			elseif relAngle < -math.pi then
--				relAngle = relAngle + 2 * math.pi
--			end

--			-- check if other circle center lies within arc sector
--			if isClockwise then
--				if relAngle >= -absDeltaAngle and relAngle <= 0 then
--					-- check if center is close enough for intersection
--					if dist <= r1 + r2 then
--						return true
--					end
--				end
--			else
--				if relAngle >= 0 and relAngle <= absDeltaAngle then
--					if dist <= r1 + r2 then
--						return true
--					end
--				end
--			end
--		end
--		::continue::
--	end

--	return false
--end

-- calculate external tangent line between two circles (right-to-right or other combinations)

local function calculateCircleCircleTangentLine(fromCircle, fromRight, toCircle, toRight)
	local x1, y1, r1 = fromCircle.x, fromCircle.y, fromCircle.radius
	local x2, y2, r2 = toCircle.x, toCircle.y, toCircle.radius

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
	local r1_sign = fromRight and 1 or -1
	local r2_sign = toRight and 1 or -1
	local r1_adj = -r1 * r1_sign
	local r2_adj = -r2 * r2_sign

	-- calculate tangent angle
	local theta = math.asin((r1_adj - r2_adj) / dist)
	local alpha = math.atan2(dy, dx)

	-- angle for tangent point on first circle
	local angle1 = alpha + theta + (fromRight and math.pi/2 or -math.pi/2)
	local angle2 = alpha + theta + (toRight and math.pi/2 or -math.pi/2)

	-- tangent points Q (on current circle) and P (on next circle)
	local q = {
		x = x1 + r1 * math.cos(angle1),
		y = y1 + r1 * math.sin(angle1)
	}
	local p = {
		x = x2 + r2 * math.cos(angle2),
		y = y2 + r2 * math.sin(angle2)
	}

	return q, p
end


--local function isOnCircle(point, circle)
--	local cx, cy, r = circle.x, circle.y, circle.radius
--	local dx = point.x - cx
--	local dy = point.y - cy
--	return math.abs(dx*dx + dy*dy - r*r) < 1e-6
--end

-- create arc segment on circle between two tangent points
-- parameters:
--   currentCircle - circle {x, y, radius}
--   pointP - start tangent point {x, y}
--   pointQ - end tangent point {x, y}
--   isLeft - arc direction (true for counter-clockwise, false for clockwise)
-- returns:
--   table with arc data or nil if points are not on circle
--local function createArcSegment(currentCircle, pointP, pointQ, isLeft)
--	local cx, cy, r = currentCircle.x, currentCircle.y, currentCircle.radius

--	-- check if points lie on circle (with 1e-6 tolerance)
--	-- if not (isOnCircle(pointP, currentCircle) and isOnCircle(pointQ, currentCircle)) then
--	-- 	return nil -- one of the points is not on circle
--	-- end

--	-- calculate angles for points P and Q
--	local startAngle = math.atan2(pointP.y - cy, pointP.x - cx)
--	local endAngle = math.atan2(pointQ.y - cy, pointQ.x - cx)

--	-- adjust angles for correct arc direction
--	if isLeft then
--		-- counter-clockwise arc
--		if endAngle < startAngle then
--			endAngle = endAngle + 2 * math.pi
--		end
--	else
--		-- clockwise arc
--		if startAngle < endAngle then
--			startAngle = startAngle + 2 * math.pi
--		end
--	end

--	-- calculate arc length
--	local deltaAngle = endAngle - startAngle
--	local arcLength = math.abs(deltaAngle) * r

--	local arc = {
--		type = "arc",
--		arc = {
--			x = cx,
--			y = cy,
--			radius = r,
--			angle1 = startAngle,
--			angle2 = endAngle,
--			length = arcLength,
--			direction = isLeft and "counter-clockwise" or "clockwise"
--		},
--		fromPoint = {x = pointP.x, y = pointP.y},
--		toPoint = {x = pointQ.x, y = pointQ.y}
--	}

--	return arc
--end


local function newPointNode (point, id)
	local pointNode = {
		x = point.x, y = point.y,
--		point = point, 
		id = id}
	return pointNode
end


local function isPointInAnyCircle(point, circles)
	for _, circle in ipairs(circles) do
		if distance (point, circle) < circle.radius then
			return true  -- true: point inside this circle
		end
	end
	return false  -- false: point not inside any circle
end


local function newLine (p1, p2)
	local line = {p1.x, p1.y, p2.x, p2.y}
	return line
end

local function getSimpleSolution (startNode, goalNode, circles)
	local line = newLine (startNode, goalNode)

	local simplePath = {
		fromNode = startNode,
		toNode = goalNode,
		id = startNode.id .. '-' .. goalNode.id,
		line = line,
		length = distance(startNode, goalNode),
	}
--	print ('simplePath id: '..simplePath.id)

--	if not anySegmentCircleIntersection(simplePath, circles) then
	local isCollision = anyLineCircleIntersection(line, circles)
	table.insert (globalTangentLines, line)
	if not isCollision then

		return {simplePath}
	elseif isPointInAnyCircle(startNode, circles) then
		return {simplePath}
	elseif isPointInAnyCircle(goalNode, circles) then
		return {simplePath}
	end
	return nil
end



local function newArc(circle, pointP, pointQ, fromRight)
	-- calculate angles
	local angle1 = math.atan2(pointP.y - circle.y, pointP.x - circle.x)
	local angle2 = math.atan2(pointQ.y - circle.y, pointQ.x - circle.x)

	-- adjust angles for direction
	if fromRight then
		if angle1 < angle2 then
			angle1 = angle1 + 2 * math.pi
		end
	else
		if angle2 < angle1 then
			angle2 = angle2 + 2 * math.pi
		end
	end

	-- calculate arc length
	local deltaAngle = math.abs(angle2 - angle1)
	local length = deltaAngle * circle.radius

	return {
		x = circle.x,
		y = circle.y,
		radius = circle.radius,
		angle1 = angle1,
		angle2 = angle2,
		length = length,
	}
end

--local function calculateCircleToCircleTangent(fromCircle, fromRight, toCircle, toRight)
--	if fromCircle == toCircle then 
--		print ('same circle!', fromCircle.id)
--		return nil 
--	end
--	-- calculate vector between centers
--	local dx = toCircle.x - fromCircle.x
--	local dy = toCircle.y - fromCircle.y
--	local distSq = dx * dx + dy * dy
--	local dist = math.sqrt(distSq)

--	-- handle edge cases
--	local r1, r2 = fromCircle.radius, toCircle.radius
--	local radiusDiff = math.abs(r1 - r2)
--	if dist <= radiusDiff then
----		print ('dist: '..dist, 'radiusDiff: '..radiusDiff)
--		return nil  -- one circle completely inside another
--	end

--	-- determine tangent type and parameters
--	local isOuter = (fromRight == toRight)
--	local angle = math.atan2(dy, dx)
--	local r2Sign = isOuter and 1 or -1
--	local combinedRadius = r1 + r2Sign * r2

--	-- check if tangent exists
--	if isOuter and dist < combinedRadius then
----		print ('tangent not exists')
--		return nil  -- circles too close for outer tangent
--	end

--	-- calculate tangent angle
--	local phi = math.acos(combinedRadius / dist)
--	if not phi then return nil end  -- invalid math domain

--	-- determine angle adjustment based on direction
--	local directionSign = (fromRight and 1 or -1) * (isOuter and -1 or 1)
--	local tangentAngle = angle + directionSign * phi

--	-- compute and return tangent points
--	local q = {  -- point on source circle
--		x = fromCircle.x + r1 * math.cos(tangentAngle),
--		y = fromCircle.y + r1 * math.sin(tangentAngle)
--	}
--	local p = {  -- point on target circle
--		x = toCircle.x + r2Sign * r2 * math.cos(tangentAngle),
--		y = toCircle.y + r2Sign * r2 * math.sin(tangentAngle)
--	}
--	return q, p
--end

local function getStartQueue (startNode, circles)
	local queue = {}
	local startId = startNode.id
	local trueFalseArray = {true, false}
	-- first iteration: paths from start to right and left tangents of circles
	for id, toCircle in ipairs(circles) do
		for _, isRight in ipairs(trueFalseArray) do
			local edgeId = startNode.id .. '-' .. (isRight and 'R' or 'L') .. toCircle.id

			local tangentP = calculatePointToCircleTangent (startNode, toCircle, isRight)
			local line = newLine (startNode, tangentP)
			local isCollision = anyLineCircleIntersection(line, circles, toCircle)


			if not isCollision then
				local segment = {line = line, arc = nil, id = edgeId}
				local path = {segment}
				local totalLength = distance(startNode, tangentP)
				local edge = {
					id = edgeId,
					fromNode = startNode,
					toNode = toCircle,
					isRight = isRight,
					path = path,
					totalLength = totalLength,
					pointP = tangentP
				}
				table.insert(queue, edge)
--				print ('created start edge:', edgeId, totalLength)
				table.insert (globalTangentLines, line)
			end
		end
	end
--	print('created ' .. #queue .. ' tangents from start')
	local str = ''
	for i, edge in ipairs (queue) do
		str = str .. edge.id ..', '
	end
--	print(str .. '\n')
	return queue
end


-- dynamically build path graph and return shortest path
local function getShortestPath(startPoint, goalPoint, circles)
	globalTangentLines = {} -- just test lines
	local startNode = newPointNode (startPoint, "start")
	local goalNode = newPointNode (goalPoint, "goal")
	for id, circle in ipairs (circles) do
		circle.id = id
	end
	local simplePath = getSimpleSolution (startNode, goalNode, circles)
	if simplePath then return simplePath end

	local queue = getStartQueue (startNode, circles)

	local bestPath = nil
	local iteration = 0
	local trueFalseArray = {true, false}

	local edgeHash = {}
	local shortestLength = math.huge

	while #queue > 0 do
		iteration = iteration + 1
--		print('\niteration ' .. iteration .. ':')

		local minIndex, minLength = 1, queue[1].totalLength
--		print ('minLength:', minLength)
		for i = 2, #queue do
--			print ('queue:', i, queue[i].totalLength)
			if queue[i].totalLength < minLength then
				minIndex, minLength = i, queue[i].totalLength
			end
		end
		local edge = table.remove(queue, minIndex)
--		print ('currend edge: '.. edge.id, 'totalLength: '..edge.totalLength)

		local toNode = edge.toNode
		if toNode == goalNode then
			-- toNode is goal
			local length = edge.totalLength
			if length < shortestLength then
				shortestLength = length
				bestPath = edge.path
--				print ('found shortest path', edge.id, edge.totalLength)
			end
		else

			-------------- to goal
			local fromCircle = edge.toNode
			local fromRight = edge.isRight


			local tangentQ = calculatePointToCircleTangent (goalNode, fromCircle, not fromRight)
			if edge.pointP and tangentQ then
				local goalLine = newLine (tangentQ, goalNode)
				local isCollision = anyLineCircleIntersection(goalLine, circles, fromCircle)

				if not isCollision then
					local edgeId = (fromRight and 'R' or 'L') .. fromCircle.id .. '-' .. goalNode.id
--			love.graphics.arc('line', 'open', arc.x, arc.y, arc.radius, arc.angle1, arc.angle2)
					if not edgeHash[edgeId] then
						edgeHash[edgeId] = true
						local pointP = edge.pointP
						local arc = newArc (fromCircle, pointP, tangentQ, fromRight)
						local segment = {line = goalLine, arc = arc, id = edgeId}
						local path = {unpack(edge.path)}
						table.insert (path, segment)
						local lineLength = distance(tangentQ, goalNode)

						local arcLength = arc.length
						local totalLength = edge.totalLength + lineLength + arcLength
						local edge = {
							id = edgeId,
							fromNode = fromCircle,
							toNode = goalNode,
--					isRight = isRight,
							path = path,
							totalLength = totalLength,
						}
						table.insert(queue, edge)
--						print ('created goal edge:', edgeId, totalLength)
						table.insert (globalTangentLines, goalLine)
					end
				end
			end

			-------------- to other circles

			fromCircle = edge.toNode
			fromRight = edge.isRight
--			print ('adding circle to circle:')

			for _, toCircle in ipairs (circles) do
				for _, toRight in ipairs (trueFalseArray) do
					local tangentQ, tangentP = calculateCircleCircleTangentLine (fromCircle, fromRight, toCircle, toRight)
--					if edge.pointP and tangentQ and tangentP then
					if tangentQ then
						local line = newLine (tangentQ, tangentP)
						local isCollision = anyLineCircleIntersection(line, circles, fromCircle, toCircle)
						if not isCollision then
							local edgeId = (fromRight and 'R' or 'L') .. fromCircle.id .. '-' .. (toRight and 'R' or 'L') .. toCircle.id
							if not edgeHash[edgeId] then
								edgeHash[edgeId] = true

--								print ('adding edge: '.. edgeId)
								local pointP = edge.pointP
								local arc = newArc (fromCircle, pointP, tangentQ, fromRight) -- old point P
								local segment = {line = line, arc = arc, id = edgeId}
								local path = {unpack(edge.path)}
								table.insert (path, segment)
								local lineLength = distance(tangentQ, tangentP)
								local arcLength = arc.length
								local totalLength = edge.totalLength + arcLength + lineLength
--								print ('edge '.. edgeId)
--								print ('totalLength = ' .. edge.totalLength..'+'.. arcLength .. '+'..lineLength..' = ' ..totalLength)

								local edge = {
									id = edgeId,
									fromNode = fromCircle,
									toNode = toCircle,
									isRight = toRight,
									path = path,
									totalLength = totalLength,
									pointP = tangentP
								}
								table.insert(queue, edge)
--								print ('created circle-circle edge:', edgeId, totalLength)
								table.insert (globalTangentLines, line)
							end
						end
					end
				end
			end
		end

	end

	return bestPath
end

-- initialize game state
function love.load()
	-- fixed circles for testing
	circles = {
		{
			x = 200,
			y = 250,
			radius = 100
		},
		{
			x = 500,
			y = 250,
			radius = 100
		},
	}

	startPoint = {x = 100, y = 100}
	goalPoint = {x = 700, y = 500}

	shortestPath = getShortestPath (startPoint, goalPoint, circles)
end

-- update goal point on mouse movement
function love.mousemoved(x, y)
	goalPoint.x = x
	goalPoint.y = y
	shortestPath = getShortestPath (startPoint, goalPoint, circles)
end

-- draw game elements
function love.draw()
	love.graphics.setLineWidth(1)

	-- draw all tangent lines
	love.graphics.setColor(1, 1, 1, 0.2)
	for _, line in ipairs (globalTangentLines) do
		love.graphics.line(line)
	end

	love.graphics.setLineWidth(2)

	-- draw circles
	love.graphics.setColor(1, 1, 1)
	for _, c in ipairs(circles) do
		love.graphics.circle('line', c.x, c.y, c.radius)
		love.graphics.circle('fill', c.x, c.y, 1)
		love.graphics.print(c.id, c.x, c.y)
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
			local arc = segment.arc
			if arc then
				love.graphics.arc('line', 'open', arc.x, arc.y, arc.radius, arc.angle1, arc.angle2)
			end

			love.graphics.line(segment.line)
		end
	end
end