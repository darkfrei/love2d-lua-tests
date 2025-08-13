-- main.lua
-- circular obstacle pathfinding demo using LÖVE2D

local pathfinding = require("pathfinding")

-- global variables
local circles, start, goal, path, diagram, currentDebugIndex

-- game setup
function love.load()
	love.window.setMode(800, 600)
	love.window.setTitle("Circular Obstacle Pathfinding")

	-- define obstacles (circles)
	circles = {
		{id = 1, x = 287, y = 299, radius = 55},
		{id = 2, x = 644, y = 460, radius = 40},
--		{id = 3, x = 400, y = 100, radius = 40},
		{id = 4, x = 175, y = 149, radius = 40},
		{id = 5, x = 690, y = 540, radius = 35},
		{id = 6, x = 452, y = 346, radius = 30},
		{id = 7, x = 515, y = 440, radius = 30} 
	}

	-- define start and goal points
	start = {x = 30, y = 74}
	goal = {x = 771, y = 575}



	-- run pathfinding algorithm
	print("Running pathfinding algorithm...")
	path, diagram = pathfinding (circles, start, goal)

	-- initialize debug visualization
	currentDebugIndex = 1

	-- print results
	if path then
		print(string.format("Path found with %d nodes:", #path))
		for i, node in ipairs(path) do
			local costInfo = string.format("cost: %.2f", node.costFromStart or 0)
			if node.arcLength then
				costInfo = costInfo .. string.format(", arc: %.2f", node.arcLength)
			end
			if node.tangentLength then  
				costInfo = costInfo .. string.format(", tangent: %.2f", node.tangentLength)
			end
			print(string.format("  Node %d: %s (type: %s, %s)", 
					i, node.id, node.type, costInfo))
		end
	else
		print("No path found!")
	end

	if diagram and diagram.debugArcs then
		print(string.format("Debug arcs available: %d", #diagram.debugArcs))
		print("Use UP/DOWN arrows to navigate through debug arcs")
	end
end



-- draw coordinate grid for reference
local function drawGrid()
	love.graphics.setColor(0.2, 0.2, 0.25, 0.5)
	love.graphics.setLineWidth(1)

	-- vertical lines
	for x = 0, love.graphics.getWidth(), 50 do
		love.graphics.line(x, 0, x, love.graphics.getHeight())
	end

	-- horizontal lines
	for y = 0, love.graphics.getHeight(), 50 do
		love.graphics.line(0, y, love.graphics.getWidth(), y)
	end
end


-- draw arc segment for surfing nodes
local function drawArcSegment(node)
	if not node.to or not node.to.circle then return end

	local circle = node.to.circle
	local startAngle = node.parentNode and node.parentNode.to.angle or 0
	local endAngle = node.to.angle

	love.graphics.setColor(1, 0, 1, 0.8)
	love.graphics.setLineWidth(3)
	love.graphics.arc("line", "open", circle.x, circle.y, circle.radius, startAngle, endAngle)
end


-- draw the complete path including lines and arcs
local function drawPath()
	-- early exit if no valid path
	if not path or #path < 2 then return end

	-- draw all path segments
	for i, node in ipairs(path) do
		-- skip last node (goal point)
--		if i < #path then
			-- set line color and width
			love.graphics.setColor(0, 1, 1) -- cyan
			love.graphics.setLineWidth(3)

			-- draw straight segment
			if node.line and #node.line >= 4 then
				love.graphics.line(node.line)
			end

			-- draw arc segment if available
			if node.arcPoints and #node.arcPoints >= 4 then
				love.graphics.setColor(1, 0, 1) -- magenta
				love.graphics.line(node.arcPoints)
			end

			-- draw node point
--            love.graphics.setColor(1, 0.5, 0) -- orange
--            love.graphics.circle("fill", node.from.x, node.from.y, 5)

			-- draw node number
			love.graphics.setColor(1, 1, 1) -- white
			love.graphics.print(tostring(i), node.from.x + 10, node.from.y + 5)

	end

	-- draw goal point
	love.graphics.setColor(1, 0, 0) -- red
	love.graphics.circle("fill", path[#path].to.x, path[#path].to.y, 6)
end

-- draw current debug arc
local	function drawCurrentDebugArc()
	local arcs = diagram.debugArcs
	if not arcs or #arcs == 0 then return end

	-- ensure index is within bounds
	currentDebugIndex = math.max(1, math.min(currentDebugIndex, #arcs))
	local arc = arcs[currentDebugIndex]

	if not arc then return end

	-- draw circle outline
	love.graphics.setColor(0.3, 0.3, 0.3)
	love.graphics.setLineWidth(2)
	love.graphics.circle("line", arc.x, arc.y, arc.radius)

	-- draw arc
	love.graphics.setColor(1, 1, 1)
	love.graphics.setLineWidth(4)
	love.graphics.arc("line", "open", arc.x, arc.y, arc.radius, arc.angle1, arc.angle2)

	-- draw radial lines
	if arc.lineRFrom then
		love.graphics.setColor(0, 1, 0)
		love.graphics.setLineWidth(2)
		love.graphics.line(arc.lineRFrom)
	end

	if arc.lineRTo then
		love.graphics.setColor(1, 0, 1)
		love.graphics.setLineWidth(2)
		love.graphics.line(arc.lineRTo)
	end

	-- draw tangent lines
	if arc.lineFrom then
		love.graphics.setColor(0, 1, 0, 0.7)
		love.graphics.setLineWidth(1)
		love.graphics.line(arc.lineFrom)
	end

	if arc.lineTo then
		love.graphics.setColor(1, 0, 1, 0.7)
		love.graphics.setLineWidth(1)
		love.graphics.line(arc.lineTo)
	end

	-- draw arc info
	love.graphics.setColor(1, 1, 1)
	if arc.length then
		love.graphics.print(string.format("Arc %d/%d: length=%.1f", 
				currentDebugIndex, #arcs, arc.length), arc.x - 50, arc.y - arc.radius - 20)
	end
end

-- draw UI information
local function drawUI()
	love.graphics.setColor(1, 1, 1)

	local info = {
		string.format("Circles: %d", #circles),
		string.format("Start: (%.0f, %.0f)", start.x, start.y),
		string.format("Goal: (%.0f, %.0f)", goal.x, goal.y),
		"",
		path and string.format("Path: %d nodes", #path) or "Path: None",
		diagram and string.format("Processed: %d nodes", diagram.nodeCount) or "Processed: 0",
		"",
		"Controls:",
		"UP/DOWN - Navigate debug arcs",
		"R - Restart pathfinding", 
		"T - Test arc calculations",
		"ESC - Exit"
	}

	for i, line in ipairs(info) do
		love.graphics.print(line, 10, 10 + (i - 1) * 15)
	end

	-- show current debug arc info
	if diagram and diagram.debugArcs and #diagram.debugArcs > 0 then
		love.graphics.print(string.format("Debug Arc: %d/%d", 
				currentDebugIndex, #diagram.debugArcs), 10, love.graphics.getHeight() - 40)
	end
end


-- render everything
function love.draw()
	-- set background
	love.graphics.clear(0.1, 0.1, 0.15)

	-- draw coordinate grid (optional)
	drawGrid()

	-- draw all circles as obstacles
	love.graphics.setColor(0.4, 0.4, 0.4, 0.7)
	love.graphics.setLineWidth(2)
	for _, circle in ipairs(circles) do
		love.graphics.circle("fill", circle.x, circle.y, circle.radius)
		love.graphics.setColor(0.6, 0.6, 0.6, 1.0)
		love.graphics.circle("line", circle.x, circle.y, circle.radius)
		love.graphics.setColor(0.4, 0.4, 0.4, 0.7)
	end

	-- draw circle centers and IDs
	love.graphics.setColor(1, 1, 1)
	love.graphics.setLineWidth(1)
	for _, circle in ipairs(circles) do
		love.graphics.circle("fill", circle.x, circle.y, 3)
		love.graphics.print(tostring(circle.id), circle.x + 8, circle.y + 8)
	end

	-- draw start point
	love.graphics.setColor(0, 1, 0)
	love.graphics.circle("fill", start.x, start.y, 6)
	love.graphics.setColor(0, 0.7, 0)
	love.graphics.circle("line", start.x, start.y, 6)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("START", start.x + 10, start.y - 5)

	-- draw goal point
	love.graphics.setColor(1, 0, 0)
	love.graphics.circle("fill", goal.x, goal.y, 6)
	love.graphics.setColor(0.7, 0, 0)
	love.graphics.circle("line", goal.x, goal.y, 6)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("GOAL", goal.x - 30, goal.y - 5)

	-- draw debug lines (all generated edges)
	if diagram and diagram.debugLines then
		love.graphics.setColor(1, 1, 0, 0.3)
		love.graphics.setLineWidth(1)
		for _, line in ipairs(diagram.debugLines) do
			if #line == 4 then
				love.graphics.line(line[1], line[2], line[3], line[4])
			end
		end
	end

	-- draw final path
	if path then
		drawPath()
	end

	-- draw current debug arc (if available)
	if diagram and diagram.debugArcs and #diagram.debugArcs > 0 then
		drawCurrentDebugArc()
	end

	-- draw UI information
	drawUI()
end


-- handle keyboard input
function love.keypressed(key)
	if key == "up" then
		if diagram and diagram.debugArcs then
			currentDebugIndex = math.max(1, currentDebugIndex - 1)
			love.window.setTitle(string.format("Pathfinding - Arc %d/%d", 
					currentDebugIndex, #diagram.debugArcs))
		end
	elseif key == "down" then
		if diagram and diagram.debugArcs then
			currentDebugIndex = math.min(#diagram.debugArcs, currentDebugIndex + 1)
			love.window.setTitle(string.format("Pathfinding - Arc %d/%d", 
					currentDebugIndex, #diagram.debugArcs))
		end
	elseif key == "r" then
		-- restart pathfinding
		print("\nRestarting pathfinding...")
--        testArcCalculations()  -- run tests again
		path, diagram = pathfinding.circularObstaclePathfinding(circles, start, goal)
		currentDebugIndex = 1
	elseif key == "t" then
		-- run arc tests
		print("\nRunning arc calculation tests...")
--        testArcCalculations()
	elseif key == "escape" then
		love.event.quit()
	end
end

-- handle mouse input for interactive placement (optional)
function love.mousepressed(x, y, button)
	if button == 1 then -- left click
		-- move start point
		start.x, start.y = x, y
		print(string.format("New start: (%.0f, %.0f)", x, y))
		-- auto-restart pathfinding
		path, diagram = pathfinding (circles, start, goal)
		currentDebugIndex = 1
	elseif button == 2 then -- right click
		-- move goal point
		goal.x, goal.y = x, y
		print(string.format("New goal: (%.0f, %.0f)", x, y))
		-- auto-restart pathfinding
		path, diagram = pathfinding.circularObstaclePathfinding(circles, start, goal)
		currentDebugIndex = 1
	end
end