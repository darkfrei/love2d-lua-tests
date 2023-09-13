-- License cc0
-- darkfrei 2023

local HalfPlanesLib = {}


function HalfPlanesLib:new(point, dx, dy, color) -- dx and dy as direction of plane
--> Create a new HalfPlanesLib object with a given point and direction vector.
	-- Calculate the length of the direction vector:
	local len = math.sqrt(dx * dx + dy * dy)
	if not color then
		
		color = {1,0,0}
	end

	-- Create a new object with the specified point and normalized direction vector.
	local obj = {
		-- Store the point as a table with 'x' and 'y' coordinates.
		point = {x = point.x, y = point.y},

		-- Calculate and store the normalized direction vector.
		normal = {x = dx / len, y = dy / len},
		
		color = color,
		fillColor = {color[1]/2, color[2]/2, color[3]/2, 0.5},
	}

	-- Set the metatable for the new object to 'self'.
	setmetatable(obj, self)

	-- Define '__index' for the object to use 'self'.
	self.__index = self

	-- Return the newly created object.
	return obj
end


function HalfPlanesLib:contains(point)
--> Check if a point is inside the half-plane.
	local dx = point.x - self.point.x
	local dy = point.y - self.point.y
	local dotProduct = dx * self.normal.x + dy * self.normal.y

	-- If the point is inside the half-plane, then dotProduct should be greater than or equal to 0.
	return dotProduct >= 0
end


function HalfPlanesLib:getIntersectionPoint(other)
--> Calculate the intersection point between two half-planes.

	-- Extract the coordinates and normals of the first half-plane:
	local px1, py1 = self.point.x, self.point.y
	local nx1, ny1 = self.normal.x, self.normal.y

	-- Extract the coordinates and normals of the second half-plane:
	local nx2, ny2 = other.normal.x, other.normal.y
	local px2, py2 = other.point.x, other.point.y

	-- Calculate the dot products of the first and second half-planes:
	local c1 = nx1 * px1 + ny1 * py1
	local c2 = nx2 * px2 + ny2 * py2

	-- Calculate the determinant of the system of equations:
	local det = nx1 * ny2 - nx2 * ny1

	-- If the determinant is zero, the lines are parallel and do not intersect:
	if det == 0 then return end

	-- Calculate the intersection point using Cramer's rule:
	local x = (ny2 * c1 - ny1 * c2) / det
	local y = (nx1 * c2 - nx2 * c1) / det

	return {x=x, y=y}
end

function HalfPlanesLib:getPolygon(x, y, w, h)
--> Calculate the polygon and line formed by the intersection of the half-plane with a rectangle.
	-- Edge points:
	local p1 = {x=x, y=y}
	local p2 = {x=x+w, y=y}
	local p3 = {x=x+w, y=y+h}
	local p4 = {x=x, y=y+h}
	local polygon = {} -- polygon as list of points
	local line = {} -- line as list of points

	-- Check if the half-plane contains point p1 and add it to the polygon if true:
	if self:contains(p1) then
		table.insert(polygon, p1)
	end

	-- Calculate the intersection point and add it to the polygon and line if it exists:
	if (self:contains(p1) and not self:contains(p2)) or (not self:contains(p1) and self:contains(p2)) then
		local x1 = self.point.x + (self.point.y - y) * self.normal.y / self.normal.x
		table.insert(polygon, {x=x1, y=y})
		table.insert(line, {x=x1, y=y})
	end

	-- Check if the half-plane contains point p2 and add it to the polygon if true:
	if self:contains(p2) then
		table.insert(polygon, p2)
	end

	-- Calculate the intersection point and add it to the polygon and line if it exists.
	if (self:contains(p2) and not self:contains(p3)) or (not self:contains(p2) and self:contains(p3)) then
		local y2 = self.point.y - (x+w - self.point.x) * self.normal.x / self.normal.y
		table.insert(polygon, {x=x+w, y=y2})
		table.insert(line, {x=x+w, y=y2})
	end

	-- Check if the half-plane contains point p3 and add it to the polygon if true.
	if self:contains(p3) then
		table.insert(polygon, p3)
	end

	-- Calculate the intersection point and add it to the polygon and line if it exists.
	if (self:contains(p3) and not self:contains(p4)) or (not self:contains(p3) and self:contains(p4)) then
		local x2 = self.point.x - ((y+h - self.point.y)) * self.normal.y / self.normal.x
		table.insert(polygon, {x=x2, y=y+h})
		table.insert(line, {x=x2, y=y+h})
	end

	-- Check if the half-plane contains point p4 and add it to the polygon if true.
	if self:contains(p4) then
		table.insert(polygon, p4)
	end

	-- Calculate the intersection point and add it to the polygon and line if it exists.
	if (self:contains(p4) and not self:contains(p1)) or (not self:contains(p4) and self:contains(p1)) then
		local y1 = self.point.y - (x - self.point.x) * self.normal.x / self.normal.y
		table.insert(polygon, {x=x, y=y1})
		table.insert(line, {x=x, y=y1})
	end

	return polygon, line
end

--------------	------	--------------
--------------	Love2D	--------------
--------------	------	--------------
function HalfPlanesLib:draw()
	-- Create and draw the polygon if not already created
	if not self.polygon then
		local x, y = 5, 5
		local w, h = love.graphics.getWidth() - 2 * x, love.graphics.getHeight() - 2 * y

		-- Generate the polygon and line data
		local polygon, line = self:getPolygon(x, y, w, h)
		self.polygon = {}

		-- Convert polygon data to a flat table for rendering
		for i = 1, #polygon do
			table.insert(self.polygon, polygon[i].x)
			table.insert(self.polygon, polygon[i].y)
		end

		self.line = {}

		-- Convert line data to a flat table for rendering
		for i = 1, #line do
			table.insert(self.line, line[i].x)
			table.insert(self.line, line[i].y)
		end
	end

	-- Set color and draw the filled polygon
	
	love.graphics.setColor(self.fillColor)

	if #self.polygon >=6 then
		love.graphics.polygon('fill', self.polygon)

		love.graphics.setColor(self.color)
		love.graphics.setLineWidth (2)
		love.graphics.line(self.line)
	else
		-- not cutted
	end



--[[
	--------------------------------------
	-- Draw a simple line representing the half-plane
	love.graphics.setColor(1, 1, 1)

	-- Calculate points for drawing the half-plane line
	local px1 = self.point.x + 100 * self.normal.y
	local py1 = self.point.y - 100 * self.normal.x
	local px2 = self.point.x - 100 * self.normal.y
	local py2 = self.point.y + 100 * self.normal.x

	local nx = self.point.x + 20 * self.normal.x
	local ny = self.point.y + 20 * self.normal.y

	-- Draw the half-plane line and half-plane direction:
	love.graphics.line(self.point.x, self.point.y, nx, ny)
	love.graphics.line(px1, py1, px2, py2)

	-- Draw a small circle at the half-plane point
	love.graphics.circle('line', self.point.x, self.point.y, 4)
]]

end



return HalfPlanesLib