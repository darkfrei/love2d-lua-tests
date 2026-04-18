-- vehicles/init.lua
-- library entry point for vehicle simulation modules
local Car = require("vehicles.car")
return {
	car_new = function(cfg) return Car.new(cfg) end,
	car_step = function(car, dt, world) car:step(dt, world) end,
	car_draw = function(car, world) car:draw(world) end,
	car_reset = function(car) car:reset() end,
}