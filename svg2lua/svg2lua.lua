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
	local vertices = {}
	local road = false
	local bezier = false
	local fill = false
	for i, c in ipairs (list) do 
		if c[1] == "M" then
			if #vertices > 2 then
				table.insert (tabl, vertices)
			end
			vertices = {road=road, fill=fill, bezier=bezier}
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
			fill = true
		elseif c[1] == "R" then
			road = c[2]
		end
	end
	if #vertices > 2 then
		
		table.insert (tabl, vertices)
	end
end



return svg2lua


--{{M,40,360},{H,-40},{R,1}}
--{{M,-40,480},{H,40},{R,1}}
--{{M,840,1000},{V,920},{R,1}}
--{{M,720,920},{V,1000},{R,1}}
--{{M,1280,-40,1200,40},{R,1}}
--{{M,1320,40,1400,-40},{R,1}}
--{{M,40,480},{H,360},{R,1}}
--{{M,760,360,400,360},{R,1}}
--{{M,1120,240,1320,40},{R,1}}
--{{M,400,360,40,360},{R,1}}
--{{M,840,920},{C,840,680,1040,320,1120,240},{R,1}}
--{{M,1200,40},{C,1160,80,1120,120,1080,160},{R,1}}
--{{M,1080,160},{C,920,320,520,360,400,360},{R,1}}
--{{M,360,480},{C,520,480,720,760,720,920},{R,1}}
--{{M,760,360},{C,640,360,560,520,640,600},{R,1}}
--{{M,640,600},{C,720,680,840,640,880,560},{R,1}}
--{{M,880,560},{C,920,480,880,360,760,360},{R,1}}
--{{M,1080,160},{C,1040,200,920,360,760,360},{R,1}}
--{{M,360,480},{C,480,480,560,520,640,600},{R,1}}
--{{M,640,600},{C,720,680,720,840,720,920},{R,1}}
--{{M,840,920},{C,840,800,840,640,880,560},{R,1}}
--{{M,880,560},{C,920,480,1120,240,1120,240},{R,1}}
--{{M,0,600},{H,360},{L,600,840},{V,960},{H,0},{F,0}}
--{{M,1440,0},{H,1920},{V,960},{H,960},{V,720},{F,0}}
--{{M,0,0},{H,1080},{L,840,240},{H,0},{F,0}}