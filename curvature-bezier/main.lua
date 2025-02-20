

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


function love.load()
	-- create bezier curve
	bezierControlPoints = {
		100, 500, 
		200, 100, 
		250, 500, 
		600, 100,
		700, 400
	}
	bezier = love.math.newBezierCurve(bezierControlPoints)

	bezierLine = bezier:render()

	bezierCurvatureLines = {}
	bezierCurvatureHeightLine = {}
	local nmax = 60 -- amound of height lines
	local length = 20
	for n = 0, nmax do
		local t = n/nmax
		local x, y = bezier:evaluate(t)
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
	end
end


function love.draw()
	-- draw bezier curve
	love.graphics.setLineWidth (1)
	love.graphics.setColor(0, 1, 0, 0.5)
	love.graphics.line(bezierControlPoints)

	love.graphics.setLineWidth (3)
	love.graphics.setColor(1, 1, 1, 0.5)
	love.graphics.line(bezierLine)


	love.graphics.setColor(1, 0, 0, 0.5) -- red color
	for i, line in ipairs (bezierCurvatureLines) do
		love.graphics.line(line)
	end

	love.graphics.line(bezierCurvatureHeightLine)

end
