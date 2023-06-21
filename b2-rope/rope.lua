
-- https://github.com/erincatto/box2d/blob/main/src/rope/b2_rope.cpp
-----------------------------------

--[[

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
local b2_pbdStretchingModel =   'b2_pbdStretchingModel'
local b2_pbdAngleBendingModel = 'b2_pbdAngleBendingModel'


local b2_xpbdStretchingModel = 'b2_xpbdStretchingModel'
local b2_xpbdAngleBendingModel = 'b2_xpbdAngleBendingModel'


local b2_pbdDistanceBendingModel = 'b2_pbdDistanceBendingModel'
local b2_pbdHeightBendingModel = 'b2_pbdHeightBendingModel'
local b2_pbdTriangleBendingModel = 'b2_pbdTriangleBendingModel'

local b2_springAngleBendingModel = 'b2_springAngleBendingModel'





local b2Rope = {}
b2Rope.__index = b2Rope

function b2Rope.new()
	local rope = {
		x = 0,
		y = 0,
		count = 0, -- node count
		stretchCount = 0, -- node count -1
		bendCount = 0,  -- node count -2
		nodes = {},
		stretchConstraints = {},
		bendConstraints = {},
		gravity = 0, -- just Y
	}
	setmetatable(rope, b2Rope)
	return rope
end

function b2Rope:destroy()
	self.m_stretchConstraints = nil
	self.m_bendConstraints = nil
	self.m_bindPositions = nil
	self.m_ps = nil
	self.m_p0s = nil
	self.m_vs = nil
	self.m_invMasses = nil
end

-----------------------------------------
-------------- create -------------------
-----------------------------------------

function b2Rope:create(def)
	assert(def.count >= 3)

	local vertices = def.vertices
	local masses = def.masses

	local x = def.position.x
	local y = def.position.y

	local rope = {
		x = x,
		y = y,

		count = def.count,
		stretchCount = def.count - 1,
		bendCount = def.count - 2,

		nodes = {},
		stretchConstraints = {},
		bendConstraints = {},

		gravity = def.gravity,
		tuning = def.tuning
	}

	for i = 1, rope.count do
		local px = x + vertices[i].x
		local py = y + vertices[i].y
		local node = {
			x = vertices[i].x, -- m_bindPositions
			y = vertices[i].y,
			pX = px, -- m_ps
			pY = py,
			p0x = px, -- m_p0s
			p0y = py,
			vX = 0, -- m_vs
			vY = 0,
			invMass = 0
		}
		if masses[i] > 0 then
			node.invMass = 1 / masses[i]
		end
		rope.nodes[i] = node
	end

	for i = 1, rope.stretchCount do
		local node1 = rope.nodes[i]
		local node2 = rope.nodes[i + 1]

		local c = {
			i1 = i,
			i2 = i + 1,
			L = math.sqrt((node2.pX - node1.pX) ^ 2 + (node2.pY - node1.pY) ^ 2),
			invMass1 = node1.invMass,
			invMass2 = node2.invMass,
			lambda = 0,
			damper = 0,
			spring = 0
		}

		rope.stretchConstraints[i] = c
	end

	for i = 1, rope.bendCount do
		local node1 = rope.nodes[i]
		local node2 = rope.nodes[i + 1]
		local node3 = rope.nodes[i + 2]

		local invMass1 = node1.invMass
		local invMass2 = node2.invMass
		local invMass3 = node3.invMass

		local e1X = node2.pX - node1.pX
		local e1Y = node2.pY - node1.pY
		local e2X = node3.pX - node2.pX
		local e2Y = node3.pY - node2.pY

		local L1sqr = e1X * e1X + e1Y * e1Y
		local L2sqr = e2X * e2X + e2Y * e2Y

		local bend = {
			i1 = i,
			i2 = i + 1,
			i3 = i + 2,
			invMass1 = invMass1,
			invMass2 = invMass2,
			invMass3 = invMass3,
			invEffectiveMass = 0,
			L1 = math.sqrt(L1sqr),
			L2 = math.sqrt(L2sqr),
			lambda = 0,
			alpha1 = 0,
			alpha2 = 0
		}

		if L1sqr * L2sqr ~= 0 then
			local invL1sqr = 1 / L1sqr
			local invL2sqr = 1 / L2sqr
			bend.invEffectiveMass = invMass1 * invL1sqr + invMass2 * (1 / L1sqr + 1 / L2sqr) + invMass3 * invL2sqr
			bend.alpha1 = invL1sqr / bend.invEffectiveMass
			bend.alpha2 = invL2sqr / bend.invEffectiveMass
		end

		rope.bendConstraints[i] = bend
	end

	rope:setTuning(def.tuning)

	return rope
end


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


	------------ bend --------------
	for i = 1, self.bendCount do
		local bend = self.bendConstraints[i]
		local L1 = bend.L1
		local L2 = bend.L2
		local L1sqr = L1 * L1
		local L2sqr = L2 * L2
		if L1sqr * L2sqr ~= 0 then
			-- Flatten the triangle formed by the two edges
			local J2 = 1 / L1 + 1 / L2
			local sum = bend.invMass1 / L1sqr + bend.invMass2 * J2 * J2 + bend.invMass3 / L2sqr
			if sum ~= 0 then
				local mass = 1 / sum
				bend.spring = bendOmega * bendOmega * mass
				bend.damper = 2 * bendDamping * bendOmega * mass
			end
		end
	end


	------------ stretch ---------------
	for i = 1, self.stretchCount do
		local stretch = self.stretchConstraints[i]
		local sum = stretch.invMass1 + stretch.invMass2
		if sum ~= 0 then
			local mass = 1 / sum
			stretch.spring = stretchOmega * stretchOmega * mass
			stretch.damper = 2 * stretchDamping * stretchOmega * mass
		end
	end

end


-----------------------------------------
-------------- step   -------------------
-----------------------------------------

function b2Rope:step(dt, iterations, position)
	if dt == 0 then
		return
	elseif dt > 05 then -- 20 fps
		local iterations2 = math.ceil(dt / 05)
		dt = dt/iterations2
		iterations = math.max (iterations, iterations2)
	end

	local tuning = self.tuning
	local bendingModel = tuning.bendingModel
	local stretchingModel = tuning.stretchingModel
	local damping = tuning.damping
	local positionX = position.x
	local positionY = position.y

	local inv_dt = 1 / dt
	local d = math.exp(-dt * damping)

	-- Apply gravity and damping
	for i = 1, self.count do
		local node = self.nodes[i]
		if node.invMass > 0 then
			node.vX = node.vX * d
			node.vY = node.vY * d + dt * self.gravity
		else
			node.vX = inv_dt * (node.x + positionX - node.p0x)
			node.vY = inv_dt * (node.y + positionY - node.p0y)
		end
	end

	-- Apply bending spring
	if bendingModel == b2_springAngleBendingModel then
		self:applyBendForces(dt)
	end

	for i = 1, self.bendCount do
		self.bendConstraints[i].lambda = 0
	end

	for i = 1, self.stretchCount do
		self.stretchConstraints[i].lambda = 0
	end

	-- Update position
	for i = 1, self.count do
		local node = self.nodes[i]
		node.pX = node.pX + dt * node.vX
		node.pY = node.pY + dt * node.vY
	end

	-- Solve constraints
	for i = 1, iterations do
		if bendingModel == b2_pbdAngleBendingModel then
			self:SolveBend_PBD_Angle()
		elseif bendingModel == b2_xpbdAngleBendingModel then
			self:SolveBend_XPBD_Angle(dt)
		elseif bendingModel == b2_pbdDistanceBendingModel then
			self:SolveBend_PBD_Distance()
		elseif bendingModel == b2_pbdHeightBendingModel then
			self:SolveBend_PBD_Height()
		elseif bendingModel == b2_pbdTriangleBendingModel then
			self:SolveBend_PBD_Triangle()
		end

		if stretchingModel == b2_pbdStretchingModel then
			self:SolveStretch_PBD()
		elseif stretchingModel == b2_xpbdStretchingModel then
			self:SolveStretch_XPBD(dt)
		end
	end

	-- Constrain velocity
	for i = 1, self.count do
		local node = self.nodes[i]
		node.vX = inv_dt * (node.pX - node.p0x)
		node.vY = inv_dt * (node.pY - node.p0y)
		node.p0x = node.pX
		node.p0y = node.pY
	end
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

	for i = 1, self.stretchCount do
		local stretch = self.stretchConstraints[i]

		local node1 = self.nodes[stretch.i1]
		local node2 = self.nodes[stretch.i2]

		local p1X = node1.pX
		local p1Y = node1.pY
		local p2X = node2.pX
		local p2Y = node2.pY

		-- Calculate current displacement and length between the nodes
		local dX = p2X - p1X
		local dY = p2Y - p1Y
		local L = math.sqrt(dX * dX + dY * dY)

		-- Calculate desired change in length and apply stiffness
		local dL = stiffness * (stretch.L - L) / L
		dX = dL * dX
		dY = dL * dY

-- Calculate inverse mass sum
		local sum = node1.invMass + node2.invMass

-- Check if the sum is non-zero to avoid division by zero
		if sum == 0 then 

		else
			local s1 = node1.invMass / sum
			local s2 = node2.invMass / sum

			-- Update node positions based on stiffness and inverse mass ratios
			node1.pX = p1X - dX * s1
			node1.pY = p1Y - dY * s1
			node2.pX = p2X + dX * s2
			node2.pY = p2Y + dY * s2
		end
	end
end

function b2Rope:solveStretch_XPBD(dt)
	-- Position-Based Dynamics with Extended Position Correction
	assert(dt > 0)

	for i = 1, self.stretchCount do
		-- Retrieve the stretch constraint
		local stretch = self.stretchConstraints[i]

		-- Retrieve the nodes involved in the constraint
		local node1 = self.nodes[stretch.i1]
		local node2 = self.nodes[stretch.i2]

		-- Calculate the total mass of the nodes
		local sum = node1.invMass + node2.invMass
		if sum ~= 0 then
			-- Retrieve the current positions of the nodes
			local p1X = node1.pX
			local p1Y = node1.pY
			local p2X = node2.pX
			local p2Y = node2.pY

			-- Calculate the position differences from the original positions
			local dp1X = p1X - node1.pX0
			local dp1Y = p1Y - node1.pY0
			local dp2X = p2X - node2.pX0
			local dp2Y = p2Y - node2.pY0 

			-- Calculate the direction vector between the nodes
			local uX = p2X - p1X
			local uY = p2Y - p1Y

			-- Calculate the current distance between the nodes
			local L = math.sqrt(uX * uX + uY * uY)

			-- Calculate the inverse distance
			local invL = 1 / L

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
			local C = L - stretch.L

			-- Calculate the velocity error
			local Cdot = J1X * dp1X + J1Y * dp1Y + J2X * dp2X + J2Y * dp2Y

			-- Calculate the impulse magnitude
			local B = C + alpha * stretch.lambda + sigma * Cdot

			-- Calculate the denominator term
			local sum2 = (1 + sigma) * sum + alpha

			-- Calculate the impulse
			local impulse = B / sum2 -- It may be negative

			-- Update the positions of the nodes
			node1.pX = p1X - node1.invMass * impulse * J1X
			node1.pY = p1Y - node1.invMass * impulse * J1Y
			node2.pX = p2X - node2.invMass * impulse * J2X
			node2.pY = p2Y - node2.invMass * impulse * J2Y

			-- Update the accumulated lambda
			stretch.lambda = stretch.lambda + impulse
		end
	end
end


-----------------------------------------
-------------- solveBend ----------------
-----------------------------------------


function b2Rope:solveBend_PBD_Angle()
-- solves the bending constraints for a rope using Position-Based Dynamics 
-- Retrieve the bend stiffness from the rope tuning parameters
	local stiffness = self.tuning.bendStiffness

	-- Iterate over each bend constraint in the rope
	for i = 1, self.bendCount do
		local bend = self.bendConstraints[i]

--		Get the nodes involved in the bend constraint (p1, p2, p3)
		local p1 = self.nodes[bend.i1]
		local p2 = self.nodes[bend.i2]
		local p3 = self.nodes[bend.i3]

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

			-- Calculate the sum of inverse masses if fixedEffectiveMass is false
			if not self.tuning.fixedEffectiveMass then
				sum = bend.invMass1 * (J1X * J1X + J1Y * J1Y) + bend.invMass2 * (J2X * J2X + J2Y * J2Y) + bend.invMass3 * (J3X * J3X + J3Y * J3Y)
				if sum == 0 then
					sum = bend.invEffectiveMass
				end
			end

			-- Ensure the sum is not zero
			if sum ~= 0 then
				-- Calculate the impulse
				local impulse = stiffness * angle / sum

				-- Apply impulses to the nodes
				p1.x = p1.x - bend.invMass1 * impulse * J1X
				p1.y = p1.y - bend.invMass1 * impulse * J1Y
				p2.x = p2.x - bend.invMass2 * impulse * J2X
				p2.y = p2.y - bend.invMass2 * impulse * J2Y
				p3.x = p3.x - bend.invMass3 * impulse * J3X
				p3.y = p3.y - bend.invMass3 * impulse * J3Y
			end
		end
	end
end



function b2Rope:solveBend_XPBD_Angle(dt)
	-- Extended Position-Based Dynamics method, considering angles
	-- Ensure that dt is greater than 0
	assert(dt > 0)

	for i = 1, self.bendCount do
		local bend = self.bendConstraints[i]

		local p1 = self.nodes[bend.i1]
		local p2 = self.nodes[bend.i2]
		local p3 = self.nodes[bend.i3]

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

			-- Calculate the sum of effective masses
			if not self.tuning.fixedEffectiveMass then
				sum = bend.invMass1 * (J1X * J1X + J1Y * J1Y) + bend.invMass2 * (J2X * J2X + J2Y * J2Y) + bend.invMass3 * (J3X * J3X + J3Y * J3Y)
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

				-- Apply impulses to the node positions
				p1.x = p1.x - bend.invMass1 * impulse * J1X
				p1.y = p1.y - bend.invMass1 * impulse * J1Y
				p2.x = p2.x - bend.invMass2 * impulse * J2X
				p2.y = p2.y - bend.invMass2 * impulse * J2Y
				p3.x = p3.x - bend.invMass3 * impulse * J3X
				p3.y = p3.y - bend.invMass3 * impulse * J3Y

				bend.lambda = bend.lambda + impulse
			end
		end
	end
end



function b2Rope:applyBendForces(dt)
-- Method that applies bending forces to the rope's nodes 
-- based on the specified constraints
-- omega = 2 * pi * hz
	local omega = 2 * math.pi * self.tuning.bendHertz

	for i = 1, self.bendCount do
		local bend = self.bendConstraints[i]

		-- Retrieve inverse masses
		local invMass1 = bend.invMass1
		local invMass2 = bend.invMass2
		local invMass3 = bend.invMass3

		-- Retrieve node positions
		local p1 = self.nodes[bend.i1]
		local p2 = self.nodes[bend.i2]
		local p3 = self.nodes[bend.i3]

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
			if not self.tuning.fixedEffectiveMass then
				sum = bend.invMass1 * (J1X * J1X + J1Y * J1Y) + bend.invMass2 * (J2X * J2X + J2Y * J2Y) + bend.invMass3 * (J3X * J3X + J3Y * J3Y)
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

				p1.vX = p1.vX - invMass1 * impulse * J1X
				p1.vY = p1.vY - invMass1 * impulse * J1Y
				p2.vX = p2.vX - invMass2 * impulse * J2X
				p2.vY = p2.vY - invMass2 * impulse * J2Y
				p3.vX = p3.vX - invMass3 * impulse * J3X
				p3.vY = p3.vY - invMass3 * impulse * J3Y
			end
		end
	end
end

function b2Rope:solveBend_PBD_Distance()
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

-- Apply positional correction to maintain desired distance
-- between the connected nodes based on bend constraints
			p1.x = p1.x - s1 * correction * dx
			p1.y = p1.y - s1 * correction * dy
			p3.x = p3.x + s2 * correction * dx
			p3.y = p3.y + s2 * correction * dy
		end
	end
end


function b2Rope:solveBend_PBD_Height()
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

			-- Calculate Jacobian vectors
			local J1X = bend.alpha1 * dX
			local J1Y = bend.alpha1 * dY
			local J2X = -dX
			local J2Y = -dY
			local J3X = bend.alpha2 * dX
			local J3Y = bend.alpha2 * dY

			-- Calculate effective mass
			local sum = bend.invMass1 * bend.alpha1 * bend.alpha1 
			+ bend.invMass2 
			+ bend.invMass3 * bend.alpha2 * bend.alpha2

			if sum ~= 0 then
				local impulse = stiffness * dLen / sum

				-- Apply positional correction to maintain desired height
				p1.x = p1.x - bend.invMass1 * impulse * J1X
				p1.y = p1.y - bend.invMass1 * impulse * J1Y
				p2.x = p2.x - bend.invMass2 * impulse * J2X
				p2.y = p2.y - bend.invMass2 * impulse * J2Y
				p3.x = p3.x - bend.invMass3 * impulse * J3X
				p3.y = p3.y - bend.invMass3 * impulse * J3Y
			end
		end
	end
end



function b2Rope:solveBend_PBD_Triangle()
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

			-- Apply positional corrections
			p1.x = p1.x + dp1X
			p1.y = p1.y + dp1Y
			p2.x = p2.x - dp2X * 2
			p2.y = p2.y - dp2Y * 2
			p3.x = p3.x + dp3X
			p3.y = p3.y + dp3Y
		end
	end
end

function b2Rope:draw(lineColor, anchorColor, dynamicColor, pointRadius)
	lineColor = lineColor or {0.4, 0.5, 0.7} -- light blue
	dynamicColor = dynamicColor or {0.1, 0.8, 0.1} -- green
	anchorColor = anchorColor or {0.7, 0.2, 0.4} -- red
	
		local p1 = self.nodes[1]
		if p1.invMasses > 0 then
			love.graphics.setColor (dynamicColor) -- dynamic segments
		else
			love.graphics.setColor (anchorColor) -- anchor segments
		end
		love.graphics.circle ('line', p1.x, p1.y, pointRadius)
		
		for i = 2, self.count do
			local p2 = self.nodes[i]
			love.graphics.setColor (lineColor) -- rope segments
			love.graphics.line (p1.x, p1.y, p2.x, p2.y)
			
			if p2.invMasses > 0 then
				love.graphics.setColor (dynamicColor) -- dynamic segments
			else
				love.graphics.setColor (anchorColor) -- anchor segments
			end
			love.graphics.circle ('line', p2.x, p2.y, pointRadius)
			p1 = p2
		end
end





