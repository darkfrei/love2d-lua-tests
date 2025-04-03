-- points.lua

local pathfinding = require("pathfinding")

-- create a new point with a given path
local function createPoint(startId, goalId, path)
	return {
		startId = startId,
		goalId = goalId,
		path = path,
		pathIndex = 1,
		progress = 0,
		speed = 50, -- pixels per second
		currentEdgeId = nil, -- track the current edge id
		toRemove = false, -- flag to mark for removal
--        isRepathing = false -- flag to indicate if the point is repathing
		isRepathing = math.random () < 0.5,  -- flag to indicate if the point is repathing after point.progress >= 1
		isGreen = false -- flag to indicate if the path of point should be green
	}
end

-- compare two paths starting from the current node id
local function comparePaths(oldPath, newPath, currentNodeId)
	-- find the index of the current node in both paths
	local startIndex1
	for i, nodeId in ipairs(oldPath) do
		if nodeId == currentNodeId then
			startIndex1 = i
		end
	end

	for i, newId in ipairs (newPath) do
		local oldId = oldPath[i+startIndex1-1]
		
		if newId ~= oldId then 
--			print (i, 'newId', newId, 'oldId', oldId)
			return true
		end
	end


	return false -- paths are identical
end

-- update all moving points
local function updatePoints(movingPoints, nodes, edges, dt)
	for _, point in ipairs(movingPoints) do
		if point.pathIndex < #point.path then
			-- calculate the total distance of the current segment
			local currentNode = nodes[point.path[point.pathIndex]]
			local nextNode = nodes[point.path[point.pathIndex + 1]]
			local dx = nextNode.x - currentNode.x
			local dy = nextNode.y - currentNode.y
			local segmentLength = math.sqrt(dx * dx + dy * dy)

			-- update progress along the segment
			point.progress = point.progress + (point.speed * dt) / segmentLength

			-- find the current edge id
			local edgeId = nil
			for _, neighbor in ipairs(currentNode.neighbors) do
				if neighbor.id == nextNode.id then
					edgeId = neighbor.edgeId
					break
				end
			end

			-- increase dynamic cost of the current edge
			if edgeId and edgeId ~= point.currentEdgeId then
				edges[edgeId].dynamicCost = edges[edgeId].dynamicCost + 1
				point.currentEdgeId = edgeId -- update the current edge id
			end

			-- move to the next segment if progress exceeds 1
			if point.progress >= 1 then
				point.pathIndex = point.pathIndex + 1
				point.progress = 0

				-- decrease dynamic cost of the previous edge
				if point.currentEdgeId then
					edges[point.currentEdgeId].dynamicCost = math.max((edges[point.currentEdgeId].dynamicCost or 0) - 1, 0)
					point.currentEdgeId = nil -- reset the current edge id
				end

				-- check if the point should attempt to repath
				if point.isRepathing and point.pathIndex < #point.path then
					local currentId = point.path[point.pathIndex] -- current node id
--					local newPath = pathfinding (currentId, point.goalId) -- attempt to find a new path
					local newPath = pathfinding (nodes, edges, currentId, point.goalId) -- attempt to find a new path
					if newPath then
						if comparePaths(point.path, newPath, currentId) then
							point.isGreen = true -- set the color to green
							point.path = newPath
							point.pathIndex = 1 -- reset the path index
						else
							point.isGreen = false -- keep the color orange
						end

--						print("repathing successful from node", currentId, "to", point.goalId)
					else
--						print("repathing failed from node", currentId, "to", point.goalId)
					end
				end

				-- check if the end of the path is reached
				if point.pathIndex >= #point.path then
					point.toRemove = true
				end
			end
		end
	end


-- remove points that have reached the end of their path
	for i = #movingPoints, 1, -1 do
		local point = movingPoints[i]
		if point.toRemove then
			table.remove(movingPoints, i)
		end
	end
end

-- draw all moving points
local function drawPoints(movingPoints, nodes)
	-- iterate through all moving points
	for _, point in ipairs(movingPoints) do
		-- ensure the point is not at the end of its path
		if point.pathIndex < #point.path then
			-- calculate the current position of the point along the path
			local currentNode = nodes[point.path[point.pathIndex]]
			local nextNode = nodes[point.path[point.pathIndex + 1]]
			local x = currentNode.x + (nextNode.x - currentNode.x) * point.progress
			local y = currentNode.y + (nextNode.y - currentNode.y) * point.progress

			-- draw the moving point as an orange-filled circle
			-- set color based on whether the point is repathing
			if point.isRepathing then
				love.graphics.setColor(0, 1, 0) -- green color for repathing points
			else
				love.graphics.setColor(1, 0.5, 0) -- orange color for normal points
			end
			love.graphics.circle("fill", x, y, 7) -- slightly larger radius for better visibility

			-- draw a black outline around the point for contrast
			love.graphics.setColor(0, 0, 0) -- black color for the outline
			love.graphics.circle("line", x, y, 7)
		end
	end
end

return {
	createPoint = createPoint,
	updatePoints = updatePoints,
	drawPoints = drawPoints
}