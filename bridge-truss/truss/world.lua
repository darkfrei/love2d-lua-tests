-- truss/world.lua
-- world is the top-level simulation container; it stores nodes beams and runs the physics step
local Node = require("truss.node")
local Beam = require("truss.beam")
local Physics = require("truss.physics")
local Config = require("truss.config")
local World = {}
World.__index = World

function World.new(config)
	local self = setmetatable({}, World)
	self.config = {}
	for k, v in pairs(Config) do self.config[k] = v end
	if config then
		for k, v in pairs(config) do self.config[k] = v end
	end

	self.nodes = {}
	self.beams = {}
	self.external_loads = {}
	self.contact_forces = {} -- stores dynamic contact forces from external agents

	self.max_force = 0
	self.peak_force = 0
	self.on_beam_break = nil

	return self
end

function World:add_node(x, y, opts)
	local node = Node.new(x, y, opts)
	table.insert(self.nodes, node)
	Physics.refresh_masses(self)
	return #self.nodes
end

function World:remove_node(idx)
	for j = #self.beams, 1, -1 do
		local bm = self.beams[j]
		if bm.n1 == idx or bm.n2 == idx then
			table.remove(self.beams, j)
		end
	end
	table.remove(self.nodes, idx)
	for _, bm in ipairs(self.beams) do
		if bm.n1 > idx then bm.n1 = bm.n1 - 1 end
		if bm.n2 > idx then bm.n2 = bm.n2 - 1 end
	end
	Physics.refresh_masses(self)
end

function World:add_beam(a, b)
	for _, bm in ipairs(self.beams) do
		if (bm.n1 == a and bm.n2 == b) or (bm.n1 == b and bm.n2 == a) then
			return nil
		end
	end
	self.beams[#self.beams + 1] = Beam.new(self.nodes, a, b, "truss")
	Physics.refresh_masses(self)
	return #self.beams
end

function World:add_road(a, b)
	for _, bm in ipairs(self.beams) do
		if (bm.n1 == a and bm.n2 == b) or (bm.n1 == b and bm.n2 == a) then
			return nil
		end
	end
	self.beams[#self.beams + 1] = Beam.new(self.nodes, a, b, "road")
	Physics.refresh_masses(self)
	return #self.beams
end

function World:remove_beam(idx)
	table.remove(self.beams, idx)
	Physics.refresh_masses(self)
end

function World:pin(node_idx, pin_x, pin_y)
	local n = self.nodes[node_idx]
	n.pin_x = pin_x or false
	n.pin_y = pin_y or false
end

function World:set_load(node_idx, load)
	self.nodes[node_idx].load = load
end

function World:add_external_load(id, beam_idx, t, mass)
	self.external_loads[id] = { beam_idx = beam_idx, t = math.max(0, math.min(1, t)), mass = mass or 10 }
end

function World:update_external_load(id, beam_idx, t)
	local load = self.external_loads[id]
	if not load then return false end
	load.beam_idx = beam_idx
	load.t = math.max(0, math.min(1, t))
	return true
end

function World:remove_external_load(id)
	self.external_loads[id] = nil
end

function World:clear_external_loads()
	self.external_loads = {}
end

function World:apply_contact_force(beam_idx, t, fx, fy)
	if not self.beams[beam_idx] or self.beams[beam_idx].broken then return end
	table.insert(self.contact_forces, { beam_idx = beam_idx, t = t, fx = fx, fy = fy })
end

function World:clear_contact_forces()
	self.contact_forces = {}
end

function World:get_beam_geometry(beam_idx, t)
	local bm = self.beams[beam_idx]
	if not bm or bm.broken then return nil end
	local n1 = self.nodes[bm.n1]
	local n2 = self.nodes[bm.n2]
	t = math.max(0, math.min(1, t))
	return {
		x = n1.x + (n2.x - n1.x) * t,
		y = n1.y + (n2.y - n1.y) * t,
		angle = math.atan2(n2.y - n1.y, n2.x - n1.x),
		beam = bm
	}
end

function World:start()
	for _, n in ipairs(self.nodes) do
		n.rest_x, n.rest_y = n.x, n.y
		n.vx, n.vy = 0, 0
	end
	for _, bm in ipairs(self.beams) do
		bm.broken = false
		bm.force = 0
	end
	self.external_loads = {}
	self.contact_forces = {}
	Physics.refresh_masses(self)
	Physics.compute_forces(self)
	self.max_force = 0
	self.peak_force = 0
end

function World:reset()
	for _, n in ipairs(self.nodes) do
		Node.reset(n)
	end
	self.contact_forces = {}
end

function World:step(dt)
	dt = math.min(dt, self.config.DT_MAX)
	self.max_force = 0
	local dt_sub = dt / self.config.SUBSTEPS
	for _ = 1, self.config.SUBSTEPS do
		Physics.verlet_step(self, dt_sub)
	end
	Physics.check_failures(self)
end

function World:broken_count()
	local n = 0
	for _, bm in ipairs(self.beams) do
		if bm.broken then n = n + 1 end
	end
	return n
end

function World:is_fixed(idx)
	local n = self.nodes[idx]
	return n.pin_x and n.pin_y
end

return World