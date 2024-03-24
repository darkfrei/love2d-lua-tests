
frame = {x=50,y=50, w=700,h=500}

vertices = {
	200,200,
--	300,210, 
	500,250, 
}

dirY = 220

function getFocusParabolaRoots (fx, fy, y) -- focus, horizontal line
-- dirY is global
	local h = fx -- x shift
	local p = -(dirY-fy)/2 -- always negative for voronoi
	local k = fy - p -y
	local leftX = h - math.sqrt (-k*4*p)
	local rightX = h + math.sqrt (-k*4*p)
	return leftX, rightX
end

getFocusParabolaRoots (2, 6, 10) -- focus x, y, directrix y
getFocusParabolaRoots (5, 3, 5) -- focus x, y, directrix y

---------------------------------------------------------------------

function getBezierControlPoint_focus_directrix(fx, fy, ax, ay, bx, by)
	-- (x-h)^2=4*p*(y-k)
	if (ay == by) then
		-- exception: horizontal AB
		local k = (fy + dirY) / 2
		local h = fx
		local cx = h
		local cy = ay + 2*(k-ay)
		return cx, cy
		
	else
--	[Axis direction](https://en.wikipedia.org/wiki/Parabola#Axis_direction)
		local h = fx
		local k = (fy + dirY) / 2
		local cx = (ax+bx)/2
		local f = (k-dirY)/2
		
		-- vertex
		-- h = -b/(2*a)
		-- k = (4*a*c-b*b)/(4*a)
		
		local a = -1/(dirY-ay)
		local b = -2 * a * h
		local c = h * h * a + k
--		print ('h', h, -b/(2*a)) -- ok, same
--		print ('k', k, (4*a*c-b*b)/(4*a)) -- ok, same
		
		-- derivative value of parabola in point A (ax):
		local day = a*2*ax + b
		local cy = ay + day * (bx-ax)/2
		
		-- usage: three control points to draw parabola:
		-- {ax, ay, cx, cy, bx, by}
		return cx, cy
	end
end

function evaluateParabola (fx, fy, x)
	local k = (fy+dirY)/2
	local p = -(dirY-fy)/2
	local y = (x-fx)^2 / (4*p) + k
	return y
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
			local left_x, right_x = getFocusParabolaRoots (fx, fy, frame.y)

-- same!
--			print ('1', math.sqrt ((left_x-fx)^2+(frame.y-fy)^2))
--			print ('2', dirY-frame.y)
			beachLine.line = {left_x, frame.y, right_x, frame.y}
			local ax, ay = left_x, frame.y
			if ax < frame.x then
				local ax1 = frame.x
				local ay1 = evaluateParabola (fx, fy, ax1)
				beachLine.line[1] = ax1 
				beachLine.line[2] = ay1
				table.insert (beachLine.line, 3, ax1)
				table.insert (beachLine.line, 4, frame.y)
				ax = ax1
				ay = ay1
			end
			
			local bx, by = right_x, frame.y
			if bx > frame.x + frame.w then
				local bx1 = frame.x + frame.w
				local by1 = evaluateParabola (fx, fy, bx1)
				beachLine.line[#beachLine.line-1] = bx1 
				beachLine.line[#beachLine.line] = by1
				table.insert (beachLine.line, #beachLine.line-1, bx1)
				table.insert (beachLine.line, #beachLine.line-1, frame.y)
				bx = bx1
				by = by1
			end
			
--			local cx, cy = getBezierThirdControlPoint(fx, fy, ax, ay, bx, by+1)
			local cx, cy = getBezierControlPoint_focus_directrix(fx, fy, ax, ay, bx, by)
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

updateBeachlines ()

function love.draw ()
	love.graphics.setColor (0.8,0.8,0.8,0.8)
	love.graphics.setLineWidth (2)
	love.graphics.rectangle ('line', frame.x, frame.y, frame.w, frame.h)

	love.graphics.line (frame.x, dirY, frame.x+frame.w, dirY)
	love.graphics.points (vertices)


	for i, beachLine in ipairs (beachLines) do
		love.graphics.setColor (0,0.7,0,0.7)
		love.graphics.setLineWidth (6)
		love.graphics.line (beachLine.line)

		if #beachLine.controlPoints > 3 
			and beachLine.controlPoints[3] ~= nil then
			love.graphics.setColor (0,0.7,0,0.7)
			love.graphics.setLineWidth (1)
			love.graphics.line (beachLine.controlPoints)
		end
		
		if beachLine.bezierLine then
		love.graphics.setColor (0,0.7,0,0.7)
		love.graphics.setLineWidth (1)
		love.graphics.line (beachLine.bezierLine)
	
	end

	end
end



function love.mousemoved (x, y)
	dirY = y

	updateBeachlines () 
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end