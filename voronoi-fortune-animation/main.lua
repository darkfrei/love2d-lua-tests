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
	table.sort(list, function(a, b) return a.y > b.y or a.y == b.y and a.x > b.x or false end)
end

local function sortX (list)
	table.sort(list, function(a, b) return a.x < b.x end)
end

local function reload ()
	vfa.dirY = 0
	vfa.segments = {}
	vfa.parabolaLines = {}
	vfa.sweepLine = {}
	vfa.queue = {}
	for i = 1, #vfa.points-1, 2 do
		local x, y = vfa.points[i], vfa.points[i+1]
		table.insert (vfa.queue, {x=x, y=y, point=true})
	end
	sortXYBackward (vfa.queue)
	for i = #vfa.queue, 1, -1 do
		local event = vfa.queue[i]
--		print (i, event.x, event.y)
	end
end

local function getCircumcircle (x1, y1, x2, y2, x3, y3)
	local d = 2*(x1*(y2-y3)+x2*(y3-y1)+x3*(y1-y2))
--	print (d)
	local t1, t2, t3 = x1*x1+y1*y1, x2*x2+y2*y2, x3*x3+y3*y3
	local x = (t1*(y2-y3)+t2*(y3-y1)+t3*(y1-y2)) / d
	local y = (t1*(x3-x2)+t2*(x1-x3)+t3*(x2-x1)) / d
	local radius = math.sqrt((x1-x)^2+(y1-y)^2)
	return x, y, radius
end


local function getParabolaCrossPoint (focus1, focus2, dirY) -- focus 1, focus 2, directrix
-- Function to find the intersection point of two parabolas
	local p1x, p1y = focus1.x, focus1.y
	local p2x, p2y = focus2.x, focus2.y
	local f1 = math.abs(dirY-p1y)/2
	local f2 = math.abs(dirY-p2y)/2

	local a1 = -1/(4*f1)
	local a2 = -1/(4*f2)
	local b1 = -2*p1x*a1
	local b2 = -2*p2x*a2
	local c1 = p1x*p1x*a1 + p1y + f1
	local c2 = p2x*p2x*a2 + p2y + f2
	local a = a1-a2
	local b = b1-b2
	local c = c1-c2

	local d = b*b-4*a*c
	local x, y
	if d >=0 then
		x = (-b-math.sqrt (d))/(2*a)
		y = a1*x*x + b1*x + c1
	end
	return x, y
end

function vfa.load ()

	vfa.points = {}
--	vfa.points = {101,100, 201, 200, 301, 300, 401, 400, 501, 500, 601, 600}

	for i = 1, 8 do
		local x = math.random (Width*0.5) + Width*0.25
		local y = math.random (Height*0.5) + Height*0.25
		table.insert (vfa.points, x)
		table.insert (vfa.points, y)
--		table.insert (vfa.points, x+200)
--		table.insert (vfa.points, y)
	end
	reload ()
end

local function pointEvent (focus)
--	local dirY = vfa.dirY
	local dirY = focus.y + 0.0001
	if #vfa.sweepLine == 0 then
		local sep1 = {x=0, y=0}
		local sep2 = {x=Width, y=0}
		table.insert (vfa.sweepLine, sep1)
		table.insert (vfa.sweepLine, focus)
		table.insert (vfa.sweepLine, sep2)
		return
	end

	local index
	for i = 3, #vfa.sweepLine, 2 do
		local sep = vfa.sweepLine[i]
		if not sep.x then
			return
		end
		if focus.x < sep.x then
			index = i-1
			break
		end
	end

	local focusOld = vfa.sweepLine[index]
	local sep2x, sep2y = getParabolaCrossPoint (focusOld, focus, dirY)
	local sep3x, sep3y = getParabolaCrossPoint (focus, focusOld, dirY)
	print (sep2x, sep3x)
	if sep2x and sep3x then
		local sep2 = {x=sep2x, y=sep2y}
		local sep3 = {x=sep3x, y=sep3y}

		table.insert (vfa.sweepLine, index, focusOld)
		table.insert (vfa.sweepLine, index+1, sep2)
		table.insert (vfa.sweepLine, index+2, focus)
		table.insert (vfa.sweepLine, index+3, sep3)

		table.insert (vfa.segments, {sep2, sep3})
	end


	--
	local circleEvent = {}
	local focus1 = vfa.sweepLine[index-2]
	local focus2 = vfa.sweepLine[index]
	local focus3 = vfa.sweepLine[index+2]
	local focus4 = vfa.sweepLine[index+4]
	local focus5 = vfa.sweepLine[index+6]

	local str = ''
	local circle1, circle2
	if focus1 and focus2 then
		str = str .. ' '.. (index-2)..' '.. (index)..' '.. (index+2) .. '; '
		local x, y, r = getCircumcircle (focus1.x, focus1.y, focus2.x, focus2.y, focus3.x, focus3.y)
		circle1 = {cx=x, cy=y, x=x, y=y+r, r=r, sep = vfa.sweepLine[index+1]}

	end
	if focus4 and focus5 then
		str = str .. ' '.. (index+2)..' '.. (index+4)..' '.. (index+6) .. '.'
		local x, y, r = getCircumcircle (focus3.x, focus3.y, focus4.x, focus4.y, focus5.x, focus5.y)
		circle2 = {cx=x, cy=y, x=x, y=y+r, r=r, sep = vfa.sweepLine[index+5]}
	end

	if circle1 then
		table.insert (vfa.queue, circle1)
	end
	if circle2 then
		table.insert (vfa.queue, circle2)
	end
	love.window.setTitle (str)
end



local function circleEvent (circle)
	local separator = circle.sep

	local index
	for i = 3, #vfa.sweepLine, 2 do
		local sep = vfa.sweepLine[i]
		if separator == sep then
			index = i-1
			break
		end
	end

	if index then
		local p1 = vfa.sweepLine[index-3]
		local p5 = vfa.sweepLine[index+3]
		local s2 = table.remove (vfa.sweepLine, index-1)
		local p3 = table.remove (vfa.sweepLine, index-1)
		local s4 = table.remove (vfa.sweepLine, index-1)
		print (tostring(circle.cx))
		s2.x, s2.y = circle.cx, circle.cy
		s4.x, s4.y = circle.cx, circle.cy

		local pNew = {x=circle.cx, y=circle.cy}
		table.insert (vfa.sweepLine, index-1, pNew)

		table.insert (vfa.segments, {s2, pNew})
--		table.insert (vfa.segments, {p5, pNew})
	end
end


local function getParabolaLine (x, y, dirY, xMin, xMax) -- focus, directrix, horizontal limits
-- Function to generate points along a parabola curve
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

function vfa.update ()

	if vfa.dirY > Height then
		reload ()
	end

	
	for i = #vfa.queue, 1, -1 do
		sortXYBackward (vfa.queue)
		local event = vfa.queue[i]
		if vfa.dirY > event.y then
			table.remove (vfa.queue, i)
			if event.point then
				pointEvent (event)
			else
				circleEvent (event)
			end
			sortXYBackward (vfa.queue)
		else
			break
		end
	end

	-- update separators
	for i = 3, #vfa.sweepLine-2, 2 do
		local sep = vfa.sweepLine[i]
		local focus1 = vfa.sweepLine[i-1]
		local focus2 = vfa.sweepLine[i+1]
		local x, y = getParabolaCrossPoint (focus1, focus2, vfa.dirY)
		sep.x, sep.y = x, y
	end

	-- update parabolas
	vfa.parabolaLines = {}
	for i = 2, #vfa.sweepLine-1, 2 do
		local sep1 = vfa.sweepLine[i-1]
		local focus = vfa.sweepLine[i]
		local sep2 = vfa.sweepLine[i+1]

		local xMin = sep1.x or 0
		local xMax = sep2.x or 0

		local line = getParabolaLine (focus.x, focus.y, vfa.dirY, xMin, xMax)
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

	love.graphics.setColor (1,1,0)
	for i = 1, #vfa.sweepLine, 2 do
		local sep = vfa.sweepLine[i]
		love.graphics.circle ('line', sep.x, sep.y, 5)
		love.graphics.print (i, sep.x, sep.y-20)
	end

	love.graphics.setColor (1,0,0)
	for i, event in ipairs (vfa.queue) do
		if event.point then
			love.graphics.circle ('line', event.x, event.y, 3)
		else
			love.graphics.circle ('line', event.cx, event.cy, event.r)
		end
	end

	love.graphics.setColor (1,1,1)
	for i, line in ipairs (vfa.parabolaLines) do
		love.graphics.line (line)
	end

	love.graphics.setColor (0,1,0)
	for i = 2, #vfa.sweepLine-1, 2 do
		local focus = vfa.sweepLine[i]
		love.graphics.circle ('line', focus.x, focus.y, 5)
		love.graphics.print (i, focus.x+i, focus.y-20)
	end
	
	love.graphics.setColor (0,1,1)
	for i, segment in ipairs (vfa.segments) do
		love.graphics.line (segment[1].x, segment[1].y, segment[2].x, segment[2].y)
	end
end

-------------------------------------
-- love
-------------------------------------

love.window.setMode(800, 800)
Width, Height = love.graphics.getDimensions( )


function love.load()
	-- preheat
	for i = 1, 6 do math.random () end

	vfa.load ()
	pause = false
end


function love.update(dt)
	if not pause then
		vfa.dirY = vfa.dirY+4*60*dt
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