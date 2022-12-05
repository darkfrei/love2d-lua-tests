-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local slope = {}

local function getMovingBoundungBox (x, y, w, h, dx, dy)
	local x1 = math.min (x, x+dx)
	local y1 = math.min (y, y+dy)
	local w1 = math.max (w, w+dx)
	local h1 = math.max (h, h+dy)
	return x1, y1, x+w1, y+h1
end

local function getLineBoundungBox (line)
	local x1, y1 = line[1], line[2]
	local x2, y2 = line[1], line[2]
	for i = 3, #line-1, 2 do
		local x = line [i]
		local y = line [i+1]
		if x1 > x then x1 = x end
		if y1 > y then y1 = y end
		if x2 < x then x2 = x end
		if y2 < y then y2 = y end
	end
	for i = 1, #line-1, 2 do
		line [i] = line [i] - x1
		line [i+1] = line [i+1] - y1
	end
	return x1, y1, x2-x1, y2-y1 -- x, y, w, h
end

local function worldAddLines (self, line)
	for i = 1, #line-3, 2 do
		local lineSegment = {line[i], line[i+1], line[i+2], line[i+3]}
		local x, y, w, h = getLineBoundungBox (lineSegment)
		local newLine = {
			profile = lineSegment,
			x=x, y=y, w=w, h=h,
			vx = 0, vy = 0,
		}
		table.insert (self.lines, newLine)
	end
end

local function worldAddPlayer (self, d)
	local newPlayer = {
		x=d.x, y=d.y, w=d.w, h=d.h,
		vx = 0, vy = 0,
	}
	table.insert (self.players, newPlayer)
end

local function checkCollisionBB (xmin,ymin,xmax,ymax, BB)
	if xmin < BB.x+BB.w and
		BB.x < xmax and
		ymin < BB.y+BB.h and
		BB.y < ymax then
		return true
	end
	return false
end

local function getSlide (world, x1, y1, x2, y2)
	local xmin, xmax = math.min (x1, x2), math.max (x1, x2)
	local ymin, ymax = math.min (y1, y2), math.max (y1, y2)
	for i, line in ipairs (world.lines) do
		if checkCollisionBB (xmin,ymin,xmax,ymax, line) then
--			print ('collision rough')
			return x1, y1
		end
	end
	return x2, y2
end

local function worldUpdate (self, dt)
	local maxSpeed = self.maxSpeed
	for i, p in ipairs (self.players) do
		-- update velocity
		local vx=p.vx+self.gravX*dt
		local vy=p.vy+self.gravY*dt
		if vx > maxSpeed then 
			vx = maxSpeed
		elseif vx < -maxSpeed then
			vx = -maxSpeed 
		end
		if vy > maxSpeed then 
			vy = maxSpeed
		elseif vy < -maxSpeed then
			vy = -maxSpeed 
		end
		p.vx = vx
		p.vy = vy
		
		local goalX = p.x + p.vx*dt
		local goalY = p.y + p.vy*dt
		
		-- check collision:
		local slideX, slideY = getSlide (self, p.x, p.y, goalX, goalY)
		
		
--		p.x = goalX; p.y = goalY
		p.x = slideX; p.y = slideY
	end
end

function slope.newWorld (meter)
	meter = meter or 100
	local world = {
		meter			= meter,
		maxSpeed		= 6*meter,
		gravX			= 0,
		gravY			= 9.81*meter, -- m / s^2
		lines			= {},
		players			= {},
--		rows			= {},
--		nonEmptyCells	= {},
--		responses 		= {},
	}
	world.addLines = worldAddLines
	world.addPlayer = worldAddPlayer
	world.update = worldUpdate

--	world:addResponse('touch', touch)
--	world:addResponse('cross', cross)
--	world:addResponse('slide', slide)
--	world:addResponse('bounce', bounce)
	
	return world
end


return slope