local nl = string.char(10) -- newline
function serialize_list (tabl, indent)
	indent = indent and (indent.."	") or ""
	local str = ''
	str = str .. indent.."{"
	for key, value in pairs (tabl) do
		local pr = (type(key)=="string") and ('["'..key..'"]=') or ""
		if type (value) == "table" then
			str = str..nl..pr..serialize_list (value, indent)..','
		elseif type (value) == "string" then
			str = str..nl..indent..pr..'"'..tostring(value)..'",'
		else
			str = str..nl..indent..pr..tostring(value)..','
		end
	end
	str = str:sub(1, #str-1) -- remove last symbol
	str = str .. nl..indent.."}"
	return str
end

