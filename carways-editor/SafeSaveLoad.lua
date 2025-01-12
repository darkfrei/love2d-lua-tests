-- for safe files

local SafeSaveLoad = {}

-- [check if table is a number array]
local function isList(tbl)
	local n = #tbl
	for i, v in pairs(tbl) do
		if type(i) ~= "number" 
		or i ~= math.floor(i) 
		or i < 1 or i > n then
			return false
		end
	end

	return true
end

local function isNumberList (tbl)
	if isList(tbl) then
		for key, value in ipairs(tbl) do
			if type(value) ~= "number" then
				return false
			end
		end
		return true
	end
end

local function isStringList (tbl)
	if isList(tbl) then
		for key, value in ipairs(tbl) do
			if type(value) ~= "string" then
				return false
			end
		end
		return true
	end
end

-- serializes a table into a formatted string representation
-- supports string and number keys, as well as string, number, and nested table values
-- unsupported key or value types will raise an error
function SafeSaveLoad.serializeTable(tabl, level)
	level = level or 0
	local result = {}
	local indent = string.rep("  ", level)

	-- append the start of a table marker
	table.insert(result, indent .. "start table")

	for key, value in pairs(tabl) do
		local typeKey = type(key)
		local typeValue = type(value)
		if (typeKey == 'number') or (typeKey == 'string') then
			if typeValue == "table" then
				table.insert(result, indent .. typeKey.."Index")
				table.insert(result, indent .. key)  -- Index (key)
				table.insert(result, indent .. typeValue.."Value")
				table.insert(result, SafeSaveLoad.serializeTable(value, level + 1))  -- recursively serialize
			elseif (typeValue == 'string') or (typeValue == 'number') then
				table.insert(result, indent .. typeKey.."Index")
				table.insert(result, indent .. key)
				table.insert(result, indent .. typeValue.."Value")
				table.insert(result, indent .. value)
			elseif (typeValue == 'boolean')then

				table.insert(result, indent .. typeKey.."Index")
				table.insert(result, indent .. key)
				table.insert(result, indent .. typeValue.."Value")
				table.insert(result, indent .. tostring(value))
			else
				error ('value type [' .. typeValue .. ']  not supported')
			end
		else
			error ('key type [' .. typeKey .. ']  not supported')
		end
	end
	table.insert(result, indent .. "end table")
	return table.concat(result, "\n")
end


-- deserializes a formatted string representation back into a Lua table
-- supports nested tables with string and number keys and values
-- maintains the same structure as the serialized table
function SafeSaveLoad.deserializeString(str)
	-- [input string with serialized data]
	local stack = {} -- stack for nested tables
	local currentTable = {} -- current table we are working with
	local tempIndex
	local state = 'tableValue'

	for line in str:gmatch("(.-)\n") do
		line = line:match("^%s*(.-)%s*$") -- remove leading/trailing spaces
--		print('['..line..']') -- print for debugging
		if line == "start table" then
			-- starting a new table
			table.insert(stack, currentTable) -- push current table to stack
			state = 'index'

		elseif line == "end table" then
			-- ending the current table
			table.remove(stack)
			currentTable = stack[#stack]
		elseif (state == 'index') then
			if line == "stringIndex" then
				-- waiting for the index (key)
--				print("Waiting for string index")
				state = 'stringIndex'
			elseif line == "numberIndex" then
				state = "numberIndex"
			end
		elseif (state == 'stringIndex') then
			tempIndex = line
			state = 'value'
		elseif (state == 'numberIndex') then
			tempIndex = tonumber(line)
			state = 'value'
		elseif (state == 'value') then
			state = line
			if state == 'tableValue' then
				local newTable = {}
				currentTable[tempIndex] = newTable
				currentTable = newTable
			end
		elseif state == "stringValue" then
			currentTable[tempIndex] = line
			tempIndex = nil -- reset temp variables
			state = 'index'
		elseif state == "numberValue" then
			currentTable[tempIndex] = tonumber(line)
			tempIndex = nil -- reset temp variables
			state = 'index'
		elseif state == "booleanValue" then
--			currentTable[tempIndex] = tonumber(line)
			if line == "true" then
				print ('added ' .. line .. ' as boolean')
				currentTable[tempIndex] = true
			elseif line == "false" then
				print ('added ' .. line .. ' as boolean')
				currentTable[tempIndex] = false
			end
			tempIndex = nil -- reset temp variables
			state = 'index'

		end
	end
	return currentTable
end



--[[
-- test functions

local data = 
{
	player = "hero",
	level = 5,
	stats = {
		health = 100,
		mana = 50,
	},
	items = {"sword", "shield", "potion"}
}



local testStr = SafeSaveLoad.serializeTable(data)
print ('')
print ('testStr')
print (testStr)
print ('')
local testTable2 = SafeSaveLoad.deserializeString(testStr)
serpent = require ('serpent')
print ('serpent:')
print (serpent.block (testTable2))
--]]


return SafeSaveLoad



