-- conf.lua
-- love2d project configuration

function love.conf(t)
	-- window settings
	t.window.title = "Traffic Intersection Network Architecture" -- window title
	t.window.width = 1920 -- initial window width
	t.window.height = 1080 -- initial window height
	t.window.resizable = true -- allow window resizing
	t.window.minwidth = 800 -- minimum window width
	t.window.minheight = 600 -- minimum window height
	t.window.vsync = 1 -- vertical sync (smooth rendering)
	t.window.x = nil -- center window horizontally
	t.window.y = nil -- center window vertically

	-- system settings
	t.version = "11.5" -- love2d version target
	t.console = false -- disable windows console
	t.accelerometerjoystick = false -- disable accelerometer (not used on pc)

	-- modules
	t.modules.joystick = false -- disable gamepad support
	t.modules.physics = false -- disable box2d physics (custom simulation used)
end