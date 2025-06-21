local polypath = require('polypath')
local utils = require("utils")

love.graphics.setLineStyle ('rough')
love.graphics.setLineWidth (3)


-- initializing game
function love.load()
	love.window.setTitle("Space Rangers 2 Style")
	love.window.setMode(800, 600)

	-- defining player
	player = {
		x = 400,  -- center of screen
		y = 300,
		length = 20,
		radius = 20,
		speed = 100,  -- 10 units of distance per turn (200 pixels per turn)
		energy = 100,
		maxEnergy = 100,
		targetX = nil,
		targetY = nil,
		polyline = {
			points = {},  -- list of points from polypath
			currentSegmentIndex = 1,
			currentSegment = nil  -- will be set by polypath
		},
		startX = nil,
		startY = nil,
		angle = 0,   -- facing direction in radians
		triangle = {},
		currentDistance = 0,
		energyCostMultiplier = 1
	}

	player.triangle = {
		player.x + player.length * math.cos(player.angle),
		player.y + player.length * math.sin(player.angle),
		player.x + player.length * 0.5 * math.cos(player.angle + 2 * math.pi / 3),
		player.y + player.length * 0.5 * math.sin(player.angle + 2 * math.pi / 3),
		player.x + player.length * 0.5 * math.cos(player.angle - 2 * math.pi / 3),
		player.y + player.length * 0.5 * math.sin(player.angle - 2 * math.pi / 3)
	}



	-- setting up camera
	camera = {
		x = player.x,
		y = player.y,
		targetX = player.x,
		targetY = player.y,
		smoothness = 0.8,  -- camera follow smoothness
		lookAheadDistance = 150,  -- how far ahead to look
		lookAheadFactor = 0.6  -- 0 = no lookahead, 1 = full lookahead
	}

	-- setting up grid
	gridSize = 50

	-- initializing game state
	score = 0
	turn = 0
	gameState = "planning"  -- "planning", "selecting", "animating"
	animationTime = 0
	animationDuration = 0  -- now in seconds

	-- setting up debug
	clickX = nil
	clickY = nil

	-- defining constants
	pixelsPerUnit = 50  -- 1 unit of distance = 20 pixels
	timePerTurn = 60   -- 1 turn = 60 time units
	animationSpeed = 1  -- 1 second per unit distance
	segmentLength = 20   -- fixed length for all segments

---------------------------------------
---------------------------------------
---------------------------------------
	-- test
	player.targetX = 100
	player.targetY = 300
	calculatePath()
end

-- updating game state
function love.update(dt)
	-- calculate look-ahead point based on player direction
	local lookAheadX = player.x + math.cos(player.angle) * camera.lookAheadDistance
	local lookAheadY = player.y + math.sin(player.angle) * camera.lookAheadDistance

	-- interpolate between player position and look-ahead point
	camera.targetX = player.x + (lookAheadX - player.x) * camera.lookAheadFactor
	camera.targetY = player.y + (lookAheadY - player.y) * camera.lookAheadFactor

	-- apply smooth camera follow
	camera.x = camera.x + (camera.targetX - camera.x) * dt / camera.smoothness
	camera.y = camera.y + (camera.targetY - camera.y) * dt / camera.smoothness


	---------------------

	if gameState == "animating" then
--		animationTime = animationTime + dt
		local deltaDistance = player.speed * dt	
		player.currentDistance = player.currentDistance + deltaDistance

		local energyCost = (deltaDistance / pixelsPerUnit) * player.energyCostMultiplier
		player.energy = math.max(0, player.energy - energyCost)

		-- check if movement completed
		if player.energy <=0 then
			gameState = "game over"
			turn = turn + 1
			return
		end

		if player.currentDistance >= player.path.totalLength then
			player.currentDistance = 0
			gameState = "planning"

			player.lastPath = player.path
			player.path = nil
			turn = turn + 1
		else
			-- get current position
			local x, y, angle = player.path:getPointAtDistance(player.currentDistance)
			player.x = x
			player.y = y
			player.angle = angle
		end
	end

	-- update player triangle (always)
	player.triangle = {
		player.x + player.length * math.cos(player.angle),
		player.y + player.length * math.sin(player.angle),
		player.x + player.length * 0.5 * math.cos(player.angle + 2 * math.pi / 3),
		player.y + player.length * 0.5 * math.sin(player.angle + 2 * math.pi / 3),
		player.x + player.length * 0.5 * math.cos(player.angle - 2 * math.pi / 3),
		player.y + player.length * 0.5 * math.sin(player.angle - 2 * math.pi / 3)
	}
end

-- handling mouse clicks
function love.mousepressed(x, y, button)
--	print("Mouse pressed at:", x, y, "button:", button, "gameState:", gameState)

	if button == 1 then
		if gameState == "planning" then
			player.targetX = (x - 400) + camera.x
			player.targetY = (y - 300) + camera.y
--			print("Calculated target:", player.targetX, player.targetY)
			calculatePath()

		elseif gameState == "selecting" then
--			print("Entering selecting state")
			-- Calculate duration based on total distance
			local totalDistance = player.path.totalLength

--			animationDuration = totalDistance / (player.speed * animationSpeed)
--			print("Calculated animationDuration:", animationDuration)
			gameState = "animating"
--			animationTime = 0
--			print("Changed gameState to animating")


		elseif gameState == "animating" then

		end
	end
end

-- drawing game
function love.draw()
	-- shifting coordinates for camera
	love.graphics.push()
	love.graphics.translate(400 - camera.x, 300 - camera.y)

	-- drawing grid
	love.graphics.setColor(0.2, 0.2, 0.2)
	for x = -400, 800, gridSize do
		love.graphics.line(x, -300, x, 600)
	end
	for y = -300, 600, gridSize do
		love.graphics.line(-400, y, 800, y)
	end

	-- drawing player (triangle arrow)
	love.graphics.setColor(0, 1, 0)
	love.graphics.polygon("fill", player.triangle)

	-- draw lastPath
	local c = 0.75
	love.graphics.setColor(c, c, c, c)
	local lastPath = player.lastPath
	if lastPath then
		for i, point in ipairs(lastPath.points) do
			love.graphics.circle("fill", point.x, point.y, 3)
		end
	end

	-- displaying movement trajectory (visible during animation)
--	if (gameState == "selecting" or gameState == "animating") and player.targetX and #player.path.points > 0 then

	-- draw path
	local path = player.path


	if path  then

		if path.circle then
			love.graphics.setColor(0, 1, 1, 0.5)
--			love.graphics.circle("line", path.circle.x, path.circle.y, path.circle.radius)
		end
		
		love.graphics.setColor(0, 1, 1)
		for i, point in ipairs(path.points) do
			love.graphics.circle("fill", point.x, point.y, 3)
		end
	end
	love.graphics.circle("line", player.targetX, player.targetY, 4)

--	end

	love.graphics.pop()

	-- displaying interface (fixed on screen)
	love.graphics.setColor(1, 1, 1)
--	love.graphics.print("Score: " .. score, 10, 10)
	love.graphics.print("Turn: " .. turn, 10, 30)
	love.graphics.print("Energy: " .. player.energy, 10, 50)
	love.graphics.print("Phase: " .. gameState, 10, 70)
--	love.graphics.print("Target: " .. (player.targetX and math.floor(player.targetX) or "nil") .. ", " .. (player.targetY and math.floor(player.targetY) or "nil"), 10, 110)
end

-- calculating trajectory as polyline using polypath
function calculatePath()
	player.startX = player.x
	player.startY = player.y
	gameState = "selecting"

	player.path = polypath.calculatePath(player.x, player.y, player.targetX, player.targetY, player.angle, segmentLength)
end