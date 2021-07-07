local slime = {}

function slime.new(x, y, grid_size)
	local factor = 8
	slime.x=x
	slime.y=y
	slime.vx=0
	slime.vx_max=2*grid_size
	slime.ax_max=500*grid_size
	slime.vy=0
	slime.r = grid_size/8
	slime.jump_vy = -((2+1/8)*factor)^0.5*grid_size
	slime.g = factor*grid_size
	slime.on_ground = false
	slime.on_wall = false
	slime.i, slime.j = 0,0
end


function slime.update(dt, map, grid_size)
	
	
--	if love.keyboard.isDown('d', 'a') then
--		local i
--		local j = math.floor((slime.y)/grid_size+0.5)
--		if love.keyboard.isDown('d') then
--			i = math.floor((slime.x+slime.r)/grid_size+0.5)
--		else
--			i = math.floor((slime.x-slime.r)/grid_size-0.5)
--		end
--		slime.i = i
--		if map[j][i] == 1 and not (slime.on_wall) then
----			slime.on_wall = true
--		end
		
--	end

	if love.keyboard.isDown('d') then
		slime.ax = slime.ax_max
		slime.vx = slime.vx + dt*slime.ax
		if slime.vx > slime.vx_max then
			slime.vx = slime.vx_max
		end
		slime.x = slime.x + dt*slime.vx
	end
	if love.keyboard.isDown('a') then
		slime.ax = slime.ax_max
		slime.vx = slime.vx + dt*slime.ax
		if slime.vx > slime.vx_max then
			slime.vx = slime.vx_max
		end
		slime.x = slime.x - dt*slime.vx
	end
	
	local i = math.floor((slime.x)/grid_size+0.5)
	local j = math.floor((slime.y+slime.r)/grid_size+0.5)
	slime.j = j
	if map[j][i] == 1 and not (slime.on_ground) and slime.vy > 0 then
		slime.on_ground = true
		slime.vy = 0
	elseif map[j][i] == 0 then
		slime.on_ground = false
	end
	
	local ay = 0
	if not slime.on_ground then
		ay = slime.g
		slime.vy = slime.vy + dt*ay
		
	end
	
	slime.y = slime.y + dt*slime.vy
	
end

function slime.draw()
	love.graphics.setColor(0,0,0)
	love.graphics.circle('fill', slime.x,slime.y, slime.r)
	love.graphics.setColor(1,1,1)
	love.graphics.circle('line', slime.x,slime.y, slime.r)
	love.graphics.setColor(0,1,0)
	love.graphics.print(slime.i..' '..slime.j..' '..tostring(slime.on_ground), slime.x,slime.y)
end

function slime.keypressed(key, scancode, isrepeat)
	if key == "space" then
--		slime.vy = slime.vy + slime.jump_vy
		slime.vy = slime.jump_vy
	end
end


return slime