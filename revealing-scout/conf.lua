-- conf.lua
-- all comments in code are in english and lowercase

function love.conf(t)
	-- window settings
	t.window.title = "Revealing Scout"
	t.window.width = 1280
	t.window.height = 800
	t.window.resizable = true
	t.window.fullscreen = false
	t.window.vsync = 1

	-- modules
	t.modules.joystick = false
	t.modules.audio = true
	t.modules.keyboard = true
	t.modules.event = true
	t.modules.graphics = true
	t.modules.image = true
	t.modules.timer = true
	t.modules.mouse = true
	t.modules.sound = true
	t.modules.physics = false
end
