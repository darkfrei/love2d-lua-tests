--[[
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
 
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 
Based of the work David Ng (2010) and of Steve J. Fortune (1987) A Sweepline Algorithm for Voronoi Diagrams,
Algorithmica 2, 153-174, and its translation to C++ by Matt Brubeck, 
http://www.cs.hmc.edu/~mbrubeck/voronoi.html

-- https://github.com/TomK32/dVoronoi/tree/working

|highlight|
`code`
**bold text**
#Header
_italic_
]]--

--------
--------
--------

--local constants = {zero = 2^(-32)} -- just on the edge
--local constants = {zero = 2^(-28)} -- just on the edge
local constants = {zero = 2^(-26)} -- just on the edge

--------
--------
--------

local HHeap = {}
function HHeap:new()
	local heap = { heap = {}, nodes = {} }
	setmetatable(heap, self)
	self.__index = self
	return heap
end

function HHeap:push(key, value)
	assert(value ~= nil, "cannot push nil")
	local heapPosition = #self.heap + 1
	self.heap[heapPosition] = key
	self.nodes[key] = value

	while heapPosition > 1 do
		local parentPosition = math.floor(heapPosition / 2)
		if self.nodes[self.heap[parentPosition]] > value then
			self.heap[parentPosition], self.heap[heapPosition] = self.heap[heapPosition], self.heap[parentPosition]
			heapPosition = parentPosition
		else
			break
		end
	end

	return key
end
function HHeap:pop()
	local heapSize = #self.heap
	assert(heapSize > 0, "cannot pop from empty heap")
	local heapRoot = self.heap[1]
	local heapRootPosition = self.nodes[heapRoot]
	local currentHeap = self.nodes[self.heap[heapSize]]
	self.heap[1] = self.heap[heapSize]
	self.heap[heapSize] = nil
	self.nodes[heapRoot] = nil
	heapSize = heapSize - 1
	local nodePosition = 1
	while true do
		local leftChildPosition = 2 * nodePosition
		local rightChildPosition = leftChildPosition + 1
		local leftChildNode = self.heap[leftChildPosition]
		local currentNodeHeap = self.nodes[self.heap[nodePosition]]
		if leftChildPosition > heapSize then
			break
		end
		if rightChildPosition <= heapSize and self.nodes[self.heap[rightChildPosition]] < self.nodes[leftChildNode] then
			leftChildPosition = rightChildPosition
		end
		local leftChildHeapNode = self.nodes[self.heap[leftChildPosition]]
		if leftChildHeapNode < currentNodeHeap then
			self.heap[leftChildPosition], self.heap[nodePosition] = self.heap[nodePosition], self.heap[leftChildPosition]
			nodePosition = leftChildPosition
		else
			break
		end
	end
	return heapRoot, heapRootPosition
end


function HHeap:isEmpty()
	return not next(self.heap)
end

--------
--------
--------

local function newPoint (x, y, key, value)
	local point = {x=x, y=y}
	if key ~= nil then
		point[key] = value
	end
	return point
end

local function newSegment (startPoint, endPoint, typ)
	local segment = {
--startPoint = {x = x, y = y},
		startPoint = startPoint,
		endPoint = endPoint,
		done = false,
--		type = 1
	}
	return segment
end

--------
--------
--------

local DoubleLinkedList = {}

function DoubleLinkedList:new()
	local list = {first = nil, last = nil} -- empty list head
	setmetatable(list, self)
	self.__index = self
	return list
end

function DoubleLinkedList:insertAfter(currentNode, newData)
	local newNode = newPoint(newData.x, newData.y)
	newNode.prev = currentNode
	newNode.next = currentNode.next
	currentNode.next = newNode
	if currentNode == self.last then
		self.last = newNode
	else
		newNode.next.prev = newNode
	end
	newNode.node = true
	return newNode
end


function DoubleLinkedList:insertAtStart(newData)
	local newNode = newPoint(newData.x, newData.y)
	newNode.prev = nil
	newNode.next = self.first
	if not self.first then -- check if the list is empty
		self.first = newNode -- the new node is the first and the last in this case
		self.last = newNode
	else
		self.first.prev = newNode
		self.first = newNode
	end
	return newNode
end

function DoubleLinkedList:delete(node)
	if node == self.first then
		self.first = node.next
	else
		node.prev.next = node.next
	end

	if node == self.last then
		self.last = node.prev
	else
		node.next.prev = node.prev
	end
end

function DoubleLinkedList:nextNode(node)
	return (not node and self.first) or node.next
end

local Tools = { }
function Tools:processCircle(event, dVoronoi)
--	print ('processCircle', event.x, event.y)
	if event.valid then
		local x, y = event.x, event.y
--startPoint, endPoint
		local startPoint = event
		local endPoint = newPoint (0, 0)
		local segment = newSegment (startPoint, endPoint, 1)

		table.insert(dVoronoi.segments, segment)

-- Remove the associated arc from the front and update segment info
		dVoronoi.beachline:delete(event.arc)

		if event.arc.prev then
			event.arc.prev.seg1 = segment
		end

		if event.arc.next then
			event.arc.next.seg0 = segment
		end

-- Finish the edges before and after arc.
		if event.arc.seg0 then
			event.arc.seg0.endPoint = {x = event.x, y = event.y}
			event.arc.seg0.done = true
		end 

		if event.arc.seg1 then
			event.arc.seg1.endPoint = {x = event.x, y = event.y}
			event.arc.seg1.done = true
		end
		local vertex = {x = event.x, y = event.y}
		table.insert(dVoronoi.vertex, vertex)

		local radius1 = self:checkCircleEvent(dVoronoi, event.arc.prev, event.x)


		local radius2 = self:checkCircleEvent(dVoronoi, event.arc.next, event.x)

	end
end


--------
--------
--------


function Tools:processPoint(point, dVoronoi)
--	print ('processPoint', point.x, point.y)
--Adds a point to the beachline
--local intersect = self:intersect
	if not dVoronoi.beachline.first then
--		print ('new beachline', point.x, point.y)
		point.isPoint = true
		dVoronoi.beachline:insertAtStart(point)
		return
	end

--Find the current arc(s) at height p.y (if there are any).

	for arcNode in dVoronoi.beachline.nextNode, dVoronoi.beachline do
--		for i, v in pairs (arcNode) do
--			print (i, type (v))
--		end

		local x, y, specialCaseX = self:intersectPointArc(point, arcNode)
--		print ('processPoint, point', x, y, 'specialcase:', tostring (specialCaseX))
		if x and specialCaseX then
--			print ('x and specicialCase', 'x', x, 'y', y)
--			print ('arcNode y', arcNode.y, 'point.y', point.y)


--			dVoronoi.beachline:insertAfter(arcNode, point)
--			return
		elseif x then
--New parabola intersects arc i. If necessary, duplicate i.
-- ie if there is a next node, but there is not interation, then creat a duplicate
			if not (arcNode.next and self:intersectPointArc(point, arcNode.next)) then
				dVoronoi.beachline:insertAfter(arcNode, arcNode)
			else
				return
			end

			arcNode.next.seg1 = arcNode.seg1
			dVoronoi.beachline:insertAfter(arcNode, point)

--local segment = {startPoint = {x = x, y = y}, endPoint = {x = 0, y = 0}, done = false, type = 2}
			local startPoint = newPoint (x, y)
			local endPoint = newPoint (point.x, point.y)
			local segment = newSegment (startPoint, endPoint, 2)
--local segment2 = {startPoint = {x = x, y = y}, endPoint = {x = 0, y = 0}, done = false, type = 2}
			local segment2 = newSegment(startPoint, endPoint, 2)

			table.insert(dVoronoi.segments, segment)
			table.insert(dVoronoi.segments, segment2)

			arcNode.next.seg0 = segment
			arcNode.seg1 = segment

			arcNode.next.seg1 = segment2
			local radius1 = self:checkCircleEvent(dVoronoi, arcNode, point.x)


			local arc2 = arcNode.next.next
			arc2.seg0 = segment2
			local radius2 = self:checkCircleEvent(dVoronoi, arc2, point.x)


			return
		else
--			print ('no x, y', arcNode.x, arcNode.y)
		end 
	end

--Special case: If p never intersects an arc, append it to the list.
	dVoronoi.beachline:insertAtStart(point)

	local lastNode = dVoronoi.beachline.last
	local startPoint = newPoint (dVoronoi.boundary[1], (lastNode.y + lastNode.prev.y) / 2)
	local endPoint = newPoint (0,0)
	local segment = newSegment (startPoint, endPoint, 3)
--local segment = {
--startPoint = startPoint,
--endPoint = endPoint,
--done = false,
--type = 3
--}

	table.insert(dVoronoi.segments, segment)

	lastNode.seg0 = segment
	lastNode.prev.seg1 = segment
end



function Tools:checkCircleEvent(dVoronoi, arc, x0)
	if (arc.event and arc.event.x ~= x0) then
		arc.event.valid = false
	end
	arc.event = nil

	if ( not arc.prev or not arc.next) then
		return
	end

	local a = arc.prev
	local b = arc
	local c = arc.next

--	print ('createCircleEvent a, b, c', a.y, b.y, c.y)

	if ((b.x-a.x)*(c.y-a.y) - (c.x-a.x)*(b.y-a.y) >= 0) then
		return false
	end 

--Algorithm from O'Rourke 2ed p. 189.
	local A = b.x - a.x
	local B = b.y - a.y
	local C = c.x - a.x
	local D = c.y - a.y
	local E = A*(a.x+b.x) + B*(a.y+b.y)
	local F = C*(a.x+c.x) + D*(a.y+c.y)
	local G = 2*(A*(c.y-b.y) - B*(c.x-b.x))

	if (G == 0) then
--return false --Points are co-linear
		print("g is 0")
		return
	end

--Point o is the center of the circle.
--local o = {}
	local x = (D*E-B*F)/G
	local y = (A*F-C*E)/G

--o.x plus radius equals max x coordinate.
	local radius = math.sqrt( math.pow(a.x - x, 2) + math.pow(a.y - y, 2) )

	if x + radius > x0 then
--Create new event.
		local circleEvent = {x = x, y = y, arc = arc, valid = true, radius = radius}
		arc.event = circleEvent
		dVoronoi.events:push(circleEvent, x + radius)
		return radius
	end
end



function Tools:intersectPointArc(point, arc)
-- Checks whether a new parabola at point p intersects with arc i.
-- Returns the intersection point or special case indicators.

-- Special case: Check if the x-coordinate of the focus aligns with the x-coordinate of the arc's vertex.
	if (arc.x == point.x) and not arc.next then 
--		print ('Special case for point and arc: x=x', point.x, point.y, arc.x, arc.y)
		table.insert (specialCaseVLines, {point.x, point.y, arc.x, arc.y})
		local x, y = point.x, point.y
		return x, y, true
	end

--Special case2
	if (arc.y == point.y) then 
--		print ('Special case for point and arc: y=y', point.x, point.y, arc.x, arc.y)
		table.insert (specialCaseHLines, {point.x, point.y, arc.x, arc.y})
--return point.x, point.y, true
	end

-- Calculate the intersection with the previous arc, if it exists.
	local ax, ay
	if (arc.prev) then
		ax, ay = self:intersectParabolas(arc.prev, arc, point.x)
	end 

-- Calculate the intersection with the next arc, if it exists.
	local bx, by
	if (arc.next) then
		bx, by = self:intersectParabolas(arc, arc.next, point.x)
	end



-- Check if the point is within the y-range of the current arc.
	if ((not arc.prev or ay <= point.y) and (not arc.next or point.y <= by)) then
-- Calculate the intersection point.
		local y = point.y
		local x = (arc.x * arc.x + (arc.y - y) * (arc.y - y) - point.x * point.x) / (2 * arc.x - 2 * point.x)
		return x, y
	end

-- No intersection or special case.
--	print ('intersectPointArc, no intersection', point.x, point.y, arc.x, arc.y)
	return nil, nil, false
end



function Tools:intersectParabolas(focus1, focus2, directrix)
-- Calculate the intersection point of two parabolas.

	local x, y
	local currentFocus = {x = focus1.x, y = focus1.y}

	if (focus1.x == focus2.x) then
-- Parabolas are symmetric, intersection is the midpoint on the y-axis.
		y = (focus1.y + focus2.y) / 2
	elseif (focus2.x == directrix) then
-- Second parabola is vertical, intersection is its y-coordinate.
		y = focus2.y
	elseif (focus1.x == directrix) then
-- First parabola is vertical, intersection is its y-coordinate.
		y = focus1.y
		currentFocus = {x = focus2.x, y = focus2.y}
	else
-- Use the quadratic formula to calculate the y-coordinate for non-vertical parabolas.
		local z0 = 2 * (focus1.x - directrix)
		local z1 = 2 * (focus2.x - directrix)

		local a = 1 / z0 - 1 / z1
		local b = -2 * (focus1.y / z0 - focus2.y / z1)
		local c = (focus1.y * focus1.y + focus1.x * focus1.x - directrix * directrix) / z0 -
		(focus2.y * focus2.y + focus2.x * focus2.x - directrix * directrix) / z1

		y = (-b - math.sqrt(b * b - 4 * a * c)) / (2 * a)
	end

-- Plug back into one of the parabola equations to find the x-coordinate.
	x = (currentFocus.x * currentFocus.x + (currentFocus.y - y) * (currentFocus.y - y) - directrix * directrix) / (2 * currentFocus.x - 2 * directrix)

	return x, y
end


function Tools:finishEdges(dVoronoi, rightDoubleBoundary)
--Extend each remaining segment to the new parabola intersectParabolass.
	for arc in dVoronoi.beachline.nextNode, dVoronoi.beachline do
		if arc.seg1 then
			local x, y = self:intersectParabolas(arc, arc.next, rightDoubleBoundary)
			arc.seg1.endPoint = {x = x, y = y}
			arc.seg1.done = true
		end
	end
end


--------
--------
--------

--------
--------
--------

-- vertical directix
--[[
local function sortPoints(p1, p2)
	if p1.x == p2.x then
		return p1.y < p2.y
	else
		return p1.x < p2.x
	end
end
--]]

-- horizontal  directix
local function sortPoints(p1, p2)
	if p1.y == p2.y then
		-- left to right
		return p1.x < p2.x
	else
--		from top to bottom
		return p1.y < p2.y
	end
end

function Tools:sortThePoints(points)
	table.sort(points, sortPoints)
	return points
end


function Tools:tableContains(tablename,attributename,value)
	if attributename == nil then
		for _, v in pairs(tablename) do
			if v == value then return true end
		end
	elseif type(attributename) == 'table' then
		for _, v in pairs(tablename) do
			local match = 0
			for j,v2 in pairs(attributename) do
				if v[v2] == value[j] then match = match + 1 end
			end
			if match == #attributename then return true end
		end
	else
		for _, v in pairs(tablename) do
			if v[attributename] == value then return true end
		end
	end
	return false

end


function Tools:sorttable(datable, parameter, sortbyascending)
	local sortedtable = {}
	local comparator = sortbyascending and 1 or -1
	table.sort(datable, function(a, b)
			return comparator * (a[parameter] - b[parameter]) < 0
		end)
	for _, value in ipairs(datable) do
		table.insert(sortedtable, value)
	end
	return sortedtable
end

function Tools:getSortedVertices(points)
	local centroidX, centroidY = 0, 0
	for _, point in pairs(points) do
		centroidX = centroidX + point.x
		centroidY = centroidY + point.y
	end
	centroidX = centroidX / #points
	centroidY = centroidY / #points

	local function compareAngles(p1, p2)
		local angle1 = math.atan2(p1.y - centroidY, p1.x - centroidX)
		local angle2 = math.atan2(p2.y - centroidY, p2.x - centroidX)
		return angle1 < angle2
	end

	table.sort(points, compareAngles)
	return points
end

--function Tools:getSortedVertices(points)
--	sortPointsClockwise(points)

--	local vertices = {}
--	for i = 1, #points do
--		local point = points[i]
--		table.insert(vertices, point.x)
--		table.insert(vertices, point.y)
--	end
--	return vertices
--end

function Tools:pointsToVertices(points)
	local vertices = {}
	for i = 1, #points do
		local point = points[i]
		table.insert(vertices, point.x)
		table.insert(vertices, point.y)
	end
	return vertices
end

--[[
function Tools:intersectionPoint(line1,line2)
local dx1, dy1 = line1[3]-line1[1], line1[4]-line1[2]
local dx2, dy2 = line2[3]-line2[1], line2[4]-line2[2]
local slope1 = dy1/dx1
local slope2 = dy2/dx2
local intercept1 = line1[2] - (slope1*line1[1])
local intercept2 = line2[2] - (slope2*line2[1])

local ix = 0
local iy = 0

-- checks if there is a vertical line
if line1[1] == line1[3] then
--line 1 is vertical
ix = line1[1]
iy = slope2*ix + intercept2
elseif line2[1] == line2[3] then
--line 2 is vertical
ix = line2[1]
iy = slope1*ix + intercept1
else
-- do the normal math
ix = (intercept2 - intercept1) / (slope1 - slope2)
iy = slope1*ix + intercept1
end

local onbothlines = self:isOnLine(ix,iy,line1) and self:isOnLine(ix,iy,line2)

return ix, iy, onbothlines
end
--]]

-- [[

local function getLineParams(x1, y1, x2, y2)
	local slope = (y2 - y1) / (x2 - x1)
	local intercept = y1 - slope * x1
	return slope, intercept
end



function Tools:intersectionLineVertices (x1, y1, x2, y2, x3, y3, x4, y4)
	local slopeA, interceptA = getLineParams(x1, y1, x2, y2)

	local slopeB, interceptB = getLineParams(x3, y3, x4, y4)

	local ix, iy

-- check if lines are vertical
	if x1 == x2 then
		ix = x1
		iy = slopeB * ix + interceptB
	elseif x3 == x4 then
		ix = x3
		iy = slopeA * ix + interceptA
	else
-- normal case
		ix = (interceptB - interceptA) / (slopeA - slopeB)
		iy = slopeA * ix + interceptA
	end

	local onBothLines = self:isOnLineVertices(ix, iy, x1, y1, x2, y2) 
	and self:isOnLineVertices(ix, iy, x3, y3, x4, y4)

	return ix, iy, onBothLines
end


function Tools:intersectionSegments(segmentA, segmentB)
	local x1, y1, x2, y2 = segmentA.startPoint.x, segmentA.startPoint.y, segmentA.endPoint.x, segmentA.endPoint.y
	local x3, y3, x4, y4 = segmentB.startPoint.x, segmentB.startPoint.y, segmentB.endPoint.x, segmentB.endPoint.y
	return self:intersectionLines(x1, y1, x2, y2, x3, y3, x4, y4)
end



function Tools:intersectionPoint(lineA, lineB)
	local x1, y1, x2, y2 = lineA[1], lineA[2], lineA[3], lineA[4]
	local x3, y3, x4, y4 = lineB[1], lineB[2], lineB[3], lineB[4]
	return self:intersectionLineVertices (x1, y1, x2, y2, x3, y3, x4, y4)
end

--[[
function Tools:isSegmentIntersect(line1, groupoflines)
-- checks if the line segment intersects any of the line segments in the group of lines

local timestrue = 0
local timesfalse = 0
local checkset = { }

for index, line2 in pairs(groupoflines) do
local ix,iy,onbothlines = self:intersectionPoint(line1,line2)

if ((math.abs(line1[1]-ix)+math.abs(line1[2]-iy))<constants.zero 
or (math.abs(line1[3]-ix)+math.abs(line1[4]-iy))<constants.zero) then 
onbothlines = false
end

checkset[index] = onbothlines

if onbothlines then timestrue = timestrue + 1 else timesfalse = timesfalse + 1 end
end

if timestrue > 0 then return false else return true end
end
--]]

local function sameVertices(x1, y1, x2, y2)
	local threshold = constants.zero
	return math.abs(x1 - x2) < threshold and math.abs(y1 - y2) < threshold
end

local function withinBounds(val, bound1, bound2)
	return (bound1 <= val and val <= bound2) or (bound2 <= val and val <= bound1)
end

function Tools:isOnLineVertices (x, y, x1, y1, x2, y2)
	return withinBounds(x, x1, x2) 
	and withinBounds(y, y1, y2) and 
	not sameVertices(x, y, x2, y2)
end

function Tools:isOnLine(x, y, line)
	local x1, y1, x2, y2 = line[1], line[2], line[3], line[4]
	return withinBounds(x, x1, x2) 
	and withinBounds(y, y1, y2) and 
	not sameVertices(x, y, x2, y2)
end


--[[
function Tools:round(num, idp)
--http://lua-users.org/wiki/SimpleRound
local mult = 10^(idp or 0)
return math.floor(num * mult + 0.5) / mult
end
--]]

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
--[[
local function sameDirection(segment1, segment2)
local dx1, dy1 = segment1.endPoint.x - segment1.startPoint.x, segment1.endPoint.y - segment1.startPoint.y
local dx2, dy2 = segment2.endPoint.x - segment2.startPoint.x, segment2.endPoint.y - segment2.startPoint.y

return math.abs(math.atan2 (dy1, dx1) - math.atan2 (dy2, dx2)) < constants.zero
or math.abs(math.atan2 (dy1, dx1) - math.atan2 (-dy2, -dx2)) < constants.zero
end
--]]

--local function samePoint(point1, point2)
--return math.abs (point1.x - point2.x) < constants.zero and math.abs (point1.y - point2.y) < constants.zero
--end

--local function mergeSegment(segment1, segment2)
--segment1.startPoint = segment1.endPoint
--segment1.endPoint = segment2.endPoint
--end

--local function removeSegment(segments, segment)
--for i, seg in ipairs(segments) do
--if seg == segment then
--table.remove(segments, i)
--break
--end
--end
--end

--local function cleanSegments(segments)
--local tempSegments = {}
--for i, segment1 in ipairs(segments) do
--for j, segment2 in ipairs(segments) do
--if i ~= j 
--and sameDirection(segment1, segment2) 
--and Tools:samePoint(segment1.startPoint, segment2.startPoint) 
--then
--mergeSegment(segment1, segment2)
--removeSegment(segments, segment2)
--break
--end
--end
--table.insert (tempSegments, segment1)
--end
--return tempSegments
--end

------------------------------------------------------
------------------------------------------------------
------------------------------------------------------

local function isSegmentOutsideBoundary(start, stop, boundary)
	return start.x < boundary[1] or stop.x < boundary[1]
	or start.x > boundary[3] or stop.x > boundary[3]
	or start.y < boundary[2] or stop.y < boundary[2]
	or start.y > boundary[4] or stop.y > boundary[4]
end



function Tools:dirtyPolygon ( dVoronoi )
	local minx, miny = dVoronoi.boundary[1], dVoronoi.boundary[2]
	local maxx, maxy = dVoronoi.boundary[3], dVoronoi.boundary[4]

	local polygonList = {}
	local processingPoints = dVoronoi.vertex
	for i = #processingPoints, 1, -1 do
		if (processingPoints[i].x < minx) 
		or (processingPoints[i].x > maxx) 
		or (processingPoints[i].y < miny) 
		or (processingPoints[i].y > maxy) then
			processingPoints[i] = nil
		end
	end

-- adds other points that are not in the vertexes, like the corners and intersectParabolass with the boundary
	local otherPoints = {
		newPoint (minx, miny),
		newPoint (minx, maxy),
		newPoint (maxx, miny),
		newPoint (maxx, maxy),
	}

	local boundaries = {
		{ minx, miny, minx, maxy }, -- left boundary
		{ maxx, miny, maxx, maxy }, -- right boundary
		{ minx, miny, maxx, miny }, -- top boundary
		{ minx, maxy, maxx, maxy } -- bottom boundary
	}

--print ('was #dVoronoi.segments', #dVoronoi.segments)
--dVoronoi.segments = cleanSegments (dVoronoi.segments)
--print ('now #dVoronoi.segments', #dVoronoi.segments)

	for _, segment in pairs(dVoronoi.segments) do
		local isects = {}
		for _, boundary in ipairs(boundaries) do
			if (segment.startPoint.x < boundary[1] or segment.endPoint.x < boundary[1])
			or (segment.startPoint.x > boundary[3] or segment.endPoint.x > boundary[3])
			or (segment.startPoint.y < boundary[2] or segment.endPoint.y < boundary[2])
			or (segment.startPoint.y > boundary[4] or segment.endPoint.y > boundary[4]) then
-- The segment intersects with the current boundary.

-- Create lines for intersection calculation.
				local line1 = boundary
				local line2 = {segment.startPoint.x, segment.startPoint.y, segment.endPoint.x, segment.endPoint.y}

-- Calculate the intersection point.
				local x, y, onlines = self:intersectionPoint(line1, line2)

				if onlines then
-- If there is an intersection on the line, create a new point.
					local isect = newPoint(x, y)
--					print('isect', x, y)
					isect.onlines = onlines
					table.insert(otherPoints, isect)
				end
			end
		end
	end

	for _, point in ipairs(otherPoints) do
--		print ('otherpoint', point.x, point.y)
		table.insert(processingPoints,point) 
	end

	for i, point in pairs(processingPoints) do
		local distances = {}
		for siteIndex, sitePoint in pairs(dVoronoi.points) do
			local distance = { 
				i = siteIndex, 
				sqrDist = ((point.x - sitePoint.x)^2 + (point.y - sitePoint.y)^2)
			}
			table.insert (distances, distance) 
		end

		distances = self:sorttable(distances, 'sqrDist', true)

		local mindistance = distances[1].sqrDist
		local related = {}
		for _, distInfo in ipairs(distances) do
			if distInfo.sqrDist - mindistance < constants.zero then
				local polyIndex = distInfo.i
				local poly = polygonList[polyIndex] or {}
				poly[#poly + 1] = { x = point.x, y = point.y }
				polygonList[polyIndex] = poly
				related[#related + 1] = polyIndex
			end
		end

		for _, indexA in ipairs(related) do
			if not dVoronoi.polygonMap[indexA] then
				dVoronoi.polygonMap[indexA] = {}
			end

			for _, indexB in ipairs(related) do
				if indexA ~= indexB and not self:tableContains(dVoronoi.polygonMap[indexA], nil, indexB) then
					dVoronoi.polygonMap[indexA][#dVoronoi.polygonMap[indexA] + 1] = indexB
				end
			end
		end
	end

	local uniquePoints = {}
	local uniquePointsHash = {}
	for i, points in ipairs(polygonList) do
		for j, point in ipairs (points) do
			local x, y = point.x, point.y
			local str = tostring(x) .. "_" .. tostring(y)
			if not uniquePointsHash[str] then
				table.insert (uniquePoints, point)
				local index = #uniquePoints
				point.index = index
				uniquePointsHash[str] = index
			end
		end
	end

	dVoronoi.uniquePoints = uniquePoints

	local uniqueSegments = {}
	local uniqueSegmentsHash = {}

	for i, points in ipairs(polygonList) do
--print (i, #points, #polygonList)
		points = self:getSortedVertices(points)


		for i = 1, #points do
			local p1 = points[i]
			local p2 = points[(i % #points)+1]
			local x1, y1, x2, y2= p1.x, p1.y, p2.x, p2.y
			if sortPoints (p1, p2) then
				local x1, y1, x2, y2 = x2, y2, x1, y1
			end
			local str = tostring(x1) .. "_" .. tostring(y1).. 
					"_" .. tostring(x2).. "_" .. tostring(y2)
			if not uniqueSegmentsHash[str] then
				table.insert (uniqueSegments, {x1, y1, x2, y2})
				local index = #uniqueSegments
				uniqueSegmentsHash[str] = index
			end
		end
		
		

		local vertices = self:pointsToVertices(points)
		dVoronoi.polygons[i] = self.polygon:new(vertices, i)
	end
	
	dVoronoi.uniqueSegments = uniqueSegments

end

---------------------------------------------
-- generates randomPoints
function Tools:randomPoint(minx,miny,maxx,maxy)
	local x = math.random(minx+1,maxx-1) 
	local y = math.random(miny+1,maxy-1)
	return x,y 
end


--------
--------
--------

local Polygon = { }

function Polygon:new(vertices, index)
-- creates the edges
	local edges = {}
	local edge = {vertices[#vertices-1], vertices[#vertices], vertices[1], vertices[2]}
	table.insert (edges, edge)

	for i=1, #vertices-2, 2 do
		edge = {vertices[i], vertices[i+1], vertices[i+2], vertices[i+3]}
		table.insert (edges, edge)
	end

	local poly = {
		points = vertices,
		edges = edges,
		index = index,
	}

	setmetatable(poly, self) 
	self.__index = self 

	return poly
end

----------------------------------------------------------
-- checks if the point is inside the polygon
function Polygon:containsPoint(x, y)
	local isInside = false
	for _, edge in ipairs (self.edges) do
		local x1, y1, x2, y2 = edge[1], edge[2], edge[3], edge[4]
		if ((y1 > y) ~= (y2 > y)) and
		(x < (x2 - x1) * (y - y1) / (y2 - y1) + x1) then
			isInside = not isInside
		end
	end
	return isInside
end


----------------
----------------
----------------


local voronoilib = { }




--local function getRVoronoi (points, iterations, minx,miny,maxx,maxy)
local function getRVoronoi (sitePoints, frameX,frameY, frameW, frameH)
--local function getRVoronoi (sitePoints, minx,miny,maxx,maxy)

	local minx,miny,maxx,maxy = frameX,frameY, frameW, frameH
	local rightDoubleBoundary = 2*(maxx + (maxx-minx) + (maxy-miny))
--print ('rightDoubleBoundary', rightDoubleBoundary)
	local boundary = {minx, miny, minx+maxx, miny+maxy}
	local dVoronoi = {}
	dVoronoi.points = sitePoints
	dVoronoi.boundary = boundary

	dVoronoi.vertex = { }
	dVoronoi.segments = { }
	dVoronoi.events = HHeap:new()
	dVoronoi.beachline = DoubleLinkedList:new()
	dVoronoi.polygons = { }
	dVoronoi.polygonMap = { }


-- sets up the dVoronoi events
--for i = 1, #sitePoints do
	for i, sitePoint in ipairs (sitePoints) do
--print (i, 'sitePoint', sitePoint.x, sitePoint.y)
		dVoronoi.events:push(sitePoint, sitePoint.x, {i})
	end

	while not dVoronoi.events:isEmpty() do
		local event = dVoronoi.events:pop()
--print ('event', event.x, event.y, 'event:', tostring (event.event))

		if event.arc then
			if event.valid then
				
				table.insert (specialCaseCircle, {event.x, event.y, event.radius, 1})
				Tools:processCircle(event, dVoronoi)
			end
		else
			Tools:processPoint(event, dVoronoi)
		end 
	end


	Tools:finishEdges(dVoronoi, rightDoubleBoundary)

	Tools:dirtyPolygon(dVoronoi)

	return dVoronoi
end

--local function generatePoints (polygoncount,iterations,minx,miny,maxx,maxy)
local function generateSitePoints (polygoncount, minx,miny, maxx,maxy)
	local points = {}
	for _ = 1, polygoncount do
		local x,y = Tools:randomPoint(minx,miny,maxx,maxy)
		while Tools:tableContains(points,{ 'x', 'y' }, { x, y }) do
			x,y = Tools:randomPoint(minx,miny,maxx,maxy)
		end
		local point = { x = x, y = y }
		table.insert (points, point)
	end
	return points
end

local function newSite (x, y, minX, minY, maxX, maxY)
	if x > minX and x < maxX and y > minY and y < maxY then
		local site = newPoint (x, y)
		site.site = true
		return site
	end
end

function voronoilib:new(siteVertices, frameX,frameY, frameW, frameH)
	local sites = {}
	local safe = 10
	local minX, minY = frameX+safe, frameY+safe
	local maxX, maxY = frameX+frameW-safe, frameY+frameH-safe

	for i = 1, #siteVertices-1, 2 do
		local x = siteVertices[i]
		local y = siteVertices[i+1]
		local site = newSite (x, y, minX, minY, maxX, maxY)
		table.insert (sites, site)
	end
	local dVoronoi = getRVoronoi (sites, frameX,frameY, frameW, frameH)
	setmetatable(dVoronoi, self) 
	self.__index = self 
	return dVoronoi -- voronoi diagram
end


function voronoilib:generateNew(polygoncount, minx,miny,maxx,maxy)
	local sites = generateSitePoints (polygoncount, minx,miny,maxx,maxy)
	local str = ''
	for _, p in ipairs (sites) do
		str = str..p.x..','..p.y..', '
	end
	print ('generated points: {'..str..'}')
	local genvoronoi = self:new(sites, minx,miny,maxx,maxy)
	setmetatable(genvoronoi, self) 
	self.__index = self 
	return genvoronoi
end

------------------------------------------------
-- returns the actual polygons that are the neighbors
function voronoilib:getNeighborsSingle(polygon)
	local index = polygon.index
	local neighbors = {}
	for _, indexNeighbour in pairs (self.polygonMap[index]) do
		local neighbor = self.polygons[indexNeighbour]
		table.insert (neighbors, neighbor)
	end
	return neighbors
end



function voronoilib:polygonContains(x, y)
	local closestPolygon = nil
	local minDistance = math.huge
	for index, point in pairs(self.points) do
		local dx = x - point.x
		local dy = y - point.y
		local sqrDist = (dx * dx + dy * dy)
		if sqrDist < minDistance then
			minDistance = sqrDist
			closestPolygon = self.polygons[index]
		end
	end
	if closestPolygon:containsPoint (x, y) then
-- if pointInConvexPolygon(x, y, poly) then
		return closestPolygon
	end
end

local function sqrDistanceToSegment(x, y, x1, y1, x2, y2)
	local dx, dy = x2 - x1, y2 - y1
	local l2 = dx * dx + dy * dy

	if l2 == 0 then
		return ((x - x1)^2 + (y - y1)^2)
	end

	local t = ((x - x1) * dx + (y - y1) * dy) / l2

	if t < 0 then
		return ((x - x1)^2 + (y - y1)^2)
	elseif t > 1 then
		return ((x - x2)^2 + (y - y2)^2)
	end

	local projectionX, projectionY = x1 + t * dx, y1 + t * dy
	return (x - projectionX)^2 + (y - projectionY)^2
end


function voronoilib:edgeContains(x, y, minDistance)
	local closestEdge = nil
	minDistance = minDistance or math.huge
	local found = false

	for _, segment in pairs(self.uniqueSegments) do
		local x1, y1 = segment[1], segment[2]
		local x2, y2 = segment[3], segment[4]
		
		local sqrDist = sqrDistanceToSegment(x, y, x1, y1, x2, y2)
		if sqrDist < minDistance then
			minDistance = sqrDist
			closestEdge = edge
			found = true
--print ('found')
		end
	end

	if found then
		return closestEdge
	else
		return nil
	end
end


----------------
----------------
----------------

Tools.polygon = Polygon

voronoilib.heap = HHeap
voronoilib.Tools = Tools
voronoilib.DoubleLinkedList = DoubleLinkedList

return voronoilib