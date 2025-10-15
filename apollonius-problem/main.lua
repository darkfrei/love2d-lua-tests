local apollonius = require("apollonius")
local geom = require("apollonius-geom")

-- задачи
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
		name = 'PLL',
		points = {{x=400, y=300}},
		lines = {
			{x1=100, y1=200, x2=700, y2=250},
			{x1=100, y1=450, x2=700, y2=400}
		},
		solutions = {},
	},
}

local currentTaskIndex = 1

local function recalcSolution()
	local task = tasks[currentTaskIndex]

	if task.name == "PPP" then
		task.solutions = apollonius.solvePPP(task.points[1], task.points[2], task.points[3])
	elseif task.name == "PLL" then
		
		task.solutions = apollonius.solvePLL(task.points[1], task.lines[1], task.lines[2])
	end
end

function love.load()
	recalcSolution()
end

function love.draw()
	love.graphics.setBackgroundColor(1,1,1)
	local task = tasks[currentTaskIndex]

	-- рисуем точки
	love.graphics.setColor(1,0,0)
	for _, p in ipairs(task.points) do
		love.graphics.circle("fill", p.x, p.y, 5)
	end

	-- рисуем линии (для PLL)
	if task.lines then
		love.graphics.setColor(0,0,0)
		for _, l in ipairs(task.lines) do
			love.graphics.line(l.x1, l.y1, l.x2, l.y2)
			love.graphics.circle('line', l.x1, l.y1, 6)
			love.graphics.circle('fill', l.x2, l.y2, 6)
		end
	end

	-- рисуем решения
	love.graphics.setColor(0,0,1)
	for _, c in ipairs(task.solutions) do
		love.graphics.circle("line", c.x, c.y, c.r)
	end

	-- подпись
	love.graphics.setColor(0,0,0)
	love.graphics.print("Task: "..task.name, 10, 10)
end

function love.keypressed(key)
	if key == "space" then
		currentTaskIndex = currentTaskIndex % #tasks + 1
		recalcSolution()
	end
end

function love.mousemoved(x, y)
	local task = tasks[currentTaskIndex]
	if task.name == "PPP" then
		local point = task.points[3]
		
		point.x = x
		point.y = y
		recalcSolution()
		
	elseif task.name == "PLL" then
		local line = task.lines[2]
		line.a = nil
		
		line.x2 = x
		line.y2 = y
		geom.lineFromTwoPointsCoords(line)
		recalcSolution()
	end
end