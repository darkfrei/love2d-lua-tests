-- qmreader.lua
-- QM/QMM quest file parser for Space Rangers
-- reads binary quest files and converts to Lua table structure

local utf16le = require("utf16le")

local QMReader = {}

-- constants
local LOCATION_TEXTS = 10

-- header magic numbers
local HEADER_QM_2 = 0x423a35d2  -- 24 parameters
local HEADER_QM_3 = 0x423a35d3  -- 48 parameters
local HEADER_QM_4 = 0x423a35d4  -- 96 parameters
local HEADER_QMM_6 = 0x423a35d6
local HEADER_QMM_7 = 0x423a35d7
local HEADER_QMM_7_OLD_TGE = 0x69f6bd7

-- enums
QMReader.ParamType = {
	Normal = 0,
	Fail = 1,
	Success = 2,
	Death = 3,
}

QMReader.ParamCritType = {
	Maximum = 0,
	Minimum = 1,
}

QMReader.ParameterShowingType = {
	NoChange = 0x00,
	Show = 0x01,
	Hide = 0x02,
}

QMReader.ParameterChangeType = {
	Value = 0x00,
	Sum = 0x01,
	Percentage = 0x02,
	Formula = 0x03,
}

QMReader.LocationType = {
	Ordinary = 0x00,
	Starting = 0x01,
	Empty = 0x02,
	Success = 0x03,
	Fail = 0x04,
	Deadly = 0x05,
}

-- reader class
local Reader = {}
Reader.__index = Reader

function Reader.new(data)
	local self = setmetatable({}, Reader)
	self.data = data
	self.pos = 1
	return self
end

function Reader:int32()
	local value, newPos = utf16le.readInt32(self.data, self.pos)
	self.pos = newPos
	return value
end

function Reader:readString(canBeUndefined)
	local value, newPos
	if canBeUndefined then
		value, newPos = utf16le.readStringOrNil(self.data, self.pos)
	else
		value, newPos = utf16le.readString(self.data, self.pos)
	end
	self.pos = newPos
	return value
end

function Reader:byte()
	local value, newPos = utf16le.readByte(self.data, self.pos)
	self.pos = newPos
	return value
end

function Reader:dwordFlag(expected)
	local value = self:int32()
	if expected and value ~= expected then
		error(string.format("Expecting %d, but got %d at position %d", expected, value, self.pos - 4))
	end
	return value
end

function Reader:float64()
	local value, newPos = utf16le.readFloat64(self.data, self.pos)
	self.pos = newPos
	return value
end

function Reader:seek(n)
	self.pos = self.pos + n
end

function Reader:isNotEnd()
	return self.pos <= #self.data
end

function Reader:remaining()
	return #self.data - self.pos + 1
end

-- parse functions
local function parseBase(r, header)
	local isQmm = header == HEADER_QMM_6 or header == HEADER_QMM_7 or header == HEADER_QMM_7_OLD_TGE

	local base = {}

	if isQmm then
		if header == HEADER_QMM_7 or header == HEADER_QMM_7_OLD_TGE then
			base.majorVersion = r:int32()
			base.minorVersion = r:int32()
			base.changeLogString = r:readString(true)
		end

		base.givingRace = r:byte()
		base.whenDone = r:byte()
		base.planetRace = r:byte()
		base.playerCareer = r:byte()
		base.playerRace = r:byte()
		base.reputationChange = r:int32()

		base.screenSizeX = r:int32()
		base.screenSizeY = r:int32()
		base.widthSize = r:int32()
		base.heightSize = r:int32()
		base.defaultJumpCountLimit = r:int32()
		base.hardness = r:int32()
		base.paramsCount = r:int32()
	else
		base.paramsCount = header == HEADER_QM_3 and 48 or 
		header == HEADER_QM_2 and 24 or
		header == HEADER_QM_4 and 96 or
		error("Unknown header: " .. tostring(header))

		r:dwordFlag()
		base.givingRace = r:byte()
		base.whenDone = r:byte()
		r:dwordFlag()
		base.planetRace = r:byte()
		r:dwordFlag()
		base.playerCareer = r:byte()
		r:dwordFlag()
		base.playerRace = r:byte()
		base.reputationChange = r:int32()

		base.screenSizeX = r:int32()
		base.screenSizeY = r:int32()
		base.widthSize = r:int32()
		base.heightSize = r:int32()
		r:dwordFlag()

		base.defaultJumpCountLimit = r:int32()
		base.hardness = r:int32()
	end

	return base
end

local function parseParam(r, isQmm)
	local param = {}

	param.min = r:int32()
	param.max = r:int32()

	if isQmm then
		param.type = r:byte()
		local unknown1 = r:byte()
		local unknown2 = r:byte()
		local unknown3 = r:byte()
		param.showWhenZero = r:byte() ~= 0
		param.critType = r:byte()
		param.active = r:byte() ~= 0
	else
		r:int32()
		param.type = r:byte()
		r:int32()
		param.showWhenZero = r:byte() ~= 0
		param.critType = r:byte()
		param.active = r:byte() ~= 0
	end

	local showingRangesCount = r:int32()
	param.isMoney = r:byte() ~= 0
	param.name = r:readString()

	param.showingInfo = {}
	for i = 1, showingRangesCount do
		local from = r:int32()
		local to = r:int32()
		local str = r:readString()
		table.insert(param.showingInfo, {from = from, to = to, str = str})
	end

	param.critValueString = r:readString()

	if isQmm then
		param.img = r:readString(true)
		param.sound = r:readString(true)
		param.track = r:readString(true)
	end

	param.starting = r:readString()

	return param
end

local function parseBase2(r, isQmm)
	local base2 = {}

	base2.strings = {}
	base2.strings.ToStar = r:readString()

	if not isQmm then
		base2.strings.Parsec = r:readString(true)
		base2.strings.Artefact = r:readString(true)
	end

	base2.strings.ToPlanet = r:readString()
	base2.strings.Date = r:readString()
	base2.strings.Money = r:readString()
	base2.strings.FromPlanet = r:readString()
	base2.strings.FromStar = r:readString()
	base2.strings.Ranger = r:readString()

	base2.locationsCount = r:int32()
	base2.jumpsCount = r:int32()
	base2.successText = r:readString()
	base2.taskText = r:readString()

	if not isQmm then
		local unknownText = r:readString()
	end

	return base2
end

local function parseLocation(r, paramsCount, isQmm)
	local loc = {}

	loc.dayPassed = r:int32() ~= 0
	loc.locX = r:int32()
	loc.locY = r:int32()
	loc.id = r:int32()

	if isQmm then
		loc.maxVisits = r:int32()
		local locType = r:byte()
		loc.isStarting = locType == QMReader.LocationType.Starting
		loc.isSuccess = locType == QMReader.LocationType.Success
		loc.isFail = locType == QMReader.LocationType.Fail
		loc.isFailDeadly = locType == QMReader.LocationType.Deadly
		loc.isEmpty = locType == QMReader.LocationType.Empty
	else
		loc.isStarting = r:byte() ~= 0
		loc.isSuccess = r:byte() ~= 0
		loc.isFail = r:byte() ~= 0
		loc.isFailDeadly = r:byte() ~= 0
		loc.isEmpty = r:byte() ~= 0
		loc.maxVisits = 0
	end

	loc.paramsChanges = {}

	if isQmm then
		-- initialize all params
		for i = 1, paramsCount do
			table.insert(loc.paramsChanges, {
					change = 0,
					showingType = QMReader.ParameterShowingType.NoChange,
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
					critText = "",
				})
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
				isChangePercentage = changeType == QMReader.ParameterChangeType.Percentage,
				isChangeValue = changeType == QMReader.ParameterChangeType.Value,
				isChangeFormula = changeType == QMReader.ParameterChangeType.Formula,
				changingFormula = changingFormula,
				critText = critText,
				img = img,
				sound = sound,
				track = track,
			}
		end
	else
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

			table.insert(loc.paramsChanges, {
					change = change,
					showingType = showingType,
					isChangePercentage = isChangePercentage,
					isChangeValue = isChangeValue,
					isChangeFormula = isChangeFormula,
					changingFormula = changingFormula,
					critText = critText,
				})
		end
	end

	loc.texts = {}
	loc.media = {}

	if isQmm then
		local locationTexts = r:int32()
		for i = 1, locationTexts do
			table.insert(loc.texts, r:readString())
			local img = r:readString(true)
			local sound = r:readString(true)
			local track = r:readString(true)
			table.insert(loc.media, {img = img, sound = sound, track = track})
		end
	else
		for i = 1, LOCATION_TEXTS do
			table.insert(loc.texts, r:readString())
			table.insert(loc.media, {img = nil, sound = nil, track = nil})
		end
	end

	loc.isTextByFormula = r:byte() ~= 0

	if not isQmm then
		r:seek(4)
		r:readString()
		r:readString()
	end

	loc.textSelectFormula = r:readString()

	return loc
end

local function parseJump(r, paramsCount, isQmm, questParams)
	local jump = {}

	jump.priority = r:float64()
	jump.dayPassed = r:int32() ~= 0
	jump.id = r:int32()
	jump.fromLocationId = r:int32()
	jump.toLocationId = r:int32()

	if isQmm then
		jump.alwaysShow = r:byte() ~= 0
	else
		r:seek(1)
		jump.alwaysShow = r:byte() ~= 0
	end

	jump.jumpingCountLimit = r:int32()
	jump.showingOrder = r:int32()

	jump.paramsChanges = {}
	jump.paramsConditions = {}

	if isQmm then
		-- initialize all params
		for i = 1, paramsCount do
			table.insert(jump.paramsChanges, {
					change = 0,
					showingType = QMReader.ParameterShowingType.NoChange,
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
					critText = "",
				})
			table.insert(jump.paramsConditions, {
					mustFrom = questParams[i].min,
					mustTo = questParams[i].max,
					mustEqualValues = {},
					mustEqualValuesEqual = false,
					mustModValues = {},
					mustModValuesMod = false,
				})
		end

		local affectedConditionsCount = r:int32()
		for i = 1, affectedConditionsCount do
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

			jump.paramsConditions[paramId] = {
				mustFrom = mustFrom,
				mustTo = mustTo,
				mustEqualValues = mustEqualValues,
				mustEqualValuesEqual = mustEqualValuesEqual,
				mustModValues = mustModValues,
				mustModValuesMod = mustModValuesMod,
			}
		end

		local affectedChangeCount = r:int32()
		for i = 1, affectedChangeCount do
			local paramId = r:int32()
			local change = r:int32()
			local showingType = r:byte()
			local changeType = r:byte()
			local changingFormula = r:readString()
			local critText = r:readString()
			local img = r:readString(true)
			local sound = r:readString(true)
			local track = r:readString(true)

			jump.paramsChanges[paramId] = {
				change = change,
				showingType = showingType,
				isChangePercentage = changeType == QMReader.ParameterChangeType.Percentage,
				isChangeValue = changeType == QMReader.ParameterChangeType.Value,
				isChangeFormula = changeType == QMReader.ParameterChangeType.Formula,
				changingFormula = changingFormula,
				critText = critText,
				img = img,
				sound = sound,
				track = track,
			}
		end
	else
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

			table.insert(jump.paramsChanges, {
					change = change,
					showingType = showingType,
					isChangePercentage = isChangePercentage,
					isChangeValue = isChangeValue,
					isChangeFormula = isChangeFormula,
					changingFormula = changingFormula,
					critText = critText,
				})

			table.insert(jump.paramsConditions, {
					mustFrom = mustFrom,
					mustTo = mustTo,
					mustEqualValues = mustEqualValues,
					mustEqualValuesEqual = mustEqualValuesEqual,
					mustModValues = mustModValues,
					mustModValuesMod = mustModValuesMod,
				})
		end
	end

	jump.formulaToPass = r:readString()
	jump.text = r:readString()
	jump.description = r:readString()

	if isQmm then
		jump.img = r:readString(true)
		jump.sound = r:readString(true)
		jump.track = r:readString(true)
	end

	return jump
end

-- main parse function
function QMReader.parse(data)
	local r = Reader.new(data)

	local header = r:int32()
	local isQmm = header == HEADER_QMM_6 or header == HEADER_QMM_7 or header == HEADER_QMM_7_OLD_TGE

	local quest = parseBase(r, header)
	quest.header = header

	quest.params = {}
	for i = 1, quest.paramsCount do
		table.insert(quest.params, parseParam(r, isQmm))
	end

	local base2 = parseBase2(r, isQmm)
	for k, v in pairs(base2) do
		quest[k] = v
	end

	quest.locations = {}
	for i = 1, quest.locationsCount do
		table.insert(quest.locations, parseLocation(r, quest.paramsCount, isQmm))
	end

	quest.jumps = {}
	for i = 1, quest.jumpsCount do
		table.insert(quest.jumps, parseJump(r, quest.paramsCount, isQmm, quest.params))
	end

	if r:isNotEnd() then
		print(string.format("Warning: %d bytes remaining", r:remaining()))
	end

	return quest
end

return QMReader