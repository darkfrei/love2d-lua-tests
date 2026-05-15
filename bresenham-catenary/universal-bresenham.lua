local UniversalBresenham = {}

function UniversalBresenham.rasterizeFunction(f, xStart, xEnd)
	local points = {}

	local step = (xEnd >= xStart) and 1 or -1

	local x = xStart
	local y = math.floor(f(x) + 0.5)

	points[#points + 1] = { x = x, y = y }

	while x ~= xEnd do
		local nextX = x + step
		local nextY = math.floor(f(nextX) + 0.5)

		-- ensure y is valid
		if type(nextY) ~= "number" or nextY ~= nextY then
			nextY = y
		end

		-- vertical fill (guarantees no gaps)
		local dy = nextY - y

		if dy > 0 then
			for i = 1, dy do
				points[#points + 1] = { x = nextX, y = y + i }
			end
		elseif dy < 0 then
			for i = -1, dy, -1 do
				points[#points + 1] = { x = nextX, y = y + i }
			end
		end

		-- always advance
		x = nextX
		y = nextY

		points[#points + 1] = { x = x, y = y }
	end

	return points
end

return UniversalBresenham