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

-- https://github.com/TomK32/iVoronoi/tree/working


]]--

--------
--------
--------

local constants = {zero = 0.1}

--------
--------
--------

local HHeap = {}
function HHeap:new()
	local o = { Heap = {}, nodes = {} }
	setmetatable(o, self)
	self.__index = self
	return o
end

function HHeap:push(k, v)
	assert(v ~= nil, "cannot push nil")
	local Heap_pos = #self.Heap + 1
	self.Heap[Heap_pos] = k
	self.nodes[k] = v
	while Heap_pos > 1 do
		local parent_pos = math.floor(Heap_pos / 2)
		if self.nodes[self.Heap[parent_pos]] > v then
			self.Heap[parent_pos], self.Heap[Heap_pos] = self.Heap[Heap_pos], self.Heap[parent_pos]
			Heap_pos = parent_pos
		else
			break
		end
	end
	return k
end

function HHeap:pop()
	local Heap_pos = #self.Heap
	assert(Heap_pos > 0, "cannot pop from empty Heap")
	local Heap_root = self.Heap[1]
	local Heap_root_pos = self.nodes[Heap_root]
	local current_Heap = self.nodes[self.Heap[Heap_pos]]
	self.Heap[1] = self.Heap[Heap_pos]
	self.Heap[Heap_pos] = nil
	self.nodes[Heap_root] = nil
	Heap_pos = Heap_pos - 1
	local node_pos = 1
	while true do
		local parent_pos = 2 * node_pos
		if Heap_pos < parent_pos then
			break
		end
		if parent_pos < Heap_pos and self.nodes[self.Heap[parent_pos + 1]] < self.nodes[self.Heap[parent_pos]] then
			parent_pos = parent_pos + 1
		end
		if self.nodes[self.Heap[parent_pos]] < current_Heap then
			self.Heap[parent_pos], self.Heap[node_pos] = self.Heap[node_pos], self.Heap[parent_pos]
			node_pos = parent_pos
		else
			break
		end
	end
	return Heap_root, Heap_root_pos
end

function HHeap:isEmpty()
	return not next(self.Heap)
end

--------
--------
--------

local doubleLinkedList = {}

function doubleLinkedList:new()
	local o = {first = nil, last = nil} -- empty list head
	setmetatable(o, self)
	self.__index = self
	return o
end

function doubleLinkedList:insertAfter(node, data)
	local new = {prev = node, next = node.next, x = data.x, y = data.y} -- creates a new node
	node.next = new
	if node == self.last then
		self.last = new
	else
		new.next.prev = new
	end
	return new 
end

function doubleLinkedList:insertAtStart(data)
	local new = {prev = nil, next = self.first, x = data.x, y = data.y} -- create the new node
	if not self.first then -- check if the list is empty
		self.first = new -- the new node is the first and the last in this case
		self.last = new
	else
		self.first.prev = new
		self.first = new
	end
	return new
end

function doubleLinkedList:delete(node)
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

function doubleLinkedList:nextNode(node)
	return (not node and self.first) or node.next
end

--------
--------
--------

local Tools = { }
function Tools:processEvent(event, ivoronoi)
	if event.valid then
--		startPoint, endPoint
		local segment = {
			startPoint = {x = event.x, y = event.y},
			endPoint = {x = 0, y = 0},
			done = false,
			type = 1
		}
		table.insert(ivoronoi.segments, segment)

		-- Remove the associated arc from the front and update segment info
		ivoronoi.beachline:delete(event.arc)

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
		local v = {x = event.x, y = event.y}
		table.insert(ivoronoi.vertex, v)
		if event.arc.prev then
			self:check_circle_event(event.arc.prev, event.x, ivoronoi)
		end

		if event.arc.next then
			self:check_circle_event(event.arc.next, event.x, ivoronoi)
		end
	end
end


function Tools:processPoint(point,ivoronoi)
	--Adds a point to the beachline
	--local intersect = self:intersect
	if not ivoronoi.beachline.first then
		ivoronoi.beachline:insertAtStart(point)
		return
	end

	--Find the current arc(s) at height p.y (if there are any).
	for arc in ivoronoi.beachline.nextNode, ivoronoi.beachline do 

		local z = self:intersect(point, arc)
		if z then
			--New parabola intersects arc i.  If necessary, duplicate i.
			-- ie if there is a next node, but there is not interation, then creat a duplicate
			if not (arc.next and self:intersect(point, arc.next)) then
				ivoronoi.beachline:insertAfter(arc, arc)
			else
				return
			end

			arc.next.seg1 = arc.seg1

			--Add p between i and i->next.
			ivoronoi.beachline:insertAfter(arc, point)


			local segment = {startPoint = {x = z.x, y = z.y}, endPoint = {x = 0, y = 0}, done = false, type = 2}
			local segment2 = {startPoint = {x = z.x, y = z.y}, endPoint = {x = 0, y = 0}, done = false, type = 2}

			-- debugging segment list!!!
			table.insert(ivoronoi.segments, segment)
			table.insert(ivoronoi.segments, segment2)


			--Add new half-edges connected to i's endpoints.
			arc.next.seg0 = segment
			arc.seg1 = segment

			arc.next.seg1 = segment2
			arc.next.next.seg0 = segment2

			--Check for new circle events around the new arc:
			self:check_circle_event(arc, point.x, ivoronoi)
--			self:check_circle_event(arc.next, point.x, ivoronoi)
			self:check_circle_event(arc.next.next, point.x, ivoronoi)
			return
		end    
	end


	--Special case: If p never intersects an arc, append it to the list.
	ivoronoi.beachline:insertAtStart(point)

	local lastNode = ivoronoi.beachline.last
	local segment = {
		startPoint = {x = ivoronoi.boundary[1], y = (lastNode.y + lastNode.prev.y) / 2},
		endPoint = {x = 0, y = 0},
		done = false,
		type = 3
	}

	table.insert(ivoronoi.segments, segment)

	lastNode.seg0 = segment
	lastNode.prev.seg1 = segment
end



function Tools:check_circle_event(arc, x0, ivoronoi)
	--Look for a new circle event for arc i.
	--Invalidate any old event.

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
	end

	--Point o is the center of the circle.
	local o = {}
	o.x = (D*E-B*F)/G
	o.y = (A*F-C*E)/G

	--o.x plus radius equals max x coordinate.
	local x = o.x + math.sqrt( math.pow(a.x - o.x, 2) + math.pow(a.y - o.y, 2) )

	if x and x > x0 then
		--Create new event.
		arc.event = {x = o.x, y = o.y, arc = arc, valid = true, event = true }
		ivoronoi.events:push(arc.event, x)
	end
end



function Tools:intersect(point, arc)
	--Will a new parabola at point p intersect with arc i?
	local res = {}
	if (arc.x == point.x) then 
		return false 
	end

	if (arc.prev) then
		--Get the interSectionTool of i->prev, i.
		a = self:interSectionTool(arc.prev, arc, point.x).y
	end    
	if (arc.next) then
		--Get the interSectionTool of i->next, i.
		b = self:interSectionTool(arc, arc.next, point.x).y
	end    
	--print("intersect", a,b,p.y)
	if (( not arc.prev or a <= point.y) and (not arc.next or point.y <= b)) then
		res.y = point.y
		-- Plug it back into the parabola equation.
		res.x = (arc.x*arc.x + (arc.y-res.y)*(arc.y-res.y) - point.x*point.x) / (2*arc.x - 2*point.x)
		return res
	end
	return false
end


function Tools:interSectionTool(p0, p1, l)
	-- Where do two parabolas intersect?

	local res = {}
	local p = {x = p0.x, y = p0.y}

	if (p0.x == p1.x) then
		res.y = (p0.y + p1.y) / 2
	elseif (p1.x == l) then
		res.y = p1.y
	elseif (p0.x == l) then
		res.y = p0.y
		p = p1
	else
		-- Use the quadratic formula.
		local z0 = 2*(p0.x - l);
		local z1 = 2*(p1.x - l);

		local a = 1/z0 - 1/z1;
		local b = -2*(p0.y/z0 - p1.y/z1);
		local c = (p0.y*p0.y + p0.x*p0.x - l*l)/z0 - (p1.y*p1.y + p1.x*p1.x - l*l)/z1
		res.y = ( -b - math.sqrt(b*b - 4*a*c) ) / (2*a)
	end

	-- Plug back into one of the parabola equations.
	res.x = (p.x*p.x + (p.y-res.y)*(p.y-res.y) - l*l)/(2*p.x-2*l)
	return res
end

function Tools:finishEdges(ivoronoi, rightDoubleBoundary)
	--Extend each remaining segment to the new parabola interSectionTools.
	for arc in ivoronoi.beachline.nextNode, ivoronoi.beachline do
		if arc.seg1 then
			local p = self:interSectionTool(arc, arc.next, rightDoubleBoundary)
			arc.seg1.endPoint = {x = p.x, y = p.y}
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

function Tools:sortThePoints(points)
--	print ('tables', table.concat (points, ','))
	local sortedpoints = self:sorttable(points,'x',true)
	sortedpoints = self:sorttable(sortedpoints,'y',true)
	return sortedpoints
end

function Tools:tableContains(tablename,attributename,value)
	if attributename == nil then
		for i,v in pairs(tablename) do
			if v == value then return true end
		end
	elseif type(attributename) == 'table' then
		for i,v in pairs(tablename) do
			local match = 0
			for j,v2 in pairs(attributename) do
				if v[v2] == value[j] then match = match + 1 end
			end
			if match == #attributename then return true end
		end
	else
		for i,v in pairs(tablename) do
			if v[attributename] == value then return true end
		end
	end
	return false

end



function Tools:polygonCentroid(listofpoints)
	-- formula here http://en.wikipedia.org/wiki/Centroid#Centroid_of_Polygon
	local A = 0
	for i = 1,#listofpoints,2 do
		--print('point',listofpoints[i],listofpoints[i+1])
		if i > #listofpoints-2 then
			A = A + listofpoints[i]*listofpoints[2] - listofpoints[1]*listofpoints[i+1]
		else
			A = A + listofpoints[i]*listofpoints[i+3] - listofpoints[i+2]*listofpoints[i+1]
		end
	end
	A = 0.5 * A

	local cx = 0
	for i = 1, #listofpoints,2 do
		if i > #listofpoints-2 then
			cx = cx + (listofpoints[i]+listofpoints[1])*(listofpoints[i]*listofpoints[2] - listofpoints[1]*listofpoints[i+1])
		else
			cx = cx + (listofpoints[i]+listofpoints[i+2])*(listofpoints[i]*listofpoints[i+3] - listofpoints[i+2]*listofpoints[i+1])
		end
	end
	cx = cx / (6*A)

	local cy = 0
	for i = 1, #listofpoints,2 do
		if i > #listofpoints-2 then
			cy = cy + (listofpoints[i+1]+listofpoints[2])*(listofpoints[i]*listofpoints[2] - listofpoints[1]*listofpoints[i+1])
		else
			cy = cy + (listofpoints[i+1]+listofpoints[i+3])*(listofpoints[i]*listofpoints[i+3] - listofpoints[i+2]*listofpoints[i+1])
		end
	end
	cy = cy / (6*A)
	--print('cx',cx,'cy',cy,'A',A)

--	cx = math.floor (cx+0.5)
--	cy = math.floor (cy+0.5)

	return cx,cy
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



function Tools:sortpolydraworder(listofpoints)
	local centroidX, centroidY = 0, 0
	local pointCount = #listofpoints

	-- Calculate the centroid of the polygon
	for _, point in pairs(listofpoints) do
		centroidX = centroidX + point.x
		centroidY = centroidY + point.y
	end

	-- Calculate and set the angle of each point with respect to the centroid
	for _, point in pairs(listofpoints) do
		point.angle = math.atan2(point.y - centroidY/ pointCount, point.x - centroidX/ pointCount)
	end

	-- Sort the points by angle
	listofpoints = self:sorttable(listofpoints, 'angle', true)

	local returner
	for _, point in pairs(listofpoints) do
		if not returner then
			returner = {point.x, point.y}
		else
			if (math.abs(returner[#returner - 1] - point.x) < constants.zero) 
			and (math.abs(returner[#returner] - point.y) < constants.zero) then
				-- Duplicate point, so do nothing
			else
				table.insert(returner, point.x)
				table.insert(returner, point.y)
			end
		end
	end

	return returner
end


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

function Tools:isSegmentIntersect(line1,groupoflines)
	-- checks if the line segment intersects any of the line segments in the group of lines

	local timestrue = 0
	local timesfalse = 0
	local checkset = { }

	for index,line2 in pairs(groupoflines) do
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

function Tools:isOnLine(x, y, line)
	-- checks if the point is on the line
	local xWithinBounds = (line[1] <= x and x <= line[3]) or (line[3] <= x and x <= line[1])
	local yWithinBounds = (line[2] <= y and y <= line[4]) or (line[4] <= y and y <= line[2])
	local isEndpoint = (line[1] == x and line[2] == y) or (line[3] == x and line[4] == y)
	return xWithinBounds and yWithinBounds and not isEndpoint
end


function Tools:round(num, idp)
	--http://lua-users.org/wiki/SimpleRound
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------

-- Проверка совпадения направления сегментов
local function sameDirection(segment1, segment2)
	local dx1, dy1 = segment1.endPoint.x - segment1.startPoint.x, segment1.endPoint.y - segment1.startPoint.y
	local dx2, dy2 = segment2.endPoint.x - segment2.startPoint.x, segment2.endPoint.y - segment2.startPoint.y

	return math.abs(math.atan2 (dy1, dx1) - math.atan2 (dy2, dx2)) < constants.zero
	or 	math.abs(math.atan2 (dy1, dx1) - math.atan2 (-dy2, -dx2)) < constants.zero
end

-- Проверка совпадения точек
local function samePoint(point1, point2)
	return math.abs (point1.x - point2.x) < constants.zero and math.abs (point1.y - point2.y) < constants.zero
end

-- Проверка, что сегменты не соединены с другими сегментами
local function connectionOther(segments, segment1, segment2)
	for _, segment in ipairs(segments) do
		if segment ~= segment1 and segment ~= segment2 then
			if samePoint(segment1.endPoint, segment.startPoint) 
			or samePoint(segment2.startPoint, segment.endPoint) then
				return true
			end
		end
	end
	return false
end

-- Объединение двух сегментов
local function mergeSegment(segment1, segment2)
	segment1.startPoint = segment1.endPoint
	segment1.endPoint = segment2.endPoint
end

local function removeSegment(segments, segment)
	for i, seg in ipairs(segments) do
		if seg == segment then
			table.remove(segments, i)
			break
		end
	end
end

local function cleanSegments(segments)
	local tempSegments = {}
	for i, segment1 in ipairs(segments) do
		for j, segment2 in ipairs(segments) do
			if i ~= j 
			and sameDirection(segment1, segment2) 
			and samePoint(segment1.startPoint, segment2.startPoint) 
--			and not connectionOther(segments, segment1, segment2) 
			then
				mergeSegment(segment1, segment2)
				removeSegment(segments, segment2)
				break
			end
		end
		table.insert (tempSegments, segment1)
	end
	return tempSegments
end

------------------------------------------------------
------------------------------------------------------
------------------------------------------------------

function Tools:dirtyPolygon ( invoronoi )
	local minx, miny = invoronoi.boundary[1], invoronoi.boundary[2]
	local maxx, maxy = invoronoi.boundary[3], invoronoi.boundary[4]
	local polygon = {}
	local processingpoints = invoronoi.vertex
	for i = #processingpoints, 1, -1 do
		if (processingpoints[i].x < minx) 
		or (processingpoints[i].x > maxx) 
		or (processingpoints[i].y < miny) 
		or (processingpoints[i].y > maxy) then
			processingpoints[i] = nil
		end
	end

	-- adds other points that are not in the vertexes, like the corners and interSectionTools with the boundary
	local otherpoints = {
		{ x = minx, y = miny },
		{ x = minx, y = maxy },
		{ x = maxx, y = miny },
		{ x = maxx, y = maxy }
	}

	local boundaries = {
		{ minx, miny, minx, maxy },  -- left boundary
		{ maxx, miny, maxx, maxy },  -- right boundary
		{ minx, miny, maxx, miny },  -- top boundary
		{ minx, maxy, maxx, maxy }  -- bottom boundary
	}

	print ('was #invoronoi.segments', #invoronoi.segments)
	invoronoi.segments = cleanSegments (invoronoi.segments)
	print ('now #invoronoi.segments', #invoronoi.segments)

	for i, segment in pairs(invoronoi.segments) do
		local isects = { }
		local removetheline = false

		for i, boundary in ipairs(boundaries) do
			if (segment.startPoint.x < boundary[1] or segment.endPoint.x < boundary[1])
			or (segment.startPoint.x > boundary[3] or segment.endPoint.x > boundary[3])
			or (segment.startPoint.y < boundary[2] or segment.endPoint.y < boundary[2])
			or (segment.startPoint.y > boundary[4] or segment.endPoint.y > boundary[4]) then
				removetheline = true
				local px, py, onlines = self:intersectionPoint(boundary, {segment.startPoint.x, segment.startPoint.y, segment.endPoint.x, segment.endPoint.y})
				isects[#isects+1] = { x=px, y=py, on=onlines }

				local segment1 = {startPoint = segment.startPoint, endPoint = {x=px, y=py}}

--				table.insert (invoronoi.segments, segment1)
--				table.insert (invoronoi.segments, segment2)
			end
		end

		for index,ise in pairs(isects) do 
			if ise.on then 
				otherpoints[#otherpoints+1] = { x = ise.x, y = ise.y }  
			end 
		end
	end



	for i,v in pairs(otherpoints) do 
		table.insert(processingpoints,v) 
	end

	for _, point in pairs(processingpoints) do
		local distances = {}

		for rindex, ranpoint in pairs(invoronoi.points) do
			distances[#distances + 1] = { 
				i = rindex, 
				dsqr = ((point.x - ranpoint.x)^2 + (point.y - ranpoint.y)^2) 
			}
		end

		distances = self:sorttable(distances, 'dsqr', true)
		local mindistance = distances[1].dsqr
		local related = {}
		for _, distInfo in ipairs(distances) do
			if distInfo.dsqr - mindistance < constants.zero then
				local polyIndex = distInfo.i
				local poly = polygon[polyIndex] or {}
				poly[#poly + 1] = { x = point.x, y = point.y }
				polygon[polyIndex] = poly

				related[#related + 1] = polyIndex
			end
		end

		for _, indexA in ipairs(related) do
			if not invoronoi.polygonMap[indexA] then
				invoronoi.polygonMap[indexA] = {}
			end

			for _, indexB in ipairs(related) do
				if indexA ~= indexB and not self:tableContains(invoronoi.polygonMap[indexA], nil, indexB) then
					invoronoi.polygonMap[indexA][#invoronoi.polygonMap[indexA] + 1] = indexB
				end
			end
		end
	end

	

	for i, points in ipairs(polygon) do
		invoronoi.polygons[i] = self.polygon:new(self:sortpolydraworder(points), i)
	end


end

---------------------------------------------
-- generates randomPoints
function Tools:randomPoint(minx,miny,maxx,maxy)
	local x = math.random(minx+1,maxx-1) 
	local y = math.random(miny+1,maxy-1)
	return x,y 
end

----------------------------------------------
-- checks if the line segment is the same
function Tools:sameEdge(line1,line2)

	local l1p1 = { x = line1[1], y = line1[2] }
	local l1p2 = { x = line1[3], y = line1[4] }
	local l2p1 = { x = line2[1], y = line2[2] }
	local l2p2 = { x = line2[3], y = line2[4] }

	local l1,l2 = { }, { }

	if (l1p1.x == l1p2.x) then
		if (l1p1.y < l1p2.y) then 
			l1 = { l1p1.x,l1p1.y,l1p2.x,l1p2.y }
		else 
			l1 = { l1p2.x,l1p2.y,l1p1.x,l1p1.y } 
		end
	elseif (l1p1.x < l1p2.x) then 
		l1 = { l1p1.x,l1p1.y,l1p2.x,l1p2.y  }
	else 
		l1 = { l1p2.x,l1p2.y,l1p1.x,l1p1.y } 
	end

	if (l2p1.x == l2p2.x) then
		if (l2p1.y < l2p2.y) then 
			l2 = { l2p1.x,l2p1.y,l2p2.x,l2p2.y }
		else 
			l2 = { l2p2.x,l2p2.y,l2p1.x,l2p1.y } 
		end
	elseif (l2p1.x < l2p2.x) then 
		l2 = { l2p1.x,l2p1.y,l2p2.x,l2p2.y  }
	else 
		l2 = { l2p2.x,l2p2.y,l2p1.x,l2p1.y } 
	end

	if (math.abs(l1[1] - l2[1]) < constants.zero) and (math.abs(l1[2] - l2[2]) < constants.zero)
	and (math.abs(l1[3] - l2[3]) < constants.zero) and (math.abs(l1[4] - l2[4]) < constants.zero) then
		return true
	end

	return false
end

--------
--------
--------

local Polygon = { }

function Polygon:new(points, index)
	-- creates the edges
	local edges = {}
	local edge = {points[#points-1], points[#points], points[1], points[2]}
	table.insert (edges, edge)

	for i=1, #points-2, 2 do
		edge = {points[i], points[i+1], points[i+2], points[i+3]}
		table.insert (edges, edge)
	end

	local poly = {
		points = points,
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
	for i, edge in ipairs (self.edges) do
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
local function getRVoronoi (points, minx,miny,maxx,maxy)
	local rightDoubleBoundary = 2*(maxx + (maxx-minx) + (maxy-miny))
--	print ('rightDoubleBoundary', rightDoubleBoundary)
	local boundary = { minx,miny,minx+maxx,miny+maxy }
	local rvoronoi = {}
	rvoronoi.points = points
	rvoronoi.boundary = boundary

	rvoronoi.vertex = { }
	rvoronoi.segments = { }
	rvoronoi.events = HHeap:new()
	rvoronoi.beachline = doubleLinkedList:new()
	rvoronoi.polygons = { }
	rvoronoi.polygonMap = { }
	rvoronoi.centroids = { }


	-- sets up the rvoronoi events
	for i = 1,#points do
		rvoronoi.events:push(points[i], points[i].x,{i})
	end

	while not rvoronoi.events:isEmpty() do
		local e, x = rvoronoi.events:pop()
		if e.event then
			Tools:processEvent(e,rvoronoi)
		else
			Tools:processPoint(e,rvoronoi)
		end    
	end


	Tools:finishEdges(rvoronoi, rightDoubleBoundary)

--	rvoronoi.segments = {}
	Tools:dirtyPolygon(rvoronoi)

	for i, polygon in pairs(rvoronoi.polygons) do
		local points = polygon.points
		local cx, cy = Tools:polygonCentroid(points)
		rvoronoi.centroids[i] = { x = cx, y = cy }
		rvoronoi.polygons[i].centroid = rvoronoi.centroids[i] -- creating a link between the two tables
	end

	return rvoronoi
end

--local function generatePoints (polygoncount,iterations,minx,miny,maxx,maxy)
local function generatePoints (polygoncount, minx,miny, maxx,maxy)
	local points = {}
	for i=1,polygoncount do
		local rx,ry = Tools:randomPoint(minx,miny,maxx,maxy)
		while Tools:tableContains(points,{ 'x', 'y' }, { rx, ry }) do
			rx,ry = Tools:randomPoint(minx,miny,maxx,maxy)
		end
		local point = { x = rx, y = ry }
		table.insert (points, point)
	end
	points = Tools:sortThePoints(points)
	return points
end

--function voronoilib:new(polygoncount,iterations,minx,miny,maxx,maxy)
function voronoilib:new(polygoncount, minx,miny,maxx,maxy)
--	local points = generatePoints (polygoncount,iterations,minx,miny,maxx,maxy)
	local points = generatePoints (polygoncount, minx,miny,maxx,maxy)
	local str = ''
	for i, p in ipairs (points) do
		str = str..p.x..','..p.y..', '
	end
	print ('{'..str..'}')

--	local genvoronoi = getRVoronoi (points,iterations,minx,miny,maxx,maxy)
	local genvoronoi = getRVoronoi (points, minx,miny,maxx,maxy)
	setmetatable(genvoronoi, self) 
	self.__index = self 
	return genvoronoi
end

------------------------------------------------
-- returns the actual polygons that are the neighbors
function voronoilib:getNeighborsSingle(polygon)
	local index = polygon.index
	local neighbors = {}
	for i, indexNeighbour in pairs (self.polygonMap[index]) do
		local neighbor = self.polygons[indexNeighbour]
		table.insert (neighbors, neighbor)
	end
	return neighbors
end


function voronoilib:polygonContains(x, y)
	local closestPolygon = nil
	local minDistance = math.huge
	for index, centroid in pairs(self.centroids) do
		local dx = x - centroid.x
		local dy = y - centroid.y
		local dsqr = (dx * dx + dy * dy)
		if dsqr < minDistance then
			minDistance = dsqr
			closestPolygon = self.polygons[index]
		end
	end
	if closestPolygon:containsPoint (x, y) then
		return closestPolygon
	end
end

local function distanceToSegment(x, y, x1, y1, x2, y2)
	local dx, dy = x2 - x1, y2 - y1
	local l2 = dx * dx + dy * dy

	if l2 == 0 then
		return math.sqrt((x - x1)^2 + (y - y1)^2)
	end

	local t = ((x - x1) * dx + (y - y1) * dy) / l2

	if t < 0 then
		return math.sqrt((x - x1)^2 + (y - y1)^2)
	elseif t > 1 then
		return math.sqrt((x - x2)^2 + (y - y2)^2)
	end

	local projectionX, projectionY = x1 + t * dx, y1 + t * dy
	return ((x - projectionX)^2 + (y - projectionY)^2)
end


function voronoilib:edgeContains(x, y, minDistance)
	local closestEdge = nil
	minDistance = minDistance or math.huge
	local found = false

	for i, edge in pairs(self.segments) do
		local x1, y1 = edge.startPoint.x, edge.startPoint.y
		local x2, y2 = edge.endPoint.x, edge.endPoint.y
		local dsqr = distanceToSegment(x, y, x1, y1, x2, y2)
		if dsqr < minDistance then
			minDistance = dsqr
			closestEdge = edge
			found = true
--			print ('found')
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

voronoilib.Heap = Heap
voronoilib.Tools = Tools
voronoilib.doubleLinkedList = doubleLinkedList

return voronoilib