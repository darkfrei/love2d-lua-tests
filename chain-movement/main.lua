local chain = {}
local segmentLength = 20
local chainLength = 20
local time = 0
local maxAngle = math.rad(20)
local maxOmega = math.rad(180*14)
print (maxOmega)

-- lissajous figure parameters
local a, b = 150, 150 -- amplitude
local omegaX, omegaY = 1, 2 -- frequency
local phase =0 -- phase shift
local delta = math.pi / 2

function love.load()
	-- create the chain with evenly spaced nodes
	for i = 1, chainLength do
		local x = 100 + (chainLength - i) * segmentLength
		local y = 100
		chain[i] = { x = x, y = y }
	end
end

function math.sign(v)
	if v > 0 then
		return 1
	elseif v < 0 then
		return -1
	else
		return 0
	end
end


-- function to return node position with soft influence if the angle between segments exceeds maxAngle
local function adjustNodePosition(x1, y1, x2, y2, x3, y3, dt)
	-- calculate the vectors between the points
	local dx1, dy1 = x2 - x1, y2 - y1
	local dx2, dy2 = x3 - x2, y3 - y2

	-- calculate the angles of the vectors
	local angle1 = math.atan2(dy1, dx1)  -- angle of the vector from (x1, y1) to (x2, y2)
	local angle2 = math.atan2(dy2, dx2)  -- angle of the vector from (x2, y2) to (x3, y3)

	-- calculate the difference between the two angles
	local angleDiff = angle2 - angle1

	-- normalize the angle difference to the range [-pi, pi]
	if angleDiff > math.pi then
		angleDiff = angleDiff - 2 * math.pi
	elseif angleDiff < -math.pi then
		angleDiff = angleDiff + 2 * math.pi
	end

	-- if the angle difference exceeds the max allowed angle, adjust the node position
	if math.abs(angleDiff) > maxAngle then
		-- limit the angle change to maxOmega * dt (soft adjustment)
		local maxDelta = maxOmega * dt

		local newMaxAngle = math.max (maxAngle, maxAngle + (math.abs(angleDiff)-maxAngle)*maxDelta)
--		print (maxDelta, maxAngle, math.abs(maxAngle)-maxDelta)

		angleDiff = math.sign(angleDiff) * newMaxAngle
--		angleDiff = math.sign(angleDiff) * math.min(math.abs(angleDiff), maxDelta)

		-- calculate the new angle for the second vector
		local newAngle = angle1 + angleDiff

		-- calculate the new position for the third node using the new angle
		local length = math.sqrt(dx2 * dx2 + dy2 * dy2)
		local newDx = math.cos(newAngle) * length
		local newDy = math.sin(newAngle) * length

		-- set the new position for the third node
		x3 = x2 + newDx
		y3 = y2 + newDy
	end

	return x3, y3
end

function love.update(dt)
	time = time + dt -- control speed of movement

	local prev = chain[1]
	-- move the first node along a lissajous figure
	prev.x = 400 + a * math.sin(omegaX * time)
	prev.y = 300 + b * math.sin(omegaY * time + phase)


--	prev.x, prev.y = love.mouse.getPosition()


	-- update the rest of the chain
	for i = 2, #chain do
		local node = chain[i]

		-- calculate the vector between nodes
		local dx, dy = node.x - prev.x, node.y - prev.y
		local dist = math.sqrt(dx * dx + dy * dy)
		if dist > 0 then 
			local move = segmentLength-dist
			if dist > 0 then
				-- adjust the position to maintain segment length
				node.x = node.x + (dx / dist) * move
				node.y = node.y + (dy / dist) * move
			end
		end

		-- check the angle between segments and adjust if necessary
		if i > 1 then
			-- use the adjustNodePosition function to modify node[3] if needed
			local nextNode = chain[i+1]

			if nextNode then
				local x3, y3 = adjustNodePosition(
					prev.x, prev.y, 
					node.x, node.y, 
					nextNode.x, nextNode.y, dt)

				nextNode.x = x3
				nextNode.y = y3
			end
		end

		prev = node
	end
end

function love.draw()
	-- draw nodes and connect them with lines
	love.graphics.setColor (1,1,1)
	for i = 1, #chain do
		love.graphics.circle('fill', chain[i].x, chain[i].y, 5)
		if i > 1 then
			love.graphics.line(chain[i].x, chain[i].y, chain[i - 1].x, chain[i - 1].y)
		end
	end
end