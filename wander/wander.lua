local Wander = {}

local twoPi = math.pi * 2

local function normalize(x, y)
	local length = math.sqrt(x * x + y * y)
	if length < 1e-7 then
		return 1, 0
	end
	return x / length, y / length
end

local function shortestAngleDelta(fromAngle, toAngle)
	local delta = (toAngle - fromAngle) % twoPi
	if delta > math.pi then
		delta = delta - twoPi
	end
	return delta
end

function Wander.new(settings, seed)
	local rng = love.math.newRandomGenerator(seed or os.time())

	return {
		rng = rng,
		wanderAngle = rng:random() * twoPi,
	}
end

function Wander.reset(state, seed)
	local rng = love.math.newRandomGenerator(seed or os.time())
	state.rng = rng
	state.wanderAngle = rng:random() * twoPi
end

function Wander.update(state, vehicle, flowAngle, dt, settings)
	local jitter = (state.rng:random() * 2 - 1) * settings.wander.jitter * dt
	local angleDelta = shortestAngleDelta(state.wanderAngle, flowAngle)

	state.wanderAngle = (state.wanderAngle + jitter + angleDelta * settings.wander.noisePull * dt) % twoPi

	local headingX, headingY = normalize(vehicle.vx, vehicle.vy)
	local centerOffsetX = headingX * settings.wander.distance
	local centerOffsetY = headingY * settings.wander.distance

	local targetOffsetX = centerOffsetX + math.cos(state.wanderAngle) * settings.wander.radius
	local targetOffsetY = centerOffsetY + math.sin(state.wanderAngle) * settings.wander.radius

	return {
		centerOffsetX = centerOffsetX,
		centerOffsetY = centerOffsetY,
		targetOffsetX = targetOffsetX,
		targetOffsetY = targetOffsetY,
		wanderAngle = state.wanderAngle,
	}
end

return Wander