-- truss/config.lua
-- default physics constants for a truss world
-- all values can be overridden when calling truss.new(config)

return {
	-- material / structural

	EA = 1e6,        -- axial stiffness (E*A) in newtons
	MAX_F = 10000,  -- fracture force limit (newtons)
	BEAM_WT = 0.004705,   -- beam mass per pixel of rest length (kg/px)
	NODE_BASE_MASS = 0.1, -- minimum node mass (kg)
	
	EXT_LOAD = 1,  -- added load mass (kg)

	-- dynamics

	G = 500, -- gravitational acceleration (px/s^2)

	-- normalized damping ratios (0 = no damping, 1 = critical)

	-- axial mode:
	-- c_crit = 2 * sqrt(k * m_eff), where k = EA / L
	-- F_damp = ZETA_AXIAL * c_crit * v_axial

	-- angular / pendulum mode:
	-- c_crit = 2 * m_eff * sqrt(G / L)
	-- F_damp = ZETA_ANGULAR * c_crit * |v_lateral|

	-- axial 0.5-1.0 -> oscillations settle in ~1-2 s
	-- angular 0.02-0.15 -> pendulum swings multiple times before stopping

	ZETA_AXIAL = 0.70,
	ZETA_ANGULAR = 0.05,

	-- integrator

	SUBSTEPS = 16, -- verlet substeps per frame
	DT_MAX = 0.2, -- max frame dt (seconds)
}