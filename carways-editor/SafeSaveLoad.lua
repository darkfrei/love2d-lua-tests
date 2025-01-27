-- for safe files

local SafeSaveLoad = {}

-- checks if a table is a list
-- a list has consecutive numeric keys starting from 1 and ending at the table's length
local function isList(tbl)
	local n = #tbl
	for i, v in pairs(tbl) do
		if type(i) ~= "number"  -- [i] must be a number
		or i ~= math.floor(i)  -- [i] must be an integer
		or i < 1 or i > n then -- [i] must be within the range 1 to n
			return false
		end
	end
	return true
end

-- checks if a table is a list of numbers
-- returns false if the table is not a list or contains non-number values
local function isNumberList(tbl)
	if isList(tbl) then
		for key, value in ipairs(tbl) do
			if type(value) ~= "number" then -- [value] must be a number
				return false
			end
		end
		return true
	end
end

-- checks if a table is a list of strings
-- returns false if the table is not a list or contains non-string values
local function isStringList(tbl)
	if isList(tbl) then
		for key, value in ipairs(tbl) do
			if type(value) ~= "string" then -- [value] must be a string
				return false
			end
		end
		return true
	end
end

local function isEmptyList(tbl)
	if isList(tbl) and (#tbl == 0) then
		return true
	end
end

-- checks if a table is a list of numbers and serializes it into a space-separated string
-- returns the serialized string if the table is valid, otherwise returns nil
local function serializeNumberList(tbl)
	if isNumberList(tbl) then -- check if the table is a list of numbers
		return table.concat(tbl, " ") -- join all numbers with spaces
	end
	return nil -- return nil if the table is not a valid number list
end

-- serializes a table into a formatted string representation
-- supports string and number keys, as well as string, number, and nested table values
-- unsupported key or value types will raise an error

function SafeSaveLoad.serializeTable(tabl, level)
--	print ('SafeSaveLoad.serializeTable:', 'start')
	level = level or 0
	local result = {}
	local indent = string.rep("  ", level)

	if isEmptyList(tabl) then
		table.insert(result, indent .. "emptyList")
		return table.concat(result, "\n")
	end

	-- check if the table is a list of numbers
	if isNumberList(tabl) then
--		print ('serializeTable: level '..level .. ' was numbers list')
		-- handle ListNumbers type
		table.insert(result, indent .. "start numbers list")
		table.insert(result, indent .. table.concat(tabl, " "))
		table.insert(result, indent .. "end numbers list")
		return table.concat(result, "\n")
	end

	-- check if the table is a list of strings
	if isStringList(tabl) then
		-- handle ListStrings type
		table.insert(result, indent .. "start strings list")
		table.insert(result, table.concat(tabl, '\n'))
		table.insert(result, indent .. "end strings list")
		return table.concat(result, "\n")
	end


	-- append the start of a table marker
	table.insert(result, indent .. "start table")

	for key, value in pairs(tabl) do
		local typeKey = type(key)
		local typeValue = type(value)
		if (typeKey == 'number') or (typeKey == 'string') then
--			if typeValue == "table" and isEmptyList(value) then
--				-- stringIndex numberIndex
--				table.insert(result, indent .. typeKey.."Index")
--				table.insert(result, indent .. key)  -- Index (key)
--				table.insert(result, indent .. typeValue.."Value")
--				table.insert(result, indent .. '  ' .. 'emptyList')
--			elseif typeValue == "table" then
			if typeValue == "table" then
				table.insert(result, indent .. typeKey.."Index")
				table.insert(result, indent .. key)  -- Index (key)
				-- tableValue numberValue booleanValue stringValue
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

--	print ('SafeSaveLoad.serializeTable:', 'end')
	return table.concat(result, "\n")
end

-- new
-- deserializes a formatted string representation back into a Lua table
-- supports nested tables with string and number keys and values
-- maintains the same structure as the serialized table
-- deserializes a formatted string representation back into a Lua table
-- supports nested tables with string and number keys and values
-- maintains the same structure as the serialized table
function SafeSaveLoad.deserializeString(str)
	-- [input string with serialized data]
	local stack = {} -- stack for nested tables
	local namesStack = {} -- stack for nested tables
	local currentTable -- current table we are working with
	local tempList
	local tempIndex
	local state = 'tableValue'



	for line in str:gmatch("(.-)\n") do
		line = line:match("^%s*(.-)%s*$") -- remove leading/trailing spaces
--		print (line)

		-- state machine logic
--		print ('current state:', state)
		if state == 'tableValue' then
			if line == 'emptyList' then
				currentTable[tempIndex] = {}
--				print ('added empty list: '..tempIndex)
				state = 'indexType'
			elseif line == 'start table' then

				local newTable = {}

				table.insert(stack, newTable) -- push current table to stack

				if #namesStack == 0 then
					table.insert(namesStack, 'root')
--					print ('created root table')
				else
					table.insert(namesStack, 'tempIndex')
--					print ('created ['..tempIndex..'] table')
				end

				if currentTable and tempIndex then
					currentTable[tempIndex] = newTable
				end
				currentTable = newTable

--				print ('new table, #stack:', #stack)
				state = 'indexType'

			elseif line == 'start numbers list' then
				tempList = {} -- reset content
				state = 'listNumbers'

			elseif line == 'start strings list' then
				tempList = {} -- reset content
				state = 'listStrings'
			else
				print ('SafeSaveLoad.deserializeString', 'comment:')
				print ('################')
				print (line)
				print ('################')
			end

		elseif state == 'indexType' then
--			print ('State: indexType', 'line: ' .. line)
			if line == 'end table' then
				table.remove(stack) -- pop current table from stack
				table.remove(namesStack)
--				print ('stack removed! #stack:', #stack)
				if #namesStack > 0 then
--					print ('back to table: '.. namesStack[#namesStack])
				end
				currentTable = stack[#stack] -- restore previous table
			else
				state = line -- 'numberIndex' or 'stringIndex'
			end

		elseif state == 'numberIndex' then
			tempIndex = tonumber(line)
			state = 'valueType' -- waiting for value type

		elseif state == 'stringIndex' then
			tempIndex = line
			state = 'valueType'

		elseif state == 'valueType' then
			state = line -- 'numberValue' or 'stringValue'

		elseif state == 'numberValue' then
			currentTable[tempIndex] = tonumber(line)
			tempIndex = nil
			state = 'indexType' -- or end of table!

		elseif state == 'stringValue' then
			currentTable[tempIndex] = line
			tempIndex = nil
			state = 'indexType' -- or end of table!

		elseif state == 'booleanValue' then
--			print (line, tostring(line == 'true'))
			currentTable[tempIndex] = (line == 'true')
			tempIndex = nil
			state = 'indexType' -- or end of table!

			-- new states:
		elseif state == 'listNumbers' then
			if line == 'end numbers list' then
				currentTable[tempIndex] = tempList
				tempList = nil
				state = 'indexType'
			else -- line or multiline values
				for num in line:gmatch("([%-?%d%.]+)") do
					table.insert(tempList, tonumber(num))
				end
			end
		elseif state == 'listStrings' then
			if line == 'end strings list' then
				currentTable[tempIndex] = tempList
				tempList = nil
				state = 'indexType'
			else -- line or multiline values
				table.insert(tempList, line)
			end
		else
			error ('not state:' .. state .. '; line: ' .. line)

		end
	end

	--[[
	print ('')
	print ('currentTable:')
	for i, v in pairs (currentTable) do
		print (i, v)
	end
	print ('end of currentTable')
	--]]

	return currentTable -- return the deserialized table
end


return SafeSaveLoad



