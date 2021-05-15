


rays = {}

function rays:new()
	
	self.position = {x=400, y=400}
	self.target = nil
	self.angle = 0
	self.max_lenght = 500
	self.point = false
	return self
end


function get_crossing (L1, L2) -- crossing function; returns point or nil
--	print (L1.x1)
	if true
--		math.max(L1.x1, L1.x2) > math.min(L2.x1, L2.x2) and
--		math.max(L1.y1, L1.y2) > math.min(L2.y1, L2.y2) and
--		math.max(L2.x1, L2.x2) > math.min(L1.x1, L1.x2) and
--		math.max(L2.y1, L2.y2) > math.min(L1.y1, L1.y2) 
		then
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
end


function rays:get_points (line, points) -- returns the nearest point from several points or nil
	local points = points or {}
	
--	print ('points: ' .. #points)
--	print ('line: ' .. #line)
	for i = 1, #line-2, 2 do
		local segment = {x1=line[i], y1=line[i+1], x2=line[i+2], y2=line[i+3]}
		local section = {x1=self.position.x, y1=self.position.y, x2=self.target.x, y2=self.target.y}
		local point = get_crossing (segment, section)
		if point then
--			print ('crosing!')
			table.insert (points, point)
		end
--		if self then print ('self') end
	end
	return points
end
 
 
function rays:best_of_points (points)
	local length, best_point
	for i, point in pairs (points) do
		local n_length = math.sqrt((self.position.x-point.x)^2+(self.position.y-point.y)^2)
		if not length then
			length = n_length
			best_point = point
		elseif length > n_length then
			length = n_length
			best_point = point
		end
	end
--	print ('points: ' .. #points)
--	return best_point, length
	self.point = best_point
	self.length = length
end
 
 
function rays:update(dt, lines)
	if self.angle then
		self.target = {x = ray.position.x + self.max_lenght*math.cos(self.angle),
		y = ray.position.y + self.max_lenght*math.sin(self.angle)}
	end
	local points = {}
	for _, line in pairs (lines) do
		self:get_points (line, points)
	end
	self:best_of_points (points)
end
 
function rays:draw ()

	
	-- draws the white ray with the white circle at the ray starting point
	love.graphics.setColor(1,1,1)
	love.graphics.circle("line", self.position.x, self.position.y, 4)
	love.graphics.setColor(0.1,0.2,0.1)
	love.graphics.line(self.position.x, self.position.y, self.target.x, self.target.y)
	
	love.graphics.setColor(1,1,0)
	love.graphics.circle("line", self.target.x, self.target.y, 4)
		
	-- get the nearest point:
--	local point, length = get_point (line, ray)
	if self.point then -- found the one, draw the green ray to this point
		self.length = math.floor(self.length*1000+0.5)/1000
		love.graphics.setColor(0,1,0)
		love.graphics.line(self.position.x, self.position.y, self.point.x, self.point.y)
		love.graphics.circle("line", self.point.x, self.point.y, 4)
			love.graphics.print(
				"length: " .. self.length .. '\n' ..
				"x: " .. self.point.x .. '\n' ..
				"y: " .. self.point.y, self.point.x+5, self.point.y+5)
	end
end

return rays