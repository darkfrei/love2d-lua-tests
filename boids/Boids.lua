-- toroidal boids
-- not tested

local function toroidalPositionDifference(x1, y1, x2, y2, width, height)
	local dx = x2 - x1
	local dy = y2 - y1
	if dx > width / 2 then
		dx = dx - width
	elseif dx < -width / 2 then
		dx = dx + width
	end
	if dy > height / 2 then
		dy = dy - height
	elseif dy < -height / 2 then
		dy = dy + height
	end
	return dx, dy
end


Boid = {
	x = 0,
	y = 0,
	vx = 0,
	vy = 0,
	ax = 0,
	ay = 0,
	radius = 5,
}

function Boid:new(x, y)
	local boid = {}
	setmetatable(boid, self)
	self.__index = self
	boid.x = x
	boid.y = y
	boid.angle = math.random() * 2 * math.pi
	boid.maxSpeed = 100
	local speed = boid.maxSpeed * math.random()
	boid.vx = speed * math.cos (boid.angle)
	boid.vy = speed * math.sin (boid.angle)
	return boid
end

function Boid:setAcceleration(ax, ay)
	self.ax = ax
	self.ay = ay
end

function Boid:applyAcceleration(ax, ay)
	self.ax = self.ax + ax
	self.ay = self.ay + ay
end

function Boid:separationRule(boids, width, height)
	local separationRadius = 25
	local separationFactor = 0.03
	local separationX, separationY = 0, 0
	local countSeparation = 0

	for _, other in ipairs(boids) do
		if other ~= self then
			local dx, dy = toroidalPositionDifference(self.x, self.y, other.x, other.y, width, height)
			local distance = (dx^2 + dy^2)
			if distance < separationRadius*separationRadius then
				distance = math.sqrt (distance)
				separationX = separationX - dx / distance
				separationY = separationY - dy / distance
				countSeparation = countSeparation + 1
			end
		end
	end

	if countSeparation > 0 then
		separationX = separationFactor * separationX / countSeparation
		separationY = separationFactor * separationY / countSeparation
		self:applyAcceleration(separationX, separationY)
	end
end

function Boid:alignmentRule(boids, width, height)
	local alignmentRadius = 50
	local alignmentFactor = 0.02
	local alignmentX, alignmentY = 0, 0
	local countAlignment = 0

	for _, other in ipairs(boids) do
		if other ~= self then
			local dx, dy = toroidalPositionDifference(self.x, self.y, other.x, other.y, width, height)
			local distanceSquared = dx^2 + dy^2

			if distanceSquared < alignmentRadius^2 then
				alignmentX = alignmentX + other.vx
				alignmentY = alignmentY + other.vy
				countAlignment = countAlignment + 1
			end
		end
	end

	if countAlignment > 0 then
		alignmentX = alignmentFactor * alignmentX / countAlignment
		alignmentY = alignmentFactor * alignmentY / countAlignment
		self:applyAcceleration(alignmentX, alignmentY)
	end
end


function Boid:cohesionRule(boids, width, height)
	local cohesionRadius = 50
	local cohesionFactor = 0.01
	local cohesionX, cohesionY = 0, 0
	local countCohesion = 0

	for _, other in ipairs(boids) do
		if other ~= self then
			local dx, dy = toroidalPositionDifference(self.x, self.y, other.x, other.y, width, height)
			local distanceSquared = dx^2 + dy^2

			if distanceSquared < cohesionRadius^2 then
				cohesionX = cohesionX + other.x
				cohesionY = cohesionY + other.y
				countCohesion = countCohesion + 1
			end
		end
	end

	if countCohesion > 0 then
		cohesionX = cohesionX / countCohesion
		cohesionY = cohesionY / countCohesion

		-- Adjust the factor if needed
		cohesionX = cohesionFactor * (cohesionX - self.x)
		cohesionY = cohesionFactor * (cohesionY - self.y)

		self:applyAcceleration(cohesionX, cohesionY)
	end
end

function Boid:steeringBehavior(targetX, targetY, width, height)
		-- Apply steering factors for seeking and arrival
	local seekFactor = 0.1
	local arrivalFactor = 0.2
	local arrivalRadius = 50
	local slowingRadius = 50
	
	
	local targetVectorX, targetVectorY = toroidalPositionDifference(self.x, self.y, targetX, targetY, width, height)

	-- Normalize the target vector
	local distanceToTarget = math.sqrt(targetVectorX^2 + targetVectorY^2)
	if distanceToTarget > 0 then
		targetVectorX = targetVectorX / distanceToTarget
		targetVectorY = targetVectorY / distanceToTarget
	end



	if distanceToTarget < arrivalRadius then
		local slowingFactor = math.sqrt(distanceToTarget) / slowingRadius
		targetVectorX = (targetVectorX * seekFactor - self.vx * arrivalFactor * slowingFactor) / (seekFactor + arrivalFactor)
		targetVectorY = (targetVectorY * seekFactor - self.vy * arrivalFactor * slowingFactor) / (seekFactor + arrivalFactor)
	else
		targetVectorX = seekFactor * targetVectorX
		targetVectorY = seekFactor * targetVectorY
	end

	-- Apply the steering behavior as acceleration
	self:applyAcceleration(targetVectorX, targetVectorY)
end


function Boid:seekingBehavior(targetX, targetY, width, height)
	-- makes smooth way to target
	local seekFactor = 0.1
	local targetVectorX, targetVectorY = toroidalPositionDifference(self.x, self.y, targetX, targetY, width, height)
	-- Normalize the target vector
	local distanceToTarget = math.sqrt(targetVectorX^2 + targetVectorY^2)
	if distanceToTarget > 0 then
		targetVectorX = seekFactor * targetVectorX / distanceToTarget
		targetVectorY = seekFactor * targetVectorY / distanceToTarget
	end
	self:applyAcceleration(targetVectorX, targetVectorY)
end



function Boid:arrivingBehavior(targetX, targetY, width, height)
	local arrivalRadius = 20
	local targetVectorX, targetVectorY = toroidalPositionDifference(self.x, self.y, targetX, targetY, width, height)
	local distanceToTargetSquared = targetVectorX^2 + targetVectorY^2

	if distanceToTargetSquared < arrivalRadius^2 then
		-- Inside arrival radius, slow down based on distance
		local slowingFactor = math.sqrt(distanceToTargetSquared) / arrivalRadius
		targetVectorX = targetVectorX * slowingFactor
		targetVectorY = targetVectorY * slowingFactor

	end
	self:applyAcceleration(targetVectorX, targetVectorY)
end




function Boid:move(dt)
	-- more precise than Euler method and still cheap
	local dvx, dvy = self.ax * dt, self.ay * dt
	self.x = self.x + (self.vx + dvx/2) * dt
	self.y = self.y + (self.vy + dvy/2) * dt
	self.vx = self.vx + dvx
	self.vy = self.vy + dvy
end

function Boid:wrapAroundScreen(width, height)
	self.x = self.x % width
	self.y = self.y % height
end


function Boid:applyRules(dt, boids)
	self:separationRule(boids)
	self:alignmentRule(boids)
	self:cohesionRule(boids)
	self:arrivingBehavior() -- just update accelerations ax, ay
end

function Boid:update(dt, boids)
	self:setAcceleration(0, 0)
	self:applyRules (boids) -- just update accelerations ax, ay
	self:move(dt) -- update vx, vy, x, y
	self:wrapAroundScreen()
end

function Boid:draw()
	love.graphics.circle("fill", self.x, self.y, self.radius)
end

return Boid

