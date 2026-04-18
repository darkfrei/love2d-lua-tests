-- vehicles/car.lua
-- independent 2d vehicle simulation with suspension and ground contact
-- chassis is a rigid body; wheels are contact points with spring-damper suspension
-- applies dynamic contact forces to the truss world; lifts off if normal force drops

-- standard default parameters
local DEFAULTS = {
	mass            = 0.8,   -- chassis mass (kg)
	width           = 90,     -- chassis width (px)
	height          = 35,     -- chassis height (px)
	susp_rest       = 15,     -- suspension rest length (px)
	susp_k          = 100,   -- suspension spring stiffness
	susp_c          = 0.1,    -- normalized damping ratio (0 = none, 1 = critical)
	engine_force    = 50,     -- max forward force
	reverse_force   = 50,     -- max reverse force
	brake_force     = 0.1,    -- max braking force
	friction        = 0.1,    -- tire-road friction coefficient
	wheel_radius    = 12,     -- wheel radius (px)
	wheel_x_ratio   = 0.45,   -- wheel horizontal offset from chassis center (fraction of width)
	wheel_y_ratio   = 0.5,    -- wheel vertical offset from chassis center (fraction of height)
	slip_damping    = 50,     -- slip velocity damping coefficient for passive friction
	ang_damping     = 0.99,   -- angular velocity damping per frame
	grip_override   = 20,      -- max drive/brake force multiplier relative to grip limit
}

local Car = {}
Car.__index = Car

function Car.new(cfg)
	cfg = cfg or {}
	local self = setmetatable({}, Car)
	
	local m = cfg.mass   or DEFAULTS.mass
	local w = cfg.width  or DEFAULTS.width
	local h = cfg.height or DEFAULTS.height
	
	self.chassis = {
		x = 0, y = 0, vx = 0, vy = 0, angle = 0, ang_vel = 0,
		mass          = m,
		width         = w,
		height        = h,
		susp_rest     = cfg.susp_rest     or DEFAULTS.susp_rest,
		susp_k        = cfg.susp_k        or DEFAULTS.susp_k,
		susp_c        = cfg.susp_c        or DEFAULTS.susp_c,
		engine_force  = cfg.engine_force  or DEFAULTS.engine_force,
		reverse_force = cfg.reverse_force or DEFAULTS.reverse_force,
		brake_force   = cfg.brake_force   or DEFAULTS.brake_force,
		friction      = cfg.friction      or DEFAULTS.friction,
		wheel_radius  = cfg.wheel_radius  or DEFAULTS.wheel_radius,
		wheel_x_ratio = cfg.wheel_x_ratio or DEFAULTS.wheel_x_ratio,
		wheel_y_ratio = cfg.wheel_y_ratio or DEFAULTS.wheel_y_ratio,
		slip_damping  = cfg.slip_damping  or DEFAULTS.slip_damping,
		ang_damping   = cfg.ang_damping   or DEFAULTS.ang_damping,
		grip_override = cfg.grip_override or DEFAULTS.grip_override,
		inv_mass      = 1 / m,
		inv_inertia   = 12 / (m * (w*w + h*h)),
	}
	
	-- wheel hubs placed at configurable corners of chassis
	local hw = w * self.chassis.wheel_x_ratio
	local hh = h * self.chassis.wheel_y_ratio
	self.wheels = {
		{ dx = -hw, dy = hh, radius = self.chassis.wheel_radius, grounded = false, contact_fx = 0, contact_fy = 0 },
		{ dx =  hw, dy = hh, radius = self.chassis.wheel_radius, grounded = false, contact_fx = 0, contact_fy = 0 },
	}
	
	self.input = { throttle = 0, reverse = 0, brake = 0 }
	return self
end

function Car:reset()
	self.chassis.vx, self.chassis.vy = 0, 0
	self.chassis.ang_vel = 0
	self.chassis.angle   = 0
	self.input.throttle  = 0
	self.input.reverse   = 0
	self.input.brake     = 0
end

-- returns the road beam whose x-span contains wx; picks the highest surface when beams overlap
local function find_road_under_x(world, wx)
	local best    = nil
	local best_sy = 1e9
	for i, bm in ipairs(world.beams) do
		if bm.type == "road" and not bm.broken then
			local n1   = world.nodes[bm.n1]
			local n2   = world.nodes[bm.n2]
			local dx_r = n2.x - n1.x
			if math.abs(dx_r) > 1e-6
				and wx >= math.min(n1.x, n2.x)
				and wx <= math.max(n1.x, n2.x)
			then
				local t  = (wx - n1.x) / dx_r
				local sy = n1.y + (n2.y - n1.y) * t
				if sy < best_sy then
					best_sy = sy
					best    = { idx = i, n1 = n1, n2 = n2, t = t }
				end
			end
		end
	end
	return best
end

function Car:step(dt, world)
	local c = self.chassis
	local g = world.config.G
	dt = math.min(dt, world.config.DT_MAX)

	world:clear_contact_forces()
	for _, w in ipairs(self.wheels) do
		w.grounded   = false
		w.contact_fx = 0
		w.contact_fy = 0
	end

	local cos_a = math.cos(c.angle)
	local sin_a = math.sin(c.angle)

	-- gravity applied once to the chassis
	c.vy = c.vy + g * dt

	-- critical damping coefficient per wheel (each wheel carries half the chassis mass)
	local c_crit = 2.0 * math.sqrt(c.susp_k * c.mass * 0.5)
	local damping = c.susp_c * c_crit

	for _, w in ipairs(self.wheels) do
		-- wheel center in local space = (w.dx, w.dy + susp_rest); rotate into world
		local lx = w.dx
		local ly = w.dy + c.susp_rest
		local wx = c.x + lx * cos_a - ly * sin_a
		local wy = c.y + lx * sin_a + ly * cos_a

		-- offset from chassis center to wheel center (world space)
		local rx_w = wx - c.x
		local ry_w = wy - c.y

		local road = find_road_under_x(world, wx)
		if road then
			local t    = road.t
			local dx_r = road.n2.x - road.n1.x
			local dy_r = road.n2.y - road.n1.y
			local len_r = math.sqrt(dx_r*dx_r + dy_r*dy_r)
			local sy   = road.n1.y + dy_r * t

			-- road surface normal pointing away from the road (upward in screen space)
			local nx =  dy_r / len_r
			local ny = -dx_r / len_r
			if ny > 0 then nx, ny = -nx, -ny end   -- guarantee upward-facing normal

			-- penetration depth
			local pen_v = (wy + w.radius) - sy
			if pen_v > 0 then
				local pen = pen_v * (-ny)   -- -ny > 0 for any upward normal
				if pen > 0 then
					w.grounded = true

					-- rigid body velocity at wheel center: v_p = v_cm + ω × r (2D, y-down)
					local vx_w = c.vx - c.ang_vel * ry_w
					local vy_w = c.vy + c.ang_vel * rx_w

					-- road velocity at contact
					local rv_x = (road.n1.vx or 0) + ((road.n2.vx or 0) - (road.n1.vx or 0)) * t
					local rv_y = road.n1.vy         + (road.n2.vy         - road.n1.vy)         * t

					-- relative velocity components
					local rel_vx = vx_w - rv_x
					local rel_vy = vy_w - rv_y
					local v_n = rel_vx * nx + rel_vy * ny   -- positive = separating
					local tx  = dx_r / len_r
					local ty  = dy_r / len_r
					local v_t = rel_vx * tx + rel_vy * ty   -- tangential slip velocity

					-- implicit euler spring-damper (unconditionally stable)
					local beta   = c.susp_k * dt + damping
					local f_norm = (c.susp_k * pen - beta * v_n) / (1.0 + beta * c.inv_mass * dt)
					f_norm = math.max(0, f_norm)   -- wheel can push but never pull

					-- friction and drive
					local f_grip = f_norm * c.friction
					
					-- passive friction (damping)
					local f_passive = -math.min(math.abs(v_t) * c.slip_damping, f_grip) * (v_t >= 0 and 1 or -1)
					
					-- active drive
					local f_active = 0
					if self.input.throttle > 0 then f_active = f_active + c.engine_force * self.input.throttle end
					if self.input.reverse > 0 then f_active = f_active - c.reverse_force * self.input.reverse end
					if self.input.brake > 0 then f_active = f_active - c.brake_force * self.input.brake end
					
					local f_fric = f_passive + f_active
					
					-- clamp to grip limits (with override)
					local limit = f_grip * c.grip_override
					f_fric = math.max(-limit, math.min(limit, f_fric))

					-- total contact force
					local cfx = f_norm * nx + f_fric * tx
					local cfy = f_norm * ny + f_fric * ty
					w.contact_fx = cfx
					w.contact_fy = cfy

					-- moment arm to contact point
					local rx_c = rx_w - nx * w.radius
					local ry_c = ry_w - ny * w.radius
					local tau = rx_c * cfy - ry_c * cfx

					c.vx      = c.vx      + cfx * c.inv_mass    * dt
					c.vy      = c.vy      + cfy * c.inv_mass    * dt
					c.ang_vel = c.ang_vel + tau * c.inv_inertia * dt

					-- reaction force on truss
					world:apply_contact_force(road.idx, t, -cfx, -cfy)
				end
			end
		end
	end

	c.x       = c.x       + c.vx      * dt
	c.y       = c.y       + c.vy      * dt
	c.angle   = c.angle   + c.ang_vel * dt
	c.ang_vel = c.ang_vel * c.ang_damping
end

function Car:draw(world)
	local c     = self.chassis
	local cos_a = math.cos(c.angle)
	local sin_a = math.sin(c.angle)
	local hw    = c.width  * 0.5
	local hh    = c.height * 0.5

	-- chassis corners
	local x1 = c.x - hw*cos_a + hh*sin_a;  local y1 = c.y - hw*sin_a - hh*cos_a
	local x2 = c.x + hw*cos_a + hh*sin_a;  local y2 = c.y + hw*sin_a - hh*cos_a
	local x3 = c.x + hw*cos_a - hh*sin_a;  local y3 = c.y + hw*sin_a + hh*cos_a
	local x4 = c.x - hw*cos_a - hh*sin_a;  local y4 = c.y - hw*sin_a + hh*cos_a

	love.graphics.setColor(0.9, 0.3, 0.2)
	love.graphics.polygon("fill", x1, y1, x2, y2, x3, y3, x4, y4)

	for _, w in ipairs(self.wheels) do
		-- wheel center: suspension hangs in chassis-local direction
		local lx = w.dx
		local ly = w.dy + c.susp_rest
		local wx = c.x + lx * cos_a - ly * sin_a
		local wy = c.y + lx * sin_a + ly * cos_a
		
		love.graphics.setColor(0.2, 0.8, 0.25)
		love.graphics.circle("fill", wx, wy, w.radius)
		love.graphics.setColor(0.6, 0.6, 0.7)
		love.graphics.setLineWidth(2)
		love.graphics.circle("line", wx, wy, w.radius)
		love.graphics.setLineWidth(1)
	end
end

return Car