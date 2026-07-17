-- appolonius-li.lua
--
-- Lie sphere geometry toolkit.
--
-- A "cycle" (point, oriented circle, or oriented line) is represented
-- as a 5-vector { x0, x1, x2, x3, x4 } living on the Lie quadric in
-- R^{3,2}. The bilinear form is
--
--     <x,y> = -x0*y0 + x1*y1 + x2*y2 + x3*y4 + x4*y3
--
-- Every valid cycle vector satisfies <x,x> = 0. Two oriented cycles
-- are tangent (touch with matching orientation) iff <x,y> = 0.
--
-- Encodings used:
--   point  (a,b)                -> { 0, a, b, -1, (a^2+b^2)/2 }
--   circle (a,b,r) signed radius -> { r, a, b, -1, (a^2+b^2-r^2)/2 }
--   line   unit normal (nx,ny),
--          nx*x + ny*y = p       -> { 1, nx, ny, 0, p }
--
-- All three cases satisfy <x,x> = 0 identically, and a line is the
-- r -> infinity limit of a circle, taken up to overall projective
-- scale (no special-casing needed at runtime).

local Cycle = {}

local EPS = 1e-9


-- Constructors


-- oriented circle, center (a,b), signed radius r (r == 0 -> a point)
function Cycle.circle(a, b, r)
	return { r, a, b, -1, (a * a + b * b - r * r) * 0.5 }
end

-- point = circle of zero radius
function Cycle.point(a, b)
	return Cycle.circle(a, b, 0)
end

-- oriented line: nx*x + ny*y = p (nx,ny need not be unit length)
function Cycle.line(nx, ny, p)
	local len = math.sqrt(nx * nx + ny * ny)
	if len < EPS then
		error("appolonius-li: degenerate line normal")
	end
	nx, ny, p = nx / len, ny / len, p / len
	return { 1, nx, ny, 0, p }
end

-- oriented line through two points, normal points to the right of a->b
function Cycle.line_through(ax, ay, bx, by)
	local dx, dy = bx - ax, by - ay
	local len = math.sqrt(dx * dx + dy * dy)
	if len < EPS then
		error("appolonius-li: line_through given coincident points")
	end
	local nx, ny = dy / len, -dx / len
	local p = nx * ax + ny * ay
	return Cycle.line(nx, ny, p)
end


-- The Lie bilinear form and related predicates


local function lie_dot(x, y)
	return -x[1] * y[1] + x[2] * y[2] + x[3] * y[3] + x[4] * y[5] + x[5] * y[4]
end
Cycle.dot = lie_dot

local function lie_norm(x)
	return lie_dot(x, x)
end
Cycle.norm = lie_norm

-- true if the vector actually lies on the Lie quadric
function Cycle.is_valid(x, eps)
	return math.abs(lie_norm(x)) < (eps or 1e-6)
end

-- true if two oriented cycles touch with matching orientation
function Cycle.is_tangent(x, y, eps)
	return math.abs(lie_dot(x, y)) < (eps or 1e-6)
end

-- same locus, opposite orientation (reflection e0: x0 -> -x0 only)
function Cycle.reverse(x)
	return { -x[1], x[2], x[3], x[4], x[5] }
end


-- Decode a cycle vector back into Euclidean data
-- returns "point", a, b
--      or "circle", a, b, r      (r ~= 0)
--      or "line",   nx, ny, p    (unit normal)


function Cycle.decode(x, eps)
	eps = eps or 1e-9
	if math.abs(x[4]) > eps then
		local s = -1 / x[4]
		local r = x[1] * s
		local a = x[2] * s
		local b = x[3] * s
		if math.abs(r) < 1e-6 then
			return "point", a, b
		end
		return "circle", a, b, r
	else
		if math.abs(x[1]) < eps then
			error("appolonius-li: degenerate cycle vector, cannot decode")
		end
		local s = 1 / x[1]
		return "line", x[2] * s, x[3] * s, x[5] * s
	end
end


-- Linear algebra helpers (private)


-- M applied to a cycle vector (M is the 5x5 matrix of the Lie form)
local function Mv(v)
	return { -v[1], v[2], v[3], v[5], v[4] }
end

-- null space of a 3x5 matrix given as three row vectors of length 5.
-- Assumes rank 3 (the three input cycles are independent), which is
-- the generic case. Returns two basis vectors u, v of the 2-D kernel.
local function null_space_3x5(r1, r2, r3)
	local m = {
		{ r1[1], r1[2], r1[3], r1[4], r1[5] },
		{ r2[1], r2[2], r2[3], r2[4], r2[5] },
		{ r3[1], r3[2], r3[3], r3[4], r3[5] },
	}

	local pivot_cols = {}
	local row = 1
	for col = 1, 5 do
		if row > 3 then break end
		local piv
		for r = row, 3 do
			if math.abs(m[r][col]) > 1e-9 then piv = r break end
		end
		if piv then
			if piv ~= row then m[piv], m[row] = m[row], m[piv] end
			local f = m[row][col]
			for c = 1, 5 do m[row][c] = m[row][c] / f end
			for r = 1, 3 do
				if r ~= row then
					local f2 = m[r][col]
					if f2 ~= 0 then
						for c = 1, 5 do m[r][c] = m[r][c] - f2 * m[row][c] end
					end
				end
			end
			pivot_cols[row] = col
			row = row + 1
		end
	end

	local rank = row - 1
	local is_pivot = {}
	for i = 1, rank do is_pivot[pivot_cols[i]] = i end

	local free_cols = {}
	for col = 1, 5 do
		if not is_pivot[col] then table.insert(free_cols, col) end
	end

	assert(rank == 3 and #free_cols == 2,
		"appolonius-li: the three cycles are not independent (degenerate configuration)")

	local basis = {}
	for _, fc in ipairs(free_cols) do
		local vec = { 0, 0, 0, 0, 0 }
		vec[fc] = 1
		for i = 1, rank do
			vec[pivot_cols[i]] = -m[i][fc]
		end
		table.insert(basis, vec)
	end

	return basis[1], basis[2]
end

-- find every q = alpha*u + beta*v (up to scale) with <q,q> = 0
local function solve_pencil(u, v)
	local A = lie_norm(u)
	local Bc = lie_dot(u, v)
	local C = lie_norm(v)

	local function combine(alpha, beta)
		local q = {}
		for i = 1, 5 do q[i] = alpha * u[i] + beta * v[i] end
		return q
	end

	-- every vector in this 2-D subspace is null: the three inputs meet
	-- tangentially at a single point, so infinitely many cycles work
	if math.abs(A) < EPS and math.abs(Bc) < EPS and math.abs(C) < EPS then
		return "infinite", { u, v }
	end

	-- u and v are themselves already the two solutions (signature (1,1))
	if math.abs(A) < EPS and math.abs(C) < EPS then
		return "solutions", { combine(1, 0), combine(0, 1) }
	end

	if math.abs(C) > EPS then
		-- solve C*t^2 + 2*Bc*t + A = 0, t = beta/alpha (alpha = 1)
		local disc = Bc * Bc - A * C
		if disc < -EPS then
			return "solutions", {}
		elseif disc < EPS then
			return "solutions", { combine(1, -Bc / C) }
		else
			local sq = math.sqrt(disc)
			return "solutions", {
				combine(1, (-Bc + sq) / C),
				combine(1, (-Bc - sq) / C),
			}
		end
	else
		-- C ~ 0, A ~= 0: solve A*s^2 + 2*Bc*s = 0, s = alpha/beta (beta = 1)
		local sols = { combine(0, 1) }
		if math.abs(Bc) > EPS then
			table.insert(sols, combine(-2 * Bc / A, 1))
		end
		return "solutions", sols
	end
end


-- Public solver


-- find every cycle tangent to all three given (oriented) cycles x,y,z.
-- returns a plain array of 0, 1 or 2 solution vectors, or
-- "infinite", u, v  if x,y,z meet tangentially at one point (any cycle
-- in the pencil spanned by u,v is a valid answer).
function Cycle.solve_apollonius(x, y, z)
	local r1, r2, r3 = Mv(x), Mv(y), Mv(z)
	local u, v = null_space_3x5(r1, r2, r3)
	local status, payload = solve_pencil(u, v)
	if status == "infinite" then
		return "infinite", payload[1], payload[2]
	end
	return payload
end

-- convenience wrapper: try the 4 essentially distinct orientation
-- combinations of x,y,z and collect every tangent cycle found,
-- decoded to Euclidean data. Recovers the classical answer (<= 8
-- circles/lines/points) for a generic configuration. Degenerate
-- "infinite solutions" configurations are not enumerated here.
function Cycle.solve_apollonius_all(x, y, z)
	local ry, rz = Cycle.reverse(y), Cycle.reverse(z)
	local combos = { { x, y, z }, { x, ry, z }, { x, y, rz }, { x, ry, rz } }

	-- decode the inputs once so we can filter out trivial "solutions"
	-- that just reproduce one of the given cycles. This happens when
	-- the inputs are themselves mutually tangent: each one can then
	-- legitimately turn up in the null space of the other two, but it
	-- is not a new 4th tangent cycle.
	local inputs = {}
	for _, c in ipairs({ x, y, z }) do
		local ok, kind, p1, p2, p3 = pcall(Cycle.decode, c)
		if ok then table.insert(inputs, { kind = kind, a = p1, b = p2, r = p3 }) end
	end

	local function same(kind, a, b, r, other, eps)
		eps = eps or 1e-4
		if kind ~= other.kind then return false end
		return math.abs(a - other.a) < eps
		and math.abs(b - other.b) < eps
		and math.abs(math.abs(r or 0) - math.abs(other.r or 0)) < eps
	end

	local found = {}
	for _, combo in ipairs(combos) do
		local qs = Cycle.solve_apollonius(combo[1], combo[2], combo[3])
		if type(qs) == "table" then
			for _, q in ipairs(qs) do
				local ok, kind, p1, p2, p3 = pcall(Cycle.decode, q)
				if ok then
					local is_trivial = false
					for _, inp in ipairs(inputs) do
						if same(kind, p1, p2, p3, inp) then is_trivial = true break end
					end
					local is_dup = false
					for _, f in ipairs(found) do
						if same(kind, p1, p2, p3, f) then is_dup = true break end
					end
					if not is_trivial and not is_dup then
						table.insert(found, { kind = kind, a = p1, b = p2, r = p3, vector = q })
					end
				end
			end
		end
	end
	return found
end


-- Self-test (run with: lua appolonius-li.lua)
-- Three mutually tangent unit circles, Descartes configuration.
-- Expected tangent circles: r ~= 0.154701 (inner) and r ~= 2.154701
-- (enclosing), both centered near (1, 0.57735).

if not love then
	local c1 = Cycle.circle(0, 0, 1)
	local c2 = Cycle.circle(2, 0, 1)
	local c3 = Cycle.circle(1, math.sqrt(3), 1)

	local results = Cycle.solve_apollonius_all(c1, c2, c3)
	print(string.format("found %d candidate tangent cycles:", #results))
	for _, s in ipairs(results) do
		if s.kind == "circle" then
			print(string.format("  circle  a=%.4f  b=%.4f  r=%.6f", s.a, s.b, s.r))
		elseif s.kind == "point" then
			print(string.format("  point   a=%.4f  b=%.4f", s.a, s.b))
		else
			print(string.format("  line    nx=%.4f  ny=%.4f  p=%.4f", s.a, s.b, s.r))
		end
	end
end

return Cycle