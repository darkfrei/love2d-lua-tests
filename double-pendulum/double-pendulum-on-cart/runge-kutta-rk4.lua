	-- Runge-Kutta 4 Lua implementation
	-- (c) darkfrei 2021
	--
	--Reference: http://gafferongames.com/game-physics/integration-basics/
	--Special thanks to Glenn Fiedler

local RK4 = {}

function RK4.evaluate (state, dt, d)
	state.x=state.x + d.dx*dt
	state.v=state.v + d.dv*dt
	return {dx=state.v, dv=state.a}
end

function RK4.integrate (x, v, acc, dt) -- old position and velocity; new acceleration, dt between them
	local state = {x=x,v=v, a=acc}
	local derivative = {dx = 0,	dv = 0}
	local a = RK4.evaluate (state, 0, derivative)
	local b = RK4.evaluate (state, 0.5*dt, a)
	local c = RK4.evaluate (state, 0.5*dt, b)
	local d = RK4.evaluate (state, dt, c)
	local dxdt = (a.dx+2*b.dx+2*c.dx+d.dx)/6
	local dvdt = (a.dv+2*b.dv+2*c.dv+d.dv)/6
	
	return state.x + dxdt*dt, state.v + dvdt*dt
end

return RK4
