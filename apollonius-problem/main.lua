local apollonius = require("apollonius")
local geom = require("apollonius-geom")

-- define all tasks
local tasks = {
	{
		name = 'PPP',
		points = {
			{x=200, y=300},
			{x=400, y=100},
			{x=600, y=350}
		},
		solutions = {},
	},
	{
		name = 'PPL',
		points = {
			{x=400, y=280},
			{x=400, y=320},
		},
		lines = {
			{x1=100, y1=200, x2=700, y2=250},
		},
		solutions = {},
	},
	{
		name = 'PLL',
		points = {{x=400, y=300}},
		lines = {
			{x1=100, y1=200, x2=700, y2=250},
			{x1=100, y1=450, x2=700, y2=400}
		},
		solutions = {},
	},
	{
		name = 'LLL',
		lines = {
			{x1=100, y1=500, x2=500, y2=100},
			{x1=300, y1=100, x2=700, y2=600},
			{x1=100, y1=300, x2=700, y2=400}
		},
		solutions = {},
	},
	{
		name = 'CLL',
		circles = {
			{x=500, y=300, r=80}
		},
		lines = {
			{x1=100, y1=400, x2=700, y2=100},
			{x1=100, y1=200, x2=700, y2=500},
		},
	},
	{
		name = 'CPP',
		circles = {
			{x=410, y=100, r=60}
		},
		points = {
			{x=300, y = 300},
			{x=500, y = 310},
		},
		solutions = {},
	},
}

-- current task index
local currentTaskIndex = 6

-- recompute solutions for current task
local function recalcSolution()
	local task = tasks[currentTaskIndex]

	if task.name == "PPP" then
		task.solutions = apollonius.solvePPP(task.points[1], task.points[2], task.points[3])
	elseif task.name == "PPL" then
		task.solutions = apollonius.solvePPL(task.points[1], task.points[2], task.lines[1])
	elseif task.name == "PLL" then
		task.solutions = apollonius.solvePLL(task.points[1], task.lines[1], task.lines[2])
	elseif task.name == "LLL" then
		task.solutions = apollonius.solveLLL(task.lines[1], task.lines[2], task.lines[3])
	elseif task.name == "CLL" then
		task.solutions = apollonius.solveCLL(task.circles[1], task.lines[1], task.lines[2])
	elseif task.name == "CPP" then
		task.solutions = apollonius.solveCPP(task.circles[1], task.points[1], task.points[2])
	end
end

function love.load()
	recalcSolution()
end

function love.draw()
	love.graphics.setBackgroundColor(1,1,1)
	local task = tasks[currentTaskIndex]

	-- draw points
	love.graphics.setColor(1,0,0)
	if task.points then
		for _, p in ipairs(task.points) do
			love.graphics.circle("fill", p.x, p.y, 5)
		end
	end

	-- draw circles
	if task.circles then
		love.graphics.setColor(0,0,0)
		for _, c in ipairs(task.circles) do
			love.graphics.circle('line', c.x, c.y, c.r)
			love.graphics.circle('fill', c.x, c.y, 3)
		end
	end

	-- draw lines
	if task.lines then
		love.graphics.setColor(0,0,0)
		for _, l in ipairs(task.lines) do
			love.graphics.line(l.x1, l.y1, l.x2, l.y2)
			love.graphics.circle('line', l.x1, l.y1, 6)
			love.graphics.circle('fill', l.x2, l.y2, 6)
		end
	end

	-- draw solutions
	love.graphics.setColor(0,0,1)
	for _, c in ipairs(task.solutions) do
		love.graphics.circle("line", c.x, c.y, c.r)
		love.graphics.circle("fill", c.x, c.y, 3)
	end

	-- draw labels
	love.graphics.setColor(0,0,0)
	love.graphics.print("Task ".. currentTaskIndex ..": "..task.name, 10, 10)
	love.graphics.print("Solutions: ".. #task.solutions, 10, 30)
end

function love.keypressed(key)
	-- switch between tasks
	if key == "space" then
		currentTaskIndex = currentTaskIndex % #tasks + 1
		recalcSolution()
	end
end

function love.mousemoved(x, y)
	-- interactive task update
	local task = tasks[currentTaskIndex]

	if task.name == "PPP" then
		local point = task.points[3]
		point.x, point.y = x, y
		recalcSolution()

	elseif task.name == "PPL" then
		local line = task.lines[1]
		line.x2, line.y2 = x, y
		geom.lineFromTwoPointsCoords(line)
		recalcSolution()

	elseif task.name == "PLL" then
		local line = task.lines[2]
		line.x2, line.y2 = x, y
		line.a = nil
		geom.lineFromTwoPointsCoords(line)
		recalcSolution()

	elseif task.name == "LLL" then
		local line = task.lines[3]
		line.x2, line.y2 = x, y
		line.a = nil
		geom.lineFromTwoPointsCoords(line)
		recalcSolution()

	elseif task.name == "CLL" then
		local circle = task.circles[1]
		circle.x, circle.y = x, y
		recalcSolution()

	elseif task.name == "CPP" then
		local circle = task.circles[1]
		circle.x, circle.y = x, y
		recalcSolution()
	end
end
