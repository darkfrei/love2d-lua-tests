love.graphics.rcircle = function( mode, x, y, radius )
	love.graphics.rectangle( mode, x-radius, y-radius, radius*2, radius*2)
end

local slime = {}

function slime.new(x, y)
	
	slime.grid_size = 96
	slime.slime_size = 24
	
	slime.r = 12

	slime.g = 40*96
	slime.jump_vy = 10*96
	slime.vx_max=5*96
	slime.ax_max=24*24*10
	slime.wall_speed = 4*24
	
	slime.x=x slime.y=y
	slime.vx=0 slime.vy=0

	slime.on_floor = false
	slime.on_ceiling = false
	slime.on_wall = false
end

function is_tile_wall (i, j)
	return map[j] and map[j][i] and map[j][i] == 1 or not (map[j] and map[j][i])
end

function get_grid (x, y)
	return math.floor(x/grid_size+0.5), math.floor(y/grid_size+0.5)
end

function bounce_floor (dt)
	local bevel = 0.8*slime.r
	-- dynamic solution
	local i1d, j1d = get_grid (slime.x+dt*slime.vx-bevel-0.00001, slime.y+slime.r+dt*slime.vy)
	local i2d, j2d = get_grid (slime.x+dt*slime.vx, slime.y+slime.r+dt*slime.vy)
	local i3d, j3d = get_grid (slime.x+dt*slime.vx+bevel, slime.y+slime.r+dt*slime.vy)
	if is_tile_wall (i2d, j2d) and not slime.on_ceiling then
		slime.y = (j2d-0.5)*grid_size-slime.r
		slime.vy = 0
		slime.on_floor = true
	else
		slime.on_floor = false
	end
end

function bounce_ceiling (dt)
	-- actual position
	local i, j = get_grid (slime.x, slime.y)
	-- static solution
	local i7, j7 = get_grid (slime.x-slime.r/2, slime.y-slime.r-0.00001)
	local i8, j8 = get_grid (slime.x, slime.y-slime.r-0.00001)
	local i9, j9 = get_grid (slime.x+slime.r/2, slime.y-slime.r-0.00001)
	-- dynamic solution
	local i8d, j8d = get_grid (slime.x+dt*slime.vx, slime.y-slime.r+dt*slime.vy-0.00001)
--	if (not slime.on_ceiling) and is_tile_wall (i8d, j8d) then
	if (not slime.on_ceiling) and is_tile_wall (i8d, j8d) then
--		print ("bounce_ceiling - " .. i8d .. ' '..j8d)
		slime.y = (j-0.5)*grid_size+slime.r
		slime.vy = 0
		slime.on_ceiling = true
--	elseif not (slime.on_ceiling) and (is_tile_wall (i7, j7) or is_tile_wall (i9, j9)) then
--		slime.vy = 0
--		slime.y = (j-0.5)*grid_size+slime.r
--		slime.on_ceiling = true
--	elseif slime.on_ceiling and (is_tile_wall (i8, j8) or is_tile_wall (i7, j7) or is_tile_wall (i9, j9)) then
	elseif slime.on_ceiling and (is_tile_wall (i8, j8)) then
		-- idle on ceiling
		slime.vy = 0
	else
		slime.on_ceiling = false
	end
end

function bounce_wall (dt)
	
	
	
	if slime.vx == 0 then 
		local i4, j4 = get_grid (slime.x-slime.r-0.00001, slime.y)
		local i6, j6 = get_grid (slime.x+slime.r, slime.y)
		if slime.on_wall and not (is_tile_wall (i4, j4) or is_tile_wall (i6, j6)) then
			slime.on_wall = false
		elseif slime.vy>slime.wall_speed then
			if not slime.on_wall and is_tile_wall (i4, j4) then
				-- left
				slime.x = (i4+0.5)*grid_size+slime.r
				slime.on_wall = true
			elseif not slime.on_wall and is_tile_wall (i6, j6) then
				-- right
				slime.x = (i6-0.5)*grid_size-slime.r
				slime.on_wall = true
			end
		end
		return 
	end
	local sign = slime.vx > 0 and 1 or slime.vx < 0 and -1 or 0
	
	-- current cell
	local i, j = get_grid (slime.x, slime.y)
	--- static solution: 
	local i3d, j3d = get_grid (slime.x+sign*slime.r+dt*slime.vx+sign*0.00001, slime.y-slime.r/2+dt*slime.vy)
	--- dynamic solution: 
	local i2d, j2d = get_grid (slime.x+sign*slime.r+dt*slime.vx+sign*0.00001, slime.y+dt*slime.vy)


	if is_tile_wall (i2d, j2d) then
		if is_tile_wall (i3d, j3d) then
			slime.vx = 0
		end
		slime.x = (i+sign*0.5)*grid_size-sign*slime.r
		if slime.vy >= 0 then
			slime.on_wall = true
		end
	elseif is_tile_wall (i3d, j3d) then
		slime.vx = 0
--		slime.r = slime.r + 2
	else
		slime.on_wall = false
	end

end





function slime.update(dt, map)
	
	if love.keyboard.isDown('d') then
		slime.vx = slime.vx + dt*slime.ax_max
		slime.vx = math.min (slime.vx, slime.vx_max)
	elseif love.keyboard.isDown('a') then
		slime.vx = slime.vx - dt*slime.ax_max
		slime.vx = math.max (slime.vx, -slime.vx_max)
	elseif love.keyboard.isDown('m') then
		slime.x = slime.x + grid_size
		return
	elseif not (slime.vx == 0) then
		local sign = slime.vx > 0 and 1 or -1
		slime.vx = sign * math.max (0, math.abs(slime.vx) - dt*slime.ax_max)
	end

	if slime.on_wall and not (slime.on_ceiling or slime.on_floor) then
		slime.vy = slime.wall_speed
	elseif not slime.on_corner then
		slime.vy = slime.vy + dt*slime.g
	end


--	check_corners (dt)
	if false and slime.on_corner then
--		bounce_corner (dt)
	else
		bounce_floor (dt)
		bounce_ceiling (dt)
		bounce_wall (dt)
	end
	
	slime.x = slime.x + dt*slime.vx
	slime.y = slime.y + dt*slime.vy
end

function slime.draw()
	if slime.on_corner then
		love.graphics.setColor(0.5,0,0)
	
	elseif slime.on_ceiling then
		love.graphics.setColor(0,0,0.7)
	elseif slime.on_wall then
		love.graphics.setColor(0,0.5,0)
	else
		love.graphics.setColor(0,0,0)
	end
	love.graphics.rcircle('fill', slime.x,slime.y, slime.r)
	love.graphics.setColor(1,1,1)
	love.graphics.rcircle('line', slime.x,slime.y, slime.r)
	
--	local ii = 1
--	for i, v in pairs (slime) do
--		if type (v) ~= "table" and type (v) ~= "function" then
--			if type (v) == "boolean" and v then
--				love.graphics.setColor(1,1,1)
--			else
--				love.graphics.setColor(0,1,0)
--			end
--			love.graphics.print(i..': '..tostring(v), 1400,ii*20)
--			ii=ii+1
--		end
--	end
end

function slime.keypressed(key, scancode, isrepeat)
	if false then
		
	elseif key == "w" or key == "space" then
		if slime.on_floor or slime.on_wall or slime.on_corner then
			if slime.on_wall then
				slime.vy = -1.4*(slime.jump_vy)
			else
				slime.vy = -(slime.jump_vy)
			end
			
			slime.on_floor = false
			slime.on_wall = false
			slime.on_corner = false
		end
	elseif key == "s" then
	
		if slime.on_ceiling then
--			slime.vy = slime.vy
			slime.on_ceiling = false
		elseif slime.on_wall and (not slime.ignore_wall) then
			slime.ignore_wall = true
		end
	end
end

function slime.mousereleased( x, y, button, istouch, presses )
	slime.x = x
	slime.y = y
	slime.vy = 0
	
	slime.on_ceiling = false
	slime.on_floor = false
	slime.on_wall = false
end



return slime