-- License CC0 (Creative Commons license) (c) darkfrei, 2022

-- based on Coding Challenge 172: Horizontal Directional Drilling
-- https://youtu.be/FfCBNL6lWK0

local function newLake (x, y, w, h)
	-- x and y in the middle
	local vertices = {}
	local n = 16
	for i = 0, n do
		local angle = math.pi*(i/n)
		local x1 = x+0.5*w*math.cos(angle)
		local y1 = y+0.5*h*math.sin(angle)
		table.insert (vertices, x1)
		table.insert (vertices, y1)
	end
	return vertices
end

local function newLevel (level)
	local x, y = Width/16, Height/8
	local radius = Height/8
	Game = {
		y = y, -- earth level
		player = {
			x = x, y = y+1,
			lastX = x, lastY = y+1,
			v = radius,
			direction = 0.5,
			drill = 1, -- one radian
		},
		path = {x, y},
		lake = newLake (Width/2, Height/8, Width/2, Height/4),
		stones = {},
	}
	
	Game.target = {x=Width*14/16, y = y-Width/32, w=Width/32, h=Width/32}
	
	for i = 1, 10+level do
		local sx = math.random(x+2*radius, Width)
		local sy = math.random(y+radius, Height)
		local sr = math.random(radius/8, radius)
		table.insert (Game.stones, {x=sx, y=sy, r=sr})
	end
end

function love.load()
	Width, Height = love.graphics.getDimensions()
	Level = 1
	Pause = false
	love.graphics.setBackgroundColor (54/255, 54/255, 54/255)
	newLevel (Level)
end

local function targetCollision ()
	local target = Game.target
	local x, y = Game.player.x, Game.player.y
	return x > target.x and x < target.x + target.w
		and y > target.y  and y < target.y + target.h
end

local function  mapCollision ()
	-- returns true if out of map
	local x, y = Game.player.x, Game.player.y
	return x < 0 or x > Width
		or y < Game.y or y > Height
end

local function lakeCollision ()
	local x, y = Game.player.x, Game.player.y
	local poly = Game.lake
	local x1, y1, x2, y2
	local len = #poly
	x2, y2 = poly[len - 1], poly[len]
	local wn = 0
	for idx = 1, len, 2 do
		x1, y1 = x2, y2
		x2, y2 = poly[idx], poly[idx + 1]
		if y1 > y then
		if (y2 <= y) and (x1 - x) * (y2 - y) < (x2 - x) * (y1 - y) then
			wn = wn + 1
		end
		else
			if (y2 > y) and (x1 - x) * (y2 - y) > (x2 - x) * (y1 - y) then
				wn = wn - 1
			end
		end
	end
	return wn % 2 ~= 0 -- even/odd rule
end

local function stonesCollision ()
	local x, y = Game.player.x, Game.player.y
	for i, stone in ipairs (Game.stones) do
		local dx, dy = math.abs (stone.x-x), math.abs(stone.y-y)
		if dx < stone.r and dy < stone.r then
			if dx*dx+dy*dy < stone.r*stone.r then
				return true
			end
		end
	end
end
 
function love.update(dt)
	if not Pause then
		local player = Game.player
		player.direction = player.direction + dt*player.drill
		local dx = dt*player.v*math.cos(player.direction)
		local dy = dt*player.v*math.sin(player.direction)
		player.x = player.x + dx
		player.y = player.y + dy
		if math.abs (player.x-player.lastX) > 5
		 or math.abs (player.y-player.lastY) > 5 then 
			player.lastX = player.x
			player.lastY = player.y
			table.insert(Game.path, player.x)
			table.insert(Game.path, player.y)
		end
		if targetCollision () then
			Level = Level + 1
			Pause = true
		elseif mapCollision () or
			lakeCollision () or
			stonesCollision () then
			Level = 1	
			Pause = true
		end
	end
end


function love.draw()
	-- draw earth
	love.graphics.setColor (126/255, 67/255, 31/255)
	love.graphics.rectangle("fill", 0, Height/8, Width, Height)
	
	-- draw lake
	love.graphics.setColor (40/255, 131/255, 235/255)
	love.graphics.polygon ('fill', Game.lake)
	
	-- draw stones
	love.graphics.setColor (235/255, 182/255, 92/255)
	for i, stone in ipairs (Game.stones) do
		love.graphics.circle ("fill", stone.x, stone.y, stone.r)
	end
	
	-- draw line
	love.graphics.setColor (0,0,0)
	love.graphics.setLineWidth (2)
	if #Game.path > 2 then
		love.graphics.line (Game.path)
	end
	love.graphics.line (Game.player.x, Game.player.y, Game.player.lastX, Game.player.lastY)
	
	-- draw target
	love.graphics.setColor (0,1,0)
	love.graphics.rectangle ("fill", Game.target.x, Game.target.y, Game.target.w, Game.target.h)
	
	-- draw drill
	love.graphics.setColor (1,0,0)
	local dx = 10*math.cos(Game.player.direction+Game.player.drill/2)
	local dy = 10*math.sin(Game.player.direction+Game.player.drill/2)
	love.graphics.line (Game.player.x, Game.player.y, Game.player.x+dx, Game.player.y+dy)
	
	-- draw player
	love.graphics.setColor (1,1,1)
	love.graphics.circle ('fill', Game.player.x, Game.player.y, 2)
	
	love.graphics.print ("Level ".. Level)
	
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "space" then
		if Pause then
			Pause = false
			newLevel (Level)
		else
			Game.player.drill = -Game.player.drill
		end
	elseif key == "escape" then
		love.event.quit()
	end
end
