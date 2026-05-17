local Wander = {}

local W, H = 1920, 1080

local MAX_SPEED   = 170
local MAX_FORCE   = 130
local WANDER_DIST = 95
local WANDER_RAD  = 58
local JITTER      = 0.9

local NOISE_SCALE  = 0.0017
local NOISE_WEIGHT = 4.8
local FBM_OCTAVES  = 3
local FBM_PERSIST  = 0.50

local FIELD_GRID  = 70

local TRAIL_STEP  = 10
local TRAIL_MAX   = 50000

local v           = {}
local trail       = {}
local show_field  = true
local noise_seed  = 0
local field_cache = {}

local perm = {}

local GRAD = {
	{ 1, 1}, {-1, 1}, { 1,-1}, {-1,-1},
	{ 1, 0}, {-1, 0}, { 0, 1}, { 0,-1},
}

local function noise_init(seed)
	math.randomseed(seed)
	local p = {}
	for i = 0, 255 do p[i] = i end
	for i = 255, 1, -1 do
		local j = math.random(0, i)
		p[i], p[j] = p[j], p[i]
	end
	for i = 0, 511 do perm[i] = p[i % 256] end
end

local function fade(t)  return t*t*t*(t*(t*6 - 15) + 10) end

local function gdot(h, x, y)
	local g = GRAD[(h % 8) + 1]
	return g[1]*x + g[2]*y
end

local function noise2d(x, y)
	local xi = math.floor(x) % 256
	local yi = math.floor(y) % 256
	local xf = x - math.floor(x)
	local yf = y - math.floor(y)

	local aa = perm[(perm[xi    ] + yi    ) % 256]
	local ab = perm[(perm[xi    ] + yi + 1) % 256]
	local ba = perm[(perm[xi + 1] + yi    ) % 256]
	local bb = perm[(perm[xi + 1] + yi + 1) % 256]

	local u  = fade(xf)
	local vf = fade(yf)
	local x1 = u*(gdot(ba, xf-1, yf  ) - gdot(aa, xf, yf  )) + gdot(aa, xf, yf  )
	local x2 = u*(gdot(bb, xf-1, yf-1) - gdot(ab, xf, yf-1)) + gdot(ab, xf, yf-1)
	return vf*(x2 - x1) + x1
end

local function fbm(x, y)
	local val, amp, freq, norm = 0, 1, 1, 0
	for _ = 1, FBM_OCTAVES do
		val  = val  + noise2d(x*freq, y*freq) * amp
		norm = norm + amp
		amp  = amp  * FBM_PERSIST
		freq = freq * 2.1
	end
	return val / norm
end

local OX, OY = 43.73, 17.91
local function flow_angle(wx, wy)
	local s  = NOISE_SCALE
	local nx = fbm(wx*s,      wy*s      )
	local ny = fbm(wx*s + OX, wy*s + OY)
	return math.atan2(ny, nx)
end

local function build_field()
	field_cache = {}
	local cols = math.ceil(W / FIELD_GRID) + 1
	local rows = math.ceil(H / FIELD_GRID) + 1
	for ci = 0, cols do
		field_cache[ci] = {}
		for ri = 0, rows do
			field_cache[ci][ri] = flow_angle(
				(ci + 0.5) * FIELD_GRID,
				(ri + 0.5) * FIELD_GRID)
		end
	end
end

local function vlen(x, y)  return math.sqrt(x*x + y*y) end

local function vnorm(x, y)
	local l = vlen(x, y)
	if l < 1e-7 then return 0, 0 end
	return x/l, y/l
end

local function vclamp(x, y, m)
	local l = vlen(x, y)
	if l > m then return x/l*m, y/l*m end
	return x, y
end

local function twrap(n, m)  return ((n % m) + m) % m end

local function adiff(a, b)
	local d = (b - a) % (2*math.pi)
	return d > math.pi and d - 2*math.pi or d
end

local function wander_geo()
	local hx, hy = vnorm(v.vx, v.vy)
	if hx == 0 and hy == 0 then hx = 1 end
	local cx = v.x + hx * WANDER_DIST
	local cy = v.y + hy * WANDER_DIST
	local tx = cx + math.cos(v.wa) * WANDER_RAD
	local ty = cy + math.sin(v.wa) * WANDER_RAD
	return cx, cy, tx, ty
end

function Wander.init(seed)
	noise_seed = seed or os.time()
	noise_init(noise_seed)
	build_field()
	math.randomseed(noise_seed + 9999)

	v = {
		x  = W / 2,
		y  = H / 2,
		vx = MAX_SPEED,
		vy = 0,
		wa = math.random() * math.pi * 2,
	}
	trail = { {x = math.floor(v.x), y = math.floor(v.y)} }

	love.graphics.setBackgroundColor(0.055, 0.055, 0.105)
	love.graphics.setLineStyle("smooth")
end

function Wander.update(dt)
	local jd = (math.random() * 2 - 1) * JITTER * dt
	local fa = flow_angle(v.x, v.y)
	local nd = adiff(v.wa, fa) * NOISE_WEIGHT * dt

	v.wa = v.wa + jd + nd

	local _, _, tx, ty = wander_geo()
	local dx, dy       = vnorm(tx - v.x, ty - v.y)
	local sx, sy       = vclamp(dx*MAX_SPEED - v.vx, dy*MAX_SPEED - v.vy, MAX_FORCE)

	v.vx, v.vy = vclamp(v.vx + sx*dt, v.vy + sy*dt, MAX_SPEED)

	v.x = twrap(v.x + v.vx*dt, W)
	v.y = twrap(v.y + v.vy*dt, H)

	local last   = trail[#trail]
	local px, py = math.floor(v.x), math.floor(v.y)
	if vlen(px - last.x, py - last.y) >= TRAIL_STEP then
		trail[#trail + 1] = {x = px, y = py}
		if #trail > TRAIL_MAX then table.remove(trail, 1) end
	end
end

function Wander.draw()
	if show_field then
		local half = FIELD_GRID * 0.21
		local cols  = math.ceil(W / FIELD_GRID)
		local rows  = math.ceil(H / FIELD_GRID)

		for ci = 0, cols do
			for ri = 0, rows do
				local fa = field_cache[ci] and field_cache[ci][ri]
				if fa then
					local wx = (ci + 0.5) * FIELD_GRID
					local wy = (ri + 0.5) * FIELD_GRID
					local dx = math.cos(fa) * half
					local dy = math.sin(fa) * half

					local t  = math.sin(fa) * 0.5 + 0.5
					love.graphics.setColor(0.08 + 0.28*t, 0.90 + 0.30*t, 0.60 + 0.22*t, 0.60)
					love.graphics.setLineWidth(2)
					love.graphics.line(wx - dx, wy - dy, wx + dx, wy + dy)

					love.graphics.setColor(0.25 + 0.28*t, 0.46*2 + 0.22*t, 0.88, 0.36)
					love.graphics.circle("fill", wx + dx, wy + dy, 3)
				end
			end
		end
	end

	love.graphics.setLineWidth(3)
	local n = #trail
	for i = 2, n do
		local a, b = trail[i-1], trail[i]
		if math.abs(b.x - a.x) < W*0.5 and math.abs(b.y - a.y) < H*0.5 then
			local age = i / n
			love.graphics.setColor(0.12*4 + 1*age, 0.42*1.5 + 1*age, 1.0, 0.09*4 + 1*age)
			love.graphics.line(a.x, a.y, b.x, b.y)
		end
	end

	local cx, cy, tx, ty = wander_geo()

	love.graphics.setColor(1, 1, 0.55, 0.23)
	love.graphics.setLineWidth(1)
	love.graphics.line(v.x, v.y, cx, cy)

	love.graphics.setColor(1, 1, 0.38, 0.21)
	love.graphics.circle("line", cx, cy, WANDER_RAD)
	love.graphics.setColor(1, 1, 0.38, 0.42)
	love.graphics.circle("fill", cx, cy, 2.5)

	local fa  = flow_angle(v.x, v.y)
	local fl  = WANDER_RAD * 0.80
	local nex = cx + math.cos(fa) * fl
	local ney = cy + math.sin(fa) * fl
	love.graphics.setColor(0.28, 0.68, 1.0, 0.62)
	love.graphics.setLineWidth(1.5)
	love.graphics.line(cx, cy, nex, ney)
	love.graphics.circle("fill", nex, ney, 4)

	love.graphics.setColor(1, 0.50, 0.07, 0.92)
	love.graphics.line(cx, cy, tx, ty)

	love.graphics.setColor(1, 0.17, 0.03, 1)
	love.graphics.circle("fill", tx, ty, 6)
	love.graphics.setColor(1, 1, 1, 0.68)
	love.graphics.setLineWidth(1)
	love.graphics.circle("line", tx, ty, 6)

	local angle = math.atan2(v.vy, v.vx)
	love.graphics.push()
	love.graphics.translate(v.x, v.y)
	love.graphics.rotate(angle)
	love.graphics.setColor(0, 0, 0, 0.32)
	love.graphics.polygon("fill",  20, 2,  -10, 11,  -6, 2,  -10, -7)
	love.graphics.setColor(0.20, 0.86, 0.44)
	love.graphics.polygon("fill",  20, 0,  -10, 10,  -6, 0,  -10, -10)
	love.graphics.setColor(0.78, 1.0, 0.80, 0.90)
	love.graphics.setLineWidth(1.2)
	love.graphics.polygon("line",  20, 0,  -10, 10,  -6, 0,  -10, -10)
	love.graphics.setColor(1, 1, 1, 0.52)
	love.graphics.circle("fill", 10, 0, 2.5)
	love.graphics.pop()
end

function Wander.keypressed(key)
	if key == "f" then
		show_field = not show_field
	elseif key == "n" then
		Wander.init(os.time())
	elseif key == "r" then
		math.randomseed(os.time())
		v = {
			x  = math.random(200, W - 200),
			y  = math.random(200, H - 200),
			vx = MAX_SPEED,
			vy = 0,
			wa = math.random() * math.pi * 2,
		}
		trail = { {x = math.floor(v.x), y = math.floor(v.y)} }
	end
end

return Wander
