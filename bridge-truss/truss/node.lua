-- truss/node.lua
-- node constructor and reset helper
--
-- a node is a point mass that can be pinned (fixed) in x, y, or both
-- external load is a scalar multiplied by G inside physics

local Node = {}

-- creates a new node at position (x, y)
--
-- opts (all optional):
-- pin_x: boolean, fix horizontal position
-- pin_y: boolean, fix vertical position
-- load: number, extra downward load scalar (multiplied by G)
--
-- returns: node table
function Node.new(x, y, opts)
	opts = opts or {}

	local node = {
		x = x,
		y = y,
		vx = 0,
		vy = 0,
		fx = 0, -- accumulated force this step
		fy = 0,
		mass = 0, -- set by physics.refresh_masses()
		load = opts.load,
		pin_x = opts.pin_x or false,
		pin_y = opts.pin_y or false,
		rest_x = x, -- position before simulation start
		rest_y = y,
	}

	-- debug: print load if present
	if opts.load then
		print('node.load', node.load)
	end

	return node
end

-- restores node to rest position and clears velocity and forces
function Node.reset(n)
	n.x, n.y = n.rest_x, n.rest_y
	n.vx, n.vy = 0, 0
	n.fx, n.fy = 0, 0
end

return Node