-- License CC0 (Creative Commons license) (c) darkfrei, 2023

-- infinity area cutting

area = {lines={}}
tempLine = {}


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
	drawInfinityArea (area)
	drawCutLine (tempLine)
end


function love.mousepressed(x, y)
	tempLine = {x, y}
end

function love.mousemoved (x, y)
	tempLine[3] = x
	tempLine[4] = y
end

local function pseudoScalarProduct(x1, y1, x2, y2, x3, y3, x4, y4)
	local dx1, dy1 = x2-x1, y2-y1
	local dx2, dy2 = x4-x3, y4-y3
	-- positive - goes inside, clockwise
	return dx1 * dy2 - dx2 * dy1
end

local function cutArea (area, segment)
	local startUnlimited = true
	local endUnlimited = true

	-- Commented out for now as it's not defined in the provided code
	-- startUnlimited, endUnlimited = checkCollisions(area, segment)

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

		if xStart < xMin or xStart > xMax then
			if dx > 0 then
				-- min max
				yStart = y1 + (xMin - x1) / slope
				xStart = xMin
				
				yEnd = y1 + (xMax - x1) / slope
				xEnd = xMax
			else
				yStart = y1 + (xMax - x1) / slope
				xStart = xMax

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
	end

	local line = {
		startPoint = {x1, y1},
		endPoint = {x2, y2},
		startUnlimited = startUnlimited,
		endUnlimited = endUnlimited,
	}

	table.insert(area.lines, line)
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
