--main.lua

local mazer = require ('mazer')
love.window.setTitle( 'mazer - lib for Love2D' )


local maze = mazer.generateMaze(16,12,16,12)
local grid = mazer.createGrid (maze, 2, 2)

function love.draw ()
	-- draw tiles
	love.graphics.setLineWidth(1)
	love.graphics.setColor(0.25,0.25,0.25)
	mazer.drawGrid (grid, 12, 'fill')
	love.graphics.setColor(0.5,0.5,0.5)
	mazer.drawGrid (grid, 12, 'line')
	
	-- draw lines
	local scale = 48
	love.graphics.scale (scale)
	love.graphics.setLineWidth(1/scale)
	love.graphics.setColor(1,1,1)
	mazer.drawMaze (maze)
end