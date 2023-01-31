--	CC0 “No Rights Reserved” / darkfrei 2023
--	https://creativecommons.org/share-your-work/public-domain/cc0/
--	load and save table separeted values;
--	for LÖVE (Love2d), Lua

--[[ it can save a table with one list layer as
	NicsTable = {	-- table of values
		b="yes",
		d="text",
		c=false,
		a=true,
		e={2, 3, 4, true, "text"}, -- list of values
		[1]=1,
		[2]=true,
		[3]=false,
		[4]="text",
		true="yes",
		false="no",
	}
]]


table.concat2 = function(tabl, sep)
	local str = ""
	for i, v in ipairs(tabl) do
		str = str .. tostring(v) .. (i ~= #tabl and sep or "") 
	end
	return str
end

local ST = {}

local function getList (stringLine)
	local list = {}
--	for value in (string.gmatch(stringLine, "[^%s]+")) do  -- tab separated values
	for value in (string.gmatch(stringLine, "[^%\t]+")) do  -- tab separated values
		if type(tonumber (value)) == "number" then
			table.insert (list, tonumber (value))
		elseif value == "true" then
			table.insert (list, true)
		elseif value == "false" then
			table.insert (list, false)
		elseif value == "nil" then
			table.insert (list, nil) -- do nothing :(
		else
			table.insert (list, value)
		end
	end
	return list
end

function ST.load (filename)
--	local lines = io.lines(filename..".tsv") -- open file as lines
	local lines = love.filesystem.lines(filename..".tsv") -- open file as lines
	
	local tabl = {}
	for line in lines do -- row iterator
		local list = getList (line)
		if list[1] and list[1] == "--" then
			-- exception: commented
		elseif #list < 2 then
			-- exception: no value
		elseif #list == 2 then
			tabl[list[1]] = list[2]
		elseif #list > 2 then
			local list2 = {}
			for i = 2, #list do
				table.insert (list2, list[i])
			end
			tabl[list[1]] = list2
		end
	end
	return tabl
end

function ST.save (filename, tabl)
	local str = ""
	for index, value in pairs (tabl) do
		if type (value) == "table" then
			str = str .. tostring(index)..'	'.. table.concat2 (value, '	')
		else
			str = str .. tostring(index)..'	'.. tostring (value)
		end
		str = str .. '\n'
	end
	
	local success, message =love.filesystem.write( filename..'.tsv', str)
	if success then
		print ('saved')
	end
end

function ST.remove (filename)
	love.filesystem.remove( filename .. '.tsv' )
end

function ST.print (index, strtabl, x, y)
	if type (index) == "string" then
		index = '"'..index..'"'
	end
	if type (strtabl) == "table" then
		love.graphics.print (index..' = {'..table.concat2(strtabl, ', ')..'}', x, y)
	elseif type (strtabl) == "string" then
		love.graphics.print (tostring(index)..' = "'..tostring(strtabl)..'"', x, y)
	else
		love.graphics.print (tostring(index)..' = '..tostring(strtabl), x, y)
		
	end
end


return ST