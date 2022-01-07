-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local voronoi = require ('voronoi')


love.window.setMode(1920, 1080, {resizable=true, borderless=false})

width, height = love.graphics.getDimensions( )

local amount = 128

points = voronoi.newPoints (width, height, amount)

canvas = love.graphics.newCanvas ()

function sqdist (x1, y1, x2, y2)
	return (x2-x1)*(x2-x1)+(y2-y1)*(y2-y1)
end

love.graphics.setCanvas(canvas)
	for x = 1, width do
		for y = 1, height do
			local bestIndex, bestDist
			local maxDist
			for index = 1, #points-1, 2 do
				local px, py = points[index], points[index+1]
				local sqd = sqdist (x, y, px, py)
				
				if not bestDist or bestDist > sqd then
--					print (sqd)
					bestIndex, bestDist = index, sqd
				end				
				if not maxDist or maxDist < sqd then
--					print (sqd)
					maxDist = sqd
				end
			end
--			local c = (1-30*bestDist/maxDist)^0.5
			local c = (30*bestDist/maxDist)^0.5
			love.graphics.setColor (c,c,c)
			love.graphics.points (x, y)
		end
	end
love.graphics.setCanvas()

 
function love.update(dt)
	
end

love.graphics.setPointSize (3)
function love.draw()
	love.graphics.setColor (1,1,1)
	love.graphics.draw(canvas)
--	love.graphics.points (points)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end