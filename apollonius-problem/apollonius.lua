-- apollonius problem solver
print ('loaded', ...)

local apollonius = {}





function apollonius.ppp (p1, p2, p3)
	-- works
	-- three points
	local x1, y1 = p1.x, p1.y
	local x2, y2 = p2.x, p2.y
	local x3, y3 = p3.x, p3.y

	local A = x1 * (y2 - y3) - y1 * (x2 - x3) + x2 * y3 - x3 * y2
	local B = (x1^2 + y1^2) * (y3 - y2) + (x2^2 + y2^2) * (y1 - y3) + (x3^2 + y3^2) * (y2 - y1)
	local C = (x1^2 + y1^2) * (x2 - x3) + (x2^2 + y2^2) * (x3 - x1) + (x3^2 + y3^2) * (x1 - x2)
	local D = (x1^2 + y1^2) * (x3 * y2 - x2 * y3) + (x2^2 + y2^2) * (x1 * y3 - x3 * y1) + (x3^2 + y3^2) * (x2 * y1 - x1 * y2)

	if A == 0 then
		error("The points are collinear and do not define a circle.")
	end

	-- Calculate the center (h, k) and radius r of the circle
	local h = -B / (2 * A)
	local k = -C / (2 * A)
	local r = math.sqrt((B^2 + C^2 - 4 * A * D) / (4 * A^2))

	return {x=h, y=k, r=r}
end


-------------------------------------------------------------
--- LLL functions

local function lineIntersection(A1, B1, C1, A2, B2, C2)
	local det = A1 * B2 - A2 * B1
	if det == 0 then
		error("Lines are parallel or coincident; no unique intersection.")
	end
	local x = (B2 * -C1 - B1 * -C2) / det
	local y = (A1 * -C2 - A2 * -C1) / det
	return x, y
end

local function externalBisector(l1, l2, external)
	local A1, B1, C1 = l1.a, l1.b, l1.c
	local A2, B2, C2 = l2.a, l2.b, l2.c

	local x0, y0 = lineIntersection(A1, B1, C1, A2, B2, C2)

	local d1 = math.sqrt(A1^2 + B1^2)
	local d2 = math.sqrt(A2^2 + B2^2)

	local factor = external and -1 or 1

	local A_bis = A1 / d1 + factor * A2 / d2
	local B_bis = B1 / d1 + factor * B2 / d2
	local C_bis = -(A_bis * x0 + B_bis * y0)

	return {a = A_bis, b = B_bis, c = C_bis}
end

--[[
local function angleBisectorIntersection(l1, l2, l3)
	-- works great!
	-- intersection points of line pairs
	local x1, y1 = lineIntersection(l1.a, l1.b, l1.c, l2.a, l2.b, l2.c)
	local x2, y2 = lineIntersection(l2.a, l2.b, l2.c, l3.a, l3.b, l3.c)
	local x3, y3 = lineIntersection(l1.a, l1.b, l1.c, l3.a, l3.b, l3.c)
	-- inCircle
	local a = math.sqrt((x2 - x3)^2 + (y2 - y3)^2)
	local b = math.sqrt((x3 - x1)^2 + (y3 - y1)^2)
	local c = math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
	local s = (a + b + c)
	local r = math.abs(x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2)) / s
	local x = (a * x1 + b * x2 + c * x3) / s
	local y = (a * y1 + b * y2 + c * y3) / s
	return x, y, r
end
--]]


local function getLLLCenter(l1, l2, l3, external)
	local bis1 = externalBisector(l1, l2, external)
	local bis2 = externalBisector(l2, l3, external)
	local x, y = lineIntersection(bis1.a, bis1.b, bis1.c, bis2.a, bis2.b, bis2.c)
	local r = math.abs(l1.a * x + l1.b * y + l1.c) / math.sqrt(l1.a^2 + l1.b^2)
	return {x=x,y=y, r=r}
end


local function updateLineCoefficients(l)
	l.a = l.y2-l.y1
	l.b = l.x1-l.x2
	l.c = -(l.a*l.x1 + l.b*l.y1)
--	print ('line a, b, c', l.a, l.b, l.c)
end

function apollonius.lll (l1, l2, l3)
	updateLineCoefficients(l1)
	updateLineCoefficients(l2)
	updateLineCoefficients(l3)
	
	local bis1 = externalBisector(l1, l2)
	local bis2 = externalBisector(l2, l3)
	local bis3 = externalBisector(l3, l1)

	-- white solution
	local mainSolution = getLLLCenter(l3, l1, l2)
	
	-- red, green, yellow solutions:
	local solution2 = getLLLCenter(l3, l1, l2, true)
	local solution3 = getLLLCenter(l2, l3, l1)
	local solution4 = getLLLCenter(l1, l2, l3)

	return mainSolution, solution2, solution3, solution4
end


---------------------

--function apollonius.ccc (c1, c2, c3)
--	-- wrong
--	-- three circles

--	local x1, y1, r1 = c1.x, c1.y, c1.r
--	local x2, y2, r2 = c2.x, c2.y, c2.r
--	local x3, y3, r3 = c3.x, c3.y, c3.r

--	local k1 = 1 / r1
--	local k2 = 1 / r2
--	local k3 = 1 / r3

--	-- Descartes Circle Theorem for externally tangent circles:
--	local k4 = k1 + k2 + k3 + 2 * math.sqrt(k1 * k2 + k2 * k3 + k3 * k1)
--	local r4 = 1 / k4  -- Radius of the solution circle

--	-- Calculate the position of the solution circle’s center
--	local x4 = (x1 * k1 + x2 * k2 + x3 * k3) / (k1 + k2 + k3)
--	local y4 = (y1 * k1 + y2 * k2 + y3 * k3) / (k1 + k2 + k3)

--	-- Verify the solution with the given circles
--	local distance1 = math.sqrt((x4 - x1)^2 + (y4 - y1)^2)
--	local distance2 = math.sqrt((x4 - x2)^2 + (y4 - y2)^2)
--	local distance3 = math.sqrt((x4 - x3)^2 + (y4 - y3)^2)

--	if math.abs(distance1 - (r4 + r1)) > 1e-6 or
--	math.abs(distance2 - (r4 + r2)) > 1e-6 or
--	math.abs(distance3 - (r4 + r3)) > 1e-6 then
--		error("No valid solution found with the current approach.")
--	end


--	return {x=x4, y=y4, r=r4}
--end

return apollonius