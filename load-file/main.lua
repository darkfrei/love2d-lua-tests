-- License CC0 (Creative Commons license) (c) darkfrei, 2022

love.window.setMode(1280, 800) -- Steam Deck resolution

local function  split (string, separator)
	local tabl = {}
	for str in string.gmatch(string, "[^"..separator.."]+") do
		table.insert (tabl, str)
	end
	return tabl
end

local function  split2 (string)
	local tabl = {}
	string:gsub(".", function(c) table.insert(tabl, tonumber (c)) end)
	return tabl
end


local function loadlevels(filename)
	local info = love.filesystem.getInfo(filename)
	if info then
	
		local levelIndex = 0
		local iterator = love.filesystem.lines(filename)
		local levels = {}
		for line in iterator do
			local level = {}
			print (line)
			for y, rowString in ipairs (split (line, "%p")) do -- symbol #
				print (y, rowString, 'elements:')
				local elements = split2 (rowString)
				print (y, "#elements", #elements)
				level[y] = elements
			end
			table.insert (levels, level)
		end
		return levels
	else
		print('error: could not read ["'.. filename ..'"] as it does not exist.')
		love.event.quit()
	end
end

local levels = loadlevels("levels.txt")



local function drawLevel(nLevel, ox, oy, tileSize)
	local level = levels[nLevel]
	for y = 1, #level do
		for x = 1, #level[y] do
			if level[y][x] == 1 then
				love.graphics.rectangle("fill", (x-1+ox)*tileSize, (y-1+oy)*tileSize, tileSize, tileSize)
			end
		end
	end
end

NLevel = 1

function love.draw ()
	love.graphics.print ('NLevel = '.. NLevel)
	drawLevel(NLevel, 1, 1, 20)
end


function love.keypressed(key, scancode, isrepeat)
	if false then 
	elseif key == "a" then
		NLevel = NLevel + 1
		if NLevel > #levels then NLevel = 1 end
	elseif key == "d" then
		NLevel = NLevel - 1
		if NLevel < 1 then NLevel = #levels end
	elseif key == "escape" then
		love.event.quit()
	end
end
