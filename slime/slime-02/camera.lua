local camera = {}

camera.x = 0
camera.y = 0



function camera.update (dt, x)
	camera.x = x - width/4 or width/4
	
	if (x+width)/grid_size > #map[1] then
		for i = 1, #map do
			local r = math.random (1, 6)
			map[i][#map[i]+1] = (r == 1) and 1 or 0
		end
--	else
--		lastx = lastx or 0
--		if lastx < x then
--			lastx = x + 200
----			print (x, width, grid_size, ((x-width/2)/grid_size), #map[1])
--		end
		
	end
end


return camera