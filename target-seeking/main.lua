-- License CC0 (Creative Commons license) (c) darkfrei, 2021

-- seek
-- pursuit of a static target
-- see: https://youtu.be/p1Ws1ZhG36g

function new_vehicle(x, y)
	local vehicle = {
		x=x or math.random(width),
		y=y or math.random(height),
		r=16,
		-- speed
		vx = 20*math.random()-1,
		vy = 20*math.random()-1,
		-- acceleration and force
		ax = 0, ay = 0, fx = 0, fy = 0,
		mass = 10,
		max_force = 10000,
		max_speed = 400
	}
	vehicle.orientation = math.atan2(vehicle.vy, vehicle.vx)
	print (vehicle.vx, vehicle.vy, vehicle.orientation)
	return vehicle
end




function love.load()
	width, height = love.graphics.getDimensions( )

	vehicle = new_vehicle()
end

function normul (x, y, factor) -- normalization and multiplication
	local d = (x*x+y*y)^0.5
	factor= factor or 1
	return factor*x/d, factor*y/d
end

function limit (dx, dy, lim)
	local d = (dx*dx+dy*dy)^0.5
	if d > lim then
		return dx*lim/d, dy*lim/d
	end
	return dx, dy
end

function seek (vehicle, target, dt)
	-- forces:
	local fx, fy = normul (vehicle.x-target.x, vehicle.y-target.y, vehicle.max_force)
	-- steering:
	fx, fy = limit (fx-vehicle.vx, fy-vehicle.vy, vehicle.max_force)
	vehicle.fx, vehicle.fy = -fx, -fy
end



function move(vehicle, dt)
	vehicle.ax = vehicle.fx/vehicle.mass
	vehicle.ay = vehicle.fy/vehicle.mass
	
--	vehicle.vx, vehicle.vy = vehicle.vx + dt*vehicle.ax, vehicle.vy + dt*vehicle.ay
	vehicle.vx, vehicle.vy = limit(vehicle.vx + dt*vehicle.ax, vehicle.vy + dt*vehicle.ay, vehicle.max_speed)
	
	vehicle.orientation = math.atan2(vehicle.vy, vehicle.vx)
	vehicle.x = vehicle.x + dt*vehicle.vx
	vehicle.y = vehicle.y + dt*vehicle.vy
end
 
function love.update(dt)
	local x, y = love.mouse.getPosition()
	local target = {x=x,y=y}
	seek (vehicle, target, dt)
	move(vehicle, dt)
end

function drawTriangle (x, y, length, width , angle) -- position, length, width and angle
	love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.rotate( angle )
	love.graphics.polygon('fill', -length/2, -width /2, -length/2, width /2, length/2, 0)
	love.graphics.pop() 
end

function love.draw()
--	draw_triangle (vehicle.x, vehicle.y, vehicle.r, vehicle.orientation)
	drawTriangle (vehicle.x, vehicle.y, 2*vehicle.r, vehicle.r, vehicle.orientation)
	
	
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end