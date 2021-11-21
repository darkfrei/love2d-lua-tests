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
		print (x, y, x1, y1, x2, y2, cx, cy, r)
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
		100,100, 100,600, 600,600, 600,100, 1100,100, 600,600,
--		100,100, 100,600, 600,600, 600,100, 1000,100, 
--		100,100, 100,600, 600,600, 600,100,
--		100,100, 100,600, 600,600,
	}
	local curve = love.math.newBezierCurve(vertices)
	

	local line = curveRender (curve, 3)
	
	local cList, cMax = getCurvatureList (curve, 3)
	
	bezier = {
		vertices = vertices,
		curve = curve,
		line = line,
		cList = cList,
		cMax = cMax,
	}
	
	selector = {x=0, y=0}
end

 
function love.update(dt)
	
end



function love.draw()

	
	love.graphics.setLineWidth (1)
	love.graphics.setColor(1,1,0)
	love.graphics.line(bezier.vertices)
	
	love.graphics.setLineWidth (3)
	love.graphics.setColor(0,1,0)
	love.graphics.line(bezier.line)
	
	love.graphics.setLineWidth (1)
	for i = 1, #bezier.line-1, 2 do
		local x, y = bezier.line[i], bezier.line[i+1]
		love.graphics.circle ('line', x,y, 10)
	end
	
	love.graphics.setColor(1,1,1, 0.5)
	for i, point in ipairs (bezier.cList) do
		local x, y = point.x, point.y
		love.graphics.print (i..' '..(point.k), x-20,y+20)
		love.graphics.circle ('line', point.cx, point.cy, point.r)
	end

	love.graphics.setLineWidth (1)
	love.graphics.setColor(1,1,1)
	love.graphics.line(bezier.curve:render())
	
	love.graphics.setLineWidth (1)
	if selector.t then
		love.graphics.circle ('fill', selector.tx, selector.ty, 10)
		love.graphics.print (selector.t, 20, 80)
	end

end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end

function getNearestPoint (line, x, y)
	local nx, ny, nDist -- nearest point, distance
	for i = 1, #line-1, 2 do
		local px, py = line[i], line[i+1]
		local dx, dy = px-x, py-y
		local dist = (dx*dx+dy*dy)^0.5
		if (not nDist) or nDist > dist then
			nDist = dist
			nx, ny = px, py
		end
	end
	return nx, ny
end



function getBezierValue (line, x, y)
	local nx, ny = getNearestPoint (line, x, y)
	local nt = 0 -- nearest t
	local ntx, nty = bezier.curve:evaluate(nt)
	local ndx, ndy = ntx-nx, nty-ny
	local nDist = (ndx*ndx+ndy*ndy)^0.5
	local amount = (#line)/2
--	print (amount)
	for i = 1, amount-1 do
		local t = (i)/(amount-1)
		local tx, ty = bezier.curve:evaluate(t)
		local dx, dy = tx-nx, ty-ny
		if (dx == 0) and (dy == 0) then
--			print (i)
			return t, tx, ty
		elseif dx < nDist and dy < nDist then
			local dist = (dx*dx+dy*dy)^0.5
			if dist < nDist then
				nDist = dist
				nt = t
				ntx, nty = tx, ty
				ndx, ndx = dx, dy
			end
		end
	end
--	print (nt)
	return nt, nx, ny
end

function love.mousemoved( x, y, dx, dy, istouch )
	
	selector.t, selector.tx, selector.ty = getBezierValue (bezier.line, x, y, 1)

end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end