-- License CC0 (Creative Commons license) (c) darkfrei, 2023

local imageToMap = require ('image-to-map')
local tiles16 = require ('map-to-tiles16')

--local map, palette = imageToMap ('image.png', true) -- string filename, bool with palette
local map, palette = imageToMap ('image-2.png', false) -- string filename, bool without palette

local quads, image = tiles16.newQuads ('tiles16-16x16.png')
local grid = tiles16.newGrid (map, 1)

love.window.setMode( 1024+16, 1024)

function love.load()
	tileSize = 16
end

 
function love.update(dt)
	
end


function love.draw()
	for y, xs in ipairs (map) do
		for x, value in ipairs (xs) do
			--[[
			local color = palette[value]
			if color then
				love.graphics.setColor (color)
			else
				print ('no color', value)
			end
			love.graphics.rectangle('fill', (x-1)*tileSize, (y-1)*tileSize, tileSize, tileSize)
			]]
			
			if not (grid[y][x] == 0) then
--				print (y, x, grid[y][x])
				love.graphics.draw (image, quads[grid[y][x]], (x-1)*tileSize, (y-1)*tileSize)
			end
		end
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end
