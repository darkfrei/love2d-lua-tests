-- truss/physics.lua
-- core physics routines; this module implements a simple mass-spring system for beams
-- each node is a point mass; each beam behaves like a spring with damping
--
-- public api:
-- physics.refresh_masses(world) recompute node masses from beam weights
-- physics.compute_forces(world) compute all forces acting on nodes
-- physics.verlet_step(world, dt) integrate motion using velocity verlet
-- physics.check_failures(world) break beams that exceed strength limit

local Physics = {}

-- distribute beam self-weight evenly to endpoint nodes; each beam contributes half its weight to each node
-- this keeps mass consistent with current structure; must be called after adding or removing beams
function Physics.refresh_masses(world)
	local cfg = world.config
	for _, n in ipairs(world.nodes) do
		n.mass = cfg.NODE_BASE_MASS -- start from base mass of node itself
	end
	for _, bm in ipairs(world.beams) do
		if not bm.broken then
			local half_mass = cfg.BEAM_WT * bm.L0 * 0.5 -- beam mass proportional to rest length
			world.nodes[bm.n1].mass = world.nodes[bm.n1].mass + half_mass
			world.nodes[bm.n2].mass = world.nodes[bm.n2].mass + half_mass
		end
	end
end

-- compute and apply forces for one beam; this is the core spring + damping model
-- result is accumulated into node force buffers n.fx / n.fy
local function apply_beam_forces(world, bm)
	local cfg = world.config
	local n1 = world.nodes[bm.n1]
	local n2 = world.nodes[bm.n2]

	-- vector from n1 to n2
	local dx = n2.x - n1.x
	local dy = n2.y - n1.y
	local L = math.sqrt(dx*dx + dy*dy) -- current length of beam

	-- skip degenerate case to avoid division by zero
	if L < 1e-6 then return end

	-- unit direction vector along beam
	local ux = dx / L
	local uy = dy / L

	-- elastic spring force; hooke law f = k * (L - L0)
	-- if L > L0 beam is stretched; if L < L0 beam is compressed
	local k = cfg.EA / bm.L0 -- stiffness scales with material stiffness EA and inversely with length
	local F_el = k * (L - bm.L0)
	bm.force = F_el -- store for visualization and failure checks

	-- track max forces for UI / debugging
	local af = math.abs(F_el)
	if af > world.max_force then world.max_force = af end
	if af > world.peak_force then world.peak_force = af end

	-- apply equal and opposite forces to nodes
	n1.fx = n1.fx + F_el * ux
	n1.fy = n1.fy + F_el * uy
	n2.fx = n2.fx - F_el * ux
	n2.fy = n2.fy - F_el * uy

	-- relative velocity between nodes
	local vx_r = n2.vx - n1.vx
	local vy_r = n2.vy - n1.vy

	-- project velocity onto beam axis; this is stretching/compression speed
	local v_ax = vx_r * ux + vy_r * uy

	-- subtract axial component to get lateral motion; this is bending/swinging
	local v_lx = vx_r - v_ax * ux
	local v_ly = vy_r - v_ax * uy
	local v_lat = math.sqrt(v_lx*v_lx + v_ly*v_ly)

	-- effective mass of beam pair; used in damping formulas
	local m_eff = (n1.mass + n2.mass) * 0.5

	-- axial damping; removes oscillations along beam direction
	-- critical damping c = 2 * sqrt(k * m); we scale it by ZETA_AXIAL
	local c_ax = 2.0 * math.sqrt(k * m_eff)
	local F_dax = cfg.ZETA_AXIAL * c_ax * v_ax

	n1.fx = n1.fx + F_dax * ux
	n1.fy = n1.fy + F_dax * uy
	n2.fx = n2.fx - F_dax * ux
	n2.fy = n2.fy - F_dax * uy

	-- lateral damping; stabilizes swinging like a pendulum
	-- frequency approx sqrt(g / L); used to estimate critical damping
	if v_lat > 1e-9 then
		local w_pend = math.sqrt(cfg.G / math.max(L, 1))
		local c_ang = 2.0 * m_eff * w_pend
		local F_dlat = cfg.ZETA_ANGULAR * c_ang * v_lat

		-- direction of lateral motion
		local lux = v_lx / v_lat
		local luy = v_ly / v_lat

		n1.fx = n1.fx + F_dlat * lux
		n1.fy = n1.fy + F_dlat * luy
		n2.fx = n2.fx - F_dlat * lux
		n2.fy = n2.fy - F_dlat * luy
	end
end

-- compute all forces in the system; result is stored in each node as fx fy
function Physics.compute_forces(world)
	local cfg = world.config
	local nodes = world.nodes

	-- reset accumulators before summing forces
	for _, n in ipairs(nodes) do
		n.fx, n.fy = 0, 0
	end

	-- gravity acts on all masses; positive G means downward force
	for _, n in ipairs(nodes) do
		n.fy = n.fy + n.mass * cfg.G
		if n.load then
			n.fy = n.fy + n.load * cfg.G -- additional user-defined load
		end
	end

	-- add internal forces from all beams
	for _, bm in ipairs(world.beams) do
		if not bm.broken then
			apply_beam_forces(world, bm)
		end
	end
end

-- integrate motion using velocity verlet; stable and commonly used in physics simulations
-- step is split into kick drift kick to improve energy behavior
function Physics.verlet_step(world, dt)
	local nodes = world.nodes

	-- first half update of velocity using current forces
	for _, n in ipairs(nodes) do
		if not (n.pin_x and n.pin_y) then
			n.vx = n.vx + (n.fx / n.mass) * dt * 0.5
			n.vy = n.vy + (n.fy / n.mass) * dt * 0.5
		end
	end

	-- update positions; pinned axes are constrained to rest position
	for _, n in ipairs(nodes) do
		if not n.pin_x then n.x = n.x + n.vx * dt end
		if not n.pin_y then n.y = n.y + n.vy * dt end
		if n.pin_x then n.x = n.rest_x; n.vx = 0 end
		if n.pin_y then n.y = n.rest_y; n.vy = 0 end
	end

	-- recompute forces at new positions; needed for second half step
	Physics.compute_forces(world)

	-- second half update of velocity
	for _, n in ipairs(nodes) do
		if not (n.pin_x and n.pin_y) then
			n.vx = n.vx + (n.fx / n.mass) * dt * 0.5
			n.vy = n.vy + (n.fy / n.mass) * dt * 0.5
		end
		if n.pin_x then n.vx = 0 end
		if n.pin_y then n.vy = 0 end
	end
end

-- check if any beam exceeds strength limit; if so mark as broken
-- broken beams no longer contribute forces; masses are recomputed after break
function Physics.check_failures(world)
	local broke = false
	for _, bm in ipairs(world.beams) do
		if not bm.broken and math.abs(bm.force) > world.config.MAX_F then
			bm.broken = true
			broke = true
			if world.on_beam_break then
				world.on_beam_break(bm) -- optional callback for effects or sound
			end
		end
	end
	
	if broke then -- commented: 
-- do not recompute masses after break
-- broken beams still contribute mass
		-- Physics.refresh_masses(world)

-- do not recompute masses here
-- broken beams are visually simulated as separate pieces
-- removing their mass would cause mismatch between physics and rendering

	end
	return broke
end

return Physics