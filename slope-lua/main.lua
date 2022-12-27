-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local slope = require 'slope'


love.window.setMode(1280, 800) -- Steam Deck resolution
Width, Height = love.graphics.getDimensions( )

local world = slope.newWorld() -- size of meter

local lines1 = {200,600, 400,400, 600,400}
world:addLines(lines1)

player ={x=300, y=10, w=20, h=10, vx=0, vy=0}



function love.load()
	
end

 
function love.update(dt)
--	player.vx = player.vx*0.99*dt
--	player.vy = (player.vy + dt*world.meter)
--	local targetX = player.x + player.vx
--	local targetY = player.y + player.vy*dt
	local targetX = love.mouse.getX()
	local targetY = love.mouse.getY()
	
	if not (player.x == targetX and player.y == targetY) then
		local actualX, actualY, cols, len = world:move(player, targetX, targetY)


		player.x = actualX
		player.y = actualY
	end
end


function love.draw()
	for i, objLine in ipairs (world.objLines) do
		love.graphics.push()
			love.graphics.translate(objLine.x, objLine.y)
			if objLine.fine then 
				love.graphics.setColor(0,1,0)
--			elseif objLine.rough then 
--				love.graphics.setColor(1,0,0)
			else
				love.graphics.setColor(1,1,1)
			end
			love.graphics.line (objLine.line)
		love.graphics.pop()
	end
	love.graphics.rectangle('line', player.x, player.y, player.w, player.h)
	love.graphics.print (player.vx ..' ' .. player.vy)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "space" then
		player.vy = -10*world.meter
	elseif key == "d" then
		player.vx = 4*world.meter
	elseif key == "a" then
		player.vx = -4*world.meter
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