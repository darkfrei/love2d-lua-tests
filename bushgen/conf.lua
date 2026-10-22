-- conf.lua
-- the real window size is set in love.load from the monitor size

function love.conf(t)
	t.window.title = "bushgen"
	t.window.width = 800
	t.window.height = 600
	t.window.resizable = true
end
