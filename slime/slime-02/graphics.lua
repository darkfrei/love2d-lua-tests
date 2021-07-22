local graphics = {}
	
graphics.draw_map = function (i1, j1, i2, j2)
--	for j, is in pairs (map) do
	for j = j1, j2 do
		local is = map[j]
		if is then
			for i = i1, i2 do
				local v = map[j][i]
				if v then
					
					local c = 1-v
					love.graphics.setColor(c,c,c)
					love.graphics.rectangle('fill', (i-0.5)*grid_size, (j-0.5)*grid_size, grid_size, grid_size)
					love.graphics.setColor(0.5,0.5,0.5)
					love.graphics.rectangle('line', (i-0.5)*grid_size, (j-0.5)*grid_size, grid_size, grid_size)
					
					
					if is_tile_wall (i, j)then
						love.graphics.setColor(1,1,1)
						local a = 1/8
						if not (is_tile_wall (i, j-1) or is_tile_wall (i-1, j) or is_tile_wall (i-1, j-1)) then
							love.graphics.line ((i-0.5)*grid_size, (j+(-0.5+a))*grid_size, (i+(-0.5+a))*grid_size, (j-0.5)*grid_size)
						end
						
						if not (is_tile_wall (i, j+1) or is_tile_wall (i-1, j) or is_tile_wall (i-1, j+1)) then
							love.graphics.line ((i-0.5)*grid_size, (j+(0.5-a))*grid_size, (i+(-0.5+a))*grid_size, (j+0.5)*grid_size)
						end
						
						if not (is_tile_wall (i, j-1) or is_tile_wall (i+1, j) or is_tile_wall (i+1, j-1)) then
							love.graphics.line ((i+0.5)*grid_size, (j+(-0.5+a))*grid_size, (i+(0.5-a))*grid_size, (j-0.5)*grid_size)
						end
						
						if not (is_tile_wall (i, j+1) or is_tile_wall (i+1, j) or is_tile_wall (i+1, j+1)) then
							love.graphics.line ((i+0.5)*grid_size, (j+(0.5-a))*grid_size, (i+(0.5-a))*grid_size, (j+0.5)*grid_size)
						end
						
					end
				end
			end
		end
	end
end

return graphics