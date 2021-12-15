-- polyline2bezier
-- how to convert polyline to bezier

-- https://github.com/ynakajima/polyline2bezier
-- https://github.com/ynakajima/polyline2bezier/blob/39186756eb7524f6797b27f798129d95e6459abc/src/polyline2bezier.js


local P2B = {}

local function v2SubII(a, b)
	local cx, cy = a.x-b.x, a.y-b.y
	return {x=cx, y=cy}
end

local function v2Normalize(v)
	local length = ((v.x * v.x) + (v.y * v.y))^0.5
	return {x=v.x/length, y=v.y/length}
end

local function computeLeftTangent(d, e)
    local tHat1 = v2SubII(d[e+1], d[e])
    tHat1 = v2Normalize(tHat1)
    return tHat1
end

local function computeRightTangent(d, e)
    local tHat2 = v2SubII(d[e-1], d[e])
    tHat2 = v2Normalize(tHat2)
    return tHat2
end

local function v2DistanceBetween2Points(a, b)
    local dx, dy = a.x - b.x,a.y - b.y;
    return math.sqrt((dx*dx)+(dy*dy))
end

local function lerp (a, b, t)
	return a + t*(b-a)
end

local function  chordLengthParameterize(d, first, last)
	
	local u = {}
	u[1] = 0
	for i = first, last-1 do
		-- please check it
		u[i-first+2] = u[i-first+1] + v2DistanceBetween2Points(d[i], d[i+1])
		
	end
	local uMax = u[#u]
	for i = first, last do
		-- please check it
		u[i-first+2] = u[i-first+2]/uMax
	end
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
	return math.sqrt((v.x * v.x) + (v.y * v.y))
end

local function v2Scale (v, newLen)
	local lenght = v2Length (v)
	if lenght > 0 then
		return {x=v.x*newLen/lenght, y=v.x*newLen/lenght}
	end
end

local function v2Dot (a, b)
	return (a.x*b.x) + (a.y*b.y)
end

--local function v2SubII(a, b)
--    var  c = new Vector2();
--    c.x = a.x - b.x; c.y = a.y - b.y;
--    return c;
--end

local function v2AddII (a, b)
	return {x=a.x+b.x, y=a.y+b.y}
end

local function v2ScaleIII(v, s)
    return {x = v.x * s; y = v.y * s}
end

local function getTemp (d1, d2, d3, u)
	local b0, b1, b2, b3 = B0(u), B1(u), B2(u), B3(u)
	local temp = v2SubII (d1,
		v2AddII (
			v2ScaleIII (d2,b0),
		v2AddII (
			v2ScaleIII (d2, b1),
				v2AddII (
					v2ScaleIII (d3, b2),
					v2ScaleIII (d3, b3)))))
	return temp
	
end

local function v2Add(a, b) -- same as v2AddII(a, b)
	return {x = a.x + b.x, y = a.y + b.y}
end

local function generateBezier (d, first, last, uPrime, tHat1, tHat2)
	local bezCurve = {}
	local nPts = last - first + 1 -- Example: from 0 to 3 OR from 1 to 4
	
	local A = {}
	for i = 1, nPts do
		local v1 = {x=tHat1.x, y=tHat1.y}
		local v2 = {x=tHat2.x, y=tHat2.y}
		local u = uPrime[i]
		v1 = v2Scale(v1, B1(u))
		v2 = v2Scale(v2, B1(u))
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
	end  
end

local function fitCubic (bezCurves, d, first, last, tHat1, tHat2, err)
	local bezCurve
	local uPrime = {}
	local maxErr
	local splitPoint
	local nPts = last - first + 1
	local iterationErr = err*err
	local maxIterations = 4
	local tHatCenter = nil -- {x=x, y=y}
	local i
	
	if nPts == 2 then
		local x1, y1 = d[first].x, d[first].y
		local x2, y2 = d[last].x, d[last].y
		bezCurve = {} -- control points
		for i = 0, 3 do
			table.insert(bezCurve, lerp (x1, x2, i/3))
			table.insert(bezCurve, lerp (y1, y2, i/3))
		end
		table.insert(bezCurves, bezCurve)
		return
	end
	
	local u =  chordLengthParameterize(d, first, last)
	bezCurve =  generateBezier(d, first, last, u, tHat1, tHat2)
	
end



function P2B.fitCurve(d, nPts, err)
	local tHat1 = computeLeftTangent(d, 1) -- first and second
	local tHat2 = computeRightTangent(d, nPts) -- prelast and last
	
	local bezCurves = {}
	getFitCubic(bezCurves, d, 1, nPts, tHat1, tHat2, err)
	
	return bezCurves
end

function P2B.polyline2bezier (line, err)
	local d = {} -- array of points
	local bezierSegments = {}
	err = err or 4
	
	for i = 1, #line-1, 2 do
		table.insert (d, {x=line[i], y=line[i+1]})
	end
	
	local bezCurve = P2B.fitCurve(d, #d, err)
	
	return bezierSegments
end

return P2B