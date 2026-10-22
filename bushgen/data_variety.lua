-- data_variety.lua
-- ranges for variety.lua
-- style: everything that makes plants look like one art set (one row)
-- plant: everything that changes the shape inside one style (columns)
-- a pair {a, b} means a random value between a and b

return {
	style = {
		-- base hue of the foliage; weight is how often the group is picked
		hues = {
			{weight = 32, h = {85, 150}},  -- greens
			{weight = 12, h = {55, 85}},   -- olive, yellow green
			{weight = 14, h = {150, 190}}, -- teal, blue green
			{weight = 17, h = {12, 50}},   -- autumn
			{weight = 8, h = {190, 240}},  -- frosty blue
			{weight = 7, h = {280, 345}},  -- exotic purple, pink
		},
		-- dark colours shift toward coolHue, light ones toward warmHue
		coolHue = 228,
		warmHue = 55,
		coolShift = {0.1, 0.55},
		warmShift = {0.05, 0.45},
		satDark = {0.35, 0.8},
		satLight = {0.3, 0.75},
		valDark = {0.07, 0.22},
		valLight = {0.66, 0.97},
		colours = {4, 8},

		outlineModes = {"dark", "dark", "ramp", "selective", "selective", "soft", "none"},
		shadow = {0.0, 0.38},
		crease = {1, 3},
		gap = {0, 2},
		fringe = {0.0, 0.55},
		textureChance = 0.5,
		texture = {0.25, 0.9},
		textureStep = {3, 4},
		edgeTipsChance = 0.6,
		edgeTips = {0.1, 0.5},
		noise = {0.0, 0.25},
		contrast = {0.9, 1.55},
		fold = {0.3, 1.1},
		toneMix = {0.0, 0.3},
		toneLight = {0.0, 0.15},
		bodyMix = {0.15, 0.6},
		clumpSquash = {0.7, 1.0},
		-- grain: size of clumps and leaves relative to the plant
		grain = {0.65, 1.45},
		spotChance = 0.4,
		spot = {0.15, 0.35},

		-- flowers and berries; each entry is hue, saturation, value
		ornamentChance = 0.45,
		ornamentColours = {
			{0, 0.80, 0.85},    -- red
			{345, 0.55, 0.95},  -- pink
			{48, 0.75, 1.0},    -- yellow
			{0, 0.05, 1.0},     -- white
			{275, 0.55, 0.85},  -- purple
			{215, 0.6, 0.95},   -- blue
			{24, 0.85, 1.0},    -- orange
			{320, 0.7, 0.75},   -- magenta
		},
		ornamentShapes = {"dot", "bud", "berry", "flower"},
		ornamentCount = {3, 10},
		barkHue = {10, 38},
		barkSat = {0.3, 0.65},
		barkVal = {0.35, 0.6},
	},

	plant = {
		-- names from data_plants.lua with a weight
		kinds = {
			{name = "round", weight = 3},
			{name = "foliage", weight = 3},
			{name = "sphere", weight = 2},
			{name = "hedge", weight = 2},
			{name = "fine", weight = 2},
			{name = "cluster", weight = 3},
			{name = "leafy", weight = 2},
			{name = "spiky", weight = 2},
			{name = "fern", weight = 1},
			{name = "broad", weight = 2},
			{name = "grass", weight = 2},
			{name = "tiered", weight = 2},
			{name = "bramble", weight = 2},
			{name = "bigleaf", weight = 2},
		},
		-- size of the plant; it is capped so the plant still fits the tile
		scale = {0.68, 1.12},
		maxRadius = 13.5,
		maxLeaf = 14.5,
		squash = {0.62, 1.05},
		stretchChance = 0.4,
		stretch = {1.1, 1.5},
		-- more or fewer clumps, leaves, stems
		count = {0.55, 1.6},
		-- chance that a plant shows the ornaments of its style
		ornamentChance = 0.65,
		-- chance of grass at the base (only for bush-like kinds)
		underChance = 0.22,
		underKinds = {blob = true, sphere = true, hedge = true, tiered = true, cluster = true, leafy = true},
	},
}
