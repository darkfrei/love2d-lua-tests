-- main.lua
--
-- minimal application bootstrap
--
-- modules:
--   example.lua
--       static level data
--
--   render.lua
--       level rendering
--
--   car.lua
--       traffic simulation
--
-- flow:
--   love.update()
--       updates simulation state
--
--   love.draw()
--       renders level first
--       then renders cars on top

local level  = require("example")
local render = require("render")
local car    = require("car")

-- window configuration
local WINDOW_WIDTH  = 1920
local WINDOW_HEIGHT = 1080

function love.load()
	love.window.setMode(
		WINDOW_WIDTH,
		WINDOW_HEIGHT,
		{
			vsync = 1,
			resizable = false
		}
	)

	love.window.setTitle(
		"traffic intersection prototype"
	)

	-- smoother line rendering
	love.graphics.setLineStyle("smooth")
	love.graphics.setLineJoin("none")

	-- default background
	love.graphics.setBackgroundColor(
		0.08,
		0.10,
		0.12
	)
end

function love.update(dt)
	car.update(dt, level)
end

function love.draw()
	-- draw road network
	render.draw(level)

	-- draw moving vehicles
	car.draw()
end