--main.lua

local mazer = require ('mazer')
local getRectanglesFromMap = require ('tiles-to-rectangles')

love.window.setTitle( 'mazer - lib for Love2D' )


local maze = mazer.generateMaze(16,12,16,12)
local grid = mazer.createGrid (maze, 1, 2) -- wall size, cell size

local rectangles = getRectanglesFromMap (grid, true) -- map, wallValue

function love.draw ()
	-- draw tiles
	--[[
	love.graphics.setLineWidth(1)
	love.graphics.setColor(0.25,0.25,0.25)
	mazer.drawGrid (grid, 12, 'fill')
	love.graphics.setColor(0.5,0.5,0.5)
	mazer.drawGrid (grid, 12, 'line')
	]]
	
	love.graphics.push()
		love.graphics.scale(16)
		love.graphics.setLineWidth(1/8)
		
		for i, r in ipairs (rectangles) do
			love.graphics.setColor(0.5,0.5,0.5)
			love.graphics.rectangle('fill', r.x-1, r.y-1, r.w, r.h)
			love.graphics.setColor(1,1,1)
			love.graphics.rectangle('line', r.x-1, r.y-1, r.w, r.h)
		end
	love.graphics.pop()
	
	-- draw lines
	
	--[[
	love.graphics.push()
		local scale = 48
		love.graphics.scale (scale)
		love.graphics.setLineWidth(1/scale)
		love.graphics.setColor(1,1,1)
		mazer.drawMaze (maze)
	love.graphics.pop()
	]]
	
end