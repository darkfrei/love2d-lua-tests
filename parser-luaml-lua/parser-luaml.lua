-- luaml.lua
-- ml parser with lua-like syntax
-- comments are lowercase
-- https://github.com/darkfrei/LuaML
-- Version: 2025-12-07

local luaml = {}

local parseValue, parseBraceBlock, parseAssignments


---------

-- log

local function hex(b)
	return string.format("0x%02X", b or 0)
end

local function log(...)
--	print("[utf8-parse]", ...)
end

------
-- utf8 things
local function utf8Char(str, i)
	local c = str:byte(i)
	if not c then
		log("utf8Char: i=", i, " -> <nil>")
		return nil
	end

	if c < 0x80 then
		local ch = str:sub(i, i)
		log("utf8Char: i=", i, " first=", hex(c), " size=1 char='", ch, "'")
		return ch, 1
	elseif c < 0xE0 then
		local c2 = str:byte(i+1)
		local ch = str:sub(i, i+1)
		log("utf8Char: i=", i, " first=", hex(c), " c2=", hex(c2), " size=2 char='", ch, "'")
		return ch, 2
	elseif c < 0xF0 then
		local c2, c3 = str:byte(i+1), str:byte(i+2)
		local ch = str:sub(i, i+2)
		log("utf8Char: i=", i, " first=", hex(c), " c2=", hex(c2), " c3=", hex(c3), " size=3 char='", ch, "'")
		return ch, 3
	else
		local c2, c3, c4 = str:byte(i+1), str:byte(i+2), str:byte(i+3)
		local ch = str:sub(i, i+3)
		log("utf8Char: i=", i, " first=", hex(c), " c2=", hex(c2), " c3=", hex(c3), " c4=", hex(c4), " size=4 char='", ch, "'")
		return ch, 4
	end
end

local function isUTF8Letter(ch)
	local b = ch:byte()

	local ok = ((b >= 65 and b <= 90) or (b >= 97 and b <= 122) or ch == "_") or (b >= 0xC0)
	log("isUTF8Letter: ch='", ch, "' b=", hex(b), " -> ", ok and "true" or "false")


	-- ASCII A–Z, a–z, _
	if (b >= 65 and b <= 90) or (b >= 97 and b <= 122) or ch == "_" then
		return true
	end

	-- everything above 0x80 is treated as letter
	if b >= 0xC0 then
		return true
	end

	return false
end

local function isUTF8identChar(ch)
	local b = ch:byte()
	local ok = (b >= 48 and b <= 57)  -- 0–9
	or (b >= 65 and b <= 90)   -- A–Z
	or (b >= 97 and b <= 122)  -- a–z
	or ch == "_" or ch == "-"
	or b >= 0x80
	log("isUTF8identChar: ch='", ch, "' b=", hex(b), " -> ", ok and "true" or "false")
	return ok
end

local function utf8match(ch, class)
	if class == "%a" then
		return isUTF8Letter(ch)
	elseif class == "%w" then
		return isUTF8identChar(ch)
	elseif class == "_" then
		return ch == "_"
	elseif class == "-" then
		return ch == "-"
	end
	return false
end


-----
-- overload

function string.utf8chars(str)
	local i = 1
	return function()
		if i > #str then return nil end
		local ch, len = utf8Char(str, i)
		i = i + len
		return ch
	end
end

function string.isLetter(ch)
	return isUTF8Letter(ch)
end

function string.isIdentChar(ch)
	return isUTF8identChar(ch)
end

-- end of utf8 things


--------


-- lexer: splits into tokens, ignores comments starting with --
local function tokenize(str)
	local tokens = {}
	local i = 1
	local n = #str

	while i <= n do
		local ch = str:sub(i,i)

		-- ignore whitespace
		if ch:match("%s") then
			i = i + 1

			-- multi-line comment --[[ ... ]]
		elseif ch == "-" and str:sub(i,i+3) == "--[[" then
			i = i + 4
			while i <= n do
				if str:sub(i,i+1) == "]]" then
					i = i + 2
					break
				end
				i = i + 1
			end

			-- single-line comment or minus sign
		elseif ch == "-" then
			local nextCh = str:sub(i+1, i+1)
			if nextCh == "-" then
				-- single-line comment
				i = i + 2
				while i <= n and str:sub(i,i) ~= "\n" do
					i = i + 1
				end
			elseif nextCh:match("[0-9]") then
				-- negative number
				local start = i
				i = i + 1
				while i <= n and str:sub(i,i):match("[%d%.eE%+%-]") do
					i = i + 1
				end
				local numstr = str:sub(start, i-1)
				local num = tonumber(numstr)
				if not num then error("invalid number format: " .. numstr) end
				tokens[#tokens+1] = {type="number", value=num}
			else
				error("unexpected character: -")
			end

		elseif ch == "{" then
			tokens[#tokens+1] = {type="{"}
			i = i + 1

		elseif ch == "}" then
			tokens[#tokens+1] = {type="}"}
			i = i + 1

		elseif ch == "," then
			tokens[#tokens+1] = {type=","}
			i = i + 1

		elseif ch == "=" then
			tokens[#tokens+1] = {type="="}
			i = i + 1

			-- brackets and multi-line string [[ ... ]]
		elseif ch == "[" then
			if str:sub(i,i+1) == "[[" then
				-- multi-line string
				local start = i + 2
				i = start
				while i <= n do
					if str:sub(i,i+1) == "]]" then
						break
					end
					i = i + 1
				end
				local raw = str:sub(start, i-1)
				tokens[#tokens+1] = {type="string", value=raw}
				i = i + 2
			else
				-- single bracket
				tokens[#tokens+1] = {type="["}
				i = i + 1
			end

		elseif ch == "]" then
			tokens[#tokens+1] = {type="]"}
			i = i + 1

			-- single-quote string
		elseif ch == "'" then
			local start = i + 1
			i = start
			while i <= n and str:sub(i,i) ~= "'" do
				if str:sub(i,i) == "\\" then
					i = i + 1
				end
				i = i + 1
			end
			local raw = str:sub(start, i-1)
			-- unescape basic sequences
			raw = raw:gsub("\\n", "\n"):gsub("\\t", "\t"):gsub("\\'", "'"):gsub("\\\\", "\\")
			tokens[#tokens+1] = {type="string", value=raw}
			i = i + 1

			-- double-quote string
		elseif ch == '"' then
			local start = i + 1
			i = start
			while i <= n and str:sub(i,i) ~= '"' do
				if str:sub(i,i) == "\\" then
					i = i + 1
				end
				i = i + 1
			end
			local raw = str:sub(start, i-1)
			-- unescape basic sequences
			raw = raw:gsub("\\n", "\n"):gsub("\\t", "\t"):gsub('\\"', '"'):gsub("\\\\", "\\")
			tokens[#tokens+1] = {type="string", value=raw}
			i = i + 1

--		elseif ch:match("[%a_]") then
--		elseif utf8match () then
--		elseif isUTF8Letter(ch) then
--			-- identifier (including with dashes), boolean, or nil
--			local start = i
--			i = i + 1
--			while i <= n and str:sub(i,i):match("[%w_%-]") do
--				i = i + 1
--			end
--			local word = str:sub(start,i-1)

		elseif isUTF8Letter(ch) then
			local start = i
			local ch, size = utf8Char(str, i)
			i = i + size

			while true do
				local next_ch, next_size = utf8Char(str, i)
				if not next_ch or not isUTF8identChar(next_ch) then
					break
				end
				i = i + next_size
			end

			local word = str:sub(start, i-1)


			if word == "return" then
				tokens[#tokens+1] = {type="return"}
			elseif word == "true" then
				tokens[#tokens+1] = {type="bool", value=true}
			elseif word == "false" then
				tokens[#tokens+1] = {type="bool", value=false}
			elseif word == "nil" then
				tokens[#tokens+1] = {type="nil", value=nil}
			else
				tokens[#tokens+1] = {type="ident", value=word}
			end

		elseif ch:match("[%+0-9]") then
			-- number (including hex 0x, exponential)
			local start = i

			-- check for hex
			if str:sub(i,i+1) == "0x" or str:sub(i,i+1) == "0X" then
				i = i + 2
				while i <= n and str:sub(i,i):match("[%da-fA-F]") do
					i = i + 1
				end
				local numstr = str:sub(start, i-1)
				local num = tonumber(numstr)
				if not num then
					-- try base 16
					num = tonumber(numstr:sub(3), 16)
				end
				if not num then error("invalid number format: " .. numstr) end
				tokens[#tokens+1] = {type="number", value=num}

			else
				-- decimal number
				i = i + 1
				while i <= n and str:sub(i,i):match("[%d%.eE%+%-]") do
					i = i + 1
				end
				local numstr = str:sub(start, i-1)
				local num = tonumber(numstr)
				if not num then error("invalid number format: " .. numstr) end
				tokens[#tokens+1] = {type="number", value=num}
			end

		else
			error("unexpected character: "..ch)
		end
	end

	return tokens
end



------

function parseBraceBlock(tokens, pos)
	-- parse { ... } block as list or object
	pos = pos + 1 -- skip '{'
	local block = {}
	local isObject = nil -- detect later

	while true do
		local token = tokens[pos]
		local tokenNext = tokens[pos + 1]

		if not token then error("unexpected end inside { }") end

		if token.type == "}" then
			return block, pos + 1
		end

		local key, val

		-- detect object entry: ident =
		if token.type == "ident" and tokenNext and tokenNext.type == "=" then
			isObject = true
			key = token.value
			pos = pos + 2
			val, pos = parseValue(tokens, pos)
			block[key] = val

			-- detect object entry: ["string"] = or ['string'] =
		elseif token.type == "[" and tokenNext and tokenNext.type == "string" then
			local tokenAfterString = tokens[pos + 2]
			if tokenAfterString and tokenAfterString.type == "]" then
				local tokenAfterBracket = tokens[pos + 3]
				if tokenAfterBracket and tokenAfterBracket.type == "=" then
					isObject = true
					key = tokenNext.value
					pos = pos + 4 -- skip [, string, ], =
					val, pos = parseValue(tokens, pos)
					block[key] = val
				else
					error("expected '=' after [\"key\"]")
				end
			else
				error("expected ']' after [\"key\"")
			end

			-- detect object entry: [ident] =
		elseif token.type == "[" and tokenNext and tokenNext.type == "ident" then
			local tokenAfterIdent = tokens[pos + 2]
			if tokenAfterIdent and tokenAfterIdent.type == "]" then
				local tokenAfterBracket = tokens[pos + 3]
				if tokenAfterBracket and tokenAfterBracket.type == "=" then
					isObject = true
					key = tokenNext.value
					pos = pos + 4 -- skip [, ident, ], =
					val, pos = parseValue(tokens, pos)
					block[key] = val
				else
					error("expected '=' after [key]")
				end
			else
				error("expected ']' after [key")
			end

			-- detect object entry: "string" =
		elseif token.type == "string" and tokenNext and tokenNext.type == "=" then
			isObject = true
			key = token.value
			pos = pos + 2
			val, pos = parseValue(tokens, pos)
			block[key] = val

		else
			-- list entry
			if isObject == nil then isObject = false end
			if isObject then
				error("cannot mix list values with object fields")
			end

			val, pos = parseValue(tokens, pos)
			table.insert(block, val)
		end

		token = tokens[pos]
		if not token then error("unexpected end after value") end

		if token.type == "," then
			pos = pos + 1
		elseif token.type ~= "}" then
			error("expected ',' or '}'")
		end
	end
end

------

function parseValue(tokens, pos)
	local token = tokens[pos]
	if not token then error("unexpected end when reading value") end

	if token.type == "string" or token.type == "number" or token.type == "bool" or token.type == "nil" then
		return token.value, pos + 1

	elseif token.type == "{" then
		return parseBraceBlock(tokens, pos)

	elseif token.type == "ident" then
		return token.value, pos + 1

	else
		error("unexpected token in value: " .. token.type)
	end
end

function parseAssignments(tokens)
	-- result table
	local result = {}
	local pos = 1

	local token = tokens[pos]
	-- skip 'return' keyword if present
	if token and token.type == "return" then
		pos = 2
		token = tokens[pos]
	end

	-- top-level { ... } shortcut
	if token and token.type == "{" then
		return (parseBraceBlock(tokens, pos))
	end

	while pos <= #tokens do
		token = tokens[pos]
		local nextToken = tokens[pos+1]

		-- if "ident =" -> normal field
		if token.type == "ident" and nextToken and nextToken.type == "=" then
			local key = token.value
			pos = pos + 2
			local val
			val, pos = parseValue(tokens, pos)
			result[key] = val

			-- ["string"] =
		elseif token.type == "[" and nextToken and nextToken.type == "string" then
			local tokenAfterString = tokens[pos + 2]
			if tokenAfterString and tokenAfterString.type == "]" then
				local tokenAfterBracket = tokens[pos + 3]
				if tokenAfterBracket and tokenAfterBracket.type == "=" then
					local key = nextToken.value
					pos = pos + 4
					local val
					val, pos = parseValue(tokens, pos)
					result[key] = val
				else
					error("expected '=' after [\"key\"]")
				end
			else
				error("expected ']' after [\"key\"")
			end

			-- [ident] =
		elseif token.type == "[" and nextToken and nextToken.type == "ident" then
			local tokenAfterIdent = tokens[pos + 2]
			if tokenAfterIdent and tokenAfterIdent.type == "]" then
				local tokenAfterBracket = tokens[pos + 3]
				if tokenAfterBracket and tokenAfterBracket.type == "=" then
					local key = nextToken.value
					pos = pos + 4
					local val
					val, pos = parseValue(tokens, pos)
					result[key] = val
				else
					error("expected '=' after [key]")
				end
			else
				error("expected ']' after [key")
			end

			-- "string" =
		elseif token.type == "string" and nextToken and nextToken.type == "=" then
			local key = token.value
			pos = pos + 2
			local val
			val, pos = parseValue(tokens, pos)
			result[key] = val

		else
			-- otherwise -> list value
			local val
			val, pos = parseValue(tokens, pos)
			table.insert(result, val)
		end
	end

	return result
end

------

local function encodeQuotes (tableValue, out)
-- choose quote style based on content
	local hasSingle = tableValue:match("'")
	local hasDouble = tableValue:match('"')

	if hasSingle and not hasDouble then
		-- use double quotes if string contains single quotes
		out[#out+1] = '"'
		out[#out+1] = tableValue:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\t", "\\t"):gsub('"', '\\"')
		out[#out+1] = '"'
	elseif hasDouble and not hasSingle then
		-- use single quotes if string contains double quotes
		out[#out+1] = "'"
		out[#out+1] = tableValue:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\t", "\\t"):gsub("'", "\\'")
		out[#out+1] = "'"
	elseif hasSingle and hasDouble then
		-- if both, use double quotes and escape
		out[#out+1] = '"'
		out[#out+1] = tableValue:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\t", "\\t"):gsub('"', '\\"')
		out[#out+1] = '"'
	else
		-- no quotes in string, prefer double quotes
		out[#out+1] = '"'
		out[#out+1] = tableValue:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\t", "\\t")
		out[#out+1] = '"'
	end
end

local function encodeValue(tableValue, indent, out)
	local typ = type(tableValue)

	if typ == "number" then
--		out[#out+1] = '\n-- number '..tableValue..'\n'
		out[#out+1] = tostring(tableValue)
	elseif typ == "boolean" then
--		out[#out+1] = '-- boolean '..tostring(tableValue)..'\n'
		out[#out+1] = tableValue and "true" or "false"
	elseif typ == "nil" then
		out[#out+1] = "nil"
	elseif typ == "string" then
		-- use [[ ]] for multi-line strings
		if tableValue:match("\n") then
			out[#out+1] = "[["
			out[#out+1] = tableValue
			out[#out+1] = "]]"
		else
--			out[#out+1] = string.format("%q", tableValue)
			encodeQuotes (tableValue, out)
		end

	elseif typ == "table" then
		out[#out+1] = "{"
		out[#out+1] = "\n"

		local nextIndent = indent .. "  "

		-- array part
		local max = #tableValue
		for i = 1, max do
			out[#out+1] = nextIndent
			encodeValue(tableValue[i], nextIndent, out)
			out[#out+1] = ",\n"
		end

		-- key-value part
		for k,val in pairs(tableValue) do
			if type(k) ~= "number" or k > max or k < 1 then
				out[#out+1] = nextIndent
				if type(k) == "string" and k:match("^[%a_][%w_]*$") then
					out[#out+1] = k
				else
					out[#out+1] = "[" .. string.format("%q", k) .. "]"
				end
				out[#out+1] = " = "
				encodeValue(val, nextIndent, out)
				out[#out+1] = ",\n"
			end
		end

		out[#out+1] = indent
		out[#out+1] = "}"
	else
		error("unsupported type: " .. typ)
	end
end


------

function luaml.encode(tbl, tableMode)

	local out = {}

	-- prepend mode comment
	if tableMode then
		out[#out+1] = "-- mode: table\n"
		out[#out+1] = "return "
		encodeValue(tbl, "", out)
	else
		out[#out+1] = "-- mode: global\n"

		local indent = ""
		local max = #tbl

		-- array part
		out[#out+1] = "-- array part\n"
		for i = 1, max do
--			out[#out+1] = "-- array part".. i .."\n"
			encodeValue(tbl[i], indent, out)
			out[#out+1] = "\n"
		end
		out[#out+1] = "-- end of array part\n\n"

		-- object part
		out[#out+1] = "-- object part\n"
		for k, value in pairs(tbl) do
			if type(k) ~= "number" or k < 1 or k > max then
				out[#out+1] = k .. " = "
				encodeValue(value, indent, out)
				out[#out+1] = "\n"
			end
		end
		out[#out+1] = "-- end of object part\n"

	end

	return table.concat(out)
end



function luaml.decode(str)
	-- tokenize the input string
	local success, tokens = pcall(tokenize, str)
	if not success then
		return nil, "tokenization error: " .. tostring(tokens)
	end

	-- parse the token sequence into a lua table
	local success2, result = pcall(parseAssignments, tokens)
	if not success2 then
		return nil, "parse error: " .. tostring(result)
	end

	-- return the decoded table
	return result
end


-- alias for consistency
luaml.parse = luaml.decode
luaml.serialize = luaml.encode

-- load from file
function luaml.load(filename)
	local file, err = io.open(filename, "r")
	if not file then
		return nil, "cannot open file: " .. tostring(err)
	end

	local content = file:read("*all")
	file:close()

	return luaml.decode(content)
end

-- save to file
function luaml.save(filename, tbl)
	local file, err = io.open(filename, "w")
	if not file then
		return nil, "cannot create file: " .. tostring(err)
	end

	local content = luaml.encode(tbl)
	file:write(content)
	file:close()

	return true
end

return luaml
