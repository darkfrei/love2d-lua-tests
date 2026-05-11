local Parabola = {}

function Parabola.collect(cx, cy, p, maxX)
	assert(p > 0, "p must be positive")

	local coefficient = 1 / (4 * p)

	local x = 0
	local y = 0

	local points = {}

	while x <= maxX do
		table.insert(points, { cx + x, cy - y })

		if x ~= 0 then
			table.insert(points, { cx - x, cy - y })
		end

		local moveX = 0
		local moveY = 0

		if math.sqrt((y + 1) / coefficient) - x - 0.5 > 0 then
			moveX = 1
		end

		if coefficient * (x + 1) * (x + 1) - y - 0.5 >= 0 then
			moveY = 1
		end

		x = x + moveX
		y = y + moveY
	end

	return points
end

function Parabola.draw(cx, cy, p, maxX, dotSize)
	dotSize = dotSize or 2

	local points = Parabola.collect(cx, cy, p, maxX)

	for _, point in ipairs(points) do
		love.graphics.rectangle(
			"fill",
			point[1] - dotSize * 0.5,
			point[2] - dotSize * 0.5,
			dotSize,
			dotSize
		)
	end
end

function Parabola.drawSmooth(cx, cy, p, maxX)
	local vertices = {}
	local step = 2

	for x = -maxX, maxX, step do
		local y = (x * x) / (4 * p)

		table.insert(vertices, cx + x)
		table.insert(vertices, cy - y)
	end

	if #vertices >= 4 then
		love.graphics.line(vertices)
	end
end

return Parabola