-- main.lua
-- converts QM/QMM files to Lua tables using serpent serialization

local qmreader = require("qmreader")
local serpent = require("serpent")  -- https://github.com/pkulchenko/serpent
local zip = require("zip")

local function loadFile(filename)
	local file = io.open(filename, "rb")
	if not file then
		error("Cannot open file: " .. filename)
	end
	local data = file:read("*all")
	file:close()
	return data
end

local function saveFile(filename, content)
	local file = io.open(filename, "w")
	if not file then
		error("Cannot create file: " .. filename)
	end
	file:write(content)
	file:close()
end

local function convertQmToLua(inputFilename)
	print("Reading: " .. inputFilename)

	-- load binary data
	local data = loadFile(inputFilename)

	-- parse QM file
	local quest = qmreader.parse(data)

	-- serialize to Lua
	local luaCode = serpent.block(quest, {
			comment = false,
			sortkeys = true,
			compact = false,
		})

	-- generate output filename
	local outputFilename = inputFilename:gsub("%.qmm?$", "") .. ".lua"

	print("Writing: " .. outputFilename)
	saveFile(outputFilename, luaCode)
	
	local archive = zip.new()
	-- addFile(archive, filename, data, compress_data)
	zip.addFile(archive, outputFilename, luaCode, true)
	zip.save(archive, outputFilename..".zip")

	print("Done! Converted successfully.")
	print(string.format("  Locations: %d", #quest.locations))
	print(string.format("  Jumps: %d", #quest.jumps))
	print(string.format("  Parameters: %d", #quest.params))
end


--[[
-- command line usage
if arg[1] then
	convertQmToLua(arg[1])
else
	print("Usage: lua main.lua <quest.qm|quest.qmm>")
	print("Example: lua main.lua Prison.qm")
end

--]]

print ('start')
convertQmToLua('quest.qmm')
print ('end')