-- darkfrei 2021

states = {}
states.menu = require ('menu')
--states.game = require ('game')

state = states.menu

------------------------------------------------------------
function love.load ()
	love.window.setMode(800, 600, {resizable = true} )
	state.load ()
end

function love.update (dt)
	state.update (dt)
end

function love.draw ()

	state.draw ()
end

function love.mousepressed(x, y, button, istouch, presses)
	state.mousepressed (x, y, button, istouch, presses)
end

function love.mousemoved( x, y, dx, dy, istouch )
	state.mousemoved( x, y, dx, dy, istouch )
end

function love.mousereleased (x, y, button, istouch, presses)
	state.mousereleased (x, y, button, istouch, presses)
end

function love.keypressed (key, scancode, isrepeat)
	state.keypressed (key, scancode, isrepeat)
end

function love.resize()
	state.resize (w, h)
end