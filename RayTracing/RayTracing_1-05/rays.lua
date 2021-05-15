-- rays; RayTracing 1-04
-- darkfrei 2020-12-12
-- may6be problems with objects

local rays = {}
local raysMT = {__index = rays}

function rays:new(data)
	local self = {}
	self.update = rays.update
	self.get_points = rays.get_points
	self.best_of_points = rays.best_of_points
	self.draw = rays.draw
	
	self.name = data.name
	self.position = {x=300, y=300}
	self.target = nil
	self.base_angle = data.base_angle or 0
	self.angle = 0
	self.max_lenght = 500
	self.length = self.max_lenght
	self.point = false
	self.color = data and data.color or {1, 1, 1}
	self.dark_color = {0.2*self.color[1], 0.2*self.color[2], 0.2*self.color[3]}
	return self
end


function get_crossing (L1, L2) -- crossing function; returns point or nil
--	print (L1.x1)
	if false or -- for disabling next checking conditions
		math.max(L1.x1, L1.x2) > math.min(L2.x1, L2.x2) and -- no shadow x L1 after L2
		math.max(L1.y1, L1.y2) > math.min(L2.y1, L2.y2) and -- no shadow y L1 after L2
		math.max(L2.x1, L2.x2) > math.min(L1.x1, L1.x2) and -- no shadow x L2 after L1
		math.max(L2.y1, L2.y2) > math.min(L1.y1, L1.y2) 	-- no shadow y L2 after L1
		then
			
		local dx1 = L1.x2 - L1.x1 -- 
		local dy1 = L1.y2 - L1.y1
		
		local dx2 = L2.x2 - L2.x1
		local dy2 = L2.y2 - L2.y1
		
		local d = dy2*dx1-dx2*dy1
		if d == 0 then 
			print ('dy2*dx1: '..dy2*dx1..' dx2*dy1: '..dx2*dy1)
			return 
		end
		
		local dy3 = L1.y1 - L2.y1
		local dx3 = L1.x1 - L2.x1
--		local u1 = math.floor(((dx2*dy3 - dy2*dx3)/d)*1000+0.5)/1000
--		local u2 = math.floor(((dx1*dy3 - dy2*dx2)/d)*1000+0.5)/1000
		local u1 = (dx2*dy3 - dy2*dx3)/d
		local u2 = (dx1*dy3 - dy2*dx2)/d
		local x = L1.x1+(u1*dx1)
		local y = L1.y1+(u1*dy1)
		local ds = 0.0001 -- small tolerance for stupid float
		if -- if x and y in the projection of both lines
			false or 
			x-ds <= math.max(L2.x1, L2.x2) and
			x+ds >= math.min(L2.x1, L2.x2) and
			y-ds <= math.max(L2.y1, L2.y2) and
			y+ds >= math.min(L2.y1, L2.y2) and
			
			x-ds <= math.max(L1.x1, L1.x2) and
			x+ds >= math.min(L1.x1, L1.x2) and
			y-ds <= math.max(L1.y1, L1.y2) and
			y+ds >= math.min(L1.y1, L1.y2)  
		then
			return {x=x,y=y, valid=true}
		end
	end
end


function rays:get_points (line, points) -- returns the nearest point from several points or nil
	points = points or {}
	
	for i = 1, #line-2, 2 do
		local segment = {x1=line[i], y1=line[i+1], x2=line[i+2], y2=line[i+3]}
		local section = {x1=self.position.x, y1=self.position.y, x2=self.target.x, y2=self.target.y}
		local point = get_crossing (segment, section)
		if point then
			table.insert (points, point)
		end
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
	self.length = length or self.max_lenght
end
 
 
--function rays:update(dt, lines)
function rays:update(dt, lines)
	if self.angle then
		self.target = {x = self.position.x + self.max_lenght*math.cos(self.angle),
		y = self.position.y + self.max_lenght*math.sin(self.angle)}
	end
	local points = {}
	for _, line in pairs (lines) do
		self:get_points (line, points)
	end
	self:best_of_points (points)
end

 
function rays:draw (Bdraw_text)
	love.graphics.setColor(self.color)
	love.graphics.circle("fill", self.position.x, self.position.y, 4)

--	if Bdraw_text then
--		love.graphics.print("target: " .. math.floor(self.angle*1000+0.5)/1000,
--			(self.target.x), (self.target.y), (self.angle+math.pi/2)%math.pi-math.pi/2)
--	end
	
	if self.point then -- the found first collision
		love.graphics.line(self.position.x, self.position.y, self.point.x, self.point.y)
		love.graphics.circle("line", self.point.x, self.point.y, 4)
		if Bdraw_text then
			love.graphics.print("length: " .. math.floor(self.length*1000+0.5)/1000,
			(self.position.x+self.point.x)/2, 
			(self.position.y+self.point.y)/2, 
			(self.angle+math.pi/2)%math.pi-math.pi/2)
		end
		
		love.graphics.setColor(self.dark_color)
		love.graphics.line(self.point.x, self.point.y, self.target.x, self.target.y)
		love.graphics.circle("line", self.target.x, self.target.y, 4)
		
--		love.graphics.print(
--				"length: " .. math.floor(self.length*1000+0.5)/1000 .. '\n' ..
--				"x: " .. self.point.x .. '\n' ..
--				"y: " .. self.point.y, self.point.x+5, self.point.y+5)
	else
--		love.graphics.setColor(self.color)
		love.graphics.line(self.position.x, self.position.y, self.target.x, self.target.y)
		love.graphics.circle("line", self.target.x, self.target.y, 4)
	end
end

return rays