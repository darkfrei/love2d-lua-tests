-- voronoi for closed polygon
print ('loaded', ...)

local utils = {}

utils.tiny = 0.0001

function utils.newPoint (x, y, fixed)
	local newPoint = {x=x, y=y, fixed=fixed}
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

function utils.newSites (flatSites)
	local sites = {}
	for i = 1, #flatSites, 2 do
		local newPoint = utils.newPoint (flatSites[i], flatSites[i+1], true)
		table.insert(sites, newPoint)
	end

	return utils.YX_Sort(sites)
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
	return x1, y1
end


local function findParabolaLineIntersection(site, segment, dirY)
	local fx, fy = site.x, site.y
	local k, m = segment.k, segment.m
	local x1, y1, x2, y2 = getParabolaToInclinedLineIntersections (fx, fy, k, m, dirY)
	-- get right point of parabola
	return x2, y2
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

local function updateBeachLine (diagram, yEvent)
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



local function executePointEvent (event)
	local diagram = event.diagram
	local beachLine = diagram.beachLine
	local site = event.site
	print ('executePointEvent', diagram.name, event.yEvent, site.x, site.y)
	local xCut = event.xCut
	local yEvent = event.yEvent
	local cell = newCell (diagram, site)

	-- update all x coordinates in the beachline
	if not (diagram.sweepLinePosition == yEvent) then
		print ('new sweepLinePosition', yEvent)
		updateBeachLine (diagram, yEvent)
		diagram.sweepLinePosition = yEvent
	end

	-- cut cutVertex when vertex x == Xcut; otherwise cut line (parabola or segment)
	local cutIndex, cutSegment = findBeachLinePointAtX(diagram, xCut)

	if cutSegment then

		local y = evaluateSegment (cutSegment, xCut, yEvent)
		print ('cut segment', cutSegment.type, xCut, y)
		local p1 = utils.newPoint (xCut, y)
		local p2 = utils.newPoint (xCut, y)

		local segment1 = copySegment (cutSegment)
		local segment2 = newParabolaSegment (p1, p2, site)
		local segment3 = copySegment (cutSegment)
		segment1.right = p1
		segment3.left = p2
		
		table.remove (beachLine, cutIndex)
		table.insert (beachLine, cutIndex, segment1)
		table.insert (beachLine, cutIndex+1, segment2)
		table.insert (beachLine, cutIndex+2, segment3)

	end
end

function utils.newEventQueue (diagram)
	local eventQueue = {}
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

	utils.sortQueue (eventQueue)
	return eventQueue
end

return utils