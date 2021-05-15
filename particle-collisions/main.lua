-- 2021-04-22 License CC0 (Creative Commons license) (c) darkfrei

function create_particle (data, id)
	local particle = {}
	particle.id = id
	particle.radius = data and data.radius or 50
	particle.mass = particle.radius*particle.radius
	particle.color = {
		0.5+0.5*(particle.radius%10)/10, 
		0.5+0.5*(particle.radius%20)/20, 
		0.5+0.5*(particle.radius%50)/50, 
	}
	particle.x = math.random (particle.radius, width - particle.radius)
	particle.y = math.random (particle.radius, height - particle.radius)
	local vel = 100*math.random ()
	local angle = math.random () * 2 * math.pi
	particle.vx =  vel * math.cos(angle)
	particle.vy = -vel * math.sin(angle)
	particle.ax, particle.ay = 0, 0
	table.insert(particles, particle)
end

function create_grid ()
	grid = {}
	local size = grid_size
	local max_x, max_y = width-size, height-size
	for x = 0, max_x, size do
		grid[x]={}
		for y = 0, max_y, size do
			local a = 132/255
			local b = 10/255
			local c = (x/size+y/size)%2
			grid[x][y]={color = {a+b*c, a+b*c, a+b*c}, size = size, particles={}}
--			print ('x: '..x..' y:'..y)
		end
	end
end

function love.load()
	love.graphics.setLineWidth( 2 )
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then -- for video capture
		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=false, borderless=true})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	
	grid_size = 50
	
	width, height = love.graphics.getDimensions( )
	width, height = math.floor(width/grid_size)*grid_size, math.floor(height/grid_size)*grid_size
	
	
	particles = {}
	create_grid ()
	for i = 1, 30 do
		create_particle ({radius = math.random (10, 100)}, i)
	end
	collidings = {}
end

function update_speed (particle, dt)
	local ddx, ddy = particle.ax*dt, particle.ay*dt
	particle.vx=particle.vx+ddx
	particle.vy=particle.vy+ddy
end

function update_position (particle, dt)
	local dx, dy = particle.vx*dt, particle.vy*dt
	particle.x=particle.x+dx
	particle.y=particle.y+dy
	
	if particle.x < particle.radius  then -- continuous collision detection
		particle.x = particle.x - (particle.radius-particle.x)/dx
		particle.vx = - particle.vx
	elseif particle.x > (width - particle.radius) then
		particle.x = particle.x + (width - particle.radius-particle.x)/dx
		particle.vx = - particle.vx
	end
	if particle.y < particle.radius then
		particle.y = particle.y - (particle.radius-particle.y)/dy
		particle.vy = - particle.vy
		elseif particle.y > (height - particle.radius) then
		particle.y = particle.y  + (height - particle.radius-particle.y)/dy
		particle.vy = - particle.vy
	end
end

function update_particle (particle, dt)
	update_speed (particle, dt)
	update_position (particle, dt)
end
 

function get_variations (list)
	local variations = {}
	for i=1, #list-1 do
		for j=i+1, #list do
			table.insert (variations, {list[i], list[j]})
		end
	end
	return variations
end

function is_overlap (particles)
	local dx = particles[2].x - particles[1].x 
	local dy = particles[2].y - particles[1].y
	local sdistance = dx*dx+dy*dy
	local b = (particles[1].radius+particles[2].radius)^2
	if not (sdistance <= (b+0.000001)) then return false end
	
	local distance = math.sqrt(sdistance)
	local overlap = -0.5*(distance - particles[1].radius - particles[2].radius)
	local nx = dx/distance -- normalizetion
	local ny = dy/distance
	
	local minid = math.min (particles[1].id, particles[2].id)
	local maxid = math.max (particles[1].id, particles[2].id)
	collision_map[minid] = collision_map[minid] or {}
	if not collision_map[minid][maxid] then
		collision_map[minid][maxid] = {
			particles ={particles[1], particles[2]},
			overlap = overlap, nx=nx, ny=ny
			}
	end
	return particles
end

function pushback (collision)
	local particles = collision.particles
	local b1, b2 = particles[1], particles[2]
	local overlap = collision.overlap
	local nx, ny = collision.nx, collision.ny 
	b1.x = b1.x - nx*overlap
	b2.x = b2.x + nx*overlap
	b1.y = b1.y - ny*overlap
	b2.y = b2.y + ny*overlap
end

function rollback (collision)
	local particles = collision.particles
	local b1, b2 = particles[1], particles[2]
	local nx, ny = collision.nx, collision.ny -- normal
	local tx, ty = -ny, nx -- tangent
	
	local dptan1 = b1.vx*tx + b1.vy*ty
	local dptan2 = b2.vx*tx + b2.vy*ty
	
	local dpnorm1 = b1.vx*nx + b1.vy*ny
	local dpnorm2 = b2.vx*nx + b2.vy*ny
	
	local m1 = (dpnorm1*(b1.mass-b2.mass)+2*b2.mass*dpnorm2)/(b1.mass+b2.mass)
	local m2 = (dpnorm2*(b2.mass-b1.mass)+2*b1.mass*dpnorm1)/(b1.mass+b2.mass)
	
	b1.vx = tx*dptan1 + nx*m1
	b1.vy = ty*dptan1 + ny*m1
	b2.vx = tx*dptan2 + nx*m2
	b2.vy = ty*dptan2 + ny*m2
end


function update_grid (dt)
	-- erase all old grid data
	for x,ys in pairs (grid) do
		for y, g in pairs (ys) do
			g.particles = {}
		end
	end
	
	-- 
	for i, particle in pairs (particles) do
		local x1 = math.floor ((particle.x-particle.radius)/grid_size)*grid_size
		local x2 = math.floor ((particle.x+particle.radius)/grid_size)*grid_size
		local y1 = math.floor ((particle.y-particle.radius)/grid_size)*grid_size
		local y2 = math.floor ((particle.y+particle.radius)/grid_size)*grid_size
		
		for x = x1, x2, grid_size do
			for y = y1, y2, grid_size do
				if grid[x] and grid[x][y] then
					table.insert (grid[x][y].particles, particle)
				end	
			end
		end
	end
	
	collision_map = {}
	for x,ys in pairs (grid) do
		for y, g in pairs (ys) do
			if #g.particles >= 2 then
				g.near = true
				local grid_overlap = false
				local variations = get_variations (particles)
				for i, v in pairs (variations) do
					local collision = is_overlap (v) -- two particles
					if collision then
						grid_overlap = true
--						table.insert(collisions, collision)
					end
				end
				g.overlap = grid_overlap
			else
				g.near = false
				g.overlap = false
			end
		end
	end
	
--	collisions = {}
	for i, js in pairs (collision_map) do
		for j, collision in pairs (js) do
			pushback (collision) -- static resolution
			rollback (collision) -- dynamic resolution
		end
	end
end

function love.update(dt)
	if dt > 0.1 then dt = 0.1 end
	for i, particle in pairs (particles) do
		update_particle (particle, dt)
	end
	update_grid (dt)
--	solve_grid (dt)
end


function love.draw()
--	print('draw')
	for x, ys in pairs (grid) do
		for y, g in pairs (ys) do
--			if g.overlap then
--				love.graphics.setColor(.8,6,.2)
			if g.near then
--			elseif g.near then
				love.graphics.setColor(.7,.5,0)
			elseif #g.particles > 0 then
				love.graphics.setColor(0.6,0.4,0)
			else
				love.graphics.setColor(g.color)
			end
			love.graphics.rectangle('fill', x, y, g.size, g.size)
		end
	end
	for i, particle in pairs (particles) do
		love.graphics.setColor(particle.color)
		love.graphics.circle('fill', particle.x, particle.y, particle.radius)
	end
	love.graphics.setColor(1,0,0)
	for i, js in pairs (collision_map) do
		for j, collision in pairs (js) do
			local particles = collision.particles
			love.graphics.line(particles[1].x, particles[1].y, particles[2].x, particles[2].y)
		end
	end
end

function love.keypressed(key, scancode, isrepeat)
   if key == "escape" then
      love.event.quit()
   end
end