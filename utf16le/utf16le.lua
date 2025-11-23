-- utf16le.lua
-- UTF-16LE encoding/decoding library for Lua
-- handles reading and writing UTF-16LE encoded strings from binary data
-- includes binary data reading utilities
-- version 2025-11-23

local utf16le = {}

-- ============================================================================
-- BINARY READING UTILITIES
-- ============================================================================

-- reads 8-bit unsigned byte
function utf16le.readByte(data, offset)
	local value = data:byte(offset)
	return value, offset + 1
end

-- reads 32-bit signed integer (little-endian)
function utf16le.readInt32(data, offset)
	local byte1 = data:byte(offset)
	local byte2 = data:byte(offset + 1)
	local byte3 = data:byte(offset + 2)
	local byte4 = data:byte(offset + 3)

	local value = byte1 + (byte2 * 0x100) + (byte3 * 0x10000) + (byte4 * 0x1000000)

	-- handle negative numbers (two's complement)
	if value >= 0x80000000 then
		value = value - 0x100000000
	end

	return value, offset + 4
end

-- reads 64-bit double (little-endian IEEE 754)
function utf16le.readFloat64(data, offset)
	local bytes = {}
	for i = 0, 7 do
		bytes[i + 1] = data:byte(offset + i)
	end

	-- extract sign, exponent, mantissa
	local sign = bytes[8] >= 128 and -1 or 1
	local exponent = ((bytes[8] % 128) * 16) + math.floor(bytes[7] / 16) - 1023

	-- calculate mantissa
	local mantissa = 1
	local mult = 0.5
	for i = 7, 1, -1 do
		local byte = bytes[i]
		if i == 7 then 
			byte = byte % 16 
		end
		for bit = 7, 0, -1 do
			if byte >= 2^bit then
				mantissa = mantissa + mult
				byte = byte - 2^bit
			end
			mult = mult * 0.5
		end
	end

	local result = sign * mantissa * (2 ^ exponent)
	return result, offset + 8
end

-- writes 32-bit signed integer (little-endian)
function utf16le.writeInt32(value)
	if value < 0 then
		value = value + 0x100000000
	end

	return string.char(
		value % 256,
		math.floor(value / 256) % 256,
		math.floor(value / 65536) % 256,
		math.floor(value / 16777216) % 256
	)
end

-- writes 64-bit double (little-endian IEEE 754)
function utf16le.writeFloat64(value)
	if value == 0 then
		return string.char(0, 0, 0, 0, 0, 0, 0, 0)
	end

	local sign = value < 0 and 1 or 0
	value = math.abs(value)

	-- extract exponent and mantissa
	local exponent = math.floor(math.log(value) / math.log(2))
	local mantissa = value / (2 ^ exponent) - 1

	exponent = exponent + 1023

	-- pack into bytes
	local bytes = {}
	bytes[8] = (sign * 128) + math.floor(exponent / 16)
	bytes[7] = ((exponent % 16) * 16)

	-- pack mantissa into remaining bits
	for i = 7, 1, -1 do
		for bit = (i == 7 and 3 or 7), 0, -1 do
			mantissa = mantissa * 2
			if mantissa >= 1 then
				bytes[i] = bytes[i] + (2 ^ bit)
				mantissa = mantissa - 1
			end
		end
		if i > 1 then
			bytes[i - 1] = 0
		end
	end

	return string.char(table.unpack(bytes))
end

-- ============================================================================
-- UTF-16LE ENCODING/DECODING
-- ============================================================================

-- converts UTF-16LE byte array to UTF-8 string
function utf16le.decode(data, offset, length)
	offset = offset or 1
	length = length or (#data - offset + 1)

	if length == 0 then
		return ""
	end

	if length % 2 ~= 0 then
		error("UTF-16LE data length must be even, got " .. length)
	end

	local result = {}
	local pos = offset
	local endPos = offset + length - 1

	while pos <= endPos - 1 do
		-- read 16-bit code unit (little-endian)
		local byte1 = data:byte(pos)
		local byte2 = data:byte(pos + 1)
		local code = byte1 + (byte2 * 256)

		pos = pos + 2

		-- check for surrogate pair (handles characters outside BMP)
		if code >= 0xD800 and code <= 0xDBFF then
			-- high surrogate, need low surrogate
			if pos > endPos - 1 then
				error("incomplete surrogate pair at position " .. (pos - 2))
			end

			local byte3 = data:byte(pos)
			local byte4 = data:byte(pos + 1)
			local low = byte3 + (byte4 * 256)

			if low < 0xDC00 or low > 0xDFFF then
				error("invalid low surrogate: " .. low)
			end

			pos = pos + 2

			-- combine surrogates to get actual code point
			code = 0x10000 + ((code - 0xD800) * 0x400) + (low - 0xDC00)
		elseif code >= 0xDC00 and code <= 0xDFFF then
			error("unexpected low surrogate at position " .. (pos - 2))
		end

		-- convert code point to UTF-8
		if code <= 0x7F then
			-- 1-byte UTF-8
			table.insert(result, string.char(code))
		elseif code <= 0x7FF then
			-- 2-byte UTF-8
			table.insert(result, string.char(
					0xC0 + math.floor(code / 64),
					0x80 + (code % 64)
				))
		elseif code <= 0xFFFF then
			-- 3-byte UTF-8
			table.insert(result, string.char(
					0xE0 + math.floor(code / 4096),
					0x80 + (math.floor(code / 64) % 64),
					0x80 + (code % 64)
				))
		elseif code <= 0x10FFFF then
			-- 4-byte UTF-8
			table.insert(result, string.char(
					0xF0 + math.floor(code / 262144),
					0x80 + (math.floor(code / 4096) % 64),
					0x80 + (math.floor(code / 64) % 64),
					0x80 + (code % 64)
				))
		else
			error("invalid code point: " .. code)
		end
	end

	return table.concat(result)
end

-- converts UTF-8 string to UTF-16LE byte string
function utf16le.encode(str)
	local result = {}
	local pos = 1

	while pos <= #str do
		local byte1 = str:byte(pos)
		local code

		if byte1 <= 0x7F then
			-- 1-byte UTF-8
			code = byte1
			pos = pos + 1
		elseif byte1 >= 0xC0 and byte1 <= 0xDF then
			-- 2-byte UTF-8
			local byte2 = str:byte(pos + 1)
			code = ((byte1 - 0xC0) * 64) + (byte2 - 0x80)
			pos = pos + 2
		elseif byte1 >= 0xE0 and byte1 <= 0xEF then
			-- 3-byte UTF-8
			local byte2 = str:byte(pos + 1)
			local byte3 = str:byte(pos + 2)
			code = ((byte1 - 0xE0) * 4096) + ((byte2 - 0x80) * 64) + (byte3 - 0x80)
			pos = pos + 3
		elseif byte1 >= 0xF0 and byte1 <= 0xF7 then
			-- 4-byte UTF-8
			local byte2 = str:byte(pos + 1)
			local byte3 = str:byte(pos + 2)
			local byte4 = str:byte(pos + 3)
			code = ((byte1 - 0xF0) * 262144) + ((byte2 - 0x80) * 4096) + 
			((byte3 - 0x80) * 64) + (byte4 - 0x80)
			pos = pos + 4
		else
			error("invalid UTF-8 byte: " .. byte1)
		end

		-- convert code point to UTF-16LE
		if code <= 0xFFFF then
			-- BMP character, single 16-bit unit
			table.insert(result, string.char(code % 256, math.floor(code / 256)))
		elseif code <= 0x10FFFF then
			-- non-BMP character, surrogate pair needed
			code = code - 0x10000
			local high = 0xD800 + math.floor(code / 0x400)
			local low = 0xDC00 + (code % 0x400)

			table.insert(result, string.char(
					high % 256, math.floor(high / 256),
					low % 256, math.floor(low / 256)
				))
		else
			error("invalid code point: " .. code)
		end
	end

	return table.concat(result)
end

-- reads UTF-16LE string with 32-bit length prefix (QM format)
function utf16le.readString(data, offset)
	offset = offset or 1

	-- read ifString flag (4 bytes)
	local ifString, newOffset = utf16le.readInt32(data, offset)

	if ifString ~= 0 then
		-- read string length in characters (4 bytes)
		local strLen
		strLen, newOffset = utf16le.readInt32(data, newOffset)

		if strLen == 0 then
			return "", newOffset
		end

		-- read UTF-16LE string (strLen * 2 bytes)
		local str = utf16le.decode(data, newOffset, strLen * 2)
		return str, newOffset + strLen * 2
	else
		return "", newOffset
	end
end

-- reads UTF-16LE string with 32-bit length prefix, can return nil
function utf16le.readStringOrNil(data, offset)
	offset = offset or 1

	local ifString, newOffset = utf16le.readInt32(data, offset)

	if ifString ~= 0 then
		local strLen
		strLen, newOffset = utf16le.readInt32(data, newOffset)

		if strLen == 0 then
			return "", newOffset
		end

		local str = utf16le.decode(data, newOffset, strLen * 2)
		return str, newOffset + strLen * 2
	else
		return nil, newOffset
	end
end

-- reads null-terminated UTF-16LE string (0x00 0x00)
function utf16le.readNullTerminated(data, offset)
	offset = offset or 1
	local start = offset

	-- find double null terminator
	while offset <= #data - 1 do
		if data:byte(offset) == 0 and data:byte(offset + 1) == 0 then
			local length = offset - start
			if length == 0 then
				return "", offset + 2
			end
			local str = utf16le.decode(data, start, length)
			return str, offset + 2
		end
		offset = offset + 2
	end

	error("null terminator not found")
end

-- writes UTF-16LE string with 32-bit length prefix (QM format)
function utf16le.writeString(str)
	if not str or str == "" then
		-- write two zeros (no string)
		return string.char(0, 0, 0, 0, 0, 0, 0, 0)
	end

	local encoded = utf16le.encode(str)
	local length = #encoded / 2  -- length in characters, not bytes

	-- write ifString flag (1)
	local result = utf16le.writeInt32(1)

	-- write length in characters
	result = result .. utf16le.writeInt32(length)

	-- write encoded string
	result = result .. encoded

	return result
end

-- writes null-terminated UTF-16LE string
function utf16le.writeNullTerminated(str)
	local encoded = utf16le.encode(str)
	return encoded .. "\x00\x00"
end

-- helper: detects if data is likely UTF-16LE
function utf16le.isUTF16LE(data, offset, length)
	offset = offset or 1
	length = length or math.min(100, #data - offset + 1)

	if length < 4 then
		return false
	end

	local nullCount = 0
	local validChars = 0

	for i = offset, offset + length - 2, 2 do
		local byte1 = data:byte(i)
		local byte2 = data:byte(i + 1)

		-- check for ASCII pattern (common in UTF-16LE)
		if byte1 > 0 and byte1 < 128 and byte2 == 0 then
			validChars = validChars + 1
		end

		-- count null bytes
		if byte1 == 0 then nullCount = nullCount + 1 end
		if byte2 == 0 then nullCount = nullCount + 1 end
	end

	-- heuristic: if many nulls and valid ASCII chars, likely UTF-16LE
	return (nullCount > length * 0.3) and (validChars > length * 0.1)
end

return utf16le