-- truss/beam.lua
-- Beam constructor.
--
-- A beam is a two-node spring-damper element.
-- Its rest length (L0) is computed from the node positions at creation time.

local Beam = {}

-- Create a beam connecting node indices a and b.
--
-- nodes array of node tables (to read initial positions)
-- a, b integer indices into nodes
--
-- Returns a beam table.
function Beam.new(nodes, a, b)
	local dx = nodes[b].x - nodes[a].x
	local dy = nodes[b].y - nodes[a].y
	return {
		n1 = a,
		n2 = b,
		L0 = math.sqrt(dx*dx + dy*dy), -- rest length
		force = 0, -- current axial force (+ tension, - compression)
		broken = false,
	}
end

return Beam
