
function deepStructure (tabl, struct)
	local str = struct.." = {}" .. '\n'
	for i, v in pairs (tabl) do
		local index = type (i) == "string" and '.'..i or '['..i..']'
		if type (v) == "table" then
			str = str .. deepStructure (v, struct..index) .. '\n'
		elseif (type (v) == "string") then
			str = str .. struct .. index .. ' = ' .. '"'..tostring (v)..'"' .. '\n'
		else
			str = str .. struct .. index .. ' = ' .. tostring (v) .. '\n'
		end
	end
	return string.sub(str, 1, -2)
end

data = {1,2,3, t = {a="a", b="b", c=true, {7, true, "text"}}}

print (deepStructure (data, "data"))

--[[
data = {}
data[1] = 1
data[2] = 2
data[3] = 3
data.t = {}
data.t[1] = {}
data.t[1][1] = 7
data.t[1][2] = true
data.t[1][3] = "text"
data.t.b = "b"
data.t.a = "a"
data.t.c = true
--]]