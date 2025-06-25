-- main.lua
Vessel = require("vessel")
PolyPath = require("polypath")

-- duration of each movement execution in seconds
local DAY_DURATION = 2
-- delay before planning next move in seconds
local PLANNING_DELAY = 0.5

-- waypoints for vessel movement example

local waypoints = {
	{x = 300, y = 400},
	{x = 300, y = 200},
	{x = 500, y = 400},
	{x = 500, y = 200}
}

-- example game states
local states = {
	PLANNING = "planning",
	WAITING = "waiting",
	EXECUTING = "executing"
}

local ship = nil            -- player vessel
local currentState = states.PLANNING  -- current game state
local currentWaypointIndex = 1  -- index of current target waypoint
local timer = 0            -- time accumulator
local executionProgress = 0 -- progress of current execution (0-1)

-- initialize game
function love.load()
	-- create vessel at first waypoint
	local startX, startY = waypoints[1].x, waypoints[1].y
	ship = Vessel.new(startX, startY, 0, 18)
	currentWaypointIndex = 1

	-- set initial target and state
	ship:setTarget(waypoints[currentWaypointIndex])
	currentState = states.WAITING
	timer = 0
end

-- update game state
function love.update(dt)
	timer = timer + dt

	-- waiting state: delay before planning
	if currentState == states.WAITING then
		if timer >= PLANNING_DELAY then
			currentState = states.PLANNING
			timer = 0
			-- move to next waypoint (loop to first after last)
			currentWaypointIndex = currentWaypointIndex % #waypoints + 1
			ship:setTarget(waypoints[currentWaypointIndex])
		end

		-- planning state: prepare for execution
	elseif currentState == states.PLANNING then
		currentState = states.EXECUTING
		executionProgress = 0
		timer = 0

		-- executing state: animate vessel movement
	elseif currentState == states.EXECUTING then
		executionProgress = executionProgress + dt / DAY_DURATION

		-- check if execution completed
		if executionProgress >= 1 then
			executionProgress = 1
			currentState = states.WAITING
			timer = 0
		end

		-- update vessel position
		ship:update(executionProgress)
	end
end

-- render game
function love.draw()
	-- draw planned path
	love.graphics.setColor(1, 1, 1, 1)
	ship.currentPath:draw()

	-- draw current target waypoint
	local target = waypoints[currentWaypointIndex]
	love.graphics.setColor(1, 1, 1)
	love.graphics.circle("fill", target.x, target.y, 3)

	-- draw vessel
	love.graphics.setColor(1, 1, 1, 1)
	ship:draw(20)
end

-- handle keyboard input
function love.keypressed(key)
	-- space key: advance game state
	if key == "space" then
		-- skip waiting delay
		if currentState == states.WAITING then
			timer = PLANNING_DELAY
			-- skip to end of execution
		elseif currentState == states.EXECUTING then
			executionProgress = 1
		end
	end
end