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

]]--

--------
--------
--------

local constants = {zero = 0.1}

--------
--------
--------

local heap = {}

function heap:new()
	local o = { heap = {}, nodes = {} }
	setmetatable(o, self)
	self.__index = self
	return o
end

function heap:push(k, v)
	assert(v ~= nil, "cannot push nil")
	local heap_pos = #self.heap + 1
	self.heap[heap_pos] = k
	self.nodes[k] = v

	while heap_pos > 1 do
		local parent_pos = math.floor(heap_pos / 2)
		if self.nodes[self.heap[parent_pos]] > v then
			self.heap[parent_pos], self.heap[heap_pos] = self.heap[heap_pos], self.heap[parent_pos]
			heap_pos = parent_pos
		else
			break
		end
	end

	return k
end

function heap:pop()
	local heap_pos = #self.heap
	assert(heap_pos > 0, "cannot pop from empty heap")

	local heap_root = self.heap[1]
	local heap_root_pos = self.nodes[heap_root]
	local current_heap = self.nodes[self.heap[heap_pos]]

	self.heap[1] = self.heap[heap_pos]
	self.heap[heap_pos] = nil
	self.nodes[heap_root] = nil
	heap_pos = heap_pos - 1

	local node_pos = 1

	while true do
		local parent_pos = 2 * node_pos
		if heap_pos < parent_pos then
			break
		end

		if parent_pos < heap_pos and self.nodes[self.heap[parent_pos + 1]] < self.nodes[self.heap[parent_pos]] then
			parent_pos = parent_pos + 1
		end

		if self.nodes[self.heap[parent_pos]] < current_heap then
			self.heap[parent_pos], self.heap[node_pos] = self.heap[node_pos], self.heap[parent_pos]
			node_pos = parent_pos
		else
			break
		end
	end

	return heap_root, heap_root_pos
end

function heap:isEmpty()
	return not next(self.heap)
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
	node.next = new -- the node after node is the new node
	if node == self.last then -- check if the old node is the last node...
		self.last = new -- ...and set the new node as the last node
	else
		-- otherwise set the next node's previous node to the new one
		new.next.prev = new
	end
	return new -- return the new node
end

function doubleLinkedList:insertAtStart(data)
	local new = {prev = nil, next = self.first, x = data.x, y = data.y} -- create the new node
	if not self.first then -- check if the list is empty
		self.first = new -- the new node is the first and the last in this case
		self.last = new
	else
		-- the node before the old first node is the new first node
		self.first.prev = new
		self.first = new -- update the list's first field
	end
	return new
end

function doubleLinkedList:delete(node)
	if node == self.first then -- check if the node is the first one...
		-- ...and set the new first node if we remove the first
		self.first = node.next
	else
		-- set the previous node's next node to the next node
		node.prev.next = node.next
	end

	if node == self.last then -- check if the node is the last one...
		-- ...the new last node is the node before the deleted node
		self.last = node.prev
	else
		node.next.prev = node.prev -- update the next node's prev field
	end
end

function doubleLinkedList:nextNode(node)
	return (not node and self.first) or node.next
end

--------
--------
--------

local tools = { }
function tools:processEvent(event, ivoronoi)
	if event.valid then
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

		-- Debugging vertex list!!!
		table.insert(ivoronoi.vertex, {x = event.x, y = event.y})

		-- Recheck circle events on either side of p
		if event.arc.prev then
			self:check_circle_event(event.arc.prev, event.x, ivoronoi)
		end

		if event.arc.next then
			self:check_circle_event(event.arc.next, event.x, ivoronoi)
		end
	end
end


function tools:processPoint(point,ivoronoi)
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



function tools:check_circle_event(arc, x0, ivoronoi)
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



function tools:intersect(point, arc)
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


function tools:interSectionTool(p0, p1, l)
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

function tools:finishEdges(ivoronoi, rightDoubleBoundary)


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

function tools:sortthepoints(points)
	local sortedpoints = self:sorttable(points,'x',true)
	sortedpoints = self:sorttable(sortedpoints,'y',true)
	return sortedpoints
end

function tools:tablecontains(tablename,attributename,value)
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

function tools:sortpolydraworder(listofpoints)

	local returner = { }

	-- sorts it assending by y
	table.sort(listofpoints,function (a,b) return a.y < b.y end)

	local unpacked = { }
	for i,point in pairs(listofpoints) do
		unpacked[#unpacked+1] = point.x
		unpacked[#unpacked+1] = point.y
	end

	local midpoint = { self:polyoncentroid(unpacked) }

	local right = { }
	local left = { }

	for i,point in pairs(listofpoints) do
		if point.x < midpoint[1] then 
			left[#left+1] = point
		else 
			right[#right+1] = point
		end
	end

	local tablecount= #left
	for j,point in pairs(left) do
		returner[tablecount+1-j] = point
	end

	for j,point in pairs(right) do
		returner[#returner+1] = point
	end

	unpacked = { }
	for i,point in pairs(returner) do
		if i > 1 then
			if (math.abs(unpacked[#unpacked-1] - point.x) < constants.zero) and (math.abs(unpacked[#unpacked] - point.y) < constants.zero) then
				-- duplicate point, so do nothing
			else
				unpacked[#unpacked+1] = point.x
				unpacked[#unpacked+1] = point.y
			end
		else
			unpacked[#unpacked+1] = point.x
			unpacked[#unpacked+1] = point.y
		end
	end
	returner = unpacked

	return returner
end

function tools:polyoncentroid(listofpoints)
	-- formula here http://en.wikipedia.org/wiki/Centroid#Centroid_of_polygon
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

	return cx,cy
end

function tools:sorttable(datable,parameter,sortbyasending)
	local count = 0
	local startingvalue = nil
	local startingvalueindex = 0
	local sortedtable = { }

	for i,v in pairs(datable) do 
		count = count + 1

		if (startingvalue == nil) 
		or (sortbyasending and (startingvalue[parameter] > v[parameter])) 
		or (sortbyasending == false and (startingvalue[parameter] < v[parameter])) then
			startingvalue = v
			startingvalueindex = i
		end
	end

	sortedtable[1] = startingvalue
	datable[startingvalueindex] = nil

	for i=2,count do
		local nextvalue = nil
		local nextvalueindex = 0

		for j,v in pairs(datable) do
			if (nextvalue == nil) 
			or (sortbyasending and (nextvalue[parameter] > v[parameter])) 
			or (sortbyasending == false and (nextvalue[parameter] < v[parameter])) then
				nextvalue = v
				nextvalueindex = j
			end
		end
		sortedtable[i] = nextvalue
		datable[nextvalueindex] = nil
	end

	return sortedtable
end

function tools:sortpolydraworder(listofpoints)
	-- gets the angle from some point in the center of the polygon and sorts by angle

	local returner = nil
	local mainpoint = { x=0, y=0 }
	local count = 0

	for i,v in pairs(listofpoints) do
		count = count + 1
		mainpoint.x = mainpoint.x + v.x
		mainpoint.y = mainpoint.y + v.y
	end

	mainpoint.x = (mainpoint.x/count)
	mainpoint.y = (mainpoint.y/count)

	-- sets the angle of each point with respect to the averaged centerpoint of the polygon.
	for i,v in pairs(listofpoints) do
		v.angle = math.acos(math.abs(mainpoint.y-v.y)/(math.sqrt(math.pow((mainpoint.x-v.x),2)+math.pow((mainpoint.y-v.y),2))))
		if (mainpoint.x <= v.x) and (mainpoint.y <= v.y) then
			v.angle = 3.14 - v.angle
		elseif (mainpoint.x >= v.x) and (mainpoint.y <= v.y) then
			v.angle = v.angle + 3.14
		elseif (mainpoint.x >= v.x)and (mainpoint.y >= v.y) then
			v.angle = 2*3.14 - v.angle
		end
	end

	-- orders the points correctly
	--table.sort(listofpoints,function(a,b) return a.angle > b.angle end)
	listofpoints = self:sorttable(listofpoints,'angle',true)

	for j,point in pairs(listofpoints) do
		if returner == nil then
			returner = { }
			returner[1] = point.x
			returner[2] = point.y
		else
			if (math.abs(returner[#returner-1] - point.x) < constants.zero) and (math.abs(returner[#returner] - point.y) < constants.zero) then
				-- duplicate point, so do nothing
			else
				returner[#returner+1] = point.x
				returner[#returner+1] = point.y
			end
		end
	end

	--print('returner: ',unpack(returner))

	return returner

end

function tools:intersectionPoint(line1,line2)
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

function tools:issegmentintersect(line1,groupoflines)
	-- checks if the line segment intersects any of the line segments in the group of lines

	local timestrue = 0
	local timesfalse = 0
	local checkset = { }

	for index,line2 in pairs(groupoflines) do
		local ix,iy,onbothlines = self:intersectionPoint(line1,line2)

		if ((math.abs(line1[1]-ix)+math.abs(line1[2]-iy))<constants.zero or (math.abs(line1[3]-ix)+math.abs(line1[4]-iy))<constants.zero) then 
			onbothlines = false
		end

		checkset[index] = onbothlines

		if onbothlines then timestrue = timestrue + 1 else timesfalse = timesfalse + 1 end
	end

	if timestrue > 0 then return false else return true end
end

function tools:isOnLine(x, y, line)
	-- checks if the point is on the line
	local xWithinBounds = (line[1] <= x and x <= line[3]) or (line[3] <= x and x <= line[1])
	local yWithinBounds = (line[2] <= y and y <= line[4]) or (line[4] <= y and y <= line[2])
	local isEndpoint = (line[1] == x and line[2] == y) or (line[3] == x and line[4] == y)
	return xWithinBounds and yWithinBounds and not isEndpoint
end


function tools:round(num, idp)
	--http://lua-users.org/wiki/SimpleRound
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

-----------------------------------------------------------------------------------------------------------------------------
-- i get lost in the arc tables. this is a way to make polygons. it might not be as fast as
-- doing it during the sweeps, but its the fastest way i can implement one and might not be too bad on the performance side.
function tools:dirty_poly(invoronoi)

	local polygon = { }

	-- removes the points that are outside the boundary
	local processingpoints = invoronoi.vertex
	for i=#processingpoints,1,-1 do
		-- checks the boundaries, and then removes it
		if (processingpoints[i].x < invoronoi.boundary[1]) or (processingpoints[i].x > invoronoi.boundary[3]) or (processingpoints[i].y < invoronoi.boundary[2]) or (processingpoints[i].y > invoronoi.boundary[4]) then
			-- removes the item
			--for remove=#processingpoints-1,i,-1 do processingpoints[remove] = processingpoints[remove+1] end
			--processingpoints[#processingpoints] = nil
			--print('bad point',processingpoints[i].x,processingpoints[i].y)
			processingpoints[i] = nil
		end
	end

	-- adds other points that are not in the vertexes, like the corners and interSectionTools with the boundary
	local otherpoints = {
		{ x = invoronoi.boundary[1], y = invoronoi.boundary[2] },
		{ x = invoronoi.boundary[1], y = invoronoi.boundary[4] },
		{ x = invoronoi.boundary[3], y = invoronoi.boundary[2] },
		{ x = invoronoi.boundary[3], y = invoronoi.boundary[4] }
	}

	-- checks all the segments to see if they pass through the boundary, if they do then this section will
	-- 'trim' the line so it stops at the boundary
	for i,v in pairs(invoronoi.segments) do
		local isects = { }
		local removetheline = false

		-- left boundary
		if (v.startPoint.x < invoronoi.boundary[1]) or (v.endPoint.x < invoronoi.boundary[1]) then 
			removetheline = true
			local px,py,onlines = self:intersectionPoint(
				{ invoronoi.boundary[1],invoronoi.boundary[2],invoronoi.boundary[1],invoronoi.boundary[4] },
				{ v.startPoint.x, v.startPoint.y, v.endPoint.x, v.endPoint.y }
			) 
			isects[#isects+1] = { x=px,y=py,on=onlines }
		end
		-- right boundary
		if (v.startPoint.x > invoronoi.boundary[3]) or (v.endPoint.x > invoronoi.boundary[3]) then 
			removetheline = true
			local px,py,onlines = self:intersectionPoint(
				{ invoronoi.boundary[3],invoronoi.boundary[2],invoronoi.boundary[3],invoronoi.boundary[4] },
				{ v.startPoint.x, v.startPoint.y, v.endPoint.x, v.endPoint.y }
			)
			isects[#isects+1] = { x=px,y=py,on=onlines }
		end
		--top boundary
		if (v.startPoint.y < invoronoi.boundary[2]) or (v.endPoint.y < invoronoi.boundary[2]) then 
			removetheline = true
			local px,py,onlines = self:intersectionPoint(
				{ invoronoi.boundary[1],invoronoi.boundary[2],invoronoi.boundary[3],invoronoi.boundary[2] },
				{ v.startPoint.x, v.startPoint.y, v.endPoint.x, v.endPoint.y }

			)
			isects[#isects+1] = { x=px,y=py,on=onlines }
		end
		-- bottom boundary
		if (v.startPoint.y > invoronoi.boundary[4]) or (v.endPoint.y > invoronoi.boundary[4]) then 
			removetheline = true
			local px,py,onlines = self:intersectionPoint(
				{ invoronoi.boundary[1],invoronoi.boundary[4],invoronoi.boundary[3],invoronoi.boundary[4] },
				{ v.startPoint.x, v.startPoint.y, v.endPoint.x, v.endPoint.y }
			)
			isects[#isects+1] = { x=px,y=py,on=onlines }	 
		end

		--if removetheline then invoronoi.segments[i] = nil end

		-- checks if the point is in or on the boundary lines
		for index,ise in pairs(isects) do 
			if ise.on then 
				otherpoints[#otherpoints+1] = { x = ise.x, y = ise.y }  
			end 
		end
	end
	-- merges the points from otherpoints into the processingpoints table
	for i,v in pairs(otherpoints) do table.insert(processingpoints,v) end

	-----------------------------------------------------------------------------------------------------------------------------------------
	-- this is the part that actually makes the polygons. it does so by calculating the distance from the vertecies
	-- to the randomgenpoints. the shortest distance means that the vertex belongs to that randomgenpoint. voronoi diagrams are constructed
	-- on the fact that these vertexes are equi-distant from the randomgenpoints, so most vertecies will have multiple owning randomgenpoints,
	-- except for the boundary points.
	for vindex,point in pairs(processingpoints) do
		local distances = { }
		---------------------------------------------------------------
		-- calculates the distances and sorts if from lowest to highest
		for rindex,ranpoint in pairs(invoronoi.points) do
			distances[#distances+1] = { i = rindex, d = (math.sqrt(math.pow(point.x-ranpoint.x,2)+math.pow(point.y-ranpoint.y,2))) }
		end
		distances = self:sorttable(distances,'d',true)

		local mindistance = distances[1].d
		local i = 1
		while (distances[i].d - mindistance < constants.zero) do

			if polygon[distances[i].i] == nil then

				polygon[distances[i].i] = { }
				polygon[distances[i].i][1] = { x = point.x, y = point.y }
			else
				polygon[distances[i].i][#polygon[distances[i].i]+1] = { x = point.x, y = point.y }
			end
			--print(vindex,distances[i].i)

			i = i + 1
		end

		--------------------------------------------------------------------------------------------------
		-- creates the relationship between polygons, which looks like a delaunay triangulation when drawn

		-- gets all the related polygons here. 
		i = i - 1
		local related = { }
		for j=1,i do 
			related[#related+1] = distances[j].i 
		end

		-- puts them in a structure, calling it polygonmap
		for j=1,#related do
			if invoronoi.polygonmap[related[j]] == nil then invoronoi.polygonmap[related[j]] = { } end
			for k=1,#related do
				if not self:tablecontains(invoronoi.polygonmap[related[j]],nil,related[k]) and (related[j] ~= related[k]) then
					invoronoi.polygonmap[related[j]][#invoronoi.polygonmap[related[j]]+1] = related[k]
				end
			end
		end
	end

	for i=1,#invoronoi.points do 
		-- quick fix to stop crashing
		if polygon[i] ~= nil then
			invoronoi.polygons[i] = self.polygon:new(self:sortpolydraworder(polygon[i]),i)
		end
	end
end

---------------------------------------------
-- generates randompoints
function tools:randompoint(minx,miny,maxx,maxy)

	local x = math.random(minx+1,maxx-1) 
	local y = math.random(miny+1,maxy-1)

	return x,y 

end

----------------------------------------------
-- checks if the line segment is the same
function tools:sameedge(line1,line2)

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

local polygon = { }

function polygon:new(inpoints,inindex)

	local returner = { points = inpoints, index = inindex }

	-- creates the edges
	local edgeno = 0
	returner.edges = { }
	for i=1,#returner.points-2,2 do
		edgeno = edgeno + 1
		returner.edges[edgeno] = { }
		returner.edges[edgeno][1] = returner.points[i]
		returner.edges[edgeno][2] = returner.points[i+1]
		returner.edges[edgeno][3] = returner.points[i+2]
		returner.edges[edgeno][4] = returner.points[i+3]
	end
	-- these last lines close the edges, without this the polygon would be missing an edge, usually on the top.
	edgeno = edgeno + 1
	returner.edges[edgeno] = { }
	returner.edges[edgeno][1] = returner.edges[edgeno-1][3]
	returner.edges[edgeno][2] = returner.edges[edgeno-1][4]
	returner.edges[edgeno][3] = returner.edges[1][1]
	returner.edges[edgeno][4] = returner.edges[1][2]

	-- lua metatable stuff...
	setmetatable(returner, self) 
	self.__index = self 

	return returner

end

----------------------------------------------------------
-- checks if the point is inside the polygon
function polygon:containspoint(inx,iny)
	local centroidline = { inx,iny, self.centroid.x, self.centroid.y }

	-- checks the point,centroid line with the edges of the polygon. if the point intersects any of the edges and is one the edge, then the point lies outside of the polygon 
	for i,line2 in pairs(self.edges) do
		local x,y,onlines = tools:intersectionPoint(centroidline,line2)
		if onlines then return false end
	end

	return true
end

----------------
----------------
----------------


local voronoilib = { }
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
-- creates a voronoi diagram and returns a table containing the structure.
--
-- polygoncount = the number of polygons wanted, this can be thought of as the total number of grid regions
-- iterations = how many times you would like to run the  voronoi. the more iterations, the smoother and more regular
--              the grid looks, recommend at least 3 iterations for a nice grid. any more is diminishing returns
-- minx,miny,maxx,maxy = the boundary for the voronoi diagram. if you choose 0,0,100,100 the function will make a voronoi diagram inside 
--                       the square defined by 0,0 and 100,100 where all the points of the voronoi are inside the square.

voronoilib.constants = constants

function voronoilib:newPoints(polygoncount, iterations, minx,miny,maxx,maxy) 
	local points = {}
	local boundary = { minx,miny,minx+maxx,miny+maxy }

	for i=1,polygoncount do
		local rx,ry = self.tools:randompoint(minx,miny,maxx,maxy)
		local point = { x = rx, y = ry }
		table.insert (points, point)
	end

	points = self.tools:sortthepoints(points)


	return points
end

function voronoilib:new(polygoncount,iterations,minx,miny,maxx,maxy)

	local rightDoubleBoundary = 2*(maxx + (maxx-minx) + (maxy-miny))

	local rvoronoi = { }
	----------------------------------------------------------
	-- the iteration loop
	for it=1,iterations do

		------------------------------------------------
		-- initalizes everything needed for this iteration
		rvoronoi[it] = { }
		rvoronoi[it].points = { }
		rvoronoi[it].boundary = { minx,miny,minx+maxx,miny+maxy }
		rvoronoi[it].vertex = { }
		rvoronoi[it].segments = { }
		rvoronoi[it].events = self.heap:new()
		rvoronoi[it].beachline = self.doubleLinkedList:new()
		rvoronoi[it].polygons = { }
		rvoronoi[it].polygonmap = { }
		rvoronoi[it].centroids = { }

		---------------------------------------------------------
		-- creates the random points that the polygons will be based
		-- off of. if this is it > 1 then it uses the centroids of the 
		-- polygons from the previous iteration as the 'random points'
		-- this relaxes the voronoi diagram and softens the grids so
		-- the grid is more even.
		if it == 1 then 
			-- creates a random point and then checks to see if that point is already inside the set of random points. 
			-- don't know what would happened but it would not return the same amount of polygons that user requested
			for i=1,polygoncount do
				local rx,ry = self.tools:randompoint(minx,miny,maxx,maxy)
				while self.tools:tablecontains(rvoronoi[it].points,{ 'x', 'y' }, { rx, ry }) do
					rx,ry = self.tools:randompoint(minx,miny,maxx,maxy)
				end
				rvoronoi[it].points[i] = { x = rx, y = ry }
			end
			rvoronoi[it].points = self.tools:sortthepoints(rvoronoi[it].points)
		else
			rvoronoi[it].points = rvoronoi[it-1].centroids
		end

		-- sets up the rvoronoi events
		for i = 1,#rvoronoi[it].points do
			rvoronoi[it].events:push(rvoronoi[it].points[i], rvoronoi[it].points[i].x,{i} )
		end

		while not rvoronoi[it].events:isEmpty() do
			local e, x = rvoronoi[it].events:pop()
			if e.event then
				self.tools:processEvent(e,rvoronoi[it])
			else
				self.tools:processPoint(e,rvoronoi[it])
			end    
		end

		self.tools:finishEdges(rvoronoi[it], rightDoubleBoundary)	 

		self.tools:dirty_poly(rvoronoi[it])

		for i,polygon in pairs(rvoronoi[it].polygons) do
			local cx, cy = self.tools:polyoncentroid(polygon.points)
			rvoronoi[it].centroids[i] = { x = cx, y = cy }
			rvoronoi[it].polygons[i].centroid = rvoronoi[it].centroids[i] -- creating a link between the two tables
		end
	end

	-----------------------------
	-- returns the last iteration
	local genvoronoi = rvoronoi[iterations]
	print (#genvoronoi.polygons)
	setmetatable(genvoronoi, self) 
	self.__index = self 
	return genvoronoi
end

------------------------------------------------
-- returns the actual polygons that are the neighbors
function voronoilib:getNeighbors(...)

	local returner = { }
	local indexes = { }

	-- builds a table of it input polygons
	for i=2,#arg do 
		indexes[arg[i]] = true 
	end

	if arg[1] == 'all' then

		-- finds all the neighbors and removes all duplicates
		local returnIs = { }
		for pindex,tt in pairs(indexes) do
			for j,index in pairs(self.polygonmap[pindex]) do
				returnIs[index] = true
			end
		end

		-- sets the in polygons as nil so it doesnt' return one of the inputs as a neighbor.
		for index,tt in pairs(indexes) do returnIs[index] = nil end

		-- builds the polygon table for returning
		for index,tt in pairs(returnIs) do
			returner[#returner+1] = self.polygons[index]
		end

	elseif arg[1] == 'shared' then

		-- finds all the neighbors, counts occurances
		local returnIs = { }
		for pindex,tt in pairs(indexes) do
			for j,index in pairs(self.polygonmap[pindex]) do
				if returnIs[index] == nil then returnIs[index] = 1
				else returnIs[index] = returnIs[index] + 1 end
			end
		end

		-- builds the polygon table for returning
		for index,count in pairs(returnIs) do
			if count == (#arg-1) then returner[#returner+1] = self.polygons[index] end
		end

	else print('unknown mode in getNeighbors(...): ' .. arg[1]) end

	--[[for pindex,tt in pairs(indexes) do
        returner[]
        for j,index in pairs(self.polygonmap[pindex]) do
            returner[#returner+1] = self.polygons[index]
        end
    end]]--

	return returner

end

-------------------------------------------------------
-- returns the edges of a polygon. if multiple polygons are 
-- inputed then only the edges that are shared with at least 
-- two polygons are returned
-- the first argument is MODE = { 'segment' or 'vertex'} 
-- segment --> returns edges where the line segment is shared with atleast 2 polygons
-- vertex --> returns segments in which the vertexes are shared with atleast 3 polygons
function voronoilib:getEdges(mode, drawlist)
	local edges = { }

	for i=1, #drawlist do
		for j,line in pairs(self.polygons[drawlist[i]].edges) do 
			edges[#edges+1] = line 
		end
	end



	if #drawlist > 1 then
		local processedreturner = { }
		local incount = { }

		for i,line1 in pairs(edges) do
			for j,line2 in pairs(edges) do
				if (i ~= j) and (incount[i] == nil) and (incount[j] == nil) then
					if self.tools:sameedge(line1,line2) then
						processedreturner[#processedreturner+1] = edges[i]
						incount[i],incount[j] = true,true
					end
				end 
			end
		end
		edges = processedreturner

		if mode == 'segment' then
			-- do nothing, everything is already done.
		elseif mode == 'vertex' then
			-- checks if the segment shares both points with 2 other segments
			-- only returns those segments
			processedreturner = { }
			for indexmain,linemain in pairs(edges) do
				-- how many other segments share the same points
				local point1 = 0
				local point2 = 0

				for indexsub,linesub in pairs(edges) do
					if ((math.abs(linemain[1] - linesub[1]) < constants.zero) and (math.abs(linemain[2] - linesub[2]) < constants.zero)) 
					or ((math.abs(linemain[1] - linesub[3]) < constants.zero) and (math.abs(linemain[2] - linesub[4]) < constants.zero)) then
						point1 = point1 + 1
					elseif ((math.abs(linemain[3] - linesub[1]) < constants.zero) and (math.abs(linemain[4] - linesub[2]) < constants.zero)) 
					or ((math.abs(linemain[3] - linesub[3]) < constants.zero) and (math.abs(linemain[4] - linesub[4]) < constants.zero)) then 
						point2 = point2 + 1
					end
				end

				if (point2 >= 2) and (point1 >= 2) then
					processedreturner[#processedreturner+1] = linemain
				end
			end
			edges = processedreturner

		else print('not an recognized voronoilib:getEdges(...) mode') end

	end

	return edges
end

-----------------------------------------------------------------------------------
-- returns the polygon that contains the point, returns nil if no polygon was found
function voronoilib:polygoncontains(x,y)

	local distance = { }
	for index,centroid in pairs(self.centroids) do
		distance[#distance+1] = { i = index, d = math.sqrt(math.pow(x-centroid.x,2) + math.pow(y-centroid.y,2)) }
	end

	table.sort(distance,function(a,b) return a.d < b.d end)

	for i,pindex in pairs({ unpack(self.polygonmap[distance[1].i]),distance[1].i }) do
		if self.polygons[pindex]:containspoint(x,y) then 
			return self.polygons[pindex]
		end
	end

	return nil
end


----------------
----------------
----------------

tools.polygon = polygon
voronoilib.heap = heap
voronoilib.tools = tools
voronoilib.doubleLinkedList = doubleLinkedList

return voronoilib