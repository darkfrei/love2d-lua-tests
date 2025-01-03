print (love.getVersion( ))

--print = function () end

love.window.setMode( 1920, 1080 )

local width = love.graphics.getWidth()
local height = love.graphics.getHeight() 

local minX = 10
local maxX = width-10


local globalEventY = 950

local site1 = {x=1310, y=590}

local sites = {site1}

table.insert (sites, {x=400, y=400})
table.insert (sites, {x=1200, y=400})
table.insert (sites, {x=800, y=600})
--table.insert (sites, {x=1200, y=300})

local beachCurvesArray = {} -- array of arrays for lines to draw beachlines

local lines = {}

local renderingArcs = {}

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

local function processCircleEvent (event, beachline, events)
	local currentIndex
	for index, arc in ipairs (beachline) do
		if arc == event.arc then
			currentIndex = index
			break
		end
	end
	if not currentIndex then return end

	local pervArc = beachline[currentIndex-1]
	local currentArc = beachline[currentIndex]
	local nextArc = beachline[currentIndex+1]

	print ('processCircleEvent', 'beachline before:')
	for i, arc in ipairs (beachline) do
		print (i, 'arc', arc.minX, arc.maxX)
	end

	local x = event.x -- x coordinate of circle
	if currentArc and currentArc.removingEvent 
	and event == event.arc.removingEvent then
		pervArc.maxX = x
		nextArc.minX = x
		table.remove (beachline, currentIndex)
		print ('processCircleEvent', 'arc removed', currentIndex)
	end

--	for index, arc in ipairs (beachline) do
--		arc.index = index
--	end

	print ('processCircleEvent', 'beachline after:')
	for i, arc in ipairs (beachline) do
		print (i, 'arc', arc.minX, arc.maxX)

	end

	print ('processCircleEvent', 'end')

end

local function addCircleEvent(currentArc, beachline, events)
	-- reindex beachline

	for index, arc in ipairs (beachline) do
		arc.index = index
	end



	local currentIndex
	for index, arc in ipairs (beachline) do
		if arc == currentArc then
			currentIndex = index
			break
		end
	end

	local leftArc = beachline[currentIndex - 1]
	local rightArc = beachline[currentIndex + 1]

	if not leftArc then

		return
	end
	if not rightArc then

		return
	end

	if leftArc.site == rightArc.site then
		error ('same sites!')
	end

	local circleX, circleY, radius = calculateCircle(
		leftArc.site, currentArc.site, rightArc.site
	)

	-- lower than site
	if circleY and (circleY+radius) > currentArc.site.y then
--		love.graphics.arc( drawmode, x, y, radius, angle1, angle2, segments )
		local renderArc = {
			drawmode = 'line',
			x = circleX,
			y = circleY,
			radius = radius,
			angle1 = math.atan2 (leftArc.y-circleY, leftArc.x-circleX),
			angle2 = math.atan2 (rightArc.y-circleY, rightArc.x-circleX),
		}
		table.insert (renderingArcs, renderArc)

		local circleEvent = {
			x = circleX,
			y = circleY + radius,
			circleY = circleY,
			arc = currentArc, -- arc to removing

--			event.process(event, beachline, events)
			process = processCircleEvent,
		}
		if currentArc.removingEvent then
			if currentArc.removingEvent.y > circleEvent.y then
				print ('removingEvent y:', currentArc.removingEvent.y, circleEvent.y)
				currentArc.removingEvent = circleEvent
			end
		else
			currentArc.removingEvent = circleEvent
		end

		table.insert (events, circleEvent)
		print ('circle event added:', #events)

	end

end


local function processSiteEvent(event, beachline, events)
	local site = event.site
	local x, y = site.x, site.y

	if #beachline == 0 then 
		-- first one
		local arc = {
			site = site, -- focus
			x=x, y=y,  -- focus
			minX = minX, maxX = maxX,
		}
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
		}


		if isArcLast and sameY then
			print ('case 1')
			-- last arc: insert after all
			-- special case to insert vertical line after vertical line
			local mx = (currentArc.x + arc.x)/2
			arc.maxX = currentArc.maxX
			currentArc.maxX = mx
			arc.minX = mx
			table.insert (beachline, arc)

			addCircleEvent(currentArc, beachline, events)

		elseif sameX and sameY then
			print ('case 2')
			-- special case to insert vertical line after vertical line
			local mx = (currentArc.x + arc.x)/2
			arc.maxX = currentArc.maxX
			currentArc.maxX = mx
			arc.minX = mx
			table.insert (beachline, currentIndex+1, arc)
			-- wip:  sameY - insert vertical edge
		elseif sameY and not sameX then
			print ('case 3')
			-- special case to insert vertical line after vertical line
			local mx = (currentArc.x + arc.x)/2
			arc.maxX = currentArc.maxX
			currentArc.maxX = mx
			arc.minX = mx
			table.insert (beachline, currentIndex+1, arc)

			print ('special case sameY and not sameX, events before:', #events)
			addCircleEvent(currentArc, beachline, events)
			print ('special case sameY and not sameX, events after:', #events)
			-- wip: sameY - insert vertical edge
		elseif not sameY and sameX then
			print ('case 4')
			-- special case to insert vertical line after current arc
			table.insert (beachline, currentIndex+1, arc)
			-- wip:  sameY - insert vertical edge
			addCircleEvent(currentArc, beachline, events)
			addCircleEvent(nextArc, beachline, events)
			
		elseif not sameY and not sameX then
			print ('case 5')

			-----------------------------
			-----------------------------
			-- standard case: 
--			print ('standard case:', x, y)
			local my = evaluateArc (currentArc, x, y)
			local nextArc = {
				x = currentArc.x,
				y = currentArc.y,
				site = currentArc.site,
				minX = x, 
				maxX = currentArc.maxX,
				removingEvent = currentArc.removingEvent,
			}
			currentArc.maxX = x
			table.insert (beachline, currentIndex+1, arc)
			table.insert (beachline, currentIndex+2, nextArc)

			print ('common case, events before:', #events)
			addCircleEvent(currentArc, beachline, events)
			print ('common case, events after 1:', #events)
			addCircleEvent(nextArc, beachline, events)
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
	if #beachline > 1 then
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
				end
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
		if dx == 0 and i > 1 then
			local prevArc = beachline[i-1]
			local x = arc.x
			local y = (x - prevArc.x)^2 / (2 * (prevArc.y - eventY)) + (prevArc.y + eventY) / 2
			table.insert (line, arc.x)
			table.insert (line, arc.y)
			table.insert (line, x)
			table.insert (line, y)

--			print ('y, arc.y', y, arc.y)
		else
			if dx/steps > 5 then
				steps = math.ceil (dx/5)
				--			print (steps, 1/steps)
			end
			for i = 0, steps do
				local x = arc.minX + i/steps * dx
				local y = (x - arc.x)^2 / (2 * (arc.y - eventY)) + (arc.y + eventY) / 2
				table.insert (line, x)
				table.insert (line, y)
			end
		end
		table.insert (lines, line)
	end

	return lines
end

local function clearConsole()
	io.write("\027[2J\027[H\n")
end

local function updateBeachline ()
--	clearConsole()

	beachCurvesArray = {}
	renderingArcs = {}
	testEdges = {}

	local events = {
		{x=0,
			y=globalEventY,
			process = function () end
		}
	}
	for i, site in ipairs (sites) do
		local event = {
			x=site.x, 
			y=site.y, 
			site = site,
			process = processSiteEvent -- must be function
		}
		table.insert (events, event)

	end



	local beachline = {}

	local lastEventY

	local nEvent = 0
	while #events > 0 do
		nEvent = nEvent + 1
		print ('----------', 'nEvent: '..nEvent)
		table.sort(events, function(a, b)
				return a.y == b.y and a.x < b.x or a.y < b.y
			end)

		local event = table.remove (events, 1)
		local eventY = event.y


		updateLimits(beachline, eventY)
		event.process(event, beachline, events)
		updateLimits(beachline, eventY)

		local beachCurves = generateBeachlineCurve (beachline, eventY)
		local line = {event.x-100, eventY, event.x+100, eventY}

		table.insert (beachCurves, line)

		if lastEventY == eventY then
			table.remove (beachCurvesArray)
		end
		lastEventY = eventY
		table.insert (beachCurvesArray, beachCurves)
	end

	updateLimits (beachline, globalEventY) -- update global value
	lines = generateBeachlineCurve (beachline, globalEventY)


	for i, site1 in ipairs (sites) do
		for j, site2 in ipairs (sites) do
			if not (i == j) then
				local mx = (site1.x+site2.x)/2
				local my = (site1.y+site2.y)/2
				local dx = site2.x-site1.x
				local dy = site2.y-site1.y
				local edge = {mx+dy,my-dx, mx, my}
				table.insert (testEdges, edge)
			end
		end
	end


end



function love.mousemoved (x, y)
	site1.x = x
	site1.y = y

	updateBeachline ()
end

function love.load ()
	updateBeachline ()
end

function love.update ()
	local key = love.keyboard.isDown ('down') and 'down' 
	or love.keyboard.isDown ('up') and 'up'
	if key == 'down' then
		eventY = eventY + 1
		updateBeachline ()
	elseif key == 'up' then
		eventY = eventY - 1
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
	love.graphics.setColor (1,1,1)
	love.graphics.line (0,globalEventY, width,globalEventY)
	love.graphics.print (globalEventY, 0, globalEventY)

	love.graphics.setColor (1,1,1)
	-- sites
	for i, site in ipairs (sites) do
		love.graphics.circle ('fill', site.x, site.y, 5)
		love.graphics.print (i..' '..site.x ..' '..site.y, site.x-15, site.y+25)
	end




	love.graphics.setColor (1,1,1)
	for i, beachCurves in ipairs (beachCurvesArray) do
		local a = 0.3 + 0.7 * i/#beachCurvesArray
		for j, line in ipairs (beachCurves) do
--			print (#beachCurves, #line)
			local t = 0.75*(j-1)/#beachCurves
			love.graphics.setColor (rainbowRGB(t, a))
			love.graphics.line (line)

			love.graphics.print (i..' '..j, line[1], line[2])
		end
	end

--	for i, line in ipairs (lines) do
--		local t = 0.75*(i-1)/#lines
--		love.graphics.setColor (rainbowRGB(t, a))
--		love.graphics.line (line)
--	end

	local c = 0.5
	love.graphics.setColor (c, c, c)
	for i, r in ipairs (renderingArcs) do
		love.graphics.arc( r.drawmode, r.x, r.y, r.radius, r.angle1, r.angle2)
		love.graphics.circle( r.drawmode, r.x, r.y, r.radius)
		love.graphics.line (r.x-20, r.y+r.radius, r.x+20, r.y+r.radius)
	end

--	love.graphics.setColor (1,1,1)
	for i, edge in ipairs (testEdges) do
		love.graphics.line (edge)
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end
