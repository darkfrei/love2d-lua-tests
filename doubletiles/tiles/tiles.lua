-- tiles

--neigbours:
--	1	2	3

--	4	5	6

--	7	8	9

unpack = unpack or table.unpack

local source = {
	{name = '1',	5, 6, 8, 9},
	{name = '2', 	4, 5, 6, 7, 8, 9},
	{name = '2-1',	4, 5, 6, 7, 8, 9},
	{name = '3',	4, 5, 7, 8},
	{name = '4',	2, 3, 5, 6, 8, 9},
	{name = '4-1',	2, 3, 5, 6, 8, 9},
	{name = '5',	1, 2, 3, 4, 5, 6, 7, 8, 9},
	{name = '5-1',	1, 2, 3, 4, 5, 6, 7, 8, 9},
	{name = '5-2',	1, 2, 3, 4, 5, 6, 7, 8, 9},
	{name = '5-3',	1, 2, 3, 4, 5, 6, 7, 8, 9},
	{name = '6',	1, 2, 4, 5, 7, 8},
	{name = '6-1',	1, 2, 4, 5, 7, 8},
	{name = '7',	3, 4, 5, 6, 7, 8, 9},
	{name = '8',	2, 3, 4, 5, 6, 7, 8, 9},
	{name = '9',	1, 2, 3, 4, 5, 6},
	{name = '9-1',	1, 2, 3, 4, 5, 6},
	{name = '10',	1, 2, 4, 5, 6, 7, 8, 9},
	{name = '11',	1, 4, 5, 6, 7, 8, 9},
	{name = '12',	2, 3, 5, 6},
	{name = '13',	1, 2, 4, 5},
}

local types = {}
for i, tile in ipairs (source) do
	local name = tile.name
	local nr = 0
	for j, value in ipairs (tile) do
		if value < 5 then
			nr = nr + 2^(value-1)
		elseif value > 5 then
			nr = nr + 2^(value-2)
		end
	end
	if not types[nr] then types[nr] = {} end
	table.insert (types[nr], tile)
end

for nr, typ in pairs (types) do
	for i, tile in ipairs (typ) do
--		print (i, nr, '"'..tile.name..'"')
		print (i, nr, '"'..tile.name..'"', unpack (tile))
	end
end

local function toBits(num, bits)
    -- returns a table of bits, least significant first.
    local t={} -- will contain the bits
	bits = bits or 8
    while num>0 do
        rest=math.fmod(num,2)
        t[#t+1]=rest
        num=math.floor((num-rest)/2)
    end
	for i = #t+1, bits do -- fill empty bits with 0
		t[i] = 0
	end
    return t
end

local function bitsToNumber (bits)
	local nr = 0
	for i, bit in ipairs (bits) do
		nr = nr + bit*2^(i-1)
	end
	return math.floor(nr)
end

local function toTyp (map, j, i) -- map, x, y
--	local bits = {
--		map[i-1][j-1],	map[i][j-1], map[i+1][j-1], 
--		map[i-1][j], 				 map[i+1][j], 
--		map[i-1][j+1], 	map[i][j+1], map[i+1][j+1], 
--	}
	local bits = {
		map[i-1][j-1],	map[i-1][j], map[i-1][j+1], 
		map[i][j-1], 				 map[i][j+1], 
		map[i+1][j-1], 	map[i+1][j], map[i+1][j+1], 
	}
	return bitsToNumber (bits)
end

local function isBitsValid (bits)
--	1	2	3
--	4	/	5
--	6	7	8
	if bits[1] == 1 and (bits[2] == 0 and bits[4] == 0) then return false end
	if bits[3] == 1 and (bits[2] == 0 and bits[5] == 0) then return false end
	if bits[6] == 1 and (bits[4] == 0 and bits[7] == 0) then return false end
	if bits[8] == 1 and (bits[5] == 0 and bits[6] == 0) then return false end
	return true
end

local allTypes = {}
--local validTypes = {}
local validTypes = {0,2,3,6,7,8,9,10,11,14,15,16,18,19,20,22,23,24,25,26,27,28,29,30,31,40,41,42,43,46,47,56,57,58,59,60,61,62,63,64,66,67,70,71,72,73,74,75,78,79,80,82,83,84,86,87,88,89,90,91,92,93,94,95,96,98,99,102,103,104,105,106,107,110,111,112,114,115,116,118,119,120,121,122,123,124,125,126,127,144,146,147,148,150,151,152,153,154,155,156,157,158,159,168,169,170,171,174,175,184,185,186,187,188,189,190,191,208,210,211,212,214,215,216,217,218,219,220,221,222,223,224,226,227,230,231,232,233,234,235,238,239,240,242,243,244,246,247,248,249,250,251,252,253,254,255}

local tiles = {}
for nr = 0, 255 do
	local bits = toBits(nr)
	
	
	if isBitsValid (bits) then
--		local nr = bitsToNumber (bits)
--		print ('n', n, 'nr', nr)
--		print(n, table.concat(bits, '	'))
		local map = {
			{bits[1], bits[2], bits[2], bits[3]},
			{bits[4], 		1, 		1, bits[5]},
			{bits[4], 		1, 		1, bits[5]},
			{bits[6], bits[7], bits[7], bits[3]},
		}
		
		local tileValid = true
		local tile = {nr=nr}
		for i = 2, 3 do -- x
			for j = 2, 3 do -- y
				local typNr = toTyp (map, i, j)
--				local amount = 0
--				if types[typNr] then amount = #types[typNr] end
--				print (typNr, amount)
				if types[typNr] then 
					table.insert (tile, typNr)
				else
					tileValid = false 
				end
				
			end
		end
		if tileValid then
			table.insert (tiles, tile)
		end
	end
end

print ('#tiles', #tiles)
for i, tile in ipairs (tiles) do
	print('{', table.concat(tile, ','),'},')
end

--print (unpack(tiles))


return {types=types, tiles=tiles}

--print (table.concat(validTypes, ','))

