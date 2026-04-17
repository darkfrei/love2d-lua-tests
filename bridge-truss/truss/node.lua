-- truss/node.lua
-- Node constructor and reset helper.
--
-- A node is a point mass that can be pinned (fixed) in x, y, or both.
-- External loads are a scalar multiplied by G inside physics.

local Node = {}

-- Create a new node at position (x, y).
--
-- opts fields (all optional):
-- pin_x boolean fix horizontal position
-- pin_y boolean fix vertical position
-- load number extra downward load scalar (multiplied by G)
--
-- Returns a node table.
function Node.new(x, y, opts)
	opts = opts or {}
	
	local node = {
		x = x,
		y = y,
		vx = 0,
		vy = 0,
		fx = 0, -- accumulated force this step (set by physics)
		fy = 0,
		mass = 0, -- set by physics.refresh_masses()
		load = opts.load,
		pin_x = opts.pin_x or false,
		pin_y = opts.pin_y or false,
		rest_x = x, -- position before simulation started
		rest_y = y,
	}
	
	if opts.load then
		print ('node.load', node.load)
	end
	
	return node
end

-- Restore a node to its rest position and clear velocity / forces.
function Node.reset(n)
	n.x, n.y = n.rest_x, n.rest_y
	n.vx, n.vy = 0, 0
	n.fx, n.fy = 0, 0
end

return Node
