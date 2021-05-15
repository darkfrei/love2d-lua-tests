ga = require ('genetic-algorithm')
dr = require ('drone')
sua = require ('sua')

deepcopy = function (tabl)
	local t = {} for i, v in pairs (tabl) do
		if type (v) == "table" then t[i] = deepcopy (v) else t[i] = v end
	end return t
end

function create_targets ()
	local targets = {}
	for i = 1, 10000 do
		local target = {
			x=math.random(border, love.graphics.getWidth()-border), 
			y=math.random(border, love.graphics.getHeight()-border)}
		table.insert (targets, target)
	end
	return targets
end


function love.load()
	love.window.setMode(1920, 1080, {resizable=false, borderless=true})
	canvas = love.graphics.newCanvas(1920, 1080)
	love.graphics.setLineWidth( 2 )

	max_speed = 150
	max_acceleration = 25
	border = 50

	
--	layer_nodes = {6, 8, 6, 4, 2}
--	layer_nodes = {4, 6, 8, 5, 2}
--	layer_nodes = {4, 16, 8, 6, 2}
--	layer_nodes = {4, 6, 4, 2}
	layer_nodes = {4, 8, 8, 2}
	drones = {}
	targets = create_targets ()
	
	for i = 1, 20 do
		local wb = ga.new_wb(layer_nodes)
		local drone = dr.new(wb)
		drone.layer_nodes = {unpack(layer_nodes)}
		drone.target = targets[1]
		table.insert(drones, drone)
	end
	
	hall_of_fame = {}
	
	cycles = 1
	
	bestpony = {points = 0}
end

function specvec(a, b)
	local sv1 = (a.x^2+a.y^2)^0.5
	local cosf = (a.x*b.x + a.y*b.y)/((a.x^2+b.x^2)^0.5*(a.y^2+b.y^2)^0.5)
	return sv1*cosf
end

 
function love.update(dt)

	love.graphics.setCanvas(canvas)
	
	if cycles > 1 then
		dt = 0.1
	end
	for i, drone in pairs (drones) do
		for j = 1, cycles do
			local target = drone.target
			local input = {}
--			input[1] = math.abs(target.x-drone.x)/love.graphics.getWidth()
			input[1] = (target.x-drone.x)
--			input[2] = math.abs(target.y-drone.y)/love.graphics.getHeight()
			input[2] = (target.y-drone.y)
			input[3] = drone.vx / max_speed
--			input[3] = drone.vx
			input[4] = drone.vy / max_speed
--			input[4] = drone.vy
--			input[5] = drone.x / love.graphics.getWidth()
--			input[6] = drone.y / love.graphics.getHeight()
--			input[5] = drone.sv
--			input[6] = drone.sa
			
			local output = ga.update (layer_nodes, input, drone.wb)
	--		print (unpack(output))
			local ax = (output[1] -0.5)*2*max_acceleration
			local ay = (output[2] -0.5)*2*max_acceleration
			local a=(ax^2+ay^2)^0.5
			drone.a = math.floor(a*1000)/1000
			if a > max_acceleration then
				ax = ax /a
				ay = ay /a
			end
			

			drone.ax = ax
			drone.ay = ay
			
			drone.vx = drone.vx + dt*100*drone.ax
			drone.vy = drone.vy + dt*100*drone.ay
			
			local v = (drone.vx^2+drone.vy^2)^0.5 
			if  v > max_speed then
				drone.vx = drone.vx * max_speed / v
				drone.vy = drone.vy * max_speed / v
			end

			drone.x = drone.x + dt*drone.vx
			drone.y = drone.y + dt*drone.vy
			
			if drone.points > 0 then
				love.graphics.setColor(drone.color[1],drone.color[2],drone.color[3], 0.1)
				love.graphics.points(drone.x, drone.y)
			end
			
			
			local sv = specvec({x=drone.vx,y=drone.vy}, {x=target.x-drone.x,y=target.y-drone.y})
			local sa = specvec({x=drone.ax,y=drone.ay}, {x=target.x-drone.x,y=target.y-drone.y})
			sv = sv > 0 and sv or 20*sv
			sa = sa > 0 and sa or 20*sa
			
			local bonus = 0
			if sa > 0 and sv < 0 then bonus = sa*2 end
			
			drone.sv = sv
			drone.sa = sa
			
			drone.score = drone.score 
			- 0.1*dt
			+ 0.1*dt*sv
			+ 10*dt*sa
--			+ dt*bonus

			
			

			if (math.abs(target.x-drone.x) < 20) and (math.abs(target.y-drone.y) < 20) then
--				drone.vx = 0.1*drone.vx
--				drone.vy = 0.1*drone.vy
				drone.score = drone.score + 1000
				drone.points = drone.points+1
				drone.target = targets[drone.points+1] or -- reached 10k targets!
					{x=math.random(border, love.graphics.getWidth()-border), 
					y=math.random(border, love.graphics.getHeight()-border)}
			end
			
			if drone.score < 0 then 
				drone.alive = false 
			end
			
			if not dr.is_in_range(drone) then 
				drone.alive = false 
--				drone.score = drone.score - 100
				if drone.points == 0 then
					drone.score = 0
				end
			end
			
			if bestpony.points < drone.points then
				bestpony = deepcopy(drone)
				sua.savetable (bestpony, 'bestpony-' .. drone.points .. '-' .. tostring(os.clock ()))
			end
		end
	end
	
	love.graphics.setCanvas()
	
	for index = #drones, 1, -1 do
		local drone = drones[index]
		if not drone.alive then
--			print('dead 2')
			drone.score = drone.score + 10000*drone.points
			local k1 = hall_of_fame[20] and hall_of_fame[20].points or 0
			local k2 = hall_of_fame[100] and hall_of_fame[100].score or 0
--			print('k1: '..k1 .. ' drone.score: ' .. drone.score)
			if (drone.points > k1) or (drone.score > k2) and (drone.points > 0) then
--			if (drone.points > k1) then
				if #hall_of_fame >=100 then
					table.remove(hall_of_fame, 100)
				end
				table.insert (hall_of_fame,
					{points=drone.points, score=math.floor(drone.score), 
					layer_nodes=drone.layer_nodes, wb=drone.wb, gen=drone.gen, color=drone.color})
				
			end
			dr.remove (drones, index)
			
			
			
--			local wb = ga.new_wb(layer_nodes)
			local case = math.random(5)
			if (case == 2) and hall_of_fame[1] then
				local wb = hall_of_fame[1].wb
				local rate = math.random ()
				wb = ga.mutate_wb (wb, rate)
				local drone = dr.new(wb, hall_of_fame[1].gen+1)
				drone.layer_nodes = {unpack(layer_nodes)}
--				drone.target = targets[1]
				drone.target = drone.target or targets[1]
				drone.color = {1,1,1, 0.5+0.5*rate}
				table.insert(drones, drone)
			
			elseif (case == 1) and #hall_of_fame >= 2 then
				dr.sort (hall_of_fame)
				local n = math.min (10, #hall_of_fame)
--				local m = math.min (20, #hall_of_fame)
				local m = #hall_of_fame
				local wb = ga.cross (hall_of_fame[n].wb, hall_of_fame[m].wb)
				local gen = math.max(hall_of_fame[n].gen, hall_of_fame[n].gen)
				if math.random (2) == 1 then
					wb = ga.mutate_wb (wb, 1)
				end
				local drone = dr.new(wb, gen)
				drone.layer_nodes = {unpack(layer_nodes)}
--				drone.target = targets[1]
				drone.target = drone.target or targets[1]
--				drone.color = {1,1,0}
				table.insert(drones, drone)
			 
			elseif (case == 3) and hall_of_fame[2] then
				local hero = hall_of_fame[math.min (2, #hall_of_fame)]
				local wb = hero.wb
				wb = ga.mutate_wb (wb, 1)
				local drone = dr.new(wb, hero.gen+1)
				drone.layer_nodes = {unpack(layer_nodes)}
				drone.target = targets[1]
				table.insert(drones, drone)
			elseif (case == 4) and (#hall_of_fame > 0) then
				local wb = ga.mutate_wb (drone.wb)
				local drone = dr.new(wb, drone.gen+1)
				drone.layer_nodes = {unpack(layer_nodes)}
				drone.target = targets[1]
				table.insert(drones, drone)
			else
				local wb = ga.new_wb(layer_nodes)
				local drone = dr.new(wb)
				drone.layer_nodes = {unpack(layer_nodes)}
				drone.target = targets[1]
				table.insert(drones, drone)
			end
		end
	end
	
end


function love.draw()
	love.graphics.setColor(1, 1, 1, 0.5)
	love.graphics.draw(canvas, 0, 0)
	
	local leader = {points = 0}
	for i, drone in pairs (drones) do
		if leader.points < drone.points then
			leader = drone
		end
--		local drone = drones[1]
		love.graphics.setColor(drone.color)
		love.graphics.circle('line', drone.x, drone.y, 10)
--		love.graphics.line(drone.x, drone.y, drone.x+20*math.cos(math.pi/2), drone.y+20*math.sin(math.pi/2))
--		love.graphics.line(drone.x, drone.y, drone.x+0.1*drone.vx, drone.y+0.1*drone.vy)
		love.graphics.line(drone.x, drone.y, drone.x+5*drone.ax, drone.y+5*drone.ay)
--		love.graphics.print('score:'..drone.x..' '..drone.y, drone.x, drone.y)
--		love.graphics.print('score:'..drone.score, drone.x, drone.y)
		love.graphics.print('points:'..drone.points, drone.x, drone.y)
--		love.graphics.print('a:'..drone.a, drone.x, drone.y)
--		love.graphics.print('ax:'..drone.ax .. ' ' ..'ay:'..drone.ay, drone.x, drone.y+20)
		
		local target = drone.target
		love.graphics.circle('fill', target.x, target.y, 5)
		love.graphics.line(target.x, target.y, drone.x, drone.y)
		
		
	end
	if leader.x then
		love.graphics.setColor(0,1,1)
		love.graphics.circle('fill', leader.x, leader.y, 8)
	end
	love.graphics.setColor(1,1,1)
	love.graphics.print('hall_of_fame: '.. #hall_of_fame, 20, 0)
--	for i, hero in pairs (hall_of_fame) do
	for i = 1, math.min(20, #hall_of_fame) do
		local hero = hall_of_fame[i]
		love.graphics.setColor(hero.color)
		love.graphics.print('score: '..hero.score..
			' points: '..hero.points..
			' gen: '..hero.gen, 20, 12+20*i)
	end
	

end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
	if key == "space" then
		if cycles == 1 then
			cycles = 100
		else
			cycles = 1
		end
	end
end