-- 2024-03-31
-- 2024-04-02

require ('math-vb')
require ('events-vb')
require ('draw-vb')

frame = {x=50,y=50, w=700,h=500}

vertices = {
	400, 450,
	550, 250,
	250, 250,

}

-- defaul directrix Y
dirY = 260

-- preparing
---------------------------------------------------------------------


-- creating sites
--sites = {}
cells = {}
for i = 1, #vertices-1, 2 do
	local x = vertices[i]
	local y = vertices[i+1]
	local index = (i-1)/2+1
	local cell = {
		x=x, y=y, -- site and parabola focus
	}
	table.insert (cells, cell)
end


-- creating queue
eventQueue = {}
for i, cell in ipairs (cells) do
	local event = {}
	event.type = 'site' -- also 'circle' and 'edge'
	event.valid = true -- site event is always valid
	event.cell = cell
	cell.siteEvent = event
	event.x = cell.x
	event.y = cell.y
	event.priority = 2
	table.insert (eventQueue, event)
end
--printEventQueue (eventQueue, 'not sorted')
sortEventQueue (eventQueue)
--printEventQueue (eventQueue, 'sorted')

function resetBeachlLines ()
	beachLines = {} -- array of arcs and lines
	local flatBeachLine = newFlatBeachline (frame.x, frame.x+frame.w, frame.y)
	table.insert (beachLines, flatBeachLine)
--	print ('#beachLines', #beachLines)
end

resetBeachlLines ()

---------------------------------------------------------------------


function updateDiagram ()
	resetBeachlLines ()
	local queue = {}
	for i, event in ipairs (eventQueue) do
		if event.y <= dirY then
			table.insert (queue, event)
		end
	end

	local n = 0
	while #queue > 0 do
		n = n+1
		sortEventQueue (eventQueue)
		local event = getEventFromQueue (queue)
		if event.valid then
--			print ('----------------------')
--			print ('event', n)
			runEvent[event.type](event)
--			print (event.type, event.x, event.y)
		end
	end
	love.window.setTitle('done events: '.. n)
end



function updateBeachlines ()
	beachLines = {}

	for i = 1, #vertices-1, 2 do
		local fx = vertices[i]
		local fy = vertices[i+1]
--		print (i, y, dirY)
		if dirY >= fy then
			local beachLine = {}
			table.insert (beachLines, beachLine)
			local left_x, right_x = getFocusParabolaRoots (fx, fy, frame.y, dirY)

			beachLine.line = {left_x, frame.y, right_x, frame.y}
			local ax, ay = left_x, frame.y
			if ax < frame.x then
				local ax1 = frame.x
				local ay1 = evaluateParabola (fx, fy, ax1, dirY)
				beachLine.line[1] = ax1 
				beachLine.line[2] = ay1
				table.insert (beachLine.line, 3, ax1)
				table.insert (beachLine.line, 4, frame.y)
				ax = ax1
				ay = ay1
			end
			beachLine.x1 = ax

			local bx, by = right_x, frame.y
			if bx > frame.x + frame.w then
				local bx1 = frame.x + frame.w
				local by1 = evaluateParabola (fx, fy, bx1, dirY)
				beachLine.line[#beachLine.line-1] = bx1 
				beachLine.line[#beachLine.line] = by1
				table.insert (beachLine.line, #beachLine.line-1, bx1)
				table.insert (beachLine.line, #beachLine.line-1, frame.y)
				bx = bx1
				by = by1
			end
			beachLine.x2 = ay

--			local cx, cy = getBezierThirdControlPoint(fx, fy, ax, ay, bx, by+1)
			local cx, cy = getBezierControlPoint(fx, fy, ax, bx, dirY)
			beachLine.controlPoints = {
				ax, ay,
				cx, cy,
				bx, by,
			}
--			print ('ax, ay', ax, ay)
--			print ('cx, cy', cx, cy)
--			print ('bx, by', bx, by)
			if #beachLine.controlPoints > 5 and beachLine.controlPoints[3] ~= nil then
				local bezier = love.math.newBezierCurve (beachLine.controlPoints)
				local bezierLine = bezier:render()
				beachLine.bezierLine = bezierLine
			end
		end
	end
end

--updateBeachlines ()

function love.load ()
--	print ('load', '#beachLines:', #beachLines)
	updateDiagram ()
end

function love.draw ()
	drawFrame ()

	drawDirectrix ()

	drawSitesVertices ()



	drawBezierControlLines ()

	drawFrameCollisionLines ()
	drawBezierArcs ()


end



function love.mousemoved (x, y)
	dirY = y
	updateDiagram ()
--	updateBeachlines ()
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end