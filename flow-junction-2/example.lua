-- example.lua
-- v2026-06-07
--
-- compact osm-style intersection
-- with straight lanes and cubic bezier turns
--
-- coordinate system:
--   x -> right
--   y -> down
--
-- intersection layout:
--
--           north
--              |
--              |
-- west --------+-------- east
--              |
--              |
--           south
--
-- lane directions:
--   each road contains:
--       - one incoming lane
--       - one outgoing lane
--
-- way naming:
--   N-IN
--       incoming lane from north
--
--   N-MID
--       straight crossing segment
--
--   N-OUT
--       outgoing lane toward south
--
-- bezier turns:
--   cubic bezier curves use:
--       start point
--       control point 1
--       control point 2
--       end point
--
-- all coordinates are generated procedurally
-- from a small set of layout constants

-- extension outside the intersection box
local EXT = 200

-- screen center
local centerX = 1920 / 2
local centerY = 1080 / 2

-- lane half-offset from road center
local laneOffset = 30

-- intersection square size
local size = 800

-- bezier handle distance
local handle = 180

-- intersection bounds
local half = size / 2

local left   = centerX - half
local right  = centerX + half

local top    = centerY - half
local bottom = centerY + half

-- lane centers
--
-- vertical:
--   lx = north -> south
--   rx = south -> north
--
-- horizontal:
--   ty = east -> west
--   by = west -> east
local lx = centerX - laneOffset
local rx = centerX + laneOffset

local ty = centerY - laneOffset
local by = centerY + laneOffset

-- point helper
local function pt(x, y)
	return {
		x = x,
		y = y
	}
end

return {

	-- node registry
	--
	-- nodes are shared between ways
	--
	-- format:
	--   [id] = { x, y }
	nodes = {

		-- north -> south lane

		-- far north spawn
		[1] = pt(lx, top - EXT),

		-- intersection entry
		[2] = pt(lx, top),

		-- intersection exit
		[4] = pt(lx, bottom),

		-- far south exit
		[5] = pt(lx, bottom + EXT),

		-- south -> north lane

		[6]  = pt(rx, bottom + EXT),
		[7]  = pt(rx, bottom),
		[9]  = pt(rx, top),
		[10] = pt(rx, top - EXT),

		-- east -> west lane

		[11] = pt(right + EXT, ty),
		[12] = pt(right, ty),
		[14] = pt(left, ty),
		[15] = pt(left - EXT, ty),

		-- west -> east lane

		[16] = pt(left - EXT, by),
		[17] = pt(left, by),
		[19] = pt(right, by),
		[20] = pt(right + EXT, by),

		-- bezier handles
		--
		-- these nodes are only used as
		-- cubic bezier control points

		-- north -> west
		[25] = pt(lx, top + handle),
		[26] = pt(left + handle, ty),

		-- south -> east
		[27] = pt(rx, bottom - handle),
		[28] = pt(right - handle, by),

		-- east -> north
		[29] = pt(right - handle, ty),
		[30] = pt(rx, top + handle),

		-- west -> south
		[31] = pt(left + handle, by),
		[32] = pt(lx, bottom - handle),
	},

	-- way registry
	--
	-- format:
	--
	-- {
	--     id = "...",
	--     nodeRefs = { ... },
	--     tags = {
	--         curve = "linear" | "bezier",
	--         type  = "in" | "mid" | "out" | "turn"
	--     }
	-- }
	ways = {

		-- north -> south lane

		{
			id = "N-IN",
			nodeRefs = { 1, 2 },
			tags = { curve = "linear", type = "in" }
		},

		{
			id = "N-MID",
			nodeRefs = { 2, 4 },
			tags = { curve = "linear", type = "mid" }
		},

		{
			id = "N-OUT",
			nodeRefs = { 4, 5 },
			tags = { curve = "linear", type = "out" }
		},

		-- south -> north lane

		{
			id = "S-IN",
			nodeRefs = { 6, 7 },
			tags = { curve = "linear", type = "in" }
		},

		{
			id = "S-MID",
			nodeRefs = { 7, 9 },
			tags = { curve = "linear", type = "mid" }
		},

		{
			id = "S-OUT",
			nodeRefs = { 9, 10 },
			tags = { curve = "linear", type = "out" }
		},

		-- east -> west lane

		{
			id = "E-IN",
			nodeRefs = { 11, 12 },
			tags = { curve = "linear", type = "in" }
		},

		{
			id = "E-MID",
			nodeRefs = { 12, 14 },
			tags = { curve = "linear", type = "mid" }
		},

		{
			id = "E-OUT",
			nodeRefs = { 14, 15 },
			tags = { curve = "linear", type = "out" }
		},

		-- west -> east lane

		{
			id = "W-IN",
			nodeRefs = { 16, 17 },
			tags = { curve = "linear", type = "in" }
		},

		{
			id = "W-MID",
			nodeRefs = { 17, 19 },
			tags = { curve = "linear", type = "mid" }
		},

		{
			id = "W-OUT",
			nodeRefs = { 19, 20 },
			tags = { curve = "linear", type = "out" }
		},

		-- turns

		{
			id = "N-E",
			nodeRefs = { 2, 25, 28, 19 },
			tags = { curve = "bezier", type = "turn" }
		},

		{
			id = "E-S",
			nodeRefs = { 12, 29, 32, 4 },
			tags = { curve = "bezier", type = "turn" }
		},

		{
			id = "S-W",
			nodeRefs = { 7, 27, 26, 14 },
			tags = { curve = "bezier", type = "turn" }
		},

		{
			id = "W-N",
			nodeRefs = { 17, 31, 30, 9 },
			tags = { curve = "bezier", type = "turn" }
		},

		{
			id = "N-W",
			nodeRefs = { 2, 25, 26, 14 },
			tags = { curve = "bezier", type = "turn" }
		},

		{
			id = "S-E",
			nodeRefs = { 7, 27, 28, 19 },
			tags = { curve = "bezier", type = "turn" }
		},

		{
			id = "E-N",
			nodeRefs = { 12, 29, 30, 9 },
			tags = { curve = "bezier", type = "turn" }
		},

		{
			id = "W-S",
			nodeRefs = { 17, 31, 32, 4 },
			tags = { curve = "bezier", type = "turn" }
		},
	}
}