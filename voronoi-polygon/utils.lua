-- voronoi for closed polygon
print ('loaded', ...)

local utils = {}

utils.tiny = 0.0001

local pointIndex = 0

function utils.newPoint (x, y, fixed)
	pointIndex = pointIndex + 1
	local newPoint = {x=x, y=y, fixed=fixed, index = pointIndex}
	return newPoint
end

function utils.clockwiseSort(polygon)
	local centroidX = 0
	local centroidY = 0
	local numVertices = #polygon

	for _, vertex in ipairs(polygon) do
		centroidX = centroidX+vertex.x
		centroidY = centroidY+vertex.y
	end

	centroidX = centroidX / numVertices
	centroidY = centroidY / numVertices

	local function angularSort (v1, v2)
		local angle1 = math.atan2(v1.y - centroidY, v1.x - centroidX)
		local angle2 = math.atan2(v2.y - centroidY, v2.x - centroidX)
--		print ('angles', angle1, angle2)
		return angle1 < angle2  -- For clockwise order, use '<' instead of '>'
	end

	table.sort(polygon, angularSort)

	print ('sorted polygon:')
	for i, v in ipairs (polygon) do
		print (i, v.x, v.y, math.atan2(v.y - centroidY, v.x - centroidX))
	end

	return polygon
end



function utils.newPolygon (flatPolygon)
	local polygon = {}
	for i = 1, #flatPolygon, 2 do
		local newPoint = utils.newPoint (flatPolygon[i], flatPolygon[i+1], true)
		table.insert(polygon, newPoint)
	end

	return utils.clockwiseSort(polygon)
end

function utils.YX_Sort(sites)
	local function firstYThenXsort (v1, v2)
		if v1.y == v2.y then
			return v1.x < v2.x
		else
			return v1.y < v2.y
		end
	end

--	for i, site in ipairs (sites) do
--		print ('site '..i, site.x, site.y)
--	end

	table.sort(sites, firstYThenXsort)

--	print ('after:')
--	for i, site in ipairs (sites) do
--		print ('site '..i, site.x, site.y)
--	end

	return sites
end

local function newCell (diagram, site)
	local cell = {
		site = site,
		vertices = {},
		edges = {},
		neighbourCells = {},
	}
	site.cell = cell
	table.insert (diagram.cells, cell)
	print ('created cell', #diagram.cells)
	return cell
end

function utils.newSites (flatSites)
	local sites = {}
	for i = 1, #flatSites, 2 do
		local site = utils.newPoint (flatSites[i], flatSites[i+1], true)
		table.insert(sites, site)
	end
	return utils.YX_Sort(sites)
end

function utils.newCells (sites)
	local cells = {}
	for i, site in ipairs (sites) do
		local cell = {
			site=site,
			vertices = {}, 
			edges = {}, 
			neighbourCells = {},
		}
		site.cell = cell
		table.insert(cells, cell)
	end

	return cells
end

local function listToFlat (list)
	local flat = {}
	for i, v in ipairs (list) do
		table.insert (flat, v.x)
		table.insert (flat, v.y)
	end
	return flat
end

local function newLineSegment (p1, p2)
	local k = (p2.y-p1.y) / (p2.x-p1.x) -- calculate the slope
	local m = p1.y - k * p1.x -- calculate the y-intercept
	local segment = {
		left = p1,  
		right = p2,
		type = 'line',
		k = k,
		m = m,
		isVertical = (p1.x == p2.x),
	}
	return segment
end

local function newParabolaSegment (p1, p2, site)
	local segment = {
		left = p1,
		right = p2,
		type = 'parabola',
		site = site
	}
	return segment
end

local function copySegment (segment)
	local newSegment = {}
	for i, v in pairs (segment) do
		newSegment[i] = v
	end
	return newSegment
end

function utils.newBeachLine(diagram)
	local polygon = diagram.polygon
	local vertices = {}

	local upperBoundary = {}
	local upperBoundaryFlat = {}
	local prevVertex = polygon[#polygon]  -- Start with the last vertex
	local first = true



	for i = 1, #polygon do
		local currentVertex = polygon[i]

		print(i, 'currentVertex.x > prevVertex.x', tostring(currentVertex.x), tostring(prevVertex.x))

		if currentVertex.x > prevVertex.x then

			if first then
				print ('adding both')
				first = false
				table.insert(upperBoundary, prevVertex)  -- Add the last vertex first if needed
				table.insert(upperBoundary, currentVertex)  -- Add the current vertex
			else
				print ('adding next')
				table.insert(upperBoundary, currentVertex)
			end
--			table.insert(upperBoundary, currentVertex)  -- Add the current vertex
		elseif not first then
			print ('it was last')
			break  -- Stop collecting points after the first downward slope
		end

		prevVertex = currentVertex  -- Update prevVertex for next iteration
	end

	upperBoundaryFlat = listToFlat (upperBoundary)

	print (table.concat(upperBoundaryFlat, ','))

	diagram.upperBoundary = upperBoundary

	local beachLine = {}

	print ('#upperBoundary', #upperBoundary)
	for i = 1, #upperBoundary-1 do
		local segment = newLineSegment (upperBoundary[i], upperBoundary[i+1])
		table.insert (beachLine, segment)
		print (i, 'new line segment', segment.left.x, segment.right.x)
	end

	return beachLine
end

function utils.sortQueue (eventQueue)
	-- low yEvent is first
	table.sort(eventQueue, function(event1, event2)
			return event1.yEvent < event2.yEvent
		end)
	print ('eventQueue was sorted:')
	for i, event in ipairs (eventQueue) do
		print (i, event.yEvent)
	end
	return eventQueue
end



local function evaluateParabolaYbyX (x, focus, dirY)
	local fx, fy = focus.x, focus.y

	local denom = 2 * (fy - dirY)

	if denom == 0 then
		error ('division by 0 exception')
	end

--	local y = 0.5*(x-fx)*(x-fx)/(fy-dirY)+fy - 0.5* (fy-dirY)
	local y = (x - fx) * (x - fx) / denom+(fy+dirY) / 2
--	local y = (x - fx) * (x - fx) / denom+fy - denom / 4

	return y
end

local function findParabolaParabolaIntersection(site1, site2, yEvent)
	local fx1, fy1 = site1.x, site1.y
	local fx2, fy2 = site2.x, site2.y
	if fy1 == yEvent and fy2 == yEvent then
		-- y is not defined
		local x = (fx1+fx2)/2
		-- the situation is impossible:
		error ('two parabolas on same yEvent')
		return x, nil
	elseif fy1 == yEvent or fy2 == yEvent then
		if fy1 == yEvent then
			local x = fx1
			local y = evaluateParabolaYbyX (x, site2, yEvent)
			return x, y
		else
			local x = fx2
			local y = evaluateParabolaYbyX(x, site1, yEvent)
			return x, y
		end
	elseif (fy1 == fy2) then
		local x = (fx1+fx2)/2
		local y = evaluateParabolaYbyX (x, site1, yEvent)
		return x, y
	else -- common case two parabolas crossing:
		-- must be tested:
		local a1 =  1 / (2 * (fy1 - yEvent))
		local a2 =  1 / (2 * (fy2 - yEvent))
		local x = (fx1 * a2 - fx2 * a1) / (a2 - a1)
		local y = evaluateParabolaYbyX (x, site1, yEvent)
		return x, y
	end
end

local function getParabolaToInclinedLineIntersections (fx, fy, k, m, dirY)
--	https://www.desmos.com/calculator/pswcxyvq1i
	-- fx, fy - focus
	-- dirY - direcrix Y
	-- k, m - factors for inclined line: y = kx+m

	local p = (fy-dirY)/2

	local a = 1 / (4*p)
	local b = -2*a*fx
	local c = a*fx*fx+fy-p

	-- graph y = a*x^2+(b-k)*x+(c-m)

	local dx = (b-k)*(b-k)-4*a*(c-m)
	if dx < 0 then
		error ('discriminant is less than 0')
	end
	dx = dx^0.5
	-- left:
	local x1 = (-(b-k)-dx)/(2*a)
	local y1 = k*x1+m
	-- right: 
	local x2 = (-(b-k)+dx)/(2*a)
	local y2 = k*x2+m
	return x1, y1, x2, y2
end

local function findLineParabolaIntersection(segment, site, dirY)
	local fx, fy = site.x, site.y
	local k, m = segment.k, segment.m
	local x1, y1, x2, y2 = getParabolaToInclinedLineIntersections (fx, fy, k, m, dirY)
	-- get left point of parabola
	print ('findLineParabolaIntersection', x1, y1, x2, y2)
	return x2, y2
end


local function findParabolaLineIntersection(site, segment, dirY)
	local fx, fy = site.x, site.y
	local k, m = segment.k, segment.m
	local x1, y1, x2, y2 = getParabolaToInclinedLineIntersections (fx, fy, k, m, dirY)
	-- get right point of parabola
	print ('findParabolaLineIntersection', x1, y1, x2, y2)
	return x1, y1
end


local function updateConjugationPoint (diagram, segment1, segment2, yEvent)
	-- updating conjugation points in the beachline
	if segment1.type == 'line' and segment2.type == 'line' then
		-- segment1.right is same object as segment2.left
		return
	end

	if segment1.type == 'parabola' and segment2.type == 'parabola' then
		local site1 = segment1.site
		local site2 = segment2.site
		local x, y = findParabolaParabolaIntersection(site1, site2, yEvent)
		segment1.right.x = x
		segment1.right.y = y
		-- segment1.right is same object as segment1.left
		return
	end

	if segment1.type == 'line' and segment2.type == 'parabola' then
		local site2 = segment2.site
		local x, y = findLineParabolaIntersection(segment1, site2, yEvent)
		segment1.right.x = x
		segment1.right.y = y
		-- segment1.right is same object as segment1.left

	elseif segment1.type == 'parabola' and segment2.type == 'line' then
		local site1 = segment1.site
		local x, y = findParabolaLineIntersection(site1, segment2, yEvent)
		segment1.right.x = x
		segment1.right.y = y
		-- segment1.right is same object as segment1.left
	else
		error ('not defined type:', tostring (segment1.type), tostring (segment2.type))
	end
end

local function getBezierControlPoint (fx, fy, ax, bx, dirY)
	local f = function (x)
		return (x*x-2*fx*x+fx*fx+fy*fy-dirY*dirY) / (2*(fy-dirY))
	end
	local function df(x)
		return (x-fx) / (fy-dirY)
	end
	if (fy == dirY) then return end -- not parabola
	local ay, by = f(ax), f(bx)
	if (ay == by) then -- special case: horizontal AB
		return fx, ay + 2*((fy + dirY) / 2-ay)
	else
		local ad = df(ax) -- tangent slope for A
		local dx = (bx-ax)/2
		return ax+dx, ay+ad*dx
	end
end

function utils.updateBeachLine (diagram, yEvent)
--	conjugation point
	for i = 1, #diagram.beachLine-1 do
		local segment1 = diagram.beachLine[i]
		local segment2 = diagram.beachLine[i+1]
		updateConjugationPoint (diagram, segment1, segment2, yEvent)
	end

	-- update rendered parabola:
	for i, segment in ipairs (diagram.beachLine) do
		print ('segment.type', segment.type)
		if (segment.type == 'parabola') and segment.site.y < yEvent then
			print ('segment.type was parabola')
			local ax, ay = segment.left.x, segment.left.y
			local bx, by = segment.right.x, segment.right.y
			local cx, cy = getBezierControlPoint (segment.site.x, segment.site.y, ax, bx, yEvent)
			local curve = love.math.newBezierCurve( ax, ay, cx, cy, bx, by)
--			print (table.concat (curve:render(2), ','))
			segment.renderedLine = curve:render(4)
			segment.controlPoints = {ax, ay, cx, cy, bx, by}
		end
	end
end

local function findBeachLinePointAtX (diagram, xCut)
	local beachLine = diagram.beachLine

	for segmentIndex, segment in ipairs (beachLine) do
		if xCut == segment.right then
			-- special case: cut between segments
			return segmentIndex, nil
		elseif xCut < segment.right.x then
			-- cut this segment
			return segmentIndex, segment
		end
	end

end

local function evaluateSegment (segment, x, dirY)
	if segment.type == 'line' then
		local k = segment.k
		local m = segment.m
		local y = k * x + m
		return y
	elseif segment.type == 'parabola' then
		local site = segment.site
		local y = evaluateParabolaYbyX (x, site, dirY)
		return y
	end
end







local function updateBeachlineLinkSegments (beachLine)
	for i = 1, #beachLine do
		local segment = beachLine[i]
		segment.rightSegment = nil
		segment.leftSegment = nil
	end
	for i = 1, #beachLine-1 do
		local segment1 = beachLine[i]
		local segment2 = beachLine[i+1]
		segment1.rightSegment = segment2
		segment2.leftSegment = segment1
	end
end







local function findIntersectionOfPerpendicularLine(fx1, fy1, fx2, fy2, k, m)
--	fx1, fy1, fx2, fy2 - two focuses
-- k, m - line as y = k*x+m
--	https://www.desmos.com/calculator/uuwgskkjnu
	local ax, ay = (fx1 + fx2) / 2, (fy1 + fy2) / 2
	local k2 = - (fx2 - fx1) / (fy2 - fy1)
	local m2 = ay - k2 * ax
	local bx = (m2 - m) / (k - k2)
	local by = k * bx + m
	return bx, by
end

local function executeCircleEventNLP (event)
	print ('executeCircleEventNLP')
	local diagram = event.diagram
	local beachLine = diagram.beachLine
	local yEvent = event.yEvent

	local segment = event.segment
	local rightSegment = segment.rightSegment

	if segment.leftSegment then
		segment.leftSegment.right = segment.right
	end
	for index, v in ipairs (diagram.beachLine) do
		if segment == v then
			table.remove (diagram.beachLine, index)
			updateBeachlineLinkSegments (beachLine)
			return
		end
	end
end

local function executeCircleEventPLN (event)
	print ('executeCircleEventPLN')
	local diagram = event.diagram
	local beachLine = diagram.beachLine
	local yEvent = event.yEvent

	local segment = event.segment

--	local rightSegment = segment.rightSegment
--	if segment.leftSegment then
--		segment.leftSegment.right = segment.right
--	end	
	local leftSegment = segment.leftSegment
	if segment.rightSegment then
		segment.rightSegment.left = segment.left
	end

	for index, v in ipairs (diagram.beachLine) do
		if segment == v then
			table.remove (diagram.beachLine, index)
			updateBeachlineLinkSegments (beachLine)
			return
		end
	end
end

local function executeCircleEventPLP (event)
	print ('executeCircleEventPLP')
	local diagram = event.diagram
	local beachLine = diagram.beachLine
	local yEvent = event.yEvent
	local segment = event.segment
	local point = event.point

	local index
	for i, v in ipairs (diagram.beachLine) do
		if segment == v then
			index = i
			break
		end
	end

	if index then
		segment.leftSegment.right = point
		segment.rightSegment.left = point
		table.remove (diagram.beachLine, index)

		updateBeachlineLinkSegments (beachLine)

		print ('circle removed segment:')
		for i, segment in ipairs (beachLine) do
			print (i, segment.left.x..' '..segment.left.y, segment.right.x..' '..segment.right.y, segment.type)
			if segment.controlPoints then
				print ('controlPoints', table.concat (segment.controlPoints, ','))
			end
		end
	end
end

local function setCircleEventNLP (diagram, segment, right) -- nil line parabola
	-- left is nil
	-- segment is line
	-- right is parabola
	local eventQueue = diagram.eventQueue 
	local px1, py1 = segment.left.x, segment.left.y
	local px2, py2 = right.site.x, right.site.y
	local dist = ((px1-px2)^2 + (py1-py2)^2)^0.5
	local yEvent = py1 + dist
	local event = {
		type='circle', 
		yEvent = yEvent, 
		segment = segment,
		execute = executeCircleEventNLP,
		diagram = diagram,
	}
	table.insert (eventQueue, event)

	print ('added setCircleEventNLP', yEvent)
end

local function setCircleEventPLN (diagram, left, segment) -- parabola line nil
	-- left is parabola
	-- segment is line
	-- right is nil
	local eventQueue = diagram.eventQueue 
	local px1, py1 = segment.right.x, segment.right.y
	local px2, py2 = left.site.x, left.site.y
	local dist = ((px1-px2)^2 + (py1-py2)^2)^0.5
	local yEvent = py1 + dist
	local event = {
		type='circle', 
		yEvent = yEvent, 
		segment = segment,
		execute = executeCircleEventPLN,
		diagram = diagram,
	}
	table.insert (eventQueue, event)

	print ('added setCircleEventPLN', yEvent)
end

local function setCircleEventPLP (diagram, left, segment, right) -- parabola line parabola
	-- left is parabola
	-- segment is line
	-- right is parabola
	local eventQueue = diagram.eventQueue 

	-- parabola focuses:
	local fx1, fy1 = left.site.x, left.site.y
	local fx2, fy2 = right.site.x, right.site.y
	local x, y
	if fy1 == fy2 then
		-- special case for vertical edge
		local k, m = segment.k, segment.m
		x = (fx1+fx2)/2
		y = k*x+m
	else
		-- crossing k1 m1
		local k, m = segment.k, segment.m
		x, y = findIntersectionOfPerpendicularLine(fx1, fy1, fx2, fy2, k, m)
	end

	local dist = ((fx1-x)^2 + (fy1-y)^2)^0.5
	local yEvent = y + dist

	local event = {
		type='circle',
		name='eventPLP',
		yEvent = yEvent, 
		segment = segment,
		execute = executeCircleEventPLP,
		diagram = diagram,
		point = utils.newPoint (x, y)
	}
	table.insert (eventQueue, event)

	print ('added setCircleEventPLP', yEvent)

end


local function getCircumcircle (x1, y1, x2, y2, x3, y3)
	local d = 2*(x1*(y2-y3)+x2*(y3-y1)+x3*(y1-y2))
	local t1, t2, t3 = x1*x1+y1*y1, x2*x2+y2*y2, x3*x3+y3*y3
	local x = (t1*(y2-y3)+t2*(y3-y1)+t3*(y1-y2))/d
	local y = (t1*(x3-x2)+t2*(x1-x3)+t3*(x2-x1))/d
	local radius = math.sqrt((x1-x)*(x1-x)+(y1-y)*(y1-y))
	return x,y,radius
end


local function setClassicCircleEvent (diagram, leftSegment, segment, rightSegment)
	local fx1, fy1 = left.site.x, left.site.y
	local fx2, fy2 = right.site.x, right.site.y
	local fx3, fy3 = segment.right.x, segment.right.y -- Using the right end of the segment

	local x, y, radius = getCircumcircle(fx1, fy1, fx2, fy2, fx3, fy3)

	local yEvent = y + radius

	local event = {
		type = "circle",
		yEvent = yEvent,
--		site = segment.site,
		segment = segment,
		leftSegment = leftSegment,
		rightSegment = rightSegment,
		execute = executeCircleEvent,
		diagram = diagram,
		vertex = utils.newPoint (x, y, true)
	}

	table.insert(diagram.eventQueue, event)
end

local function setCircleEvent (diagram, segment)
	local left = segment.leftSegment
	local right = segment.rightSegment

	if left and right and left.type == "parabola" and right.type == "parabola" then
		if segment.type == "parabola" then
			-- classic circle event
			setClassicCircleEvent (diagram, left, segment, right)
			return
		elseif segment.type == "line" then
			-- crossing two parabolas on the given line:
			setCircleEventPLP (diagram, left, segment, right)
			return
		end

--		if left.type == "line" and segment.type == "line" and  right.type == "parabola" then
--			setCircleEventNLP (diagram, segment, right)
--			return

--		elseif left.type == "parabola" and segment.type == "line" and  right.type == "line" then
--			setCircleEventPLN (diagram, left, segment)
--			return
--		end

	elseif right and not left then
--		if segment.type == "line" and  right.type == "parabola" then
--			setCircleEventNLP (diagram, segment, right)
--			return
--		end

	elseif left and not right then
--		if segment.type == "line" and  left.type == "parabola" then
--			setCircleEventPLN (diagram, left, segment)
--			return
--		end
	end

end

local function executePointEvent (event)
	local diagram = event.diagram
	local beachLine = diagram.beachLine
	local site = event.site
	print ('executePointEvent', diagram.name, event.yEvent, site.x, site.y)
	local xCut = event.xCut
	local yEvent = event.yEvent
--	local cell = newCell (diagram, site)


	-- cut cutVertex when vertex x == Xcut; otherwise cut line (parabola or segment)
	local cutIndex, cutSegment = findBeachLinePointAtX(diagram, xCut)

	if cutSegment then

		local y = evaluateSegment (cutSegment, xCut, yEvent)
		print ('cut segment', cutSegment.type, xCut, y)
		local p1 = utils.newPoint (xCut-1, y)
		local p2 = utils.newPoint (xCut+1, y)

		local segment1 = copySegment (cutSegment)
		local segment2 = newParabolaSegment (p1, p2, site)
		local segment3 = copySegment (cutSegment)
		segment1.right = p1
		segment3.left = p2

		table.remove (beachLine, cutIndex)
		table.insert (beachLine, cutIndex, segment1)
		table.insert (beachLine, cutIndex+1, segment2)
		table.insert (beachLine, cutIndex+2, segment3)

		print ('point cutSegment:')
		for i, segment in ipairs (beachLine) do
			print (i, segment.left.x..' '..segment.left.y, segment.right.x..' '..segment.right.y)
		end

		updateBeachlineLinkSegments (beachLine)

		setCircleEvent (diagram, segment1)
		setCircleEvent (diagram, segment3)

		utils.sortQueue (diagram.eventQueue)
	else
		-- cut point: special case

	end
end

local function executePolygonVertexEvent (event)
	local site = event.site
	local vertex = event.vertex
	local yEvent = event.yEvent
	local diagram = event.diagram


end

function utils.newEventQueue (diagram)
	local eventQueue = {}

	-- adding sites

	for i, site in ipairs (diagram.sites) do
		local event = {
			type='site', 
			yEvent = site.y, 
			xCut = site.x,
			site=site,
			execute = executePointEvent,
			diagram = diagram
		}
		table.insert (eventQueue, event)
	end

	for i, vertex in ipairs (diagram.polygon) do
		local mindstsqr = math.huge
		local nearest = {}

		for j, site in ipairs (diagram.sites) do
			local sqrdist = (site.x-vertex.x)^2 + (site.y-vertex.y)^2

			if sqrdist < mindstsqr then
				nearest = {{site=site, vertex=vertex}}
				mindstsqr = sqrdist
			elseif sqrdist == mindstsqr then
				table.insert (nearest, {site=site, vertex = vertex})
			end
		end

		local dist = math.sqrt(mindstsqr)
		local yEvent = vertex.y + dist

		for i, near in ipairs (nearest) do
			local event = {
				type='vertex', 
				yEvent = yEvent, 
				site=near.site,
				vertex=near.vertex,
				execute = executePolygonVertexEvent,
				diagram = diagram
			}
			table.insert (eventQueue, event)
		end
	end

	utils.sortQueue (eventQueue)
	return eventQueue
end

return utils