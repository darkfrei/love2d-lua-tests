--[[The Separating Axis Theorem (SAT) 
is a collision detection algorithm that can be used in Love2D 
(or any other game development framework/engine) 
to check for collisions between convex polygons. 
]]

-- Separating Axis Theorem with Minimum Translation Vector



local function checkSATCollision(vertices1, vertices2)
	-- Separating Axis Theorem with Minimum Translation Vector
	local function projectVertices(vertices, dx, dy)
		local min, max = math.huge, -math.huge
		local indexMin, indexMax
		for i = 1, #vertices-1, 2 do
			local dotProduct = vertices[i]*dy-vertices[i+1]*dx
			if dotProduct < min then 
				min = dotProduct 
				indexMin = i
			end
			if dotProduct > max then 
				max = dotProduct 
				indexMax = i
			end
		end
		return min, max, indexMin, indexMax
	end
	
	local minDist = math.huge
	local dx, dy
	local x1, y1, x2, y2 = vertices1[#vertices1-1], vertices1[#vertices1],vertices1[1], vertices1[2]
	for i = 1, #vertices1-1, 2 do
    local nx, ny = x2-x1, y2-y1
		local length = math.sqrt(nx*nx+ny*ny)
    nx, ny = nx/length, ny/length
    local min1, max1, indexMin1, indexMax1 = projectVertices(vertices1, nx, ny)
    local min2, max2, indexMin2, indexMax2 = projectVertices(vertices2, nx, ny)
		local dist = math.min (max2-min1, max1-min2)
    if dist < 0 then
      return false -- no collision
		elseif minDist >= dist then
			minDist = dist
			dx, dy = ny, -nx
		end
		x1, y1, x2, y2 = x2, y2, vertices1[i+2], vertices1[i+3]
  end
	if minDist*2^45 < 1 then
		minDist = 0
	end
  return minDist, minDist*dx, minDist*dy -- collision and direction
end

-- example: 
local vertices1 = {0,0, 200,0, 0,100}
local vertices2 = {50,50, 60,80, 80,60}
local dist, dx, dy = checkSATCollision(vertices1, vertices2)
print (dist, dx, dy) -- 24.149534156998	10.8	21.6
local str = ''
for i = 1, #vertices2-1, 2 do
	vertices2[i] = vertices2[i] + dx
	vertices2[i+1] = vertices2[i+1] + dy
	str = str .. vertices2[i] .. ', ' .. vertices2[i+1] .. ', '
end
print (str) -- 58.8, 70.6, 70.8, 101.6, 90.8, 81.6, 
dist, dx, dy = checkSATCollision(vertices1, vertices2)
print (dist, dx, dy) -- 0	0.0	0.0

return checkSATCollision