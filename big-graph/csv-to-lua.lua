-- stript reads file "big_tables.txt" (text with tab separated values)
-- every line is one value; tab separates indexes
-- example with two graphs, each with 4 values:
--[[
	123	456
	125	450
	130	440
	133	435
]]


--local filename = "big_tables.txt"
local filename = "big_tables.csv"

local lines = io.lines(filename)

local tables = {}
for line in lines do 
--	print(line)
	local i = 1
--	for value in (string.gmatch(line, "[^%s]+")) do  -- tab separated values
	for value in (string.gmatch(line, '%d[%d.]*')) do -- comma separated values
--		print (value)
		tables[i]=tables[i]or{}
		tables[i][#tables[i]+1]=tonumber(value)
		i=i+1
	end
end

--tables[2].a = "a" -- just for test
--tables.b = "b"

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

local str = serialize_list(tables)
print('return '..nl..str)

local file,err = io.open("big_tables.lua",'w')
if file then
	file:write('return '..nl..tostring(str))
	file:close()
else
	print("error:", err)
end