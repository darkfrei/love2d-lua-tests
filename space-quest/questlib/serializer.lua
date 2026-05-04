local serializer = {}

-- minimal safe lua table dumper
local function dump_value(v, indent)
	indent = indent or ""
	local t = type(v)
	if t == "string" then return string.format("%q", v) end
	if t == "number" or t == "boolean" then return tostring(v) end
	if t == "nil" then return "nil" end
	if t == "table" then
		local res = "{\n"
		local next_indent = indent .. "  "
		for k, val in pairs(v) do
			local key = type(k) == "number" and k or string.format("[%q]", k)
			res = res .. next_indent .. key .. " = " .. dump_value(val, next_indent) .. ",\n"
		end
		return res .. indent .. "}"
	end
	return "nil"
end

-- choose filesystem backend
local function get_fs()
	if love and love.filesystem then return love.filesystem end
	return io
end

-- save any lua table to file
function serializer.save_table(path, data)
	local str = "return " .. dump_value(data)
	local fs = get_fs()
	if fs.write then
		local ok, err = fs.write(path, str)
		return ok == true, err
	else
		local f, err = io.open(path, "w")
		if not f then return false, err end
		f:write(str)
		f:close()
		return true
	end
end

-- load lua table from file
function serializer.load_table(path)
	local fs = get_fs()
	local content
	if fs.read then
		content = fs.read(path)
	else
		local f, err = io.open(path, "r")
		if not f then return nil, err end
		content = f:read("*all")
		f:close()
	end
	if not content then return nil, "file empty or missing" end
	local fn, err = load(content, path, "t", {})
	if not fn then return nil, err end
	local ok, res = pcall(fn)
	return ok and res or nil, res
end

return serializer