-- License CC0 (Creative Commons license) (c) darkfrei, 2023

-- infinity area cutting

area = {lines={}}
tempLine = {}



local function pseudoScalarProduct(x1, y1, x2, y2, x3, y3, x4, y4)
	local dx1, dy1 = x2-x1, y2-y1
	local dx2, dy2 = x4-x3, y4-y3
	-- positive - goes inside, clockwise
	return dx1 * dy2 - dx2 * dy1
end

local function findIntersection(x1, y1, x2, y2, x3, y3, x4, y4, unlimStart1, unlimEnd1, unlimStart2, unlimEnd2)

	local dx1, dy1 = x2-x1, y2-y1
	local dx2, dy2 = x4-x3, y4-y3
	local denominator = dx1*dy2-dy1*dx2
	if denominator == 0 then
		return nil -- Линии параллельны или совпадают
	end

	local dx13, dy13 = (x1 - x3), (y1 - y3)

	local t = (dx13 * (y3 - y4) - dy13 * (x3 - x4)) / denominator
	local u = (dx13 * (y1 - y2) - dy13 * (x1 - x2)) / denominator

	if 	(unlimStart1 	or t >= 0) and 
	(unlimEnd1 		or t <= 1) and
	(unlimStart2 	or u >= 0) and 
	(unlimEnd2 		or u <= 1) then
		local intersectionX = x1 + t * (x2 - x1)
		local intersectionY = y1 + t * (y2 - y1)
		return intersectionX, intersectionY
	end

--	return nil
end

local function checkCollisions(area, segment)
	local startUnlimited = true
	local endUnlimited = true
	local segmentValid = false

	local x1, y1, x2, y2 = segment[1], segment[2], segment[3], segment[4]
	for i, aLine in ipairs (area.lines) do
		local x3, y3 = aLine.startPoint[1], aLine.startPoint[2]
		local x4, y4 = aLine.endPoint[1], aLine.endPoint[2]

		-- negative for clockwise direction:
		local psp = pseudoScalarProduct(x1, y1, x2, y2, x3, y3, x4, y4)

		local us1, ue1 = startUnlimited, endUnlimited
		local us2, ue2 = aLine.startUnlimited, aLine.endUnlimited

		if psp < 0 then
			local cx, cy = findIntersection(x1, y1, x2, y2, x3, y3, x4, y4, us1, ue1, us2, ue2)
			if cx then
				startUnlimited = false
				segment[1], segment[2] = cx, cy
				aLine.endPoint[1] = cx
				aLine.endPoint[2] = cy
				aLine.endUnlimited = false

				segmentValid = true
			else
				-- no intersection
			end
		elseif psp > 0 then
			local cx, cy = findIntersection(x1, y1, x2, y2, x3, y3, x4, y4, us1, ue1, us2, ue2)
			if cx then
				endUnlimited = false
				segment[3], segment[4] = cx, cy
				aLine.startPoint[1] = cx
				aLine.startPoint[2] = cy
				aLine.startUnlimited = false

				segmentValid = true
			else
				-- no intersection
			end
		else
			-- parallel
			-- no intersection
		end
	end

	if segmentValid then
		print ('segment valid', #area.lines)
		local lines = area.lines
		for iLine = #lines, 1, -1 do
			local jLine = (#lines + iLine-2) % #lines + 1
			print (iLine, jLine)
			
		end
	end



	return startUnlimited, endUnlimited
end

local function cutArea (area, segment)
--	local startUnlimited = true
	local startUnlimited = true
	local endUnlimited = true
--	local endUnlimited = false

	if #segment < 4 then return end

	startUnlimited, endUnlimited = checkCollisions(area, segment)

	local x1, y1, x2, y2 = segment[1], segment[2], segment[3], segment[4]
	local dx, dy = x2 - x1, y2 - y1
	local w, h = love.graphics.getDimensions()

	if (startUnlimited or endUnlimited) and dy ~= 0 then
		local xMin, yMin, xMax, yMax = 10, 10, w - 10, h - 10
		local slope = dx / dy

		-- Calculate extended points for the starting point
		local xStart, yStart
		local xEnd, yEnd


		if dy > 0 then
			--min max
			xStart = x1 + (yMin - y1) * slope
			yStart = yMin

			xEnd = x1 + (yMax - y1) * slope
			yEnd = yMax
		else
			-- max min
			xStart = x1 + (yMax - y1) * slope
			yStart = yMax

			xEnd = x1 + (yMin - y1) * slope
			yEnd = yMin
		end

--		if xStart < xMin or xStart > xMax or xEnd < xMin or xEnd > xMax then
		if xStart < xMin or xStart > xMax then
			if dx > 0 then
				-- min max

				yStart = y1 + (xMin - x1) / slope
				xStart = xMin

			else
				yStart = y1 + (xMax - x1) / slope
				xStart = xMax
			end
		end

		if xEnd < xMin or xEnd > xMax then
			if dx > 0 then
				yEnd = y1 + (xMax - x1) / slope
				xEnd = xMax
			else
				yEnd = y1 + (xMin - x1) / slope
				xEnd = xMin
			end
		end

		if startUnlimited then
			x1, y1 = xStart, yStart
		end
		if endUnlimited then
			x2, y2 = xEnd, yEnd
		end

	elseif (startUnlimited or endUnlimited) and dy == 0 then
		-- Handling the case when the line segment is horizontal (dy == 0)
		local xMin, xMax = 10, w - 10

		-- Calculate extended points for the starting point
		local xStart = dx > 0 and xMin or xMax
		local yStart = y1

		-- Calculate extended points for the ending point
		local xEnd = dx > 0 and xMax or xMin
		local yEnd = y2

		if startUnlimited then
			x1, y1 = xStart, yStart
		end
		if endUnlimited then
			x2, y2 = xEnd, yEnd
		end
	end

	local line = {
		startPoint = {x1, y1},
		endPoint = {x2, y2},
		startUnlimited = startUnlimited,
		endUnlimited = endUnlimited,
	}

	table.insert(area.lines, line)
end

function love.load()

end


function love.update(dt)

end

local function drawCutLine (line)

	if #line > 3 then
		love.graphics.line (line)
	end
end


local function drawInfinityArea(area)
	for _, line in ipairs(area.lines) do
		local startPoint = line.startPoint
		local endPoint = line.endPoint

		love.graphics.line(startPoint[1], startPoint[2], endPoint[1], endPoint[2])
	end
end


function love.draw()
	love.graphics.setLineWidth (3)
	love.graphics.setColor (0.6,0.6,0.6)
	drawInfinityArea (area)
	love.graphics.setColor (1,1,1)
	drawCutLine (tempLine)
end


function love.mousepressed(x, y)
	tempLine = {x, y}
end

function love.mousemoved (x, y)
	tempLine[3] = x
	tempLine[4] = y
	--	tempLine[4] = tempLine[2]
end



function love.mousereleased ( x, y)
	cutArea (area, tempLine)
	tempLine = {}
end


function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end
