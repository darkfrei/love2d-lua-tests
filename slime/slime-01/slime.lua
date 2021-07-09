love.graphics.rcircle = function( mode, x, y, radius )
--	love.graphics.circle( mode, x, y, radius )
--	love.graphics.rectangle( mode, x, y, width, height )
	love.graphics.rectangle( mode, x-radius, y-radius, radius*2, radius*2)
end

local slime = {}

function slime.new(x, y, grid_size)
	local factor = 8
	slime.x=x
	slime.y=y
	slime.vx=0
	slime.vx_max=2*grid_size
	slime.wall_speed = grid_size/4
	
	slime.ax_max=500*grid_size
	slime.vy=0
	slime.r = grid_size/8
	slime.jump_vy = -((2+1/8)*factor)^0.5*grid_size
	slime.g = factor*grid_size
	
	slime.flying = true
	slime.n_jumps = 1
	slime.n_jumps_max = 2
	
	slime.on_ground = false
	slime.on_ceiling = false
	slime.on_wall = false
	slime.i, slime.j = 0,0
end

function is_tile_wall (i, j)
	return map[j] and map[j][i] and map[j][i] == 1
end

function bounce_floor (dt, map, grid_size)
	local i = math.floor((slime.x)/grid_size+0.5)
	local j = math.floor((slime.y)/grid_size+0.5)
	local j2 = math.floor((slime.y+slime.r+1)/grid_size+0.5)
	
	if (not is_tile_wall(i, j) and is_tile_wall (i, j2)) and slime.flying then
		slime.flying = false
		slime.on_ground = true
		slime.vy = 0
		slime.y = (j+0.5)*grid_size-slime.r
	elseif not is_tile_wall (i, j2) then
		slime.flying = true
		slime.on_ground = false
	end
end

function bounce_ceiling (dt, map, grid_size)
	local i = math.floor((slime.x)/grid_size+0.5)
	local j = math.floor((slime.y)/grid_size+0.5)
	local j2 = math.floor((slime.y-slime.r-1)/grid_size+0.5)
	
	if (not is_tile_wall(i, j) and is_tile_wall (i, j2)) and slime.flying then
		slime.flying = false
		slime.on_ceiling = true
		slime.vy = 0
		slime.y = (j-0.5)*grid_size+slime.r
--		if is_on_wall (dt, map, grid_size) then
--			slime.on_wall = true
--		end
	elseif not is_tile_wall (i, j2) and slime.on_ceiling then
		slime.flying = true
		slime.on_ceiling = false
		
	end
end

function is_on_wall (dt, map, grid_size)
	local i = math.floor((slime.x)/grid_size+0.5)
	local i2 = math.floor((slime.x+slime.r+1)/grid_size+0.5)
	local i3 = math.floor((slime.x-slime.r-1)/grid_size+0.5)
	local j = math.floor((slime.y)/grid_size+0.5)
	
	if (not is_tile_wall(i, j) and is_tile_wall (i2, j)) 
	or (not is_tile_wall(i, j) and is_tile_wall (i3, j)) then
		return true
	end
end

function bounce_right (dt, map, grid_size)
	local i = math.floor((slime.x)/grid_size+0.5)
	local i2 = math.floor((slime.x+slime.r+1)/grid_size+0.5)
	local j = math.floor((slime.y)/grid_size+0.5)
	
	if (not is_tile_wall(i, j) and is_tile_wall (i2, j)) and not (slime.on_wall) then
		slime.flying = false
		slime.on_wall = true
		slime.vx = 0
		slime.x = (i+0.5)*grid_size-slime.r
	elseif not is_tile_wall (i2, j) then
		slime.vx = math.min(slime.vx_max, slime.vx + dt*slime.ax_max)
		slime.on_wall = false
--		slime.flying = true
	end
end

function bounce_left (dt, map, grid_size)
	local i = math.floor((slime.x)/grid_size+0.5)
	local i2 = math.floor((slime.x-slime.r-1)/grid_size+0.5)
	local j = math.floor((slime.y)/grid_size+0.5)
	
	if (not is_tile_wall(i, j) and is_tile_wall (i2, j)) and not (slime.on_wall) then
		slime.flying = false
		slime.on_wall = true
		slime.vx = 0
		slime.x = (i-0.5)*grid_size+slime.r
	elseif not is_tile_wall (i2, j) then
		slime.vx = math.max(-slime.vx_max, -slime.vx - dt*slime.ax_max)
		slime.on_wall = false
--		slime.flying = true
	end
end


function slime.update(dt, map, grid_size)
	
	

	if slime.on_wall and not (slime.on_ceiling or slime.on_ground) then
		slime.vy = slime.wall_speed
	elseif slime.flying then
		slime.vy = slime.vy + dt*slime.g
	end
	
	slime.y = slime.y + dt*slime.vy
	
	bounce_floor (dt, map, grid_size)
	bounce_ceiling (dt, map, grid_size)
	
	
	if love.keyboard.isDown('d') then
		slime.x = slime.x + dt*slime.vx
		bounce_right (dt, map, grid_size)
	elseif love.keyboard.isDown('a') then
		slime.x = slime.x + dt*slime.vx
		bounce_left (dt, map, grid_size)
	else
		slime.vx = 0
	end
	
	if love.keyboard.isDown('s') and slime.on_ceiling then
		
		slime.y = slime.y + dt*slime.wall_speed
		slime.on_ceiling = false
		slime.flying = true
--		bounce_right (dt, map, grid_size)
--		bounce_left (dt, map, grid_size)
	end
	
	
end

function slime.draw()
	love.graphics.setColor(0,0,0)
	love.graphics.rcircle('fill', slime.x,slime.y, slime.r)
	love.graphics.setColor(1,1,1)
	love.graphics.rcircle('line', slime.x,slime.y, slime.r)
	love.graphics.setColor(0,1,0)
	love.graphics.print(slime.i..' '..slime.j..' '..tostring(slime.on_ceiling), slime.x,slime.y)
	love.graphics.print(slime.i..' '..slime.j..' '..tostring(slime.on_ground), slime.x,slime.y+20)
	love.graphics.print(slime.i..' '..slime.j..' '..tostring(slime.flying), slime.x,slime.y+40)
	love.graphics.print(slime.i..' '..slime.j..' '..tostring(slime.on_wall), slime.x,slime.y+60)
end

function slime.keypressed(key, scancode, isrepeat)
	if key == "space" then
		if not slime.flying or slime.on_wall then
			slime.vy = slime.jump_vy
			slime.flying = true
			slime.on_ceiling = false
			slime.on_ground = false
			slime.on_wall = false
		end
	end
end


return slime
