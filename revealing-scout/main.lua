-- main.lua
-- all comments in code are in english and lowercase

local Settings = require("settings")
local WorldECS = require("core.world-ecs")
local MapLoader = require("map/mapLoader")
local testMap = require("map/maps/testMap")

-- systems
local RenderSystem = require("systems.renderSystem")
local InputSystem = require("systems.inputSystem")
local Movement = require("systems/movementSystem")
local CameraSystem = require("systems/cameraSystem")
local FogSystem = require("systems/fogSystem")

-- components
local CameraComp = require("components.camera")

-- entities
local Entity = require("core.entity")
local Scout = require("entities.scout")
local Village = require("entities.village")




-- LOVE2D callbacks
function love.load()

-- init ecs world
	world = WorldECS.newWorld()

-- create camera entity
	local cameraEntity = Entity.new(world, 'camera')
	cameraEntity:addComponent("camera", CameraComp.new(600, 400))
	world.camera = cameraEntity.components.camera

-- register systems
	world.inputSystem = InputSystem
	world:addSystem(InputSystem)
	world:addSystem(RenderSystem)
	world:addSystem(Movement)
	world:addSystem(CameraSystem)
	world:addSystem(FogSystem)


-- load map and create tile entities
	MapLoader.load(world, testMap)

--	playerScout = Scout.new(world, 0, 0) -- r, q
--	village = Village.new(world, 0, 0) -- r, q
end

function love.update(dt)
	world:update(dt)
end

function love.draw()
	world:draw()
end

function love.keypressed(key, scancode)
--	print ('love.keypressed(key, scancode)', key, scancode)
	if world and world.inputSystem then
--		print ('world.inputSystem exists!')
		world.inputSystem:keypressed(world, key, scancode)
	end
end
