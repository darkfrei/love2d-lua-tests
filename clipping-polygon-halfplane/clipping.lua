-- clipping.lua

-- function to clip a polygon with a half-plane given with points A and B
local function clipByHalfPlane(polygon, pointA, pointB)
	-- calculate normalized normal vector perpendicular to AB
	local normalX = pointB.y - pointA.y
	local normalY = pointA.x - pointB.x

	local length = math.sqrt(normalX^2 + normalY^2)
	normalX = normalX / length
	normalY = normalY / length

	local clippedPolygon = {}

	for i = 1, #polygon-1, 2 do
		local j = ((i+1) % #polygon)+1
		local x1 = polygon[i]
		local y1 = polygon[i + 1]
		local x2 = polygon[j]
		local y2 = polygon[j + 1]

-- calculate side of each vertex relative to the half-plane
		local side1 = (x1 - pointA.x) * normalX + (y1 - pointA.y) * normalY
		local side2 = (x2 - pointA.x) * normalX + (y2 - pointA.y) * normalY

		-- preserve vertices on the negative side of the plane
		if (side1 <= 0) then
			table.insert(clippedPolygon, x1)
			table.insert(clippedPolygon, y1)
		end

		-- add intersection points between edges and the plane
		if side1 * side2 < 0 then
			local t = side1 / (side1 - side2)
			local ix = x1 + t * (x2 - x1)
			local iy = y1 + t * (y2 - y1)
			table.insert(clippedPolygon, ix)
			table.insert(clippedPolygon, iy)
		end
	end

	return clippedPolygon, normalX, normalY
end

return {
	clipByHalfPlane = clipByHalfPlane,
}