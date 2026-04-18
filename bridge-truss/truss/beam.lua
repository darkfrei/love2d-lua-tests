-- truss/beam.lua
-- beam constructor
-- a beam is a two-node spring-damper element
-- its rest length (L0) is computed from node positions at creation time
local Beam = {}
-- creates a beam connecting node indices a and b
-- nodes: array of node tables (used to read initial positions)
-- a, b: integer indices into nodes
-- type: optional string, "truss" or "road"
-- returns: beam table
function Beam.new(nodes, a, b, type)
local dx = nodes[b].x - nodes[a].x
local dy = nodes[b].y - nodes[a].y
return {
	n1 = a, -- index of first node
	n2 = b, -- index of second node
	L0 = math.sqrt(dx*dx + dy*dy), -- rest length
	force = 0, -- current axial force (+ tension, - compression)
	broken = false, -- fracture flag
	type = type or "truss"
}
end
return Beam