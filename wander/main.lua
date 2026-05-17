local Wander = require("wander")

function love.load()
	love.window.setMode(1920, 1080, {
			fullscreen = false,
			resizable  = false,
			vsync      = true,
		})
	Wander.init()
end

function love.update(dt)
	dt = math.min(dt, 0.05)
	Wander.update(dt)
end

function love.draw()
	Wander.draw()
end

function love.keypressed(key)
	if key == "escape" then love.event.quit() end
	Wander.keypressed(key)
end
