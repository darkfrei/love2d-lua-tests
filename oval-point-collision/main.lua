
function updateOval (oval)
	local angle = math.atan2 (oval.B.y-oval.A.y, oval.B.x-oval.A.x)
	oval.angle1 = angle + math.pi/2
	oval.angle2 = oval.angle1 + math.pi
	oval.angle3 = oval.angle2 + math.pi
	oval.dx = oval.radius * math.cos (oval.angle1)
	oval.dy = oval.radius * math.sin (oval.angle1)
end

function love.load()
	Oval = {
		A = {x=100, y=100},
		B = {x=500, y=200},
		radius = 50,
	}
	updateOval (Oval)

	Point = {x = 200, y=200, tx=0, ty=0}
	Collides = false
end


function love.update(dt)

end

function drawOval (oval)
	local angle1, angle2, angle3  = oval.angle1, oval.angle2, oval.angle3
	love.graphics.line (oval.A.x, oval.A.y, oval.B.x, oval.B.y)

	love.graphics.arc( 'line', 'open', oval.A.x, oval.A.y, oval.radius, angle1, angle2)
	love.graphics.arc( 'line', 'open', oval.B.x, oval.B.y, oval.radius, angle2, angle3)

	love.graphics.line (oval.A.x+oval.dx, oval.A.y+oval.dy, oval.B.x+oval.dx, oval.B.y+oval.dy)
	love.graphics.line (oval.A.x-oval.dx, oval.A.y-oval.dy, oval.B.x-oval.dx, oval.B.y-oval.dy)
end

function love.draw()
	if Collides then
		love.graphics.setColor (1,0,0)
	else
		love.graphics.setColor (1,1,1)
	end
	drawOval (Oval)

	love.graphics.setColor (1,1,1)
	love.graphics.circle ('line', Point.x, Point.y, 4)
--	if Collides then
		love.graphics.line (Point.x, Point.y, Point.tx, Point.ty)
--	end
end

function pointToOvalOverlap (oval, p1, p2)
	-- Calculate vector AB
	local ax, ay = oval.A.x, oval.A.y
	local bx, by = oval.B.x, oval.B.y

	local dx_AB, dy_AB = bx - ax, by - ay

	local function getDistance(x1, y1, x2, y2)
		return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
	end


	-- Calculate squared distance from point P to line segment AB
	local function distanceToSegment (ax, ay, bx, by, p1, p2)
		local t = ((p1 - ax) * dx_AB + (p2 - ay) * dy_AB) / (dx_AB^2 + dy_AB^2)
		t = math.max(0, math.min(1, t)) -- Clamp t to [0, 1]
		local tx, ty = ax + t * dx_AB, ay + t * dy_AB
		return getDistance(p1, p2, tx, ty), tx, ty
	end

	-- Calculate distance from point P to line segment AB
	local distance, tx, ty = distanceToSegment(ax, ay, bx, by, p1, p2)
	love.window.setTitle (distance)
	
	if distance > oval.radius then
		-- no overlap
		return false, tx, ty
	else -- overlap
		return true, tx, ty
	end

end

function love.mousemoved( x, y, dx, dy, istouch )
	Point.x, Point.y = x, y
	Collides, Point.tx, Point.ty = pointToOvalOverlap(Oval, x, y)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end