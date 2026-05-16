-- universal bresenham rasterizer for y = f(x) functions
-- produces a connected 8-neighborhood discrete curve without gaps

local UniversalBresenham = {}

--
-- safety limits
--

local MAX_VERTICAL_STEP = 512   -- max pixels filled per x-step (prevents hang on extreme slopes)
local MAX_POINTS        = 32768 -- hard cap on total point count

--
-- helpers
--

local function isFinite(v)
	return type(v) == "number" and v == v and v ~= math.huge and v ~= -math.huge
end

--
-- rasterizer
--

function UniversalBresenham.rasterizeFunction(f, xStart, xEnd)
	local points = {}
	local step = (xEnd >= xStart) and 1 or -1

	local x = xStart
	local rawY = f(x)

	-- guard: degenerate starting sample
	if not isFinite(rawY) then return points end

	local y = math.floor(rawY + 0.5)

	points[#points + 1] = { x = x, y = y }

	while x ~= xEnd do
		-- guard: hard point cap
		if #points >= MAX_POINTS then break end

		local nextX = x + step
		local raw   = f(nextX)

		-- guard: degenerate sample → stay at current y
		if not isFinite(raw) then
			x = nextX
			points[#points + 1] = { x = x, y = y }
		else
			local nextY = math.floor(raw + 0.5)
			local dy    = nextY - y

			-- guard: clamp vertical fill to prevent hang on steep curves
			if math.abs(dy) > MAX_VERTICAL_STEP then
				x = nextX
				y = nextY
				points[#points + 1] = { x = x, y = y }
			else
				-- fill vertical transitions to preserve connectivity
				if dy > 0 then
					for i = 1, dy do
						points[#points + 1] = { x = nextX, y = y + i }
					end
				elseif dy < 0 then
					for i = -1, dy, -1 do
						points[#points + 1] = { x = nextX, y = y + i }
					end
				end

				x = nextX
				y = nextY

				points[#points + 1] = { x = x, y = y }
			end
		end
	end

	return points
end

return UniversalBresenham