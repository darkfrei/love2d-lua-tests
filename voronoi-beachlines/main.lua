
frame = {x=50,y=50, w=700,h=500}

vertices = {
	200,200,
--	300,210, 
--	400,210, 
}

dirY = 220

function getFocusParabolaRoots (fx, fy, y) -- focus

	local h = fx -- x shift
	local p = -(dirY-fy)/2 -- always negative for voronoi
	local k = fy - p -y

	-- roots
	local left_x = h - math.sqrt (-k*4*p)
	local right_x = h + math.sqrt (-k*4*p)
--	print (left_x, right_x)
	return left_x, right_x
end

getFocusParabolaRoots (2, 6, 10) -- focus x, y, directrix y
getFocusParabolaRoots (5, 3, 5) -- focus x, y, directrix y

---------------------------------------------------------------------

function getBezierControlPoint_focus_directrix(fx, fy, ax, ay, bx, by)
	if (ay == by) then
		-- exception: horizontal AB
		local h = fx
		local k = (fy + dirY) / 2
		local cx = h
		local cy = ay + 2*(k-ay)
		return cx, cy		
	end
	-- Calculate the axis of symmetry (h)
	local h = -fx / (2 * (ay - dirY))

	-- Calculate the vertex of the parabola (k)
	local k = ay - (ay - dirY) / 4

	-- Calculate the distance from A and B to the vertex
	local dA = math.abs(ax - h)
	local dB = math.abs(bx - h)

	-- Calculate the control point's x-coordinate (c_x)
	local cx = (dA * bx + dB * ax) / (dA + dB)

	-- Calculate the control point's y-coordinate (c_y)
	local cy = k + (cx - h)^2 / (4 * (k - dirY))

	return c_x, c_y
end

function get_y1 (fx, fy, x1)
	local k = (fy+dirY)/2
--	local p = k-dirY
	local p = -(dirY-fy)/2
	local h = fx
	-- (x-h)^2 = 4*p*(y-k)
	-- dirY = k-p
	local y1 = (x1-h)^2 / (4*p) + k
	love.window.setTitle ('x:'..x1..
		' y1:'..y1.. ' p:'..p )
	return y1
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
--				print ('ax, ay', ax, ay)
				beachLine.line[1] = frame.x
				beachLine.line[2] = get_y1 (fx, fy, frame.x)
				table.insert (beachLine.line, 3, frame.x)
				table.insert (beachLine.line, 4, frame.y)
			end
			local bx, by = right_x, frame.y
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