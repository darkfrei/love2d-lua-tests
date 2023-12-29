-- Voronoi Fortune
-- Public Domain, (c) darkfrei 2023

local function createIDGenerator()
	local idCounter = 0
	return function ()
		idCounter = idCounter + 1
		return idCounter
	end
end

local getID = createIDGenerator()

local function createNode (key, value, x)
	local node = {
		x=x,
		[key] = value,
		id = getID (),
	}
	print ('created node', node.id, key)
	return node
end

local function linkNodes(...)
	local nodes = { ... }
	for i = 1, #nodes - 1 do
--		print ('link node', nodes[i].id, 'to', nodes[i+1].id)
		nodes[i].next = nodes[i + 1]
		nodes[i + 1].prev = nodes[i]
	end
end

local function getEmptyBeachline(width, height)
	local leftPoint = { x = 0, y = 0 }
	local rightPoint = { x = width, y = 0 }
	local node1 = createNode('point', leftPoint, 0)
--	local node2 = createNode('cell', cell)
	local node2 = createNode('placeholder', true)
	local node3 = createNode('point', rightPoint, width)
	linkNodes(node1, node2, node3)
	local beachline = {headPointNode = node1}
	print ('created beachline', beachline.headPointNode)
	return beachline
end

local function createPointEvent(cell)
	return { point = true, cell = cell, sortY = cell.siteY}
end

local function createCircleEvent(arc, x, y, sortY, r)
	return { circle = true, arc = arc, 
		x=x, y=y, r=r, -- crossing point
		sortY = sortY}
end

local function createEventQueue(cells)
	local eventQueue = {}
	for _, cell in ipairs(cells) do
		local pointEvent = createPointEvent(cell)
		table.insert(eventQueue, pointEvent)
	end
	-- sort it in the loop, not here
	return eventQueue 
end

local function removeNodeLinks (node)
	node.prev = nil
	node.next = nil
	node.cell = nil
	node.valid = false
end

local function sortQueue(queue)
	table.sort(queue, function(a, b)
			return a.sortY > b.sortY -- lowest is last
		end)
end

local function sortCells (cells)
	table.sort(cells, function(a, b)
			return a.sortY < b.sortY -- lowest is last
		end)
end




local function getFocusParabolaRoots (fx, fy, dirY) -- focus, directrix
	-- https://love2d.org/forums/viewtopic.php?p=257944#p257944
	-- https://www.desmos.com/calculator/vx3tj0tixk
	-- vertex form of parabola
	-- focus: (h, k+p)
	-- directrix Y: y=k-p
	print ('fx, fy, dirY', fx, fy, dirY)

	local h = fx -- x shift
	local p = (fy-dirY)/2 -- always negative for voronoi
	local k = fy - p

	-- roots
	local left_x = h - math.sqrt (-k*4*p)
	local right_x = h + math.sqrt (-k*4*p)
	print (left_x, right_x, (left_x+right_x)/2)
	return left_x, right_x
end

local function findParabolaCrossing(fx1, fy1, fx2, fy2, dirY) -- focus1, focus2, directrixY
	-- [desmos](https://www.desmos.com/calculator/fadiqu5tyk)
	if fy1 == fy2 then
		local x = (fx1+fx2)/2
		local y = (x-fx1)^2 / (2 * (fy1 - dirY)) + fy1 - (fy1-dirY)/2 -- right
--		print ('a==0: x, y', x, y)
		return x, y, x, y
	else
		local z2 = 2*(fy2-dirY)
		local z1 = 2*(fy1-dirY)
		local a = 1/z2-1/z1
		local b = 2*fx1/z1-2*fx2/z2
		local c2 = fx2^2/z2+fy2-z2/4
		local c1 = fx1^2/z1+fy1-z1/4
		local k = c2-c1 - b^2 / (4 * a)
		local x = -b / (2 * a) - math.sqrt (-k/a)
		local y = (x-fx1)^2 / z1 + fy1 - z1/4
--		print ('a='..a..' x, y', x, y)
		return x, y -- the point between two parabolas
	end
end


--local function specialCaseNode2 (node3, node4, dirY)
--	-- Case: Placeholder followed by Arc
--	-- find left x and set to node3
--	local cell = node4.cell
--	local focusX, focusY = cell.siteX, cell.siteY
--	local x1, x2 = getFocusParabolaRoots (focusX, focusY, dirY)
--	node3.x = x1
--	node3.point.x = x1
--	return x1, x2
--end

--local function specialCaseNode4 (node3, node2, dirY)
--	-- Case: Arc followed by Placeholder
--	-- find right x and set to node3
--	local cell = node2.cell
--	local focusX, focusY = cell.siteX, cell.siteY
--	local x1, x2 = getFocusParabolaRoots (focusX, focusY, dirY)
--	node3.x = x2
--	node3.point.x = x2
--	return x1, x2
--end

local function updatePoints(beachline, dirY)
	print ('update beachline, dirY', dirY)
	local node1 = beachline.headPointNode -- point 1
	local node2 = node1.next -- arc 1
	local node3 = node2.next -- point 2
	local node4 = node3.next -- arc 2

	local i = 1
	while node4 do
		local x1, y1 = node2.cell.siteX, node2.cell.siteY
		local x2, y2 = node4.cell.siteX, node4.cell.siteY
		local x, y = findParabolaCrossing (x1, y1, x2, y2, dirY)
		
		node3.x = x
		node3.point.x = x
		node3.point.y = y
		print (i, 'moved node', node3.id, 'to', x, y)

		node1 = node3 -- next point 1
		node2 = node1.next -- arc 1
		node3 = node2.next -- point 2
		node4 = node3.next -- arc 2, can be nil
		i = i + 1
	end
end

local function findArc (beachline, siteX)

	local currentPoint = beachline.headPointNode
	local currentArc = currentPoint.next
	local nextPoint = currentArc.next

	while currentArc do
		nextPoint = currentArc.next
--		print (nextPoint.point.x)
		if nextPoint then
			local x = nextPoint.point.x
			if siteX == nextPoint.point.x then
				local nextArc = nextPoint.next
				if nextArc then
					-- special case: 
					-- add point to both cells,
					-- create two new parabolas
					return nil, nextPoint
				end
			elseif siteX < nextPoint.x then
				-- break current arc
				print ('current arc', currentArc.id)
				return currentArc, nil
			end
		end
		currentPoint = nextPoint
		currentArc = beachline.next
	end

	-- out of border
	return currentArc, nil
end


local function printBeachlineLength (beachline)
	local beachlineLength = 0
	local node = beachline.headPointNode
	while node do
--		print ('node id', node.id)
		beachlineLength = beachlineLength + 1
		node = node.next
	end
	print ('beachlineLength', beachlineLength)
end



---------------------------------------------------------------
-- Insert a new arc into the beachline, updating its structure.
-- This function takes the beachline, an existing arc, 
-- a new cell, and the current site coordinates.
-- It replaces the existing arc with a new structure 
-- containing two cells and two points, creating a new parabola
-- in the process.
-- Parameters:
--   beachline: The beachline data structure.
--   arc: The existing arc to be replaced.
--   cell: The new cell to be inserted.
--   siteX: The x-coordinate of the current site.
--   siteY: The y-coordinate of the current site.
--   arcY: The y-coordinate on the existing arc.
local function insertArc (beachline, arc, cell, siteX, siteY, arcY)
	if arc.placeholder then
		arc.placeholder = false
		arc.cell = cell
		return
	end
	local node1 = arc.prev -- point
	local newpoint1 = {x=siteX,y=arcY}
	local newpoint2 = {x=siteX,y=arcY}
	print ('cell', cell)
	print ('arc.cell', arc.cell)

	print ('break arc id', arc.id)

	-- insert vertex point to cell.vertexPoints
	table.insert (cell.vertexPoints, newpoint1)
	table.insert (cell.vertexPoints, newpoint2)

	-- insert vertex point to cell.vertexPoints
	table.insert (arc.cell.vertexPoints, newpoint1)
	table.insert (arc.cell.vertexPoints, newpoint2)
	
	local node2 = createNode('cell', arc.cell)
	local node3 = createNode ('point', newpoint1, siteX)
	local node4 = createNode('cell', cell)
	local node5 = createNode ('point', newpoint2, siteX)
	local node6 = createNode('cell', arc.cell)
	local node7 = arc.next -- point

	linkNodes(node1, node2, node3, node4, node5, node6, node7)
	printBeachlineLength (beachline)

	removeNodeLinks (arc)


	print ('created nodes:', node2.id, node3.id, node4.id, node5.id, node6.id)

	return node4 -- new arc
end

local function evaluateParabola(fx, fy, x, dirY)
-- focus, current x, directrixY
--returns the y value
	local z = 2*(fy-dirY)
	return (x-fx)^2 / z + fy - z/4
end


local function findCircleCenter (x1, y1, x2, y2, x3, y3)
	local d = 2*(x1*(y2-y3)+x2*(y3-y1)+x3*(y1-y2))
	local t1, t2, t3 = x1*x1+y1*y1, x2*x2+y2*y2, x3*x3+y3*y3
	local x = (t1*(y2-y3)+t2*(y3-y1)+t3*(y1-y2)) / d
	local y = (t1*(x3-x2)+t2*(x1-x3)+t3*(x2-x1)) / d
	local radius = math.sqrt((x1-x)^2+(y1-y)^2)
	return x, y, radius
end

local function checkForCircleEvents(beachline, eventQueue, leftArc, arc, rightArc, dirY)
	print (' ------- checkForCircleEvents ------- ')
	print ('arc id', arc.id)

	local c1 = leftArc.cell
	local c2 = arc.cell
	local c3 = rightArc.cell
	local x1, y1 = c1.siteX, c1.siteY
	local x2, y2 = c2.siteX, c2.siteY
	local x3, y3 = c3.siteX, c3.siteY
	local x, y, r = findCircleCenter(x1, y1, x2, y2, x3, y3)

	local sortY = y + r
	local circleEvent = createCircleEvent(arc, x, y, sortY, r)
	print ('added circle event:', sortY, 'currend dirY:', dirY)
	table.insert(eventQueue, circleEvent)
end

local function mergeParabolas (arc1, arc2, arc3, dirY)
	print ('merging, dirY', dirY)
	local fx1, fy1 = arc1.cell.siteX, arc1.cell.siteY
	local fx2, fy2 = arc3.cell.siteX, arc3.cell.siteY
	local x, y = findParabolaCrossing(fx1, fy1, fx2, fy2, dirY)
	print ('merging by point', x, y)
	local point = {x=x,y=y}
	local nodePoint = createNode('point', point, x)

	removeNodeLinks (arc1.next)
	removeNodeLinks (arc2)
	removeNodeLinks (arc3.prev)

	linkNodes (arc1, nodePoint, arc3)
end

local function printBeachline (beachline)
	local node = beachline.headPointNode
	local str = 'beachline nodes: '
	while node do
		str = str .. node.id .. ' '
		node = node.next
	end
	print (str)
end

local function processPointEvent(event, beachline, eventQueue)
	local cell = event.cell
	local siteX = cell.siteX -- current x
	local siteY = cell.siteY -- current directrix
	local dirY = siteY

	printBeachlineLength (beachline)

	-- old arc, tat must be replaced by same two new arcs
	local arc, point = findArc (beachline, siteX)
	

	if arc then
		print ('point event, arc.id', arc.id)
		-- Insert new arc into the beachline
		local arcY = 0
		if arc.cell then
			-- (fx, fy, x, dirY)
			arcY = evaluateParabola(arc.cell.siteX, arc.cell.siteY, siteX, siteY)
		end
		print ('arcY', arcY)

		local arcC = insertArc(beachline, arc, cell, siteX, siteY, arcY)
		
		if arcC then
			print ('arcC.id', arcC.id)
			printBeachline (beachline)
			if arcC.prev.prev then
				local arcB = arcC.prev.prev
				print ('arcB exist')
				if arcB.prev.prev then
					print ('arcA exist')
					local arcA = arcB.prev.prev
					checkForCircleEvents(beachline, eventQueue, arcA, arcB, arcC, dirY)
				end
			end
			if arcC.next.next then
				local arcD = arcC.next.next
				print ('arcD exist')
				if arcD.next.next then
					local arcE = arcD.next.next
					print ('arcE exist')
					checkForCircleEvents(beachline, eventQueue, arcC, arcD, arcE, dirY)
				end
			end
		end
	elseif point then
		-- special case for vertical alligned site and vertex point
		-- insert new arc to two arcs, not one
	end	
end

local function processCircleEvent(event, beachline)
	table.insert (CIRCLEEVENTLINESS, event.sortY)
	table.insert (CIRCLEEVENTCIRCLES, {x=event.x, y=event.y, r=event.r})
	
	local arc = event.arc
	if arc.prev and arc.next then
		local point = {x=event.x, y=event.y}
		local node2 = createNode('point', point, event.x)
		local node1 = arc.prev.prev
		local node3 = arc.next.next
		linkNodes (node1, node2, node3)
		removeNodeLinks (arc.prev)
		removeNodeLinks (arc.next)
		
		print ('circle event complete')
		printBeachline (beachline)
	end
end

local function voronoiMainLoop (eventQueue, beachline)
	print ('voronoiMainLoop')
	print ('#eventQueue'.. #eventQueue)
	local eventNumber = 0
	CIRCLEEVENTLINESS = {}
	CIRCLEEVENTCIRCLES = {}

	local lastDir = 0
	while #eventQueue > 0 do
		sortQueue(eventQueue)
		eventNumber = eventNumber + 1
		print ('\n' .. 'event number', eventNumber)
		local event = table.remove (eventQueue) -- take the last element, it's faster
		print ((event.point and 'point event' or 'circle event'))
		local dirY = event.sortY -- current directrix
		if not (lastDir == dirY) then
			updatePoints(beachline, dirY)
			lastDir = dirY
		end
		
		if event.point then
			
			-- Process site event
			processPointEvent(event, beachline, eventQueue)
		elseif event.circle then
			-- Process circle event
			processCircleEvent(event, beachline)
		end
	end
end

local function generateVoronoiCells (cells, width, height)

	for i, cell in ipairs (cells) do
		-- vertexPoint: {x=x,y=y}
		cell.vertexPoints = {}
		cell.neighbourCells = {}
		cell.sortY = cell.siteY
	end
	sortCells(cells)
	for id, cell in ipairs (cells) do
		cell.id = id
	end
	
	local beachline = getEmptyBeachline(width, height)
	local eventQueue = createEventQueue (cells)

	voronoiMainLoop (eventQueue, beachline)


	-- by return the each cell contains:
	-- siteX, siteY (position of site)
	-- color (cell color)
	-- polygon (vertices in array of pairs as {x1, y1, x2, y2 ...})
	-- (in the clockwise direction from top left corner: negative x and y)
	return cells
end

return generateVoronoiCells