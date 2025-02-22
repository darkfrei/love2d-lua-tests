local chain = {}         -- array of wagons (locomotive + cars)
local trail = {}         -- array of locomotive position records (trail)
local trailMaxLength = 370  -- max number of positions in the trail
local segmentLength = 20     -- distance between wagons
local chainLength = 10       -- number of nodes (locomotive + wagons)

local a, b = 150, 150        -- amplitudes for the trajectory (Lissajous)
local omegaX, omegaY = 1, 2   -- frequencies for the trajectory
local phase = 0             -- phase shift
local time = 0

function love.load()
	-- initialize the chain nodes. the first node is the locomotive, the rest are wagons
	for i = 1, chainLength do
		chain[i] = { x = 400, y = 300 }
	end
end

-- function returns the position along the trail corresponding to the given distance from the start
local function getPositionAtDistance(distance)
	local accumulated = 0
	for j = 1, #trail - 1 do
		local p1 = trail[j]
		local p2 = trail[j + 1]
		local dx = p1.x - p2.x
		local dy = p1.y - p2.y
		local d = math.sqrt(dx * dx + dy * dy)
		if accumulated + d >= distance then
			local ratio = (distance - accumulated) / d
			local x = p1.x + (p2.x - p1.x) * ratio
			local y = p1.y + (p2.y - p1.y) * ratio
			return { x = x, y = y }, j
		end
		accumulated = accumulated + d
	end
end

-- function to delete trail elements after a specified index
local function deleteTrailAfterIndex(endIndex)
	for i = #trail, endIndex + 3, -1 do -- small tail overlap
		table.remove(trail, i)
	end
end

function love.update(dt)
	time = time + dt

	-- update the position of the locomotive (first node) along the Lissajous trajectory
	local head = chain[1]
	head.x = 400 + a * math.sin(omegaX * time)
	head.y = 300 + b * math.sin(omegaY * time + phase)

	-- the first wagon creates the path by recording its position
	table.insert(trail, 1, { x = head.x, y = head.y })
	if #trail > trailMaxLength then
		table.remove(trail)
	end

	-- for each wagon, calculate its position along the trail
	local pos, lastTrailIndex
	for i = 2, chainLength do
		local desiredDistance = (i - 1) * segmentLength
		pos, lastTrailIndex = getPositionAtDistance(desiredDistance)
		if pos then
			chain[i].x = pos.x
			chain[i].y = pos.y
		end
	end

    -- delete the trail elements after the last wagon
	if lastTrailIndex then
--		print ('delete lastTrailIndex', lastTrailIndex)
--		deleteTrailAfterIndex (lastTrailIndex)
	end

end

function love.draw()
	-- optionally: draw the locomotive trail for visibility
	love.graphics.setColor(0, 1, 0)
	for i = 1, #trail - 1 do
--		love.graphics.circle('line', trail[i].x, trail[i].y, 2)
		love.graphics.line(trail[i].x, trail[i].y, trail[i + 1].x, trail[i + 1].y)
	end

	-- draw nodes and connect them with lines
	love.graphics.setColor (1,1,1)
	for i = 1, #chain do
		love.graphics.circle('fill', chain[i].x, chain[i].y, 5)
--		if i > 1 then
--			love.graphics.line(chain[i].x, chain[i].y, chain[i - 1].x, chain[i - 1].y)
--		end
	end
end
