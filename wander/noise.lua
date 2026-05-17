local Noise = {}

local gradients3 = {
	{ 1, 1, 0 }, { -1, 1, 0 }, { 1, -1, 0 }, { -1, -1, 0 },
	{ 1, 0, 1 }, { -1, 0, 1 }, { 1, 0, -1 }, { -1, 0, -1 },
	{ 0, 1, 1 }, { 0, -1, 1 }, { 0, 1, -1 }, { 0, -1, -1 },
}

local function fade(t)
	return t * t * t * (t * (t * 6 - 15) + 10)
end

local function lerp(a, b, t)
	return a + t * (b - a)
end

local function gradDot(hash, x, y, z)
	local g = gradients3[(hash % #gradients3) + 1]
	return g[1] * x + g[2] * y + g[3] * z
end

local function permHash(perm, x, y, z)
	return perm[(perm[(perm[x] + y) % 256] + z) % 256]
end

function Noise.new(seed)
	local rng = love.math.newRandomGenerator(seed or os.time())

	local base = {}
	for i = 0, 255 do
		base[i] = i
	end

	for i = 255, 1, -1 do
		local j = rng:random(0, i)
		base[i], base[j] = base[j], base[i]
	end

	local perm = {}
	for i = 0, 511 do
		perm[i] = base[i % 256]
	end

	return {
		seed = seed or os.time(),
		perm = perm,
	}
end

function Noise.perlin3(noise, x, y, z)
	local perm = noise.perm

	local xi = math.floor(x) % 256
	local yi = math.floor(y) % 256
	local zi = math.floor(z) % 256

	local xf = x - math.floor(x)
	local yf = y - math.floor(y)
	local zf = z - math.floor(z)

	local u = fade(xf)
	local v = fade(yf)
	local w = fade(zf)

	local aaa = permHash(perm, xi, yi, zi)
	local aba = permHash(perm, xi, (yi + 1) % 256, zi)
	local aab = permHash(perm, xi, yi, (zi + 1) % 256)
	local abb = permHash(perm, xi, (yi + 1) % 256, (zi + 1) % 256)

	local baa = permHash(perm, (xi + 1) % 256, yi, zi)
	local bba = permHash(perm, (xi + 1) % 256, (yi + 1) % 256, zi)
	local bab = permHash(perm, (xi + 1) % 256, yi, (zi + 1) % 256)
	local bbb = permHash(perm, (xi + 1) % 256, (yi + 1) % 256, (zi + 1) % 256)

	local x1 = lerp(gradDot(aaa, xf, yf, zf), gradDot(baa, xf - 1, yf, zf), u)
	local x2 = lerp(gradDot(aba, xf, yf - 1, zf), gradDot(bba, xf - 1, yf - 1, zf), u)
	local y1 = lerp(x1, x2, v)

	local x3 = lerp(gradDot(aab, xf, yf, zf - 1), gradDot(bab, xf - 1, yf, zf - 1), u)
	local x4 = lerp(gradDot(abb, xf, yf - 1, zf - 1), gradDot(bbb, xf - 1, yf - 1, zf - 1), u)
	local y2 = lerp(x3, x4, v)

	return lerp(y1, y2, w)
end

function Noise.fbm3(noise, x, y, z, octaves, persistence, lacunarity)
	local total = 0
	local amplitude = 1
	local frequency = 1
	local amplitudeSum = 0

	octaves = octaves or 1
	persistence = persistence or 0.5
	lacunarity = lacunarity or 2.0

	for _ = 1, octaves do
		total = total + Noise.perlin3(noise, x * frequency, y * frequency, z * frequency) * amplitude
		amplitudeSum = amplitudeSum + amplitude
		amplitude = amplitude * persistence
		frequency = frequency * lacunarity
	end

	if amplitudeSum < 1e-7 then
		return 0
	end

	return total / amplitudeSum
end

return Noise