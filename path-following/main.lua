-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function love.load()
	love.window.setMode(1920, 1080, {resizable=true, borderless=false})

	width, height = love.graphics.getDimensions( )
	
	
	line = {width/10, height/2, 
		width/2, height*2/3, 
		width*2/3, height/3, 
		width*4/5, height/3, 
		width*5/6, height*2/3, 
		width/2, height*9/10, 

		width/10, height*2/3,
		width/10, height/2,
		}
	
	vehicle = {
		x=100, y=100,
		vx=90, vy=0,
		ax=0, ay=50,
		
		maxSpeed = 300, -- pixels/s
		maxAcceleration = 300, -- pixels/s^2
		maxAngleAcceleration = 2, -- rad/s
		r = 20,
		
		k1 = 80,
		k2 = 80,
		px1=0, py1=0,
		px2=0, py2=0,
		px3=0, py3=0,
	}
	
	canvas = love.graphics.newCanvas()
end

local function distPointToLine(px,py,x1,y1,x2,y2) -- point, start and end of the segment
	local dx,dy = x2-x1,y2-y1
	local length = math.sqrt(dx*dx+dy*dy)
	dx,dy = dx/length,dy/length
	local p = dx*(px-x1)+dy*(py-y1)
	if p < 0 then
		dx,dy = px-x1,py-y1
		return math.sqrt(dx*dx+dy*dy), x1, y1 -- distance, nearest point
	elseif p > length then
		dx,dy = px-x2,py-y2
		return math.sqrt(dx*dx+dy*dy), x2, y2 -- distance, nearest point
	end
	return math.abs(dy*(px-x1)-dx*(py-y1)), x1+dx*p, y1+dy*p -- distance, nearest point
end

function get_point_on_line (line, x, y)
	local nx, ny, min_dist -- nearest point and distance
	local sx1, sy1, sx2, sy2 -- the nearest segment of the line
	local ax,ay = line[1], line[2]
	for j = 3, #line-1, 2 do
		local bx,by = line[j], line[j+1]
		local dist, px, py = distPointToLine(x,y,ax,ay,bx,by)
		if not min_dist or dist < min_dist then
			min_dist = dist
			nx, ny = px, py
			sx1,sy1, sx2,sy2 = ax,ay, bx,by
		end
		ax,ay = bx,by
	end
	return nx, ny, sx1,sy1, sx2,sy2, min_dist
end


function seek_target (vehicle, tx, ty)
	-- desired:
	local dx, dy = tx-vehicle.x, ty-vehicle.y
	-- vehicle speed:
	local vx, vy = vehicle.vx, vehicle.vy
	-- steering:
	local ax, ay = dx-vx, dy-vy
	
	return ax, ay
end

 
function love.update(dt)
	-- the point above: 
--	local px1, py1 = vehicle.x+2*vehicle.vx, vehicle.y+2*vehicle.vy
	local nx, ny = vehicle.vx, vehicle.vy
	local lenght = (nx*nx + ny*ny)^0.5
	nx, ny = nx/lenght, ny/lenght
--	local px1, py1 = vehicle.x+vehicle.k1*vehicle.vx, vehicle.y+vehicle.k1*vehicle.vy
	local px1, py1 = vehicle.x+vehicle.k1*nx, vehicle.y+vehicle.k1*ny
	vehicle.px1, vehicle.py1 = px1, py1
	
	-- nearest point on line, segment, distance:
	local px2, py2, sx1,sy1, sx2,sy2, min_dist = get_point_on_line (line, px1, py1)
	vehicle.px2, vehicle.py2 = px2, py2
	
	local sign = vehicle.vx*(sx2-sx1) + vehicle.vy*(sy2-sy1) > 0 and 1 or -1
	vehicle.sign = sign
--	sign = 1
	
	local sdx,sdy = sx2-sx1, sy2-sy1
	local segment_lenght = (sdx*sdx + sdy*sdy)^0.5
	sdx,sdy = sdx/segment_lenght,sdy/segment_lenght
	
	
	local px3, py3 = px2 + sign*vehicle.k2*sdx, py2 + sign*vehicle.k2*sdy
	vehicle.px3, vehicle.py3 = px3, py3
	
	local ax, ay = seek_target (vehicle, px3, py3)
	
	vehicle.ax, vehicle.ay = ax, ay
	
	if vehicle.ax*vehicle.ax + vehicle.ay*vehicle.ay > vehicle.maxAcceleration*vehicle.maxAcceleration then
		local ax, ay = vehicle.ax, vehicle.ay
		local a = (ax*ax + ay*ay)^0.5
		vehicle.ax = vehicle.maxAcceleration*ax/a -- normalization
		vehicle.ay = vehicle.maxAcceleration*ay/a
	end
	vehicle.vx = vehicle.vx + dt* vehicle.ax
	vehicle.vy = vehicle.vy + dt* vehicle.ay

	if vehicle.vx*vehicle.vx + vehicle.vy*vehicle.vy > vehicle.maxSpeed*vehicle.maxSpeed then
		local vx, vy = vehicle.vx, vehicle.vy
		local a = (vx*vx + vy*vy)^0.5
		vehicle.vx = vehicle.maxSpeed*vx/a -- normalization
		vehicle.vy = vehicle.maxSpeed*vy/a
	end
	
	local x = vehicle.x + dt* vehicle.vx
	local y = vehicle.y + dt* vehicle.vy
	vehicle.x = x
	vehicle.y = y
	
	love.graphics.setCanvas(canvas)
		love.graphics.setColor(1,1,1, 0.5)
		love.graphics.points (x, y)
	love.graphics.setCanvas()
end

function norm (x, y)
	local l = (x*x+y*y)^0.5
	return x/l, y/l
end

function drawTriangle (x, y, length, width , angle) -- position, length, width and angle
	love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.rotate( angle )
	love.graphics.polygon('fill', -length/2, -width /2, -length/2, width /2, length/2, 0)
	love.graphics.pop() 
end

function draw_vehicle (vehicle)
	local x, y = vehicle.x, vehicle.y
	local vx, vy = vehicle.vx, vehicle.vy
--	local nx, ny = norm (vx, vy)
	local angle = math.atan2(vy, vx)
	drawTriangle (x, y, 2*vehicle.r, vehicle.r, angle)
	
	love.graphics.setColor(1,1,0)
	
	love.graphics.line (vehicle.x, vehicle.y, vehicle.px1, vehicle.py1)
	love.graphics.setColor(0.75,0.75,1)
	
	love.graphics.line (vehicle.px1, vehicle.py1, vehicle.px2, vehicle.py2)
	love.graphics.circle('fill', vehicle.px2, vehicle.py2, 3)
	if vehicle.sign == 1 then
		love.graphics.setColor(0,1,0)
	else
		love.graphics.setColor(1,0,0)
	end
	love.graphics.setLineWidth(3)
	love.graphics.line (vehicle.px2, vehicle.py2, vehicle.px3, vehicle.py3)
	love.graphics.circle('fill', vehicle.px3, vehicle.py3, 3)
	love.graphics.setLineWidth(1)
end

function love.draw()
	love.graphics.setColor(1,1,1)
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
	love.graphics.setLineJoin( 'none')

	love.graphics.line(line)
	draw_vehicle (vehicle)
	
	love.graphics.setColor(1,1,1)
	love.graphics.draw(canvas, 0, 0)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "space" then
		for i = 1, #line-3, 2 do
			line[i]=math.random(width-200)+100
			line[i+1]=math.random(height-200)+100
		end
		-- closing loop:
		line[#line-1] = line[1]
		line[#line] = line[2]
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