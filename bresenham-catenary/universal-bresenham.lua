-- universal bresenham rasterizer for y = f(x) functions
-- produces a connected 8-neighborhood discrete curve without gaps

local UniversalBresenham = {}

function UniversalBresenham.rasterizeFunction(f, xStart, xEnd)
	local points = {}
	local step = (xEnd >= xStart) and 1 or -1

	local x = xStart
	local y = math.floor(f(x) + 0.5)

	-- initial point
	points[#points + 1] = { x = x, y = y }

	while x ~= xEnd do
		local nextX = x + step
		local nextY = math.floor(f(nextX) + 0.5)

		-- sanitize invalid function output (NaN / nil / inf)
		if type(nextY) ~= "number" or nextY ~= nextY then
			nextY = y
		end

		-- fill vertical transitions to preserve connectivity
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

		-- advance state
		x = nextX
		y = nextY

		-- add endpoint of current step
		points[#points + 1] = { x = x, y = y }
	end

	return points
end

return UniversalBresenham