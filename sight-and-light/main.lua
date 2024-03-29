-- License CC0 (Creative Commons license) (c) darkfrei, 2021

-- based on https://ncase.me/sight-and-light/


function getAllUniquePoints ()
	local map, uniquePoints = {}, {}
	for i, segment in ipairs (segments) do
		for j = 1, #segment-1, 2 do
			local x, y = segment[j], segment[j+1]
			if map[x] then 
				map[x][y] = true
			else
				map[x] = {[y] = true}
			end
		end
	end
	for x, ys in pairs (map) do
		for y, bool in pairs (ys) do
			table.insert (uniquePoints, {x=x,y=y})
		end
	end
	return uniquePoints
end

function love.load()
	scale = 3
	local font = love.graphics.newFont(20*scale)
	love.graphics.setFont(font)
	love.window.setMode(640*scale, 360*scale, {resizable=true, borderless=false})

	width, height = love.graphics.getDimensions( )

	segments = {

		-- border
		{0,0, 640,0, 640,360, 0,360},
		-- #1
		{100,150, 120,50, 200,80, 140,210},
		-- #2 
		{100,200, 120,250, 60, 300, 100, 300},
		-- #3
		{200,260, 220,150, 300,200, 350,320, 250,250},
		-- #4
		{340,60, 360,40, 370,70},
		-- #5
		{450,170, 560,170, 560,290, 450,290},
		-- #6
		{400,95, 580,50, 450,150},
	}

	-- unique points
	uniquePoints = getAllUniquePoints ()
	
	uniqueAngles = {}
	
	-- points as intersects[i] = {x=x,y=y, angle=angle}
	intersects = {} 
	
--	new polygons
	areas = {}
	
	mesh = nil

	radius = 200
	
--	love.graphics.setBackgroundColor (178/255,228/255,249/255)
end


function love.update(dt)
	
end

function drawDebugLines (mx, my)
	-- draw debug lines to uniquePoints
	love.graphics.setColor (1,1,1)
	love.graphics.setLineWidth (1/scale)
	for i, point in ipairs (uniquePoints) do
		love.graphics.line (mx, my, point.x, point.y)
	end
end

function drawAreas ()
	-- areas, new polygons
	love.graphics.setColor (1,0,0, 0.5)
	for i, verticles in ipairs (areas) do
		love.graphics.polygon ('fill', verticles)
	end
end

function drawDebugViewLines (mx, my)
	-- draw red lines
	love.graphics.setColor (1,0,0)
	love.graphics.setLineWidth (4/scale)
	for i, point in ipairs (intersects) do
		love.graphics.line (mx, my, point.x, point.y)
--		love.graphics.print(tostring(point.dist), point.x, point.y, 0, 0.25*1/scale)
	end
end

function drawSegments ()
	-- draw segments (polygons)
	love.graphics.setColor (1,1,1)
	love.graphics.setLineWidth (4/scale)
	for i, polygon in ipairs (segments) do
		if #polygon > 4 then
			love.graphics.polygon('line', polygon)
		elseif #polygon == 4 then
			love.graphics.line(polygon)
		end
	end
end

function love.draw()
	
	love.graphics.scale (scale)

	local mx, my = love.mouse.getPosition()
	mx, my = mx/scale, my/scale
	
--	drawDebugLines (mx, my)

--	drawAreas () -- red area

--	drawDebugViewLines (mx, my)

	drawSegments ()

	if mesh then
		love.graphics.draw(mesh)
	end
	
--	for i, point in ipairs (intersects) do
----		love.graphics.line (mx, my, point.x, point.y)
--		love.graphics.print(tostring(point.dist), point.x, point.y, 0, 0.25*1/scale)
--	end
end

function getUniqueAngles (mx, my)
	local angles = {}
	
	local deltaAngle = 5
	for i = deltaAngle/2, 360, deltaAngle do
		local angle = math.rad(i)
		angles[angle] = true
	end
	
	local precision = 2^16
	
	for i, point in ipairs (uniquePoints) do
		local angle = math.atan2 (point.y-my, point.x-mx)
		angle = math.floor (angle*precision/math.pi + 0.5)/precision*math.pi
--		angles[angle] = true
		angles[angle-1/(precision/math.pi)] = true
		angles[angle+1/(precision/math.pi)] = true
		
	end
	local uniqueAngles = {}
	for angle, bool in pairs (angles) do
		table.insert (uniqueAngles, (angle)%(2*math.pi))
	end
	table.sort(uniqueAngles)
	return uniqueAngles
end

function getIntersection(ray, segment)
	-- ray = {x, y, dx, dy}
	local r_px, r_py, r_dx, r_dy = ray[1], ray[2], ray[3], ray[4]
	
	-- segment = {ax, ay, bx, by}
	local s_px, s_py = segment[1], segment[2]
	local s_dx, s_dy = segment[3]-s_px, segment[4]-s_py
	
	local r_mag = (r_dx*r_dx+r_dy*r_dy)^0.5
	local s_mag = (s_dx*s_dx+s_dy*s_dy)^0.5
	
	if (r_dx/r_mag==s_dx/s_mag and r_dy/r_mag==s_dy/s_mag) then
		return -- parallel
	end
	
	local t2 = (r_dx*(s_py-r_py) + r_dy*(r_px-s_px))/(s_dx*r_dy - s_dy*r_dx)
	local t1 = (s_px+s_dx*t2-r_px)/r_dx
	
	-- for one ray
--	if t1<0 or t2 < -0.01 or t2 > 1.01 then return end
	
	-- for three rays
	if t1<0 or t2 < 0 or t2 > 1 then return end
	
	local x, y, dist = r_px+r_dx*t1, r_py+r_dy*t1, t1*r_mag
	
	return {x=x,y=y, dist=dist}, dist
end



function findClosestIntersection (ray)
	local closestIntersect, closestDist = nil, radius
	for i, polygon in ipairs (segments) do
		for j = 1, #polygon-3, 2 do
			local segment = {polygon[j], polygon[j+1], polygon[j+2], polygon[j+3]}
			local intersect, dist = getIntersection(ray,segment)
			if dist and ((not closestDist) or (dist < closestDist)) then
				closestDist = dist
				closestIntersect = intersect
			end
		end
		
		local segment = {polygon[#polygon-1], polygon[#polygon], polygon[1], polygon[2]}
		local intersect, dist = getIntersection(ray,segment)
		if dist and ((not closestDist) or (dist < closestDist)) then
			secondClosestIntersect, secondClosestDist = closestIntersect, closestDist
			closestDist = dist
			closestIntersect = intersect
		end
		
	end
	
	return closestIntersect, closestDist
end

function love.mousemoved( x, y, dx, dy, istouch )
	x=x/scale
	y=y/scale
	dx=dx/scale
	dy=dy/scale
	uniqueAngles = getUniqueAngles (x, y)
	
	intersects = {}
	for i, angle in ipairs (uniqueAngles) do
		local dx = math.cos(angle)
		local dy = math.sin(angle)
		local ray = {x, y, dx, dy}
		local closestIntersect = findClosestIntersection (ray)
		if closestIntersect then
			closestIntersect.angle = angle
			table.insert (intersects, closestIntersect)
		else
--			local radius = 100
			local nointersect = {x=x+radius*math.cos(angle), y=y+radius*math.sin(angle), dist=radius}
			table.insert (intersects, nointersect)
		end
	end
	
	areas = {}
	local int1 = intersects[#intersects]
	for i = 1, #intersects do
		local int2 = intersects[i]
		local area = {x, y, int1.x, int1.y, int2.x, int2.y}
		table.insert (areas, area)
		int1 = int2
	end
	
	local verticles = {}
	local verticle = {x, y, 0, 0, 1,1,1}
	table.insert (verticles, verticle)
	
	local int = intersects[#intersects]
	local value = (radius-int.dist)/radius
--	verticle = {int.x, int.y, 0, 0, value,value,value}
	verticle = {int.x, int.y, 0, 0, 1,1,1, value}
	table.insert (verticles, verticle)
	
	for i = 1, #intersects do
		int = intersects[i]
		value = (radius-int.dist)/radius
--		verticle = {int.x, int.y, 0, 0, value,value,value}
		verticle = {int.x, int.y, 0, 0, 1,1,1, value}
		table.insert (verticles, verticle)
	end
	
	mesh = love.graphics.newMesh(verticles, mode, usage )
end


function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end