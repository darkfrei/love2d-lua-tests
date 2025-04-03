-- main.lua
-- load data from data.lua and pathfinding module
local data = require("data")
local pathfinding = require("pathfinding")
local points = require("points")


-- global variables to store nodes and edges
local nodes = data.nodes
local edges = data.edges

-- global variables
local movingPoints = {} -- list of moving points
local spawnTimer = 0 -- timer for spawning new points

-- predefined start and goal pairs
local fromToArray = {{76, 72}, {77, 59}, {78, 62}, {79, 61}}

-- main initialization
function love.load()

end

-- function to spawn a random point
local function spawnRandomPoint()
	-- randomly select start and goal nodes from the predefined array
	local fromTo = fromToArray[math.random(#fromToArray)]
	local startId, goalId = fromTo[1], fromTo[2]
--	print("spawning point:", startId, "->", goalId)

	-- find a path using the pathfinding algorithm
	local path = pathfinding(nodes, edges, startId, goalId)
	if path then
		local point = points.createPoint(startId, goalId, path)
		table.insert(movingPoints, point)
	else
		print("failed to spawn point: no path found between", startId, "and", goalId)
	end
end

function love.update(dt)
--	local tact = 0.25
	local tact = 0.1
	-- update spawn timer
	spawnTimer = spawnTimer + dt

	-- check if a tact has passed
	if spawnTimer >= tact then
		spawnTimer = spawnTimer - tact -- reset the timer

		-- generate a new point with a 50% chance
		if math.random() < 0.5 then
			spawnRandomPoint()
		end
	end

	-- update moving points
	points.updatePoints(movingPoints, nodes, edges, dt)
end

-- key press event to manually spawn a point
function love.keypressed(key)
	if key == "p" then
		spawnRandomPoint()
	end
end

-- main drawing loop
function love.draw()
	-- clear the screen
	love.graphics.setBackgroundColor(0.95, 0.95, 0.95) -- light gray background

	-- draw edges
	love.graphics.setColor(0.2, 0.2, 0.2) -- dark gray color for edges
	love.graphics.setLineWidth(2)
	for _, edge in pairs(edges) do
		love.graphics.line(edge.line)
--		for i = 1, #edge-1 do
--			local node1 = nodes[edge.nodes[i]]
--			local node2 = nodes[edge.nodes[i+1]]
--			love.graphics.line(node1.x, node1.y, node2.x, node2.y)
--		end
	end

	-- draw nodes
	love.graphics.setColor(0.2, 0.4, 0.9) -- blue color for nodes
	for _, node in pairs(nodes) do
		love.graphics.circle("fill", node.x, node.y, 5) -- radius of the circle
	end

	-- draw the paths (if found)
	-- red color for the paths
	love.graphics.setLineWidth(3)
	for _, point in ipairs(movingPoints) do
		if point.isGreen then
			love.graphics.setColor(0, 1, 0, 1)
		else
			love.graphics.setColor(0, 0, 0, 0.2)
		end
		for i = 1, #point.path - 1 do
			local node1 = nodes[point.path[i]]
			local node2 = nodes[point.path[i + 1]]
			if node1 and node2 then
				love.graphics.line(node1.x, node1.y, node2.x, node2.y)
			end
		end
	end

	-- draw the moving points

	points.drawPoints(movingPoints, nodes)


	-- add labels to nodes
	love.graphics.setColor(0, 0, 0) -- black color for text
	for _, node in pairs(nodes) do
		love.graphics.print(tostring(node.id), node.x + 7, node.y - 2)
	end

	for _, edge in pairs(edges) do

		love.graphics.print(tostring(edge.dynamicCost), edge.x + 7, edge.y - 2)
	end
end