-- truss/world.lua
-- World: the top-level simulation container.
--
-- Quick-start example:
--
-- local Truss = require("truss")
--
-- local world = Truss.new() -- or Truss.new({ G=300, EA=2e7 })
--
-- local n1 = world:add_node(100, 400)
-- local n2 = world:add_node(300, 400)
-- local n3 = world:add_node(200, 260)
--
-- world:pin(n1, true, true) -- fixed pin support
-- world:pin(n2, false, true) -- vertical roller
-- world:set_load(n3, 5) -- downward load scalar
--
-- world:add_beam(n1, n2)
-- world:add_beam(n1, n3)
-- world:add_beam(n2, n3)
--
-- world:start() -- snapshot rest, begin simulation
--
-- -- in your update loop:
-- world:step(dt)
--
-- -- read back state:
-- for _, node in ipairs(world.nodes) do
-- print(node.x, node.y)
-- end
-- for _, beam in ipairs(world.beams) do
-- print(beam.force, beam.broken)
-- end

local Node = require("truss.node")
local Beam = require("truss.beam")
local Physics = require("truss.physics")
local Config = require("truss.config")

local World = {}
World.__index = World

-- Create a new simulation world.
-- config optional table; keys override defaults from truss/config.lua.
function World.new(config)
	local self = setmetatable({}, World)

	-- Merge user overrides on top of defaults
	self.config = {}
	for k, v in pairs(Config) do self.config[k] = v end
	if config then
		for k, v in pairs(config) do self.config[k] = v end
	end

	self.nodes = {}
	self.beams = {}

	self.max_force = 0 -- peak force seen this simulation step
	self.peak_force = 0 -- peak force since last world:start()

	-- Optional callback, fired when a beam breaks.
	-- Signature: function(beam_table) -> void
	self.on_beam_break = nil

	return self
end

---------------------------------------------------------------
-- Topology
---------------------------------------------------------------

-- Add a node at (x, y) and return its integer index.
-- opts: { pin_x, pin_y, load }
function World:add_node(x, y, opts)
--	self.nodes[#self.nodes + 1] = Node.new(x, y, opts)
	local node = Node.new(x, y, opts)
	table.insert (self.nodes, node)
	Physics.refresh_masses(self)
	return #self.nodes 
end

-- Remove the node at index idx and all beams connected to it.
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

-- Add a beam between node indices a and b.
-- Returns the beam index, or nil if the beam already exists.
function World:add_beam(a, b)
	for _, bm in ipairs(self.beams) do
		if (bm.n1 == a and bm.n2 == b) or (bm.n1 == b and bm.n2 == a) then
			return nil
		end
	end
	self.beams[#self.beams + 1] = Beam.new(self.nodes, a, b)
	Physics.refresh_masses(self)
	return #self.beams
end

-- Remove the beam at index idx.
function World:remove_beam(idx)
	table.remove(self.beams, idx)
	Physics.refresh_masses(self)
end

---------------------------------------------------------------
-- Node property setters (convenience wrappers)
---------------------------------------------------------------

-- Set pin constraints on a node.
-- pin_x true = fixed horizontal, pin_y true = fixed vertical
function World:pin(node_idx, pin_x, pin_y)
	local n = self.nodes[node_idx]
	n.pin_x = pin_x or false
	n.pin_y = pin_y or false
end

-- Set (or clear) an external load on a node.
-- load number multiplied by G, or nil to remove the load.
function World:set_load(node_idx, load)
	print ('World:set_load, load', load)
	self.nodes[node_idx].load = load
end

---------------------------------------------------------------
-- Simulation lifecycle
---------------------------------------------------------------

-- Snapshot current positions as rest positions and reset velocities.
-- Must be called before the first step().
function World:start()
	for _, n in ipairs(self.nodes) do
		n.rest_x, n.rest_y = n.x, n.y
		n.vx, n.vy = 0, 0
	end
	for _, bm in ipairs(self.beams) do
		bm.broken = false
		bm.force = 0
	end
	Physics.refresh_masses(self)
	Physics.compute_forces(self)
	self.max_force = 0
	self.peak_force = 0
end

-- Rewind all nodes to rest positions and zero their velocities.
function World:reset()
	for _, n in ipairs(self.nodes) do
		Node.reset(n)
	end
end

-- Advance the simulation by dt seconds.
-- Runs config.SUBSTEPS Verlet sub-steps, then checks for beam failures.
function World:step(dt)
	dt = math.min(dt, self.config.DT_MAX)
	self.max_force = 0
	local dt_sub = dt / self.config.SUBSTEPS
	for _ = 1, self.config.SUBSTEPS do
		Physics.verlet_step(self, dt_sub)
	end
	Physics.check_failures(self)
end

---------------------------------------------------------------
-- Queries
---------------------------------------------------------------

-- Return the number of broken beams.
function World:broken_count()
	local n = 0
	for _, bm in ipairs(self.beams) do
		if bm.broken then n = n + 1 end
	end
	return n
end

-- Return true if node idx is fixed in both x and y.
function World:is_fixed(idx)
	local n = self.nodes[idx]
	return n.pin_x and n.pin_y
end

return World
