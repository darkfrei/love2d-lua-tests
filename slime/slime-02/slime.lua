love.graphics.rcircle = function( mode, x, y, radius )
--	love.graphics.circle( mode, x, y, radius )
--	love.graphics.rectangle( mode, x, y, width, height )
	love.graphics.rectangle( mode, x-radius, y-radius, radius*2, radius*2)
end

local slime = {}

function slime.new(x, y, grid_size, slime_size)
--	local factor = 0.1*grid_size
--	local factor = 1*grid_size
	local factor = 1*grid_size
	slime.r = grid_size*slime_size

	slime.g = (10*factor)
	slime.jump_vy = (5*factor)
	slime.vx_max=(2.25*factor)
	slime.ax_max=(128*factor)
	slime.wall_speed = (1/2)*factor
	
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
	local points = {
		{i=-1.000001,j=-1.000001}, 	{i=0,j=-1.000001},	{i=1,j=-1.000001}, 
		{i=-1.000001,j=0}, 								{i=1,j=0}, 
		{i=-1.000001,j=1}, 			{i=0,j=1},			{i=1,j=1}
		}
	
	
	for nn_corner, k in pairs (points) do
		if is_tile_wall (get_grid(slime.x+k.i*slime.r, slime.y+k.j*slime.r)) then
			n = n + 1
			n_corner = nn_corner
		end
	end
	if n == 1 then
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
	
	if love.keyboard.isDown('s') and slime.on_ceiling then
		slime.vy = slime.vy + dt*slime.g
		slime.on_ceiling = false
		slime.flying = true
	end
	

	check_corners (dt)
	if slime.on_corner then
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
	elseif slime.on_wall then
		love.graphics.setColor(0,0.5,0)
	elseif slime.on_ceiling then
		love.graphics.setColor(0,0,0.7)
	else
		love.graphics.setColor(0,0,0)
	end
	love.graphics.rcircle('fill', slime.x,slime.y, slime.r)
	love.graphics.setColor(1,1,1)
	love.graphics.rcircle('line', slime.x,slime.y, slime.r)
	love.graphics.setColor(0,1,0)
--	love.graphics.print(' '..tostring(slime.on_ceiling), slime.x,slime.y)
	love.graphics.print('floor: '..tostring(slime.on_floor), slime.x,slime.y+20)
	love.graphics.print('corner: '..tostring(slime.n_corner), slime.x,slime.y+40)
	love.graphics.print('wall: '..tostring(slime.on_wall), slime.x,slime.y+60)
	
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
	if key == "space" then
		if slime.on_floor or slime.on_wall or slime.on_corner then
			slime.vy = -(slime.jump_vy)
			
			slime.on_floor = false
			slime.on_wall = false
			slime.on_corner = false
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