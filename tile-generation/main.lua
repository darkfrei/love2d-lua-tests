-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local LG = love.graphics
local TT = require('ter-tiles')
local tileSize = 8 -- for image 32x32 pixels
local font = love.graphics.newFont(7, "mono")
font:setFilter("nearest")

love.graphics.setFont(font)

local map = {}

function love.load()
	local w, h = 20,16
	local seedX = love.math.random (1024)
	local seedY = love.math.random (1024)

	for y = 1, h do
		map[y] = {}
		for x = 1, w do
			local value = love.math.noise( 0.04*x+seedX, 0.14*y+seedY)
			if value > 0.7 then -- 70% air and 30% ground
				map[y][x] = 1 -- ground
			else
				map[y][x] = 0 -- air
			end
		end
	end
	
	TT.load (map)
end

 
function love.update(dt)
	
end


function love.draw()
	
	
	love.graphics.scale(4)
	love.graphics.print ("Hello World 0123", 1, 1)
--	local image = TT.image
--	for y, xs in ipairs (map) do
--		for x, tile in ipairs (xs) do
--			local quad = tile.quad
			
--			love.graphics.draw(image, quad, (x-1)*tileSize, (y-1)*tileSize)
--			love.graphics.print (tile.typ, (x-1)*tileSize+1, (y-1)*tileSize+1)
--		end
--	end
end


function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end
