-- apollonius.lua
-- solves all 10 apollonius problems using apollonius-geom.lua

local geom = require("apollonius-geom")
local epsylon = 1e-6

local M = {}

-- ======================
-- 1. ppp: 3 points
-- ======================
function M.solvePPP(p1,p2,p3)
	local c = geom.circleFrom3Points(p1,p2,p3)
	if c then return {c} else return {} end
end

-- ======================
-- 2. ppl: 2 points + 1 line
-- ======================
function M.solvePPL(p1, p2, line, debug)
	local eps = 1e-9
	local solutions = {}

	if not p1 or not p2 or not line then return solutions end

	if debug then
		print("\n--- solvePPL ---")
		print(string.format("p1=(%.3f,%.3f)  p2=(%.3f,%.3f)", p1.x, p1.y, p2.x, p2.y))
		print(string.format("line: a=%.3f b=%.3f c=%.3f", line.a or 0, line.b or 0, line.c or 0))
	end

	-- compute midpoint and perpendicular unit vector
	local m, u, d = geom.midpointAndPerpUnit(p1, p2)
	if d < eps then return solutions end

	-- compute quadratic coefficients
	local Qa, Qb, Qc = geom.pplQuadraticCoeffs(m, u, d, line)

	-- solve quadratic for t parameter
	local roots = geom.solveQuadratic(Qa, Qb, Qc, eps)

	for _, t in ipairs(roots) do
		-- construct circle from solution parameter
		local sol = geom.pplSolutionFromT(t, m, u, p1, line, eps)
		if sol.valid then
			table.insert(solutions, sol)
		end
	end

	return solutions
end

-- ======================
-- 3. pll: 1 point + 2 lines
-- ======================
function M.solvePLL(p, l1, l2, debug)
    geom.recalculateLine(l1)
    geom.recalculateLine(l2)
    local solutions = {}
    local seen = {}

    local ok, n1, n2 = geom.areLinesValid(l1, l2, epsylon)
    if not ok then return {} end

    for _, s in ipairs({1, -1}) do
        -- compute bisector of two lines
        local bis = geom.lineBisector(l1, l2, n1, n2, s)

        if math.abs(bis.a) >= epsylon or math.abs(bis.b) >= epsylon then
						-- find all circle centers satisfying tangency condition
            local results = geom.solveBisector(p, l1, l2, bis, epsylon)
            for _, sol in ipairs(results) do
                local key = string.format("%.9f_%.9f_%.9f", sol.x, sol.y, sol.r)
                if not seen[key] then
                    seen[key] = true
                    table.insert(solutions, sol)
                end
            end
        end
    end
    return solutions
end

-- ======================
-- 4. lll: 3 lines
-- ======================
function M.solveLLL(l1, l2, l3, debug)
    geom.recalculateLine(l1)
    geom.recalculateLine(l2)
    geom.recalculateLine(l3)

    local solutions = {}
    local seen = {}

    local ok12, n1, n2 = geom.areLinesValid(l1, l2, epsylon)
    local ok23, n2b, n3 = geom.areLinesValid(l2, l3, epsylon)
    if not (ok12 and ok23) then return {} end

    for _, s1 in ipairs({1, -1}) do
        local bis12 = geom.lineBisector(l1, l2, n1, n2, s1)
        for _, s2 in ipairs({1, -1}) do
            local bis23 = geom.lineBisector(l2, l3, n2b, n3, s2)

            -- compute intersection of two bisectors
            local p = geom.lineLineIntersection(bis12, bis23)
            if p then
                local r1 = geom.pointLineDistance(p, l1)
                local r2 = geom.pointLineDistance(p, l2)
                local r3 = geom.pointLineDistance(p, l3)
                local tol = 1e-5
                if math.abs(r1 - r2) < tol and math.abs(r1 - r3) < tol then
                    local key = string.format("%.9f_%.9f_%.9f", p.x, p.y, r1)
                    if not seen[key] then
                        seen[key] = true
                        table.insert(solutions, {x = p.x, y = p.y, r = r1})
                    end
                end
            end
        end
    end
    return solutions
end

-- ======================
-- 5. cll: 1 circle + 2 lines
-- ======================
function M.solveCLL(c, l1, l2)
    local solutions = {}
    local seen = {}
    local tol = 1e-9
    local compareTol = 1e-5

    geom.recalculateLine(l1)
    geom.recalculateLine(l2)

    local a1, b1, c1 = l1.a, l1.b, l1.c
    local a2, b2, c2 = l2.a, l2.b, l2.c

    local n1 = geom.lineNorm(l1)
    local n2 = geom.lineNorm(l2)

    local signs = {1, -1}
    local tangency_types = {1, -1}

    for _, s1 in ipairs(signs) do
        for _, s2 in ipairs(signs) do
            -- solve for parametric form of circle centers
            local X0, X1, Y0, Y1 = geom.solveLinearSystemParam(
                a1, b1, a2, b2,
                c1, c2,
                s1 * n1, s2 * n2,
                tol
            )
            if X0 then
                local Ox, Oy, rC = c.x, c.y, c.r
                local Ux, Uy = X0 - Ox, Y0 - Oy
                local alpha = X1*X1 + Y1*Y1
                local beta = 2*(X1*Ux + Y1*Uy)
                local gamma = Ux*Ux + Uy*Uy

                for _, t in ipairs(tangency_types) do
                    -- construct quadratic equation for radius
                    local Qa = alpha - 1
                    local Qb = beta - 2 * t * rC
                    local Qc = gamma - rC * rC
                    local roots = geom.solveQuadratic(Qa, Qb, Qc, tol)

                    -- compute valid circle centers from roots
                    for _, rprime in ipairs(roots) do
                        if rprime < 0 then rprime = 0 end
                        local cx = X0 + X1 * rprime
                        local cy = Y0 + Y1 * rprime
                        local center = {x = cx, y = cy}
                        local d1 = geom.pointLineDistance(center, l1)
                        local d2 = geom.pointLineDistance(center, l2)
                        local perimDist = math.abs(geom.distance(center, {x = Ox, y = Oy}) - rC)

                        if math.abs(d1 - rprime) < compareTol
                           and math.abs(d2 - rprime) < compareTol
                           and math.abs(perimDist - rprime) < compareTol then
                            local key = string.format("%.9f_%.9f_%.9f", cx, cy, rprime)
                            if not seen[key] then
                                seen[key] = true
                                table.insert(solutions, {x = cx, y = cy, r = rprime})
                            end
                        end
                    end
                end
            end
        end
    end

    return solutions
end

-- ======================
-- 6. cpl: 1 circle + 1 point + 1 line
-- ======================
function M.solveCPL(c,p,l)
	-- find tangent points from p to c
	local tangents = geom.tangentPointsPointCircle(p,c)
	local solutions = {}
	for _, tp in ipairs(tangents) do
		local r = geom.distance(tp, p)
		table.insert(solutions, {x=tp.x, y=tp.y, r=r})
	end
	return solutions
end

-- ======================
-- 7. cpp: 1 circle + 2 points
-- ======================
function M.solveCPP(c,p1,p2)
	-- build circles from 3 points shifted by radius in both directions
	local circle1 = geom.circleFrom3Points(p1,p2,{x=c.x+c.r, y=c.y})
	local circle2 = geom.circleFrom3Points(p1,p2,{x=c.x-c.r, y=c.y})
	local solutions = {}
	if circle1 then table.insert(solutions, circle1) end
	if circle2 then table.insert(solutions, circle2) end
	return solutions
end

-- ======================
-- 8. ccl: 2 circles + 1 line
-- ======================
function M.solveCCL(c1,c2,l)
	-- find intersections of two circles
	local intersections = geom.circleCircleIntersection(c1,c2)
	local solutions = {}
	for _, p in ipairs(intersections) do
		local r = math.max(geom.distance(p,c1), geom.distance(p,c2))
		table.insert(solutions, {x=p.x, y=p.y, r=r})
	end
	return solutions
end

-- ======================
-- 9. ccp: 2 circles + 1 point
-- ======================
function M.solveCCP(c1,c2,p)
	-- find intersection points and use distance to p as radius
	local intersections = geom.circleCircleIntersection(c1,c2)
	local solutions = {}
	for _, inter in ipairs(intersections) do
		local r = geom.distance(inter, p)
		table.insert(solutions, {x=inter.x, y=inter.y, r=r})
	end
	return solutions
end

-- ======================
-- 10. ccc: 3 circles
-- ======================
function M.solveCCC(c1,c2,c3)
	-- find intersections of first two circles and check distance to third
	local intersections = geom.circleCircleIntersection(c1,c2)
	local solutions = {}
	for _, p in ipairs(intersections) do
		local r = math.max(geom.distance(p,c3), geom.distance(p,c2), geom.distance(p,c1))
		table.insert(solutions, {x=p.x, y=p.y, r=r})
	end
	return solutions
end

return M
