--[[The Separating Axis Theorem (SAT) 
is a collision detection algorithm that can be used in Love2D 
(or any other game development framework/engine) 
to check for collisions between convex polygons. 
]]

-- Separating Axis Theorem with Minimum Translation Vector



local function checkSAT(poly1, poly2)
	local result = {
		length = math.huge,
		edge = {},
		dx = 0,
		dy = 0,
		nx = 0,
		ny = 0,
		x = 0,
		y = 0,
		x1 = 0,
		y1 = 0,
		x2 = 0,
		y2 = 0,
	}

	for index1 = 1, #poly1 - 1, 2 do
		local x1, y1 = poly1[index1], poly1[index1 + 1]
		local index2 = ((index1 + 1) % #poly1) + 1
		local x2, y2 = poly1[index2], poly1[index2 + 1]
		local nx = y1 - y2
		local ny = x2 - x1
		local d = math.sqrt(nx * nx + ny * ny)
		nx = nx / d
		ny = ny / d

		local uBase = x1 * nx + y1 * ny

		local u1min = 0
		local u1max = -math.huge
		for j = 1, #poly1 - 1, 2 do
			local px, py = poly1[j], poly1[j + 1]
			local q = px * nx + py * ny - uBase
			u1max = math.max(u1max, q)
		end
--		print ('u1max', u1max) -- 150 (positive)

		local min_r2 = math.huge
		local max_r2 = -math.huge
		
		local min_u2 = math.huge

		local x, y = 0, 0
		for j = 1, #poly2 - 1, 2 do
			local px, py = poly2[j], poly2[j+1]
			local q = px * nx + py * ny - uBase
			min_r2 = math.min (min_r2, q)
			max_r2 = math.max (max_r2, q)
			
			if (q > 0) then -- collision possible
				min_u2 = math.min (q, min_u2)
				x = px
				y = py
--				print ('min_u2', min_u2)
			end
		end

		min_u2 = math.min (min_u2, max_r2)

		if not (max_r2 >= 1e-10 and min_r2 < u1max) then
			return false

	elseif min_u2 == math.huge then
	
		-- do nothing
	else
--		print ('not huge', min_u2)


			if min_u2 < result.length and max_r2 > 0 and min_r2 < 0 then
				result.length = min_u2
				result.dx = - nx * min_u2
				result.dy = - ny * min_u2
				result.x = x
				result.y = y
				result.x1 = x1
				result.y1 = y1
				result.x2 = x2
				result.y2 = y2
			end
		end
	end

	return result
end



local function checkCollision (poly1, poly2) -- vertices
	local overlap1 = checkSAT (poly1, poly2)
	local overlap2 = checkSAT (poly2, poly1)

	if overlap1 and overlap2 then
		
		if overlap1.length < overlap2.length then
			love.window.setTitle ('real overlap1 '..overlap1.length)
			return overlap1, -1
		else
			love.window.setTitle ('real overlap2 '..overlap1.length)
			return overlap2, 1
		end
	elseif overlap1 then
		love.window.setTitle ('overlap1 '..overlap1.length)
		return
	elseif overlap2 then
		love.window.setTitle ('overlap2 '..overlap2.length)
		return
	end
	love.window.setTitle ('no overlap')
end

local sat = {
	checkCollision = checkCollision,
}
return sat