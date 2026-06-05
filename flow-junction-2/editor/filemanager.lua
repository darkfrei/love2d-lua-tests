-- editor/filemanager.lua
-- save and load utilities for intersection network maps

local FileManager = {}
local SAVE_DIR = "saves"

function FileManager.init()
	if not love.filesystem.getInfo(SAVE_DIR) then
		love.filesystem.createDirectory(SAVE_DIR)
	end
end

function FileManager.listSaves()
	FileManager.init()

	local files = love.filesystem.getDirectoryItems(SAVE_DIR)
	local out = {}

	for _, f in ipairs(files) do
		if f:match("%.lua$") then
			out[#out + 1] = f
		end
	end

	table.sort(out)

	return out
end

function FileManager.generateName(base)
	base = base or "map"

	local i = 1

	while true do
		local name = base .. "_" .. i .. ".lua"
		local path = SAVE_DIR .. "/" .. name

		if not love.filesystem.getInfo(path) then
			return name
		end

		i = i + 1
	end
end

function FileManager.save(filename, data)
	FileManager.init()

	local path = SAVE_DIR .. "/" .. filename

	local file = love.filesystem.newFile(path, "w")
	if not file then
		return false, "cannot open file"
	end

	file:write(data)
	file:close()

	return true
end

function FileManager.load(filename)
	local path = SAVE_DIR .. "/" .. filename

	local chunk = love.filesystem.load(path)
	if not chunk then
		return nil, "cannot load file"
	end

	local ok, result = pcall(chunk)
	if not ok then
		return nil, result
	end

	return result
end

return FileManager