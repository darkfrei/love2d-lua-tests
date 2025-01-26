-- world-manager.lua

-- todo:
-- F2 to show debug

local WorldManager = {}
local SafeSaveLoad = require ('SafeSaveLoad')

-- world: stores information about levels
-- if world.dat exists, then from world.dat

------------- utils data

local cardinalOffsets = { -- keyboard keys
	down = { dx = 0, dy = 1 },
	right = { dx = 1, dy = 0 },
	up = { dx = 0, dy = -1 },
	left = { dx = -1, dy = 0 },
}

------------- end utils data

------------ world


function WorldManager.generateNewLevelIndex ()
	-- increment the last level index and return it
	WorldManager.world.lastLevelIndex = WorldManager.world.lastLevelIndex + 1
	return WorldManager.world.lastLevelIndex
end

---------------------------

function WorldManager.createNewWorldLevel (col, row, enabled)
	local index = WorldManager.generateNewLevelIndex ()
	local worldLevel = {  -- default level structure
		index = index, 
		col = col, -- x or w
		row = row, -- y or h
		enabled = enabled,
		neighbours = {},
	}


	table.insert (WorldManager.world.worldLevels, worldLevel)

	if enabled then
		local extendedOffsets = UtilsData.extendedOffsets
		for offsetName, offset in pairs (extendedOffsets) do
			local col2 = col + offset.dx
			local row2 = row + offset.dy
			if not (WorldManager.getWorldLevelByPosition (col2, row2)) then
				local otherWorldLevel = WorldManager.createNewWorldLevel (col2, row2, false)
				local otherWorldLevelIndex = otherWorldLevel.index

				local oppositeOffsetName = UtilsData.extendedOffsetOpposites[offsetName]

				worldLevel.neighbours[offsetName] = otherWorldLevelIndex

				otherWorldLevel.neighbours[oppositeOffsetName] = index

				print ('level '..index..' has '..offsetName..' neighbour: '..otherWorldLevelIndex)
				print ('and level '..otherWorldLevelIndex..' has '..oppositeOffsetName..' neighbour: '..index)

			end
		end

	end
	return worldLevel
end



function WorldManager.generateNewEntityIndex ()
	WorldManager.world.entityIndex = WorldManager.world.entityIndex + 1
	return WorldManager.world.entityIndex
end

function WorldManager.initWorld()
	-- initializes the world structure with default values
	WorldManager.world = {
		worldLevels = {}, -- list of all levels; structures
		lastLevelIndex = 0, -- index of the last added level
		entityIndex = 0, -- main entity index iterator
	}

	WorldManager.createNewWorldLevel (1,1, true)
end


function WorldManager.loadWorld()
	-- loads world from the file or initializes default world if not found
	local filename = 'world.dat'
	local file = io.open(filename, "r")
	if file then
		local str = file:read("*a")
		file:close()
--		local success, world = pcall(SafeSaveLoad.deserializeString, str)
		local world = SafeSaveLoad.deserializeString (str)
		if type(world) == "table" then
			WorldManager.world = world
			print("WorldManager.world: loaded")
			if world.worldLevels then
				print (' WorldManager.loadWorld()', 'Levels are loaded:', #world.worldLevels)
			else
				print (' WorldManager.loadWorld()', 'Levels are not loaded', '###########')
			end
		else
			print("WorldManager.world: invalid or corrupted")
			WorldManager.initWorld()
		end
	else
		print("WorldManager.world: not found")
		WorldManager.initWorld()
	end
end


function WorldManager.saveWorld()
	-- saves the current world to a file, creating a backup of the existing file
	local data = SafeSaveLoad.serializeTable(WorldManager.world)
	local filename = 'world.dat'

	-- create a backup of the existing file if it exists
--	if love.filesystem.getInfo(filename) then
--		if not os.rename(filename, filename .. ".bak") then
--			print("Warning: failed to create a backup of " .. filename)
--		end
--	end

	-- write the new world data to the file
	local file = io.open(filename, 'w')
	if file then
		file:write(data)
		file:close()
		print("WorldManager.world: saved")
	else
		print("WorldManager.world: not saved")
	end
end

------------ end world

------------ progress

function WorldManager.initProgress()
	-- initializes the progress structure with default values
	WorldManager.progress = {
		openedLevels = { 1 }, -- list of opened levels
		completedLevels = {}, -- list of completed levels
		currentLevelIndex = 1, -- index of the current level
		levels = {} -- data for each level
	}

	--[[ -- each level structure:
	{
		currentSolution = "current-solution-1.dat", -- filename of the current solution
		bestSolution = "best-solution-1.dat", -- filename of the best solution
		bestSolutionScore = 500 -- integer score for the best solution
	}
	--]]
end

function WorldManager.loadProgress()
	-- loads progress from the file or initializes default progress if not found
	local filename = 'progress.dat'

-- option 1
--	local file = love.filesystem.read(filename, "r")

-- option 2
	local file = io.open(filename, "r")

	if file then
		local str = file:read("*a")
		file:close()
		local success, progress = pcall(SafeSaveLoad.deserializeString, str)
		if success and type(progress) == "table" then
			WorldManager.progress = progress
			print("WorldManager.progress: loaded")
		else
			print("WorldManager.progress: invalid or corrupted")
			WorldManager.initProgress()
		end
	else
		print("WorldManager.progress: not found")
		WorldManager.initProgress()
	end
end

function WorldManager.saveProgress()
	-- saves the current progress to a file, creating a backup of the existing file
	local data = SafeSaveLoad.serializeTable(WorldManager.progress)
	local filename = 'progress.dat'

	-- create a backup of the existing file if it exists
--	if love.filesystem.getInfo(filename) then
--		if not os.rename(filename, filename .. ".bak") then
--			print("Warning: failed to create a backup of " .. filename)
--		end
--	end

	-- write the new progress data to the file
	local file = io.open(filename, 'w')
	if file then
		file:write(data)
		file:close()
		print("WorldManager.progress: saved")
	else
		print("WorldManager.progress: not saved")
	end
end


------------ end of progress



function WorldManager.changeLevel (currentLevelIndex, offsetKey)
	local curentWorldLevel
	local  worldLevels = WorldManager.world.worldLevels

	-- find the current world level based on its index
	for _, worldLevel in ipairs (worldLevels) do
		if worldLevel.index == currentLevelIndex then
			curentWorldLevel = worldLevel
			break
		end
	end

	if not curentWorldLevel then
		error ('no current level: '..currentLevelIndex)
	end

	local offset = cardinalOffsets[offsetKey]
	if not offset then error ('no offset: '..offsetKey) end

	local newWorldLevel

	local col = curentWorldLevel.col + offset.dx
	local row = curentWorldLevel.row + offset.dy


	for _, worldLevel in ipairs (WorldManager.world.worldLevels) do
		if col == worldLevel.col and row == worldLevel.row then
--			print ('worldLevel already exists!', worldLevel.index, worldLevel.col, worldLevel.row)
			newWorldLevel = worldLevel
			break
		end
	end



	if not newWorldLevel then
		newWorldLevel = WorldManager.createNewWorldLevel (col, row, false)
--		print (offsetKey, 'added new world level: '.. newWorldLevel.index, col, row)
	end
	local worldLevelIndex = newWorldLevel.index




	love.window.setTitle ('Level: '..worldLevelIndex.. ' row: '..row..' col: '..col)

	return newWorldLevel
end

function WorldManager.getWorldLevelByIndex (index)
	for i, worldLevel in ipairs (WorldManager.world.worldLevels) do
		if worldLevel.index == index then
			return worldLevel
		end
	end
end

function WorldManager.getWorldLevelByPosition (col, row)
	local worldLevels = WorldManager.world.worldLevels
	for i, worldLevel in ipairs (worldLevels) do
		if worldLevel.col == col and worldLevel.row == row then
			return worldLevel
		end
	end

	-- Return nil if no match is found
	print("Warning: No worldLevel found at position ("..col..", "..row..")")

end

function WorldManager.setWorldLevelEnabled (worldLevel)
	worldLevel.enabled = true

	local index = worldLevel.index
	local col = worldLevel.col
	local row = worldLevel.row

	local extendedOffsets = UtilsData.extendedOffsets
	for _, offset in pairs (extendedOffsets) do
		local col2 = col + offset.dx
		local row2 = row + offset.dy

		if not WorldManager.getWorldLevelByPosition (col2, row2) then
			local otherWorldLevel = WorldManager.createNewWorldLevel (col2, row2, false)
			
			worldLevel.neighbours[offset] = otherWorldLevel.index
			
			local oppositeOffset = UtilsData.extendedOffsetOpposites[offset]
			otherWorldLevel.neighbours[offset] = worldLevel.index
		end
	end
end


WorldManager.loadWorld() -- for editor only

WorldManager.loadProgress() -- for game only

return WorldManager
