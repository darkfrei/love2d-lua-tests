-- Deep Space Bastards
love.window.setTitle ('Deep Space Bastards')
spaceCamera = require("scripts.space-camera")
starSystemPrototypes = require("scripts.star-system-prototypes")
systemLoader = require("scripts.system-loader")
starSystem = require("scripts.star-system")
spaceBackground = require("scripts.space-background")

-- initialize game state
function love.load()
	-- set window dimensions
	windowWidth = 1080
	windowHeight = 1080
	love.window.setMode(windowWidth, windowHeight)

	-- load star system from prototype
	local systemPrototype = starSystemPrototypes.defaultSystem
	starSystem.load(systemPrototype)


end

-- update game state
function love.update(dt)
	-- update camera
	spaceCamera.update(dt)

	-- update star system with a single call
	starSystem.update(dt)
end

-- draw game
function love.draw()


	-- draw star system with a single call
	starSystem.draw()

end