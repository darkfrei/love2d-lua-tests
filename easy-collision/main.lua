-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function love.load()
	width, height = love.graphics.getDimensions( )

	tileSize = 100
	map={{true, false, false, true}} -- map[y][x]
	
	player = {x=250, y=200, w=50, h=50, v=200, byWall = false}
end

function isCollision (x,y)
	x = math.floor (x/tileSize)
	y = math.floor (y/tileSize)
	return map[y] and map[y][x] or false
end
 
function love.update(dt)
	local small = 1/256
	local byWall = false
	
	if love.keyboard.isDown("up", "w") then
		player.y = player.y - dt*player.v
		if isCollision (player.x+small,player.y+small) 
			or isCollision (player.x+player.w-small,player.y+small) then
			player.y = math.floor (player.y/tileSize+0.5)*tileSize
		end
	elseif love.keyboard.isDown("down", "s") then
		player.y = player.y + dt*player.v
		if isCollision (player.x+player.w-small,player.y+player.h-small) or
			isCollision (player.x+small,player.y+player.h-small) then
			player.y = math.floor ((player.y+player.h)/tileSize+0.5)*tileSize-player.h
		end
    end


	if love.keyboard.isDown("left", "a") then
		player.x = player.x - dt*player.v
		if isCollision (player.x+small,player.y+small)
			or isCollision (player.x+small,player.y+player.h-small) then
			player.x = math.floor (player.x/tileSize+0.5)*tileSize
		end
	elseif love.keyboard.isDown("right", "d") then
		player.x = player.x + dt*player.v
		if isCollision (player.x+player.w-small,player.y+small) 
			or isCollision (player.x+player.w-small,player.y+player.h-small) then
			player.x = math.floor ((player.x+player.w)/tileSize+0.5)*tileSize-player.w
		end
    end
	
	player.byWall = byWall
end


function love.draw()
	love.graphics.setColor(1,1,1)
	for y, xs in pairs (map) do
		for x, is_tile in pairs (xs) do
			if is_tile then
				love.graphics.rectangle('fill', x*tileSize, y*tileSize, tileSize,tileSize)
			end
		end
	end
	if player.byWall then
		love.graphics.setColor(1,1,0)
	end
	love.graphics.rectangle('fill', player.x, player.y, player.w, player.h)
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