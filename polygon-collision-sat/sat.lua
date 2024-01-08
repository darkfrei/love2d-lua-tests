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

		local baseU = x1 * nx + y1 * ny

		local max_r1 = -math.huge
		for j = 1, #poly1 - 1, 2 do
			local px, py = poly1[j], poly1[j + 1]
			local q = px * nx + py * ny - baseU
			max_r1 = math.max(max_r1, q)
		end

		local min_r2, max_r2 = math.huge, -math.huge

		local x, y
		for j = 1, #poly2 - 1, 2 do
			local px, py = poly2[j], poly2[j + 1]
			local q = px * nx + py * ny - baseU
			if min_r2 > q then
				min_r2 = q
				if q > 0 then
					x, y = px, py
				end
			end
			if max_r2 < q then
				max_r2 = q
				x = px
				y = py

			end
		end

		if not (max_r2 >= 0 and max_r1 >= min_r2) then
			return false
		else

			local max_r = math.min (0, max_r2)
			local	min_r = math.max (0, min_r2)

			local overlap = max_r-min_r
			if overlap < result.length and overlap < 0 then
				result.length = overlap
				result.dx = - nx * overlap
				result.dy = - ny * overlap
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
		love.window.setTitle (overlap1.length..' '..overlap2.length)
		return overlap1, overlap2
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