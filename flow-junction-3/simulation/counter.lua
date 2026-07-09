-- simulation/counter.lua
-- counts cars per minute per in/out way and total
-- uses a sliding window of simulation time

local M = {}

local WINDOW = 60.0  -- simulation seconds

local spawnEvents   = {}  -- wayIdx -> { t1, t2, ... }
local despawnEvents = {}  -- wayIdx -> { t1, t2, ... }
local wayLabels     = {}  -- wayIdx -> label string
local wayType       = {}  -- wayIdx -> "in" | "out"
local firstSpawn    = nil
local firstDespawn  = nil

function M.reset()
	spawnEvents   = {}
	despawnEvents = {}
	wayLabels     = {}
	wayType       = {}
	firstSpawn    = nil
	firstDespawn  = nil
end

function M.build(map)
	M.reset()
	for idx, way in ipairs(map.ways or {}) do
		local t = way.tags and way.tags.type
		if t == "in" or t == "out" then
			-- prefer tags.name, then tags.from, then index
			local label = (way.tags.name and way.tags.name ~= "" and way.tags.name)
				or (way.tags.from and way.tags.from ~= "" and way.tags.from)
				or tostring(idx)
			wayLabels[idx] = label
			wayType[idx]   = t
		end
	end
end

local function pushEvent(tbl, wayIdx, simTime)
	if not tbl[wayIdx] then tbl[wayIdx] = {} end
	local list = tbl[wayIdx]
	list[#list + 1] = simTime
end

function M.onSpawn(wayIdx, simTime)
	pushEvent(spawnEvents, wayIdx, simTime)
	if not firstSpawn then firstSpawn = simTime end
end

function M.onDespawn(wayIdx, simTime)
	pushEvent(despawnEvents, wayIdx, simTime)
	if not firstDespawn then firstDespawn = simTime end
end

local function countRecent(list, simTime)
	if not list or #list == 0 then return 0 end
	local cutoff = simTime - WINDOW
	local i = 1
	while i <= #list and list[i] < cutoff do i = i + 1 end
	if i > 1 then
		for k = 1, #list - i + 1 do list[k] = list[k + i - 1] end
		for k = #list - i + 2, #list do list[k] = nil end
	end
	return #list
end

local function cpm(list, simTime, firstEvent)
	local n = countRecent(list, simTime)
	if not firstEvent then return 0 end
	local elapsed = math.min(simTime - firstEvent, WINDOW)
	if elapsed < 0.5 then return 0 end
	return n / elapsed * 60
end

function M.getStats(simTime)
	local inRows, outRows = {}, {}
	local inTotal, outTotal = 0, 0

	for wayIdx, label in pairs(wayLabels) do
		local wt = wayType[wayIdx]
		if wt == "in" then
			local v = cpm(spawnEvents[wayIdx], simTime, firstSpawn)
			inTotal = inTotal + v
			inRows[#inRows + 1] = { label = label, cpm = v }
		else
			local v = cpm(despawnEvents[wayIdx], simTime, firstDespawn)
			outTotal = outTotal + v
			outRows[#outRows + 1] = { label = label, cpm = v }
		end
	end

	table.sort(inRows,  function(a, b) return a.label < b.label end)
	table.sort(outRows, function(a, b) return a.label < b.label end)

	return inRows, outRows, inTotal, outTotal
end

return M