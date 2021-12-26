unpack = unpack or table.unpack


--.	all characters
--%a	letters
--%c	control characters
--%d	digits
--%l	lower case letters
--%p	punctuation characters
--%s	space characters
--%u	upper case letters
--%w	alphanumeric characters
--%x	hexadecimal digits
--%z	the character with representation 0

-- pattern = ([MmZzLlHhVvCcSsQqTtAa])([^MmZzLlHhVvCcSsQqTtAa]*)

--local bigLetterExpression = "[A-Z]" -- M
--local smallLetterExpression = "[a-z]"
--local numbExpr = "[%d+][%.%d+]?"
--local numbExpr = "%d+.%d+" -- 40.1	nil	nil

--local str = "M 40.1,360 H -40"

--local a, b = string.match (str, "%d+ %a+")
--print (a, b) -- 360 H	nil

--local a, b = string.match (str, "(%d+) (%a+)")
--print (a, b) -- 360	H

--local a, b, c = string.match (str, bigLetterExpression..'%s'..numbExpr)
--local a, b, c = string.match (str, "%a%s%d+%.%d+,%d+")
--print (a, b, c) -- M	40	nil


--local list = string.match ()


local function parsePath (input)
    input = input:gsub("([^%s,;])([%a])", "%1 %2") -- Convert "100D" to "100 D"
    input = input:gsub("([%a])([^%s,;])", "%1 %2") -- Convert "D100" to "D 100"
	local output, line = {}
	for v in input:gmatch("([^%s,;]+)") do
        if tonumber(v) then
			line[#line+1] = math.floor(tonumber(v)+0.5)
		else
			line = {v}
            output[#output+1] = line
        end
    end
    return output
end

local function svg2lua (input)
	local list = parsePath (input)
	local str = '{'
	for i, component in ipairs (list) do 
		str = str .. '{'.. table.concat(component, ',') ..'},'
	end
	str = str:sub(1, -2) -- remove last comma
	str = str .. '}'
	print (str)
	
	local x, y
	local vertices = {}
	for i, c in ipairs (list) do 
		if c[1] == "M" then
			for j = 2, #c-1, 2 do
				x, y = c[j], c[j+1]
				table.insert (vertices, x)
				table.insert (vertices, y)
			end
		elseif c[1] == "H" then
			x = c[2]
			table.insert (vertices, x)
			table.insert (vertices, y)
		elseif c[1] == "V" then
			y = c[2]
			table.insert (vertices, x)
			table.insert (vertices, y)

		elseif c[1] == "L" then
			for j = 2, #c-1, 2 do
				x, y = c[j], c[j+1]
				table.insert (vertices, x)
				table.insert (vertices, y)
			end
		elseif c[1] == "C" then
			-- bezier
			vertices.bezier = true
			for j = 2, #c-1, 2 do
				x, y = c[j], c[j+1]
				table.insert (vertices, x)
				table.insert (vertices, y)
			end
		elseif c[1] == "F" then
			vertices.fill = true
		end
	end
	return vertices
end

return svg2lua