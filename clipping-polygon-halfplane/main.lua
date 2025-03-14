-- main.lua
local clipping= require ('clipping') -- clipping.lua
local clipByHalfPlane = clipping.clipByHalfPlane

function love.load()
	-- get window dimensions
	local w, h = love.graphics.getDimensions ()

	-- define bounding rectangle (full window)
	bounding = {0,0, w,0, w,h, 0,h}
	clippedBounding = {}

	-- define initial triangle polygon
	polygon = {200, 100, 600, 100, 600, 500} -- {x1, y1, x2, y2, x3, y3}
	clippedPolygon = {} -- this will store the result of the clipping

	pointA = {x = 410, y = 290} -- fixed point a
	pointB = {x = 410, y = 290} -- point b (mouse position)

	-- perform initial clipping
	clippedPolygon, normalX, normalY = clipByHalfPlane(polygon, pointA, pointB)
	clippedBounding = clipByHalfPlane(bounding, pointB, pointA)
end

function love.mousepressed (x, y, b)
	if b == 1 then
		-- left mouse button adds points to polygon
		table.insert (polygon, x)
		table.insert (polygon, y)
	elseif #polygon > 6 then
		-- right mouse button removes last point
		table.remove (polygon)
		table.remove (polygon)
	end

	-- update clipped polygons after modification
	clippedPolygon, normalX, normalY = clipByHalfPlane(polygon, pointA, pointB)
end
function love.mousemoved (x, y)
	-- update pointB position with mouse movement
	pointB.x = x
	pointB.y = y

	-- update clipped polygons after modification
	clippedPolygon, normalX, normalY = clipByHalfPlane(polygon, pointA, pointB)
	clippedBounding = clipByHalfPlane(bounding, pointB, pointA)
end

function love.draw()
	-- draw clipped bounding area
	if #clippedBounding >= 6 then
		love.graphics.setColor(0.4, 0, 0, 0.4)
		love.graphics.polygon("fill", clippedBounding)
		love.graphics.setColor(1, 0, 0)
		love.graphics.polygon("line", clippedBounding)
	end

	-- draw original polygon
	love.graphics.setColor(1, 1, 1)
	love.graphics.polygon("line", polygon)
	for i = 1, #polygon-1, 2 do
		love.graphics.print ((i-1)/2+1, polygon[i]+5, polygon[i+1]-14)
	end

	-- draw the clipped polygon
	if #clippedPolygon >= 6 then
		love.graphics.setColor(0, 0.4, 0, 0.4)
		love.graphics.polygon("fill", clippedPolygon)

		love.graphics.setColor(0, 1, 0)
		love.graphics.polygon("line", clippedPolygon)
		for i = 1, #clippedPolygon-1, 2 do
			love.graphics.print ((i-1)/2+1, clippedPolygon[i]+5, clippedPolygon[i+1])
		end
	end

	-- draw clipping line and normal vector
	love.graphics.setColor(0, 0, 1)
	love.graphics.line(pointA.x, pointA.y, pointB.x, pointB.y)
	local normalLength = 50 -- length of the normal for visualization
	local normalEndX = pointA.x + normalX * normalLength
	local normalEndY = pointA.y + normalY * normalLength
	love.graphics.line(pointA.x, pointA.y, normalEndX, normalEndY)

	-- add arrowhead to normal vector
	local arrowSize = 10
	local angle = math.atan2(normalY, normalX)
	local arrowX1 = normalEndX - arrowSize * math.cos(angle - math.pi / 6)
	local arrowY1 = normalEndY - arrowSize * math.sin(angle - math.pi / 6)
	local arrowX2 = normalEndX - arrowSize * math.cos(angle + math.pi / 6)
	local arrowY2 = normalEndY - arrowSize * math.sin(angle + math.pi / 6)
	love.graphics.line(normalEndX, normalEndY, arrowX1, arrowY1)
	love.graphics.line(normalEndX, normalEndY, arrowX2, arrowY2)
end

function love.keypressed (key, scancode)
	if key == 'escape' then
		love.event.quit()
	end
end
