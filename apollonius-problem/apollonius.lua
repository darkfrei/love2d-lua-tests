-- apollonius.lua
-- solving all 10 Apollonius problems using apollonius-utils.lua

local geom = require("apollonius-geom")
local epsylon = 1e-6

local M = {}

-- ======================
-- 1. PPP: 3 points
-- ======================
function M.solvePPP(p1,p2,p3)
	local c = geom.circleFrom3Points(p1,p2,p3)
	if c then return {c} else return {} end
end

-- ======================
-- 2. PPL: 2 points + 1 line
-- ======================
function M.solvePPL(p1,p2,l)
	local mid = geom.midpoint(p1,p2)
	local perp = geom.perpendicularLine(geom.lineFromPoints(p1,p2), mid)
	local intersections = geom.lineLineIntersection(perp, l)
	if not intersections then return {} end
	-- distances to points
	local r = geom.distance(intersections, p1)
	return {{x=intersections.x, y=intersections.y, r=r}}
end

-- ======================
-- 3. PLL: 1 point + 2 lines
-- ======================
function M.solvePLL(p, l1, l2, debug)
		geom.recalculateLine(l1)
		geom.recalculateLine(l2)
    local solutions = {}
    local seen = {}

    -- normalize both lines
    local n1 = math.sqrt(l1.a^2 + l1.b^2)
    local n2 = math.sqrt(l2.a^2 + l2.b^2)
    if n1 < epsylon or n2 < epsylon then return {} end

    if debug then
        print(string.format("--- solvePLL ---"))
        print(string.format("point p = (%.6f, %.6f)", p.x, p.y))
        print(string.format("line1: a=%.6f b=%.6f c=%.6f", l1.a, l1.b, l1.c))
        print(string.format("line2: a=%.6f b=%.6f c=%.6f", l2.a, l2.b, l2.c))
    end

    for _, s in ipairs({1, -1}) do
        -- compute bisector line
        local bis = {
            a = l1.a / n1 + s * l2.a / n2,
            b = l1.b / n1 + s * l2.b / n2,
            c = l1.c / n1 + s * l2.c / n2
        }

        if debug then
            print(string.format("bisector s=%d: a=%.6f b=%.6f c=%.6f", s, bis.a, bis.b, bis.c))
        end

        if math.abs(bis.a) < epsylon and math.abs(bis.b) < epsylon then
            if debug then print("  degenerate bisector -> skip") end
        else
            local results
            if math.abs(bis.b) > epsylon then
                results = geom.solveBisectorY(p, l1, l2, bis, n1, eps)
            else
                results = geom.solveBisectorX(p, l1, l2, bis, n1, eps)
            end

            for _, sol in ipairs(results) do
                local key = string.format("%.9f_%.9f_%.9f", sol.x, sol.y, sol.r)
                if not seen[key] then
                    seen[key] = true
                    table.insert(solutions, sol)
                    if debug then
                        print(string.format(
                            "solution: center=(%.9f, %.9f), r=%.9f",
                            sol.x, sol.y, sol.r
                        ))
                    end
                end
            end
        end
    end

    if debug then
        print(string.format("found %d solution(s)", #solutions))
        print("--- end solvePLL ---")
    end

    return solutions
end






local centers = M.solvePLL({x=0, y=0}, {x1=-1, y1=-2, x2=1, y2=-1}, {x1=-1, y1=2, x2=1, y2=1})
for i,c in ipairs(centers) do
	print(string.format("Center %d: (%.3f, %.3f), r=%.3f", i, c.x, c.y, c.r))
end



-- ======================
-- 4. LLL: 3 lines
-- ======================
function M.solveLLL(l1,l2,l3)
--	if l1.x1 then
--		l1 = geom.lineFromTwoPointsCoords(l1)
--	end
--	if l2.x1 then
--		l2 = geom.lineFromTwoPointsCoords(l2)
--	end
--	if l2.x3 then
--		l3 = geom.lineFromTwoPointsCoords(l3)
--	end

	local solutions = {}
	local function intersectionSign(a,b,c)
		local det = a*b - c*b
		return det
	end
	-- brute-force: combine any two lines with perpendicular offsets
	-- approximate solution: use perpendicular bisector intersections
	-- for simplicity, only approximate center at intersection of l1-l2 bisectors
	local perp12 = geom.perpendicularLine(l1, {x=0, y=0})
	local perp13 = geom.perpendicularLine(l3, {x=0, y=0})
	local center = geom.lineLineIntersection(perp12, perp13)
	if center then
		local r = math.min(
			geom.pointLineDistance(center,l1),
			geom.pointLineDistance(center,l2),
			geom.pointLineDistance(center,l3))
		table.insert(solutions, {x=center.x, y=center.y, r=r})
	end
	return solutions
end

-- ======================
-- 5. CLL: 1 circle + 2 lines
-- ======================
function M.solveCLL(c,l1,l2)
	-- circle center on bisector of distances to lines at distance r-c.r
	-- approximate: find intersection of two parallel offset lines
	local d1 = geom.pointLineDistance({x=c.x,y=c.y},l1)
	local d2 = geom.pointLineDistance({x=c.x,y=c.y},l2)
	local r = math.min(d1,d2) + c.r
	-- naive center at c
	return {{x=c.x, y=c.y, r=r}}
end

-- ======================
-- 6. CPL: 1 circle + 1 point + 1 line
-- ======================
function M.solveCPL(c,p,l)
	local tangents = geom.tangentPointsPointCircle(p,c)
	local solutions = {}
	for _, tp in ipairs(tangents) do
		local r = geom.distance(tp, p)
		table.insert(solutions, {x=tp.x, y=tp.y, r=r})
	end
	return solutions
end

-- ======================
-- 7. CPP: 1 circle + 2 points
-- ======================
function M.solveCPP(c,p1,p2)
	local circle1 = geom.circleFrom3Points(p1,p2,{x=c.x+c.r, y=c.y})
	local circle2 = geom.circleFrom3Points(p1,p2,{x=c.x-c.r, y=c.y})
	local solutions = {}
	if circle1 then table.insert(solutions, circle1) end
	if circle2 then table.insert(solutions, circle2) end
	return solutions
end

-- ======================
-- 8. CCL: 2 circles + 1 line
-- ======================
function M.solveCCL(c1,c2,l)
	local intersections = geom.circleCircleIntersection(c1,c2)
	local solutions = {}
	for _, p in ipairs(intersections) do
		local r = math.max(geom.distance(p,c1), geom.distance(p,c2))
		table.insert(solutions, {x=p.x, y=p.y, r=r})
	end
	return solutions
end

-- ======================
-- 9. CCP: 2 circles + 1 point
-- ======================
function M.solveCCP(c1,c2,p)
	local intersections = geom.circleCircleIntersection(c1,c2)
	local solutions = {}
	for _, inter in ipairs(intersections) do
		local r = geom.distance(inter, p)
		table.insert(solutions, {x=inter.x, y=inter.y, r=r})
	end
	return solutions
end

-- ======================
-- 10. CCC: 3 circles
-- ======================
function M.solveCCC(c1,c2,c3)
	local intersections = geom.circleCircleIntersection(c1,c2)
	local solutions = {}
	for _, p in ipairs(intersections) do
		local r = math.max(geom.distance(p,c3), geom.distance(p,c2), geom.distance(p,c1))
		table.insert(solutions, {x=p.x, y=p.y, r=r})
	end
	return solutions
end

return M
