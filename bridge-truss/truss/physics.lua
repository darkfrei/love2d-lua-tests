-- truss/physics.lua
-- core physics routines; mass-spring system with verlet integration
local Physics = {}

function Physics.refresh_masses(world)
	local cfg = world.config
	for _, n in ipairs(world.nodes) do
		n.mass = cfg.NODE_BASE_MASS
	end
	for _, bm in ipairs(world.beams) do
		if not bm.broken then
			local wt = (bm.type == "road" and cfg.ROAD_BEAM_WT) or cfg.BEAM_WT
			local half_mass = wt * bm.L0 * 0.5
			world.nodes[bm.n1].mass = world.nodes[bm.n1].mass + half_mass
			world.nodes[bm.n2].mass = world.nodes[bm.n2].mass + half_mass
		end
	end
end

local function apply_beam_forces(world, bm)
	local cfg = world.config
	local n1 = world.nodes[bm.n1]
	local n2 = world.nodes[bm.n2]
	local dx = n2.x - n1.x
	local dy = n2.y - n1.y
	local L = math.sqrt(dx*dx + dy*dy)
	if L < 1e-6 then return end

	local ux = dx / L
	local uy = dy / L

	local ea = (bm.type == "road" and cfg.ROAD_EA) or cfg.EA
	local k = ea / bm.L0
	local F_el = k * (L - bm.L0)
	bm.force = F_el

	local af = math.abs(F_el)
	if af > world.max_force then world.max_force = af end
	if af > world.peak_force then world.peak_force = af end

	n1.fx = n1.fx + F_el * ux
	n1.fy = n1.fy + F_el * uy
	n2.fx = n2.fx - F_el * ux
	n2.fy = n2.fy - F_el * uy

	local vx_r = n2.vx - n1.vx
	local vy_r = n2.vy - n1.vy
	local v_ax = vx_r * ux + vy_r * uy
	local v_lx = vx_r - v_ax * ux
	local v_ly = vy_r - v_ax * uy
	local v_lat = math.sqrt(v_lx*v_lx + v_ly*v_ly)
	local m_eff = (n1.mass + n2.mass) * 0.5

	local c_ax = 2.0 * math.sqrt(k * m_eff)
	local F_dax = cfg.ZETA_AXIAL * c_ax * v_ax
	n1.fx = n1.fx + F_dax * ux
	n1.fy = n1.fy + F_dax * uy
	n2.fx = n2.fx - F_dax * ux
	n2.fy = n2.fy - F_dax * uy

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

-- distribute external static loads
	for _, load in pairs(world.external_loads) do
		local bm = world.beams[load.beam_idx]
		if bm and not bm.broken then
			local n1 = world.nodes[bm.n1]
			local n2 = world.nodes[bm.n2]
			local t = math.max(0, math.min(1, load.t))
			local f = load.mass * cfg.G
			n1.fy = n1.fy + f * (1 - t)
			n2.fy = n2.fy + f * t
		end
	end

-- distribute dynamic contact forces from vehicles
	for _, cf in ipairs(world.contact_forces) do
		local bm = world.beams[cf.beam_idx]
		if bm and not bm.broken then
			local n1 = world.nodes[bm.n1]
			local n2 = world.nodes[bm.n2]
			local t = math.max(0, math.min(1, cf.t))
			n1.fx = n1.fx + cf.fx * (1 - t)
			n1.fy = n1.fy + cf.fy * (1 - t)
			n2.fx = n2.fx + cf.fx * t
			n2.fy = n2.fy + cf.fy * t
		end
	end

	for _, bm in ipairs(world.beams) do
		if not bm.broken then
			apply_beam_forces(world, bm)
		end
	end
end

function Physics.verlet_step(world, dt)
	local nodes = world.nodes
	for _, n in ipairs(nodes) do
		if not (n.pin_x and n.pin_y) then
			n.vx = n.vx + (n.fx / n.mass) * dt * 0.5
			n.vy = n.vy + (n.fy / n.mass) * dt * 0.5
		end
	end

	for _, n in ipairs(nodes) do
		if not n.pin_x then n.x = n.x + n.vx * dt end
		if not n.pin_y then n.y = n.y + n.vy * dt end
		if n.pin_x then n.x = n.rest_x; n.vx = 0 end
		if n.pin_y then n.y = n.rest_y; n.vy = 0 end
	end

	Physics.compute_forces(world)

	for _, n in ipairs(nodes) do
		if not (n.pin_x and n.pin_y) then
			n.vx = n.vx + (n.fx / n.mass) * dt * 0.5
			n.vy = n.vy + (n.fy / n.mass) * dt * 0.5
		end
		if n.pin_x then n.vx = 0 end
		if n.pin_y then n.vy = 0 end
	end
end

function Physics.check_failures(world)
	local broke = false
	for _, bm in ipairs(world.beams) do
		if not bm.broken then
			local max_f = (bm.type == "road" and world.config.ROAD_MAX_F) or world.config.MAX_F
			if math.abs(bm.force) > max_f then
				bm.broken = true
				broke = true
				if world.on_beam_break then
					world.on_beam_break(bm)
				end
			end
		end
	end
	if broke then
		Physics.refresh_masses(world)
	end
	return broke
end

return Physics