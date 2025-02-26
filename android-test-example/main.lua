local screen = require "android-screen"

local nativeScreen = {w=1280, h=800}

function love.load()
	screen.init()
	screen.setRenderSize(nativeScreen.w, nativeScreen.h)  -- set render size
--    screen.setWindowSize(1920, 1080) -- set window size
end

function love.resize(windowWidth, windowHeight)
	screen.resize(windowWidth, windowHeight)
end

points = {}

function love.mousepressed(x, y, button, istouch, presses)
	local renderX, renderY = screen.toRenderCoordinates(x, y)
	
	table.insert (points, renderX)
	table.insert (points, renderY)
end

function love.draw()
	local mx, my = love.mouse.getPosition()
	local rx, ry = screen.toRenderCoordinates(mx, my)
	local w, h = nativeScreen.w, nativeScreen.h

	-- apply the custom transform
	love.graphics.push()
	love.graphics.applyTransform(screen.transform)

	-- draw the rectangle and diagonals
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle("line", 0, 0, w, h)
	love.graphics.line(0, 0, w, h)
	love.graphics.line(w, 0, 0, h)

	-- draw the mouse position as green lines
	love.graphics.setColor(0, 1, 0)
	love.graphics.line(0, ry, w, ry)
	love.graphics.line(rx, 0, rx, h)

	love.graphics.setColor(1, 1, 1)
	love.graphics.points (points)

	love.graphics.pop()
end
