-- Polygon substraction from a rectangle
-- https://love2d.org/forums/viewtopic.php?t=96290

-- this script performs polygon subtraction by iterating over the vertices of a polygon,
-- finding intersection points with another polygon, and constructing the resulting shape.


-- converts a rectangle into a polygon (list of points)
local function rectangleToPolygon(r) -- r is rectangle: x, y, w, h
	return {
		{x=r.x, y=r.y},
		{x=r.x + r.w, y=r.y},
		{x=r.x + r.w, y=r.y + r.h},
		{x=r.x, y=r.y + r.h}
	} -- the array of points as {{x=x1, y=y1}, {x=x2, y=y2}, ...}
end


-- converts a flat list of coordinates into a list of points
local function convertToPoints(coords)
	local points = {}
	for i = 1, #coords, 2 do
		table.insert(points, {x = coords[i], y = coords[i + 1]})
	end
	return points
end

local function convertToCoords(poly)
	local coords = {}
	for i, point in ipairs(poly) do
		table.insert(coords, math.floor(point.x+0.5))
		table.insert(coords, math.floor(point.y+0.5))
	end
	return coords
end


-- checks if a ray intersects with a segment and returns intersection factor
local function doRayIntersect(x1, y1, x2, y2, x3, y3, x4, y4)
	local denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
	if denom == 0 then return false end

	local num1 = (x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)
	local num2 = (x1 - x3) * (y1 - y2) - (y1 - y3) * (x1 - x2)

	local t1 = num1 / denom
	local t2 = num2 / denom

	return t1 >= 0 and t1 <= 1 and t2 >= 0 and t1
end


-- finds the intersection of a ray with a polygon
local function findIntersectionWithPolygon(px, py, dx, dy, poly)
	local n = #poly 	-- here poly is the outer rectangle

	for i = 1, n do
		local j = (i % n) + 1 -- the next one

		local x1, y1 = poly[i].x, poly[i].y
		local x2, y2 = poly[j].x, poly[j].y

		local t1 = doRayIntersect(x1, y1, x2, y2, px, py, dx, dy)
		if t1 then
			local cx = x1 + t1 * (x2 - x1)
			local cy = y1 + t1 * (y2 - y1)

			local intersection = {x=cx, y=cy, isVertex = (t1 == 1), index = i}
			return intersection
		end
	end
end

-- calculates the bisector direction of an angle defined by three points
local function getAngleBisector(p1, p2, p3)
	local x1, y1 = p1.x, p1.y
	local x2, y2 = p2.x, p2.y
	local x3, y3 = p3.x, p3.y

	local ab_x, ab_y = x2 - x1, y2 - y1
	local bc_x, bc_y = x3 - x2, y3 - y2

	local len_ab = math.sqrt(ab_x^2 + ab_y^2)
	local len_bc = math.sqrt(bc_x^2 + bc_y^2)

	ab_x = ab_x / len_ab
	ab_y = ab_y / len_ab
	bc_x = bc_x / len_bc
	bc_y = bc_y / len_bc

	local bisector_x = ab_x + bc_x
	local bisector_y = ab_y + bc_y

	local len_bisector = math.sqrt(bisector_x^2 + bisector_y^2)
	bisector_x = bisector_x / len_bisector
	bisector_y = bisector_y / len_bisector

	return bisector_y, -bisector_x
end


-- iterator for iterating over each vertex and returning its bisector angle
local function vertexIterator(poly)
	local n = #poly  -- number of points

	-- iterator function that returns each vertex and its bisector angle
	local function iter(state, i)
		i = i + 1
		if i > n then return nil end  -- stop after the last vertex

		local a = (i - 2) % n + 1  -- previous point
		local b = (i - 1) % n + 1  -- current point
		local c = i % n + 1        -- next point

		-- extract points
		local p1 = poly[a]
		local p2 = poly[b]
		local p3 = poly[c]

		-- calculate bisector direction
		local bisector_x, bisector_y = getAngleBisector(p1, p2, p3)
		local bisector_angle = math.atan2(bisector_y, bisector_x)

		-- return vertex and bisector angle
--		print (i, p2.x, p2.y)
		return i, p2, bisector_angle
	end
	return iter, poly, 0
end

bisectors = {}
points = {}


local function getPolygonSubtraction(poly1, poly2) -- rectangle, triangle

	local currentPoly = nil
	local prevPoly = nil
	local prevSegmentIndex = nil
	local result = {}



--	for i, a, b, c in vertexIterator (poly2) do
	for i, vertex, angle in vertexIterator(poly2) do
--		each vertex starts the polygon
		currentPoly = {}
		table.insert (result, currentPoly)

		local lRay = 30
		local x1 = vertex.x
		local y1 = vertex.y
		local x2 = vertex.x + lRay*math.cos (angle)
		local y2 = vertex.y + lRay*math.sin (angle)

		table.insert(bisectors, {x1, y1, x2, y2})

		-- crossing
		local point = findIntersectionWithPolygon(x1, y1, x2, y2, poly1)

		table.insert (points, point)

		-- current
		table.insert (currentPoly, vertex)
		table.insert (currentPoly, point) -- second or last is crossing

		-- prev
		if prevPoly then
			local indexFrom = prevPoly[2].index+1 -- second or last is crossing
			local indexTo = point.index
			print ('indexFrom: '..indexFrom, 'indexTo: '..indexTo)
			if indexFrom > indexTo then
				print ('fixed, was:', 'indexFrom: '..indexFrom, 'indexTo: '..indexTo)
				indexTo = indexTo + #poly1
				print ('fixed, now:', 'indexFrom: '..indexFrom, 'indexTo: '..indexTo)
			end

			for i = indexFrom, indexTo do
				local index = (i-1) % #poly1 + 1 -- restore circle
				local outPoint = poly1[index]
				table.insert (prevPoly, outPoint)
			end
			table.insert (prevPoly, point)
			table.insert (prevPoly, vertex)
		end
		prevPoly = currentPoly
	end



	if prevPoly then
--		print ('#prevPoly', #prevPoly)

		currentPoly = result[1]
		local vertex = currentPoly[1]
		local point = currentPoly[2]

		-- same as above:
		local indexFrom = prevPoly[2].index+1
		local indexTo = point.index
		print ('last', 'indexFrom: '..indexFrom, 'indexTo: '..indexTo)
		if indexFrom > indexTo then
			print ('last', 'fixed, was:', 'indexFrom: '..indexFrom, 'indexTo: '..indexTo)
			indexTo = indexTo + #poly1
			print ('last', 'fixed, now:', 'indexFrom: '..indexFrom, 'indexTo: '..indexTo)
		end

		for i = indexFrom, indexTo do
			local index = (i-1) % #poly1 + 1 -- restore circle
			print ('last', 'adding index '..index)
			local outPoint = poly1[index]
			table.insert (prevPoly, outPoint)
		end
		table.insert (prevPoly, point)
		table.insert (prevPoly, vertex)
	end


	-- option 1: restore polygons to simple (no self crossings)
	-- option 2: restore polygons to clockwise
	
	
	
	-- option 3: set polyon.vertices as coordinata pairs: {x1, y1, x2, y2}
	--           for love2d format:
	for i, poly in ipairs (result) do
		print (i, '#points: '.. #poly)
		poly.vertices = convertToCoords(poly)
		print (table.concat (poly.vertices, ','))
	end
	
	return result
end


------------- start


local rectangle = {
	x=50,
	y=50, 
	w=700,
	h=500
}

-- triangle
local triangle = {

	400,150, -- top
	600,350, -- right
	200,350, -- left
}

local p1 = rectangleToPolygon (rectangle) -- rectangle
local p2 = convertToPoints (triangle) -- triangle

local arrayP = getPolygonSubtraction(p1, p2)


local function getColor(i, n)
	local t = (i - 1) / (n - 1)
	local r = math.max(0, 1 - math.abs(2 * t - 0) * 2) -- красный от 1 до 0
	local g = math.max(0, 1 - math.abs(2 * t - 1) * 2) -- зелёный в центре
	local b = math.max(0, 1 - math.abs(2 * t - 2) * 2) -- синий от 0 до 1
--	print(i, n, r, g, b)
	return r, g, b
end


function love.draw()
	-- rectangle:
	love.graphics.setColor(1, 1, 1)
	love.graphics.setLineWidth(5)
	love.graphics.rectangle('line', rectangle.x, rectangle.y, rectangle.w, rectangle.h)

	-- triangle:
	love.graphics.setLineWidth(5)
	love.graphics.polygon('line', triangle)

	-- test rays:
	love.graphics.setColor(0, 1, 0)
	love.graphics.setLineWidth(3)

	for i, line in ipairs(bisectors) do
		love.graphics.setColor(getColor(i, #bisectors))
		love.graphics.line(line)
	end

	for i, point in ipairs(points) do
		love.graphics.setColor(getColor(i, #points))
		love.graphics.circle('fill', point.x, point.y, 5)
	end

	-- result polygons:
	love.graphics.setLineWidth(1)
	for iPoly, poly in ipairs(arrayP) do
		local r, g, b = getColor(iPoly, #arrayP)
		local c = 0.5
		love.graphics.setColor(c*r,c*g,c*b,c)
		love.graphics.polygon ('fill', poly.vertices)
		
		love.graphics.setColor(r,g,b,1)
		for i = 1, #poly do
			local j = i % #poly + 1
--			print (i, j, #poly)
			local x1, y1 = poly[i].x, poly[i].y
			local x2, y2 = poly[j].x, poly[j].y
			love.graphics.line (x1, y1, x2, y2)
		end
	end
end