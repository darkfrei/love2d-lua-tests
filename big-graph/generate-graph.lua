-- run as Lua 5.3
math.randomseed( os.time() )

print (filename)

local nl = string.char(10) -- new line
local tab = '	'
local str = 'return {'
local sep = '---------------------------------------------------------------------------------------------------'
local value = 0 
local vel = 0
local acc = 0

local appdata = true
--local filename = 'big-table.lua' -- was defined in main.lua

if appdata then
	success, message = love.filesystem.write( filename, str..nl)
	str = ''
else
	file = io.open( 'big-table.lua', "w" )
end

local colors = {{1,1,1},{1,1,0}}


for n = 1, 2 do
	value = 0
	local color = colors[n]
	if n>1 then
		str = str .. sep .. nl
	end
	str = str .. tab .. '{' .. nl
	str = str .. tab .. "color = " .. "{" .. table.concat( color, "," ) .. "}," .. nl .. tab
	for i = 1, 20000 do
--	for i = 1, 20000000 do
		acc = math.random(3)-2
		vel = vel + acc
		vel = math.max(math.min(vel, 5), -5)
		value = value + vel
		if (value < 0) then -- I want positive only
--			vel = -vel
			vel = 0
			value = -value
		end
		str = str .. value .. ','
		if (i%10000)==0 then
			if appdata then
				love.filesystem.append(filename, str .. nl)
			else
				file:write(nl, str)
			end
				
			str = tab
			print (i)
		end
	end
	
	str = str .. sep .. nl
	
	str = str .. tab .. '},' .. nl
end


str = str .. '}'


if appdata then
	love.filesystem.append(filename, str)
else
	file:write(str)
	file:close()
end
