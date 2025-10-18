-- qmm to lua converter - full version
-- converts quest.qmm binary format to quest.lua text format with ALL data

-- get script directory and file paths
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local scriptDir = scriptPath:match("(.+)\\") or scriptPath:match("(.+)/")
local qmmFile = scriptDir .. "\\" .. "quest.qmm"
local luaFile = scriptDir .. "\\" .. "quest.lua"

local LOCATION_TEXTS = 10

-- header constants
local HEADER_QM_2 = 0x423a35d2
local HEADER_QM_3 = 0x423a35d3
local HEADER_QM_4 = 0x423a35d4
local HEADER_QMM_6 = 0x423a35d6
local HEADER_QMM_7 = 0x423a35d7
local HEADER_QMM_7_WITH_OLD_TGE_BEHAVIOUR = 0x69f6bd7

-- reader class
local Reader = {}
Reader.__index = Reader

function Reader:new(data)
	return setmetatable({data=data, i=1}, self)
end

function Reader:isNotEnd()
	return self.i <= #self.data
end

function Reader:int32()
	if self.i + 3 > #self.data then
		local val = 0
		self.i = #self.data + 1
		return val
	end
	local b1,b2,b3,b4 = string.byte(self.data, self.i, self.i+3)
	self.i = self.i + 4
	local val = b1 + b2*0x100 + b3*0x10000 + b4*0x1000000
	if val >= 0x80000000 then val = val - 0x100000000 end
	return val
end

function Reader:byte()
	if self.i > #self.data then
		error("read byte beyond end of file")
	end
	local b = string.byte(self.data, self.i)
	self.i = self.i + 1
	return b
end

function Reader:dwordFlag(expected)
	local val = self:int32()
	if expected and val ~= expected then
		error(string.format("expecting %d, but got %d at position %d", expected, val, self.i-4))
	end
end

function Reader:float64()
	if self.i + 7 > #self.data then error("read float64 beyond end of file") end
	local b1,b2,b3,b4,b5,b6,b7,b8 = string.byte(self.data, self.i, self.i+7)
	self.i = self.i + 8
	return string.unpack("<d", string.char(b1,b2,b3,b4,b5,b6,b7,b8))
end

function Reader:seek(n)
	self.i = self.i + n
end

function Reader:readString(canBeUndefined)
	if self.i + 3 > #self.data then
		return canBeUndefined and nil or ""
	end

	local ifString = self:int32()
	if ifString ~= 0 then
		if self.i + 3 > #self.data then
			return ""
		end
		local strLen = self:int32()
		if strLen <= 0 then return "" end
		if self.i + strLen*2 - 1 > #self.data then
			strLen = math.floor((#self.data - self.i + 1)/2)
		end

		-- read utf-16le and convert to utf-8
		local chars = {}
		for j = 1, strLen do
			local b1, b2 = string.byte(self.data, self.i, self.i + 1)
			if not b1 or not b2 then break end

			local codepoint = b1 + b2 * 256

			-- utf-16le to utf-8 conversion
			if codepoint < 0x80 then
				table.insert(chars, string.char(codepoint))
			elseif codepoint < 0x800 then
				table.insert(chars, string.char(
						0xC0 + math.floor(codepoint / 64),
						0x80 + (codepoint % 64)
					))
			elseif codepoint >= 0xD800 and codepoint <= 0xDBFF then
				self.i = self.i + 2
				if j < strLen then
					local b3, b4 = string.byte(self.data, self.i, self.i + 1)
					if b3 and b4 then
						local low = b3 + b4 * 256
						if low >= 0xDC00 and low <= 0xDFFF then
							local cp = 0x10000 + ((codepoint - 0xD800) * 0x400) + (low - 0xDC00)
							table.insert(chars, string.char(
									0xF0 + math.floor(cp / 262144),
									0x80 + (math.floor(cp / 4096) % 64),
									0x80 + (math.floor(cp / 64) % 64),
									0x80 + (cp % 64)
								))
							j = j + 1
						end
					end
				end
			elseif codepoint >= 0xDC00 and codepoint <= 0xDFFF then
				self.i = self.i + 2
			else
				table.insert(chars, string.char(
						0xE0 + math.floor(codepoint / 4096),
						0x80 + (math.floor(codepoint / 64) % 64),
						0x80 + (codepoint % 64)
					))
			end

			self.i = self.i + 2
		end
		return table.concat(chars)
	else
		return canBeUndefined and nil or ""
	end
end

--------------------------------------------

-- parsing functions
local function parseBase(r, header)
	local isQmm = (header==HEADER_QMM_6 or header==HEADER_QMM_7 or header==HEADER_QMM_7_WITH_OLD_TGE_BEHAVIOUR)
	local res = {}
	if isQmm then
		if header==HEADER_QMM_7 or header==HEADER_QMM_7_WITH_OLD_TGE_BEHAVIOUR then
			res.majorVersion = r:int32()
			res.minorVersion = r:int32()
			res.changeLogString = r:readString(true)
		end
		res.givingRace = r:byte()
		res.whenDone = r:byte()
		res.planetRace = r:byte()
		res.playerCareer = r:byte()
		res.playerRace = r:byte()
		res.reputationChange = r:int32()
		res.screenSizeX = r:int32()
		res.screenSizeY = r:int32()
		res.widthSize = r:int32()
		res.heightSize = r:int32()
		res.defaultJumpCountLimit = r:int32()
		res.hardness = r:int32()
		res.paramsCount = r:int32()
	else
		local paramsCount = (header==HEADER_QM_3) and 48 or (header==HEADER_QM_2) and 24 or (header==HEADER_QM_4) and 96 or 0
		r:dwordFlag()
		res.givingRace = r:byte()
		res.whenDone = r:byte()
		r:dwordFlag()
		res.planetRace = r:byte()
		r:dwordFlag()
		res.playerCareer = r:byte()
		r:dwordFlag()
		res.playerRace = r:byte()
		res.reputationChange = r:int32()
		res.screenSizeX = r:int32()
		res.screenSizeY = r:int32()
		res.widthSize = r:int32()
		res.heightSize = r:int32()
		r:dwordFlag()
		res.defaultJumpCountLimit = r:int32()
		res.hardness = r:int32()
		res.paramsCount = paramsCount
	end
	return res
end

-- detect if a string can be safely converted to number
local function autoConvertNumber(val)
	-- only convert if it's a string that looks like a number
	if type(val) == "string" and val:match("^%-?%d+%.?%d*$") then
		local num = tonumber(val)
		if num then return num end
	end
	return val
end

local function parseParamQmm(r)
	local p = {}
	p.min = r:int32()
	p.max = r:int32()
	p.type = r:byte()
	r:byte(); r:byte(); r:byte()
	p.showWhenZero = r:byte()~=0
	p.critType = r:byte()
	p.active = r:byte()~=0
	local showingRangesCount = r:int32()
	p.isMoney = r:byte()~=0
	p.name = r:readString()
	p.showingInfo = {}
	for i=1,showingRangesCount do
		table.insert(p.showingInfo,{from=r:int32(), to=r:int32(), str=r:readString()})
	end
	p.critValueString = r:readString()
	p.img = r:readString(true)
	p.sound = r:readString(true)
	p.track = r:readString(true)
	p.starting = r:readString()
	p.starting = autoConvertNumber(p.starting)
--	print ('p.starting', p.starting)
--	p.starting = autoConvertNumber(r:readString())
	return p
end

local function parseParam(r)
	local p = {}
	p.min = r:int32()
	p.max = r:int32()
	r:int32()
	p.type = r:byte()
	r:int32()
	p.showWhenZero = r:byte()~=0
	p.critType = r:byte()
	p.active = r:byte()~=0
	local showingRangesCount = r:int32()
	p.isMoney = r:byte()~=0
	p.name = r:readString()
	p.showingInfo = {}
	for i=1,showingRangesCount do
		table.insert(p.showingInfo,{from=r:int32(), to=r:int32(), str=r:readString()})
	end
	p.critValueString = r:readString()
	p.starting = r:readString()
	return p
end

local function parseBase2(r, isQmm)
	local res = {strings={}}
	res.strings.ToStar = r:readString()
	if not isQmm then
		res.strings.Parsec = r:readString(true)
		res.strings.Artefact = r:readString(true)
	end
	res.strings.ToPlanet = r:readString()
	res.strings.Date = r:readString()
	res.strings.Money = r:readString()
	res.strings.FromPlanet = r:readString()
	res.strings.FromStar = r:readString()
	res.strings.Ranger = r:readString()
	res.locationsCount = r:int32()
	res.jumpsCount = r:int32()
	res.successText = r:readString()
	res.taskText = r:readString()
	if not isQmm then r:readString() end
	return res
end

local function parseLocationQmm(r, paramsCount)
	local loc = {}
	loc.dayPassed = r:int32() ~= 0
	loc.locX = r:int32()
	loc.locY = r:int32()
	loc.id = r:int32()
	loc.maxVisits = r:int32()
	loc.type = r:byte()

	loc.paramsChanges = {}
	for i = 1, paramsCount do
		loc.paramsChanges[i] = {
			change = 0,
			showingType = 0,
			isChangePercentage = false,
			isChangeValue = false,
			isChangeFormula = false,
			changingFormula = "",
			critText = ""
		}
	end

	local affectedParamsCount = r:int32()
	for i = 1, affectedParamsCount do
		local paramN = r:int32()
		local change = r:int32()
		local showingType = r:byte()
		local changeType = r:byte()
		local changingFormula = r:readString()
		local critText = r:readString()
		local img = r:readString(true)
		local sound = r:readString(true)
		local track = r:readString(true)

		loc.paramsChanges[paramN] = {
			change = change,
			showingType = showingType,
			isChangePercentage = (changeType == 2),
			isChangeValue = (changeType == 0),
			isChangeFormula = (changeType == 3),
			changingFormula = changingFormula,
			critText = critText,
			img = img,
			sound = sound,
			track = track
		}
	end

	loc.texts = {}
	loc.media = {}
	local locationTexts = r:int32()
	for i = 1, locationTexts do
		table.insert(loc.texts, r:readString())
		table.insert(loc.media, {
				img = r:readString(true),
				sound = r:readString(true),
				track = r:readString(true)
			})
	end

	loc.isTextByFormula = r:byte() ~= 0
	loc.textSelectFormula = r:readString()

	return loc
end

local function parseLocation(r, paramsCount)
	local loc = {}
	loc.dayPassed = r:int32() ~= 0
	loc.locX = r:int32()
	loc.locY = r:int32()
	loc.id = r:int32()

	local isStarting = r:byte() ~= 0
	local isSuccess = r:byte() ~= 0
	local isFaily = r:byte() ~= 0
	local isFailyDeadly = r:byte() ~= 0
	local isEmpty = r:byte() ~= 0

	if isStarting then loc.type = 1
	elseif isEmpty then loc.type = 2
	elseif isSuccess then loc.type = 3
	elseif isFaily then loc.type = 4
	elseif isFailyDeadly then loc.type = 5
	else loc.type = 0 end

	loc.paramsChanges = {}
	for i = 1, paramsCount do
		r:seek(12)
		local change = r:int32()
		local showingType = r:byte()
		r:seek(4)
		local isChangePercentage = r:byte() ~= 0
		local isChangeValue = r:byte() ~= 0
		local isChangeFormula = r:byte() ~= 0
		local changingFormula = r:readString()
		r:seek(10)
		local critText = r:readString()
		loc.paramsChanges[i] = {
			change = change,
			showingType = showingType,
			isChangePercentage = isChangePercentage,
			isChangeValue = isChangeValue,
			isChangeFormula = isChangeFormula,
			changingFormula = changingFormula,
			critText = critText
		}
	end

	loc.texts = {}
	loc.media = {}
	for i = 1, LOCATION_TEXTS do
		table.insert(loc.texts, r:readString())
		loc.media[i] = {}
	end

	loc.isTextByFormula = r:byte() ~= 0
	r:seek(4)
	r:readString()
	r:readString()
	loc.textSelectFormula = r:readString()
	loc.maxVisits = 0

	return loc
end

local function parseJumpQmm(r, paramsCount, params)
	local jmp = {}
	jmp.priority = r:float64()
	jmp.dayPassed = r:int32() ~= 0
	jmp.id = r:int32()
	jmp.fromLocationId = r:int32()
	jmp.toLocationId = r:int32()
	jmp.alwaysShow = r:byte() ~= 0
	jmp.jumpingCountLimit = r:int32()
	jmp.showingOrder = r:int32()

	jmp.paramsChanges = {}
	jmp.paramsConditions = {}

	for i = 1, paramsCount do
		jmp.paramsChanges[i] = {
			change = 0,
			showingType = 0,
			isChangePercentage = false,
			isChangeValue = false,
			isChangeFormula = false,
			changingFormula = "",
			critText = ""
		}
		jmp.paramsConditions[i] = {
			mustFrom = params[i].min,
			mustTo = params[i].max,
			mustEqualValues = {},
			mustEqualValuesEqual = false,
			mustModValues = {},
			mustModValuesMod = false
		}
	end

	local affectedConditionsParamsCount = r:int32()
	for i = 1, affectedConditionsParamsCount do
		local paramId = r:int32()
		local mustFrom = r:int32()
		local mustTo = r:int32()
		local mustEqualValuesCount = r:int32()
		local mustEqualValuesEqual = r:byte() ~= 0
		local mustEqualValues = {}
		for j = 1, mustEqualValuesCount do
			table.insert(mustEqualValues, r:int32())
		end
		local mustModValuesCount = r:int32()
		local mustModValuesMod = r:byte() ~= 0
		local mustModValues = {}
		for j = 1, mustModValuesCount do
			table.insert(mustModValues, r:int32())
		end

		jmp.paramsConditions[paramId] = {
			mustFrom = mustFrom,
			mustTo = mustTo,
			mustEqualValues = mustEqualValues,
			mustEqualValuesEqual = mustEqualValuesEqual,
			mustModValues = mustModValues,
			mustModValuesMod = mustModValuesMod
		}
	end

	local affectedChangeParamsCount = r:int32()
	for i = 1, affectedChangeParamsCount do
		local paramId = r:int32()
		local change = r:int32()
		local showingType = r:byte()
		local changingType = r:byte()
		local changingFormula = r:readString()
		local critText = r:readString()
		local img = r:readString(true)
		local sound = r:readString(true)
		local track = r:readString(true)

		jmp.paramsChanges[paramId] = {
			change = change,
			showingType = showingType,
			isChangePercentage = (changingType == 2),
			isChangeValue = (changingType == 0),
			isChangeFormula = (changingType == 3),
			changingFormula = changingFormula,
			critText = critText,
			img = img,
			sound = sound,
			track = track
		}
	end

	jmp.formulaToPass = r:readString()
	jmp.text = r:readString()
	jmp.description = r:readString()
	jmp.img = r:readString(true)
	jmp.sound = r:readString(true)
	jmp.track = r:readString(true)

	return jmp
end

local function parseJump(r, paramsCount)
	local jmp = {}
	jmp.priority = r:float64()
	jmp.dayPassed = r:int32() ~= 0
	jmp.id = r:int32()
	jmp.fromLocationId = r:int32()
	jmp.toLocationId = r:int32()
	r:seek(1)
	jmp.alwaysShow = r:byte() ~= 0
	jmp.jumpingCountLimit = r:int32()
	jmp.showingOrder = r:int32()

	jmp.paramsChanges = {}
	jmp.paramsConditions = {}

	for i = 1, paramsCount do
		r:seek(4)
		local mustFrom = r:int32()
		local mustTo = r:int32()
		local change = r:int32()
		local showingType = r:int32()
		r:seek(1)
		local isChangePercentage = r:byte() ~= 0
		local isChangeValue = r:byte() ~= 0
		local isChangeFormula = r:byte() ~= 0
		local changingFormula = r:readString()

		local mustEqualValuesCount = r:int32()
		local mustEqualValuesEqual = r:byte() ~= 0
		local mustEqualValues = {}
		for j = 1, mustEqualValuesCount do
			table.insert(mustEqualValues, r:int32())
		end

		local mustModValuesCount = r:int32()
		local mustModValuesMod = r:byte() ~= 0
		local mustModValues = {}
		for j = 1, mustModValuesCount do
			table.insert(mustModValues, r:int32())
		end

		local critText = r:readString()

		jmp.paramsChanges[i] = {
			change = change,
			showingType = showingType,
			isChangePercentage = isChangePercentage,
			isChangeValue = isChangeValue,
			isChangeFormula = isChangeFormula,
			changingFormula = changingFormula,
			critText = critText
		}

		jmp.paramsConditions[i] = {
			mustFrom = mustFrom,
			mustTo = mustTo,
			mustEqualValues = mustEqualValues,
			mustEqualValuesEqual = mustEqualValuesEqual,
			mustModValues = mustModValues,
			mustModValuesMod = mustModValuesMod
		}
	end

	jmp.formulaToPass = r:readString()
	jmp.text = r:readString()
	jmp.description = r:readString()

	return jmp
end

local function parse(data)
	local r = Reader:new(data)
	local header = r:int32()
	print(string.format("Header: %d", header))

	local base = parseBase(r, header)
	print(string.format("Params count: %d", base.paramsCount))

	local isQmm = (header==HEADER_QMM_6 or header==HEADER_QMM_7 or header==HEADER_QMM_7_WITH_OLD_TGE_BEHAVIOUR)

	local params = {}
	for i=1,base.paramsCount do
		table.insert(params, isQmm and parseParamQmm(r) or parseParam(r))
	end
	print(string.format("Parsed %d parameters", #params))

	local base2 = parseBase2(r, isQmm)
	print(string.format("Locations: %d, Jumps: %d", base2.locationsCount, base2.jumpsCount))

	local locations = {}
	for i=1,base2.locationsCount do
		table.insert(locations, isQmm and parseLocationQmm(r, base.paramsCount) or parseLocation(r, base.paramsCount))
	end
	print(string.format("Parsed %d locations", #locations))

	local jumps = {}
	for i=1,base2.jumpsCount do
		table.insert(jumps, isQmm and parseJumpQmm(r, base.paramsCount, params) or parseJump(r, base.paramsCount))
	end
	print(string.format("Parsed %d jumps", #jumps))

	return {
		header=header,
		base=base,
		params=params,
		base2=base2,
		locations=locations,
		jumps=jumps
	}
end

---------------------------------------------




-- check quest connectivity
local function validateQuest(quest)
	local locationMap = {}
	local errors = {}
	local linksFrom = {}
	local linksTo = {}

	-- collect location ids
	for _, loc in ipairs(quest.locations or {}) do
		locationMap[loc.id] = true
		linksFrom[loc.id] = 0
		linksTo[loc.id] = 0
	end

	-- check jumps
	for _, jmp in ipairs(quest.jumps or {}) do
		local fromExists = locationMap[jmp.fromLocationId]
		local toExists = locationMap[jmp.toLocationId]

		if not fromExists then
			table.insert(errors, string.format(
				"jump %d: fromLocationId=%d does not exist",
				jmp.id, jmp.fromLocationId
			))
		else
			linksFrom[jmp.fromLocationId] = (linksFrom[jmp.fromLocationId] or 0) + 1
		end

		if not toExists then
			table.insert(errors, string.format(
				"jump %d: toLocationId=%d does not exist",
				jmp.id, jmp.toLocationId
			))
		else
			linksTo[jmp.toLocationId] = (linksTo[jmp.toLocationId] or 0) + 1
		end
	end

	-- find isolated locations
	for _, loc in ipairs(quest.locations or {}) do
		local fromCount = linksFrom[loc.id] or 0
		local toCount = linksTo[loc.id] or 0

		if fromCount == 0 and toCount == 0 then
			table.insert(errors, string.format(
				"location [L%d] (%s) is isolated (no incoming/outgoing jumps)",
				loc.id, loc.texts and loc.texts[1] and loc.texts[1]:sub(1, 30) or "no text"
			))
		elseif fromCount == 0 then
			table.insert(errors, string.format(
				"location [L%d] has no outgoing jumps", loc.id
			))
		elseif toCount == 0 then
			table.insert(errors, string.format(
				"location [L%d] has no incoming jumps", loc.id
			))
		end
	end

	-- report
	if #errors > 0 then
		print("\nvalidation errors found:")
		for _, err in ipairs(errors) do
			print("  - " .. err)
		end
	else
		print("\nno connectivity errors detected ✅")
	end
end


-- find unused (unreachable) locations starting from type=1
local function findUnusedLocations(quest)
	-- build map of jumps
	local jumpsFrom = {}
	for _, jmp in ipairs(quest.jumps or {}) do
		local from = jmp.fromLocationId
		local to = jmp.toLocationId
		if from and to then
			jumpsFrom[from] = jumpsFrom[from] or {}
			table.insert(jumpsFrom[from], to)
		end
	end

	-- find all start locations (type = 1)
	local startIds = {}
	for _, loc in ipairs(quest.locations or {}) do
		if loc.type == 1 then
			table.insert(startIds, loc.id)
		end
	end

	-- recursive search
	local visited = {}
	local function visit(id)
		if visited[id] then return end
		visited[id] = true
		local nextList = jumpsFrom[id]
		if nextList then
			for _, toId in ipairs(nextList) do
				visit(toId)
			end
		end
	end

	-- start traversal from each start location
	for _, sid in ipairs(startIds) do
		visit(sid)
	end

	-- collect unused
	local unused = {}
	for _, loc in ipairs(quest.locations or {}) do
		if not visited[loc.id] then
			table.insert(unused, loc)
		end
	end

	-- report
	if #unused == 0 then
		print("\nno unused locations found ✅")
	else
		print("\nunused locations:")
		for _, loc in ipairs(unused) do
			local title = loc.texts and loc.texts[1] or "(no text)"
			print(string.format("  - id=%d  type=%s  %s", loc.id, tostring(loc.type), title))
		end
	end

	return unused, visited
end

-- find unreachable locations (not connected to any start location)
local function findUnreachableLocations(quest)
	if not quest or not quest.locations or not quest.jumps then
		print("invalid quest structure")
		return
	end

	-- build map of jumps by fromLocationId
	local jumpMap = {}
	for _, jmp in ipairs(quest.jumps) do
		if jmp.fromLocationId then
			jumpMap[jmp.fromLocationId] = jumpMap[jmp.fromLocationId] or {}
			table.insert(jumpMap[jmp.fromLocationId], jmp.toLocationId)
		end
	end

	-- find all start locations
	local startIds = {}
	for _, loc in ipairs(quest.locations) do
		if loc.type == 1 or loc.isStarting == true then
			table.insert(startIds, loc.id)
		end
	end

	if #startIds == 0 then
		print("⚠️  no start locations found")
		return
	end

	-- recursive dfs
	local visited = {}
	local function visit(id)
		if visited[id] then return end
		visited[id] = true
		local nextJumps = jumpMap[id]
		if nextJumps then
			for _, toId in ipairs(nextJumps) do
				visit(toId)
			end
		end
	end

	-- start traversal
	for _, id in ipairs(startIds) do
		visit(id)
	end

	-- find unreachable locations
	local unreachable = {}
	for _, loc in ipairs(quest.locations) do
		if not visited[loc.id] then
			table.insert(unreachable, loc)
		end
	end

	-- report
	if #unreachable > 0 then
		print("\nunreachable locations found:")
		for _, loc in ipairs(unreachable) do
			print(string.format("  - id=%d  (%s)", loc.id, loc.texts and loc.texts[1] or "no text"))
		end
	else
		print("\nall locations are reachable ✅")
	end
end

-- find all unique paths between two locations, sorted by length
local function findAllPathsSorted(quest, fromId, toId)
	-- build quick access map: fromLocationId -> {toLocationId, ...}
	local jumpsFrom = {}
	for _, jmp in ipairs(quest.jumps or {}) do
		if jmp.fromLocationId and jmp.toLocationId then
			jumpsFrom[jmp.fromLocationId] = jumpsFrom[jmp.fromLocationId] or {}
			table.insert(jumpsFrom[jmp.fromLocationId], jmp.toLocationId)
		end
	end

	local allPaths = {}

	-- recursive depth-first search
	local function dfs(current, path, visited)
		if visited[current] then return end -- avoid cycles
		table.insert(path, current)
		visited[current] = true

		if current == toId then
			table.insert(allPaths, {table.unpack(path)})
		else
			local nextList = jumpsFrom[current]
			if nextList then
				for _, nextId in ipairs(nextList) do
					dfs(nextId, path, visited)
				end
			end
		end

		-- backtrack
		visited[current] = nil
		table.remove(path)
	end

	dfs(fromId, {}, {})

	-- remove duplicates
	local unique = {}
	local finalPaths = {}
	for _, path in ipairs(allPaths) do
		local key = table.concat(path, "-")
		if not unique[key] then
			unique[key] = true
			table.insert(finalPaths, path)
		end
	end

	-- sort by path length (shortest first)
	table.sort(finalPaths, function(a, b)
		return #a < #b
	end)

	-- print summary
	print(string.format("\npaths from %d to %d:", fromId, toId))
	if #finalPaths == 0 then
		print("  no path found ❌")
	else
		for i, path in ipairs(finalPaths) do
			print(string.format("  path %d (%d steps): %s", i, #path - 1, table.concat(path, " → ")))
		end
		print(string.format("\nfound %d unique path(s) ✅", #finalPaths))
	end

	return finalPaths
end




---------------------------------------------

-- escape string for lua output
local function escapeString(str)
	if not str then return "nil" end
	str = str:gsub("\\","\\\\"):gsub('"','\\"'):gsub("\n","\\n"):gsub("\r","\\r"):gsub("\t","\\t")
	return '"'..str..'"'
end

-- helper to write array of numbers
local function arrayToString(arr)
	if #arr == 0 then return "{}" end
	local parts = {}
	for _,v in ipairs(arr) do
		table.insert(parts, tostring(v))
	end
	return "{" .. table.concat(parts, ",") .. "}"
end

-- check if table is empty
local function isTableEmpty(t)
	if type(t) ~= "table" then return true end
	return next(t) == nil
end

-- check if table (including nested subtables) is empty
-- treats tables with only empty strings or empty subtables as empty too
local function isTableEmptyDeep(t)
	if type(t) ~= "table" then return false end
	local empty = true

	for k, v in pairs(t) do
		if type(v) == "table" then
			-- recursively check subtable
			if not isTableEmptyDeep(v) then
				empty = false
				return false
			end
		elseif v ~= "" then
--			print (k, 'value: ', v)
			empty = false
			return false
		end
	end

	return true
end




---------------------------------------------

local function mergeBaseProperties (lines, q)
	-- header
	lines[#lines+1] = "	header = " .. q.header .. ","

	-- base properties
	lines[#lines+1] = "	givingRace = " .. q.base.givingRace .. ","
	lines[#lines+1] = "	whenDone = " .. q.base.whenDone .. ","
	lines[#lines+1] = "	planetRace = " .. q.base.planetRace .. ","
	lines[#lines+1] = "	playerCareer = " .. q.base.playerCareer .. ","
	lines[#lines+1] = "	playerRace = " .. q.base.playerRace .. ","
	lines[#lines+1] = "	reputationChange = " .. q.base.reputationChange .. ","
	lines[#lines+1] = "	screenSizeX = " .. q.base.screenSizeX .. ","
	lines[#lines+1] = "	screenSizeY = " .. q.base.screenSizeY .. ","
	lines[#lines+1] = "	widthSize = " .. q.base.widthSize .. ","
	lines[#lines+1] = "	heightSize = " .. q.base.heightSize .. ","
	lines[#lines+1] = "	defaultJumpCountLimit = " .. q.base.defaultJumpCountLimit .. ","
	lines[#lines+1] = "	hardness = " .. q.base.hardness .. ","

	if q.base.majorVersion then
		lines[#lines+1] = "	majorVersion = " .. q.base.majorVersion .. ","
		lines[#lines+1] = "	minorVersion = " .. q.base.minorVersion .. ","
	end
	if q.base.changeLogString then
		lines[#lines+1] = "	changeLogString = " .. escapeString(q.base.changeLogString) .. ","
	end
end


local function mergeStrings (lines, q)
	-- strings
	lines[#lines+1] = "	strings = {"
	lines[#lines+1] = "		ToStar = " .. escapeString(q.base2.strings.ToStar) .. ","
	lines[#lines+1] = "		ToPlanet = " .. escapeString(q.base2.strings.ToPlanet) .. ","
	lines[#lines+1] = "		Date = " .. escapeString(q.base2.strings.Date) .. ","
	lines[#lines+1] = "		Money = " .. escapeString(q.base2.strings.Money) .. ","
	lines[#lines+1] = "		FromPlanet = " .. escapeString(q.base2.strings.FromPlanet) .. ","
	lines[#lines+1] = "		FromStar = " .. escapeString(q.base2.strings.FromStar) .. ","
	lines[#lines+1] = "		Ranger = " .. escapeString(q.base2.strings.Ranger) .. ","
	if q.base2.strings.Parsec then
		lines[#lines+1] = "		Parsec = " .. escapeString(q.base2.strings.Parsec) .. ","
	end
	if q.base2.strings.Artefact then
		lines[#lines+1] = "		Artefact = " .. escapeString(q.base2.strings.Artefact) .. ","
	end
	lines[#lines+1] = "	},"
	lines[#lines+1] = "	taskText = " .. escapeString(q.base2.taskText) .. ","
	lines[#lines+1] = "	successText = " .. escapeString(q.base2.successText) .. ","
end

local function mergeParams (lines, q)
	-- params - FULL VERSION
	lines[#lines+1] = "	-- amount params: " .. #q.params
	lines[#lines+1] = "	params = {"
	for id, p in ipairs(q.params) do
		lines[#lines+1] = "		{"
		lines[#lines+1] = '			index = "[p' .. id .. ']",'
		lines[#lines+1] = "			name = " .. escapeString(p.name) .. ","
		lines[#lines+1] = "			min = " .. p.min .. ","
		lines[#lines+1] = "			max = " .. p.max .. ","
		lines[#lines+1] = "			type = " .. p.type .. ","
		lines[#lines+1] = "			showWhenZero = " .. tostring(p.showWhenZero) .. ","
		lines[#lines+1] = "			critType = " .. p.critType .. ","
		lines[#lines+1] = "			active = " .. tostring(p.active) .. ","
		lines[#lines+1] = "			isMoney = " .. tostring(p.isMoney) .. ","
		if type (p.starting) == "string" then
			lines[#lines+1] = "			starting = " .. escapeString(p.starting) .. ","
		else
			lines[#lines+1] = "			starting = " .. p.starting .. ","
		end
		if p.critValueString and p.critValueString ~= "" then 
			lines[#lines+1] = "			critValueString = " .. escapeString(p.critValueString) .. ","
		end
		if p.img and p.img ~= "" then lines[#lines+1] = "			img = " .. escapeString(p.img) .. "," end
		if p.sound and p.sound ~= ""	then lines[#lines+1] = "			sound = " .. escapeString(p.sound) .. "," end
		if p.track and p.track ~= ""	then lines[#lines+1] = "			track = " .. escapeString(p.track) .. "," end
		if #p.showingInfo > 0 then
			lines[#lines+1] = "			showingInfo = {"
			for _, si in ipairs(p.showingInfo) do
				lines[#lines+1] = "				{from=" .. si.from .. ", to=" .. si.to .. ", str=" .. escapeString(si.str) .. "},"
			end
			lines[#lines+1] = "			},"
		end
		lines[#lines+1] = "		},"
	end
	lines[#lines+1] = "	},"
end


-- merge paramsChanges block for location or jump
local function mergeParamsChangesUniversal(lines, obj, context)
	-- detect object type for clarity
	local objType = context or "unknown"
	local paramsChanges = obj.paramsChanges
--	lines[#lines+1] = "			paramsChanges = { -- for " .. objType .. ", amount: " .. #paramsChanges
	lines[#lines+1] = "			paramsChanges = { -- amount: " .. #paramsChanges

	for id, pch in ipairs(paramsChanges) do
		-- only output non-default changes
		if pch.change ~= 0 or pch.changingFormula ~= "" or pch.critText ~= "" then
			lines[#lines+1] = "				{"
			lines[#lines+1] = '					index = "[p' .. id .. ']",'
			lines[#lines+1] = "					change = " .. pch.change .. ","
			lines[#lines+1] = "					showingType = " .. pch.showingType .. ","
			lines[#lines+1] = "					isChangePercentage = " .. tostring(pch.isChangePercentage) .. ","
			lines[#lines+1] = "					isChangeValue = " .. tostring(pch.isChangeValue) .. ","
			lines[#lines+1] = "					isChangeFormula = " .. tostring(pch.isChangeFormula) .. ","
			if pch.changingFormula ~= "" then
				lines[#lines+1] = "					changingFormula = " .. escapeString(pch.changingFormula) .. ","
			end
			if pch.critText ~= "" then
				lines[#lines+1] = "					critText = " .. escapeString(pch.critText) .. ","
			end
			if pch.img and pch.img ~= "" then lines[#lines+1] = "					img = " .. escapeString(pch.img) .. "," end
			if pch.sound and pch.sound ~= ""	then lines[#lines+1] = "					sound = " .. escapeString(pch.sound) .. "," end
			if pch.track and pch.track ~= ""	then lines[#lines+1] = "					track = " .. escapeString(pch.track) .. "," end
			lines[#lines+1] = "				},"
		elseif false then
			-- empty disabled
			lines[#lines+1] = '				{}, -- [p' .. id .. ']'
		end
	end

	lines[#lines+1] = "			},"
end


local function mergeParamsChanges (lines, loc)
	-- paramsChanges

	lines[#lines+1] = "			paramsChanges = { -- location, amount: " .. #loc.paramsChanges
	for id, pc in ipairs(loc.paramsChanges) do
		-- only output non-default changes
		if pc.change ~= 0 or pc.changingFormula ~= "" or pc.critText ~= "" then
			lines[#lines+1] = "				{"
			lines[#lines+1] = '					index = "[p' .. id .. ']",'
			lines[#lines+1] = "					change = " .. pc.change .. ","
			lines[#lines+1] = "					showingType = " .. pc.showingType .. ","
			lines[#lines+1] = "					isChangePercentage = " .. tostring(pc.isChangePercentage) .. ","
			lines[#lines+1] = "					isChangeValue = " .. tostring(pc.isChangeValue) .. ","
			lines[#lines+1] = "					isChangeFormula = " .. tostring(pc.isChangeFormula) .. ","
			if pc.changingFormula ~= "" then
				lines[#lines+1] = "					changingFormula = " .. escapeString(pc.changingFormula) .. ","
			end
			if pc.critText ~= "" then
				lines[#lines+1] = "					critText = " .. escapeString(pc.critText) .. ","
			end
			if pc.img then lines[#lines+1] = "					img = " .. escapeString(pc.img) .. "," end
			if pc.sound then lines[#lines+1] = "					sound = " .. escapeString(pc.sound) .. "," end
			if pc.track then lines[#lines+1] = "					track = " .. escapeString(pc.track) .. "," end
			lines[#lines+1] = "				},"
		elseif false then
			-- empty disabled
			lines[#lines+1] = '				{}, -- [p' .. id .. ']'
		end
	end
	lines[#lines+1] = "			},"
end

local lotTypeStr = {
	[1] = 'isStarting',
	[2] = 'isEmpty',
	[3] = 'isSuccess',
	[4] = 'isFaily',
	[5] = 'isFailyDeadly',
	[0] = 'undefined',
	}


local function mergeLocations (lines, q)
	-- locations - FULL VERSION
	lines[#lines+1] = "	locations = {"
	for id, loc in ipairs(q.locations) do
		lines[#lines+1] = "		{"
		lines[#lines+1] = "			index = " .. id .. ", -- number"
		lines[#lines+1] = "			id = " .. loc.id .. ", -- location [L".. loc.id .."]"
		lines[#lines+1] = "			type = " .. loc.type .. ", -- " .. lotTypeStr[loc.type]
		lines[#lines+1] = "			locX = " .. loc.locX .. ","
		lines[#lines+1] = "			locY = " .. loc.locY .. ","
		lines[#lines+1] = "			maxVisits = " .. (loc.maxVisits or 0) .. ","
		lines[#lines+1] = "			dayPassed = " .. tostring(loc.dayPassed) .. ","
		lines[#lines+1] = "			isTextByFormula = " .. tostring(loc.isTextByFormula) .. ","
		lines[#lines+1] = "			textSelectFormula = " .. escapeString(loc.textSelectFormula) .. ","

		-- texts
		lines[#lines+1] = "			texts = {"
		for _, text in ipairs(loc.texts) do
			lines[#lines+1] = "				" .. escapeString(text) .. ","
		end
		lines[#lines+1] = "			},"

		-- media
--		if #loc.media > 0 then
		local isEmpty = isTableEmptyDeep(loc.media)
		if not isEmpty then
--			lines[#lines+1] = " -- not empty media: "
			lines[#lines+1] = "			media = {"
			for _, m in ipairs(loc.media) do
				lines[#lines+1] = "				{"
				if m.img and m.img ~= "" then lines[#lines+1] = "					img = " .. escapeString(m.img) .. "," end
				if m.sound and m.sound ~= ""	then lines[#lines+1] = "					sound = " .. escapeString(m.sound) .. "," end
				if m.track and m.track ~= ""	then lines[#lines+1] = "					track = " .. escapeString(m.track) .. "," end
				lines[#lines+1] = "				},"
			end
			lines[#lines+1] = "			},"
		else
			lines[#lines+1] = "			-- no media"
		end

--		mergeParamsChanges (lines, loc)
		mergeParamsChangesUniversal (lines, loc, "locations")

		lines[#lines+1] = "		},"
	end
	lines[#lines+1] = "	},"
end

local function mergeParamsConditionsJumps (lines, jmp)
	-- paramsConditions
	local anyCondition = false
	for id, pcond in ipairs(jmp.paramsConditions) do
		local hasCondition = #pcond.mustEqualValues > 0 or #pcond.mustModValues > 0
		if hasCondition then
			anyCondition = true
			break
		end
	end
	
	if not anyCondition then
		return
	end
	
	lines[#lines+1] = "			paramsConditions = { -- " .. #jmp.paramsConditions
	for id, pcond in ipairs(jmp.paramsConditions) do
		-- only output non-default conditions
		local hasCondition = #pcond.mustEqualValues > 0 or #pcond.mustModValues > 0
		if hasCondition then
--		if true then
--			lines[#lines+1] = "				-- " .. #
			lines[#lines+1] = "				{"
			lines[#lines+1] = '					index = "[p' .. id .. ']",'
			lines[#lines+1] = "					mustFrom = " .. pcond.mustFrom .. ","
			lines[#lines+1] = "					mustTo = " .. pcond.mustTo .. ","
			if #pcond.mustEqualValues > 0 then
				lines[#lines+1] = "					mustEqualValues = " .. arrayToString(pcond.mustEqualValues) .. ","
				lines[#lines+1] = "					mustEqualValuesEqual = " .. tostring(pcond.mustEqualValuesEqual) .. ","
			end
			if #pcond.mustModValues > 0 then
				lines[#lines+1] = "					mustModValues = " .. arrayToString(pcond.mustModValues) .. ","
				lines[#lines+1] = "					mustModValuesMod = " .. tostring(pcond.mustModValuesMod) .. ","
			end
			lines[#lines+1] = "				},"
		elseif false then
			-- empty disabled
			lines[#lines+1] = '				{}, -- [p' .. id .. ']'
		end
	end
	lines[#lines+1] = "			},"
end

local function mergeParamsChangesJumps (lines, jmp)

	-- paramsChanges
	lines[#lines+1] = "			paramsChanges = {"
	for id, pch in ipairs(jmp.paramsChanges) do
		-- only output non-default changes
		if pch.change ~= 0 or pch.changingFormula ~= "" or pch.critText ~= "" then
			lines[#lines+1] = "				{"
			lines[#lines+1] = '					index = "[p' .. id .. ']",'
			lines[#lines+1] = "					change = " .. pch.change .. ","
			lines[#lines+1] = "					showingType = " .. pch.showingType .. ","
			lines[#lines+1] = "					isChangePercentage = " .. tostring(pch.isChangePercentage) .. ","
			lines[#lines+1] = "					isChangeValue = " .. tostring(pch.isChangeValue) .. ","
			lines[#lines+1] = "					isChangeFormula = " .. tostring(pch.isChangeFormula) .. ","
			if pch.changingFormula ~= "" then
				lines[#lines+1] = "					changingFormula = " .. escapeString(pch.changingFormula) .. ","
			end
			if pch.critText ~= "" then
				lines[#lines+1] = "					critText = " .. escapeString(pch.critText) .. ","
			end
			if pch.img then lines[#lines+1] = "					img = " .. escapeString(pch.img) .. "," end
			if pch.sound then lines[#lines+1] = "					sound = " .. escapeString(pch.sound) .. "," end
			if pch.track then lines[#lines+1] = "					track = " .. escapeString(pch.track) .. "," end
			lines[#lines+1] = "				},"
		elseif false then
			-- empty disabled
			lines[#lines+1] = '				{}, -- [p' .. id .. ']'
--				lines[#lines+1] = "				{},"
		end
	end
	lines[#lines+1] = "			},"
end

local function mergeJumps (lines, q)
	-- jumps - FULL VERSION
	lines[#lines+1] = "	jumps = {"
	for id, jmp in ipairs(q.jumps) do
		lines[#lines+1] = "		{"
		lines[#lines+1] = "			index = " .. id .. ", -- number"
		lines[#lines+1] = "			id = " .. jmp.id .. ", -- jump [J".. jmp.id .."]"
		lines[#lines+1] = "			fromLocationId = " .. jmp.fromLocationId .. ", -- from[L"..jmp.fromLocationId.."]"
		lines[#lines+1] = "			toLocationId = " .. jmp.toLocationId .. ", -- to[L"..jmp.toLocationId.."]"
		lines[#lines+1] = "			priority = " .. jmp.priority .. ","
		lines[#lines+1] = "			dayPassed = " .. tostring(jmp.dayPassed) .. ","
		lines[#lines+1] = "			alwaysShow = " .. tostring(jmp.alwaysShow) .. ","
		lines[#lines+1] = "			jumpingCountLimit = " .. jmp.jumpingCountLimit .. ","
		lines[#lines+1] = "			showingOrder = " .. jmp.showingOrder .. ","
		lines[#lines+1] = "			text = " .. escapeString(jmp.text) .. ","
		lines[#lines+1] = "			description = " .. escapeString(jmp.description) .. ","
		lines[#lines+1] = "			formulaToPass = " .. escapeString(jmp.formulaToPass) .. ","
		if jmp.img and jmp.img ~= "" then lines[#lines+1] = "			img = " .. escapeString(jmp.img) .. "," end
		if jmp.sound and jmp.sound ~= ""  then lines[#lines+1] = "			sound = " .. escapeString(jmp.sound) .. "," end
		if jmp.track and jmp.track ~= ""  then lines[#lines+1] = "			track = " .. escapeString(jmp.track) .. "," end

		mergeParamsConditionsJumps (lines, jmp)

		mergeParamsChangesUniversal (lines, jmp, "jumps")

		lines[#lines+1] = "		},"
	end
	lines[#lines+1] = "	},"
end
---------------------------------------------

-- convert parsed quest to lua table text - COMPLETE VERSION
local function convertToLua(q)
	local lines = {}
	lines[#lines+1] = "return {"


	mergeBaseProperties (lines, q)
	mergeStrings (lines, q)
	mergeParams (lines, q)
	mergeLocations (lines, q)
	mergeJumps (lines, q)

	lines[#lines+1] = "}"
	return table.concat(lines, "\n")
end

-- main conversion function
local function convertQmmToLua()
	print("QMM to Lua Converter - Full Version")
	print("Input: " .. qmmFile)
	print("Output: " .. luaFile)
	print("")

	local f = assert(io.open(qmmFile, "rb"), "cannot open " .. qmmFile)
	local data = f:read("*a")
	f:close()

	local quest = parse(data)
--	validateQuest(quest)
--	findUnusedLocations(quest)
--	findUnreachableLocations(quest)
--	findAllPathsSorted(quest, 236, 4)

	print("\nConverting to Lua (with ALL data)...")
	local luaText = convertToLua(quest)

	local f2 = assert(io.open(luaFile, "w"), "cannot write to " .. luaFile)
	f2:write(luaText)
	f2:close()

	print("Conversion complete!")
	print("File size: " .. #luaText .. " bytes")
end

convertQmmToLua()