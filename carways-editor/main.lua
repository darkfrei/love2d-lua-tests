

local Resolution = require("resolution")
Resolution.setup(1280, 800)




currentLevel = {
	index = 1,
	walls = {},
	spawners = {},
	entities = {},
	selectedZone = nil, -- or entity
	
}

levels = {currentLevel}

Game = {
	levels = levels,
	currentLevel = currentLevel,
	tileSize = 40,
	tw = 32,
	tw = 20,
--	mouseLevelCursor = {tx=0, ty=0, tw=1, th=1},
}

StateManager = require("state_manager")
Data = require("data")
Editor = require("editor")





function love.load()
	-- [sets the initial state to editor]
	StateManager.switchState(Editor)
end

function love.update(dt)
	-- [updates the current state]
	StateManager.update(dt)
end

function love.draw()
	-- [renders the current state]
	local scale = Resolution.scale
	local dx, dy = Resolution.translateX, Resolution.translateY
	love.graphics.translate (dx, dy)
	love.graphics.scale(scale, scale)
	StateManager.draw()
end

function love.keypressed(key)
	-- [handles keypress events in the current state]
	StateManager.handleEvent("keypressed", key)
end

function love.mousepressed(x, y, button)
	-- [handles mouse press events in the current state]
	StateManager.handleEvent("mousepressed", x, y, button)
end

function love.mousereleased(x, y, button)
	-- [handles mouse release events in the current state]
	StateManager.handleEvent("mousereleased", x, y, button)
end

function love.mousemoved(x, y, dx, dy)
	-- [handles mouse move events in the current state]
	StateManager.handleEvent("mousemoved", x, y, dx, dy)

end

function love.resize (w, h)
	print("Window resized to: " .. w .. "x" .. h)
	Resolution.resize(w, h)
end

function love.wheelmoved(x, y)
    -- [handles mouse wheel events]
    StateManager.handleEvent("wheelmoved", x, y)
end