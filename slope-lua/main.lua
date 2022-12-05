-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local slope = require 'slope'


love.window.setMode(1280, 800) -- Steam Deck resolution
Width, Height = love.graphics.getDimensions( )

local world = slope.newWorld(100) -- size of meter

local line1 = {0,600, 200,600, 400,400, 600,400, 800,500}
world:addLines(line1)

world:addPlayer({x=10, y=10, w=10, h=10}, 1)



function love.load()
	
end

 
function love.update(dt)
	if dt > 1/16 then dt = 1/16 end
	world:update (dt)
end


function love.draw()
	for i, line in ipairs (world.lines) do
		love.graphics.push()
			love.graphics.translate(line.x, line.y)
			love.graphics.line (line.profile)
		love.graphics.pop()
	end
	for i, player in ipairs (world.players) do
		love.graphics.rectangle('line', player.x, player.y, player.w, player.h)
	end
	love.graphics.print (world.players[1].vx ..' ' .. world.players[1].vy)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "space" then
	world.players[1].vy = -10*world.meter
	elseif key == "d" then
	world.players[1].vx = 10*world.meter
	elseif key == "a" then
	world.players[1].vx = -10*world.meter
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