fov = {}
-- i and j - number of columns and rows, integers
-- x and y - part



fov.march_line = function (map, view, i1, j1, i2, j2, radius) -- source and target
	local length = math.abs(i2-i1) + math.abs(j2-j1)
	if length > 1 then
		local dx = (i2-i1)/(length)
		local dy = (j2-j1)/(length)
		for n = 1, length do
--			local i, j = math.floor (i1+n*dx+0.5), math.floor (j1+n*dy+0.5) -- makes path wetweed diagonals
			local i, j = math.floor (i1+n*dx+0.5+0.00001*dy), math.floor (j1+n*dy+0.5-0.000001*dx) -- fixed!
			
			if radius^2 <= ((i1-i)^2+(j1-j)^2) then
				-- out of range for circle
				return
			end
			
			view[i] = view[i] or {}
			if map[i] and map[i][j] and map[i][j] <= 0 then
				-- is opaque
				view[i][j] = false
				return
			else
				-- is transparent
				view[i][j] = true
			end
		end
	else
		if map[i2] and map[i2][j2] and map[i2][j2] <= 0 then
			view[i2] = view[i2] or {}
			view[i2][j2] = false
		end
	end
end

function fov.marching (map, i, j, radius)
	local view = {}
	for i2 = i-radius, i+radius do
		fov.march_line (map, view, i, j, i2, j+radius, radius)
		fov.march_line (map, view, i, j, i2, j-radius, radius)
	end
	for j2 = j-radius+1, j+radius-1 do
		fov.march_line (map, view, i, j, i+radius, j2, radius)
		fov.march_line (map, view, i, j, i-radius, j2, radius)
	end
	return view
end

return fov