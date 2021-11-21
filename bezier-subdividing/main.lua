-- License CC0 (Creative Commons license) (c) darkfrei, 2021

-- index five:
function getBezierCurvature (curve, t) -- love bezier curve as
	local db = curve:getDerivative() -- speed
	if db:getControlPointCount() == 1 then
		return 0 -- no speed
	end
	local x1, y1 = db:evaluate(t) -- speed
	local d2b = db:getDerivative()
	if d2b:getControlPointCount() == 1 then
		local x2, y2 = d2b:getControlPoint(1)
		local K = math.abs(x1 * y2 - x2 * y1) / (math.sqrt(x1^2 + y1^2))^3
		return K -- no acceleration
	end
	local x2, y2 = d2b:evaluate(t) -- acceleration
	-- curvature: 
	local K = math.abs(x1 * y2 - x2 * y1) / (math.sqrt(x1^2 + y1^2))^3
	return K
end

function getCurvatureList (BezierCurve, depth) -- BezierCurve is BezierCurve
	local amount = 2^depth
	local cList = {}
	local db = BezierCurve:getDerivative()
	local d2b = db:getDerivative()
	for n = 0, amount do
		local t = n/amount
		-- curvature, circlePosition, radius:
		local k, cx, cy, r
		
		local x, y = BezierCurve:evaluate(t)
		local x1, y1 = db:getControlPoint(1)
		local x2, y2 = d2b:getControlPoint(1)
		
		if db:getControlPointCount() == 1 then
			k = 0
		elseif d2b:getControlPointCount() == 1 then
			x1, y1 = db:evaluate(t)
--			x2, y2 = d2b:getControlPoint(1)
--			k = math.abs(x1*y2-x2*y1)/(x1^2+y1^2)^(3/2)
			k = (x1*y2-x2*y1)/(x1^2+y1^2)^(3/2)
		else
			x1, y1 = db:evaluate(t)
			x2, y2 = d2b:evaluate(t)
--			k = math.abs(x1*y2-x2*y1)/(x1^2+y1^2)^(3/2)
			k = (x1*y2-x2*y1)/(x1^2+y1^2)^(3/2)
		end
		
		if not (k == 0) then
			local sign = k > 0 and 1 or -1
			r = math.abs(1/k)
			
			local angle = math.atan2 (y1, x1)
			cx = x - sign*r * math.sin(angle)
			cy = y + sign*r * math.cos(angle)
		end
--		print (x, y, x1, y1, x2, y2, cx, cy, r)
		table.insert (cList, {x=x,y=y,k=k,cx=cx, cy=cy, r=r})
	end
	return cList, cMax
end


function curveRender (BezierCurve, depth)
	local subdivisions = 2^depth
	local line = {}
	for i = 0, subdivisions do
		local t = i/subdivisions
		local x, y = BezierCurve:evaluate(t)
		table.insert (line, x)
		table.insert (line, y)
	end
	return line
end


function newBezier (vertices)
	local curve = love.math.newBezierCurve(vertices)
	local line = curveRender (curve, 3)
	local cList, cMax = getCurvatureList (curve, 3)
	
	local bezier = {
		vertices = vertices, -- control points
		curve = curve, -- Löve's BezierCurve
		line = line, -- list of pairs
		cList = cList,
		cMax = cMax,
	}
	return bezier
end

function love.load()
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	width, height = love.graphics.getDimensions()

	local vertices = {
		100,100, 100,1000, 1000,1000, 1000,100, 1800,100
	}
	
	beziers = {}
	table.insert (beziers, newBezier (vertices))
	
--	vertices = {
--			200,700, 700,700, 1000,400, 1000,100, 1600,100, 
--	}
--	table.insert (beziers, newBezier (vertices))
	
	selector = {x=0, y=0, t=0, 
		bezierIndex=0,
		bezier = beziers[1]}
end

 
function love.update(dt)
	
end



function love.draw()

	for iBezier, bezier in ipairs (beziers) do
		
--		print (iBezier, )
		if selector.bezierIndex and selector.bezierIndex == iBezier then
			love.graphics.setLineWidth (3)
			love.graphics.setColor(1,1,0)
		else
			love.graphics.setLineWidth (2)
			love.graphics.setColor(1,1,0, 0.5)
		end
		
		love.graphics.line(bezier.vertices)
		
		if selector.bezierIndex and selector.bezierIndex == iBezier then
			love.graphics.setLineWidth (5)
			love.graphics.setColor(0,1,0)
		else
			love.graphics.setLineWidth (3)
			love.graphics.setColor(0,1,0, 0.5)
		end
		
		love.graphics.line(bezier.line)
		
		love.graphics.setLineWidth (1)
		for i = 1, #bezier.line-1, 2 do
			local x, y = bezier.line[i], bezier.line[i+1]
			love.graphics.circle ('line', x,y, 10)
		end
		
--		love.graphics.setColor(1,1,1, 0.5)
--		for i, point in ipairs (bezier.cList) do
--			local x, y = point.x, point.y
--			love.graphics.print (i..' '..(point.k), x-20,y+20)
--			love.graphics.circle ('line', point.cx, point.cy, point.r)
--		end

--		love.graphics.setLineWidth (1)
--		love.graphics.setColor(1,1,1)
--		love.graphics.line(bezier.curve:render())
		

	end

	love.graphics.setColor(1,1,1)
	love.graphics.setLineWidth (1)
	if selector.t then
		love.graphics.circle ('fill', selector.x, selector.y, 8)
		love.graphics.print (selector.t, 20, 20)
		love.graphics.print (selector.x, 20, 40)
		love.graphics.print (selector.y, 20, 60)
		love.graphics.print (selector.bezierIndex, 20, 80)
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end


function getNearestPoint (line, x, y)
	local nx, ny, nDist, nIndex -- nearest point, distance
	for i = 1, #line-1, 2 do
		local px, py = line[i], line[i+1]
		local dx, dy = px-x, py-y
		local dist = (dx*dx+dy*dy)^0.5
		if (not nDist) or nDist > dist then
			nDist = dist
			nx, ny = px, py
			nIndex = i
		end
	end
	local t = ((nIndex-1)/2)/(#line/2-1)
--	print (t)
	return nx, ny, t, nDist
end



function updateSelectedBezierValue (beziers, x, y)
	local bestBezierIndex, bestBezier
	local bX, bY, t, bestDist
	for iBezier, bezier in ipairs (beziers) do
		local line = bezier.line
		local nx, ny, nt, nDist = getNearestPoint (line, x, y)
		if not bestDist or bestDist > nDist then
			bestDist = nDist
			bestBezierIndex, bestBezier = iBezier, bezier
			bX, bY, t = nx, ny, nt
		end
	end
	
	selector = {x=bX, y=bY, t=t, bezier = bestBezier, bezierIndex = bestBezierIndex}
end

function lerp (a, b, t)
	return a + t*(b-a)
end

function pointsToVertices (points) -- as pairs {{x=x1,y=y1}, {x=x2,y=y2}, }
--	print ('points', #points)
	local vertices = {}
	for i, point in ipairs (points) do
		table.insert (vertices, point.x)
		table.insert (vertices, point.y)
	end
	return vertices
end

function cutBezier (beziers, bezierIndex, t)
	local bezier = beziers[bezierIndex]
	table.remove (beziers, bezierIndex)
	selector = {}
	
	local vertices = bezier.vertices
	local points = {}
	for i = 1, #vertices-1, 2 do
		local x, y = vertices[i], vertices[i+1]
		table.insert (points, {x=x,y=y})
	end
	
	local first, second = {}, {}
	
	for i = 1, #points do
		local points2 = {}
		table.insert (first, 1, points[1])
		table.insert (second, 1, points[#points])
--		table.insert (second, points[#points])
		for j = 1, #points-1 do
			local x1, y1 = points[j].x, points[j].y
			local x2, y2 = points[j+1].x, points[j+1].y
			local x = lerp (x1, x2, t)
			local y = lerp (y1, y2, t)
			table.insert (points2, {x=x,y=y})
		end
		points = points2
	end
	
	local verticesFirst = pointsToVertices (first)
	local verticesSecond = pointsToVertices (second)
	
	table.insert (beziers, newBezier (verticesFirst))
	table.insert (beziers, newBezier (verticesSecond))
end

function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
		cutBezier (beziers, selector.bezierIndex, selector.t)
	elseif button == 2 then -- right mouse button
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
	
	
	updateSelectedBezierValue (beziers, x, y, 1)

end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end