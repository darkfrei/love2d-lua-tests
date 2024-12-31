print ('loaded', ...)

local utils = {}

-- calculate euclidean distance
function utils.distance(x1, y1, x2, y2)
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- find midpoint between two points
function utils.midpoint(x1, y1, x2, y2)
	return { x = (x1 + x2) / 2, y = (y1 + y2) / 2 }
end

-- check if two points are equal
function utils.arePointsEqual(p1, p2)
	return p1.x == p2.x and p1.y == p2.y
end

-- find the closest cell to a vertex
function utils.closestCellToVertex(vertex, cells)
	local closestCell, minDistance = nil, math.huge
	for _, cell in ipairs(cells) do
		local distance = utils.distance(vertex.x, vertex.y, cell.site.x, cell.site.y)
		if distance < minDistance then
			closestCell = cell
			minDistance = distance
		end
	end
	return closestCell
end

-- find the closest one or two cells to a vertex
function utils.closestCellsToVertex(vertex, cells)
	local closestCells = {}  -- table to store the closest cells
	local minDistance = math.huge  -- start with a very large distance

	-- find the closest cell(s)
	for _, cell in ipairs(cells) do
		local distance = utils.distance(vertex.x, vertex.y, cell.site.x, cell.site.y)

		if distance < minDistance then
			-- found a closer cell, reset the closestCells table
			closestCells = {cell}
			minDistance = distance
		elseif distance == minDistance then
			-- found another cell equally close, add to the table
			table.insert(closestCells, cell)
		end
	end

	-- return either one or two cells (if there is a tie)
	return closestCells
end


-- utils.lua

-- function to check if a point is inside a polygon using the ray-casting algorithm
function utils.isPointInPolygon(x, y, polygon)
	local inside = false
	local n = #polygon
	local p1x, p1y = polygon[1].x, polygon[1].y
	for i = 1, n + 1 do
		local p2x, p2y = polygon[i % n + 1].x, polygon[i % n + 1].y
		if y > math.min(p1y, p2y) then
			if y <= math.max(p1y, p2y) then
				if x <= math.max(p1x, p2x) then
					if p1y ~= p2y then
						local xinters = (y - p1y) * (p2x - p1x) / (p2y - p1y) + p1x
						if p1x == p2x or x <= xinters then
							inside = not inside
						end
					end
				end
			end
		end
		p1x, p1y = p2x, p2y
	end
	return inside
end

-- function to prepare polygon vertices for rendering
function utils.getPolygonVertices(polygon)
	-- list of vertices for rendering:
	-- from {{x=x1, y=y1}, {x=x2, y=y2} ...}
	-- to {x1, y1, x2, y2 ...}
	local vertices = {}
	for _, vertex in ipairs(polygon) do
		table.insert(vertices, vertex.x)
		table.insert(vertices, vertex.y)
	end
	return vertices
end

function utils.evaluateYbyX(arc, x, eventY)
	local denominator = 2 * (arc.y - eventY)
	local numerator = (x - arc.x)^2
	return numerator / denominator + (arc.y + eventY) / 2
end

local function arcArcCrossingCommon(arc1, arc2, eventY)
	-- [arc1.x and arc1.y] — focus coordinates of the first parabola
	-- [arc2.x and arc2.y] — focus coordinates of the second parabola
	local p1x = arc1.x
	local p1y = arc1.y

	local p2x = arc2.x
	local p2y = arc2.y

	local dirY = eventY -- directrix y-coordinate

	-- calculate focal distances
	local f1 = math.abs(dirY - p1y) / 2
	local f2 = math.abs(dirY - p2y) / 2

	-- calculate parabola coefficients for y = ax^2 + bx + c
	local a1 = -1 / (4 * f1)
	local a2 = -1 / (4 * f2)
	local b1 = -2 * p1x * a1
	local b2 = -2 * p2x * a2
	local c1 = p1x * p1x * a1 + p1y + f1
	local c2 = p2x * p2x * a2 + p2y + f2

	-- calculate the coefficients for the resulting quadratic equation
	local a = a1 - a2
	local b = b1 - b2
	local c = c1 - c2

	-- calculate the discriminant
	local d = b * b - 4 * a * c

	local x, y
	if d >= 0 then
		-- solve for the intersection x-coordinate
		x = (-b - math.sqrt(d)) / (2 * a)
		-- calculate the corresponding y-coordinate
		y = a1 * x * x + b1 * x + c1
	end

	-- return the intersection point (x, y) between the two parabolas
	return x, y
end


function utils.arcArcCrossing(arc1, arc2, eventY)
	print ('arcArcCrossing')
	print ('arc1:', arc1.x, arc1.y)
	print ('arc2:', arc2.x, arc2.y)
	print ('eventY:', eventY)


-- case 1: when arc1.y == arc2.y (same foci)
	if arc1.y == arc2.y then
		-- the directrix is horizontal; arcs are symmetrical around the midpoint
		local x = (arc1.x + arc2.x) / 2
		local y = nil

		if (arc1.y == eventY) then
			print ('both arcs lie on the directrix:', eventY)
			y = eventY
		else
			-- calculate y-coordinate based on the parabola equation
			y = utils.evaluateYbyX(arc1, x, eventY)
			print ('case 1, x:', x, 'y:', y)
		end
		return x, y
	end

	-- case 2: when arc1.y == eventY (arc1 is a point on the directrix)
	if arc1.y == eventY then
		return arc1.x, eventY
	end

	-- case 3: when arc2.y == eventY (arc2 is a point on the directrix)
	if arc2.y == eventY then
		return arc2.x, eventY
	end


	-- common case; for given parabolas focus1 and focus2 and direcrix Y
	-- find the crossing between them 

	local x, y = arcArcCrossingCommon (arc1, arc2, eventY)
	print ('arcArcCrossing common case, x:', x, 'y:', y)
	return x, y
end

function utils.createCounter()
	local count = 0 -- initialize the counter
	return function()
		count = count + 1 -- increment the counter
		return count -- return the updated value
	end
end

function utils.findRayIntersection(x0, y0, dx, dy, x1, y1, x2, y2)
	-- calculate the direction vectors
	local edgeDx = x2 - x1
	local edgeDy = y2 - y1

	local denominator = dx * edgeDy - dy * edgeDx
	if denominator == 0 then
		return nil, nil  -- parallel lines, no intersection
	end

	-- solve for t1 (intersection point on the ray)
	local t1 = ((x1 - x0) * edgeDy - (y1 - y0) * edgeDx) / denominator

	-- solve for t2 (intersection point on the edge)
	local t2 = ((x1 - x0) * dy - (y1 - y0) * dx) / denominator

	-- t1 is the parametric value along the ray, t2 along the edge
	if t1 >= 0 and (t2 >= 0 and t2 <= 1) then
		-- intersection point
		local intersectX = x0 + t1 * dx
		local intersectY = y0 + t1 * dy
		return intersectX, intersectY
	end

	return nil, nil  -- no intersection
end


function utils.findRayPolygonCrossing(ray, polygon)
	-- loop through each edge of the polygon
	-- polygon is {{x=x1, y=y1}, {x=x2, y=y2}...}
	local x0, y0 = ray.x, ray.y
	local dx, dy = ray.dx, ray.dy

	for i = 1, #polygon do
		local p1 = polygon[i]
		local p2 = polygon[i % #polygon + 1]  -- wrap around to first point

		local x1, y1 = p1.x, p1.y
		local x2, y2 = p2.x, p2.y

		-- check for intersection with the polygon edge (p1, p2)
		local x, y = utils.findRayIntersection(x0, y0, dx, dy, x1, y1, x2, y2)

		-- return the first intersection point found
		if x and y then
			addTestPoint (x, y)
			return x, y
		end
	end
	return nil, nil  -- no intersection
end

-- function to sort a list of sites


function utils.sortYX(elements) 
	local function sortYXFunction (a, b) 
		if a.y ~= b.y then
			return a.y < b.y -- sort by y-coordinate first
		else
			return a.x < b.x -- if y is equal, sort by x-coordinate
		end
	end
	table.sort(elements, sortYXFunction )
end



return utils
