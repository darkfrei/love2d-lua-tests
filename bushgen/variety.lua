-- variety.lua
-- random recipes for bushgen, in two layers:
--   makeStyle(seed, t)           shared look of a set: palette, outline,
--                                texture, fringe, contrast, ornaments, bark
--   makePlant(style, seed, t)    one plant in that style: kind, size,
--                                proportions, counts, flowers, undergrowth
-- all ranges live in data_variety.lua
--
-- time: every continuous parameter follows its own smooth random curve
-- over t (one channel per parameter), so moving t a little changes the
-- plant a little: that is the mutation animation. choices that cannot
-- change smoothly (plant kind, outline mode, number of colours, flower
-- shape) are taken at fixed positions and do not change with t.

local bushgen = require("bushgen")
local plants = require("data_plants")
local ranges = require("data_variety")

local variety = {}

local floor, sqrt, max, min = math.floor, math.sqrt, math.max, math.min
local hashU = bushgen.hash

local byName = {}
for _, p in ipairs(plants) do
	byName[p.name] = p
end

---------------------------------------------------------------- smooth noise

-- catmull-rom through random values at whole numbers of t: smooth curve,
-- no stops at the knots; each channel is shifted so knots do not line up
local function curve(seed, ch, t)
	t = t + hashU(seed, ch, 99991) * 7
	local i = floor(t)
	local f = t - i
	local p0 = hashU(seed, ch, i - 1)
	local p1 = hashU(seed, ch, i)
	local p2 = hashU(seed, ch, i + 1)
	local p3 = hashU(seed, ch, i + 2)
	local v = 0.5 * ((2 * p1) + (-p0 + p2) * f
		+ (2 * p0 - 5 * p1 + 4 * p2 - p3) * f * f
		+ (-p0 + 3 * p1 - 3 * p2 + p3) * f * f * f)
	return max(0, min(1, v))
end

-- continuous parameter in a range {a, b}
local function cont(seed, ch, t, range)
	return range[1] + (range[2] - range[1]) * curve(seed, ch, t)
end

-- parameter that is mostly 0; when on it grows from 0 smoothly
local function contChance(seed, ch, t, chance, range)
	local u = curve(seed, ch, t)
	local on = max(0, (u - (1 - chance)) / chance)
	return range[2] * on
end

-- fixed choice, independent of t
local function fixed(seed, ch)
	return hashU(seed, ch, 424242)
end

local function pickU(list, u)
	return list[min(#list, 1 + floor(u * #list))]
end

local function pickWeightedU(list, u)
	local total = 0
	for _, e in ipairs(list) do total = total + e.weight end
	local v = u * total
	for _, e in ipairs(list) do
		v = v - e.weight
		if v <= 0 then return e end
	end
	return list[#list]
end

local function intU(range, u)
	return min(range[2], range[1] + floor(u * (range[2] - range[1] + 1)))
end

-- moves hue a toward hue b along the shorter way round, f in 0..1;
-- the result is not wrapped, so a ramp from it interpolates correctly
local function lerpHue(a, b, f)
	local d = ((b - a + 540) % 360) - 180
	return a + d * f
end

local function copy(t)
	local q = {}
	for k, v in pairs(t) do q[k] = v end
	return q
end

local function scalePair(t, f, lo)
	lo = lo or 0
	return {max(lo, t[1] * f), max(lo, t[2] * f)}
end

---------------------------------------------------------------- style

local STYLE_FIELDS = {
	"palette", "outlineMode", "shadow", "crease", "gap", "fringe", "texture",
	"textureStep", "edgeTips", "noise", "contrast", "fold", "toneMix",
	"toneLight", "bodyMix", "clumpSquash", "spot",
}

function variety.makeStyle(seed, t)
	t = t or 0
	local s = ranges.style
	local st = {seed = seed}
	local group = pickWeightedU(s.hues, fixed(seed, 1))
	local hc = cont(seed, 2, t, group.h)
	st.palette = {
		h0 = lerpHue(hc, s.coolHue, cont(seed, 3, t, s.coolShift)),
		h1 = lerpHue(hc, s.warmHue, cont(seed, 4, t, s.warmShift)),
		s0 = cont(seed, 5, t, s.satDark),
		s1 = cont(seed, 6, t, s.satLight),
		v0 = cont(seed, 7, t, s.valDark),
		v1 = cont(seed, 8, t, s.valLight),
		n = intU(s.colours, fixed(seed, 9)),
	}
	st.outlineMode = pickU(s.outlineModes, fixed(seed, 10))
	st.shadow = cont(seed, 11, t, s.shadow)
	st.crease = intU(s.crease, fixed(seed, 12))
	st.gap = intU(s.gap, fixed(seed, 13))
	st.fringe = cont(seed, 14, t, s.fringe)
	st.texture = contChance(seed, 15, t, s.textureChance, s.texture)
	st.textureStep = intU(s.textureStep, fixed(seed, 16))
	st.edgeTips = contChance(seed, 17, t, s.edgeTipsChance, s.edgeTips)
	st.noise = cont(seed, 18, t, s.noise)
	st.contrast = cont(seed, 19, t, s.contrast)
	st.fold = cont(seed, 20, t, s.fold)
	st.toneMix = cont(seed, 21, t, s.toneMix)
	st.toneLight = cont(seed, 22, t, s.toneLight)
	st.bodyMix = cont(seed, 23, t, s.bodyMix)
	st.clumpSquash = cont(seed, 24, t, s.clumpSquash)
	st.grain = cont(seed, 25, t, s.grain)
	local spot = contChance(seed, 26, t, s.spotChance, s.spot)
	if spot > 0 then st.spot = spot end
	if fixed(seed, 27) < s.ornamentChance then
		local col = pickU(s.ornamentColours, fixed(seed, 28))
		st.ornament = {
			h = col[1], s = col[2], v = col[3],
			shape = pickU(s.ornamentShapes, fixed(seed, 29)),
			count = cont(seed, 30, t, s.ornamentCount),
		}
	end
	st.bark = {
		h = cont(seed, 31, t, s.barkHue),
		s = cont(seed, 32, t, s.barkSat),
		v = cont(seed, 33, t, s.barkVal),
	}
	return st
end

---------------------------------------------------------------- plant

-- largest scale that keeps this kind inside the tile
local function scaleCap(q, pr)
	local cap = 10
	if q.kind == "hedge" then
		cap = min(cap, 14 / (q.length[2] / 2 + q.radius[2]))
	elseif q.kind == "bramble" then
		cap = min(cap, 13 / (2.3 * q.stemLength[2]))
	elseif q.radius then
		cap = min(cap, pr.maxRadius / q.radius[2])
	end
	if q.leafLength then
		cap = min(cap, pr.maxLeaf / q.leafLength[2])
	end
	return cap
end

function variety.makePlant(st, seed, t)
	t = t or 0
	local pr = ranges.plant
	local base = byName[pickWeightedU(pr.kinds, fixed(seed, 101)).name]
	local q = copy(base)
	for _, f in ipairs(STYLE_FIELDS) do
		if st[f] ~= nil then q[f] = st[f] end
	end
	q.bark = st.bark

	-- size
	local s = min(cont(seed, 102, t, pr.scale), scaleCap(q, pr))
	local g = st.grain * cont(seed, 103, t, {0.85, 1.15})
	local cf = cont(seed, 104, t, pr.count)
	local area = s * s / (g * g)
	if q.radius then q.radius = scalePair(q.radius, s) end
	if q.length then q.length = scalePair(q.length, s) end
	if q.stemLength then q.stemLength = scalePair(q.stemLength, s) end
	if q.leafLength then q.leafLength = scalePair(q.leafLength, s) end
	if q.lift then q.lift = scalePair(q.lift, s) end
	if q.clumpRadius then q.clumpRadius = scalePair(q.clumpRadius, sqrt(s) * g, 1.3) end
	if q.leafWidth then q.leafWidth = scalePair(q.leafWidth, sqrt(s * g), 1.1) end
	if q.leafletLength then q.leafletLength = q.leafletLength * s end
	if q.leafletWidth then q.leafletWidth = max(1.1, q.leafletWidth * sqrt(g)) end

	-- counts (fractional, the generator grows the last part in smoothly)
	if q.clumps then q.clumps = scalePair(q.clumps, cf * area, 3) end
	if q.leaves then
		if q.kind == "leafy" then
			q.leaves = scalePair(q.leaves, cf * area, 8)
		else
			q.leaves = scalePair(q.leaves, cf, 4)
		end
	end
	if q.stems then q.stems = scalePair(q.stems, cf, 1) end
	if q.parts then q.parts = scalePair(q.parts, cf, 1) end

	-- proportions
	if q.squash and q.kind ~= "tiered" then
		q.squash = min(1.05, max(0.6, cont(seed, 105, t, pr.squash)))
	end
	if q.kind == "blob" then
		local sw = contChance(seed, 106, t, pr.stretchChance, {0, pr.stretch[2] - 1})
		q.stretch = 1 + sw
		q.radius = scalePair(q.radius, 1 / q.stretch)
	end
	if q.kind == "rosette" then
		q.droop = (q.droop or 1) * cont(seed, 107, t, {0.3, 1.8})
		q.innerShrink = cont(seed, 108, t, {0.0, 0.5})
	end
	if q.kind == "tiered" then
		q.taper = cont(seed, 109, t, {0.35, 0.8})
		q.tierHeight = cont(seed, 110, t, {0.3, 0.55})
	end
	if q.kind == "bramble" then
		q.fan = cont(seed, 111, t, {0.9, 1.7})
		q.jointLeaves = cont(seed, 112, t, {0.2, 0.8})
	end

	-- flowers or berries
	if st.ornament and fixed(seed, 113) < pr.ornamentChance then
		local o = copy(st.ornament)
		o.count = max(2, o.count * s)
		o.spacing = 3 + intU({0, 2}, fixed(seed, 114))
		q.ornament = o
	end

	-- grass at the base
	if pr.underKinds[q.kind] and fixed(seed, 115) < pr.underChance then
		local u = copy(byName.grass)
		local us = cont(seed, 116, t, {0.45, 0.75})
		u.leafLength = scalePair(u.leafLength, us)
		u.lift = scalePair(u.lift, us)
		u.leafWidth = scalePair(u.leafWidth, 0.8, 1.1)
		u.leaves = {6, 10}
		u.dep0 = 14
		u.baseOffset = 4
		u.baseSpread = 1.5 + 3 * s
		u.salt = 50
		q.under = u
	end
	return q
end

return variety
