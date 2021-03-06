love.graphics.rcircle = function( mode, x, y, radius )
--	love.graphics.circle( mode, x, y, radius )
--	love.graphics.rectangle( mode, x, y, width, height )
	love.graphics.rectangle( mode, x-radius, y-radius, radius*2, radius*2)
end

local slime = {}

function slime.new(x, y, grid_size, slime_size)
--	local factor = 0.1*grid_size
--	local factor = 1*grid_size
	local factor = 3
	
	slime.grid_size = grid_size
	slime.slime_size = slime_size
--	local factor = 2*grid_size
	
	slime.r = grid_size*slime_size

--	slime.g = (50000*factor)^0.5
	slime.g = 1000*factor
--	slime.jump_vy = (7*factor)
	slime.jump_vy = 500*factor^0.5
--	slime.vx_max=(2.25*factor)
	slime.vx_max=220*factor^0.5
	slime.ax_max=(1000*grid_size)
	slime.wall_speed = (1/2)*grid_size*factor
	
	slime.x=x
	slime.y=y
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

function check_corners (dt) -- static solution only
	local n = 0
	local n_corner = 0
--	local points = {{i=-1.000001,j=-1.000001}, {i=1,j=-1.000001}, {i=1,j=1}, {i=-1.000001,j=1}}
--	local points = {{i=-1.000001,j=-1.000001}, {i=1,j=-1.000001}, {i=1,j=1}, {i=-1.000001,j=1}}
--	local points = {{i=-0.99,j=-0.99}, {i=0.99,j=-1}, {i=0.99,j=0.99}, {i=-0.99999,j=0.99}}
--	local points = {
--		{i=-1.000001,j=-1.000001}, 	{i=0,j=-1.000001},	{i=1,j=-1.000001}, 
--		{i=-1.000001,j=0}, 								{i=1,j=0}, 
--		{i=-1.000001,j=1}, 			{i=0,j=1},			{i=1,j=1}
--		}
	local points = {
		{i=-0.99,j=-0.99}, 	{i=0,j=-0.99},	{i=0.99,j=-0.99}, 
		{i=-0.99,j=0}, 						{i=0.99,j=0}, 
		{i=-0.99,j=0.99}, 	{i=0,j=0.99},	{i=0.99,j=0.99}
		}
	
	
	for nn_corner, k in pairs (points) do
		if is_tile_wall (get_grid(slime.x+k.i*slime.r, slime.y+k.j*slime.r)) then
			n = n + 1
			n_corner = nn_corner
		end
	end
	if n>0 and n<3 then
--	if n == 1 then
		slime.on_corner = true
		slime.n_corner = n_corner
	else
		slime.on_corner = false
	end
end


function bounce_floor (dt)
	-- dynamic solution
	local i2, j2 = get_grid (slime.x+dt*slime.vx, slime.y+slime.r+dt*slime.vy)
	if is_tile_wall (i2, j2) and not slime.on_ceiling then
		slime.y = (j2-0.5)*grid_size-slime.r
		slime.vy = 0
		slime.on_floor = true
	else
		slime.on_floor = false
	end
end

function bounce_ceiling (dt)
	-- static solution
	local i, j = get_grid (slime.x, slime.y)
	
	local i1, j1 = get_grid (slime.x, slime.y-slime.r-0.00001)
	
	local i2, j2 = get_grid (slime.x+dt*slime.vx, slime.y-slime.r+dt*slime.vy-0.00001)

--	if (not slime.on_ceiling) and is_tile_wall (i1, j1) then
--		slime.vy = 0
--		slime.on_ceiling = true
--	elseif (not slime.on_ceiling) and is_tile_wall (i2, j2) then
	if (not slime.on_ceiling) and is_tile_wall (i2, j2) then
		slime.y = (j-0.5)*grid_size+slime.r
		slime.vy = 0
		slime.on_ceiling = true
--	elseif slime.on_ceiling and is_tile_wall (i, j-1) then
	elseif slime.on_ceiling and is_tile_wall (i1, j1) then
		-- idle on ceiling
		slime.vy = 0
	else
		slime.on_ceiling = false
	end
end

function bounce_wall (dt)
	
	
	local sign = slime.vx > 0 and 1 or slime.vx < 0 and -1 or 0
	if sign == 0 then 
		local i4, j4 = get_grid (slime.x-slime.r-0.00001, slime.y)
		local i6, j6 = get_grid (slime.x+slime.r, slime.y)
--		local i2, j2 = get_grid (slime.x+slime.r, slime.y)
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
	-- current cell
	local i, j = get_grid (slime.x, slime.y)
	
	--- static and dynamic solutions: 
	local i2, j2 = get_grid (slime.x+sign*(slime.r+0.00001), slime.y)
	local i3, j3 = get_grid (slime.x+sign*slime.r+dt*slime.vx, slime.y+dt*slime.vy)

	if is_tile_wall (i3, j3) then
		slime.vx = 0
		slime.x = (i+sign*0.5)*grid_size-sign*slime.r
		slime.on_wall = true
	else
		slime.on_wall = false
	end

end

function XOR (a, b)
	return (a or b) and not (a==b)
end

function bounce_corner (dt)
	if slime.n_corner == 1 then
		slime.vx = -slime.vy
		slime.on_ceiling = true
	elseif slime.n_corner == 2 then
		slime.vx = slime.vy
		slime.on_ceiling = true
	elseif slime.n_corner == 3 then
		slime.vx = math.min(-slime.vy, slime.vx)
	elseif slime.n_corner == 4 then
		slime.vx = math.max(slime.vy, slime.vx)
	end
	
--	if slime.n_corner == 6 or slime.n_corner == 7 or slime.n_corner == 8 then
--		slime.vy = 0
--	else
--		slime.vx = 0
--	end
--	if false then
		
--	elseif slime.n_corner == 3 then
		
--	elseif slime.n_corner == 4 then
--		slime.vx = 0
----		slime.vx, slime.vy = slime.vx, slime.vy


--	elseif slime.n_corner == 6 or slime.n_corner == 7 then
--		slime.vx = math.max(slime.vy, slime.vx)
--		slime.on_wall = true
--	elseif slime.n_corner == 8 then
--		slime.vx = math.min(-slime.vy, slime.vx)
--		slime.on_wall = true
--	end
end


function slime.update(dt, map)
	
	if love.keyboard.isDown('d') then
		slime.vx = slime.vx + dt*slime.ax_max
		slime.vx = math.min (slime.vx, slime.vx_max)
	elseif love.keyboard.isDown('a') then
		slime.vx = slime.vx - dt*slime.ax_max
		slime.vx = math.max (slime.vx, -slime.vx_max)
	elseif not (slime.vx == 0) then
		local sign = slime.vx > 0 and 1 or -1
		slime.vx = sign * math.max (0, math.abs(slime.vx) - dt*slime.ax_max)
	end

	if slime.on_wall and not (slime.on_ceiling or slime.on_floor) then
		slime.vy = slime.wall_speed
	elseif not slime.on_corner then
		slime.vy = slime.vy + dt*slime.g
	end


	check_corners (dt)
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
	
	local ii = 1
	for i, v in pairs (slime) do
		if type (v) ~= "table" and type (v) ~= "function" then
			if type (v) == "boolean" and v then
				love.graphics.setColor(1,1,1)
			else
				love.graphics.setColor(0,1,0)
			end
			love.graphics.print(i..': '..tostring(v), 1400,ii*20)
			ii=ii+1
		end
	end
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