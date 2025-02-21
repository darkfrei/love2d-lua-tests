

-- compute first derivative of bezier curve
local function evaluateDerivative(curve, t)
	if type(curve) ~= 'userdata' then return 0, 0 end
	local controlPointCount = curve:getControlPointCount()

	-- for cubic bezier curve (4 control points)
	if controlPointCount >= 4 then
		local derivative = curve:getDerivative()
		return derivative:evaluate(t)
		-- for quadratic bezier curve (3 control points)
	elseif controlPointCount == 3 then
		local p1x, p1y = curve:getControlPoint(1)
		local p2x, p2y = curve:getControlPoint(2)
		local p3x, p3y = curve:getControlPoint(3)
		-- compute derivative components separately
		local dx = 2 * (1 - t) * (p2x - p1x) + 2 * t * (p3x - p2x)
		local dy = 2 * (1 - t) * (p2y - p1y) + 2 * t * (p3y - p2y)
		return dx, dy
	else
		return 0, 0
	end
end

-- compute second derivative of bezier curve
local function evaluateSecondDerivative(curve, t)
	if type(curve) ~= 'userdata' then return 0, 0 end
	local controlPointCount = curve:getControlPointCount()

	-- for cubic bezier curve (4 control points)
	if controlPointCount >= 4 then
		local derivative = curve:getDerivative()
		local secondDerivative = derivative:getDerivative()
		return secondDerivative:evaluate(t)
		-- for quadratic bezier curve (3 control points)
	elseif controlPointCount == 3 then
		local p1x, p1y = curve:getControlPoint(1)
		local p2x, p2y = curve:getControlPoint(2)
		local p3x, p3y = curve:getControlPoint(3)
		-- compute second derivative components separately
		local ddx = 2 * (p1x - 2 * p2x + p3x)
		local ddy = 2 * (p1y - 2 * p2y + p3y)
		return ddx, ddy
	else
		return 0, 0
	end
end

-- compute curvature for bezier curve
local function curvatureAt(curve, t)
	local x1, y1 = evaluateDerivative(curve, t)      -- first derivative
	local x2, y2 = evaluateSecondDerivative(curve, t) -- second derivative
	return (x1 * y2 - y1 * x2) / ((x1^2 + y1^2) ^ (3/2))
end

-- compute normal vector at point on bezier curve (flipped for outward direction)
local function normalAt(curve, t)
	local dx, dy = evaluateDerivative(curve, t)
	return dy, -dx -- rotate by 90 degrees to get outward normal vector
end

---- function to calculate the curvature of a polyline segment using three points
--local function calculatePolylineCurvature(p1x, p1y, p2x, p2y, p3x, p3y)
--	local dx1 = p2x - p1x
--	local dy1 = p2y - p1y
--	local dx2 = p3x - p2x
--	local dy2 = p3y - p2y

--	local crossProduct = dx1 * dy2 - dy1 * dx2

--	local len1 = math.sqrt(dx1^2 + dy1^2)
--	local len2 = math.sqrt(dx2^2 + dy2^2)

----	local curvature = -(crossProduct) / (len1 * len2) -- first
----	local curvature = -(crossProduct) / (len1^2 * len2^2)
--	local curvature = -(crossProduct) / (len1^3 * len2^3) -- second
----	local curvature = -(crossProduct)
--	return curvature*500000
--end

-- function to calculate the curvature of a polyline segment using three points
local function calculatePolylineCurvature(p1x, p1y, p2x, p2y, p3x, p3y)
--	https://gis.stackexchange.com/questions/195370/determining-curvature-of-polylines
	-- compute the determinant (signed area of the triangle)
	local numerator = 2 * ((p2x - p1x) * (p3y - p2y) - (p2y - p1y) * (p3x - p2x))

	-- compute the product of the three segment lengths
	local len1 = (p2x - p1x)^2 + (p2y - p1y)^2
	local len2 = (p3x - p2x)^2 + (p3y - p2y)^2
	local len3 = (p1x - p3x)^2 + (p1y - p3y)^2

	local denominator = math.sqrt(len1 * len2 * len3)

	-- prevent division by zero
	if denominator == 0 then
		return nil
	end
	return -8.1*numerator / denominator
end


-- function to calculate the normal vector to the polyline segment
local function calculatePolylineNormal(p1x, p1y, p2x, p2y, p3x, p3y)
	return p1y - p3y, p3x - p1x
end


function love.load()
	-- create bezier curve
	bezierControlPoints = {
		100, 300, 
		300, 100, 
		500, 500,
		700, 300
	}
	bezier = love.math.newBezierCurve(bezierControlPoints)

	bezierRenderLine = bezier:render()

	bezierLine = {} -- points in Love2D line format
	bezierCurvatureLines = {}
	bezierCurvatureHeightLine = {}

	local length = 20

	local nmax = 16 -- amount of height lines
	for n = 0, nmax do
		local t = n/nmax
		local x, y = bezier:evaluate(t)
--		x = math.floor (x + 0.5)
--		y = math.floor (y + 0.5)
--		local k = math.abs(curvatureAt(bezier, t)) * length
		local k = curvatureAt(bezier, t) * length
		-- get the outward normal vector
		local nx, ny = normalAt(bezier, t)
		-- scale the normal vector by the curvature
		nx = nx * k
		ny = ny * k
		table.insert (bezierCurvatureLines, {x, y, x + nx, y + ny})
		-- store x, y as a pair for curvature height line
		table.insert (bezierCurvatureHeightLine, x + nx)
		table.insert (bezierCurvatureHeightLine, y + ny)


		table.insert (bezierLine, x)
		table.insert (bezierLine, y)
	end

	print ('polyline = {'..table.concat (bezierLine, ',')..'}')
	polyline = bezierLine

	
	local length = 20
	polylineCurvatureLines = {}
	polylineCurvatureHeightLine = {}

	table.insert (polylineCurvatureHeightLine, polyline[1])
	table.insert (polylineCurvatureHeightLine, polyline[2])

	for i = 3, #polyline - 3, 2 do
		local p1x, p1y = polyline[i-2], polyline[i-1]
		local p2x, p2y = polyline[i], polyline[i+1]
		local p3x, p3y = polyline[i+2], polyline[i+3]

		local k = calculatePolylineCurvature(p1x, p1y, p2x, p2y, p3x, p3y)
--		normal
		local nx, ny = calculatePolylineNormal (p1x, p1y, p2x, p2y, p3x, p3y)
--		nx = nx * k * length*1000000
--		ny = ny * k * length*1000000
		nx = nx * k * length
		ny = ny * k * length
		print (p2x, p2y, p2x + nx, p2y + ny)

		table.insert (polylineCurvatureLines, {p2x, p2y, p2x + nx, p2y + ny})
		table.insert (polylineCurvatureHeightLine, p2x + nx)
		table.insert (polylineCurvatureHeightLine, p2y + ny)
	end


	table.insert (polylineCurvatureHeightLine, polyline[#polyline-1])
	table.insert (polylineCurvatureHeightLine, polyline[#polyline])
end


function love.draw()
	-- draw bezier curve
	love.graphics.setLineWidth (1)
	love.graphics.setColor(0, 1, 0, 0.5)
--	love.graphics.line(bezierControlPoints)

	love.graphics.setLineWidth (3)
	love.graphics.setColor(1, 1, 1)
	love.graphics.line(bezierLine)

	love.graphics.setLineWidth (2)
	love.graphics.setColor(1, 0, 0) -- red color
	for i, line in ipairs (bezierCurvatureLines) do
		love.graphics.line(line)
	end

	love.graphics.line(bezierCurvatureHeightLine)

	love.graphics.setLineWidth (2)
	love.graphics.setColor(0, 1, 0) -- green color
	for i, line in ipairs (polylineCurvatureLines) do
		love.graphics.line(line)
	end

	love.graphics.line(polylineCurvatureHeightLine)
end
