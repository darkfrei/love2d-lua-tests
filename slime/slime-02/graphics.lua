local graphics = {}
	
graphics.draw_map = function (i1, j1, i2, j2, view, seen)
--	for j, is in pairs (map) do
	for j = j1, j2 do
		local is = map[j]
		if is then
			for i = i1, i2 do
				local v = map[j][i]
				local is_view = view[j] and view[j][i]
--				local is_seen = seen and seen[j] and seen[j][i]
				local is_seen = seen and seen[i] and seen[i][j]
--				if v and is_view then
				if v and is_seen then
--				if v then
					
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
				elseif not is_seen and not v then
					map[j][i] = 1
				end
			end
		end
	end
end

return graphics