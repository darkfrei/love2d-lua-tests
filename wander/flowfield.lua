local Noise = require("noise")

local FlowField = {}

local twoPi = math.pi * 2

local function atan2(y, x)
	if math.atan2 then
		return math.atan2(y, x)
	end

	if x > 0 then
		return math.atan(y / x)
	elseif x < 0 and y >= 0 then
		return math.atan(y / x) + math.pi
	elseif x < 0 and y < 0 then
		return math.atan(y / x) - math.pi
	elseif x == 0 and y > 0 then
		return math.pi * 0.5
	elseif x == 0 and y < 0 then
		return -math.pi * 0.5
	end

	return 0
end

function FlowField.new(settings, seed)
	return {
		seed = seed or os.time(),
		time = 0,
		settings = settings,
		noise = Noise.new(seed),
	}
end

function FlowField.update(field, dt)
	field.time = field.time + dt
end

local function sampleChannel(field, x, y, timeValue, phaseX, phaseY, phaseTime)
	local settings = field.settings
	local worldWidth = settings.world.width
	local worldHeight = settings.world.height
	local noiseSettings = settings.noise

	local ax = twoPi * (x / worldWidth)
	local ay = twoPi * (y / worldHeight)

	local cx = math.cos(ax)
	local sx = math.sin(ax)
	local cy = math.cos(ay)
	local sy = math.sin(ay)

	return Noise.fbm3(
		field.noise,
		(cx * 1.8 + sy * 0.8 + phaseX) * noiseSettings.domainScale,
		(sx * 1.8 + cy * 0.8 + phaseY) * noiseSettings.domainScale,
		timeValue + phaseTime,
		noiseSettings.octaves,
		noiseSettings.persistence,
		noiseSettings.lacunarity
	)
end

function FlowField.sampleVector(field, x, y, timeOverride)
	local settings = field.settings
	local timeValue = (timeOverride or field.time) * settings.noise.timeScale

	local vx = sampleChannel(field, x, y, timeValue, 11.7, 3.1, 0.0)
	local vy = sampleChannel(field, x, y, timeValue, 29.3, 17.4, 41.7)

	local length = math.sqrt(vx * vx + vy * vy)
	if length < 1e-7 then
		return 1, 0, 0
	end

	vx = vx / length
	vy = vy / length

	return vx, vy, atan2(vy, vx)
end

function FlowField.sampleAngle(field, x, y, timeOverride)
	local _, _, angle = FlowField.sampleVector(field, x, y, timeOverride)
	return angle
end

return FlowField