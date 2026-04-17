-- truss/physics.lua
-- Core physics routines. All functions receive a World as first argument.
--
-- Public API:
-- Physics.refresh_masses(world) redistribute beam self-weight to nodes
-- Physics.compute_forces(world) accumulate forces into node.fx / node.fy
-- Physics.verlet_step(world, dt) one Velocity Verlet sub-step
-- Physics.check_failures(world) break beams that exceed MAX_F

local Physics = {}

-- Distribute beam self-weight evenly to endpoint nodes.
-- Must be called after any topology change (add / remove node or beam).
function Physics.refresh_masses(world)
	local cfg = world.config
	for _, n in ipairs(world.nodes) do
		n.mass = cfg.NODE_BASE_MASS
	end
	for _, bm in ipairs(world.beams) do
		if not bm.broken then
			local half_mass = cfg.BEAM_WT * bm.L0 * 0.5
			world.nodes[bm.n1].mass = world.nodes[bm.n1].mass + half_mass
			world.nodes[bm.n2].mass = world.nodes[bm.n2].mass + half_mass
		end
	end
end

-- Compute and apply forces for one beam.
-- Separated into its own function to keep compute_forces readable.
local function apply_beam_forces(world, bm)
	local cfg = world.config
	local n1 = world.nodes[bm.n1]
	local n2 = world.nodes[bm.n2]

	local dx = n2.x - n1.x
	local dy = n2.y - n1.y
	local L = math.sqrt(dx*dx + dy*dy)

	-- skip degenerate (zero-length) beams
	if L < 1e-6 then return end

	local ux = dx / L
	local uy = dy / L

	-- 1. Elastic spring force: F = k * (L - L0)
	local k = cfg.EA / bm.L0
	local F_el = k * (L - bm.L0)
	bm.force = F_el

	local af = math.abs(F_el)
	if af > world.max_force then world.max_force = af end
	if af > world.peak_force then world.peak_force = af end

	n1.fx = n1.fx + F_el * ux
	n1.fy = n1.fy + F_el * uy
	n2.fx = n2.fx - F_el * ux
	n2.fy = n2.fy - F_el * uy

	-- Split relative velocity into axial and lateral components
	local vx_r = n2.vx - n1.vx
	local vy_r = n2.vy - n1.vy
	local v_ax = vx_r * ux + vy_r * uy -- scalar, along beam axis
	local v_lx = vx_r - v_ax * ux -- lateral vector component x
	local v_ly = vy_r - v_ax * uy -- lateral vector component y
	local v_lat = math.sqrt(v_lx*v_lx + v_ly*v_ly)

	local m_eff = (n1.mass + n2.mass) * 0.5

	-- 2. Axial damping
	-- c_crit = 2 * sqrt(k * m_eff)
	local c_ax = 2.0 * math.sqrt(k * m_eff)
	local F_dax = cfg.ZETA_AXIAL * c_ax * v_ax
	n1.fx = n1.fx + F_dax * ux
	n1.fy = n1.fy + F_dax * uy
	n2.fx = n2.fx - F_dax * ux
	n2.fy = n2.fy - F_dax * uy

	-- 3. Lateral (angular / pendulum) damping
	-- c_crit = 2 * m_eff * sqrt(G / L)
	if v_lat > 1e-9 then
		local w_pend = math.sqrt(cfg.G / math.max(L, 1))
		local c_ang = 2.0 * m_eff * w_pend
		local F_dlat = cfg.ZETA_ANGULAR * c_ang * v_lat
		local lux = v_lx / v_lat
		local luy = v_ly / v_lat
		n1.fx = n1.fx + F_dlat * lux
		n1.fy = n1.fy + F_dlat * luy
		n2.fx = n2.fx - F_dlat * lux
		n2.fy = n2.fy - F_dlat * luy
	end
end

-- Zero force accumulators, then accumulate gravity, loads, and beam forces.
function Physics.compute_forces(world)
	local cfg = world.config
	local nodes = world.nodes

	for _, n in ipairs(nodes) do
		n.fx, n.fy = 0, 0
	end

	for _, n in ipairs(nodes) do
		n.fy = n.fy + n.mass * cfg.G
		if n.load then
			n.fy = n.fy + n.load * cfg.G
		end
	end

	for _, bm in ipairs(world.beams) do
		if not bm.broken then
			apply_beam_forces(world, bm)
		end
	end
end

-- Advance positions and velocities by one Velocity Verlet sub-step.
-- Pinned DOFs are held at rest position after each drift.
function Physics.verlet_step(world, dt)
	local nodes = world.nodes

	-- Half-kick: v += a * (dt/2)
	for _, n in ipairs(nodes) do
		if not (n.pin_x and n.pin_y) then
			n.vx = n.vx + (n.fx / n.mass) * dt * 0.5
			n.vy = n.vy + (n.fy / n.mass) * dt * 0.5
		end
	end

	-- Drift: x += v * dt, then enforce pin constraints
	for _, n in ipairs(nodes) do
		if not n.pin_x then n.x = n.x + n.vx * dt end
		if not n.pin_y then n.y = n.y + n.vy * dt end
		if n.pin_x then n.x = n.rest_x; n.vx = 0 end
		if n.pin_y then n.y = n.rest_y; n.vy = 0 end
	end

	-- Recompute forces at new positions
	Physics.compute_forces(world)

	-- Second half-kick
	for _, n in ipairs(nodes) do
		if not (n.pin_x and n.pin_y) then
			n.vx = n.vx + (n.fx / n.mass) * dt * 0.5
			n.vy = n.vy + (n.fy / n.mass) * dt * 0.5
		end
		if n.pin_x then n.vx = 0 end
		if n.pin_y then n.vy = 0 end
	end
end

-- Break any beam whose |force| exceeds MAX_F.
-- Fires world.on_beam_break(beam) callback if set.
-- Returns true if at least one beam broke.
function Physics.check_failures(world)
	local broke = false
	for _, bm in ipairs(world.beams) do
		if not bm.broken and math.abs(bm.force) > world.config.MAX_F then
			bm.broken = true
			broke = true
			if world.on_beam_break then
				world.on_beam_break(bm)
			end
		end
	end
	if broke then
		Physics.refresh_masses(world)
	end
	return broke
end

return Physics
