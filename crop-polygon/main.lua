-- License CC0 (Creative Commons license) (c) darkfrei, 2023

--love.window.setMode(1280, 800) -- Steam Deck resolution
--Width, Height = love.graphics.getDimensions( )





local function findIntersection(x1, y1, x2, y2, x3, y3, x4, y4)
	-- x1, y1, x2, y2 - segment
	-- x3, y3, x4, y4 - continuous line
	local dx1, dy1 = x2-x1, y2-y1
	local dx2, dy2 = x4-x3, y4-y3
	local denominator = dx1*dy2-dy1*dx2
	if denominator == 0 then
		return nil -- Линии параллельны или совпадают
	end

	local dx13, dy13 = (x1 - x3), (y1 - y3)

	local t = (dx13 * (y3 - y4) - dy13 * (x3 - x4)) / denominator
	local u = (dx13 * (y1 - y2) - dy13 * (x1 - x2)) / denominator

	if t >= 0 and t <= 1 and u >= 0 then
		local intersectionX = x1 + t * (x2 - x1)
		local intersectionY = y1 + t * (y2 - y1)
		return intersectionX, intersectionY
	end

	return nil
end

local function pseudoScalarProduct(x1, y1, x2, y2, x3, y3, x4, y4)
	local dx1, dy1 = x2-x1, y2-y1
	local dx2, dy2 = x4-x3, y4-y3
	-- positive - goes inside, clockwise
	return dx1 * dy2 - dx2 * dy1
end


local function cropPolygon(polygon, line)
	local x3, y3, x4, y4 = line[1], line[2], line[3], line[4]

	local segments = {}
	local goesInside = nil

	for i = 1, #polygon-1, 2 do
		local x1, y1 = polygon[i], polygon[i + 1]
		local j = (i + 1)%(#polygon)+1
		local x2, y2 = polygon[j], polygon[j + 1]
		local cx, cy = findIntersection(x1, y1, x2, y2, x3, y3, x4, y4)

		local segment = {x1=x1, y1=y1, x2=x2, y2=y2}

		if cx then
			segment.cx = cx
			segment.cy = cy
			goesInside = pseudoScalarProduct(x1, y1, x2, y2, x3, y3, x4, y4) > 0
			segment.goesInside = goesInside
		elseif goesInside ~= nil then
			segment.goesInside = goesInside
		end

		table.insert(segments, segment)
	end

	for i = 1, #segments do
		local segment = segments[i]
		if segment.goesInside == nil then
			segment.goesInside = goesInside
		else
			break
		end
	end

	local clippedPolygon = {}

--	print ('	', #segments)
	local isInside

	local firstSegment = segments[1]
	if not firstSegment.cx and not firstSegment.goesInside then
		table.insert (clippedPolygon, firstSegment.x1)
		table.insert (clippedPolygon, firstSegment.y1)
	elseif firstSegment.cx and firstSegment.goesInside then

		table.insert (clippedPolygon, firstSegment.x1)
		table.insert (clippedPolygon, firstSegment.y1)
	end

	local cx, cy
	for i = 1, #segments do
		local segment = segments[i]
		if segment.cx and segment.goesInside then
--			print (i, 'cx, ins')
			table.insert (clippedPolygon, segment.cx)
			table.insert (clippedPolygon, segment.cy)

			table.insert (clippedPolygon, cx)
			table.insert (clippedPolygon, cy)
		elseif segment.goesInside then
			--print (i, 'ins')
			-- do nothing
		elseif segment.cx and not segment.goesInside then
			--print (i, 'cx, not ins')
			table.insert (clippedPolygon, segment.cx)
			table.insert (clippedPolygon, segment.cy)

			if (not (i == #segments)) then
				table.insert (clippedPolygon, segment.x2)
				table.insert (clippedPolygon, segment.y2)
			end
			-- for not polygons: 
--			cx, cy = segment.cx, segment.cy
		elseif not segment.goesInside then
			--print (i, 'not ins')
			if (not (i == #segments)) then
				table.insert (clippedPolygon, segment.x2)
				table.insert (clippedPolygon, segment.y2)
			end
		else
			--print ('what')
		end
	end 


	return clippedPolygon
end


polygon1 = {300, 100, 600, 200, 500, 400, 200, 500}
--polygon1 = {300, 100, 800, 200, 900, 400}
cropperLine = {100,100, 600, 50}
polygon2 = cropPolygon (polygon1, cropperLine)

function love.load()

end


function love.update(dt)

end

function love.draw()
	love.graphics.setLineWidth (3)
	love.graphics.setColor (0.5,0.5,0.5)
	love.graphics.polygon ('line', polygon1)
	--	love.graphics.line (polygon1)

	love.graphics.setColor (0.8,0,0)
	love.graphics.line (cropperLine)

	if polygon2 and #polygon2 > 2 then
		love.graphics.setColor (0,0.8,0)
		love.graphics.polygon ('line', polygon2)
		--		love.graphics.line (polygon2)
	end
end


function love.mousepressed( x, y, button, istouch, presses )
	cropperLine[1] = x
	cropperLine[2] = y

	polygon2 = cropPolygon (polygon1, cropperLine)
end

function love.mousemoved( x, y, dx, dy, istouch )
	cropperLine[3] = x
	cropperLine[4] = y

	polygon2 = cropPolygon (polygon1, cropperLine)
end


function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end
