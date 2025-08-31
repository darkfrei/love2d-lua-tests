-- testMap

local tiles = {
	{ q = 0, r = 0, typ = "grass" },
	{ q = 1, r = 0, typ = "grass" },
	{ q = 2, r = 0, typ = "forest" },
	{ q = 0, r = 1, typ = "grass" },
	{ q = 1, r = 1, typ = "forest" },
	{ q = 2, r = 1, typ = "grass" },
	{ q = -1, r = 1, typ = "grass" },
	{ q = -1, r = 0, typ = "grass" },
	{ q = -1, r = -1, typ = "grass" },
	{ q = 0, r = -1, typ = "grass" },
	{ q = 1, r = -1, typ = "forest" },
}

local objects = {
		{ q = 0, r = 0, typ = "village" },
		{ q = 0, r = 0, typ = "scout"},
	}

local map = {
	tiles = tiles,
	objects = objects,
	}

return map
