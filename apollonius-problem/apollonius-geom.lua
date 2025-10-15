-- apollonius-geom.lua
-- helper functions for solving Apollonius' problems in 2D geometry

local geom = {}
local epsylon = 1e-6


-- ========= BASIC TYPES =========
-- point = {x=..., y=...}
-- circle = {x=..., y=..., r=...}
-- line = {a=..., b=..., c=...} -- ax + by + c = 0

-- ========= BASIC GEOMETRY FUNCTIONS =========

function geom.distLine(x, y, a, b, c)
	return (a*x + b*y + c) / math.sqrt(a*a + b*b)
end



-- create line from two points (x1,y1) and (x2,y2)
-- returns {a, b, c} such that a*x + b*y + c = 0
function geom.lineFromTwoPointsCoords(l)
	local x1, y1 = l.x1, l.y1
	local x2, y2 = l.x2, l.y2
	l.a = y2 - y1
	l.b = x1 - x2
	l.c = -(l.a*x1 + l.b*y1)
end

-- recalculate line: fill either a,b,c from points, or x1,y1,x2,y2 from a,b,c
function geom.recalculateLineCoefficiens(l, width, height)
	width = width or love.graphics.getWidth ()
	height = height or love.graphics.getHeight ()
	if l.a and l.b and l.c then
		-- есть коэффициенты, нужно получить две точки для рисования
		local points = {}
		local a, b, c = l.a, l.b, l.c

		if math.abs(b) > epsylon then
			-- линия не вертикальная: y = (-a*x - c)/b
			table.insert(points, {x=0, y=(-a*0 - c)/b})
			table.insert(points, {x=width, y=(-a*width - c)/b})
		else
			-- вертикальная линия: x = -c/a
			local x = -c/a
			table.insert(points, {x=x, y=0})
			table.insert(points, {x=x, y=height})
		end

		-- присваиваем в l для рисования
		l.x1 = points[1].x
		l.y1 = points[1].y
		l.x2 = points[2].x
		l.y2 = points[2].y
	else
		error("Line must have either points or coefficients")
	end
	return l
end


--function geom.recalculateLine (l)
--	if not l.a then
----		print ('recalculateLine 1:', l.x1, l.y1, l.x2, l.y2)
--		geom.lineFromTwoPointsCoords(l)
--	end
--	if l.a then
--		local width, height = love.graphics.getDimensions()
--		geom.recalculateLineCoefficiens(l, width, height)
----		print ('recalculateLine 2:', l.x1, l.y1, l.x2, l.y2)
--	end
--end

-- recalculate line coefficients (normalize if needed)
function geom.recalculateLine(l)
	local a, b, c = l.a, l.b, l.c
	if not a or not b or not c then
		local dx = l.x2 - l.x1
		local dy = l.y2 - l.y1
		a = dy
		b = -dx
		c = -(a * l.x1 + b * l.y1)
	end
	l.a, l.b, l.c = a, b, c
end
-- 

-- euclidean distance between two points
function geom.distance(p1, p2)
	local dx, dy = p1.x - p2.x, p1.y - p2.y
	return math.sqrt(dx * dx + dy * dy)
end

-- perpendicular distance from point to line
function geom.pointLineDistance(p, l)
	return math.abs(l.a * p.x + l.b * p.y + l.c) / math.sqrt(l.a * l.a + l.b * l.b)
end

-- return unit normal length of line
function geom.lineNorm(l)
	return math.sqrt(l.a * l.a + l.b * l.b)
end

-- solve when bisector is x = m2*y + k2
function geom.solveBisectorX(p, l1, l2, bis, n1, eps)
	local results = {}
	local m2 = -bis.b / bis.a
	local k2 = -bis.c / bis.a
	local px, py = p.x, p.y
	local Lc = (l1.a * m2 + l1.b)
	local Ld = (l1.a * k2 + l1.c)
	local A = m2*m2 + 1 - (Lc*Lc)/(n1*n1)
	local B = 2*(m2*(k2 - px) - py) - 2*(Lc*Ld)/(n1*n1)
	local C = (k2 - px)^2 + py^2 - (Ld*Ld)/(n1*n1)
	for _, y in ipairs(geom.solveQuadratic(A, B, C, eps)) do
		local x = m2*y + k2
		local r = geom.distance(p, {x=x, y=y})
		local dl1 = geom.pointLineDistance({x=x, y=y}, l1)
		local dl2 = geom.pointLineDistance({x=x, y=y}, l2)
		if math.abs(dl1 - r) < 1e-5 and math.abs(dl2 - r) < 1e-5 then
			table.insert(results, {x=x, y=y, r=r})
		end
	end
	return results
end

-- solve when bisector is y = m*x + k
function geom.solveBisectorY(p, l1, l2, bis, n1, eps)
	local results = {}
	local m = -bis.a / bis.b
	local k = -bis.c / bis.b
	local px, py = p.x, p.y
	local Lc = (l1.a + l1.b * m)
	local Ld = (l1.b * k + l1.c)
	local A = 1 + m*m - (Lc*Lc)/(n1*n1)
	local B = -2*px + 2*m*(k - py) - 2*(Lc*Ld)/(n1*n1)
	local C = px*px + (k - py)^2 - (Ld*Ld)/(n1*n1)
	for _, x in ipairs(geom.solveQuadratic(A, B, C, eps)) do
		local y = m*x + k
		local r = geom.distance(p, {x=x, y=y})
		local dl1 = geom.pointLineDistance({x=x, y=y}, l1)
		local dl2 = geom.pointLineDistance({x=x, y=y}, l2)
		if math.abs(dl1 - r) < 1e-5 and math.abs(dl2 - r) < 1e-5 then
			table.insert(results, {x=x, y=y, r=r})
		end
	end
	return results
end

-- compute bisector coefficients for sign s = ±1
function geom.lineBisector(l1, l2, s)
	local n1 = geom.lineNorm(l1)
	local n2 = geom.lineNorm(l2)
	local a = l1.a / n1 - s * (l2.a / n2)
	local b = l1.b / n1 - s * (l2.b / n2)
	local c = l1.c / n1 - s * (l2.c / n2)
	return {a = a, b = b, c = c}
end



-- solve quadratic equation A*x² + B*x + C = 0
function geom.solveQuadratic(A, B, C, eps)
	eps = eps or epsylon
	local roots = {}
	if math.abs(A) < eps then
		if math.abs(B) < eps then return roots end
		table.insert(roots, -C / B)
		return roots
	end
	local D = B * B - 4 * A * C
	if D < -eps then return roots end
	if D < 0 then D = 0 end
	local sqrtD = math.sqrt(D)
	table.insert(roots, (-B + sqrtD) / (2 * A))
	table.insert(roots, (-B - sqrtD) / (2 * A))
	return roots
end

-- check if point lies on a circle
function geom.isPointOnCircle(p, c, eps)
	eps = eps or epsylon
	return math.abs(geom.distance(p, {x=c.x, y=c.y}) - c.r) < eps
end

-- check if point lies on a line
function geom.isPointOnLine(p, l, eps)
	geom.recalculateLine (l)
	eps = eps or epsylon
	return math.abs(l.a*p.x + l.b*p.y + l.c) < eps
end

-- tangent points from external point to circle
function geom.tangentPointsPointCircle(p, c)
	local dx = c.x - p.x
	local dy = c.y - p.y
	local d2 = dx*dx + dy*dy
	local r2 = c.r*c.r
	if d2 < r2 then
		return {} -- point is inside circle, no tangents
	end
	local d = math.sqrt(d2)
	local l = r2 / d2
	local h = c.r * math.sqrt(d2 - r2) / d2

	local x1 = c.x - l*dx + h*dy
	local y1 = c.y - l*dy - h*dx
	local x2 = c.x - l*dx - h*dy
	local y2 = c.y - l*dy + h*dx
	return {{x=x1, y=y1}, {x=x2, y=y2}}
end

-- intersection of two circles
function geom.circleCircleIntersection(c1, c2)
	local dx = c2.x - c1.x
	local dy = c2.y - c1.y
	local d = math.sqrt(dx*dx + dy*dy)
	if d > c1.r + c2.r or d < math.abs(c1.r - c2.r) then
		return {} -- no intersection
	end
	local a = (c1.r^2 - c2.r^2 + d^2) / (2*d)
	local h = math.sqrt(c1.r^2 - a^2)
	local xm = c1.x + a*dx/d
	local ym = c1.y + a*dy/d
	local xs1 = xm + h*dy/d
	local ys1 = ym - h*dx/d
	local xs2 = xm - h*dy/d
	local ys2 = ym + h*dx/d
	return {{x=xs1, y=ys1}, {x=xs2, y=ys2}}
end

-- intersection of line and circle
function geom.lineCircleIntersection(l, c)
	geom.recalculateLine (l)
	local a, b, cc = l.a, l.b, l.c + 0 -- avoid modifying original
	local cx, cy, r = c.x, c.y, c.r
	local x0, y0 = 0, 0

	if math.abs(b) > epsylon then
		-- y = (-ax - c)/b
		local A = 1 + (a/b)^2
		local B = 2*a*cc/b^2 - 2*cx + 2*a*cy/b
		local C = cx*cx + (cc/b + cy)^2 - r*r
		local D = B*B - 4*A*C
		if D < -epsylon then return {} end
		D = math.max(D,0)
		local sqrtD = math.sqrt(D)
		local x1 = (-B + sqrtD)/(2*A)
		local x2 = (-B - sqrtD)/(2*A)
		local y1 = (-a*x1 - cc)/b
		local y2 = (-a*x2 - cc)/b
		return {{x=x1, y=y1}, {x=x2, y=y2}}
	else
		-- vertical line x = -c/a
		local x = -cc/a
		local dx = r*r - (x - cx)^2
		if dx < -epsylon then return {} end
		dx = math.max(dx,0)
		local y1 = cy + math.sqrt(dx)
		local y2 = cy - math.sqrt(dx)
		return {{x=x, y=y1}, {x=x, y=y2}}
	end
end

-- intersection of two lines
function geom.lineLineIntersection(l1, l2)
	geom.recalculateLine (l1)
	geom.recalculateLine (l2)
	local det = l1.a*l2.b - l2.a*l1.b
	if math.abs(det) < epsylon then 
		print ('lineLineIntersection', math.abs(det) ..'<'..epsylon)
		return nil 
	end
	local x = (l2.b*(-l1.c) - l1.b*(-l2.c))/det
	local y = (l1.a*(-l2.c) - l2.a*(-l1.c))/det
	local point = {x=x, y=y}
	return point
end

-- create line from two points
function geom.lineFromPoints(p1, p2)
	local a = p2.y - p1.y
	local b = p1.x - p2.x
	local c = -(a*p1.x + b*p1.y)
	return {a=a, b=b, c=c}
end

-- midpoint between two points
function geom.midpoint(p1, p2)
	return {x=(p1.x + p2.x)/2, y=(p1.y + p2.y)/2}
end

-- vector operations
function geom.addVec(v1,v2) return {x=v1.x+v2.x, y=v1.y+v2.y} end
function geom.subVec(v1,v2) return {x=v1.x-v2.x, y=v1.y-v2.y} end
function geom.mulVec(v,s) return {x=v.x*s, y=v.y*s} end
function geom.lenVec(v) return math.sqrt(v.x*v.x + v.y*v.y) end
function geom.normalize(v) local l=geom.lenVec(v); return {x=v.x/l, y=v.y/l} end



-- perpendicular line through a point
function geom.perpendicularLine(l, p, flip)
	geom.recalculateLine(l)
	local a, b = -l.b, l.a
	if flip then
		a, b = -a, -b
	end
	local c = -(a*p.x + b*p.y)
	local perpLine = {a=a, b=b, c=c}
	geom.recalculateLine(perpLine)
	return perpLine
end





-- circle from 3 points
function geom.circleFrom3Points(p1,p2,p3)
	local m1 = geom.midpoint(p1,p2)
	local m2 = geom.midpoint(p2,p3)
	local l1 = geom.perpendicularLine(geom.lineFromPoints(p1,p2), m1)
	local l2 = geom.perpendicularLine(geom.lineFromPoints(p2,p3), m2)
	local center = geom.lineLineIntersection(l1,l2)
--	print ('circleFrom3Points', center.x, center.y)
	if not center then return nil end
	local r = geom.distance(center, p1)
	local circle = {x=center.x, y=center.y, r=r}
	return circle
end



return geom
