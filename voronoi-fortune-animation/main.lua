--[[
Copyright 2023 darkfrei

The MIT License
https://opensource.org/license/mit/

Permission is hereby granted, free of charge, to any person obtaining 
a copy of this software and associated documentation files (the “Software”), 
to deal in the Software without restriction, including without limitation 
the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom 
the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included 
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH 
THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]


--vfa = require ('vfa')

local vfa = {}

local function sortXYBackward (list)
	table.sort(list, function(a, b) return a.y > b.y or a.y == b.y and a.x > b.x end)
end


local function sortX (list)
	table.sort(list, function(a, b) return a.x < b.x end)
end

local function newCell (x, y)
	local cell = {x=x, y=y}
--	cell.site = {x=x, y=y}
	cell.edges = {}
	cell.vertices = {}
	return cell
end


local function newPoint (x, y)
	print ("newPoint", tostring(x), tostring(y))
	return {x=x, y=y, point = true}
end

local function setPoint (point, x, y)
	print ("newPoint", tostring(x), tostring(y))
	if x then
		point.x=x
	end
	if y then
		point.y=y
	end
end

local function newParabola (cell)
	return {x=cell.x, y=cell.y, cell = cell}
end



local function reload ()
	vfa.dirY = 0
	vfa.segments = {}
	vfa.parabolaLines = {}
	vfa.beachLine = {}
	vfa.queue = {}
	for i = 1, #vfa.points-1, 2 do
		local x, y = vfa.points[i], vfa.points[i+1]
		table.insert (vfa.queue, newCell (x, y))
	end
	sortXYBackward (vfa.queue)
end

local function getCircumcircle (x1, y1, x2, y2, x3, y3)
	local d = 2*(x1*(y2-y3)+x2*(y3-y1)+x3*(y1-y2))
	local t1, t2, t3 = x1*x1+y1*y1, x2*x2+y2*y2, x3*x3+y3*y3
	local x = (t1*(y2-y3)+t2*(y3-y1)+t3*(y1-y2)) / d
	local y = (t1*(x3-x2)+t2*(x1-x3)+t3*(x2-x1)) / d
	local radius = math.sqrt((x1-x)^2+(y1-y)^2)
	return x, y, radius
end

local function getParabolaCircumcircle (p1, p2, p3)
	local x1, y1 = p1.x, p1.y
	local x2, y2 = p2.x, p2.y
	local x3, y3 = p3.x, p3.y
	return getCircumcircle (x1, y1, x2, y2, x3, y3)
end

local function getParabolaCrossPoint (p1x, p1y, p2x, p2y, dirY) -- focus 1, focus 2, directrix Y
	if (p1y == dirY) and (p1y == dirY) then
		local x = (p1x+p2x)/2
		local y = 0
		return x, y, x, y
	end

	-- calculate the focal length (half the distance from the focus to the directrix) for both foci:
	local f1, f2 = math.abs(dirY-p1y)/2, math.abs(dirY-p2y)/2
	-- calculate the a, b, c coefficients as parabolas difference:
	local a1, a2 = -1/(4*f1), -1/(4*f2)
	local b1, b2 = -2*p1x*a1, -2*p2x*a2
	local c1, c2 = p1x*p1x*a1 + p1y + f1, p2x*p2x*a2 + p2y + f2
	-- calculate the coefficients for the combined parabola formed by subtracting the second parabola from the first:
	local a, b, c = a1-a2, b1-b2, c1-c2
	-- calculate the discriminant to determine the number of intersection points:
	local d = b*b-4*a*c
	if d >=0 then
		-- calculate the x-coordinate of the intersection point:
		local x1 = (-b-math.sqrt (d))/(2*a)
		local x2 = (-b+math.sqrt (d))/(2*a)
		-- calculate the y-coordinate of the intersection point using the equation of the first parabola:
		local y1 = a1*x1*x1 + b1*x1 + c1
		local y2 = a1*x2*x2 + b1*x2 + c1
		-- return the intersection point coordinates (just left one):
		return x1, y1, x2, y2
	end
end

local function getParabolasCrossing (p1, p2, dirY)
	local p1x, p1y = p1.x, p1.y
	local p2x, p2y = p2.x, p2.y
	return getParabolaCrossPoint (p1x, p1y, p2x, p2y, dirY)
end

local function getRandomPoints (amount)
	local points = {}
	for i = 1, amount do
		local x = math.random (Width*0.8) + Width*0.1
		local y = math.random (Height*0.8) + Height*0.1
		table.insert (points, x)
		table.insert (points, y)
	end
	return points
end

function vfa.load ()
	vfa.points = getRandomPoints (8)
--	vfa.points = {260,80, 
----		550, 80, -- special case
--		300, 100, 
--		200,140, 
----		920,130, 
--		980,270, 260,350, 350,460, 290,590, 800,650, 610,780, 680,830, 50,890}
	reload ()
end

local function setDoubleLinking (...)
	local nodes = {...}
	local a = nodes[1]
	for i = 2, #nodes do
		local b = nodes[i]
		a.next = b
		b.prev = a
		a = b
	end
end

local function evaluateParabola (parabola, x, dirY)
	local cell = parabola.cell
	local px, py = cell.x, cell.y
	local f = math.abs(dirY-py)/2
	if (f == 0) then
		-- exception, x is same, y is 0
		return x, 0
	end
	local a = -1/(4*f)
	local b = -2*px*a
	local c = px*px*a + py + f
	return x, a*x*x + b*x + c -- x, y
end

local function getCircleEvent(parabola1, parabola2, parabola3)
	-- Check if the parabolas have the same focus (this indicates a potential circle event)
	if (parabola1.focus == parabola2.focus) 
	or (parabola2.focus == parabola3.focus) 
	or (parabola1.focus == parabola3.focus) then
		-- no circle with two points
		return 
	else
		-- Calculate the intersection point of the three parabolas
		local x1, y1 = parabola1.focus.x, parabola1.focus.y
		local x2, y2 = parabola1.focus.x, parabola2.focus.y
		local x3, y3 = parabola1.focus.x, parabola3.focus.y

		local x, y, radius = getCircumcircle (x1, y1, x2, y2, x3, y3)

		-- Calculate the event's y-coordinate
		local eventY = y + radius -- lower than middle

		local highestFocusParabola = parabola1
		if parabola2.focus.y < highestFocusParabola.focus.y then
			highestFocusParabola = parabola2
		end
		if parabola3.focus.y < highestFocusParabola.focus.y then
			highestFocusParabola = parabola3
		end

		-- Create and return the circle event as a table
		local circleEvent = {
			x = x,
			y = eventY,
			radius = radius,
			parabola = highestFocusParabola
		}
		return circleEvent
	end
end




local function newBeachLine (cell)
	local p2 = newParabola (cell) -- parabola
	local p1 = newPoint (0,0) -- separator
	local p3 = newPoint (Width,0)
--	setDoubleLinking (p1, p2, p3)
	local beachLine = {p1, p2, p3}
	return beachLine
end


local function updateBeachLineX (beachLine, dirY)
	for i = 2, #beachLine-3, 2 do -- every parabola
		local p2 = beachLine[i] -- parabola
		local p3 = beachLine[i+1] -- point
		local p4 = beachLine[i+2] -- parabola
		if p2.cell.y == p4.cell.y then
			local x = (p2.cell.x + p4.cell.x)/2
			setPoint (p3, x)
		else
			-- update cross point
			local x, y = getParabolasCrossing (p2, p4, dirY)
			setPoint (p3, x)
		end
	end
end

local function updateBeachLine (beachLine, dirY)
	for i = 2, #beachLine-3, 2 do -- every parabola
		local p2 = beachLine[i] -- parabola
		local p3 = beachLine[i+1] -- point
		local p4 = beachLine[i+2] -- parabola
		if p2.cell.y == p4.cell.y then
			local x = (p2.cell.x + p4.cell.x)/2
			p3.x = x
		else
			-- update cross point
			local x, y = getParabolasCrossing (p2, p4, dirY)
			if not x then
				error ('no x')
			end
			p3.x, p3.y = x, y
		end
	end
end


local function findIndex (beachLine, cell)
	local x = cell.x
	for i = 1, #beachLine-2, 2 do
		local p3 = beachLine[i+2]
		if (not (p3 and p3.x)) or (not x) then
			serpent = require ("serpent")
			print (serpent.block (beachLine))
			print (i, #beachLine)
			print (tostring (p3.x), tostring (x))
		end
		if p3.x >= x then
			return i
		end
	end
end


local function insertParabola (beachLine, cell, index)
--	print ('insertParabola', index)
	local x = cell.x
	local dirY = cell.y
	
	local p1 = beachLine[index] -- point
	local p7 = beachLine[index+2] -- point
	local p2Old = table.remove (beachLine, index+1)  -- old parabola
	
	local p2 = newParabola (p2Old.cell)
	local p4 = newParabola (cell)
	local p6 = newParabola (p2Old.cell)
	local x3, y3 = evaluateParabola (p2Old, x, dirY)
--	print ('x3, y3', x3, y3)
	local p3 = newPoint (x3, y3)
	local p5 = newPoint (x3, y3)
	
	table.insert (beachLine, index+1, p2)
	table.insert (beachLine, index+2, p3)
	table.insert (beachLine, index+3, p4)
	table.insert (beachLine, index+4, p5)
	table.insert (beachLine, index+5, p6)
	
	table.insert (vfa.segments, {p3, p5})
	
--	print ('inserted point', cell.x, cell.y, #beachLine)
--	for i = 1, #beachLine do
--		local p = beachLine[i]
--		print (i, p.x, p.y, tostring(p.cell == nil))
--	end
--	setDoubleLinking (p1, p2, p3, p4, p5, p6, p7)
end

local function insertCircleEvent (queue, beachLine, index)
	local p4 = beachLine[index+3]
	local p6 = beachLine[index+5]
	local p8 = beachLine[index+7]
	if p4 and p8 then
		local x, y, radius = getParabolaCircumcircle (p4, p6, p8)
		local yEvent = y + radius
		local min = p4
		if p6.y < min.y then
			min = p6
		end
		if p8.y < min.y then
			min = p8
		end
		local sep = newPoint (x, yEvent)
		local circle = {x=x, y=yEvent, sep=sep, par = min}
	end
end


local function pointEvent (cell)
	local dirY = cell.y

	if #vfa.beachLine == 0 then
		vfa.beachLine = newBeachLine (cell)
--		print ('beachLine created')
		return
	end

	
	for i = 1, #vfa.beachLine do
		if not vfa.beachLine[i].x then
			error ('no x'..i)
		end
	end
	
	local p2 = vfa.beachLine [2] -- parabola
	if (#vfa.beachLine == 3) and (p2.y == dirY) then
		-- special case
		local p4 = newParabola (cell) -- parabola
		local p1 = vfa.beachLine [1] -- point
		local p3 = newPoint ((p2.x+p4.x)/2, 0) -- point
		local p5 = vfa.beachLine [3] -- point 
		table.insert (vfa.beachLine, 3, p3)
		table.insert (vfa.beachLine, 4, p4)
		
		
--		setDoubleLinking (p1, p2, p3, p4, p5)
--		print ('special case beachLine: y=y')
		return
	end


	updateBeachLineX (vfa.beachLine, dirY)
	

	local index = 1
	if #vfa.beachLine > 3 then 
		index = findIndex (vfa.beachLine, cell)
	end

	insertParabola (vfa.beachLine, cell, index)
	
	if #vfa.beachLine >= 9 then 
--		print ('index point', index)
		insertCircleEvent (vfa.queue, vfa.beachLine, index)
	end
end



local function circleEvent (circle)
	local separator = circle.sep
	local index
	for i = 3, #vfa.beachLine, 2 do
		local sep = vfa.beachLine[i]
		if separator == sep then
			index = i-1
			break
		end
	end

	if index then
		local p1 = vfa.beachLine[index-3]
		local p5 = vfa.beachLine[index+3]
		local s2 = table.remove (vfa.beachLine, index-1)
		local p3 = table.remove (vfa.beachLine, index-1)
		local s4 = table.remove (vfa.beachLine, index-1)
--		print (tostring(circle.cx))
		s2.x, s2.y = circle.cx, circle.cy
		s4.x, s4.y = circle.cx, circle.cy

		local pNew = {x=circle.cx, y=circle.cy}
		table.insert (vfa.beachLine, index-1, pNew)

		table.insert (vfa.segments, {s2, pNew})
--		table.insert (vfa.segments, {p5, pNew})
	end
end


local function getParabolaLine (x, y, dirY, xMin, xMax) -- focus, directrix, horizontal limits
-- Function to generate points along a parabola curve
--	xMin, xMax = math.min (xMin, xMax), math.max (xMin, xMax)
	local line = {}
	local f = math.abs(dirY-y)/2
	local a = -1/(4*f) 
	local b = -2*x*a
	local c = x*x*a + y + f
	local nSteps = math.floor((xMax-xMin)/5)
	local step = (xMax-xMin)/nSteps
	for i = 0, nSteps do
		local x0 = xMin + i * step
		local y0 = a*x0*x0 + b*x0 + c
		table.insert (line, x0)
		table.insert (line, y0)
	end
	return line
end


local function cleanBeachLine (beachLine, dirY)
	-- no circle event right now, placeholder
	local p1 = beachLine[1]
--	local p2 = beachLine[3]
	for i = 2, #vfa.beachLine-1, 2 do
		local p2 = beachLine[i]
		local p3 = beachLine[i+1]
		local xMax = p2.x
			if p1.x > p3.x then
			p2.toRemove = true
		end
		p1 = p3
	end
	
	local i = 2
	while vfa.beachLine[i] do
		local focus = vfa.beachLine[i]
		if focus.toRemove then
			local p5 = vfa.beachLine[i+2] -- parabola
			local p1 = vfa.beachLine[i-2] -- parabola
			local p4 = table.remove (vfa.beachLine, i+1) -- point
			local p3 = table.remove (vfa.beachLine, i) -- old parabola
			local p2 = table.remove (vfa.beachLine, i-1) -- point
			local x, y = (p2.x+p4.x)/2, (p2.y+p4.y)/2
			if p1 and p5 then
				x, y = getParabolasCrossing (p1, p5, dirY)
				print ('x', tostring (x))
			end
			local p2New = newPoint (x, y)
			print ('p2New', tostring(p2New.x), tostring(p2New.y))
			table.insert (vfa.beachLine, i-1, p2New)
			
			table.insert (vfa.segments, {p4, p2New})
--			table.insert (vfa.segments, {p2, p2New})
--			setDoubleLinking (p1, p2New, p5)
		else
			i = i + 2
		end
	end
end


function vfa.update ()
--	for i = #vfa.queue, 1, -1 do
	while (#vfa.queue > 0) do -- true
		sortXYBackward (vfa.queue)
		local event = vfa.queue[#vfa.queue]
		if vfa.dirY >= event.y then
			table.remove (vfa.queue, #vfa.queue)
			if event.circle then
				circleEvent (event)
			else
				pointEvent (event)
			end
--			sortXYBackward (vfa.queue)
		else
			break
		end
	end

	-- update parabolas
	local dirY = vfa.dirY
	updateBeachLine (vfa.beachLine, dirY)
	cleanBeachLine (vfa.beachLine, dirY)
	
	vfa.parabolaLines = {}
	for i = 2, #vfa.beachLine-1, 2 do
		local sep1 = vfa.beachLine[i-1]
		local focus = vfa.beachLine[i]
		local sep2 = vfa.beachLine[i+1]

		local xMin = sep1.x
		local xMax = sep2.x

		local line = getParabolaLine (focus.x, focus.y, dirY, xMin, xMax)
		if #line > 3 then
			table.insert (vfa.parabolaLines, line)
		end

	end

end

function vfa.draw ()

	love.graphics.setColor (1,1,1)
	love.graphics.points (vfa.points)
	for i = 1, #vfa.points, 2 do
		love.graphics.circle ('line', vfa.points[i], vfa.points[i+1], 3)
	end

	love.graphics.line (0, vfa.dirY, Width, vfa.dirY)

	-- points
	love.graphics.setColor (1,1,0)
	for i = 1, #vfa.beachLine, 2 do
		local sep = vfa.beachLine[i]
		love.graphics.circle ('line', sep.x, sep.y, 5)
--		love.graphics.print (i, sep.x, sep.y-20)
	end

	-- queue
	love.graphics.setColor (1,0,0)
	for i, event in ipairs (vfa.queue) do
		if event.circle then
			love.graphics.circle ('line', event.cx, event.cy, event.r)
		else
			love.graphics.circle ('line', event.x, event.y, 3)
		end
	end

	
	love.graphics.setColor (1,1,1)
	for i, line in ipairs (vfa.parabolaLines) do
		love.graphics.line (line)
	end

	love.graphics.setColor (0,1,0)
	for i = 2, #vfa.beachLine-1, 2 do
		local focus = vfa.beachLine[i]
		love.graphics.circle ('line', focus.x, focus.y, 5)
--		love.graphics.print (i, focus.x+i, focus.y-20)
	end

	love.graphics.setColor (0,1,1)
	for i, segment in ipairs (vfa.segments) do
		love.graphics.line (segment[1].x, segment[1].y, segment[2].x, segment[2].y)
	end
end

-------------------------------------
-- love
-------------------------------------

--love.window.setMode(1200, 900)
--love.window.setMode(800, 800)
love.window.setMode(400, 400)
Width, Height = love.graphics.getDimensions( )


function love.load()
	love.window.setTitle (Width ..' x '.. Height)
	-- preheat
	for i = 1, 6 do math.random () end


	vfa.load ()
--	pause = false
	pause = true
end


function love.update(dt)
	if not pause then
		vfa.dirY = vfa.dirY+1*60*dt

		if vfa.dirY > Height then
			vfa.points = getRandomPoints (8)
			reload ()
		end
		vfa.update ()
	end
end


function love.draw()
	love.graphics.setLineWidth (2)
	love.graphics.setLineStyle ('rough')
	vfa.draw ()
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "s" then
		vfa.dirY = vfa.dirY+1
		vfa.update ()
	elseif key == "space" then
		pause = not pause
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	reload ()
	vfa.dirY = y
	vfa.update ()
end

function love.mousemoved( x, y, dx, dy, istouch )

end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end