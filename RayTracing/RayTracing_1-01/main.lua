-- darkfrei, 2020-11-22

function love.load()
	-- example closed (or not closed) line:
	line = {
		50,50, 
		750, 500, 
		700, 500, 
		200, 350, 
		100, 500, 
		100, 300, 
		50, 250, 
		50,50}
	
	-- example ray (click to change the source point):
	ray = {x=400, y=300, r=400, w=0, speed = 0.5, x2=0, y2=0}
end
 

function love.update(dt)
	ray.w = ray.w + dt*ray.speed
	if false then -- disabled example ray rotation
		ray.x2 = ray.x + ray.r*math.cos(ray.w)
		ray.y2 = ray.y + ray.r*math.sin(ray.w)
	else -- ray to mouse position
		ray.x2, ray.y2 = love.mouse.getPosition()
	end
end


function get_crossing (L1, L2) -- crossing function; returns point or nil
	local dx1 = L1.x2 - L1.x1
	local dy1 = L1.y2 - L1.y1
	local dx2 = L2.x2 - L2.x1
	local dy2 = L2.y2 - L2.y1
	
	local d = dy2*dx1-dx2*dy1
	if d == 0 then return end
	local dy3 = L1.y1 - L2.y1
	local dx3 = L1.x1 - L2.x1
	local u1 = math.floor(((dx2*dy3 - dy2*dx3)/d)*1000+0.5)/1000
	local u2 = math.floor(((dx1*dy3 - dy2*dx2)/d)*1000+0.5)/1000
	local x = L1.x1+(u1*dx1)
	local y = L1.y1+(u1*dy1)
	if -- if x and y in the projection of both lines
		x <= math.max(L2.x1, L2.x2) and
		x >= math.min(L2.x1, L2.x2) and
		y <= math.max(L2.y1, L2.y2) and
		y >= math.min(L2.y1, L2.y2) and
		
		x <= math.max(L1.x1, L1.x2) and
		x >= math.min(L1.x1, L1.x2) and
		y <= math.max(L1.y1, L1.y2) and 
		y >= math.min(L1.y1, L1.y2)  
	then
		if false then -- disabled debug info
			love.graphics.setColor(0,1,0)
			love.graphics.print(
				"d: " .. d .. '\n' ..
				"L1.x1: " .. L1.x1 .. '\n' ..
				"L1.y1: " .. L1.y1 .. '\n' ..
				"u1: " .. u1 .. '\n' ..
				"u2: " .. u2 .. '\n' ..
				"x: " .. x .. '\n' ..
				"y: " .. y, x, y)
		end
		return {x=x,y=y, valid=true}
	elseif false then -- disabled debug info
		love.graphics.setColor(1,0,0)
		love.graphics.print(
			"d: " .. d .. '\n' ..
			"L1.x1: " .. L1.x1 .. '\n' ..
			"L1.y1: " .. L1.y1 .. '\n' ..
			"u1: " .. u1 .. '\n' ..
			"u2: " .. u2 .. '\n' ..
			"x: " .. x .. '\n' ..
			"y: " .. y, x, y)
		return {x=x,y=y, valid=false}
	end
end


function get_point (line, ray) -- returns the nearest point from several points or nil
	local length, best_point
	for i = 1, #line-2, 2 do
		local segment = {x1=line[i], y1=line[i+1], x2=line[i+2], y2=line[i+3]}
		local section = {x1=ray.x,	 y1=ray.y, 	   x2=ray.x2,	 y2=ray.y2}
		local point = get_crossing (segment, section)
		if point then
--			love.graphics.setColor(0,1,0)
--			love.graphics.circle("line", point.x, point.y, i+2)
			local n_length = math.sqrt((ray.x-point.x)^2+(ray.y-point.y)^2)
			if not length then
				length = n_length
				best_point = point
			elseif length > n_length then
				length = n_length
				best_point = point
			end
		end
	end
	return best_point, length
end
 
 
function love.draw()
	-- draws the example line
	love.graphics.setColor(1,1,0)
	love.graphics.line(line)
	
	-- draws the white ray with the white circle at the ray starting point
	love.graphics.setColor(1,1,1)
	love.graphics.circle("line", ray.x, ray.y, 4)
	love.graphics.line(ray.x, ray.y, ray.x2, ray.y2)
	
	-- get the nearest point:
	local point, length = get_point (line, ray)
	if point then -- found the one, draw the green ray to this point
		length = math.floor(length*1000+0.5)/1000
		love.graphics.setColor(0,1,0)
		love.graphics.line(ray.x, ray.y, point.x, point.y)
		love.graphics.circle("line", point.x, point.y, 4)
			love.graphics.print(
				"length: " .. length .. '\n' ..
				"x: " .. point.x .. '\n' ..
				"y: " .. point.y, point.x+5, point.y+5)
	end
end


function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then
		ray.x = x
		ray.y = y
	end
end