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

local Heap = {}
function Heap:new()
	local o = { Heap = {}, nodes = {} }
	setmetatable(o, self)
	self.__index = self
	return o
end

function Heap:push(k, v)
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

function Heap:pop()
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

function Heap:isEmpty()
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

function Tools:sortthepoints(points)
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

function Tools:sortpolydraworder(listofpoints)

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

function Tools:polyoncentroid(listofpoints)
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

function Tools:sorttable(datable,parameter,sortbyasending)
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

function Tools:sortpolydraworder(listofpoints)
	-- gets the angle from some point in the center of the Polygon and sorts by angle

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

	-- sets the angle of each point with respect to the averaged centerpoint of the Polygon.
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

function Tools:issegmentintersect(line1,groupoflines)
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

-----------------------------------------------------------------------------------------------------------------------------
-- i get lost in the arc tables. this is a way to make polygons. it might not be as fast as
-- doing it during the sweeps, but its the fastest way i can implement one and might not be too bad on the performance side.
function Tools:dirty_poly(invoronoi)

	local polygon = { }

	-- removes the points that are outside the boundary
	local processingpoints = invoronoi.vertex
--	for i = 1, #processingpoints do
--		print (i, processingpoints[i])
--	end

	for i=#processingpoints,1,-1 do
--		print (i, processingpoints[i])
--		print (i, tostring(processingpoints[i].x), tostring(processingpoints[i].y))
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

		-- puts them in a structure, calling it polygonMap
		for j=1,#related do
			if invoronoi.polygonMap[related[j]] == nil then invoronoi.polygonMap[related[j]] = { } end
			for k=1,#related do
				if not self:tableContains(invoronoi.polygonMap[related[j]],nil,related[k]) and (related[j] ~= related[k]) then
					local indexA = related[j]
					local indexB = #invoronoi.polygonMap[indexA]+1
					invoronoi.polygonMap[indexA][indexB] = related[k]
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

	--	points, index, edges
	local returner = {
		points = points,
		edges = edges,
		index = index,
	}

	-- lua metatable stuff...
	setmetatable(returner, self) 
	self.__index = self 

	return returner
end

----------------------------------------------------------
-- checks if the point is inside the Polygon
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
--voronoilib.constants = constants

function voronoilib:newPoints(polygonCount, iterations, minx,miny,maxx,maxy) 
	local points = {}
	local boundary = { minx,miny,minx+maxx,miny+maxy }

	for i=1,polygonCount do
		local rx,ry = self.Tools:randomPoint(minx,miny,maxx,maxy)
		local point = { x = rx, y = ry }
		table.insert (points, point)
	end

	points = Tools:sortthepoints(points)
	return points
end


local function getRVoronoi (points, iterations, minx,miny,maxx,maxy)
	local rightDoubleBoundary = 2*(maxx + (maxx-minx) + (maxy-miny))
	local boundary = { minx,miny,minx+maxx,miny+maxy }

	local rvoronoi = {}
	rvoronoi.points = points
	rvoronoi.boundary = boundary

	rvoronoi.vertex = { }
	rvoronoi.segments = { }
	rvoronoi.events = Heap:new()
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
	Tools:dirty_poly(rvoronoi)

	for i, polygon in pairs(rvoronoi.polygons) do
		local cx, cy = Tools:polyoncentroid(polygon.points)
		rvoronoi.centroids[i] = { x = cx, y = cy }
		rvoronoi.polygons[i].centroid = rvoronoi.centroids[i] -- creating a link between the two tables
	end

	return rvoronoi
end

local function generatePoints (polygoncount,iterations,minx,miny,maxx,maxy)
	local points = {}
	for i=1,polygoncount do
		local rx,ry = Tools:randomPoint(minx,miny,maxx,maxy)
		while Tools:tableContains(points,{ 'x', 'y' }, { rx, ry }) do
			rx,ry = Tools:randomPoint(minx,miny,maxx,maxy)
		end

		points[i] = { x = rx, y = ry }
	end
	points = Tools:sortthepoints(points)
	return points
end

function voronoilib:new(polygoncount,iterations,minx,miny,maxx,maxy)
	local points = generatePoints (polygoncount,iterations,minx,miny,maxx,maxy)
	local str = ''
	for i, p in ipairs (points) do
		str = str..p.x..','..p.y..', '
	end
	print ('{'..str..'}')

	local genvoronoi = getRVoronoi (points,iterations,minx,miny,maxx,maxy)
	setmetatable(genvoronoi, self) 
	self.__index = self 
	return genvoronoi
end

------------------------------------------------
-- returns the actual polygons that are the neighbors
function voronoilib:getNeighborsSingle(polygon)
	local index = polygon.index
	local neighbors = {}
	for i, indexNeighbour in pairs(self.polygonMap[index]) do
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


function voronoilib:edgeContains(x, y, minDistance)
	local closestEdge = nil
	minDistance = minDistance or math.huge
	for _, edge in pairs(self.edges) do
		local dx, dy = x - edge.x1, y - edge.y1
		local d = math.sqrt(dx * dx + dy * dy)

		if d < minDistance then
			minDistance = d
			closestEdge = edge
		end
	end
	return closestEdge
end


----------------
----------------
----------------

Tools.polygon = Polygon

voronoilib.Heap = Heap
voronoilib.Tools = Tools
voronoilib.doubleLinkedList = doubleLinkedList

return voronoilib