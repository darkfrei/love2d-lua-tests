-- License CC0 (Creative Commons license) (c) darkfrei, 2023

local function segmentVsSegment(x1,y1, x2,y2, x3,y3, x4,y4)
-- from https://2dengine.com/?p=intersections#Segment_vs_segment
	local dx1, dy1, dx2, dy2, dx3, dy3 = x2-x1, y2-y1, x4-x3, y4-y3, x1-x3, y1-y3
	local d = dx1*dy2 - dy1*dx2
	if d == 0 then return false end
	local t1 = (dx2*dy3 - dy2*dx3)/d
	if t1 < 0 or t1 > 1 then return false end
	local t2 = (dx1*dy3 - dy1*dx3)/d
	if t2 < 0 or t2 > 1 then return false end
	return x1 + t1*dx1, y1 + t1*dy1 -- point of intersection
end

local function reflectRay (x1,y1, x2,y2, x3,y3, x4,y4)
-- from https://stackoverflow.com/questions/30970103/2d-line-reflection-on-a-mirror
	-- x1,y1, x2,y2 is a mirror line
	-- x3,y3, x4,y4 is a ray
-- intersection:
	local x5, y5 = segmentVsSegment(x1, y1, x2, y2, x3, y3, x4, y4)
	if not x5 then return end -- no crossing

-- ray vector:
	local rayX, rayY = x4-x5, y4-y5

-- normal:
	local nx, ny = y2-y1, x1-x2
	local nlength = math.sqrt(nx*nx + ny*ny)
	if nlength == 0 then return end 
	nx, ny = nx/nlength, ny/nlength

-- dot product:
	local dotProduct = (rayX*nx)+(rayY*ny)
	local x6 = x4-2*dotProduct*nx
	local y6 = y4-2*dotProduct*ny
	return x3,y3, x5,y5, x6,y6 -- three points of reflected ray
end

local function getReflectedRay ()
	local x1,y1, x2,y2 = line[1], line[2], line[3], line[4]
	local x3,y3, x4,y4 = ray.x1, ray.y1, ray.x2, ray.y2
	local x3,y3, x5,y5, x6,y6 = reflectRay (x1,y1, x2,y2, x3,y3, x4,y4)
	if x3 then
--		return {x3,y3, x5,y5, x6,y6}
		return {x5,y5, x6,y6}
	end
end

function love.load()
	ray = {
		x1=50, y1=100,
		x2=400, y2=400,
	}
	
	line = {100, 400, 600, 100}
	
	reflectedRay = getReflectedRay ()
end

 
function love.update(dt)
	
end


function love.draw()
	love.graphics.setColor (1,1,1)
	love.graphics.line(line)
	
	love.graphics.setColor (1,1,0)
	love.graphics.line(ray.x1, ray.y1, ray.x2, ray.y2)
--	love.graphics.circle ('line', ray.x2, ray.y2, 10)
	
	if reflectedRay then
		love.graphics.setColor (0,1,0)
		love.graphics.line(reflectedRay)
	end

end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
		ray.x1, ray.y1 = x, y
		
	elseif button == 2 then -- right mouse button
		
	end
	reflectedRay = getReflectedRay ()
end

function love.mousemoved( x, y, dx, dy, istouch )
	ray.x2, ray.y2 = x, y
	reflectedRay = getReflectedRay ()
end
