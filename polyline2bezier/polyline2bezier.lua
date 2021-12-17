-- polyline2bezier
-- how to convert polyline to bezier

-- https://github.com/ynakajima/polyline2bezier
-- https://github.com/ynakajima/polyline2bezier/blob/39186756eb7524f6797b27f798129d95e6459abc/src/polyline2bezier.js


local P2B = {}

local function v2SubII(a, b)
	local x, y = a.x-b.x, a.y-b.y
	return {x=x, y=y}
--	local x, y = b.x-a.x, b.y-a.y
--	return {x=-x, y=-y}
end

local function v2Normalize(v)
	local length = ((v.x*v.x)+(v.y*v.y))^0.5
	return {x=v.x/length, y=v.y/length}
end

local function computeLeftTangent(d, e)
    local tHat1 = v2SubII(d[e+1], d[e])
--    local tHat1 = {x=1, y=0}
    tHat1 = v2Normalize(tHat1)
    return tHat1
end

local function computeRightTangent(d, e)
--    local tHat2 = v2SubII(d[e], d[e-1])
    local tHat2 = v2SubII(d[e-1], d[e])
--    local tHat2 = {x=1, y=0}
    tHat2 = v2Normalize(tHat2)
    return tHat2
end

local function v2DistanceBetween2Points(a, b)
    local dx, dy = a.x-b.x,a.y-b.y;
    return math.sqrt((dx*dx)+(dy*dy))
end

local function lerp (a, b, t)
	return a + t*(b-a)
end

local function  chordLengthParameterize(d, first, last)
	local u = {0}
	local nPts = last-first+1
	local uMax = 0
	for i = 2, nPts do -- from second to last
		local j = i+first-1
--		print (i, j, first, last)
		u[i] = u[i-1] + v2DistanceBetween2Points(d[j-1], d[j])
		uMax = u[i]
	end
	for i = 1, nPts do
		local t = u[i]/uMax
--		print (i, 'chordLengthParameterize', nPts, t, uMax)
		u[i] = t
	end
	return u
end

local function B0 (u)
	return (1-u)*(1-u)*(1-u)
end

local function B1 (u)
	return 3*u*(1-u)*(1-u)
end

local function B2 (u)
	return 3*u*u*(1-u)
end

local function B3 (u)
	return u*u*u
end

local function v2Length (v)
	return math.sqrt((v.x*v.x)+(v.y*v.y))
end

local function v2Scale (v, newLen)
	local lenght = v2Length (v)
	if lenght > 0 then
		return {x=v.x*newLen/lenght, y=v.y*newLen/lenght}
--	else
--		return v
	end
end

local function v2Dot (a, b)
	return (a.x*b.x) + (a.y*b.y)
end

local function v2AddII (a, b)
	return {x=a.x+b.x, y=a.y+b.y}
end

local function v2ScaleIII(v, s)
    return {x=v.x*s; y=v.y*s}
end

local function getTemp (d1, d2, d3, u)
	local b0, b1, b2, b3 = B0(u), B1(u), B2(u), B3(u)
--	local temp = - d1 (+ (* d2 b0) (+ (* d2 b1) (+ (* d3 b2) (* d3 b3))))
--	local temp = d1 - (d2*b0 + d2*b1 + d3*b2 + d3 * b3)

	local xi, xf, xl = d1.x, d2.x, d3.x
	local yi, yf, yl = d1.y, d2.y, d3.y
	
	local x = xi - (xf*b0 + xf*b1 + xl*b2 + xl*b3)
	local y = yi - (yf*b0 + yf*b1 + yl*b2 + yl*b3)

--	local temp = v2SubII (d1,
--		v2AddII (
--			v2ScaleIII (d2,b0),
--			v2AddII (
--				v2ScaleIII (d2, b1),
--					v2AddII (
--						v2ScaleIII (d3, b2),
--						v2ScaleIII (d3, b3)))))
	
--	return temp
	return {x=x, y=y}

end

local function v2Add(a, b) -- same as v2AddII(a, b)
	return {x = a.x + b.x, y = a.y + b.y}
end

local function generateBezier (d, first, last, uPrime, tHat1, tHat2)
	local bezCurve = {}
	local nPts = last - first + 1 -- Example: from 0 to 3 OR from 1 to 4
	
	local A = {}
--	print ('nPts', nPts)
	for i = 1, nPts do
		local v1 = {x=tHat1.x, y=tHat1.y}
		local v2 = {x=tHat2.x, y=tHat2.y}
		local u = uPrime[i]
		v1 = v2Scale(v1, B1(u))
		v2 = v2Scale(v2, B2(u))
		A[i] = {v1, v2}
	end
	
	local C = {{0,0}, {0,0}}
	local X = {0, 0}
	
	for i = 1, nPts do
		C[1][1] = C[1][1] + v2Dot(A[i][1], A[i][1])
		C[1][2] = C[1][1] + v2Dot(A[i][1], A[i][2])
		
		C[2][1] = C[1][2]
		C[2][2] = C[2][2] + v2Dot(A[i][2], A[i][2])
		
		-- check it
		local temp = getTemp (d[first+i-1], d[first], d[last], uPrime[i])
		
		X[1] = X[1] + v2Dot (A[i][1], temp)
		X[2] = X[2] + v2Dot (A[i][2], temp)
	end
	
    local det_C0_C1 = C[1][1] * C[2][2] - C[2][1] * C[1][2]
    local det_C0_X  = C[1][1] * X[2]    - C[2][1] * X[1]
    local det_X_C1  = X[1]    * C[2][2] - X[2]    * C[1][2]
	
	local alpha_l = det_X_C1 / det_C0_C1
	local alpha_r = det_C0_X / det_C0_C1
	
	local segLength = v2DistanceBetween2Points(d[last], d[first])
	local epsilon = (1/2^20) * segLength
	
	if (alpha_l < epsilon or alpha_r < epsilon) then
		
		local dist = segLength / 3
		local p1 = d[first]
		local p4 = d[last]

		local p2 = v2Add(p1, v2Scale(tHat1, dist))
		local p3 = v2Add(p4, v2Scale(tHat2, dist))
		local bezCurve = {p1, p2, p3, p4}
		return bezCurve
	else
		local p1 = d[first]
		local p4 = d[last]
		
		local p2 = v2Add(p1, v2Scale(tHat1, alpha_l))
		local p3 = v2Add(p4, v2Scale(tHat1, alpha_r))
		local bezCurve = {p1, p2, p3, p4}
		return bezCurve
	end
end

local function bezierII(degree, V, t)
	-- degree == 3 is cubic; 4 points
	local nPts = degree+1
	local Vtemp = {}
	for i = 1, nPts do
		Vtemp[i] = {x=V[i].x, y=V[i].y}
	end
	
	for i = 2, nPts do
		for j = 1, i-1 do
			-- lerp
			Vtemp[j].x = (1-t)*Vtemp[j].x + t*Vtemp[j+1].x
			Vtemp[j].y = (1-t)*Vtemp[j].y + t*Vtemp[j+1].y
		end
	end
	
	-- Q is a point on bezier at parameter t
	local Q = {x=Vtemp[1].x, y=Vtemp[1].y}
	return Q
end

local function v2SquaredLength(v)
	return (v.x*v.x)+(v.y*v.y)
end

local function computeMaxError(d, first, last, bezCurve, u, splitPoint)
	-- for example splitPoint in the middle
--	local splitPoint = splitPoint or math.floor((last - first + 1)/2)
	local maxErr = 0
--	print ('computeMaxError', first, last)
	for i = first+1, last-1 do
		-- parameter t
		local t = u[i-first+1]
--		print (i ,'t', t)
		-- point on bezier at t
		local P = bezierII (3, bezCurve, t)
		local v = v2SubII(P, d[i])
		local sqDist = v2SquaredLength(v)
--		if sqDist >= maxSqDist then
		if sqDist > maxErr then
			maxErr = sqDist
			splitPoint = i
		end
	end
	-- check it 
--	maxErr = math.sqrt (maxErr)
	return maxErr, splitPoint
end

local function newtonRaphsonRootFind(bezCurve, point, u) -- (_Q, _P, u)
	local Q1 = {} -- {{x=0, y=0}, {x=0, y=0}, {x=0, y=0}}
	local Q2 = {} -- {{x=0, y=0}, {x=0, y=0}}
	
	local Q = bezCurve
	local P = {x=point.x, y=point.y}
    
    
    local Q_u = bezierII(3, Q, u);
    
--    /* Generate control vertices for Q'  */
    for i = 1, 3 do
		Q1[i] = {x=(Q[i+1].x-Q[i].x)*3, y=(Q[i+1].y-Q[i].y)*3}
	end
    
--    /* Generate control vertices for Q'' */
    for i = 1, 2 do
		Q2[i]= {x=(Q1[i+1].x - Q1[i].x) * 2.0, y = (Q1[i+1].y - Q1[i].y) * 2.0}
    end
    
--    /* Compute Q'(u) and Q''(u)  */
    local Q1_u = bezierII(2, Q1, u);
    local Q2_u = bezierII(1, Q2, u);
    
--    /* Compute f(u)/f'(u) */
    local numerator = (Q_u.x - P.x) * (Q1_u.x) + (Q_u.y - P.y) * (Q1_u.y)
    local denominator = (Q1_u.x)*(Q1_u.x)+(Q1_u.y)*(Q1_u.y)
		+(Q_u.x-P.x)*(Q2_u.x)+(Q_u.y-P.y)*(Q2_u.y)
    if denominator == 0 then return u end

--    /* u = u - f(u)/f'(u) */
    local uPrime = u - (numerator/denominator);
    return uPrime
end

local function reparameterize(d, first, last, u, bezCurve)
    local uPrime = {}

    for i = first, last do
		local newBezCurve = {
			{x=bezCurve[1].x, y=bezCurve[1].y},
			{x=bezCurve[2].x, y=bezCurve[2].y},
			{x=bezCurve[3].x, y=bezCurve[3].y},
			{x=bezCurve[4].x, y=bezCurve[4].y},
		}
		uPrime[i-first+1] = newtonRaphsonRootFind(newBezCurve, d[i], u[i-first+1])
	end
    return uPrime
end

local function computeCenterTangent(d, center)
	local V1 = v2SubII(d[center-1], d[center])
	local V2 = v2SubII(d[center], d[center+1])
--	V1, V2 = v2Normalize(V1), v2Normalize(V2) -- check it
	local tHatCenter = {x=(V1.x+V2.x)/2, y=(V1.y+V2.y)/2}
    tHatCenter = v2Normalize(tHatCenter)
	return tHatCenter
end

local function v2Negate(v)
	return {x=-v.x, y=-v.y}
end
  
local function fitCubic (bezCurves, d, first, last, tHat1, tHat2, err, ignore)
--	local bezCurve
--	local uPrime = {}
--	local maxErr
	
	local nPts = last - first + 1
--	local splitPoint = math.ceil(nPts/2)
	local iterationErr = err*err
	local maxIterations = 4
--	local tHatCenter = nil -- {x=x, y=y}
	
	if nPts == 2 then
		-- line
		local x1, y1 = d[first].x, d[first].y
		local x4, y4 = d[last].x, d[last].y
		local x2, y2 = lerp(x1, x4, 1/3), lerp(y1, y4, 1/3)
		local x3, y3 = lerp(x1, x4, 2/3), lerp(y1, y4, 2/3)
		local bezCurve = {
			{x=x1, y=y1}, 
			{x=x2, y=y2}, 
			{x=x3, y=y3}, 
			{x=x4, y=y4}, 
		}
		table.insert(bezCurves, bezCurve)
		return
	elseif nPts == 3 then
		-- quadratic
		local x1, y1 = d[first].x, d[first].y
		local x4, y4 = d[last].x, d[last].y
		local xi, yi = d[first+1].x, d[first+1].y
		local x2, y2 = x1+(2/3)*(xi-x1), y1+(2/3)*(yi-y1)
		local x3, y3 = x4+(2/3)*(xi-x4), y4+(2/3)*(yi-y4)
		local bezCurve = {
			{x=x1, y=y1}, 
			{x=x2, y=y2}, 
			{x=x3, y=y3}, 
			{x=x4, y=y4}, 
		}
		table.insert(bezCurves, bezCurve)
--		print ('quadratic')
		return
	elseif nPts == 4 then
		-- cubic
		local u =  chordLengthParameterize(d, first, last)
		local bezCurve =  generateBezier(d, first, last, u, tHat1, tHat2)
		table.insert(bezCurves, bezCurve)
--		print ('cubic')
		return
	end
	
	local u =  chordLengthParameterize(d, first, last)
	
	-- generateBezier (d, first, last, uPrime, tHat1, tHat2)
	local bezCurve =  generateBezier(d, first, last, u, tHat1, tHat2)
	
	-- resultMaxError returns maxErr, splitPoint
	local splitPoint = math.floor((last - first + 1)/2)
	local maxErr, splitPoint = computeMaxError(d, first, last, bezCurve, u, splitPoint)
	
	
--	if maxErr < err then
--		print ('maxErr < err', maxErr, err)
--		table.insert(bezCurves, bezCurve)
--		return
--	end
	
	
	if maxErr < iterationErr then
--		print ('maxErr < iterationErr', maxErr, iterationErr)
		for i = 1, maxIterations do
			
			local uPrime = reparameterize(d, first, last, u, bezCurve)
			bezCurve = generateBezier(d, first, last, uPrime, tHat1, tHat2)
--			uPrime = reparameterize(d, first, last, u, bezCurve)
--			bezCurve = generateBezier(d, first, last, uPrime, tHat1, tHat2)
			
			-- (d, first, last, bezCurve, u)
			local maxErr, splitPoint = computeMaxError(d, first, last, bezCurve, uPrime, splitPoint)
			
			if maxErr < err then
--				print ('saved', i, maxErr)
				table.insert(bezCurves, bezCurve)
				return
			end
		end
	end
	
	local splitPoint = math.floor((last + first + 1)/2)+1
	
--	print ('split', first, splitPoint, last)
	local tHatCenter = computeCenterTangent(d, splitPoint)
    fitCubic(bezCurves, d, first, splitPoint, tHat1, tHatCenter, err)
	
    tHatCenter = v2Negate(tHatCenter)
    fitCubic(bezCurves, d, splitPoint, last, tHatCenter, tHat2, err)
	
end



function P2B.fitCurve(d, nPts, err, ignore)
	local tHat1 = computeLeftTangent(d, 1) -- first and second
	local tHat2 = computeRightTangent(d, nPts) -- prelast and last
	
	local bezCurves = {}
	fitCubic(bezCurves, d, 1, nPts, tHat1, tHat2, err, ignore)
	
	return bezCurves
end

function P2B.polyline2bezier (line, err, ignore)
	local d = {} -- array of points
--	local bezierSegments = {}
	err = err or 4
	
	for i = 1, #line-1, 2 do
		table.insert (d, {x=line[i], y=line[i+1]})
	end
	
	local bezCurves = P2B.fitCurve(d, #d, err, ignore)
--	serpent = require ('serpent')
--	print(serpent.block (bezCurves))
	
	local bezierSegments = {}
	for i, bezCurve in ipairs (bezCurves) do
		bezierSegments[i] = {}
		for j, point in ipairs (bezCurve) do
--			print ('#bezCurve', #bezCurve)
			table.insert (bezierSegments[i], point.x)
			table.insert (bezierSegments[i], point.y)
		end
	end
	
	print ('#bezierSegments', #bezierSegments)
	
	return bezierSegments
end

return P2B