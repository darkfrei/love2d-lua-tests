-- qmm to lua converter
-- converts quest.qmm binary format to quest.lua text format

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

-- enums
local PlayerRace = {maloki=1, pelengi=2, humans=4, feyane=8, gaaltsy=16}
local PlanetRace = {maloki=1, pelengi=2, humans=4, feyane=8, gaaltsy=16, uninhabited=64}
local WhenDone = {onReturn=0, onFinish=1}
local PlayerCareer = {trader=1, pirate=2, warrior=4}
local ParamType = {normal=0, failing=1, successful=2, deadly=3}
local ParamCritType = {maximum=0, minimum=1}
local ParameterShowingType = {dontTouch=0x00, show=0x01, hide=0x02}
local ParameterChangeType = {value=0x00, sum=0x01, percentage=0x02, formula=0x03}
local LocationType = {ordinary=0x00, starting=0x01, empty=0x02, success=0x03, faily=0x04, deadly=0x05}

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
				-- ascii
				table.insert(chars, string.char(codepoint))
			elseif codepoint < 0x800 then
				-- 2-byte utf-8
				table.insert(chars, string.char(
						0xC0 + math.floor(codepoint / 64),
						0x80 + (codepoint % 64)
					))
			elseif codepoint >= 0xD800 and codepoint <= 0xDBFF then
				-- high surrogate - need to read low surrogate
				self.i = self.i + 2
				if j < strLen then
					local b3, b4 = string.byte(self.data, self.i, self.i + 1)
					if b3 and b4 then
						local low = b3 + b4 * 256
						if low >= 0xDC00 and low <= 0xDFFF then
							-- valid surrogate pair
							local cp = 0x10000 + ((codepoint - 0xD800) * 0x400) + (low - 0xDC00)
							-- 4-byte utf-8
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
				-- invalid low surrogate without high surrogate - skip
				self.i = self.i + 2
			else
				-- 3-byte utf-8
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
	-- check if format is qmm type
	local isQmm = (header==HEADER_QMM_6 or header==HEADER_QMM_7 or header==HEADER_QMM_7_WITH_OLD_TGE_BEHAVIOUR)
	local res = {}
	if isQmm then
		-- handle qmm header versions
		if header==HEADER_QMM_7 or header==HEADER_QMM_7_WITH_OLD_TGE_BEHAVIOUR then
			res.majorVersion = r:int32()
			res.minorVersion = r:int32()
			res.changeLogString = r:readString(true)
		end
		-- basic fields
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
		-- handle older qm formats
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

-- parse single param for qmm
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
	return p
end

-- parse single param for old qm
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

-- parse base2 structure (texts and counts)
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

-- parse location (qmm format)
local function parseLocationQmm(r, paramsCount)
	local loc = {}
	loc.dayPassed = r:int32() ~= 0
	loc.locX = r:int32()
	loc.locY = r:int32()
	loc.id = r:int32()
	loc.maxVisits = r:int32()
	loc.type = r:byte()

	-- init param changes
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

	-- read affected params
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

	-- read texts and media
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

-- parse location (old qm format)
local function parseLocation(r, paramsCount)
	local loc = {}
	loc.dayPassed = r:int32() ~= 0
	loc.locX = r:int32()
	loc.locY = r:int32()
	loc.id = r:int32()

	-- read flags
	local isStarting = r:byte() ~= 0
	local isSuccess = r:byte() ~= 0
	local isFaily = r:byte() ~= 0
	local isFailyDeadly = r:byte() ~= 0
	local isEmpty = r:byte() ~= 0

	-- determine type
	if isStarting then loc.type = 1
	elseif isEmpty then loc.type = 2
	elseif isSuccess then loc.type = 3
	elseif isFaily then loc.type = 4
	elseif isFailyDeadly then loc.type = 5
	else loc.type = 0 end

	-- parse param changes
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

	-- read texts
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

-- parse jump (qmm format)
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

	-- init defaults
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

	-- read conditions
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

	-- read param changes
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

	-- read text fields
	jmp.formulaToPass = r:readString()
	jmp.text = r:readString()
	jmp.description = r:readString()
	jmp.img = r:readString(true)
	jmp.sound = r:readString(true)
	jmp.track = r:readString(true)

	return jmp
end

-- parse jump (old qm format)
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

	-- loop through params
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

	-- final text fields
	jmp.formulaToPass = r:readString()
	jmp.text = r:readString()
	jmp.description = r:readString()

	return jmp
end

-- main parse entry
local function parse(data)
	local r = Reader:new(data)
	local header = r:int32()
	print(string.format("Header: 0x%x", header))

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

-- escape string for lua output
local function escapeString(str)
	if not str then return '""' end
	str = str:gsub("\\","\\\\"):gsub('"','\\"'):gsub("\n","\\n"):gsub("\r","\\r")
	return '"'..str..'"'
end

-- convert parsed quest to lua table text
local function convertToLua(q)
	local lines = {}
	lines[#lines+1] = "return {"
	lines[#lines+1] = "  header = " .. q.header .. ","

	-- params
	lines[#lines+1] = "  params = {"
	for _, p in ipairs(q.params) do
		lines[#lines+1] = string.format(
			"    {name=%s, min=%d, max=%d, type=%d, starting=%s},",
			escapeString(p.name), p.min, p.max, p.type, escapeString(p.starting)
		)
	end
	lines[#lines+1] = "  },"

	-- locations
	lines[#lines+1] = "  locations = {"
	for _, loc in ipairs(q.locations) do
		lines[#lines+1] = string.format(
			"    {id=%d, type=%d, x=%d, y=%d, maxVisits=%d, texts={",
			loc.id, loc.type, loc.locX, loc.locY, loc.maxVisits or 0
		)
		for _, text in ipairs(loc.texts) do
			lines[#lines+1] = "      " .. escapeString(text) .. ","
		end
		lines[#lines+1] = "    }},"
	end
	lines[#lines+1] = "  },"

	-- jumps
	lines[#lines+1] = "  jumps = {"
	for _, jmp in ipairs(q.jumps) do
		lines[#lines+1] = string.format(
			"    {id=%d, from=%d, to=%d, priority=%f, text=%s, desc=%s},",
			jmp.id, jmp.fromLocationId, jmp.toLocationId, jmp.priority,
			escapeString(jmp.text), escapeString(jmp.description)
		)
	end
	lines[#lines+1] = "  },"

	lines[#lines+1] = "}"
	return table.concat(lines, "\n")
end

-- main conversion function
local function convertQmmToLua()
	print("QMM to Lua Converter")
	print("Input: " .. qmmFile)
	print("Output: " .. luaFile)
	print("")

	local f = assert(io.open(qmmFile, "rb"), "cannot open " .. qmmFile)
	local data = f:read("*a")
	f:close()

	local quest = parse(data)

	print("\nconverting to lua...")
	local luaText = convertToLua(quest)

	local f2 = assert(io.open(luaFile, "w"), "cannot write to " .. luaFile)
	f2:write(luaText)
	f2:close()

	print("conversion complete!")
end

convertQmmToLua()
