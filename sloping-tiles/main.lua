-- License CC0 (Creative Commons license) (c) darkfrei, 2023

love.window.setMode(1280, 800) -- Steam Deck resolution
Width, Height = love.graphics.getDimensions( )

-- based on https://youtu.be/Isvs9OzX6Lk

love.graphics.setDefaultFilter("linear", "nearest")


local sprite1  = love.graphics.newImage('slope-1.png')
local sprite2  = love.graphics.newImage('slope-2.png')
local sprite6  = love.graphics.newImage('slope-6.png')
local sprite10 = love.graphics.newImage('slope-10.png')
local sprite8  = love.graphics.newImage('slope-8.png')
local sprite4 =  love.graphics.newImage('slope-4.png')
local sprite5  = love.graphics.newImage('slope-5.png')

-- prototypes:
local psolid8  = {image = sprite8,  m= 0,  c=2, r=50}


local pslope1  = {image = sprite1,  m= 1,  c=0, r=53}
local pslope2  = {image = sprite2,  m= 1,  c=1, r=54}

local pslope4  = {image = sprite4,  m=-1,  c=2, r=55}
local pslope5  = {image = sprite5,  m=-1,  c=1, r=56}
local pslope6  = {image = sprite6,  m= 2,  c=0, r=51}
local pslope10 = {image = sprite10, m=-2,  c=2, r=52}

player = {x=5, y=1,w=1/32, h=1, s=0}

tS = 32 -- tile size

local function newSolid (x, y)
	return {x=x, y=y}
end

local function newSlope (x, y, p) -- position, prototype
	return {x=x, y=y, m=p.m, c=p.c, image = p.image}
end

local function drawSolid (solid)
	love.graphics.polygon('line', 
		solid.x*tS, solid.y*tS, 
		solid.x*tS+tS, solid.y*tS, 
		solid.x*tS+tS, solid.y*tS+tS, 
		solid.x*tS, solid.y*tS+tS)
end

local function drawSlope (slope)
	local x1 = slope.x
	local y1 = slope.y+1-slope.c/2
	local x2 = slope.x+1
	local y2 = slope.y+1-slope.c/2-slope.m/2
	local y3 = slope.y+1
	if y1 == y3 then
		love.graphics.polygon('line', x1*tS,y1*tS, x2*tS,y2*tS, x2*tS,y3*tS)
	elseif y2 == y3 then
		love.graphics.polygon('line', x1*tS,y1*tS, x2*tS,y2*tS, x1*tS,y3*tS)
	else
		love.graphics.polygon('line', x1*tS,y1*tS, x2*tS,y2*tS, x2*tS,y3*tS, x1*tS,y3*tS)
	end
	love.graphics.draw(slope.image, slope.x*tS, slope.y*tS)
end

function love.load(slope)
	
	Slopes = {
	newSlope (3, 5, pslope1),
	newSlope (4, 5, pslope2),
	newSlope (6, 5, pslope4),
	newSlope (7, 5, pslope5),

	newSlope (5, 5, psolid8),
	newSlope (2, 6, psolid8),
	newSlope (1, 6, psolid8),
	newSlope (8, 6, psolid8),
	newSlope (9, 6, psolid8)
	}
end

function isCollision(player, dy, slope)
	local x1,y1,w1,h1 = player.x, player.y, player.w, player.h
	local x2,y2,w2,h2 = slope.x, slope.y, 1,1
	local m, c = slope.m, slope.c
	
  if x1 < x2+w2 and x2 < x1+w1 and y1+dy < y2+h2 and y2 < y1+dy+h1 then
		local dist = (y2+1-c*0.5 +(x2-(x1+w1))*m/2)-(y1+h1)
		if dist < 0 then
			player.s = dist
			return true 
		else
			return false
		end
	end
end

function love.update(dt)
	local dx = 0
	local left = love.keyboard.isScancodeDown('a')
	local right = love.keyboard.isScancodeDown('d')
	if left and not right then 
		dx = -2*dt
	elseif right and not left then 
		dx = 2*dt
	end
	if love.keyboard.isScancodeDown('w') then
		player.y = player.y - 4*dt
	end

	local dy = 2*dt
	for i, slope in ipairs (Slopes) do
--		print (player.x, player.y, slope.x, slope.y)
		if isCollision (player, dy, slope) then
			dy = 0
			slope.red = true
		else
			slope.red = false
		end
	end
	player.y = player.y + dy
	player.x = player.x + dx
end


function love.draw()
	love.graphics.print ('press W AD to move')
	love.graphics.scale (3)
	
	
	for i, slope in ipairs (Slopes) do
		if slope.red then
			love.graphics.setColor(1,0,0)
		else
			love.graphics.setColor(1,1,1)
		end
		drawSlope (slope)
	end
	love.graphics.setColor(1,1,1)
	love.graphics.rectangle('line', player.x*tS, player.y*tS, player.w*tS, player.h*tS)
	love.graphics.print(player.s, player.x*tS, player.y*tS)
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