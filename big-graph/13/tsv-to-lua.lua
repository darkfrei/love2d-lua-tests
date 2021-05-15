-- stript reads file "big_tables.txt" (text with tab separated values)
-- every line is one value; tab separates indexes
-- example with two graphs, each with 4 values:
--[[
	123	456
	125	450
	130	440
	133	435
]]

local to_tsv = function (filename)
	local lines = love.filesystem.lines(filename)
	
	local tables = {}
	for line in lines do 
		local i = 1
		for value in (string.gmatch(line, "[^%s]+")) do  -- tab separated values
			tables[i]=tables[i]or{}
			tables[i][#tables[i]+1]=tonumber(value)
			i=i+1
		end
	end
	return tables
end

return to_tsv
