-- luaml.lua
-- Lua parser for LuaML with lua-like syntax

-- https://github.com/darkfrei/LuaML
-- https://github.com/darkfrei/love2d-lua-tests/tree/main/parser-luaml-lua
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


-- lexer: splits input string into tokens, ignores comments starting with --
-- str: luaml formatted string
-- returns: array of tokens, where each token is a table with:
--   type: token type ("string", "number", "bool", "nil", "ident", "{", "}", etc.)
--   value: token value (for string, number, bool, nil, ident types)
-- special handling:
--   - skips single-line comments (--) and multi-line comments (--[[ ... ]])
--   - recognizes keywords: return, function, end, true, false, nil
--   - when "function" keyword is found, skips entire function body until matching "end"
--     and creates a single "function_placeholder" token instead
--   - supports UTF-8 identifiers with dashes (kebab-case)
--   - supports multiple string formats: "...", '...', [[ ... ]]
--   - supports hex numbers (0x...), decimals, and scientific notation
local function tokenize(str)
	-- tokenize input, return list of tokens
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

			-- parentheses tokens (no debug prints)
		elseif ch == "(" then
			tokens[#tokens+1] = {type="("}
			i = i + 1

		elseif ch == ")" then
			tokens[#tokens+1] = {type=")"}
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
			elseif word == "function" then
--				tokens[#tokens+1] = {type="function"}

				-- begin skip-function mode: ignore everything until matching "end"
				-- does not generate any tokens for the function body

				local depth = 1
				-- we are currently at the end of the word "function"
				-- now skip characters until depth returns to 0

				while i <= n and depth > 0 do
					local ch2 = str:sub(i,i)

					-- detect nested "function"
					if ch2:match("[%a_]") then
						local start2 = i
						i = i + 1
						while i <= n and str:sub(i,i):match("[%w_%-]") do
							i = i + 1
						end
						local w2 = str:sub(start2, i-1)

						if w2 == "function" then
							depth = depth + 1
						elseif w2 == "end" then
							depth = depth - 1
						end

					else
						i = i + 1
					end
				end

				-- finally insert a placeholder token
				tokens[#tokens+1] = {type="function_placeholder"}


			elseif word == "end" then
				tokens[#tokens+1] = {type="end"}
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
	-- parse a single value, supports primitives, tables and functions
	local token = tokens[pos]
	if not token then 
		error("unexpected end when reading value") 
	end

	if token.type == "string" or token.type == "number" or token.type == "bool" or token.type == "nil" then
		return token.value, pos + 1

	elseif token.type == "{" then
		return parseBraceBlock(tokens, pos)

	elseif token.type == "ident" then
		return token.value, pos + 1

	elseif token.type == "function_placeholder" then
		-- return lightweight marker
--	return { __luaml_function = true }, pos + 1
--	return { __luaml_skip_function = true }, pos + 1
		return { __luaml_skip_function = true }, pos + 1

--[[
	elseif token.type == "function" then
		-- skip function definition and return a placeholder object
		-- this preserves table structure and allows encode to skip or annotate functions
		local startPos = pos
		pos = pos + 1 -- skip 'function' token

		-- skip optional parameter list (...) if present
		if tokens[pos] and tokens[pos].type == "(" then
			local depth = 1
			pos = pos + 1
			while pos <= #tokens and depth > 0 do
				if tokens[pos].type == "(" then
					depth = depth + 1
				elseif tokens[pos].type == ")" then
					depth = depth - 1
				end
				pos = pos + 1
			end
		end

		-- now skip function body until matching 'end', handling nested functions
		local depth = 1
		while pos <= #tokens and depth > 0 do
			if tokens[pos].type == "function" then
				depth = depth + 1
			elseif tokens[pos].type == "end" then
				depth = depth - 1
			end
			pos = pos + 1
		end

		-- return a placeholder table marking a function was here
		local placeholder = { __luaml_function = true }
		return placeholder, pos
--]]

	else
		error("unexpected token in value: " .. token.type)
	end
end


-- improved parseAssignments: safer checks and better error messages
function parseAssignments(tokens)
	-- result table
	local result = {}
	local pos = 1

	local function peek(off)
		return tokens[pos + (off or 0)]
	end

	-- skip optional leading return
	if tokens[1] and tokens[1].type == "return" then
		pos = 2
	end

	-- top-level { ... } shortcut
	if tokens[pos] and tokens[pos].type == "{" then
		local ok, block, newPos = pcall(function() return parseBraceBlock(tokens, pos) end)
		if not ok then error("parseBraceBlock error at top-level: " .. tostring(block)) end
		return block
	end

	while pos <= #tokens do
		local token = tokens[pos]
		if not token then
			error("unexpected end of tokens at pos " .. pos)
		end

		local nextToken = tokens[pos + 1]

		-- safety: check token types before indexing
		local tokType = token.type

		-- if "ident =" -> normal field
		if tokType == "ident" and nextToken and nextToken.type == "=" then
			local key = token.value
			pos = pos + 2
			local val
			val, pos = parseValue(tokens, pos)
			result[key] = val

			-- ["string"] = ...
		elseif tokType == "[" and nextToken and nextToken.type == "string" then
			local after = tokens[pos + 2]
			local afterEq = tokens[pos + 3]
			if not after or after.type ~= "]" then
				error("expected ']' after [\"key\"] at pos " .. pos .. " (got " .. tostring(after and after.type) .. ")")
			end
			if not afterEq or afterEq.type ~= "=" then
				error("expected '=' after [\"key\"] at pos " .. pos .. " (got " .. tostring(afterEq and afterEq.type) .. ")")
			end
			local key = nextToken.value
			pos = pos + 4
			local val
			val, pos = parseValue(tokens, pos)
			result[key] = val

			-- [ident] = ...
		elseif tokType == "[" and nextToken and nextToken.type == "ident" then
			local after = tokens[pos + 2]
			local afterEq = tokens[pos + 3]
			if not after or after.type ~= "]" then
				error("expected ']' after [key] at pos " .. pos .. " (got " .. tostring(after and after.type) .. ")")
			end
			if not afterEq or afterEq.type ~= "=" then
				error("expected '=' after [key] at pos " .. pos .. " (got " .. tostring(afterEq and afterEq.type) .. ")")
			end
			local key = nextToken.value
			pos = pos + 4
			local val
			val, pos = parseValue(tokens, pos)
			result[key] = val

			-- "string" = ...
		elseif tokType == "string" and nextToken and nextToken.type == "=" then
			local key = token.value
			pos = pos + 2
			local val
			val, pos = parseValue(tokens, pos)
			result[key] = val

		else
			-- otherwise -> list value (anonymous)
			local val
			val, pos = parseValue(tokens, pos)
			table.insert(result, ' --- '..val)
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

-- add helper function before encodeValue
local function isValidIdentifier(str)
	if not str or str == "" then return false end

	-- check first character
	local firstCh = utf8Char(str, 1)
	if not firstCh or not isUTF8Letter(firstCh) then
		return false
	end

	-- check rest
	local i = 1
	while i <= #str do
		local ch, size = utf8Char(str, i)
		if not ch then break end
		if not isUTF8identChar(ch) then
			return false
		end
		i = i + size
	end

	return true
end

local function encodeValue(tableValue, indent, out, skipFunctions, keyForComment)
	local typ = type(tableValue)

	-- check for skipped function placeholder FIRST
	if typ == "table" and tableValue.__luaml_skip_function then
		-- just add comment, parent will handle formatting
		out[#out+1] = "-- skipped function: " .. (keyForComment or "(anonymous)")
		return
	end

	if typ == "number" then
		out[#out+1] = tostring(tableValue)
	elseif typ == "boolean" then
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
			encodeQuotes(tableValue, out)
		end

	elseif typ == "table" then
		out[#out+1] = "{"
		out[#out+1] = "\n"

		local nextIndent = indent .. "  "

		-- array part
		local max = #tableValue
		for i = 1, max do
			local item = tableValue[i]
			local itemType = type(item)

			-- check for function placeholder
			-- case 1: function was skipped during decode (placeholder table with __luaml_skip_function flag)
			if itemType == "table" and item.__luaml_skip_function then
				out[#out+1] = nextIndent .. "-- skipped function [" .. i .. "]\n"
				-- case 2: normal value - encode it
			elseif not (skipFunctions and itemType == "function") then
				out[#out+1] = nextIndent
				encodeValue(item, nextIndent, out, skipFunctions, tostring(i))
				out[#out+1] = ",\n"
				-- case 3: actual function object being encoded with skipFunctions=true
			elseif skipFunctions and itemType == "function" then
				out[#out+1] = nextIndent .. "-- skipped function [" .. i .. "] (raw)\n"
			end
		end

		-- key-value part
		for k, v in pairs(tableValue) do
			if type(k) ~= "number" or k < 1 or k > max then
				local isIdent = type(k) == "string" and isValidIdentifier(k)
				local keyString = isIdent and k or ("[" .. string.format("%q", k) .. "]")

				-- check for function placeholder
				-- check for function placeholder
				-- case 1: function was skipped during decode (placeholder table with __luaml_skip_function flag)
				if type(v) == "table" and v.__luaml_skip_function then
					out[#out+1] = nextIndent .. "-- skipped function: " .. keyString .. "\n"
					-- case 2: actual function object being encoded with skipFunctions=true
				elseif type(v) == "function" and skipFunctions then
					out[#out+1] = nextIndent .. "-- skipped function: " .. keyString .. " (raw)\n"
					-- case 3: normal value - encode it
				else
					out[#out+1] = nextIndent
					out[#out+1] = keyString .. " = "
					encodeValue(v, nextIndent, out, skipFunctions, keyString)
					out[#out+1] = ",\n"
				end
			end
		end

		out[#out+1] = indent .. "}"

	elseif typ == "function" then
		if skipFunctions then
			out[#out+1] = "nil -- function skipped"
		else
			error("cannot serialize function (use skipFunctions flag)")
		end

	else
		error("unsupported type: " .. typ)
	end
end


------

-- encode lua table to luaml string
-- tbl: table to encode
-- tableMode: if true, wrap in "return {...}", if false use global mode with assignments
-- skipFunctions: if true, skip functions and add comments; if false, error on functions

function luaml.encode(tbl, tableMode, skipFunctions)
	local out = {}

	-- prepend mode comment
	if tableMode then
		out[#out+1] = "-- mode: table\n"
		out[#out+1] = "return "
		encodeValue(tbl, "", out, skipFunctions)
	else
		out[#out+1] = "-- mode: global\n"

		local indent = ""
		local max = #tbl

		-- array part
		out[#out+1] = "-- array part\n"
		for i = 1, max do
			local item = tbl[i]
			local itemType = type(item)

			-- check for function placeholder
			if itemType == "table" and item.__luaml_skip_function then
				out[#out+1] = "-- skipped function [" .. i .. "]\n"
			elseif not (skipFunctions and itemType == "function") then
				encodeValue(item, indent, out, skipFunctions)
				out[#out+1] = "\n"
			elseif skipFunctions and itemType == "function" then
				out[#out+1] = "-- skipped function [" .. i .. "] (raw)\n"
			end
		end
		out[#out+1] = "-- end of array part\n\n"

		-- object part
		out[#out+1] = "-- object part\n"
		for k, value in pairs(tbl) do
			if type(k) ~= "number" or k < 1 or k > max then
				local valType = type(value)

				-- check for function placeholder
				if valType == "table" and value.__luaml_skip_function then
					out[#out+1] = "-- skipped function: " .. k .. "\n"
				elseif not (skipFunctions and valType == "function") then
					out[#out+1] = k .. " = "
					encodeValue(value, indent, out, skipFunctions, k)
					out[#out+1] = "\n"
				elseif skipFunctions and valType == "function" then
					out[#out+1] = "-- skipped function: " .. k .. " (raw)\n"
				end
			end
		end
		out[#out+1] = "-- end of object part\n"
	end

	return table.concat(out)
end



-- decode luaml string to lua table
-- str: luaml formatted string to parse
-- returns: table on success, or (nil, error_info) on failure
--   error_info is a table with fields:
--     stage: "tokenize" or "parse"
--     error: error message string
--     pos: token position where error occurred (parse stage only)
--     snippet: array of nearby tokens for debugging (parse stage only)
function luaml.decode(str)
	-- tokenize the input string
	local ok, tokens_or_err = pcall(tokenize, str)
	if not ok then
		-- tokenization raised an error
		return nil, {
			stage = "tokenize",
			error = tostring(tokens_or_err)
		}
	end
	local tokens = tokens_or_err

	-- parse with better error capture
	local success, result_or_err = pcall(function() return parseAssignments(tokens) end)
	if not success then
		-- build token context near failure if possible
		local errMsg = tostring(result_or_err)
		-- try to find numeric pos inside message
		local posHint = errMsg:match("pos (%d+)")
		local pos = tonumber(posHint) or nil

		-- create small dump of nearby tokens for debugging
		local dumpStart = 1
		local dumpEnd = math.min(#tokens, 80)
		if pos then
			dumpStart = math.max(1, pos - 6)
			dumpEnd = math.min(#tokens, pos + 6)
		end

		local snippet = {}
		for i = dumpStart, dumpEnd do
			local tk = tokens[i]
			if tk then
				table.insert(snippet, i .. ":" .. tostring(tk.type) .. (tk.value ~= nil and ("=" .. tostring(tk.value)) or ""))
			else
				table.insert(snippet, i .. ":<nil>")
			end
		end

		return nil, {
			stage = "parse",
			error = errMsg,
			pos = pos,
			snippet = snippet
		}
	end

	-- return the decoded table
	return result_or_err
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
