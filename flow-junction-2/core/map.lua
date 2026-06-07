-- core/map.lua
-- graph topology and editing api

local FileManager = require("editor.filemanager")

local Map = {}
Map.__index = Map

--
-- constructor
--

function Map.new()
	local self = setmetatable({}, Map)
	self.nodes = {}
	self.ways  = {}
	self._nextNodeId = 1000
	return self
end

--
-- editor api
--

function Map.addNode(map, x, y)
	map._nextNodeId = (map._nextNodeId or 1) + 1
	local id = map._nextNodeId
	map.nodes[id] = { x = x, y = y }
	return id
end

function Map.moveNode(map, id, x, y)
	local n = map.nodes[id]
	if not n then return end
	n.x = x
	n.y = y
end

function Map.addWay(map, id, nodeRefs, curveType)
	local way = {
		id       = id or (#map.ways + 1),
		nodeRefs = nodeRefs,
		tags     = { curve = curveType or "linear" }
	}
	table.insert(map.ways, way)
	return way.id
end

--
-- default map
--

function Map.loadDefault(map)
	map.nodes = {
		[1]  = { x = 930,  y = -60  },
		[2]  = { x = 930,  y = 140  },
		[4]  = { x = 930,  y = 940  },
		[5]  = { x = 930,  y = 1140 },
		[6]  = { x = 990,  y = 1140 },
		[7]  = { x = 990,  y = 940  },
		[9]  = { x = 990,  y = 140  },
		[10] = { x = 990,  y = -60  },
		[11] = { x = 1560, y = 510  },
		[12] = { x = 1360, y = 510  },
		[14] = { x = 560,  y = 510  },
		[15] = { x = 360,  y = 510  },
		[16] = { x = 360,  y = 570  },
		[17] = { x = 560,  y = 570  },
		[19] = { x = 1360, y = 570  },
		[20] = { x = 1560, y = 570  },
	}

	map.ways = {
		{ id = "N-IN",  nodeRefs = { 1,  2  }, tags = { curve = "linear", type = "in",  from = "N", to = "N" } },
		{ id = "N-MID", nodeRefs = { 2,  4  }, tags = { curve = "linear", type = "mid", from = "N", to = "S" } },
		{ id = "N-OUT", nodeRefs = { 4,  5  }, tags = { curve = "linear", type = "out", from = "N", to = "S" } },

		{ id = "S-IN",  nodeRefs = { 6,  7  }, tags = { curve = "linear", type = "in",  from = "S", to = "S" } },
		{ id = "S-MID", nodeRefs = { 7,  9  }, tags = { curve = "linear", type = "mid", from = "S", to = "N" } },
		{ id = "S-OUT", nodeRefs = { 9,  10 }, tags = { curve = "linear", type = "out", from = "S", to = "N" } },

		{ id = "E-IN",  nodeRefs = { 11, 12 }, tags = { curve = "linear", type = "in",  from = "E", to = "E" } },
		{ id = "E-MID", nodeRefs = { 12, 14 }, tags = { curve = "linear", type = "mid", from = "E", to = "W" } },
		{ id = "E-OUT", nodeRefs = { 14, 15 }, tags = { curve = "linear", type = "out", from = "E", to = "W" } },

		{ id = "W-IN",  nodeRefs = { 16, 17 }, tags = { curve = "linear", type = "in",  from = "W", to = "W" } },
		{ id = "W-MID", nodeRefs = { 17, 19 }, tags = { curve = "linear", type = "mid", from = "W", to = "E" } },
		{ id = "W-OUT", nodeRefs = { 19, 20 }, tags = { curve = "linear", type = "out", from = "W", to = "E" } },
	}

	map._nextNodeId = 32
end

--
-- queries
--

function Map.nodeAt(map, wx, wy, radius)
	local r2 = radius * radius

	for id, node in pairs(map.nodes) do
		local dx = node.x - wx
		local dy = node.y - wy
		if dx * dx + dy * dy <= r2 then
			return id
		end
	end

	return nil
end

local function distToSegment2(px, py, ax, ay, bx, by)
	local dx, dy = bx - ax, by - ay
	local len2 = dx * dx + dy * dy

	if len2 == 0 then
		local ex, ey = px - ax, py - ay
		return ex * ex + ey * ey
	end

	local t = ((px - ax) * dx + (py - ay) * dy) / len2
	t = math.max(0, math.min(1, t))

	local cx, cy = ax + t * dx, ay + t * dy
	local fx, fy = px - cx, py - cy

	return fx * fx + fy * fy
end

local function collectPts(map, way)
	local pts = {}

	for _, id in ipairs(way.nodeRefs) do
		if map.nodes[id] then
			pts[#pts + 1] = map.nodes[id]
		end
	end

	return pts
end

function Map.wayAt(map, wx, wy, radius)
	local r2 = radius * radius

	for idx, way in ipairs(map.ways) do
		local curve = way.tags and way.tags.curve or "linear"
		local pts   = collectPts(map, way)

		if #pts >= 2 then
			if curve == "bezier" and #pts == 4 then
				local prev = pts[1]

				for i = 1, 20 do
					local t = i / 20
					local u = 1 - t

					local x =
					u^3 * pts[1].x +
					3 * u^2 * t * pts[2].x +
					3 * u * t^2 * pts[3].x +
					t^3 * pts[4].x

					local y =
					u^3 * pts[1].y +
					3 * u^2 * t * pts[2].y +
					3 * u * t^2 * pts[3].y +
					t^3 * pts[4].y

					local cur = { x = x, y = y }

					if distToSegment2(wx, wy, prev.x, prev.y, cur.x, cur.y) <= r2 then
						return idx
					end

					prev = cur
				end
			else
				for i = 1, #pts - 1 do
					if distToSegment2(wx, wy,
						pts[i].x, pts[i].y,
						pts[i + 1].x, pts[i + 1].y
						) <= r2 then
						return idx
					end
				end
			end
		end
	end

	return nil
end

--
-- editing
--

function Map.removeNode(map, nodeId)
	map.nodes[nodeId] = nil

	for i = #map.ways, 1, -1 do
		local way = map.ways[i]

		for _, id in ipairs(way.nodeRefs) do
			if id == nodeId then
				table.remove(map.ways, i)
				break
			end
		end
	end
end

function Map.removeWay(map, idx)
	local way = map.ways[idx]
	if not way then return end

	local candidates = {}

	for _, id in ipairs(way.nodeRefs) do
		candidates[id] = true
	end

	table.remove(map.ways, idx)

	for id in pairs(candidates) do
		local used = false

		for _, w in ipairs(map.ways) do
			for _, ref in ipairs(w.nodeRefs) do
				if ref == id then
					used = true
					break
				end
			end
			if used then break end
		end

		if not used then
			map.nodes[id] = nil
		end
	end
end

--
-- io
--

function Map.loadFromFile(map, filename)

	-- set tags on existing way
	function Map.setWayTags(map, idx, tags)
		local way = map.ways[idx]
		if not way then return end
		if not way.tags then way.tags = {} end

		for k, v in pairs(tags) do
			way.tags[k] = v
		end
	end

	-- clear way type tag
	function Map.clearWayType(map, idx)
		local way = map.ways[idx]
		if not way then return end
		if way.tags then
			way.tags.type = nil
		end
	end

	local data = FileManager.load(filename)
	if type(data) ~= "table" then
		return false, "invalid map"
	end

	map.nodes = data.nodes or {}
	map.ways  = data.ways or {}

	local maxId = 0
	for id, _ in pairs(map.nodes) do
		local n = tonumber(id) or 0
		if n > maxId then maxId = n end
	end

	map._nextNodeId = maxId

	return true
end

return Map