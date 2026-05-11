-- main.lua
-- Bresenham parabola with pixel-perfect 5x rendering

local Parabola = require("parabola")

local state = {}

local renderScale = 5
local canvas = nil

local function clamp(value, minValue, maxValue)
	return math.max(minValue, math.min(maxValue, value))
end

local function createCanvas()
	local width = math.floor(love.graphics.getWidth() / renderScale)
	local height = math.floor(love.graphics.getHeight() / renderScale)

	canvas = love.graphics.newCanvas(width, height)
	canvas:setFilter("nearest", "nearest")

	love.graphics.setDefaultFilter("nearest", "nearest")
end

local function resetState()
	state = {
		cx = 90,
		cy = 120,

		p = 12,
		pMin = 2,
		pMax = 80,

		dotSize = 1,

		showSmooth = false,
		showGrid = true,

		dragging = false,
		dragOffsetX = 0,
		dragOffsetY = 0,
	}
end

local function drawGrid(cx, cy, w, h)
	local spacing = 10

	love.graphics.setColor(0.18, 0.18, 0.25, 1)

	local offsetX = cx % spacing
	for x = offsetX, w, spacing do
		love.graphics.line(x, 0, x, h)
	end

	local offsetY = cy % spacing
	for y = offsetY, h, spacing do
		love.graphics.line(0, y, w, y)
	end

	love.graphics.setColor(0.3, 0.3, 0.45, 1)
	love.graphics.line(0, cy, w, cy)
	love.graphics.line(cx, 0, cx, h)
end

local function drawFocus(cx, cy, p)
	local fx, fy = cx, cy - p

	love.graphics.setColor(1, 0.85, 0.2, 1)
	love.graphics.points(fx, fy)

	love.graphics.setColor(1, 0.85, 0.2, 0.4)
	love.graphics.line(0, cy + p, canvas:getWidth(), cy + p)
end

local function drawHud()
	love.graphics.setColor(0, 0, 0, 0.6)
	love.graphics.rectangle("fill", 2, 2, 70, 45)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("p: " .. math.floor(state.p), 4, 4)
	love.graphics.print("fps: " .. love.timer.getFPS(), 4, 14)
	love.graphics.print("scale 5x", 4, 24)
end

function love.load()
	love.window.setTitle("Bresenham Parabola 5x Pixel Render")
	love.window.setMode(900, 700, { resizable = true })

	love.graphics.setDefaultFilter("nearest", "nearest")

	createCanvas()
	resetState()
end

function love.resize()
	createCanvas()
	resetState()
end

function love.keypressed(key)
	if key == "r" then
		resetState()
	elseif key == "s" then
		state.showSmooth = not state.showSmooth
	elseif key == "g" then
		state.showGrid = not state.showGrid
	elseif key == "=" or key == "+" then
		state.dotSize = clamp(state.dotSize + 1, 1, 4)
	elseif key == "-" then
		state.dotSize = clamp(state.dotSize - 1, 1, 4)
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.wheelmoved(_, dy)
	state.p = clamp(state.p + dy, state.pMin, state.pMax)
end

function love.mousepressed(x, y, button)
	if button ~= 1 then return end

	x = math.floor(x / renderScale)
	y = math.floor(y / renderScale)

	state.dragging = true
	state.dragOffsetX = x - state.cx
	state.dragOffsetY = y - state.cy
end

function love.mousereleased(_, _, button)
	if button == 1 then
		state.dragging = false
	end
end

function love.mousemoved(x, y)
	if not state.dragging then return end

	x = math.floor(x / renderScale)
	y = math.floor(y / renderScale)

	state.cx = x - state.dragOffsetX
	state.cy = y - state.dragOffsetY
end

function love.draw()
	local w = canvas:getWidth()
	local h = canvas:getHeight()

	love.graphics.setCanvas(canvas)
	love.graphics.clear(0.07, 0.07, 0.12, 1)

	if state.showGrid then
		drawGrid(state.cx, state.cy, w, h)
	end

	drawFocus(state.cx, state.cy, state.p)

	local maxX = math.max(w - state.cx, state.cx)

	if state.showSmooth then
		love.graphics.setColor(1, 0.35, 0.35, 1)
		Parabola.drawSmooth(state.cx, state.cy, state.p, maxX)
	end

	love.graphics.setColor(0.35, 0.85, 1, 1)
	Parabola.draw(state.cx, state.cy, state.p, maxX, state.dotSize)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.points(state.cx, state.cy)

	drawHud()

	love.graphics.setCanvas()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(canvas, 0, 0, 0, renderScale, renderScale)
end