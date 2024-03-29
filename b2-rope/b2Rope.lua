
-- [b2_rope.cpp](https://github.com/erincatto/box2d/blob/main/src/rope/b2_rope.cpp)
-- [classb2_rope](https://box2d.org/documentation/classb2_rope.html)
-----------------------------------

-- todo:

-- add the line as {x1, y1, x2, y2 .. } to draw with love2D
--[[
	lineCurrent = {}
	linePrevious = {}
	lineInitial = {}
	lineVelocity = {} -- why not
	lineInvMass = {} -- why not
	
]]


--[[

-- node
--x and y: These represent the current position of the node in 2D space. 
--They store the x-coordinate and y-coordinate, respectively.

--pX and pY: These represent the previous position of the node. 
--They store the x-coordinate and y-coordinate of the node's position in the previous time step.

--p0x and p0y: These represent the initial position of the node. 
--They store the x-coordinate and y-coordinate of the node's position at the start of the simulation.

--vX and vY: These represent the velocity of the node 
--in the x-direction and y-direction, respectively. 
--They store the current velocity components of the node.

--invMass: This parameter represents the inverse mass of the node. 
--In physics simulations, using the inverse mass instead of mass simplifies calculations. 
--A mass of zero represents an immovable or fixed node, 
--while a positive mass represents a movable node. 
--The inverse mass is calculated as the reciprocal of the mass, 
--allowing for efficient multiplication instead of division in calculations.



local node = {
	x = 0,
	y = 0,
	pX = 0,
	pY = 0,
	p0x = 0,
	p0y = 0,
	vX = 0,
	vY = 0,
	invMass = 0,
}

-- stretch
--i1 and i2: These represent the indices of the two nodes connected by the stretch constraint. 
--They indicate the indices of the nodes in the system or simulation.

--invMass1 and invMass2: These represent the inverse masses of the two nodes involved 
--in the stretch constraint. Similar to the explanation in the previous question, 
--the inverse mass simplifies calculations by using the reciprocal of the mass.

--L: This parameter represents the rest length or natural length of the stretch constraint. 
--It defines the desired distance between the two connected nodes 
--when there is no stretching or compression.

--lambda: This represents the Lagrange multiplier or the stretching factor. 
--It is used in position-based dynamics (PBD) or other constraint solvers 
--to enforce the constraint by applying positional corrections to the connected nodes.

--spring: This parameter represents the stiffness or spring constant of the stretch constraint. 
--It determines how resistant the constraint is to stretching or compression. 
--A higher value indicates a stiffer constraint, while a lower value allows more flexibility.

--damper: This parameter represents the damping coefficient of the stretch constraint. 
--It controls the rate at which the constraint dissipates energy or reduces oscillations. 
--A higher value results in stronger damping, while a lower value allows for more oscillations.


local stretch = {
  i1 = 0,
  i2 = 0,
  invMass1 = 0,
  invMass2 = 0,
  L = 0,
  lambda = 0,
  spring = 0,
  damper = 0
}


i1, i2, and i3: These represent the indices of the three nodes involved in the bend constraint. 
They indicate the indices of the nodes in the system or simulation.

invMass1, invMass2, and invMass3: These represent the inverse masses of the three nodes involved 
in the bend constraint. Similar to the explanation in the previous question, 
the inverse mass simplifies calculations by using the reciprocal of the mass.

invEffectiveMass: This parameter represents the inverse effective mass of the bend constraint. 
It combines the inverse masses of the three nodes to determine the overall mass of the constraint.

lambda: This represents the Lagrange multiplier or the bending factor. It is used 
in position-based dynamics (PBD) or other constraint solvers to enforce the constraint 
by applying positional corrections to the connected nodes.

L1 and L2: These parameters represent the rest lengths or natural lengths 
of the two segments forming the bend constraint. They define the desired lengths 
of the segments when there is no bending.

alpha1 and alpha2: These parameters represent the barycentric coordinates of the bend constraint. 
They determine the relative positions of the nodes along the segments forming the bend.

spring: This parameter represents the stiffness or spring constant of the bend constraint. 
It determines how resistant the constraint is to bending. A higher value indicates a stiffer constraint, 
while a lower value allows more flexibility.

damper: This parameter represents the damping coefficient of the bend constraint. 
It controls the rate at which the constraint dissipates energy or reduces oscillations during bending. 
A higher value results in stronger damping, while a lower value allows for more oscillations.


local bend = {
  i1 = 0,
  i2 = 0,
  i3 = 0,
  invMass1 = 0,
  invMass2 = 0,
  invMass3 = 0,
  invEffectiveMass = 0,
  lambda = 0,
  L1 = 0,
  L2 = 0,
  alpha1 = 0,
  alpha2 = 0,
  spring = 0,
  damper = 0
}

--]]
-----------------------------------
-- Stretching
local b2_pbdStretchingModel =   'pbd'
local b2_xpbdStretchingModel = 'xpbd'

-- Bending
local b2_springAngleBendingModel = 'springAngle'

local b2_pbdAngleBendingModel = 'pbdAngle'
local b2_xpbdAngleBendingModel = 'xpbdAngle'

local b2_pbdHeightBendingModel = 'pbdHeight'
local b2_pbdDistanceBendingModel = 'pbdDistance'
local b2_pbdTriangleBendingModel = 'pbdTriangle'



local b2Rope = {}
b2Rope.__index = b2Rope


b2Rope.stretchingSolvers = {
	pbd = 	b2Rope.solveStretch_PBD,
	xpbd = 	b2Rope.solveStretch_XPBD,
}

b2Rope.bendingSolvers = {
	springAngle = 	b2Rope.solveBend_spring_angle,

	pbdAngle = 			b2Rope.solveBend_PBD_angle,
	xpbdAngle = 		b2Rope.solveBend_XPBD_angle,

	pbdHeight = 		b2Rope.solveBend_PBD_height,
	pbdDistance = 	b2Rope.solveBend_PBD_distance,
	pbdTriangle = 	b2Rope.solveBend_PBD_triangle,
}

b2Rope.stretchingModels = 
{
	"pbd",
	"xpbd",
}

b2Rope.bendingModels = 
{
	"springAngle",
	
	"pbdAngle",
	"xpbdAngle",
	

	"pbdHeight",
	"pbdDistance",
	"pbdTriangle",
}


local function createNodes (vertices, masses, x0, y0)
	local nodes = {}
	
	for i = 1, #vertices-1, 2 do
		local x = vertices[i]
		local y = vertices[i+1]
		local px = x0 + x
		local py = y0 + y
--		print (i, px, py)
		local node = {
--			x = px, -- current position of the node
--			y = py,
			x = x, -- current position of the node
			y = y,
			pX = px, -- previous node position
			pY = py,
			p0x = px, -- initial position of the node
			p0y = py,
			vX = 0, -- velocity of the node
			vY = 0,
			invMass = 0
		}
		local iMass = (i+1)/2
		if masses[iMass] > 0 then
			node.invMass = 1 / masses[iMass]
		end
		
		vertices[i] = px
		vertices[i+1] = py
		table.insert (nodes, node)
	end
	return nodes
end


local function createStretchConstraints (vertices)
	local stretchConstraints = {}
	local px1 = vertices[1]
	local py1 = vertices[2]
	for i = 3, #vertices-1, 2 do
		local px2 = vertices[i]
		local py2 = vertices[i+1]
		local dx = px2-px1
		local dy = py2-py1

		local stretch = {
			length = math.sqrt(dx*dx + dy*dy),
			lambda = 0,
			damper = 0,
			spring = 1
		}
		table.insert (stretchConstraints, stretch)
		px1 = px2
		py1 = py2
	end
	return stretchConstraints
end

local function createBendConstraints (vertices, masses)
	local bendConstraints = {}
	local px1 = vertices[1]
	local py1 = vertices[2]
	local px2 = vertices[3]
	local py2 = vertices[4]

	local m1 = masses[1]
	local m2 = masses[2]
	for i = 5, #vertices-1, 2 do
		local px3 = vertices[i]
		local py3 = vertices[i+1]
		local m3 = masses[(i+1)/2]

-- differences in x and y coordinates between the vertices of the triangle
		local e1X = px2 - px1
		local e1Y = py2 - py1
		local e2X = px3 - py2
		local e2Y = py3 - py2

-- squared lengths of the edges of the triangle.
		local L1sqr = e1X * e1X + e1Y * e1Y
		local L2sqr = e2X * e2X + e2Y * e2Y

		local bend = {
			invEffectiveMass = 0, -- inverse effective mass of the bend
			lambda = 0, -- Lagrange multiplier or the bending factor
			alpha1 = 0, -- barycentric coordinates of the bend constraint
			alpha2 = 0,
		}

		if L1sqr * L2sqr ~= 0 then
			local invL1sqr = 1 / L1sqr
			local invL2sqr = 1 / L2sqr
			bend.invEffectiveMass = invL1sqr/m1 + (invL1sqr + invL2sqr)/m2 + invL2sqr/m3
			bend.alpha1 = invL1sqr / bend.invEffectiveMass
			bend.alpha2 = invL2sqr / bend.invEffectiveMass
		end

		table.insert (bendConstraints, bend)
	end

	return bendConstraints
end


function b2Rope:create(def)

	local x0 = def.position.x
	local y0 = def.position.y

	local vertices = def.vertices
	local count = #vertices/2
	local stretchCount = count-1
	local bendCount = count-2

	assert(count >= 6)

	local masses = def.masses
	
	
	local invMasses = {}
	for i, mass in ipairs (masses) do
		if mass == 0 then
			invMasses[i] = 0
		else
			invMasses[i] = 1/mass
		end
		print ('invMasses[i]', i, invMasses[i])
	end
	
	self.invMasses = invMasses

	self.x = x0
	self.y = y0
	
	
	self.vertices = vertices
--	self.masses = masses
--	self.count = count
--	self.stretchCount = stretchCount
--	self.bendCount = bendCount

	self.nodes = createNodes (vertices, masses, x0, y0)
	self.stretchConstraints = createStretchConstraints (vertices)
	self.bendConstraints = createBendConstraints (vertices, masses)

	self.gravityX = def.gravity.x
	self.gravityY = def.gravity.y
	self.tuning = def.tuning



	self:setTuning()

end



function b2Rope:new(def)


	local rope = setmetatable({}, b2Rope)
	rope:create (def)
	
	

	return rope
end


-----------------------------------------
-------------- create -------------------
-----------------------------------------


-----------------------------------------
-------------- tuning -------------------
-----------------------------------------

function b2Rope:setTuning()
	local tuning = self.tuning
-- Pre-compute spring and damper values based on tuning

	local stretchDamping = tuning.stretchDamping
	local bendDamping = tuning.bendDamping

	local stretchHertz = tuning.stretchHertz
	local bendHertz = tuning.bendHertz

	local stretchOmega = 2 * math.pi * stretchHertz
	local bendOmega = 2 * math.pi * bendHertz


	------------ stretch ---------------
	for i = 1, #self.vertices-3, 2 do
		local iStretch = (i+1)/2
		local stretch = self.stretchConstraints[iStretch]
		local invMass1 = self.invMasses[iStretch]
		local invMass2 = self.invMasses[iStretch+1]
		local sum = invMass1 + invMass2
		if sum ~= 0 then
			stretch.spring = stretchOmega * stretchOmega / sum
			stretch.damper = 2 * stretchDamping * stretchOmega / sum
		end
		print ((i+1)/2, 'stretch.spring', stretch.spring)
	end
	
	------------ bend --------------

	for i = 1, #self.vertices-5, 2 do
		local iBend = (i+1)/2
		local bend = self.bendConstraints[iBend]
--		print (iBend, #self.bendConstraints)
		local s1 = self.stretchConstraints[iBend]
		local s2 = self.stretchConstraints[iBend+1]
--		print (#self.masses)
		local invMass1 = self.invMasses[iBend]
		local invMass2 = self.invMasses[iBend+1]
		local invMass3 = self.invMasses[iBend+2]
		
		local L1 = s1.length
		local L2 = s2.length
		local L1sqr = L1 * L1
		local L2sqr = L2 * L2
--		if L1sqr * L2sqr ~= 0 and invMass1 * invMass2 * invMass3 ~= 0 then
		if L1sqr * L2sqr ~= 0 then
			-- Flatten the triangle formed by the two edges
			local J2 = 1 / L1 + 1 / L2
			local sum = invMass1/ L1sqr + J2*J2*invMass2 + invMass3/L2sqr
			if sum ~= 0 then
--				local mass = 1 / sum
				bend.spring = bendOmega * bendOmega / sum
				bend.damper = 2 * bendDamping * bendOmega / sum
			end
		end
		
		print ((i+1)/2, 'bend.spring', bend.spring)
	end

	self.stretchSolver = b2Rope.stretchingSolvers[tuning.stretchingModel]
	self.bendSolver = b2Rope.bendingSolvers[tuning.bendingModel]

end


-----------------------------------------
-------------- step   -------------------
-----------------------------------------

function b2Rope:step(dt, iterations, x, y)
	

	local tuning = self.tuning
	local bendingModel = tuning.bendingModel
	local stretchingModel = tuning.stretchingModel
	local damping = tuning.damping

	local inv_dt = 1 / dt
	local d = math.exp(-dt * damping)

	-- apply gravity and damping
	for i = 1, #self.vertices-1, 2 do
		local iNode = (i+1)/2
		local node = self.nodes[iNode]
		if node.invMass > 0 then
			node.vX = node.vX * d + dt * self.gravityX
			node.vY = node.vY * d + dt * self.gravityY
--			print ('delta vY:'.. dt * self.gravityY)
		else
			node.vX = inv_dt * (node.x + x - node.p0x)
			node.vY = inv_dt * (node.y + y - node.p0y)
		end
	end

	-- apply bending spring
	if bendingModel == b2_springAngleBendingModel then
--		print ('bendingModel')
		self:solveBend_spring_angle(dt)
	end

	for i = 1, #self.stretchConstraints do
		self.stretchConstraints[i].lambda = 0
	end
	
	for i = 1, #self.bendConstraints do
		self.bendConstraints[i].lambda = 0
	end

	-- Update position
	for i = 1, #self.nodes do
		local node = self.nodes[i]
		node.pX = node.pX + dt * node.vX
		node.pY = node.pY + dt * node.vY
	end

	-- solve constraints
	for _ = 1, iterations do
--		print (bendingModel)
		if bendingModel == b2_pbdAngleBendingModel then
			self:solveBend_PBD_angle()
		elseif bendingModel == b2_xpbdAngleBendingModel then
			self:solveBend_XPBD_angle(dt)
		elseif bendingModel == b2_pbdDistanceBendingModel then
			self:solveBend_PBD_distance()
		elseif bendingModel == b2_pbdHeightBendingModel then
			self:solveBend_PBD_height()
		elseif bendingModel == b2_pbdTriangleBendingModel then
			self:solveBend_PBD_triangle()
		end

--		print (stretchingModel, b2_pbdStretchingModel)
		if stretchingModel == b2_pbdStretchingModel then
			self:solveStretch_PBD()
		elseif stretchingModel == b2_xpbdStretchingModel then
			self:solveStretch_XPBD(dt)
		end
	end

--	 Constrain velocity
	for i = 1, #self.nodes do
		local node = self.nodes[i]
		node.vX = inv_dt * (node.pX - node.p0x)
		node.vY = inv_dt * (node.pY - node.p0y)
		node.p0x = node.pX
		node.p0y = node.pY
	end

	for i = 1, #self.nodes do
		local node = self.nodes[i]
		self.vertices[i*2-1] = node.pX
		self.vertices[i*2] = node.pY
	end
	
	
end

function b2Rope:update(dt, x, y)
	x = x or self.x
	y = y or self.y
	
	local iterations = 1
	if dt == 0 then
		return
	elseif dt > 0.05 then -- 20 fps
		iterations = math.ceil(dt / 0.05)
		dt = dt/iterations
	end
	self:step(dt, iterations, x, y)
end

-----------------------------------------
-------------- reset  -------------------
-----------------------------------------

function b2Rope:reset(position)
	local x = position.x
	local y = position.y
	self.x = x
	self.y = y

	for i = 1, self.count do
		local node = self.nodes[i]
		node.pX = node.x + x
		node.pY = node.y + y
		node.pX0 = node.x + x
		node.pY0 = node.y + y

		node.vX = 0
		node.vY = 0
	end

	for i = 1, self.bendCount do
		self.bendConstraints[i].lambda = 0
	end

	for i = 1, self.stretchCount do
		self.stretchConstraints[i].lambda = 0
	end
end


-----------------------------------------
-------------- solveStretch -------------
-----------------------------------------


function b2Rope:solveStretch_PBD()
	-- Retrieve stiffness value from tuning parameters

	local stiffness = self.tuning.stretchStiffness

	for i = 1, #self.stretchConstraints do
		-- Retrieve the stretch constraint
		local stretch = self.stretchConstraints[i]

		-- Retrieve the nodes involved in the constraint
		local node1 = self.nodes[i]
		local node2 = self.nodes[i+1]

		-- Retrieve the current positions of the nodes
		local p1X = node1.pX
		local p1Y = node1.pY
		local p2X = node2.pX
		local p2Y = node2.pY

		-- Calculate current displacement and length between the nodes
		local dX = p2X - p1X
		local dY = p2Y - p1Y
		local L = math.sqrt(dX * dX + dY * dY)

		-- Calculate desired change in length and apply stiffness
--		print (i, 'Stretch_PBD', 'L', L)
		if L ~= 0 then
			local dL = stiffness * (stretch.length - L) / L
--			print (i, 'Stretch_PBD', 'dL', dL)
			dX = dL * dX
			dY = dL * dY

	-- Calculate inverse mass sum
			local invMass1 = self.invMasses[i]
			local invMass2 = self.invMasses[i+1]
			local sum = invMass1 + invMass2

	-- Check if the sum is non-zero to avoid division by zero
--			print (i, 'Stretch_PBD', 'sum', sum)
			if sum ~= 0 then 
				invMass1 = invMass1 / sum
				invMass2 = invMass2 / sum

				-- Update node positions based on stiffness and inverse mass ratios
				node1.pX = p1X - dX*invMass1
				node1.pY = p1Y - dY*invMass1
				node2.pX = p2X + dX*invMass2
				node2.pY = p2Y + dY*invMass2
			end
		end
	end
end

function b2Rope:solveStretch_XPBD(dt)
	-- Position-Based Dynamics with Extended Position Correction
	assert(dt > 0)
--	print ('dt', dt)

		for i = 1, #self.stretchConstraints do
		-- Retrieve the stretch constraint
		local stretch = self.stretchConstraints[i]

		-- Retrieve the nodes involved in the constraint
		local node1 = self.nodes[i]
		local node2 = self.nodes[i+1]

		-- Retrieve the current positions of the nodes
		local p1X = node1.pX
		local p1Y = node1.pY
		local p2X = node2.pX
		local p2Y = node2.pY

		-- Calculate the total mass of the nodes
			-- Calculate inverse mass sum
		local invMass1 = self.invMasses[i]
		local invMass2 = self.invMasses[i+1]
--		print ('invMass1', invMass1, 'invMass2', invMass2)
			
		local sum = invMass1 + invMass2
		
		if sum ~= 0 then
		
--			print (i, 'p1X', p1X)

			-- Calculate the position differences from the original positions
			local dp1X = p1X - node1.p0x
			local dp1Y = p1Y - node1.p0y
			local dp2X = p2X - node2.p0x
			local dp2Y = p2Y - node2.p0y 

			-- Calculate the direction vector between the nodes
			local uX = p2X - p1X
			local uY = p2Y - p1Y

			-- Calculate the current distance between the nodes
			local L = math.sqrt(uX * uX + uY * uY)

			if L ~= 0 then
				-- Calculate the Jacobian vectors
				local J1X = -uX / L
				local J1Y = -uY / L
				local J2X = uX / L
				local J2Y = uY / L

				-- Calculate the stiffness coefficient
				local alpha = 1 / (stretch.spring * dt * dt)
				
				-- Calculate the damping coefficient
				local beta = dt * dt * stretch.damper
				
				-- Calculate the correction coefficient
				local sigma = alpha * beta / dt

				-- Calculate the position error
				local C = L - stretch.length

				-- Calculate the velocity error
				local Cdot = J1X * dp1X + J1Y * dp1Y + J2X * dp2X + J2Y * dp2Y

				-- Calculate the impulse magnitude
				local B = C + alpha * stretch.lambda + sigma * Cdot

				-- Calculate the denominator term
				local sum2 = (1 + sigma) * sum + alpha
	--			print ('sum2', sum2)
				if sum2 ~= 0 then
					-- Calculate the impulse
--					print ('B', B, 'sum', sum)
					local impulse = B / sum2 -- It may be negative

					-- Update the positions of the nodes
--					print ('p1X', p1X, 'invMass1', invMass1, 'impulse', 'J1X', J1X)
--					print ('p2X', p2X, 'invMass2', invMass2, 'impulse', impulse, 'J2X', J2X)
--					print ('p2Y', p2Y, 'invMass2', invMass2, 'impulse', impulse, 'J2Y', J2Y)
					
					node1.pX = p1X - invMass1 * impulse * J1X
					node1.pY = p1Y - invMass1 * impulse * J1Y
					
					local pX = (p2X - invMass2 * impulse * J2X)
					local pY = (p2Y - invMass2 * impulse * J2Y)
					
					node2.pX = (p2X - invMass2 * impulse * J2X)
					node2.pY = (p2Y - invMass2 * impulse * J2Y)
					
--					print ('node2', pX, pY)

					-- Update the accumulated lambda
					stretch.lambda = stretch.lambda + impulse
				end
			end
		end
	end
end


-----------------------------------------
-------------- solveBend ----------------
-----------------------------------------



function b2Rope:solveBend_spring_angle(dt)
	self:applyBendForces(dt)
end


function b2Rope:solveBend_PBD_angle()
-- solves the bending constraints for a rope using Position-Based Dynamics 
-- Retrieve the bend stiffness from the rope tuning parameters
	local stiffness = self.tuning.bendStiffness

	-- Iterate over each bend constraint in the rope
	for i = 1, #self.bendConstraints do
		local bend = self.bendConstraints[i]

--		Get the nodes involved in the bend constraint (p1, p2, p3)
		local p1 = self.nodes[i]
		local p2 = self.nodes[i+1]
		local p3 = self.nodes[i+2]

--Calculate the direction vectors (d1, d2) between the nodes
		local d1X = p2.x - p1.x
		local d1Y = p2.y - p1.y
		local d2X = p3.x - p2.x
		local d2Y = p3.y - p2.y

--Compute the signed area (a) and dot product (b) of the direction vectors.
		local a = d1X * d2Y - d1Y * d2X
		local b = d1X * d2X + d1Y * d2Y

		-- Calculate the angle between two vectors
		local angle = math.atan2(a, b)

		local L1sqr, L2sqr

		-- Determine the squared lengths based on the isometric flag
		if self.tuning.isometric then
			L1sqr = bend.L1 * bend.L1
			L2sqr = bend.L2 * bend.L2
		else
			L1sqr = d1X * d1X + d1Y * d1Y
			L2sqr = d2X * d2X + d2Y * d2Y
		end

		-- Ensure the product of squared lengths is not zero
		if L1sqr * L2sqr ~= 0 then
			-- Calculate the Jacobians for the constraints
			local Jd1X = -d1Y / L1sqr
			local Jd1Y = d1X / L1sqr
			local Jd2X = d2Y / L2sqr
			local Jd2Y = -d2X / L2sqr

			local J1X = -Jd1X
			local J1Y = -Jd1Y
			local J2X = Jd1X - Jd2X
			local J2Y = Jd1Y - Jd2Y
			local J3X = Jd2X
			local J3Y = Jd2Y

			local sum = bend.invEffectiveMass

			local invMass1 = self.invMasses[i]
			local invMass2 = self.invMasses[i+1]
			local invMass3 = self.invMasses[i+2]
			-- Calculate the sum of inverse masses if fixedEffectiveMass is false
			
			if not self.tuning.fixedEffectiveMass then
				sum = invMass1 * (J1X * J1X + J1Y * J1Y) + invMass2 * (J2X * J2X + J2Y * J2Y) + invMass3 * (J3X * J3X + J3Y * J3Y)
				if sum == 0 then
					sum = bend.invEffectiveMass
				end
			end

			-- Ensure the sum is not zero
			if sum ~= 0 then
				-- Calculate the impulse
				local impulse = stiffness * angle / sum

				-- apply impulses to the nodes
				p1.x = p1.x - invMass1 * impulse * J1X
				p1.y = p1.y - invMass1 * impulse * J1Y
				p2.x = p2.x - invMass2 * impulse * J2X
				p2.y = p2.y - invMass2 * impulse * J2Y
				p3.x = p3.x - invMass3 * impulse * J3X
				p3.y = p3.y - invMass3 * impulse * J3Y
			end
		end
	end
end



function b2Rope:solveBend_XPBD_angle(dt)
	-- Extended Position-Based Dynamics method, considering angles
	-- Ensure that dt is greater than 0
	assert(dt > 0)

	for i = 1, #self.bendConstraints do
		local bend = self.bendConstraints[i]

		local p1 = self.nodes[i]
		local p2 = self.nodes[i+1]
		local p3 = self.nodes[i+2]

		local dp1X = p1.x - p1.p0x
		local dp1Y = p1.y - p1.p0y
		local dp2X = p2.x - p2.p0x
		local dp2Y = p2.y - p2.p0y
		local dp3X = p3.x - p3.p0x
		local dp3Y = p3.y - p3.p0y

		local d1X = p2.x - p1.x
		local d1Y = p2.y - p1.y
		local d2X = p3.x - p2.x
		local d2Y = p3.y - p2.y

		local L1sqr, L2sqr

		if self.tuning.isometric then
			L1sqr = bend.L1 * bend.L1
			L2sqr = bend.L2 * bend.L2
		else
			L1sqr = d1X * d1X + d1Y * d1Y
			L2sqr = d2X * d2X + d2Y * d2Y
		end

		-- Check if L1sqr and L2sqr are non-zero
		if L1sqr * L2sqr ~= 0 then
			local a = d1X * d2Y - d1Y * d2X
			local b = d1X * d2X + d1Y * d2Y

			local angle = math.atan2(a, b)

			local Jd1X = -d1Y / L1sqr
			local Jd1Y = d1X / L1sqr
			local Jd2X = d2Y / L2sqr
			local Jd2Y = -d2X / L2sqr

			local J1X = -Jd1X
			local J1Y = -Jd1Y
			local J2X = Jd1X - Jd2X
			local J2Y = Jd1Y - Jd2Y
			local J3X = Jd2X
			local J3Y = Jd2Y

			local sum = bend.invEffectiveMass
			
			local invMass1 = self.invMasses[i]
			local invMass2 = self.invMasses[i+1]
			local invMass3 = self.invMasses[i+2]

			-- Calculate the sum of effective masses
			if not self.tuning.fixedEffectiveMass then
				sum = invMass1 * (J1X * J1X + J1Y * J1Y) + invMass2 * (J2X * J2X + J2Y * J2Y) + invMass3 * (J3X * J3X + J3Y * J3Y)
				if sum == 0 then
					-- If sum is zero, use invEffectiveMass
					sum = bend.invEffectiveMass
				end
			end

			-- Check if sum is non-zero
			if sum ~= 0 then
				local alpha = 1 / (bend.spring * dt * dt)
				local beta = dt * dt * bend.damper
				local sigma = alpha * beta / dt
				local C = angle

				-- Calculate the time derivative of the constraint
				local Cdot = J1X * dp1X + J1Y * dp1Y + J2X * dp2X + J2Y * dp2Y + J3X * dp3X + J3Y * dp3Y

				local B = C + alpha * bend.lambda + sigma * Cdot
				local sum2 = (1 + sigma) * sum + alpha

				-- Calculate the impulse magnitude
				local impulse = B / sum2

				-- apply impulses to the node positions
				p1.x = p1.x - invMass1 * impulse * J1X
				p1.y = p1.y - invMass1 * impulse * J1Y
				p2.x = p2.x - invMass2 * impulse * J2X
				p2.y = p2.y - invMass2 * impulse * J2Y
				p3.x = p3.x - invMass3 * impulse * J3X
				p3.y = p3.y - invMass3 * impulse * J3Y

				bend.lambda = bend.lambda + impulse
			end
		end
	end
end



function b2Rope:solveBend_PBD_distance()
	-- Position-Based Dynamics approach
	local stiffness = self.tuning.bendStiffness

	for i = 1, self.bendCount do
		local bend = self.bendConstraints[i]
		local sum = bend.invMass1 + bend.invMass3

		if sum ~= 0 then
			local i1 = bend.i1
			local i3 = bend.i3

			local p1 = self.nodes[i1]
			local p3 = self.nodes[i3]

			local dx = p3.x - p1.x
			local dy = p3.y - p1.y
			local L = math.sqrt(dx * dx + dy * dy)
			dx = dx / L
			dy = dy / L
			local s1 = bend.invMass1 / sum
			local s2 = bend.invMass3 / sum

			local correction = stiffness * (bend.L1 + bend.L2 - L)

-- apply positional correction to maintain desired distance
-- between the connected nodes based on bend constraints
			p1.x = p1.x - s1 * correction * dx
			p1.y = p1.y - s1 * correction * dy
			p3.x = p3.x + s2 * correction * dx
			p3.y = p3.y + s2 * correction * dy
		end
	end
end


function b2Rope:solveBend_PBD_height()
	-- Position-Based Dynamics approach
	local stiffness = self.tuning.bendStiffness

	for i = 1, self.bendCount do
		local bend = self.bendConstraints[i]

		-- Retrieve node positions
		local p1 = self.nodes[bend.i1]
		local p2 = self.nodes[bend.i2]
		local p3 = self.nodes[bend.i3]

		-- Calculate displacement vector
		local dX = bend.alpha1 * p1.x + bend.alpha2 * p3.x - p2.x
		local dY = bend.alpha1 * p1.y + bend.alpha2 * p3.y - p2.y

		-- Calculate displacement length
		local dLen = math.sqrt(dX * dX + dY * dY)

		if dLen ~= 0 then
			-- Calculate normalized displacement vector
			dX = dX / dLen
			dY = dY / dLen

			-- Calculate effective mass
			local sum = bend.invMass1 * bend.alpha1 * bend.alpha1 
			+ bend.invMass2 
			+ bend.invMass3 * bend.alpha2 * bend.alpha2

			if sum ~= 0 then
				local impulse = stiffness * dLen / sum

				-- apply positional correction to maintain desired height
				p1.x = p1.x - bend.invMass1 * impulse * dX * bend.alpha1
				p1.y = p1.y - bend.invMass1 * impulse * dY * bend.alpha1
				p2.x = p2.x + bend.invMass2 * impulse * dX
				p2.y = p2.y + bend.invMass2 * impulse * dY
				p3.x = p3.x - bend.invMass3 * impulse * dX * bend.alpha2
				p3.y = p3.y - bend.invMass3 * impulse * dY * bend.alpha2
			end
		end
	end
end



function b2Rope:solveBend_PBD_triangle()
	-- Position-Based Dynamics approach
	local stiffness = self.tuning.bendStiffness

	for i = 1, self.bendCount do
		local bend = self.bendConstraints[i]

		-- Retrieve inverse masses
		local invMass1 = bend.invMass1
		local invMass2 = bend.invMass2
		local invMass3 = bend.invMass3

		-- Calculate total weight and inverse weight
		local sum = invMass1 + 2 * invMass2 + invMass3
		if sum ~= 0 then
			-- double magnitude of the displacement corrections
			local dmd = 2 * stiffness / sum

			-- Retrieve node positions
			local p1 = self.nodes[bend.i1]
			local p2 = self.nodes[bend.i2]
			local p3 = self.nodes[bend.i3]

			-- Calculate displacement vector
			local dX = p2.x - (p1.x + p2.x + p3.x) / 3
			local dY = p2.y - (p1.y + p2.y + p3.y) / 3

			-- Calculate positional corrections
			local dp1X = invMass1 * dmd * dX
			local dp1Y = invMass1 * dmd * dY
			local dp2X = invMass2 * dmd * dX
			local dp2Y = invMass2 * dmd * dY
			local dp3X = invMass3 * dmd * dX
			local dp3Y = invMass3 * dmd * dY

			-- apply positional corrections
			p1.x = p1.x + dp1X
			p1.y = p1.y + dp1Y
			p2.x = p2.x - dp2X * 2
			p2.y = p2.y - dp2Y * 2
			p3.x = p3.x + dp3X
			p3.y = p3.y + dp3Y
		end
	end
end


function b2Rope:applyBendForces(dt)
-- Method that applies bending forces to the rope's nodes 
-- based on the specified constraints
-- omega = 2 * pi * hz
	local omega = 2 * math.pi * self.tuning.bendHertz
	

	for i = 1, #self.bendConstraints do
		local bend = self.bendConstraints[i]



		-- Retrieve node positions
		local p1 = self.nodes[i]
		local p2 = self.nodes[i+1]
		local p3 = self.nodes[i+2]

		-- Retrieve node velocities
		local v1X = p1.vX
		local v1Y = p1.vY
		local v2X = p2.vX
		local v2Y = p2.vY
		local v3X = p3.vX
		local v3Y = p3.vY

		-- Calculate displacements between nodes
		local d1X = p2.x - p1.x
		local d1Y = p2.y - p1.y
		local d2X = p3.x - p2.x
		local d2Y = p3.y - p2.y

		-- Calculate squared lengths of displacements
		local L1sqr, L2sqr

		if self.tuning.isometric then
			L1sqr = bend.L1 * bend.L1
			L2sqr = bend.L2 * bend.L2
		else
			L1sqr = d1X * d1X + d1Y * d1Y
			L2sqr = d2X * d2X + d2Y * d2Y
		end

		if L1sqr * L2sqr ~= 0 then
			local a = d1X * d2Y - d1Y * d2X
			local b = d1X * d2X + d1Y * d2Y

			local angle = math.atan2(a, b)

			local Jd1X = -d1Y / L1sqr
			local Jd1Y = d1X / L1sqr
			local Jd2X = d2Y / L2sqr
			local Jd2Y = -d2X / L2sqr

			local J1X = -Jd1X
			local J1Y = -Jd1Y
			local J2X = Jd1X - Jd2X
			local J2Y = Jd1Y - Jd2Y
			local J3X = Jd2X
			local J3Y = Jd2Y

			local sum = bend.invEffectiveMass
			
		-- Retrieve inverse masses
		local invMass1 = self.invMasses[i]
		local invMass2 = self.invMasses[i+1]
		local invMass3 = self.invMasses[i+2]
			
			if not self.tuning.fixedEffectiveMass then
				sum = (J1X * J1X + J1Y * J1Y)*invMass1 + (J2X * J2X + J2Y * J2Y)*invMass2 + (J3X * J3X + J3Y * J3Y)*invMass3
				if sum == 0 then
					sum = bend.invEffectiveMass
				end
			end

			if sum ~= 0 then
				local mass = 1 / sum

				local spring = mass * omega * omega
				local damper = 2 * mass * self.tuning.bendDamping * omega

				local C = angle
				local Cdot = J1X * v1X + J1Y * v1Y + J2X * v2X + J2Y * v2Y + J3X * v3X + J3Y * v3Y

				local impulse = dt * (spring * C + damper * Cdot)

				p1.vX = p1.vX - impulse * J1X*invMass1
				p1.vY = p1.vY - impulse * J1Y*invMass1
				p2.vX = p2.vX - impulse * J2X*invMass2
				p2.vY = p2.vY - impulse * J2Y*invMass2
				p3.vX = p3.vX - impulse * J3X*invMass3
				p3.vY = p3.vY - impulse * J3Y*invMass3
			end
		end
	end
end


function b2Rope:draw(pointRadius, lineColor, anchorColor, dynamicColor)
	lineColor = lineColor or {0.4, 0.5, 0.7} -- light blue
	dynamicColor = dynamicColor or {0.1, 0.8, 0.1} -- green
	anchorColor = anchorColor or {0.7, 0.2, 0.4} -- red

	local x1 = self.vertices[1]
	local y1 = self.vertices[2]
	local invMass1 = self.invMasses[1]
	if invMass1 > 0 then
		love.graphics.setColor (dynamicColor) -- dynamic segments
	else
		love.graphics.setColor (anchorColor) -- anchor segments
	end
	love.graphics.circle ('line', x1, y1, pointRadius)

	for i = 3, #self.vertices-1, 2 do
		local x2 = self.vertices[i]
		local y2 = self.vertices[i+1]
		local invMass2 = self.invMasses[1]
		love.graphics.setColor (lineColor) -- rope segments
		love.graphics.line (x1, y1, x2, y2)

		if invMass2 > 0 then
			love.graphics.setColor (dynamicColor) -- dynamic segments
		else
			love.graphics.setColor (anchorColor) -- anchor segments
		end
		love.graphics.circle ('line', x2, y2, pointRadius)
		x1 = x2
		y1 = y2
		invMass1 = invMass2
	end
end





--[[
bendingModel	b2_springAngleBendingModel	ApplyBendForces

bendingModel 	b2_pbdAngleBendingModel	SolveBend_PBD_Angle
bendingModel 	b2_xpbdAngleBendingModel	SolveBend_XPBD_Angle
bendingModel 	b2_pbdDistanceBendingModel	SolveBend_PBD_Distance
bendingModel 	b2_pbdHeightBendingModel	SolveBend_PBD_Height
bendingModel 	b2_pbdTriangleBendingModel	  SolveBend_PBD_Triangle

stretchingModel 	b2_pbdStretchingModel	SolveStretch_PBD
stretchingModel 	b2_xpbdStretchingModel	SolveStretch_XPBD
--]]


return b2Rope
