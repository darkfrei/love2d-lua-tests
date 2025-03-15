-- main.lua
local ViewScale = require("viewscale") -- load the scaling library

local lastTime = 0
local maxTime = 4
local pressedPoints = {}

function love.load()
	ViewScale.load()
end

function love.update(dt)
	local currentTime = lastTime + dt
	if currentTime > maxTime then
		currentTime = currentTime - maxTime
	end
	lastTime = currentTime
end

function love.mousepressed(x, y, button, istouch, presses)
	-- adjust mouse coordinates to scale and offset
	local adjustedX, adjustedY = ViewScale.mouseToScaled(x, y)

	print("Mouse clicked at adjusted position: (" .. adjustedX .. ", " .. adjustedY .. ")")

	table.insert (pressedPoints, {x=adjustedX, y=adjustedY})
end

function love.resize(w, h)
	ViewScale.resize(w, h)
end

function love.draw()
	ViewScale.push()
	-- game rendering:
	-- set background color
	love.graphics.setColor(88/255, 88/255, 200/255)
	love.graphics.rectangle("fill", 0, 0, 1280, 800)

	love.graphics.setColor(1,1,1)
	for i, p in ipairs (pressedPoints) do
		love.graphics.circle ('line', p.x, p.y, 5)
	end
	ViewScale.pop()

	-- GUI rendering:
	-- draw the progress bar
	local progress = lastTime / maxTime
	local barWidth = 400
	local barHeight = 20
	local x = (love.graphics.getWidth() - barWidth) / 2
	local y = love.graphics.getHeight() - 50

	-- background of the progress bar
	love.graphics.setColor(0.2, 0.2, 0.2)
	love.graphics.rectangle("fill", x, y, barWidth, barHeight)

	-- color of the progress
	love.graphics.setColor(0.2, 0.8, 0.2)
	love.graphics.rectangle("fill", x, y, barWidth * progress, barHeight)

	-- display the current time and duration in seconds
	love.graphics.setColor(1, 1, 1)
	love.graphics.print(string.format("Time: %.1f / %.1f sec", lastTime, maxTime), x + barWidth + 10, y)
end

