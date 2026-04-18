-- truss/config.lua
-- default physics constants for a truss world
-- all values can be overridden when calling truss.new(config)
return {
-- material / structural
	EA = 10000,        -- axial stiffness (E*A) in newtons
	MAX_F = 750,  -- fracture force limit (newtons)
	BEAM_WT = 0.0001,   -- beam mass per pixel of rest length (kg/px)
	NODE_BASE_MASS = 0.001, -- minimum node mass (kg)

	EXT_LOAD = 0.2,  -- added load mass (kg)

-- dynamics
	G = 500, -- gravitational acceleration (px/s^2)

-- normalized damping ratios (0 = no damping, 1 = critical)
	ZETA_AXIAL = 0.70,
	ZETA_ANGULAR = 0.05,
	HINGE_DAMPING = 0.02,

-- integrator
	SUBSTEPS = 16, -- verlet substeps per frame
	DT_MAX = 0.02, -- max frame dt (seconds)

-- road specific overrides
	ROAD_EA = 10000,
	ROAD_MAX_F = 1000,
	ROAD_BEAM_WT = 0.00015,
}