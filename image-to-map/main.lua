-- License CC0 (Creative Commons license) (c) darkfrei, 2023

local imageToMap = require ('image-to-map')
--local image = love.graphics.newImage()
--local map, palette = imageToMap ('image.png', true) -- string filename, bool with palette
local map, palette = imageToMap ('image-2.png', false) -- string filename, bool without palette
local tileSize = 2

function love.load()
	
end

 
function love.update(dt)
	
end


function love.draw()
	for y, xs in ipairs (map) do
		for x, value in ipairs (xs) do
			local color = palette[value]
			if color then
				love.graphics.setColor (color)
			else
				print ('no color', value)
			end
			
			love.graphics.rectangle('fill', (x-1)*tileSize, (y-1)*tileSize, tileSize, tileSize)
			
		end
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end
