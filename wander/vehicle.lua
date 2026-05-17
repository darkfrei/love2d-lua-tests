local World = require("world")

local Vehicle = {}

function Vehicle.new(settings)
	return {
		x = settings.world.width * 0.5,
		y = settings.world.height * 0.5,
		vx = settings.vehicle.maxSpeed,
		vy = 0,
	}
end

function Vehicle.reset(vehicle, x, y, headingAngle, settings)
	local speed = settings.vehicle.maxSpeed

	vehicle.x = x
	vehicle.y = y
	vehicle.vx = math.cos(headingAngle) * speed
	vehicle.vy = math.sin(headingAngle) * speed
end

function Vehicle.integrate(vehicle, ax, ay, dt, settings)
	vehicle.vx = vehicle.vx + ax * dt
	vehicle.vy = vehicle.vy + ay * dt

	local speed = math.sqrt(vehicle.vx * vehicle.vx + vehicle.vy * vehicle.vy)
	local maxSpeed = settings.vehicle.maxSpeed

	if speed > maxSpeed then
		local scale = maxSpeed / speed
		vehicle.vx = vehicle.vx * scale
		vehicle.vy = vehicle.vy * scale
	end

	vehicle.x = World.wrap(vehicle.x + vehicle.vx * dt, settings.world.width)
	vehicle.y = World.wrap(vehicle.y + vehicle.vy * dt, settings.world.height)
end

function Vehicle.speed(vehicle)
	return math.sqrt(vehicle.vx * vehicle.vx + vehicle.vy * vehicle.vy)
end

return Vehicle