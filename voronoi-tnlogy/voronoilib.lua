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


math.log2 = function (x)
	return math.log(x) / math.log(2)
end

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

function HHeap:heapPrint()
	if not next(self.heap) then
		print("Heap is empty.")
		return
	end

	local levels = math.ceil(math.log2(#self.heap))
	local index = 1
	print ('heap size', #self.heap)
	for level = 1, levels do
		local spaces = string.rep("	", 2 ^ (levels - level) - 1)
		for i = 1, 2^(level - 1) do
			if index <= #self.heap then
				print(spaces..'heapIndex: '..self.nodes[self.heap[index]], 
					'x:'..self.heap[index].x, 'y:'..self.heap[index].y)
				index = index + 1
			else
				break
			end
		end
	end
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
		startPoint = startPoint,
		endPoint = endPoint,
		done = false,
	}
	return segment
end

--------
--------
--------

local DoubleLinkedList = {}
-- class for beachline

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

function DoubleLinkedList:length()
	local index = 0
	local current = self.first
	while current do
		index = index + 1
		current.index = index
		current = current.next
	end
	return index
end

local function segmentToStr(segment)
	local str = "Start Point: (" .. segment.startPoint.x .. ", " .. segment.startPoint.y .. ")"
	.. " End Point: (" .. segment.endPoint.x .. ", " .. segment.endPoint.y .. ")"
	return str
end


function DoubleLinkedList:showContents()
	local node = self.first
	print ('beachline length:', self:length())
	while node do
		print (node.index, 'x:'..node.x, 'y:'..node.y)

		local str = ''
		for i in pairs (node) do
			str = str .. i .. ' '
		end
		print (str)

		if node.leftSegm then
			print(node.index, 'left', segmentToStr(node.leftSegm))
		end
		if node.rightSegm then
			print(node.index, 'right', segmentToStr(node.rightSegm))
		end

		node = node.next
		if node then
			print ('# # #')
		end
	end
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

---------------
---------------
---------------


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


---------------
---------------
---------------

local Tools = { }
function Tools:processCircle(dVoronoi, circle)
--	print ('processCircle', event.x, event.y)
	if circle.valid then
		local x, y = circle.x, circle.y
--startPoint, endPoint
		local startPoint = circle
		local endPoint = newPoint (0, 0)
		local segment = newSegment (startPoint, endPoint, 1)

		table.insert(dVoronoi.segments, segment)

		-- Remove the associated arc from the front and update segment info
		dVoronoi.beachline:delete(circle.arc)

		if circle.arc.prev then
			-- prev is left
			circle.arc.prev.rightSegm = segment
		end

		if circle.arc.next then
			-- next is right
			circle.arc.next.leftSegm = segment
		end

-- Finish the edges before and after arc.
		if circle.arc.leftSegm then
			circle.arc.leftSegm.endPoint = {x = circle.x, y = circle.y}
			circle.arc.leftSegm.done = true
		end 

		if circle.arc.rightSegm then
			circle.arc.rightSegm.endPoint = {x = circle.x, y = circle.y}
			circle.arc.rightSegm.done = true
		end
--		local vertex = {x = circle.x, y = circle.y}
		local vertex = newPoint (circle.x, circle.y)
		table.insert(dVoronoi.vertex, vertex)

		self:checkCircleEvent(dVoronoi, circle.arc.prev, circle.x)


		self:checkCircleEvent(dVoronoi, circle.arc.next, circle.x)

	end
end


--------
--------
--------

function Tools:insertPointCommon (dVoronoi, arcNode1, site, x, y)
	dVoronoi.beachline:insertAfter(arcNode1, arcNode1)

--	local arcNode2 = arcNode1.next

	arcNode1.next.rightSegm = arcNode1.rightSegm

	dVoronoi.beachline:insertAfter(arcNode1, site)

	local arcNode2 = arcNode1.next

	local startPoint = newPoint (x, y)
	local endPoint = newPoint (site.x, site.y)
	local segment = newSegment (startPoint, endPoint, 2)
	local segment2 = newSegment(startPoint, endPoint, 2)

	table.insert(dVoronoi.segments, segment)
	table.insert(dVoronoi.segments, segment2)

	arcNode1.rightSegm = segment
	arcNode2.leftSegm = segment
	arcNode1.next.rightSegm = segment2

	self:checkCircleEvent(dVoronoi, arcNode1, site.x)
	arcNode1.next.next.leftSegm = segment2
	self:checkCircleEvent(dVoronoi, arcNode1.next.next, site.x)
end



function Tools:getCurrentArc(dVoronoi, site)
	local currentNode = dVoronoi.beachline.first
	while currentNode do
		local nextNode = currentNode.next
		if nextNode then
			local x, y, specialCaseX = self:intersectPointArc(site, currentNode)
			if x then
				if not self:intersectPointArc(site, nextNode) then
					return currentNode
				end
			end
		end
		currentNode = currentNode.next
	end
	return dVoronoi.beachline.last
end


function Tools:processPoint(dVoronoi, site)
	print ('processPoint', site.x, site.y)


	if not dVoronoi.beachline.first then
		-- creates new beachline and return
		print ('new beachline', site.x, site.y)
		dVoronoi.beachline:insertAtStart(site)
		return
	end


	local arcNodeTest = self:getCurrentArc(dVoronoi, site)
	print ('arcNodeTest', arcNodeTest.index)

	for arcNode in dVoronoi.beachline.nextNode, dVoronoi.beachline do
		local x, y, specialCaseX = self:intersectPointArc(site, arcNode)
		print ('processPoint, point', x, y, 'specialcase:', tostring (specialCaseX))
		if x and specialCaseX then
			print ('x and specicialCase', 'x', x, 'y', y)
			if not (arcNode.next and self:intersectPointArc(site, arcNode.next)) then
				self:insertPointCommon (dVoronoi, arcNode, site, x, y)
			end
			return
		elseif x then
			-- New parabola intersects arc i. If necessary, duplicate i.
			-- ie if there is a next node, but there is not interation, then creat a duplicate
			print ('intersectPointArc crossing:', x, y)
			if not (arcNode.next and self:intersectPointArc(site, arcNode.next)) then
				print ('no next')
				self:insertPointCommon (dVoronoi, arcNode, site, x, y)
			end
			return
		end 
	end

--Special case: If p never intersects an arc, append it to the list.
	print ('special case 2')


	dVoronoi.beachline:insertAtStart(site)
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

	lastNode.leftSegm = segment
	lastNode.prev.rightSegm = segment
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
		dVoronoi.eventsHeap:push(circleEvent, x + radius) -- vertical directrix
--		dVoronoi.eventsHeap:push(circleEvent, y + radius) -- hoizontal directrix
		return radius
	end
end



function Tools:intersectPointArc(point, arc)
-- Checks whether a new parabola at point p intersects with arc i.
-- Returns the intersection point or special case indicators.

-- Special case: Check if the x-coordinate of the focus aligns with the x-coordinate of the arc's vertex.
	if (arc.x == point.x) and not arc.next then 
		print ('Special case for point and arc: x=x', point.x, point.y, arc.x, arc.y)
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
		ax, ay = self:intersectParabolasV(arc.prev, arc, point.x) -- vertical directrix
--		ax, ay = self:intersectParabolasH(arc.prev, arc, point.y) -- horizontal directrix
	end 

-- Calculate the intersection with the next arc, if it exists.
	local bx, by
	if (arc.next) then
		bx, by = self:intersectParabolasV(arc, arc.next, point.x) -- vertical directrix
--		bx, by = self:intersectParabolasH(arc, arc.next, point.y) -- horizontal directrix
	end



-- Check if the point is within the y-range of the current arc.
	if ((not arc.prev or ay <= point.y) and (not arc.next or point.y <= by)) then -- vertical directrix
--	if ((not arc.prev or ax <= point.x) and (not arc.next or point.x <= bx)) then -- horizontal directrix
-- Calculate the intersection point.

		-- vertical directrix
		local y = point.y
		local x = (arc.x * arc.x + (arc.y - y) * (arc.y - y) - point.x * point.x) / (2 * arc.x - 2 * point.x)

		-- horizontal directrix
--		local x = point.x
--		local y = (arc.y * arc.y + (arc.x - x) * (arc.x - x) - point.y * point.y) / (2 * arc.y - 2 * point.y)
		return x, y
	end

-- No intersection or special case.
--	print ('intersectPointArc, no intersection', point.x, point.y, arc.x, arc.y)
	return nil, nil, false
end



function Tools:intersectParabolasV(focus1, focus2, directrix)
-- Calculate the intersection point of two parabolas.

	local x, y
--	local currentFocus = {x = focus1.x, y = focus1.y}
	local currentFocus = focus1

	print ('directrix:'..directrix, 'focus1.x:'..focus1.x, 'focus2.x:'..focus2.x)
	if (focus1.x == directrix) and (focus2.x == directrix) then
		print ('special case: same x by f1, f2 and directrix')
		y = (focus1.y + focus2.y) / 2
		x = 0
		return x, y
	elseif (focus1.x == focus2.x) then
-- Parabolas are symmetric, intersection is the midpoint on the y-axis.
		print ('intersectParabolasV, same x:'..focus1.x, 'y1:'..focus1.y, 'y2:'..focus1.y)
		y = (focus1.y + focus2.y) / 2
	elseif (focus2.x == directrix) then
-- Second parabola is vertical, intersection is its y-coordinate.
		y = focus2.y
	elseif (focus1.x == directrix) then
-- First parabola is vertical, intersection is its y-coordinate.
		y = focus1.y
--		currentFocus = {x = focus2.x, y = focus2.y}
		currentFocus = focus2
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
--Extend each remaining segment to the new parabola intersectParabolasVs.
	for arc in dVoronoi.beachline.nextNode, dVoronoi.beachline do
		if arc.rightSegm then
			local x, y = self:intersectParabolasV(arc, arc.next, rightDoubleBoundary)
			arc.rightSegm.endPoint = {x = x, y = y}
			arc.rightSegm.done = true
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
local function comparePoints(p1, p2)
	if p1.x == p2.x then
		return p1.y < p2.y
	else
		return p1.x < p2.x
	end
end
--]]

-- horizontal  directix
local function comparePoints(p1, p2)
	if p1.y == p2.y then
		-- left to right
		return p1.x < p2.x
	else
--		from top to bottom
		return p1.y < p2.y
	end
end

function Tools:sortThePoints(points)
	table.sort(points, comparePoints)
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
--	comparePointsClockwise(points)

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


local function dotProductLineTangentPoint (x, y, tx, ty, px, py)
-- x,y - starting point of line
-- tx, ty - normalized tangent vector of line
-- px, py - point to check
--	return tx * (px - x) + ty * (py - y)
	return ty * (px - x) + tx * (py - y)
end

local function isVertexInBoundary(x, y, frameX, frameY, frameW, frameH)
	return x >= frameX and x <= frameX + frameW and y >= frameY and y <= frameY + frameH
end

local function isVertexOnBoundary(x, y, frameX, frameY, frameW, frameH)
	-- ! exactly on boundry !
	local onX = ((x == frameX) or (x == frameX + frameW)) and (y >= frameY) and (y <= frameY + frameH)
	local onY = ((y == frameY) or (y == frameY + frameH)) and x >= frameX and x <= frameX + frameW
--	print ('isVertexOnBoundary', x, y)
--	if onX or onY then
--		print ('onX', tostring (onX), 'onY', tostring (onY))
--	end
	return onX or onY
end

local function isPointInBoundary(point, frameX, frameY, frameW, frameH)
	return isVertexInBoundary(point.x, point.y, frameX, frameY, frameW, frameH)
end

local function isSegmentInBoundary(segment, frameX, frameY, frameW, frameH)
	local startPointInside = isVertexInBoundary(segment.startPoint, frameX, frameY, frameW, frameH)
	local endPointInside = isVertexInBoundary(segment.endPoint, frameX, frameY, frameW, frameH)

	return startPointInside and endPointInside
end


local function findIntersectionWithVerticalLine(x1, y1, x2, y2, x)
	local t = (x - x1) / (x2 - x1)
	local y = y1 + t * (y2 - y1)
	return x, y
end

local function findIntersectionWithHorizontalLine(x1, y1, x2, y2, y)
	local t = (y - y1) / (y2 - y1)
	local x = x1 + t * (x2 - x1)
	return x, y
end


local function findCrossingLineTangentSegment(bx, by, tx, ty, p1, p2)

	if tx == 0 then

		local x, y = findIntersectionWithVerticalLine(p1.x, p1.y, p2.x, p2.y, bx)
--		print ('cross with vertical')
		return x, y
	elseif ty == 0 then
		local x, y = findIntersectionWithHorizontalLine(p1.x, p1.y, p2.x, p2.y, by)
--		print ('cross with horizontal')
		return x, y
	else
		print ('!!!!!!!!!!!!!!!!!!!!wrong tx, ty', tx, ty)
--		local u = ((p2.x - p1.x) * ty + (p1.y - by) * tx) / (tx * (p1.y - p2.y) + ty * (p2.x - p1.x))
		local u = dotProductLineTangentPoint(bx, by, tx, ty, p1) / dotProductLineTangentPoint(bx, by, tx, ty, p1, p2)

		local cx = p1.x + u * (p2.x - p1.x)
		local cy = p1.y + u * (p2.y - p1.y)
		return cx, cy
	end
end



function Tools:cropBoundarySegments ( dVoronoi, frameX, frameY, frameW, frameH)
	local halfPlanes = {
--		 halfplane as starting point and tangent
		{frameX, frameY, -1, 0}, -- y < frameY
		{frameX + frameW, frameY, 0, 1},  -- x > frameX + frameW
		{frameX + frameW, frameY+frameH, 1, 0}, -- y > frameY + frameH
		{frameX, frameY+frameH, 0, -1}, -- x < frameX
	}

	for _, segment in ipairs(dVoronoi.segments) do
		for indexHP, hp in ipairs (halfPlanes) do
			local bx, by, tx, ty = hp[1], hp[2], hp[3], hp[4]
			local p1 = segment.startPoint
			local p2 = segment.endPoint
			local d1 = dotProductLineTangentPoint (bx, by, tx, ty, p1.x, p1.y)
			local d2 = dotProductLineTangentPoint (bx, by, tx, ty, p2.x, p2.y)

			if (d1 > 0 and d2 < 0) then
				local cx, cy = findCrossingLineTangentSegment (bx, by, tx, ty, p1, p2)
				if isVertexOnBoundary(cx, cy, frameX, frameY, frameW, frameH) then
--					table.insert (specialCaseSectors, {p2.x, p2.y, cx, cy})
					p1.x = cx
					p1.y = cy
					table.insert (dVoronoi.vertex, newPoint (cx, cy))
				end
			elseif (d1 < 0 and d2 > 0) then
				local cx, cy = findCrossingLineTangentSegment (bx, by, tx, ty, p1, p2)
--				print ('start', 'd1', d1, 'd2', d2)
				if isVertexOnBoundary(cx, cy, frameX, frameY, frameW, frameH) then
--					table.insert (specialCaseSectors, {p1.x, p1.y, cx, cy})
					p1.x = cx
					p1.y = cy
					table.insert (dVoronoi.vertex, newPoint (cx, cy))
				end
			end
		end
	end
end

function Tools:filterSegments(dVoronoi, frameX, frameY, frameW, frameH)
	local segments = dVoronoi.segments
	local i = #segments

	while i > 0 do
--		print ('segment', i)
		local segment = segments[i]
		local p1, p2 = segment.startPoint, segment.endPoint
		local minx, maxx = math.min(p1.x, p2.x), math.max(p1.x, p2.x)
		local miny, maxy = math.min(p1.y, p2.y), math.max(p1.y, p2.y)

		if maxx < frameX or minx > frameX + frameW or maxy < frameY or miny > frameY + frameH then
			print ('segment removed')
			table.remove(segments, i)
		end
		i = i - 1
	end
end


local function filterPoints (points, minx, miny, maxx, maxy)
	local filteredPoints = {}
	local frameW, frameH = maxx-minx, maxy-miny
	for _, point in ipairs(points) do
		if isVertexInBoundary(point.x, point.y, minx, miny, frameW, frameH) then
			table.insert(filteredPoints, point)
		else
			print ('removed point', point.x, point.y)
		end
	end
	return filteredPoints
end



function Tools:dirtyPolygon ( dVoronoi )
	local minx, miny = dVoronoi.boundary[1], dVoronoi.boundary[2]
	local maxx, maxy = dVoronoi.boundary[3], dVoronoi.boundary[4]

	local polygonList = {}
	local processingPoints = dVoronoi.vertex

	table.sort(processingPoints, comparePoints)
	processingPoints = filterPoints (processingPoints, minx, miny, maxx, maxy)


	local cornerPoints = {
		newPoint (minx, miny),
		newPoint (minx, maxy),
		newPoint (maxx, miny),
		newPoint (maxx, maxy),
	}

	for _, point in ipairs(cornerPoints) do
		table.insert(processingPoints,point) 
	end

	for i, point in pairs(processingPoints) do
		local distances = {}
		for siteIndex, sitePoint in ipairs(dVoronoi.sitePoints) do
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
			if comparePoints (p1, p2) then
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
		dVoronoi.polygons[i] = Polygon:new(vertices, i)
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





----------------
----------------
----------------


local voronoilib = { }




local function getRVoronoi (sitePoints, frameX,frameY, frameW, frameH)

	-- magic value!
	local rightDoubleBoundary = 2*(2*frameW - frameX + frameH-frameY)

	local dVoronoi = {}
	dVoronoi.sitePoints = sitePoints
	dVoronoi.boundary = {frameX, frameY, frameX+frameW, frameY+frameH}

	dVoronoi.vertex = { }
	dVoronoi.segments = { }
	dVoronoi.eventsHeap = HHeap:new()
	dVoronoi.beachline = DoubleLinkedList:new()
	dVoronoi.polygons = { }
	dVoronoi.polygonMap = { }


-- sets up the dVoronoi events
	for i, sitePoint in ipairs (sitePoints) do
		dVoronoi.eventsHeap:push(sitePoint, sitePoint.x, {i})
	end

	local index = 0
	while not dVoronoi.eventsHeap:isEmpty() do
		index = index + 1
		local event = dVoronoi.eventsHeap:pop()
		print ('\n	-----event '.. index..' '..(event.arc~=nil and "circle" or "point"))

		if event.arc then
			if event.valid then
				table.insert (specialCaseCircle, {event.x, event.y, event.radius, 1})
				Tools:processCircle(dVoronoi, event)
			end
--			print ('beachline:length', dVoronoi.beachline:length())
			dVoronoi.beachline:showContents()
			print ('# end of cirlce event\n')

		else
			Tools:processPoint(dVoronoi, event)
--			print ('beachline:length', dVoronoi.beachline:length())
			dVoronoi.beachline:showContents()
			print ('# end of point event\n')

		end 


	end


	Tools:finishEdges(dVoronoi, rightDoubleBoundary)



	Tools:cropBoundarySegments (dVoronoi, frameX,frameY, frameW, frameH)
	Tools:filterSegments (dVoronoi, frameX,frameY, frameW, frameH)



	Tools:dirtyPolygon(dVoronoi)

	return dVoronoi
end

--local function generatePoints (polygoncount,iterations,minx,miny,maxx,maxy)
local function generateSitePoints (polygoncount, minx,miny, maxx,maxy)
	local sitePoints = {}
	for _ = 1, polygoncount do
		local x,y = Tools:randomPoint(minx,miny,maxx,maxy)
		while Tools:tableContains(sitePoints, { 'x', 'y' }, { x, y }) do
			x,y = Tools:randomPoint (minx,miny,maxx,maxy)
		end
		local point = { x = x, y = y }
		table.insert (sitePoints, point)
	end
	return sitePoints
end

local function newSite (x, y, minX, minY, maxX, maxY)
	if x > minX and x < maxX and y > minY and y < maxY then
		local site = newPoint (x, y)
		site.site = true
		return site
	end
end

function voronoilib:newDiagram(siteVertices, frameX,frameY, frameW, frameH)
	local sitePoints = {}
	local safe = 5
	local minX, minY = frameX+safe, frameY+safe
	local maxX, maxY = frameX+frameW-safe, frameY+frameH-safe

	for i = 1, #siteVertices-1, 2 do
		local x = siteVertices[i]
		local y = siteVertices[i+1]
		local sitePoint = newSite (x, y, minX, minY, maxX, maxY)
		table.insert (sitePoints, sitePoint)
	end

	local dVoronoi = getRVoronoi (sitePoints, frameX,frameY, frameW, frameH)

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
	local genvoronoi = self:newDiagram(sites, minx,miny,maxx,maxy)
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
	for index, sitePoint in pairs(self.sitePoints) do
		local dx = x - sitePoint.x
		local dy = y - sitePoint.y
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

--Tools.polygon = Polygon

--voronoilib.HHeap = HHeap
--voronoilib.Tools = Tools
--voronoilib.DoubleLinkedList = DoubleLinkedList

return voronoilib