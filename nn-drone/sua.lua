sua = {}

sua.serialize = function (tabl, indent)
	indent = indent and indent .. '	' or '	'
	local str = indent..'{'
	local bool = true
	for i, v in pairs (tabl) do
		local pr = (type(i)=="string") and i..'=' or ''
		if type (v) == "table" then
			str=str..string.char(10) -- new line before table
			str = str..pr.. sua.serialize(v, indent)..','..string.char(10)
			bool = true
		elseif type (v) == "string" then
			str = str..pr..'"'..tostring(v)..'"'..','
			bool = false
		else
			str = str..pr..tostring(v)..','
			bool = false
		end
	end
	if bool then
		str = str:sub(1, -3) -- remove last comma and char10
	else
		str = str:sub(1, -2) -- remove last comma
	end
	str=str..'}'
	return str
end

sua.load_table = function (name)
	local chunk, errormsg = love.filesystem.load( name..'.lua' )
	if not (errormsg) then
		return chunk()
	else
		print('errormsg: '..errormsg)
	end
end


sua.savetable = function (tabl, name)
	love.filesystem.write(name..".lua", 'return '.. sua.serialize(tabl))
end

return sua