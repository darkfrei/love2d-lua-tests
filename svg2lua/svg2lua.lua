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
--	print (1, input)
--    input = input:gsub("([^%s,;])([%a])", "%1 %2") -- Convert "100D" to "100 D"
    input = input:gsub("([^%s,;])([0-9][%a])", "%1 %2") -- Convert "100DD" to "100 DD"
--	print (2, input)
--    input = input:gsub("([%a])([^%s,;])", "%1 %2") -- Convert "D100" to "D 100"
    input = input:gsub("([0-9][%a])([^%s,;])", "%1 %2") -- Convert "DD100" to "DD 100"
--	print (3, input)
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

local function svg2lua (tabl, input)
	local list = parsePath (input)
	local str = '{'
	for i, component in ipairs (list) do 
		str = str .. '{'.. table.concat(component, ',') ..'},'
	end
	str = str:sub(1, -2) -- remove last comma
	str = str .. '}'
	print (str)
	
	local x, y
	local vertices
	
	local railroad = false
	
	
	local fill = list[1][1] == "F" and list[1][2] or false
	
	local road = list[1][1] == "R" and list[1][2] or false
	
	print ("road", tostring(road))
	-- 
	
	print (1, tostring(tabl))
	local filltable = {fill = fill, withGaps = false}
	if fill then
		
		table.insert (tabl, filltable)
		tabl = filltable
	end
	print (2, tostring(tabl))
	
	for i, c in ipairs (list) do 
		if c[1] == "M" then
			
			-- move
			if vertices and #vertices > 0 then
				filltable.withGaps = true
				table.insert (tabl, vertices)
				print (i, "#M vertices saved", #vertices, unpack(vertices), #tabl)
				vertices = {road=road, fill=fill, railroad=railroad}
			elseif not vertices then
				vertices = {road=road, fill=fill, railroad=railroad}
			end
			for j = 2, #c-1, 2 do
				x, y = c[j], c[j+1]
				table.insert (vertices, x)
				table.insert (vertices, y)
			end
			print ("M #vertices", #vertices)
		elseif c[1] == "H" then
--			if vertices and vertices.bezier and #vertices > 2 then
			if vertices and vertices.bezier then
				table.insert (tabl, vertices)
				vertices = nil
			end
			if not vertices then
				vertices = {road=road, fill=fill, railroad=railroad}
				table.insert (vertices, x)
				table.insert (vertices, y)
			end
			x = c[2]
			table.insert (vertices, x)
			table.insert (vertices, y)
			print ("H #vertices", #vertices)
		elseif c[1] == "V" then
			if vertices and vertices.bezier and #vertices > 2 then
				table.insert (tabl, vertices)
				vertices = nil
			end
			if not vertices then
				vertices = {road=road, fill=fill, railroad=railroad}
				table.insert (vertices, x)
				table.insert (vertices, y)
			end
			y = c[2]
			table.insert (vertices, x)
			table.insert (vertices, y)
			
		elseif c[1] == "L" then
--			if not vertices then
			if vertices and vertices.bezier and #vertices > 2 then
--			if vertices and #vertices > 2 then
				table.insert (tabl, vertices)
				vertices = nil
			end
			if (not vertices) then
				vertices = {road=road, fill=fill, railroad=railroad}
				table.insert (vertices, x)
				table.insert (vertices, y)
			end

			for j = 2, #c-1, 2 do
				x, y = c[j], c[j+1]
				table.insert (vertices, x)
				table.insert (vertices, y)
			end
--			table.insert (tabl, vertices)
		elseif c[1] == "C" then
			-- bezier
			if vertices and #vertices > 2 then
				table.insert (tabl, vertices)
			end
			vertices = {road=road, fill=fill, bezier=true, railroad=railroad}
			table.insert (vertices, x)
			table.insert (vertices, y)
			for j = 2, #c-1, 2 do
--				print (j, 'bezier', x, y)
				x, y = c[j], c[j+1]
				table.insert (vertices, x)
				table.insert (vertices, y)
			end
--			print (j, 'bezier', x, y)
--			table.insert (tabl, vertices)
--			vertices = nil
		elseif c[1] == "R" then
			road = c[2]
		elseif c[1] == "F" then
			fill = c[2]
		elseif c[1] == "RR" then
			railroad = true
		end
	end
	
	if #vertices > 2 then
		table.insert (tabl, vertices)
		print ('saved last  #vertices	', #vertices, unpack(vertices), #tabl)
		
	else
		print ('not enougth #vertices', #vertices, unpack(vertices), #tabl)
	end
end



return svg2lua
