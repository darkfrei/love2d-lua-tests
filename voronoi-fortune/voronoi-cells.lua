-- Voronoi Fortune
-- Public Domain, (c) darkfrei 2023


-- nodes 


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
	local str = (key == "cell") and 'cell.id: ' .. tostring (value.id) or ""
--	print ('created node', node.id, key, str)
	return node
end


-- beachline and beachline nodes

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
--	print ('created beachline', beachline.headPointNode)
	return beachline
end

local function removeNodeLinks (node)
	node.prev = nil
	node.next = nil
	node.removed = true
end

--------------- events


local function createPointEvent(cell)
	return { point = true, cell = cell, sortY = cell.siteY}
end

local function createCircleEvent(arc, x, y, sortY, r)
--	print ('----------- createCircleEvent', x, y, sortY) 
	return { circle = true, arc = arc, 
		x=x, y=y, r=r, -- crossing point
		sortY = sortY}
end

--------------- queue


local function createEventQueue(cells)
	local eventQueue = {}
	for _, cell in ipairs(cells) do
		local pointEvent = createPointEvent(cell)
		table.insert(eventQueue, pointEvent)
	end
	-- sort it in the loop, not here
	return eventQueue 
end

local function sortQueue(queue)
	table.sort(queue, function(a, b)
			return a.sortY > b.sortY -- lowest is last
		end)
end


------------- cells


local function newCell (x, y)
	local cell = {
		siteX = x,
		siteY = y,
		color = {
			math.random ()/2+0.5,
			math.random ()/2+0.5,
			math.random ()/2+0.5,
		},
		vertexPoints = {},
		neighbourCells = {},
		sortY = y,
	}
	return cell
end


local function sortCells (cells)
	table.sort(cells, function(a, b)
			return a.sortY < b.sortY -- lowest is last
		end)
end

local function addVertexPointToCell (vertexPoint, cell)
	if cell.vertices == nil then
		cell.vertices = {}
	end
	table.insert(cell.vertexPoints, vertexPoint)
end


-------------------------------------------------------
----------------------- math --------------------------
-------------------------------------------------------


local function getFocusParabolaRoots (fx, fy, dirY) -- focus, directrix
	-- https://love2d.org/forums/viewtopic.php?p=257944#p257944
	-- https://www.desmos.com/calculator/vx3tj0tixk
	-- vertex form of parabola
	-- focus: (h, k+p)
	-- directrix Y: y=k-p
--	print ('fx, fy, dirY', fx, fy, dirY)

	local h = fx -- x shift
	local p = (fy-dirY)/2 -- always negative for voronoi
	local k = fy - p

	-- roots
	local left_x = h - math.sqrt (-k*4*p)
	local right_x = h + math.sqrt (-k*4*p)
--	print (left_x, right_x, (left_x+right_x)/2)
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
		local x2 = -b / (2 * a) + math.sqrt (-k/a)
		local y = (x-fx1)^2 / z1 + fy1 - z1/4
		local y2 = (x2-fx1)^2 / z1 + fy1 - z1/4
--		print ('a='..a..' x, y', x, y)
		return x, y, x2, y2 -- the point between two parabolas
	end
end

-------------------------


local function evaluateParabola(fx, fy, x, dirY)
-- focus, current x, directrixY
--returns the y value
	local z = 2*(fy-dirY)
	return (x-fx)^2 / z + fy - z/4
end


local function updateBeachline(beachline, dirY)
--	print ('---- update beachline, dirY', dirY)
	local node1 = beachline.headPointNode -- point 1
	local node2 = node1.next -- arc 1
	local node3 = node2.next -- point 2
	local node4 = node3.next -- arc 2

--	print ('node3', node3.x)
	local i = 1
	while node4 do
		local x1, y1 = node2.cell.siteX, node2.cell.siteY
		local x2, y2 = node4.cell.siteX, node4.cell.siteY

		local x, y, x22, y22

		if y2 == dirY then
			x = x2
			y = evaluateParabola (x1, y1, x, dirY)
		elseif y1 == dirY then
			x = x1
			y = node1.y
		else
--			print ('findParabolaCrossing')
			x, y, x22, y22 = findParabolaCrossing (x1, y1, x2, y2, dirY)
			if x1 > x2 then
				x, y = x22, y22
			end
		end

--		print ('crossing', x, y)
		node3.x = x
		node3.y = y
		node3.point.x = x
		node3.point.y = y
--		print (i, 'moved node', node3.id, 'to', x, y)

		node1 = node3 -- next point 1
		node2 = node1.next -- arc 1
		node3 = node2.next -- point 2
		node4 = node3.next -- arc 2, can be nil
		i = i + 1
	end


end

--------------------


local function findArc (beachline, siteX)

	local currentPoint = beachline.headPointNode
	local currentArc = currentPoint.next


	while currentArc do
		local nextPoint = currentArc.next
		local x = nextPoint.point.x
		if siteX == x then
			local nextArc = nextPoint.next
			if nextArc then
				-- special case: 
				-- add point to both cells,
				-- create two new parabolas

				return nil, nextPoint
			end
		elseif siteX < x then
			-- break current arc
--			print ('found arc', currentArc.id, 'site x'..siteX..' < x='..x)
			return currentArc, nil
		end

		currentArc = nextPoint.next
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

local function insertVertexPoint (cell, vertexPoint)
	table.insert (cell.vertexPoints, vertexPoint)
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
local function insertArc (beachline, oldArc, cell, siteX, siteY, arcY)
	if oldArc.placeholder then
		oldArc.placeholder = false
		oldArc.cell = cell
--		print ('oldArc', oldArc.id, 'was placeholder')
		return
	end
	local x, y = siteX, arcY
--	print ('cut points to', x, y)
	local node1 = oldArc.prev -- point
	local newpoint1 = {x=x,y=y}
	local newpoint2 = {x=x,y=y}
	local oldCell = oldArc.cell

	local node2 = createNode('cell', oldCell)
	local node3 = createNode ('point', newpoint1, siteX)
	local node4 = createNode('cell', cell)
	local node5 = createNode ('point', newpoint2, siteX)
	local node6 = createNode('cell', oldCell)
	local node7 = oldArc.next -- point

	linkNodes(node1, node2, node3, node4, node5, node6, node7)

--	print ('new beach line, one removed, added 5')
--	printBeachlineLength (beachline)

	removeNodeLinks (oldArc)


--	print ('created nodes:', node2.id, node3.id, node4.id, node5.id, node6.id)

	return node4, node3, node5 -- new arc
end



local function findCircleCenter (x1, y1, x2, y2, x3, y3)
	local d = 2*(x1*(y2-y3)+x2*(y3-y1)+x3*(y1-y2))
	if d == 0 then
		-- parallel
		return nil
	end
	local t1, t2, t3 = x1*x1+y1*y1, x2*x2+y2*y2, x3*x3+y3*y3
	local x = (t1*(y2-y3)+t2*(y3-y1)+t3*(y1-y2)) / d
	local y = (t1*(x3-x2)+t2*(x1-x3)+t3*(x2-x1)) / d
	local radius = math.sqrt((x1-x)^2+(y1-y)^2)
	return x, y, radius
end

local function checkForCircleEvents(beachline, eventQueue, leftArc, arc, rightArc, dirY)
--	print (' ------- checkForCircleEvents ------- ')
--	print ('arc id', arc.id)

	local c1 = leftArc.cell
	local c2 = arc.cell
	local c3 = rightArc.cell
	local x1, y1 = c1.siteX, c1.siteY
	local x2, y2 = c2.siteX, c2.siteY
	local x3, y3 = c3.siteX, c3.siteY
--	print ('-------- findCircleCenter', x1, y1, x2, y2, x3, y3)
	local x, y, r = findCircleCenter(x1, y1, x2, y2, x3, y3)

	if x then
		local sortY = y + r
		local circleEvent = createCircleEvent(arc, x, y, sortY, r)
--		print ('added circle event:', sortY, 'currend dirY:', dirY)
		table.insert(eventQueue, circleEvent)
	end
end

local function mergeParabolas (arc1, arc2, arc3, dirY)
--	print ('merging, dirY', dirY)
	local fx1, fy1 = arc1.cell.siteX, arc1.cell.siteY
	local fx2, fy2 = arc3.cell.siteX, arc3.cell.siteY
	local x, y = findParabolaCrossing(fx1, fy1, fx2, fy2, dirY)
--	print ('merging by point', x, y)
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
--	print ('--- processPointEvent ---', 'site: '..siteX..' '..siteY)
	local dirY = siteY

--	printBeachlineLength (beachline)

	local oldArc, point = findArc (beachline, siteX)


	if oldArc then
--		print ('point event, arc.id', oldArc.id)
		-- Insert new arc into the beachline
		local arcY = 0
		if oldArc.cell then
			-- (fx, fy, x, dirY)
			-- not sure
			arcY = evaluateParabola(oldArc.cell.siteX, oldArc.cell.siteY, siteX, siteY)
		end
--		print ('arcY', arcY)

		local arcC, p1, p2 = insertArc(beachline, oldArc, cell, siteX, siteY, arcY)


		if arcC then
			-- insert points
			insertVertexPoint (oldArc.cell, p1.point)
			insertVertexPoint (oldArc.cell, p2.point)

			insertVertexPoint (arcC.cell, p1.point)
			insertVertexPoint (arcC.cell, p2.point)

			-- check for left arc to make left circle event
			if arcC.prev.prev then
				local arcB = arcC.prev.prev
				if arcB.prev.prev then
					local arcA = arcB.prev.prev
					checkForCircleEvents(beachline, eventQueue, arcA, arcB, arcC, dirY)
				end
			end

			-- check for right arc to make right circle event
			if arcC.next.next then
				local arcD = arcC.next.next
--				print ('arcD exist')
				if arcD.next.next then
					local arcE = arcD.next.next
--					print ('arcE exist')
					checkForCircleEvents(beachline, eventQueue, arcC, arcD, arcE, dirY)
				end
			end
		end
	elseif point then
		-- special case for vertical alligned site and vertex point
		-- insert new arc to two arcs, not one
	end	
end

local function calculateAngle(x1, y1, x2, y2)
	return math.atan2(y2 - y1, x2 - x1)
end

local function compareAngles(siteX, siteY)
	return function(point1, point2)
		print (point1.x, point1.y)
		print (point2.x, point2.y)
		local angle1 = calculateAngle(siteX, siteY, point1.x, point1.y)
		local angle2 = calculateAngle(siteX, siteY, point2.x, point2.y)
		return angle1 < angle2
	end
end

local function updatePolygon (cell)
	local siteX, siteY = cell.siteX, cell.siteY
	print ('#cell.vertexPoints', #cell.vertexPoints)
	table.sort(cell.vertexPoints, compareAngles(siteX, siteY))

	cell.polygon = {}
	for i, vertexPoint in ipairs (cell.vertexPoints) do
		table.insert (cell.polygon, vertexPoint.x)
		table.insert (cell.polygon, vertexPoint.y)
	end
end

local function processCircleEvent(event, beachline)

	local arc = event.arc
	if not arc.removed then
		local point = {x=event.x, y=event.y}
--		print ('circle event', event.x, event.y)
		local node2 = createNode('point', point, event.x)
		local node1 = arc.prev.prev
		local node3 = arc.next.next
--		insertVertexPoint (arc.cell, node2.point)
--		insertVertexPoint (node1.cell, node2.point)
--		insertVertexPoint (node3.cell, node2.point)
--		print (arc.cell.id, node1.cell.id, node3.cell.id)
		
		updatePolygon (arc.cell)
		
		linkNodes (node1, node2, node3)
		removeNodeLinks (arc.prev)
		removeNodeLinks (arc.next)


	end
end







local function createPoints (number_cells, width, height)
	local points = {}
	for i = 1, number_cells do
		table.insert (points, math.random(0, width))
		table.insert (points, math.random(0, height))
	end
	return points
end


local function newDiagram (points, width, height)
	local diagram = {width=width, height=height}
	local cells = {}
	for i = 1, #points-1, 2 do
		local cell = newCell (points[i], points[i+1])
		table.insert (cells, cell)
	end

	sortCells(cells)

	for id, cell in ipairs (cells) do
		cell.id = id
	end

	diagram.cells = cells

	diagram.beachline = getEmptyBeachline(width, height)
	diagram.eventQueue = createEventQueue (cells)
	diagram.dirY = 0
	diagram.iEvent = 0

	return diagram
end


local function processEvent (eventQueue, beachline)
--	print ('process event')
	sortQueue(eventQueue)

	local event = table.remove (eventQueue) -- take the last element, it's faster
	local dirY = event.sortY -- current directrix Y

	updateBeachline(beachline, dirY)

	if event.point then
		print ('Process point event')
		processPointEvent(event, beachline, eventQueue)
		return dirY, 'point'
	elseif event.circle then
		print ('Process circle event')
		processCircleEvent(event, beachline)
		return dirY, 'circle'
	else
--		print ('Process edge event')
--		on given dirY add edge point and add vertex point to the cell
		return dirY, 'edge'
	end


end


local function getLine(point1, cell, point2, dirY)
	local x1, y1 = point1.x, point1.y
	local x3, y3 = point2.x, point2.y
	local fx, fy= cell.siteX, cell.siteY

--	print ('getLine 1', x1, y1)
--	print ('getLine 3', x3, y3)
--	print ('getLine f', fx, fy)

	if fy == dirY  then
		-- current dir Y is on focus
--		print ('vertical line', fx, y1, fx, fy)

		return {fx, y1, fx, fy}
	else

	end


	local line = {}
	local dx = x3-x1
	local nSteps = 10

	for t = 0, nSteps do
		local x = x1 + dx*t/nSteps
		local y = evaluateParabola (fx, fy, x, dirY)
		table.insert(line, x)
		table.insert(line, y)
	end

--	print ('line, x1, y1, x2, y2', x1, y1, x3, y3)

	return line
end


local function getDrawableBeachLine (beachline, dirY)
	local lines = {}

	local node1 = beachline.headPointNode
	local arc = node1.next

--	print ('getDrawableBeachLine')
	while arc do
--		print ('arc.id', arc.id, 'site:', arc.cell.siteX, arc.cell.siteY)

		local node2 = arc.next
--		print ('arc', arc.id, 'from ', node1.point.x, 'to', node2.point.x)
		local line = getLine (node1.point, arc.cell, node2.point, dirY)
		table.insert (lines, line)
		node1 = node2
		arc = node1.next
	end

--	print ('beachlines drawable:', #lines)
	return lines
end



local function processNextEvent (diagram)
	diagram.iEvent = diagram.iEvent + 1
--	print ('\n -------- next voronoi event', diagram.iEvent)

	local eventQueue = diagram.eventQueue
	if #eventQueue > 0 then
		local beachline = diagram.beachline
		local dirY, str = processEvent (eventQueue, beachline)
		diagram.dirY = dirY
		updateBeachline(beachline, dirY)
		diagram.drawableBeachLines = getDrawableBeachLine (beachline, dirY)

		love.window.setTitle ('dirY: '..dirY..' '..str)

	else
		love.window.setTitle ('no events')
		diagram.drawableBeachLines = nil
	end
end

local function processResult (diagram)
--	print ('voronoiMainLoop')

	local eventQueue = diagram.eventQueue
	local beachline = diagram.beachline

	while #eventQueue > 0 do
		processEvent (eventQueue, beachline)
	end
end


local function getColor (t)
	t = t%1
	-- https://github.com/darkfrei/love2d-lua-tests/blob/main/ore-patches/main.lua
	if t<0.25 then
		return {(t)/0.25,0.25-t,0.25-t}
	elseif t<0.75 then
		return {1,(t-0.25)/0.55,0}
	elseif t>=1 then
		return {0,1,1}
	end

	return {1,1,(t-0.75)/0.25}
end



local function drawBeachline (diagram)
	if diagram.beachline then
		local p1 = diagram.beachline.headPointNode
		love.graphics.line (p1.x, 0, p1.x, diagram.height)
--		love.graphics.print (p1.id, p1.x, diagram.dirY)
		local i = 1
		while p1.next do
			p1 = p1.next.next
			love.graphics.line (p1.x, 0, p1.x, diagram.height)
			local dy = 0
			if (i-1)%2 == 0 then dy = -20 end
			love.graphics.print (p1.id..' '..p1.x, p1.x, diagram.dirY + dy)
			i = i + 1
		end
	end

	local lines = diagram.drawableBeachLines

	if lines then
		for i, line in ipairs (lines) do
			local t = i/#lines
--			love.graphics.setColor (birdColors (t))
			love.graphics.setColor (getColor (t))
			love.graphics.print (i, 10,20*i)
			if #line > 3 then
				love.graphics.line (line)
			end

		end
		love.graphics.setColor (1,1,1)
		love.graphics.line (0, diagram.dirY, diagram.width, diagram.dirY)

	end
end

local function  drawCells (diagram)
	local cells = diagram.cells
	for i, cell in ipairs(cells) do
		local x, y = cell.siteX, cell.siteY
		love.graphics.setColor (0,1,0)
		for i, vertexPoint in ipairs (cell.vertexPoints) do
			love.graphics.line (x, y, vertexPoint.x, vertexPoint.y)
		end

		love.graphics.setColor (0,0,0)
		love.graphics.print (i..' '..#cell.vertexPoints, x, y)
		
		love.graphics.setColor (1,1,0)
		if cell.polygon and #cell.polygon > 4 then
			love.graphics.polygon ('line', cell.polygon)
		end
	end
end

local voronoi = {}
voronoi.createPoints = createPoints -- (number_cells, width, height)
voronoi.newDiagram = newDiagram -- (points, width, height)

voronoi.processNextEvent = processNextEvent -- (diagram)
voronoi.processResult = processResult -- (diagram)

voronoi.drawBeachline = drawBeachline
voronoi.drawCells = drawCells

return voronoi