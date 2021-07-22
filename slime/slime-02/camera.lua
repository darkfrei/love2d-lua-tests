local camera = {}



function camera.create (width, height)
	camera.x = 0
	camera.y = 0
	camera.w = width
	camera.h = height
end

function camera.update (dt, x, y)
	camera.x = x - width/4 or width/4
	if y > camera.y+height - grid_size then
		camera.y = y-height/2
	elseif y < camera.y+grid_size then
		camera.y = y-200
	end
	
	camera.w = width
	
	if (x+width)/grid_size > #map[1] then
		if math.random (1, 5) == 5 then
			
			map[#map+1] = {}
		end
		
		for i = 1, #map do
			local r = math.random (1, 5)
			map[i][#map[i]+1] = (r == 1) and 1 or 0
		end

		
	end
end


return camera