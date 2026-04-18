-- truss/world.lua
-- world is the top-level simulation container; it stores nodes beams and runs the physics step
-- think of it as the "scene" that owns everything and updates it each frame
--
-- quick-start example:
--
-- local truss = require("truss")
--
-- local world = truss.new() -- or truss.new({ G=300, EA=2e7 })
--
-- local n1 = world:add_node(100, 400)
-- local n2 = world:add_node(300, 400)
-- local n3 = world:add_node(200, 260)
--
-- world:pin(n1, true, true) -- fixed support; cannot move
-- world:pin(n2, false, true) -- roller; can move in x but not in y
-- world:set_load(n3, 5) -- downward load scalar
--
-- world:add_beam(n1, n2)
-- world:add_beam(n1, n3)
-- world:add_beam(n2, n3)
--
-- world:start() -- capture rest state; required before simulation
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

-- create a new simulation world; config can override default physics parameters
function World.new(config)
	local self = setmetatable({}, World)

	-- copy default config; then override with user values if provided
	self.config = {}
	for k, v in pairs(Config) do self.config[k] = v end
	if config then
		for k, v in pairs(config) do self.config[k] = v end
	end

	self.nodes = {} -- array of node tables
	self.beams = {} -- array of beam tables

	self.max_force = 0 -- max force seen in current step; used for visualization
	self.peak_force = 0 -- max force since last start; useful for stats

	-- optional callback when a beam breaks; can be used for sound particles debris
	self.on_beam_break = nil

	return self
end

---------------------------------------------------------------
-- topology
---------------------------------------------------------------

-- add a node at position x y; returns its index
-- opts may contain pin_x pin_y load
function World:add_node(x, y, opts)
	local node = Node.new(x, y, opts)
	table.insert(self.nodes, node)

	-- recompute masses because topology changed; beams attached to this node affect mass
	Physics.refresh_masses(self)

	return #self.nodes 
end

-- remove a node and all beams connected to it; indices are compacted after removal
function World:remove_node(idx)
	for j = #self.beams, 1, -1 do
		local bm = self.beams[j]
		if bm.n1 == idx or bm.n2 == idx then
			table.remove(self.beams, j)
		end
	end

	table.remove(self.nodes, idx)

	-- fix indices inside beams after removing node
	for _, bm in ipairs(self.beams) do
		if bm.n1 > idx then bm.n1 = bm.n1 - 1 end
		if bm.n2 > idx then bm.n2 = bm.n2 - 1 end
	end

	-- topology changed so masses must be updated
	Physics.refresh_masses(self)
end

-- add a beam between nodes a and b; returns index or nil if already exists
function World:add_beam(a, b)
	for _, bm in ipairs(self.beams) do
		if (bm.n1 == a and bm.n2 == b) or (bm.n1 == b and bm.n2 == a) then
			return nil -- prevent duplicate beams
		end
	end

	self.beams[#self.beams + 1] = Beam.new(self.nodes, a, b)

	-- beam adds mass to both nodes so recompute
	Physics.refresh_masses(self)

	return #self.beams
end

-- remove beam at index idx
function World:remove_beam(idx)
	table.remove(self.beams, idx)

	-- removing beam changes mass distribution
	Physics.refresh_masses(self)
end

---------------------------------------------------------------
-- node property setters
---------------------------------------------------------------

-- set pin constraints; pinned axis cannot move during simulation
function World:pin(node_idx, pin_x, pin_y)
	local n = self.nodes[node_idx]
	n.pin_x = pin_x or false
	n.pin_y = pin_y or false
end

-- set or clear external load; load is multiplied by gravity G
function World:set_load(node_idx, load)
	self.nodes[node_idx].load = load
end

---------------------------------------------------------------
-- simulation lifecycle
---------------------------------------------------------------

-- initialize simulation; captures rest positions and clears velocities
-- must be called once before stepping
function World:start()
	for _, n in ipairs(self.nodes) do
		n.rest_x, n.rest_y = n.x, n.y -- reference position for constraints
		n.vx, n.vy = 0, 0 -- start at rest
	end

	for _, bm in ipairs(self.beams) do
		bm.broken = false
		bm.force = 0
	end

	-- compute initial masses and forces
	Physics.refresh_masses(self)
	Physics.compute_forces(self)

	self.max_force = 0
	self.peak_force = 0
end

-- reset nodes back to rest positions; does not rebuild topology
function World:reset()
	for _, n in ipairs(self.nodes) do
		Node.reset(n)
	end
end

-- advance simulation by dt seconds; internally splits into smaller stable steps
function World:step(dt)
	dt = math.min(dt, self.config.DT_MAX)
	self.max_force = 0

	local dt_sub = dt / self.config.SUBSTEPS

	for _ = 1, self.config.SUBSTEPS do
		Physics.verlet_step(self, dt_sub)
	end

	-- check for beam failure; important: masses are NOT recomputed after break
	-- broken beams stop applying forces but their mass remains on nodes
	Physics.check_failures(self)
end

---------------------------------------------------------------
-- queries
---------------------------------------------------------------

-- count how many beams are broken; useful for win/lose conditions
function World:broken_count()
	local n = 0
	for _, bm in ipairs(self.beams) do
		if bm.broken then n = n + 1 end
	end
	return n
end

-- check if node is fully fixed; cannot move in both axes
function World:is_fixed(idx)
	local n = self.nodes[idx]
	return n.pin_x and n.pin_y
end

return World