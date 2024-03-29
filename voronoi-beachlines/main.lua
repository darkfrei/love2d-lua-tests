-- 2024-03-25

frame = {x=50,y=50, w=700,h=500}

vertices = {
	200,120,
--	300,210, 
	500,180, 
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



function fdParabolaToBezier(fx, fy, dirY, ax, bx)
	local f = function (x, fx, fy, dirY)
		local n = x*x-2*fx*x+fx*fx+fy*fy-dirY*dirY
		return n / (2*(fy-dirY))
	end

	local function df(x, fx, fy, dirY)
		local derivative = (x-fx) / (fy-dirY)
		return derivative
	end

	if (fy == dirY) then return end

	-- y coordinate for point A:
	local ay = f(ax, fx, fy, dirY)
	-- tangent slope for A:
	local ad = df(ax, fx, fy, dirY)
	-- difference x for C and A
	local dx = (bx-ax)/2
	-- position of point C:
	local cx = ax+dx
	local cy = ay+dx*ad	
	-- y coordinate for point B:
	local by = f(bx, fx, fy, dirY)
	return ax, ay, cx, cy, bx, by
end

-- fx, fy, dirY, ax, bx
print (fdParabolaToBezier(0, 0.25, -0.25, -1, 2))

function getBezierControlPoint (fx, fy, ax, bx)
	local f = function (x)
		return (x*x-2*fx*x+fx*fx+fy*fy-dirY*dirY) / (2*(fy-dirY))
	end
	local function df(x)
		return (x-fx) / (fy-dirY)
	end
	if (fy == dirY) then return end -- not parabola
	local ay, by = f(ax), f(bx)
	local ad = df(ax) -- tangent slope for A
	local dx = (bx-ax)/2
	return ax+dx, ay+ad*dx
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
			local cx, cy = getBezierControlPoint(fx, fy, ax, bx)
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