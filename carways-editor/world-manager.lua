-- world-manager.lua

local WorldManager = {}
local ssl = require ('SafeSaveLoad')

-- world: stores information about levels
-- if world.dat exists, then from world.dat
WorldManager.world = {
	{ index = 1, row = 1, col = 1 },
	{ index = 2, row = 1, col = 2 },
	{ index = 3, row = 2, col = 1 },
	{1, 2, 3, 4},
	{'a', 'b', 'c'},
	
}



-- progress: stores information about progress
-- if progress.dat exists, then from progress.dat
WorldManager.progress = {
	openedLevels = { 1 }, -- list of levels that are open
	completedLevels = {}, -- list of completed levels
	currentLevelIndex = 1
}

-- function to save progress to a file (progress.dat)
function WorldManager.saveProgress()
	local progress = WorldManager.getProgress()
	local data = love.filesystem.newFileData(progress, "progress.dat")
	love.filesystem.write("progress.dat", data)
end


function WorldManager.saveWorld()
	local data = ssl.serializeTable(WorldManager.world)
	local file = io.open('world.dat', 'w')
	if file then
		file:write(data)
		file:close()
		print("WorldManager.world: saved")
	else
		print("WorldManager.world: not saved")
	end
end

function WorldManager.loadWorld()
	local file = io.open("world.dat", "r")
	if file then
		local str = file:read("*a")
		file:close()
		local world = ssl.deserializeString(str)
		WorldManager.world = world
		print("WorldManager.world: loaded")
	else
		print("WorldManager.world: not loaded")
	end
end

--serpent = require ('serpent')

function WorldManager.initWorld()
	if not love.filesystem.getInfo("world.dat") then
		WorldManager.saveWorld()
	else
		WorldManager.loadWorld()
--		print('serpent WorldManager.world')
--		print(serpent.block (WorldManager.world))
	end
end

WorldManager.initWorld()





return WorldManager
