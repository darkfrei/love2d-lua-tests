local voronoi = {}

function voronoi.newPoints (width, height, amount)
	local points = {}
	for i = 1, amount do
		local x = math.random (width)
		local y = math.random (height)
		table.insert (points, x)
		table.insert (points, y)
	end
	return points
end

return voronoi