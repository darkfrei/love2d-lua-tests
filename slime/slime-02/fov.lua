fov = {}
-- i and j - number of columns and rows, integers
-- x and y - part

fov.is_opaque = function (map, i, j)
	-- must be custom function;
	-- in this situation 1 or more than 0 is opaque, rest is transperent
--	return map[i] and map[i][j] and map[i][j] >= 1
	return map[j] and map[j][i] and map[j][i] >= 1
end

fov.march_line = function (map, view, i1, j1, i2, j2, radius) -- source and target
	local length = math.abs(i2-i1) + math.abs(j2-j1)
	if length > 1 then
		local dx = (i2-i1)/(length)
		local dy = (j2-j1)/(length)
		for n = 1, length do
--			local i, j = math.floor (i1+n*dx+0.5), math.floor (j1+n*dy+0.5) -- makes path wetweed diagonals
--			local i, j = math.floor (i1+n*dx+0.5+0.00001*dy), math.floor (j1+n*dy+0.5-0.000001*dx) -- fixed!
			local i, j = math.floor (i1+n*dx+0.5+0.00001*dy), math.floor (j1+n*dy+0.5-0.000001*dx) -- fixed!
			
			if radius^2 <= ((i1-i)^2+(j1-j)^2) then
				-- out of range for circle
				return
			end
			
			view[i] = view[i] or {}
			view[i][j] = true -- true means "I see that", also walls
--			view[j] = view[i] or {}
--			view[j][i] = true -- true means "I see that", also walls
			
--			if fov.is_opaque (map, i, j) then
			if fov.is_opaque (map, j, i) then
				-- is opaque
				return
			else
				-- is transparent
				-- do nothing
			end
		end
	else -- length == 1 or 0
--		if map[i2] and map[i2][j2] and map[i2][j2] <= 0 then
--			view[i2] = view[i2] or {}
--			view[i2][j2] = false
--		end
	end
end

function fov.marching (map, seen, i, j, radius)
	local view = {}
	view[i]={}
	view[i][j]=true
	for i2 = i-radius, i+radius do
		fov.march_line (map, view, i, j, i2, j+radius, radius)
		fov.march_line (map, view, i, j, i2, j-radius, radius)
	end
	for j2 = j-radius+1, j+radius-1 do
		fov.march_line (map, view, i, j, i+radius, j2, radius)
		fov.march_line (map, view, i, j, i-radius, j2, radius)
	end
	for i, js in pairs (view) do
--		seen[i] = seen[i] or {}
		
		for j, v in pairs (js) do
			seen[j] = seen[j] or {}
			seen[j][i] = true
--			seen[i][j] = true
		end
	end
	return view
end

return fov