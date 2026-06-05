-- main.lua
-- application entry point: editor / simulation state switch

local Editor     = require("editor")
local Simulation = require("simulation")

local state = "editor"

local App = {}

local function deepCopyMap(src)
	local map = {
		nodes = {},
		ways = {}
	}

	for id, n in pairs(src.nodes or {}) do
		map.nodes[id] = { x = n.x, y = n.y }
	end

	for i, w in ipairs(src.ways or {}) do
		local refs = {}
		for _, r in ipairs(w.nodeRefs or {}) do
			refs[#refs + 1] = r
		end

		map.ways[i] = {
			id = w.id or i,
			nodeRefs = refs,
			tags = {
				curve = (w.tags and w.tags.curve) or "linear"
			}
		}
	end

	return map
end

-- 
-- state control
-- 

function App.setState(newState)
	if type(newState) ~= "string" then
		print("ERROR: invalid state:", newState)
		return
	end

	if newState == state then return end
	state = newState

	if state == "simulation" then
		local mapCopy = deepCopyMap(Editor.map)
		Simulation.syncMap(mapCopy)
	end
end

function App.getState()
	return state
end

-- 
-- love lifecycle
-- 

function love.load()
	love.window.setMode(1920, 1080, { resizable = true, vsync = true })
	love.window.setTitle("flow junction")

	Editor.load(App)
	Simulation.load(App)
end

function love.update(dt)
	if state == "editor" then
		Editor.update(dt)
	elseif state == "simulation" then
		Simulation.update(dt)
	end
end

function love.draw()
	if state == "editor" then
		Editor.draw()
	elseif state == "simulation" then
		Simulation.draw()
	end
end

-- 
-- input routing
-- 

function love.mousepressed(x, y, button)
	if state == "editor" then
		Editor.mousepressed(x, y, button)
	elseif state == "simulation" then
		Simulation.mousepressed(x, y, button)
	end
end

function love.mousereleased(x, y, button)
	if state == "editor" then
		Editor.mousereleased(x, y, button)
	elseif state == "simulation" then
		Simulation.mousereleased(x, y, button)
	end
end

function love.mousemoved(x, y, dx, dy)
	if state == "editor" then
		Editor.mousemoved(x, y, dx, dy)
	elseif state == "simulation" then
		Simulation.mousemoved(x, y, dx, dy)
	end
end

function love.wheelmoved(x, y)
	if state == "editor" then
		if Editor.wheelmoved then
			Editor.wheelmoved(x, y)
		end
	elseif state == "simulation" then
		if Simulation.wheelmoved then
			Simulation.wheelmoved(x, y)
		end
	end
end

function love.keypressed(key)
	if state == "editor" then
		if Editor.keypressed then
			Editor.keypressed(key)
		end
	elseif state == "simulation" then
		if Simulation.keypressed then
			Simulation.keypressed(key)
		end
	end
end

function love.keyreleased(key, scancode)
	if state == "editor" then
		if Editor.keyreleased then
			Editor.keyreleased(key)
		end
	elseif state == "simulation" then
		if Simulation.keyreleased then
			Simulation.keyreleased(key)
		end
	end
end