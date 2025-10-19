-- qm to lua converter
-- converts quest.qm binary format (old format) to quest.lua text format

-- get script directory and file paths
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local scriptDir = scriptPath:match("(.+)\\") or scriptPath:match("(.+)/")
local qmFile = scriptDir .. "\\" .. "quest.qm"
local luaFile = scriptDir .. "\\" .. "quest.lua"

local LOCATION_TEXTS = 10

-- header constants
local HEADER_QM_2 = 0x423a35d2  -- 24 parameters
local HEADER_QM_3 = 0x423a35d3  -- 48 parameters
local HEADER_QM_4 = 0x423a35d4  -- 96 parameters

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
-- QM (old format) parsing functions
--------------------------------------------

local function parseBase(r, header)
	local res = {}
	
	local paramsCount = (header==HEADER_QM_3) and 48 
		or (header==HEADER_QM_2) and 24 
		or (header==HEADER_QM_4) and 96 
		or 0
	
	if paramsCount == 0 then
		error("Unknown header: " .. tostring(header))
	end
	
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
	
	return res
end

-- detect if a string can be safely converted to number
local function autoConvertNumber(val)
	if type(val) == "string" and val:match("^%-?%d+%.?%d*$") then
		local num = tonumber(val)
		if num then return num end
	end
	return val
end

local function parseParam(r)
	local p = {}
	p.min = r:int32()
	p.max = r:int32()
	r:int32()  -- unknown
	p.type = r:byte()
	r:int32()  -- unknown
	p.showWhenZero = r:byte()~=0
	p.critType = r:byte()
	p.active = r:byte()~=0
	local showingRangesCount = r:int32()
	p.isMoney = r:byte()~=0
	p.name = r:readString()
	p.showingInfo = {}
	for i=1,showingRangesCount do
		table.insert(p.showingInfo,{
			from=r:int32(), 
			to=r:int32(), 
			str=r:readString()
		})
	end
	p.critValueString = r:readString()
	p.starting = autoConvertNumber(r:readString())
	-- old format doesn't have img/sound/track in params
	p.img = nil
	p.sound = nil
	p.track = nil
	return p
end

local function parseBase2(r)
	local res = {strings={}}
	res.strings.ToStar = r:readString()
	res.strings.Parsec = r:readString(true)
	res.strings.Artefact = r:readString(true)
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
	r:readString()  -- unknown text
	return res
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
			critText = critText,
			-- old format doesn't have img/sound/track
			img = nil,
			sound = nil,
			track = nil
		}
	end

	loc.texts = {}
	loc.media = {}
	for i = 1, LOCATION_TEXTS do
		table.insert(loc.texts, r:readString())
		-- old format doesn't have media
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
			critText = critText,
			-- old format doesn't have img/sound/track
			img = nil,
			sound = nil,
			track = nil
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
	-- old format doesn't have img/sound/track
	jmp.img = nil
	jmp.sound = nil
	jmp.track = nil

	return jmp
end

local function parse(data)
	local r = Reader:new(data)
	local header = r:int32()
	print(string.format("Header: 0x%x (%d)", header, header))

	local base = parseBase(r, header)
	print(string.format("Params count: %d", base.paramsCount))

	local params = {}
	for i=1,base.paramsCount do
		table.insert(params, parseParam(r))
	end
	print(string.format("Parsed %d parameters", #params))

	local base2 = parseBase2(r)
	print(string.format("Locations: %d, Jumps: %d", base2.locationsCount, base2.jumpsCount))

	local locations = {}
	for i=1,base2.locationsCount do
		table.insert(locations, parseLocation(r, base.paramsCount))
	end
	print(string.format("Parsed %d locations", #locations))

	local jumps = {}
	for i=1,base2.jumpsCount do
		table.insert(jumps, parseJump(r, base.paramsCount))
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
-- Conversion to Lua
---------------------------------------------

local function escapeString(str)
	if not str then return "nil" end
	str = str:gsub("\\","\\\\"):gsub('"','\\"'):gsub("\n","\\n"):gsub("\r","\\r"):gsub("\t","\\t")
	return '"'..str..'"'
end

local function arrayToString(arr)
	if #arr == 0 then return "{}" end
	local parts = {}
	for _,v in ipairs(arr) do
		table.insert(parts, tostring(v))
	end
	return "{" .. table.concat(parts, ",") .. "}"
end

local function isTableEmpty(t)
	if type(t) ~= "table" then return true end
	return next(t) == nil
end

local function isTableEmptyDeep(t)
	if type(t) ~= "table" then return false end
	local empty = true

	for k, v in pairs(t) do
		if type(v) == "table" then
			if not isTableEmptyDeep(v) then
				empty = false
				return false
			end
		elseif v ~= "" then
			empty = false
			return false
		end
	end

	return true
end

local defaultParam = {
	type = 0,
	showWhenZero = true,
	critType = 0,
	active = true,
	isMoney = false,
	critValueString = "",
}

local defaultParamChange = {
	change = 0,
	showingType = 0,
	isChangePercentage = false,
	isChangeValue = false,
	isChangeFormula = true,
}

local defaultLocation = {
	type = 2,
	maxVisits = 0,
	dayPassed = false,
	isTextByFormula = false,
	textSelectFormula = "",
}

local defaultJump = {
	priority = 1.0,
	dayPassed = false,
	alwaysShow = false,
	jumpingCountLimit = 0,
	showingOrder = 5,
	text = "",
	description = "",
	formulaToPass = "",
}

local showingTypeStr = {
	[0] = "don't change",
	[1] = "show",
	[2] = "hide",
}

local lotTypeStr = {
	[1] = 'isStarting',
	[2] = 'isEmpty',
	[3] = 'isSuccess',
	[4] = 'isFaily',
	[5] = 'isFailyDeadly',
	[0] = 'undefined',
}

local function mergeBaseProperties(lines, q)
	lines[#lines+1] = "	header = " .. q.header .. ","
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
end

local function mergeStrings(lines, q)
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

local function mergeParams(lines, q)
	lines[#lines+1] = "	-- amount params: " .. #q.params
	lines[#lines+1] = "	params = {"
	for id, p in ipairs(q.params) do
		lines[#lines+1] = "		{"
		lines[#lines+1] = '			index = "[p' .. id .. ']",'
		lines[#lines+1] = "			name = " .. escapeString(p.name) .. ","
		lines[#lines+1] = "			min = " .. p.min .. ","
		lines[#lines+1] = "			max = " .. p.max .. ","

		if p.type ~= defaultParam.type then
			lines[#lines+1] = "			type = " .. p.type .. ","
		end
		if p.showWhenZero ~= defaultParam.showWhenZero then
			lines[#lines+1] = "			showWhenZero = " .. tostring(p.showWhenZero) .. ","
		end
		if p.critType ~= defaultParam.critType then
			lines[#lines+1] = "			critType = " .. p.critType .. ","
		end
		if p.active ~= defaultParam.active then
			lines[#lines+1] = "			active = " .. tostring(p.active) .. ","
		end
		if p.isMoney ~= defaultParam.isMoney then
			lines[#lines+1] = "			isMoney = " .. tostring(p.isMoney) .. ","
		end
		if p.critValueString ~= defaultParam.critValueString then 
			lines[#lines+1] = "			critValueString = " .. escapeString(p.critValueString) .. ","
		end

		if type(p.starting) == "string" then
			lines[#lines+1] = "			starting = " .. escapeString(p.starting) .. ","
		else
			lines[#lines+1] = "			starting = " .. p.starting .. ","
		end

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

local function mergeParamsChangesUniversal(lines, obj, context)
	local paramsChanges = obj.paramsChanges
	local hadAny = false
	lines[#lines+1] = "			paramsChanges = { -- amount: " .. #paramsChanges

	for id, pch in ipairs(paramsChanges) do
		local hasContent = (
			pch.change ~= 0 or
			(pch.changingFormula and pch.changingFormula ~= "") or
			(pch.critText and pch.critText ~= "")
		)

		if hasContent then
			hadAny = true
			lines[#lines+1] = "				{"
			lines[#lines+1] = '					index = "[p' .. id .. ']",'

			if pch.change ~= defaultParamChange.change then
				lines[#lines+1] = "					change = " .. pch.change .. ","
			end
			if pch.showingType ~= defaultParamChange.showingType then
				lines[#lines+1] = "					showingType = " .. pch.showingType .. ", -- " .. showingTypeStr[pch.showingType]
			end
			if pch.isChangePercentage ~= defaultParamChange.isChangePercentage then
				lines[#lines+1] = "					isChangePercentage = " .. tostring(pch.isChangePercentage) .. ","
			end
			if pch.isChangeValue ~= defaultParamChange.isChangeValue then
				lines[#lines+1] = "					isChangeValue = " .. tostring(pch.isChangeValue) .. ","
			end
			if pch.isChangeFormula ~= defaultParamChange.isChangeFormula then
				lines[#lines+1] = "					isChangeFormula = " .. tostring(pch.isChangeFormula) .. ","
			end
			if pch.changingFormula ~= "" then
				lines[#lines+1] = "					changingFormula = " .. escapeString(pch.changingFormula) .. ","
			end
			if pch.critText ~= "" then
				lines[#lines+1] = "					critText = " .. escapeString(pch.critText) .. ","
			end
			lines[#lines+1] = "				},"
		end
	end

	if not hadAny then
		lines[#lines] = nil
	else
		lines[#lines+1] = "			},"
	end
end

local function mergeLocations(lines, q)
	lines[#lines+1] = "	locations = {"
	for id, loc in ipairs(q.locations) do
		lines[#lines+1] = "		{"
		lines[#lines+1] = "			index = " .. id .. ", -- number"
		lines[#lines+1] = "			id = " .. loc.id .. ", -- location [L".. loc.id .."]"
		lines[#lines+1] = "			type = " .. loc.type .. ", -- " .. lotTypeStr[loc.type]
		lines[#lines+1] = "			locX = " .. loc.locX .. ","
		lines[#lines+1] = "			locY = " .. loc.locY .. ","
		if loc.maxVisits ~= defaultLocation.maxVisits then
			lines[#lines+1] = "			maxVisits = " .. (loc.maxVisits or 0) .. ","
		end
		if loc.dayPassed ~= defaultLocation.dayPassed then
			lines[#lines+1] = "			dayPassed = " .. tostring(loc.dayPassed) .. ","
		end
		if loc.isTextByFormula ~= defaultLocation.isTextByFormula then
			lines[#lines+1] = "			isTextByFormula = " .. tostring(loc.isTextByFormula) .. ","
		end
		if loc.textSelectFormula ~= defaultLocation.textSelectFormula then
			lines[#lines+1] = "			textSelectFormula = " .. escapeString(loc.textSelectFormula) .. ","
		end

		if not isTableEmpty(loc.texts) then
			lines[#lines+1] = "			texts = {"
			for _, text in ipairs(loc.texts) do
				lines[#lines+1] = "				" .. escapeString(text) .. ","
			end
			lines[#lines+1] = "			},"
		end

		mergeParamsChangesUniversal(lines, loc, "locations")

		lines[#lines+1] = "		},"
	end
	lines[#lines+1] = "	},"
end

local function mergeParamsConditionsJumps(lines, jmp)
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
		local hasCondition = #pcond.mustEqualValues > 0 or #pcond.mustModValues > 0
		if hasCondition then
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
		end
	end
	lines[#lines+1] = "			},"
end

local function mergeJumps(lines, q)
	lines[#lines+1] = "	jumps = {"
	for id, jmp in ipairs(q.jumps) do
		lines[#lines+1] = "		{"
		lines[#lines+1] = "			index = " .. id .. ", -- number"
		lines[#lines+1] = "			id = " .. jmp.id .. ", -- jump [J".. jmp.id .."]"
		lines[#lines+1] = "			fromLocationId = " .. jmp.fromLocationId .. ", -- from[L"..jmp.fromLocationId.."]"
		lines[#lines+1] = "			toLocationId = " .. jmp.toLocationId .. ", -- to[L"..jmp.toLocationId.."]"
		if jmp.priority ~= defaultJump.priority then
			lines[#lines+1] = "			priority = " .. jmp.priority .. ","
		end
		if jmp.dayPassed ~= defaultJump.dayPassed then
			lines[#lines+1] = "			dayPassed = " .. tostring(jmp.dayPassed) .. ","
		end
		if jmp.alwaysShow ~= defaultJump.alwaysShow then
			lines[#lines+1] = "			alwaysShow = " .. tostring(jmp.alwaysShow) .. ","
		end
		if jmp.jumpingCountLimit ~= defaultJump.jumpingCountLimit then
			lines[#lines+1] = "			jumpingCountLimit = " .. jmp.jumpingCountLimit .. ","
		end
		if jmp.showingOrder ~= defaultJump.showingOrder then
			lines[#lines+1] = "			showingOrder = " .. jmp.showingOrder .. ","
		end
		if jmp.text ~= defaultJump.text then
			lines[#lines+1] = "			text = " .. escapeString(jmp.text) .. ","
		end
		if jmp.description ~= defaultJump.description then
			lines[#lines+1] = "			description = " .. escapeString(jmp.description) .. ","
		end
		if jmp.formulaToPass ~= defaultJump.formulaToPass then
			lines[#lines+1] = "			formulaToPass = " .. escapeString(jmp.formulaToPass) .. ","
		end

		mergeParamsConditionsJumps(lines, jmp)
		mergeParamsChangesUniversal(lines, jmp, "jumps")

		lines[#lines+1] = "		},"
	end
	lines[#lines+1] = "	},"
end

local function mergeDefaults(lines)
	lines[#lines+1] = "	 "
	lines[#lines+1] = "	defaultParam = {"
	lines[#lines+1] = "		type = " .. defaultParam.type .. ','
	lines[#lines+1] = "		showWhenZero = " .. tostring(defaultParam.showWhenZero) .. ','
	lines[#lines+1] = "		critType = " .. defaultParam.critType .. ','
	lines[#lines+1] = "		active = " .. tostring(defaultParam.active) .. ','
	lines[#lines+1] = "		isMoney = " .. tostring(defaultParam.isMoney) .. ','
	lines[#lines+1] = "		critValueString = " .. escapeString(defaultParam.critValueString) .. ','
	lines[#lines+1] = "	},"
	
	lines[#lines+1] = "	defaultParamChange = {"
	lines[#lines+1] = "		change = " .. defaultParamChange.change .. ','
	lines[#lines+1] = "		showingType = " .. defaultParamChange.showingType .. ", -- " .. showingTypeStr[defaultParamChange.showingType]
	lines[#lines+1] = "		isChangePercentage = " .. tostring(defaultParamChange.isChangePercentage) .. ','
	lines[#lines+1] = "		isChangeValue = " .. tostring(defaultParamChange.isChangeValue) .. ','
	lines[#lines+1] = "		isChangeFormula = " .. tostring(defaultParamChange.isChangeFormula) .. ','
	lines[#lines+1] = "	},"

	lines[#lines+1] = "	defaultLocation = {"
	lines[#lines+1] = "		type = " .. defaultLocation.type .. ','
	lines[#lines+1] = "		maxVisits = " .. defaultLocation.maxVisits .. ','
	lines[#lines+1] = "		dayPassed = " .. tostring(defaultLocation.dayPassed) .. ','
	lines[#lines+1] = "		isTextByFormula = " .. tostring(defaultLocation.isTextByFormula) .. ','
	lines[#lines+1] = "		textSelectFormula = " .. escapeString(defaultLocation.textSelectFormula) .. ','
	lines[#lines+1] = "	},"

	lines[#lines+1] = "	defaultJump = {"
	lines[#lines+1] = "		priority = " .. defaultJump.priority .. ','
	lines[#lines+1] = "		dayPassed = " .. tostring(defaultJump.dayPassed) .. ','
	lines[#lines+1] = "		alwaysShow = " .. tostring(defaultJump.alwaysShow) .. ','
	lines[#lines+1] = "		jumpingCountLimit = " .. defaultJump.jumpingCountLimit .. ','
	lines[#lines+1] = "		showingOrder = " .. defaultJump.showingOrder .. ','
	lines[#lines+1] = "		text = " .. escapeString(defaultJump.text) .. ','
	lines[#lines+1] = "		description = " .. escapeString(defaultJump.description) .. ','
	lines[#lines+1] = "		formulaToPass = " .. escapeString(defaultJump.formulaToPass) .. ','
	lines[#lines+1] = "	},"
	lines[#lines+1] = "	 "
end

local function convertToLua(q)
	local lines = {}
	lines[#lines+1] = "return {"

	mergeBaseProperties(lines, q)
	mergeDefaults(lines)
	mergeStrings(lines, q)
	mergeParams(lines, q)
	mergeLocations(lines, q)
	mergeJumps(lines, q)

	lines[#lines+1] = "}"
	return table.concat(lines, "\n")
end

-- validation functions
local function validateQuest(quest)
	local locationMap = {}
	local errors = {}
	local linksFrom = {}
	local linksTo = {}

	for _, loc in ipairs(quest.locations or {}) do
		locationMap[loc.id] = true
		linksFrom[loc.id] = 0
		linksTo[loc.id] = 0
	end

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

	for _, loc in ipairs(quest.locations or {}) do
		local fromCount = linksFrom[loc.id] or 0
		local toCount = linksTo[loc.id] or 0

		if fromCount == 0 and toCount == 0 then
			table.insert(errors, string.format(
				"location [L%d] is isolated (no incoming/outgoing jumps)",
				loc.id
			))
		end
	end

	if #errors > 0 then
		print("\nValidation errors found:")
		for _, err in ipairs(errors) do
			print("  - " .. err)
		end
	else
		print("\nNo connectivity errors detected ✓")
	end
end

local function findUnreachableLocations(quest)
	if not quest or not quest.locations or not quest.jumps then
		print("Invalid quest structure")
		return
	end

	local jumpMap = {}
	for _, jmp in ipairs(quest.jumps) do
		if jmp.fromLocationId then
			jumpMap[jmp.fromLocationId] = jumpMap[jmp.fromLocationId] or {}
			table.insert(jumpMap[jmp.fromLocationId], jmp.toLocationId)
		end
	end

	local startIds = {}
	for _, loc in ipairs(quest.locations) do
		if loc.type == 1 then
			table.insert(startIds, loc.id)
		end
	end

	if #startIds == 0 then
		print("No start locations found!")
		return
	end

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

	for _, id in ipairs(startIds) do
		visit(id)
	end

	local unreachable = {}
	for _, loc in ipairs(quest.locations) do
		if not visited[loc.id] then
			table.insert(unreachable, loc)
		end
	end

	if #unreachable > 0 then
		print("Unreachable locations found:")
		for _, loc in ipairs(unreachable) do
			print(string.format("  - id=%d", loc.id))
		end
	else
		print("All locations are reachable ✓")
	end
end

-- main conversion function
local function convertQmToLua()
	print("QM to Lua Converter (Old Format)")
	print("Input: " .. qmFile)
	print("Output: " .. luaFile)
	print("")

	local f = assert(io.open(qmFile, "rb"), "Cannot open " .. qmFile)
	local data = f:read("*a")
	f:close()

	local quest = parse(data)
	
	-- optional validation
	-- validateQuest(quest)
	-- findUnreachableLocations(quest)

	print("\nConverting to Lua...")
	local luaText = convertToLua(quest)

	local f2 = assert(io.open(luaFile, "w"), "Cannot write to " .. luaFile)
	f2:write(luaText)
	f2:close()

	print("Conversion complete!")
	print("File size: " .. #luaText .. " bytes")
end

--convertQmToLua()

-- Batch converter for multiple .qm files
local lfs = require("lfs")

local inputFolder = scriptDir .. "\\input_qm"
local outputFolder = scriptDir .. "\\output_lua"

local function ensureDir(path)
	local attr = lfs.attributes(path)
	if not attr then
		assert(lfs.mkdir(path), "Cannot create folder: " .. path)
	end
end

local function getFilesWithExtension(path, ext)
	local files = {}
	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			if file:sub(-#ext) == ext then
				table.insert(files, path .. "/" .. file)
			end
		end
	end
	return files
end

local function processFile(qmPath)
	local name = qmPath:match("([^/\\]+)%.qm$")
	local luaPath = outputFolder .. "/" .. name .. ".lua"

	print("--------------------------------------------")
	print("Processing:", qmPath)

	local f = io.open(qmPath, "rb")
	if not f then
		print("  Error: cannot open file")
		return false
	end
	local data = f:read("*a")
	f:close()

	local ok, quest = pcall(parse, data)
	if not ok then
		print("  Error during parsing:", quest)
		return false
	end

	local ok2, luaText = pcall(convertToLua, quest)
	if not ok2 then
		print("  Error during conversion:", luaText)
		return false
	end

	local f2 = io.open(luaPath, "w")
	if not f2 then
		print("  Error: cannot write to output file:", luaPath)
		return false
	end
	f2:write(luaText)
	f2:close()

	print("  Done -> " .. luaPath .. " (" .. #luaText .. " bytes)")
	return true
end

local function convertAllQm()
	print("\n\nQM to LUA Batch Converter")
	print("Input folder: " .. inputFolder)
	print("Output folder: " .. outputFolder)
	print("")

	ensureDir(outputFolder)

	local files = getFilesWithExtension(inputFolder, ".qm")
	if #files == 0 then
		print("No .qm files found in " .. inputFolder)
		return
	end

	local successCount = 0
	for _, file in ipairs(files) do
		if processFile(file) then
			successCount = successCount + 1
		end
	end

	print("--------------------------------------------")
	print(string.format("Processed %d / %d files successfully", successCount, #files))
end

-- Uncomment to run batch conversion
 convertAllQm()