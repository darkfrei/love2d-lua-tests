-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function love.load()
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	width, height = love.graphics.getDimensions( )

	local vertices = {
		100,100, 100,600, 600,600, 600,100, 1000, 100
--		100,100, 100,600, 600,600, 600,100,
--		100,100, 100,600, 600,600,
	}
	local curve = love.math.newBezierCurve(vertices)
	local line = curve:render(1)
	bezier = {
		vertices = vertices,
		curve = curve,
		line = line,
	}
	
	selector = {x=0, y=0}
end

 
function love.update(dt)
	
end


function curveRender (vertices, depth)
	local curve = love.math.newBezierCurve(vertices)
--	local degree = (#vertices-2)/2
--	local nPoints = 2^degree+1
--	local startIndex = (nPoints-1)/2
--	local startStep = (nPoints-1)/2
	local list = {{0, 1, startIndex, startStep}}
	local points = {}
	table.insert (points, {t=0, x=vertices[1], y=vertices[2]})
	for _ = 1, 2^depth-1 do
		local p = list[1]
		local t = (p[1] + p[2])/2
--		local index = p[3]
--		local step = p[4]
		local x,y = curve:evaluate(t)
		table.insert (points, {t=t, x=x, y=y})
		table.remove(list, 1)
		table.insert(list, {p[1], t})
		table.insert(list, {t, p[2]})
	end
	table.insert (points, {t=1, x=vertices[#vertices-1], y=vertices[#vertices]})
	table.sort(points, function(a,b) return a.t > b.t end)
	local line = {}
	for i, point in pairs (points) do
		table.insert (line, point.x)
		table.insert (line, point.y)
	end
	return line
end

function love.draw()

	love.graphics.setLineWidth (1)
	love.graphics.setColor(1,1,0)
	love.graphics.line(bezier.vertices)
	
	love.graphics.setLineWidth (3)
	love.graphics.setColor(1,0,0)
	love.graphics.line(bezier.line)
	love.graphics.setLineWidth (1)
	for i = 1, #bezier.line-1, 2 do
		local x, y = bezier.line[i], bezier.line[i+1]
		love.graphics.circle ('line', x,y, 10)
	end
--	for i = 1, #bezier.line-1, 2 do
--		love.graphics.print (bezier.line[i]..' '..bezier.line[i+1], bezier.line[i], bezier.line[i+1])
--	end

	local line = curveRender (bezier.vertices, 3)
	love.graphics.setLineWidth (3)
	love.graphics.setColor(0,1,0)
	love.graphics.line(line)
	
	
	
	love.graphics.setColor(1,1,1)
	love.graphics.line(bezier.curve:render())
	
	love.graphics.setLineWidth (1)
--	love.graphics.circle ('line', selector.x, selector.y, 20)
	if selector.t then
--		love.graphics.print ('\ntx '..selector.tx ..' '.. selector.ty, selector.tx, selector.ty)
--		love.graphics.print ('\nnx '..selector.nx ..' '.. selector.ny, selector.nx, selector.ny)
		
--		love.graphics.circle ('line', selector.nx, selector.ny, 10)
		
		love.graphics.circle ('line', selector.tx, selector.ty, 10)
		
--		love.graphics.print (selector.str, 20, 20)

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
			index = i
		end
	end
	return nx, ny
end



function getBezierValue (curve, x, y, nSteps)
--	local line = curveRender(nSteps+2)
	local line = curve:render(nSteps+2)
	local nx, ny = getNearestPoint (line, x, y)
	
	
	local list = {{0, 1}}
	local nt = 0.5 -- nearest t
	local ntx, nty = bezier.curve:evaluate(nt)
	local ndx, ndy = ntx-nx, nty-ny
	local nIndex = 1
	
	local nDist = (ndx*ndx+ndy*ndy)^0.5
	
	
	for i = 1, 4^(nSteps+1)-1 do
		local p = list[1]
		local t = (p[1]+p[2])/2 -- 1/2, 1/4, 3/4, 1/8, 3/8, 5/8, 7/8, 1/16 etc.
--		print (i, t)
		local tx, ty = bezier.curve:evaluate(t)
		local dx, dy = tx-nx, ty-ny
		
		if (dx == 0) and (dy == 0) then
--			print (i, t)
			return t, tx, ty
		elseif dx < nDist and dy < nDist then
			local dist = (dx*dx+dy*dy)^0.5
			if dist < nDist then
				nDist = dist
				nt = t
				ntx, nty = tx, ty
				ndx, ndx = dx, dy
				nIndex = i
			end
		end
		table.remove(list, 1)
		table.insert(list, {p[1], t})
		table.insert(list, {t, p[2]})
	end
	
--	print (nIndex, nt, ndx, ndy)
	return nt, ntx, nty
end

function love.mousemoved( x, y, dx, dy, istouch )
	
	selector.t, selector.tx, selector.ty = getBezierValue (bezier.curve, x, y, 0)

end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end