local camera = {}



function camera.create (width, height)
	camera.x = 0
	camera.y = 0
	camera.w = width
	camera.h = height
end

function camera.update (dt, x, y)
	camera.x = x - width/4
	if y > camera.y+height - grid_size/2 then
		camera.y = y-grid_size
	elseif y < camera.y+grid_size/2 then
		camera.y = y-grid_size
	end
end


return camera