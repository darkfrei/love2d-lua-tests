--[[
Copyright 2023 darkfrei

The MIT License
https://opensource.org/license/mit/

Permission is hereby granted, free of charge, to any person obtaining 
a copy of this software and associated documentation files (the “Software”), 
to deal in the Software without restriction, including without limitation 
the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom 
the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included 
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH 
THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]


Width,Height = love.graphics.getDimensions()
love.window.setTitle ('Boids - Flocking Simulation')
love.graphics.setLineWidth (3)


-- Define boids class
Boids = {}

Toroidal = {}

function Toroidal.position (x,y , width,height)
	x = (x + width) % width
	y = (y + height) % height
	return x, y
end

function Toroidal.positionDifference(x1, y1, x2, y2, width, height)
	local dx = x2 - x1
	local dy = y2 - y1
	dx = (dx + width / 2) % width - width / 2
	dy = (dy + height / 2) % height - height / 2

	return dx, dy
end


function Toroidal.sqdistance (x1,y1, x2,y2, width,height)
	local dx = math.abs(x1 - x2)
	local dy = math.abs(y1 - y2)

	dx = math.min(dx, width - dx)
	dy = math.min(dy, height - dy)
	return dx*dx + dy*dy
end

function Toroidal.distance (x1,y1, x2,y2, w,h)
	return math.sqrt(Toroidal.sqdistance (x1,y1, x2,y2, w,h))
end


function Boids.newBoid(x, y)
	local boid = {}
	boid.x = x
	boid.y = y
	boid.speed = 200
	local angle = math.random() * 2 * math.pi
	boid.vx = boid.speed * math.cos (angle)
	boid.vy = boid.speed * math.sin (angle)
	boid.angle = angle

	boid.radius = 6
	return boid
end


function Boids:updateAcceleration(boid)
	local separationRadius = 80
	local separation = 20
	local alignmentRadius = 50
	local alignment = 1
	local cohesionRadius = 50
	local cohesion = 1
	local friction = 1/8

	local sepX = 0
	local sepY = 0
	local alignX = 0
	local alignY = 0
	local cohesionX = 0
	local cohesionY = 0
	local total = 0

	for _, other in ipairs(self.boids) do
		if not (boid == other) then
			local diffX, diffY = Toroidal.positionDifference (other.x,other.y, boid.x,boid.y, Width,Height)

			local distance = math.sqrt(diffX*diffX + diffY*diffY)
			local reaction = false
			if distance > 0 then
				if distance < separationRadius then
					sepX = sepX + diffX / distance
					sepY = sepY + diffY / distance
					reaction = true
				end
				if distance < alignmentRadius then
					alignX = alignX + other.vx
					alignY = alignY + other.vy
					reaction = true
				end
				if distance < cohesionRadius then
					cohesionX = cohesionX + diffX
					cohesionY = cohesionY + diffY
					reaction = true
				end
				if reaction then
					total = total + 1
				end
			end

			
		end
	end

	if total > 0 then
		sepX = sepX / total
		sepY = sepY / total

		alignX = alignX / total
		alignY = alignY / total

		cohesionX = boid.x + cohesionX / total
		cohesionY = boid.y + cohesionY / total


		-- Apply the rules
		sepX = sepX * separation
		sepY = sepY * separation

		alignX = alignX * alignment
		alignY = alignY * alignment

		cohesionX = (cohesionX - boid.x) * cohesion
		cohesionY = (cohesionY - boid.y) * cohesion

		local frictionX = boid.vx * friction
		local frictionY = boid.vy * friction

		boid.ax = sepX + alignX + cohesionX - frictionX
		boid.ay = sepY + alignY + cohesionY - frictionY

	else
		boid.ax = boid.vx * friction
		boid.ay = boid.vy * friction
	end


end

function Boids:updateVelocity()
	local vx, vy = 0, 0
	for _, boid in ipairs(Boids.boids) do
		vx = vx + boid.vx
		vy = vy + boid.vy
	end
	vx = vx / #Boids.boids
	vy = vy / #Boids.boids
	for _, boid in ipairs(Boids.boids) do
		boid.vx = boid.vx - vx
		boid.vy = boid.vy - vy
	end
end

function Boids:updatePosition(boid, dt)
	-- Update velocity
	boid.vx = boid.vx + dt * boid.ax
	boid.vy = boid.vy + dt * boid.ay

	-- limit speed
	local speed = math.sqrt(boid.vx^2 + boid.vy^2)
	if speed > boid.speed then
		local factor = boid.speed / speed
		boid.vx = boid.vx * factor
		boid.vy = boid.vy * factor
	end
	if speed > 0 then
		boid.angle = math.atan2 (boid.vy, boid.vx)
	end
	

	-- Update position
	boid.x, boid.y = Toroidal.position(boid.x + boid.vx*dt, boid.y + boid.vy*dt, Width, Height)
	
end

function love.load()
	-- Create a set of boids
	Boids.boids = {}
	for i = 1, 50 do
		local boid = Boids.newBoid(
			math.random(0, love.graphics.getWidth()), 
			math.random(0, love.graphics.getHeight())
		)
		table.insert(Boids.boids, boid)
	end
end

function love.update(dt)
	for _, boid in ipairs(Boids.boids) do
		Boids:updateAcceleration(boid)
	end

--	Boids:updateVelocity()

	for _, boid in ipairs(Boids.boids) do
		Boids:updatePosition(boid, dt)
	end
	
	local boid = Boids.boids[1]
	boid.vx = 0
	boid.vy = 0
	boid.x = Width/2
	boid.y = Height/2
	
	boid.x = love.mouse.getX ()
	boid.y = love.mouse.getY ()
	
end

local function drawBoid (mode, x, y, length, width , angle) -- position, length, width and angle
	love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.rotate( angle )
	love.graphics.polygon(mode, -length/2, -width /2, -length/2, width /2, length/2, 0)
	love.graphics.pop() 
end

function love.draw()
	love.graphics.clear()

	-- Draw boids
	for _, boid in ipairs(Boids.boids) do
--		love.graphics.circle("fill", boid.x, boid.y, boid.radius)
--		love.graphics.line (boid.x, boid.y, boid.x-boid.vx/10, boid.y-boid.vy/10)
		drawBoid  ('line', boid.x, boid.y, boid.radius*4, boid.radius*2 , boid.angle)
		
	end
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