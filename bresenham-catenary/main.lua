-- main.lua
-- catenary chain rendered via function-based Bresenham rasterization

local catenary = require("catenary")
local bresenham = require("universal-bresenham")

local state = {}

local renderScale = 5
local canvas = nil

-- clamp helper
local function clamp(v, lo, hi)
	return math.max(lo, math.min(hi, v))
end

-- squared distance
local function dist2(ax, ay, bx, by)
	local dx = ax - bx
	local dy = ay - by
	return dx * dx + dy * dy
end

local function createCanvas()
	local w = math.floor(love.graphics.getWidth() / renderScale)
	local h = math.floor(love.graphics.getHeight() / renderScale)

	canvas = love.graphics.newCanvas(w, h)
	canvas:setFilter("nearest", "nearest")
	love.graphics.setDefaultFilter("nearest", "nearest")
end

local function resetState()
	local w = canvas:getWidth()
	local h = canvas:getHeight()

	state = {
		ax = math.floor(w * 0.25),
		ay = math.floor(h * 0.38),
		bx = math.floor(w * 0.75),
		by = math.floor(h * 0.38),

		slackFactor = 1.35,
		slackMin = 1.001,
		slackMax = 6.0,
		slackStep = 0.02,

		showGrid = true,
		showSmooth = false,
		showInfo = true,

		dragging = nil,
		dragOffsetX = 0,
		dragOffsetY = 0,
	}
end

-- rasterize catenary directly from function
local function buildCatenaryPixels(s)
	local dx = s.bx - s.ax
	local dy = s.by - s.ay

	local straight = math.sqrt(dx * dx + dy * dy)
	local len = straight * s.slackFactor

	local f = catenary.buildFunction(
		s.ax, s.ay,
		s.bx, s.by,
		len
	)

	local xStart = math.min(s.ax, s.bx)
	local xEnd = math.max(s.ax, s.bx)

	local pixels = bresenham.rasterizeFunction(f, xStart, xEnd)

	return pixels, len, straight
end

local function drawChain(s)
	local pixels, len, straight = buildCatenaryPixels(s)

	if not pixels or #pixels < 2 then
		return nil
	end

	-- convert to flat array for love.graphics.points
	local flat = {}

	for i = 1, #pixels do
		local p = pixels[i]
		if p and p.x and p.y then
			flat[#flat + 1] = p.x
			flat[#flat + 1] = p.y
		end
	end

	love.graphics.setColor(0.35, 0.85, 1, 1)
	love.graphics.points(flat)

	local lowest = nil

	for _, p in ipairs(pixels) do
		if p and p.x and p.y then
			if not lowest or p.y > lowest.y then
				lowest = p
			end
		end
	end

	if not lowest then
		return nil
	end

	return lowest, len, straight
end

local function drawGrid(w, h)
	local step = 10
	love.graphics.setColor(0.18, 0.18, 0.25, 1)

	for x = 0, w, step do
		love.graphics.line(x, 0, x, h)
	end

	for y = 0, h, step do
		love.graphics.line(0, y, w, y)
	end
end

local function drawAnchors(s)
	love.graphics.setColor(0.55, 0.55, 0.7, 0.4)
	love.graphics.line(s.ax, s.ay, s.bx, s.by)

	love.graphics.setColor(1, 0.85, 0.2, 1)
	love.graphics.points({
			s.ax, s.ay,
			s.ax - 1, s.ay,
			s.ax + 1, s.ay,
			s.bx, s.by,
			s.bx - 1, s.by,
			s.bx + 1, s.by,
		})
end

local function drawNadir(lowest)
	if not lowest or type(lowest.x) ~= "number" or type(lowest.y) ~= "number" then
		return
	end

	local nx = math.floor(lowest.x + 0.5)
	local ny = math.floor(lowest.y + 0.5)

	love.graphics.setColor(1, 0.85, 0.2, 0.3)
--	love.graphics.line(nx, 0, nx, canvas:getHeight())

	love.graphics.setColor(1, 0.85, 0.2, 1)
	love.graphics.points(nx, ny)
end

function love.load()

	love.window.setTitle("Catenary Function, Bresenham Raster")
	love.window.setMode(800, 600, { resizable = true })

	love.graphics.setLineStyle( "rough" )


	createCanvas()
	resetState()
end

function love.resize()
	createCanvas()
	resetState()
end

function love.mousepressed(x, y, button)
	if button ~= 1 then return end

	local sx = math.floor(x / renderScale)
	local sy = math.floor(y / renderScale)

	local da = dist2(sx, sy, state.ax, state.ay)
	local db = dist2(sx, sy, state.bx, state.by)

	local threshold = 20 * 20

	if da <= threshold or db <= threshold then
		local which = (da < db) and "a" or "b"
		state.dragging = which
	end
end

function love.mousereleased(x, y, button)
	if button == 1 then state.dragging = nil end
end

function love.mousemoved(x, y)
	if not state.dragging then return end

	local sx = math.floor(x / renderScale)
	local sy = math.floor(y / renderScale)

	if state.dragging == "a" then
		state.ax, state.ay = sx, sy
	else
		state.bx, state.by = sx, sy
	end
end

function love.wheelmoved(dx, dy)
	state.slackFactor = clamp(
		state.slackFactor + dy * state.slackStep,
		state.slackMin,
		state.slackMax
	)
end

function love.draw()
	local w = canvas:getWidth()
	local h = canvas:getHeight()

	love.graphics.setCanvas(canvas)
	love.graphics.clear(0.07, 0.07, 0.12, 1)

	if state.showGrid then
		drawGrid(w, h)
	end

	local lowest, len, str = drawChain(state)

	drawAnchors(state)
	drawNadir(lowest)

	love.graphics.setCanvas()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(canvas, 0, 0, 0, renderScale, renderScale)
end