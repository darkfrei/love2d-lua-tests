-- truss/broken-truss.lua
-- optional module for visualizing broken beams as hinged fragments
-- each broken beam is replaced by two rods attached to original nodes
-- these rods do not affect main physics; they are purely visual secondary motion
--
-- mental model:
-- beam breaks -> spring disappears -> two rigid sticks remain
-- each stick rotates like a pendulum around its node

local BrokenTruss = {}

-- enable broken beam visualization; installs callback into world
function BrokenTruss.enable(world)
	world.hinged_fragments = {}

	-- called by physics when a beam breaks
	world.on_beam_break = function(beam)
		local n1 = world.nodes[beam.n1]
		local n2 = world.nodes[beam.n2]
		local L0 = beam.L0

		-- ignore very small beams; avoids unstable fast rotations
		if L0 < 2 then return end

		-- initial direction of the beam; used as starting angle
		local dx = n2.x - n1.x
		local dy = n2.y - n1.y
		local angle = math.atan2(dy, dx)

		-- estimate angular velocity from relative motion at break moment
		local ux = dx / L0
		local uy = dy / L0
		local dvx = n2.vx - n1.vx
		local dvy = n2.vy - n1.vy

		-- perpendicular component gives rotation tendency
		local v_perp = dvx * (-uy) + dvy * ux
		local ang_vel = v_perp / L0

		-- fragment geometry
		local length = L0 * 0.5

		-- mass derived from beam linear density (BEAM_WT)
		-- ensures broken fragments preserve physical weight
		local mass = length * world.config.BEAM_WT

		-- first fragment; attached to node 1
		table.insert(world.hinged_fragments, {
			node_idx = beam.n1,
			length = length,
			angle = angle,
			ang_vel = ang_vel,
			original_L0 = L0,
			mass = mass,
		})

		-- second fragment; attached to node 2 and flipped
		table.insert(world.hinged_fragments, {
			node_idx = beam.n2,
			length = length,
			angle = angle + math.pi,
			ang_vel = ang_vel,
			original_L0 = L0,
			mass = mass,
		})
	end
end

-- update all fragments; pendulum-like motion with mass-aware gravity and consistent damping
function BrokenTruss.step(world, dt)
	if not world.hinged_fragments or #world.hinged_fragments == 0 then return end
	local cfg = world.config

--	local zeta = cfg.HINGE_ZETA or 0.10
	local zeta = cfg.HINGE_DAMPING or 0.10

	for i = #world.hinged_fragments, 1, -1 do
		local f = world.hinged_fragments[i]
		local n = world.nodes[f.node_idx]

		if not n then
			table.remove(world.hinged_fragments, i)
		else
			-- gravity torque (mass-aware rigid rod approximation)
			local ang_acc = (0.05 * cfg.G * math.cos(f.angle)) / math.max(f.original_L0, 1)

			-- inertia effect: heavier fragments rotate slower
			ang_acc = ang_acc / math.max(f.mass, 1e-6)

			f.ang_vel = f.ang_vel + ang_acc * dt

			-- damping (consistent with rest of physics system)
			local w_damp = 2.0 * zeta * math.sqrt(cfg.G / math.max(f.original_L0, 1))
			f.ang_vel = f.ang_vel - w_damp * f.ang_vel * dt

			-- update angle
			f.angle = f.angle + f.ang_vel * dt

			-- linear gravity contribution from fragment mass
			-- makes broken pieces actually "pull" the structure down
			n.fy = n.fy + f.mass * cfg.G
		end
	end
end

-- remove all fragments; useful on reset or rebuild
function BrokenTruss.clear(world)
	if world.hinged_fragments then
		world.hinged_fragments = {}
	end
end

return BrokenTruss