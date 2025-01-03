-- print (love.getVersion( ))

-- disable log: 
--print = function () end

love.window.setMode( 1920, 1080 )

love.graphics.setLineStyle ('rough')


local width = love.graphics.getWidth()
local height = love.graphics.getHeight() 

local minX = 10
local maxX = width-10

local sites = {}


local globalEventY = 950

local epsilon = 1e-9



--table.insert (sites, {x=1200, y=300})

local beachCurvesArray = {} -- array of arrays for lines to draw beachlines

local lines = {}

local renderingCircleEvents = {}

local testEdges = {}

local function evaluateArc (arc, x, eventY)
	local y = (x - arc.x)^2 / (2 * (arc.y - eventY)) + (arc.y + eventY) / 2
	return y
end


local function getEventY(arc1, arc2, x)
	-- for removing out of border arcs
	-- not tested
	-- not used
	-- [coefficients for quadratic equation in eventY]
	local A1 = arc1.y
	local A2 = arc2.y
	local B1 = arc1.x
	local B2 = arc2.x

	local a = 1 / (2 * (A1 - x)) - 1 / (2 * (A2 - x))
	local b = (A1 + x) / (2 * (A1 - x)) - (A2 + x) / (2 * (A2 - x))
	local c = ((x - B1)^2 / (2 * (A1 - x))) - ((x - B2)^2 / (2 * (A2 - x)))

	-- [quadratic equation: a * eventY^2 + b * eventY + c = 0]
	local discriminant = b * b - 4 * a * c

	if discriminant < 0 then
		return nil -- no solution
	end

	-- [find the two possible roots for eventY]
	local sqrtDiscriminant = math.sqrt(discriminant)
	local eventY1 = (-b + sqrtDiscriminant) / (2 * a)
	local eventY2 = (-b - sqrtDiscriminant) / (2 * a)

	-- [return the largest valid eventY, since the sweep line moves downwards]
	return math.max(eventY1, eventY2)
end




local function getCircumcircle (x1, y1, x2, y2, x3, y3)
	local d = 2 * (x1*(y2-y3)+x2*(y3-y1)+x3*(y1-y2))
	if math.abs(d) < 0.000000000001 then return end
	local t1, t2, t3 = x1*x1+y1*y1, x2*x2+y2*y2, x3*x3+y3*y3
	local x = (t1 * (y2 - y3) + t2 * (y3 - y1) + t3 * (y1 - y2)) / d
	local y = (t1 * (x3 - x2) + t2 * (x1 - x3) + t3 * (x2 - x1)) / d
	local radius = math.sqrt((x1-x)^2 + (y1-y)^2)

	return x, y, radius
end

local function calculateCircle (p1, p2, p3)
	return getCircumcircle (p1.x, p1.y, p2.x, p2.y, p3.x, p3.y)
end


local processCircleEvent
local addCircleEvent

-- updates the circle event associated with an arc, or creates a new one if necessary
local function updateCircleEvent(arc, beachline, events, nEvent)
	local currentIndex
	for index, beachArc  in ipairs (beachline) do
		if beachArc  == arc then
			currentIndex = index
			break
		end
	end

	-- if the arc is not in the beachline, exit
	if not currentIndex then 
		print ('arc not in beachline')
		return 
	end

	local prevArc = beachline[currentIndex-1]
	local currentArc = beachline[currentIndex]
	local nextArc = beachline[currentIndex+1]

	-- if there's no next arc, this arc is at the end of the beachline
	if not nextArc then
		print('updateCircleEvent: arc is the last one in the beachline')
		return
	end

	if not prevArc then
		print('updateCircleEvent: arc is the first one in the beachline')
		return
	end

	-- calculate the circle formed by the three sites
	local circleX, circleY, radius = calculateCircle(prevArc.site, currentArc.site, nextArc.site)
	if not radius then
		print('no valid circle found for the arcs')
		return -- no valid circle, exit
	end


	-- update or add the circle event
	if currentArc.removingEvent then

		local circleEvent = currentArc.removingEvent
		circleEvent.x = circleX
		circleEvent.y = circleY + radius
		circleEvent.endY = circleY
		print("updated circle event:", circleEvent.x, circleEvent.y)
	else
		print("no existing circle event for arc:", currentArc, 'adding new:')

		addCircleEvent(currentArc, beachline, events, nEvent)
	end
end

-- processes a circle event by removing the corresponding arc and updating the beachline
function processCircleEvent (event, beachline, events, nEvent)
	local currentIndex
--	for index, arc in ipairs (beachline) do
--		if arc == event.arc then
--			currentIndex = index
--			break
--		end
--	end

	for index = 2, #beachline-1 do
		local arc = beachline[index]
		if arc == event.arc then
			currentIndex = index
			break
		end
	end

	-- if the arc is not found, exit
	if not currentIndex then 
		return 
	end


	local prevArc = beachline[currentIndex-1]
	local currentArc = beachline[currentIndex]
	local nextArc = beachline[currentIndex+1]

	-- x-coordinate of the circle's center
	local x = event.x -- x coordinate of circle

	if currentArc and currentArc.removingEvent and event == currentArc.removingEvent then


		local gap = math.abs(currentArc.minX - currentArc.maxX)
		print ('processCircleEvent', 'arc removed', currentIndex)

		print ('processCircleEvent', 'gap: '..gap)
		if gap < epsilon then

			print('processCircleEvent: removing arc with minimal gap')

			prevArc.maxX = x
			nextArc.minX = x

			table.remove (beachline, currentIndex)

			updateCircleEvent(prevArc, beachline, events, nEvent)
			updateCircleEvent(nextArc, beachline, events, nEvent)

		else
			print('processCircleEvent: error - gap too large:', gap)
		end

	end

end

function addCircleEvent(currentArc, beachline, events, nEvent)
	print ('addCircleEvent', 'nEvent: '..nEvent)
	local currentIndex
	for index, arc in ipairs (beachline) do
		if arc == currentArc then
			currentIndex = index
			break
		end
	end

	if not currentIndex then 
		print ('addCircleEvent', 'no current index: ')
		return 
	end

	print ('addCircleEvent', 'currentIndex: '.. currentIndex)

	local leftArc = beachline[currentIndex - 1]
	local rightArc = beachline[currentIndex + 1]

	if not leftArc and not rightArc then
		print ('addCircleEvent', 'no left arc', 'no right arc')
		return
	elseif not leftArc then
		print ('addCircleEvent', 'no left arc', 'arc ' ..currentIndex ..' of ' .. #beachline)
		return
	elseif not rightArc then
		print ('addCircleEvent', 'no right arc', 'arc ' ..currentIndex ..' of ' .. #beachline)
		return
	end

	if leftArc.site == rightArc.site then
		error ('same sites!')
	end

	local circleX, circleY, radius = calculateCircle(
		leftArc.site, currentArc.site, rightArc.site
	)

	if not radius then return end
	print ('arc '..currentIndex, 'circle x:'..circleX..'r:'..radius)


	-- lower than site
	if circleY and (circleY+radius) > currentArc.site.y then
--		love.graphics.arc( drawmode, x, y, radius, angle1, angle2, segments )

		local renderingCircle = {
			drawmode = 'line',
			x = circleX,
			y = circleY,
			radius = radius,
			lines = {
				{circleX, circleY, leftArc.x, leftArc.y},
				{circleX, circleY, currentArc.x, currentArc.y},
				{circleX, circleY, rightArc.x, rightArc.y},
			}
		}
		table.insert (renderingCircleEvents, renderingCircle)

		local circleEvent = {
			x = circleX,
			y = circleY + radius,
			endY = circleY,
			arc = currentArc, -- arc to removing

--			event.process(event, beachline, events)
			process = processCircleEvent,
			type = 'circle',
			nEvent = nEvent, -- added on
		}
		print ('addCircleEvent', 'nEvent: ' .. circleEvent.nEvent)


		if currentArc.removingEvent then
			if currentArc.removingEvent.y > circleEvent.y then
				print ('removingEvent y:', currentArc.removingEvent.y, circleEvent.y)
				currentArc.removingEvent = circleEvent
			end
		else
			currentArc.removingEvent = circleEvent
		end

		table.insert (events, circleEvent)
--		-- print ('circle event added:', #events)

	end

end

local function getRightEdgeDirectrix(prevArc, arc, x)
	-- Уравнения параболы: 
	-- Для prevArc: (x - px)^2 = 2 * (py - d) * (y - d)
	-- Для arc: (x - ax)^2 = 2 * (ay - d) * (y - d)
	-- Где px, py — фокус prevArc, ax, ay — фокус arc, d — директриса.

	local px, py = prevArc.x, prevArc.y
	local ax, ay = arc.x, arc.y

	-- Уравнение для y:
	-- ((x - px)^2 / (2 * (py - d))) + ((py + d) / 2) =
	-- ((x - ax)^2 / (2 * (ay - d))) + ((ay + d) / 2)

	-- Решим для d:
	local a1 = (x - px)^2
	local a2 = (x - ax)^2

	local num = a1 * (ay - py) + a2 * (py - ay) + 2 * (py * ay - py^2 + ay^2)
	local den = 2 * (a1 - a2 + py - ay)

	if den == 0 then
		return nil -- Проблема: арки слишком близко или параллельны.
	end

	return num / den
end

local function processRightEdgeEvent (event, beachline, events, nEvent)

	local currentIndex
	for index, arc in ipairs (beachline) do
		if arc == event.arc then
			currentIndex = index
			break
		end
	end
	if not currentIndex then return end
	local currentArc = beachline[currentIndex]
	local prevArc = beachline[currentIndex-1]

	if currentIndex == #beachline then
		-- last one
		if currentArc and currentArc.removingEvent 
		and event == event.arc.removingEvent then
			-- this one
			print ('removing arc: '.. currentIndex)
			print ('current arc limits:', currentArc.minX, currentArc.maxX)
			print ('prev arc limits:', prevArc.minX, prevArc.maxX)

			-- remove last:
			table.remove (beachline)
		end
	end
end

-- function to find the intersection point of a line and a straight line
local function findIntersectionLineFoci (A, B, C, f1, f2)
	-- step 1: find point C
	local Cx = (f1.x + f2.x) / 2
	local Cy = (f1.y + f2.y) / 2

	-- step 2: find two points defining the line through point C
	local dx = f2.x - f1.x
	local dy = f2.y - f1.y

	local length = math.sqrt(dx^2 + dy^2)
	-- normal
	local nx = dy / length
	local ny = -dx / length

	local x1 = Cx + nx
	local y1 = Cy + ny

	local x2 = Cx
	local y2 = Cy

	print ('control A, B, C:', A, B, C)
	print ('control x1, y1, x2, y2:', x1, y1, x2, y2)

	-- step 3: find the intersection with the line Ax + By + C = 0
	-- substitute into the line equation Ax + By + C = 0
	-- get the equation for parameter t

	local denominator = A * dy - B * dx

	if denominator == 0 then
		return nil -- lines are parallel, no intersection
	end

--	local t = -(A * x1 + B * y1 + C) / denominator
	local t = -(A * Cx + B * Cy + C) / denominator


	-- substitute t back to find the intersection point
	local x = Cx + t * dy
	local y = Cy - t * dx



	print ('control x, y:', x, y)
	return x, y -- return the intersection point
end





local function distance (x1, y1, x2, y2)
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

testPoints = {}

local function addRightEdgeEvent(prevArc, arc, events, nEvent)
	print (''..nEvent)
	local A = 1
	local B = 0
	local C = -maxX
	local f1 = prevArc.site
	local f2 = arc.site
	local ix, iy = findIntersectionLineFoci (A, B, C, f1, f2, prevArc, arc)
	print ('addRightEdgeEvent', 'intersection', ix, iy)
	

	if not ix then
		print ('no crossing')
		return
	end
	table.insert (testPoints, {x=ix, y=iy})
	
	local dist = distance (f1.x, f1.y, ix, iy)

	local eventY = iy + dist


	print ('####### rightEdgeDirectrix', iy, dist, eventY)
	if eventY < arc.y then 
		print ('edge not added')
		return
	else
	end

	local event = {
		type = "edge",
		x = ix,
		y = eventY,
		endY = iy,
		arc = arc,
		process = processRightEdgeEvent, -- processRightEdgeEvent(event, beachline, events)
		nEvent = nEvent,
	}

	table.insert(events, event)
	arc.removingEvent = event -- Привязываем событие к арке
end



local function processSiteEvent(event, beachline, events, nEvent)
	local site = event.site
	local x, y = site.x, site.y

	if #beachline == 0 then 
		-- first one
		local arc = {
			site = site, -- focus
			x=x, y=y,  -- focus
			minX = minX, maxX = maxX,
			nEvent = nEvent, -- added on
		}
		print ('processSiteEvent first', 'nEvent: ' .. arc.nEvent)
		table.insert (beachline, arc)

	else -- not first


		local currentIndex = #beachline
		local sameX = false
		local sameY = false
		local isArcLast = false

		for index, arc in ipairs (beachline) do
			if x <= arc.maxX then
				currentIndex = index
				break
			end
		end

		local prevtArc = beachline[currentIndex-1]
		local currentArc = beachline[currentIndex]
		local nextArc = beachline[currentIndex+1]

		if currentIndex == #beachline then isArcLast = true end
		if currentArc.y == y then sameY = true end
		if currentArc.maxX == x then sameX = true end

		local arc = {
			site = site, -- focus
			x=x, y=y,  -- focus
			minX = x, maxX = x,
			nEvent = nEvent, -- added on
		}
		print ('processSiteEvent', 'nEvent: ' .. arc.nEvent)


		if isArcLast and sameY then
			print ('case 1')
			-- last arc: insert after all
			-- special case to insert vertical line after vertical line
			local mx = (currentArc.x + arc.x)/2
			arc.maxX = currentArc.maxX
			currentArc.maxX = mx
			arc.minX = mx
			table.insert (beachline, arc)

			-- add circle event to the left
			addCircleEvent(currentArc, beachline, events, nEvent)

			-- add edge event to the right
			addRightEdgeEvent(currentArc, arc, events, nEvent)

		elseif isArcLast and not sameY then
			print ('case 1.1', 'almost standard case')
			local my = evaluateArc (currentArc, x, y)
			local nextArc = {
				x = currentArc.x,
				y = currentArc.y,
				site = currentArc.site,
				minX = x, 
				maxX = currentArc.maxX,
				removingEvent = currentArc.removingEvent,
				nEvent = nEvent, -- added on
			}
			currentArc.maxX = x

			table.insert (beachline, currentIndex+1, arc)

			table.insert (beachline, currentIndex+2, nextArc)

			-- add circle event to the left
			addCircleEvent(currentArc, beachline, events, nEvent)

			-- add edge event to the right
			addRightEdgeEvent(arc, nextArc, events, nEvent)

		elseif sameX and sameY then
			print ('case 2')
			-- special case to insert vertical line after vertical line
			local mx = (currentArc.x + arc.x)/2
			arc.maxX = currentArc.maxX
			currentArc.maxX = mx
			arc.minX = mx
			table.insert (beachline, currentIndex+1, arc)

			-- left
			addCircleEvent(currentArc, beachline, events)

		elseif sameY and not sameX then
			print ('case 3')
			-- special case to insert vertical line after vertical line
			local mx = (currentArc.x + arc.x)/2
			arc.maxX = currentArc.maxX
			currentArc.maxX = mx
			arc.minX = mx
			table.insert (beachline, currentIndex+1, arc)

			-- print ('special case sameY and not sameX, events before:', #events)
			addCircleEvent(currentArc, beachline, events)
			-- print ('special case sameY and not sameX, events after:', #events)
			-- wip: sameY - insert vertical edge
		elseif not sameY and sameX then
			print ('case 4')
			-- special case to insert vertical line after current arc
			table.insert (beachline, currentIndex+1, arc)
			-- wip:  sameY - insert vertical edge
			addCircleEvent(currentArc, beachline, events)
			addCircleEvent(nextArc, beachline, events)

		elseif not sameY and not sameX then
			print ('case 5', 'standard case')

			-----------------------------
			-----------------------------
			-- standard case: 
--			-- print ('standard case:', x, y)
			local my = evaluateArc (currentArc, x, y)
			local nextArc = {
				x = currentArc.x,
				y = currentArc.y,
				site = currentArc.site,
				minX = x, 
				maxX = currentArc.maxX,
				removingEvent = currentArc.removingEvent,
				nEvent = nEvent, -- added on
			}
			-- test
			currentArc.removingEvent = nil
			nextArc.removingEvent = nil

			currentArc.maxX = x

			table.insert (beachline, currentIndex+1, arc)

			table.insert (beachline, currentIndex+2, nextArc)


			print ('common case, events before:', #events)
			addCircleEvent(currentArc, beachline, events, nEvent)
			print ('common case, events after 1:', #events)
			addCircleEvent(nextArc, beachline, events, nEvent)
			print ('common case, events after 2:', #events)

			for i, arc in ipairs (beachline) do
				print (i, 'arc', arc.minX, arc.maxX)
			end
		end
	end


end


local function getParabolaCrossPoint (p1x, p1y, p2x, p2y, dirY) -- focus 1, focus 2, directrix
-- Function to find the intersection point of two parabolas
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

local function findIntersection(arc1, arc2, eventY)
--	local a1, a2 = arc1.y - eventY, arc2.y - eventY
--	local b1 = arc1.x - arc2.x
--	return (b1 * a2) / (a1 - a2)
	local x, y = getParabolaCrossPoint (arc1.x, arc1.y, arc2.x, arc2.y, eventY)
	return x
end

local function clamp(low, n, high) 
	return math.min(math.max(n, low), high) 
end


local function updateLimits(beachline, eventY)

	if #beachline <= 1 then 
		print("updateLimits: not enough arcs in the beachline")
		return 
	end

	local arc = beachline[1]
	if arc.minX == arc.maxX then
		print ('remove first empty arc')
		table.remove (beachline, 1)
	end


	for i = 1, #beachline-1 do
		local arc1 = beachline[i]
		local arc2 = beachline[i+1]
		if arc1.y == arc2.y then
			-- do nothing or
			local mx = (arc1.x + arc2.x)/2
			mx = clamp (minX, mx, maxX)
			arc1.maxX = mx
			arc2.minX = mx
		else
			local mx = findIntersection (arc1, arc2, eventY)
			if mx then
				mx = clamp (minX, mx, maxX)
				arc1.maxX = mx
				arc2.minX = mx
--				print(string.format("updateLimits: intersection found mx=%.5f", mx))
			else
				-- no intersection found; log warning
				print("updateLimits: no valid intersection found for arcs", i, "and", i + 1)
			end
		end



	end
end

local function generateBeachlineCurve (beachline, eventY)
	local lines = {}
	local steps = 64
	for i, arc in pairs (beachline) do
		local line = {}
		local dx = arc.maxX - arc.minX
		if dx == 0 and arc.minX < maxX and arc.maxX > minX then
			print (i, 'dx was 0:', dx)
			local prevArc = beachline[i-1]
			local x = arc.x
			local y = (x - prevArc.x)^2 / (2 * (prevArc.y - eventY)) + (prevArc.y + eventY) / 2
			table.insert (line, arc.x-2)
			table.insert (line, arc.y)
			table.insert (line, x-2)
			table.insert (line, y)
			table.insert (line, x+2)
			table.insert (line, y)

			table.insert (line, arc.x+2)
			table.insert (line, arc.y)

--			-- print ('y, arc.y', y, arc.y)
		elseif dx > 0 then
			if dx/steps > 5 then
				steps = math.ceil (dx/5)
				--			-- print (steps, 1/steps)
			end
			for i = 0, steps do
				local x = arc.minX + i/steps * dx
				local y = (x - arc.x)^2 / (2 * (arc.y - eventY)) + (arc.y + eventY) / 2
				table.insert (line, x)
				table.insert (line, y)
			end
		else
			print ('generateBeachlineCurve', 'arc was short, nothing to draw')
		end
		table.insert (lines, line)
	end

	print ('generated beachline:')
	for i, arc in pairs (beachline) do
		if arc.minX < arc.maxX then
			print ('', i, arc.minX, arc.maxX)
		elseif arc.minX > arc.maxX then
			print ('', i, arc.minX, arc.maxX, 'overlap!', 'arc.nEvent: '.. arc.nEvent)
			print ('error: ', arc.minX-arc.maxX, (arc.minX-arc.maxX)*1000000)
			if arc.removingEvent then
				print ('', 'arc.removingEvent nEvent: '..arc.removingEvent.nEvent)
			end
		else
			print ('', i, arc.minX, arc.maxX, 'zero!')
		end
	end

	return lines
end

local function clearConsole()
	io.write("\027[2J\027[H\n")
end

local testEndLines = {}

local function updateBeachline ()
--	clearConsole()

	beachCurvesArray = {}
	renderingCircleEvents = {}
	testEdges = {}
	testEndLines = {}

	local events = {
		{x=0,
			y=globalEventY,
			process = function () end,
			type = 'directrix',
			nEvent = 0,
		}
	}
	for i, site in ipairs (sites) do
		local event = {
			x=site.x, 
			y=site.y, 
			site = site,
			process = processSiteEvent, -- must be function
			type = 'site',
			nEvent = 0,
		}
		table.insert (events, event)
	end



	local beachline = {}

	local lastEventY

	local nEvent = 0
	while #events > 0 do

		nEvent = nEvent + 1

		table.sort(events, function(a, b)
				return a.y == b.y and a.x < b.x or a.y < b.y
			end)

		local event = table.remove (events, 1)
		local eventY = event.y
		print ('----------', 'nEvent: '..nEvent, event.type, eventY)
		print ('nEvent was added: '.. event.nEvent)


		if eventY > globalEventY then
			print ('break of update', eventY)
			break
		end

		updateLimits(beachline, eventY)
		event.process(event, beachline, events, nEvent)
		print ('events after process:')
		for i, e in ipairs (events) do
			print (i, e.type, (e.nEvent or 'no'))

		end
		updateLimits(beachline, eventY)

		local beachCurves = generateBeachlineCurve (beachline, eventY)

		if lastEventY == eventY then
			-- we don't need two curves
			table.remove (beachCurvesArray)
		end

		lastEventY = eventY
		table.insert (beachCurvesArray, beachCurves)

		print ('----------', 'end of event '..nEvent)
		print ('')
	end

	-- test lines to show the end events:
	for i, arc in ipairs (beachline) do

		local x = (arc.minX + arc.maxX)/2
		local y = evaluateArc (arc, x, globalEventY)

		local removingEvent = arc.removingEvent
		if removingEvent then
			local x2 = removingEvent.x
			local y2 = removingEvent.endY
			if y2 then
				table.insert (testEndLines, {x, y, x2, y2})
			else
				print ('removingEvent.type', removingEvent.type)
			end
		end
	end

	for i, site1 in ipairs (sites) do
		for j, site2 in ipairs (sites) do
			if not (i == j) then
				local mx = (site1.x+site2.x)/2
				local my = (site1.y+site2.y)/2
				local dx = site2.x-site1.x
				local dy = site2.y-site1.y
				dx = dx*2*2
				dy = dy*2*2
				local edge = {mx+dy,my-dx, mx, my}
				table.insert (testEdges, edge)
			end
		end
	end


end



function love.mousemoved (x, y)
--	site1.x = x
--	site1.y = y

--	updateBeachline ()

	love.window.setTitle ('x:'..x..' y:'..y)
end

function love.mousepressed (x, y, b)
	if b == 1 then
		table.insert (sites, {x=x, y=y})
		print ('added point:', 'table.insert (sites, {x='..x..', y='..y..'})')
		updateBeachline ()
	elseif b == 2 then
		table.remove (sites)
		updateBeachline ()
	elseif b == 3 then
		globalEventY = y
		updateBeachline ()
	end

end

local function insertSite (x, y)
	print ('new site:', x, y, #sites+1)
	table.insert (sites, {x=x, y=y, index = #sites+1})
end

function love.load ()

	
	
	insertSite (300, 300)
	insertSite (400, 300)
	insertSite (300, 400)
	insertSite (400, 400)
	insertSite (500, 400)
	insertSite (400, 500)
	insertSite (500, 500)
	insertSite (600, 500)
	insertSite (500, 600)
	insertSite (600, 600)
	insertSite (700, 600)
	insertSite (600, 700)
	insertSite (700, 700)
	insertSite (800, 700)
	insertSite (700, 800)
	insertSite (800, 800)
	insertSite (900, 800)
	insertSite (800, 900)
	insertSite (900, 900)


	globalEventY = 1000

	updateBeachline ()
end

function love.update (dt)
	local key = love.keyboard.isDown ('down') and 'down' 
	or love.keyboard.isDown ('up') and 'up'
	if key == 'down' then
		globalEventY = globalEventY + 60*dt
		updateBeachline ()
	elseif key == 'up' then
		globalEventY = globalEventY - 120*dt
		updateBeachline ()
	end
end

local function rainbowRGB(t, a)
	local r = math.min(math.max(3 * math.abs(((360*t     ) / 180) % 2 - 1) - 1, 0), 1)
	local g = math.min(math.max(3 * math.abs(((360*t - 120) / 180) % 2 - 1) - 1, 0), 1)
	local b = math.min(math.max(3 * math.abs(((360*t + 120) / 180) % 2 - 1) - 1, 0), 1)

	return r, g, b, a
end



function love.draw ()



	love.graphics.setLineWidth (1)
	love.graphics.setColor (0,1,0, 0.5)
	for i, line in ipairs (testEndLines) do
		love.graphics.line (line)
	end

	love.graphics.setLineWidth (2)

	local c = 0.2
	love.graphics.setColor (c, c, c)

	-- circle events reference:
	for i, r in ipairs (renderingCircleEvents) do
		if not hiddenEvents then
			love.graphics.circle( r.drawmode, r.x, r.y, r.radius)
			for j, line in ipairs (r.lines) do
				love.graphics.line (line)
			end
		end
	end

--	love.graphics.setColor (1,1,1)
	-- edges
	for i, edge in ipairs (testEdges) do
		love.graphics.line (edge)
	end





	love.graphics.setColor (1,1,1)
	love.graphics.line (0,globalEventY, width,globalEventY)
	love.graphics.print (globalEventY, 0, globalEventY)

	love.graphics.setLineWidth (3)


	love.graphics.setColor (1,1,1)
	-- sites
	for i, site in ipairs (sites) do
		love.graphics.circle ('fill', site.x, site.y, 5)

		if not hiddenText then
			love.graphics.print (i..' '..site.x ..' '..site.y, site.x-10, site.y+5)
		end
	end




	love.graphics.setColor (1,1,1)
	for i, beachCurves in ipairs (beachCurvesArray) do
		local a = 1 * i/#beachCurvesArray


		for j, line in ipairs (beachCurves) do
			if #line > 3 then
				local t = 0.75*(j-1)/#beachCurves
				love.graphics.setColor (rainbowRGB(t, a))
				love.graphics.line (line)

			end
		end
	end

--	for i, line in ipairs (lines) do
--		local t = 0.75*(i-1)/#lines
--		love.graphics.setColor (rainbowRGB(t, a))
--		love.graphics.line (line)
--	end

	love.graphics.setColor (1,1,1)
	for i, p in ipairs (testPoints) do
		love.graphics.circle ('fill', p.x, p.y, 5)
	end



	love.graphics.setColor (0, 0, 0, 1)
	love.graphics.rectangle ('fill',0,0,230,60)

	love.graphics.setColor (0, 1, 0)
	love.graphics.print ('Left mouse botton: add site')
	love.graphics.print ('Right mouse botton: remove last site', 0, 14)
	love.graphics.print ('Middle mouse botton: set directrix', 0, 2*14)
	love.graphics.print ('Arrows UP and DOWN: move directrix', 0, 3*14)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "t" then
		hiddenText = not hiddenText
	elseif key == "e" then
		hiddenEvents = not hiddenEvents
	elseif key == "escape" then
		love.event.quit()
	end
end
