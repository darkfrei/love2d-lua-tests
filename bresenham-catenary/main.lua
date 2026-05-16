-- main.lua
-- fixed-length catenary chain with stable endpoint rendering (geometry-driven endpoint only)

local catenary = require("catenary")
local bresenham = require("universal-bresenham")

local state = {}
local renderScale = 5
local canvas = nil

-- cached chain result (prevents recomputation)
local cached = {
	key    = nil,
	points = nil,
	nadirX = nil,
	nadirY = nil,
	endX   = nil,
	endY   = nil,
}

local function clamp(v, lo, hi)
	return math.max(lo, math.min(hi, v))
end

local function dist2(ax, ay, bx, by)
	local dx = ax - bx
	local dy = ay - by
	return dx * dx + dy * dy
end

--
-- canvas setup
--

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

		chainLength = 100,
		lengthMin   = 50,
		lengthMax   = 2000,
		lengthStep  = 10,

		showGrid  = true,
		showNadir = true,

		dragging = nil,
	}
end

--
-- cache key
--

local function makeKey(s)
	return table.concat({ s.ax, s.ay, s.bx, s.by, s.chainLength }, ":")
end

--
-- vertical helper
--

local function verticalPixels(x, yFrom, yTo)
	local pts  = {}
	local step = (yTo >= yFrom) and 1 or -1

	for y = yFrom, yTo, step do
		pts[#pts + 1] = { x = x, y = y }
	end

	return pts
end

--
-- chain builder — always starts from A, never exceeds chainLength
--

local function buildChainPixels(s)
	local key = makeKey(s)

	if cached.key == key then
		return cached.points, cached.nadirX, cached.nadirY, cached.endX, cached.endY
	end

	local dx = s.bx - s.ax
	local dy = s.by - s.ay

	local straight = math.sqrt(dx * dx + dy * dy)
	local len      = s.chainLength

	-- chain too short → truncated segment from A towards B
	if len < straight then
		local t  = len / math.max(straight, 1e-6)
		local ex = math.floor(s.ax + dx * t + 0.5)
		local ey = math.floor(s.ay + dy * t + 0.5)

		local pixels

		if math.abs(ex - s.ax) < 1 then
			-- vertical truncation
			pixels = verticalPixels(
				s.ax,
				math.min(s.ay, ey),
				math.max(s.ay, ey)
			)
		else
			local slope = (ey - s.ay) / (ex - s.ax)

			local function lineF(x)
				return s.ay + slope * (x - s.ax)
			end

			pixels = bresenham.rasterizeFunction(
				lineF,
				math.min(s.ax, ex),
				math.max(s.ax, ex)
			)
		end

		local last = pixels[#pixels]

		cached.key    = key
		cached.points = pixels
		cached.nadirX = nil
		cached.nadirY = nil
		cached.endX   = last and last.x
		cached.endY   = last and last.y

		return pixels, nil, nil, cached.endX, cached.endY
	end

	-- vertical chain special case
	if math.abs(dx) < 1 then
		local midY    = (s.ay + s.by) * 0.5 + len * 0.5
		local yTop    = math.min(s.ay, s.by)
		local yBottom = math.floor(midY + 0.5)

		local pixels = verticalPixels(s.ax, yTop, yBottom)
		local last   = pixels[#pixels]

		cached.key    = key
		cached.points = pixels
		cached.nadirX = s.ax
		cached.nadirY = yBottom
		cached.endX   = last and last.x
		cached.endY   = last and last.y

		return pixels, s.ax, yBottom, cached.endX, cached.endY
	end

	-- true catenary curve from A to B
	local f, nadirX, nadirY = catenary.buildFunction(
		s.ax, s.ay,
		s.bx, s.by,
		len
	)

	local pixels = bresenham.rasterizeFunction(
		f,
		math.min(s.ax, s.bx),
		math.max(s.ax, s.bx)
	)

	local last = pixels[#pixels]

	cached.key    = key
	cached.points = pixels
	cached.nadirX = nadirX
	cached.nadirY = nadirY
	cached.endX   = last and last.x
	cached.endY   = last and last.y

	return pixels, nadirX, nadirY, cached.endX, cached.endY
end

--
-- rendering
--

local function drawChain(s)
	local pixels, nadirX, nadirY = buildChainPixels(s)

	if not pixels or #pixels < 2 then return end

	local flat = {}
	for i = 1, #pixels do
		local p = pixels[i]
		flat[#flat + 1] = p.x
		flat[#flat + 1] = p.y
	end

	love.graphics.setColor(0.35, 0.85, 1, 1)
	love.graphics.points(flat)

	if state.showNadir and nadirX and nadirY then
		love.graphics.setColor(1, 0.85, 0.2, 0.6)
		love.graphics.points(
			math.floor(nadirX + 0.5),
			math.floor(nadirY + 0.5)
		)
	end
end

--
-- grid and anchors
--

local function drawGrid(w, h)
	local step = 10
	love.graphics.setColor(0.18, 0.18, 0.25, 1)

	for x = 0, w, step do love.graphics.line(x, 0, x, h) end
	for y = 0, h, step do love.graphics.line(0, y, w, y) end
end

local function drawAnchors(s)
	-- dashed line between anchors
	love.graphics.setColor(0.55, 0.55, 0.7, 0.4)
	love.graphics.line(s.ax, s.ay, s.bx, s.by)

	-- point A — red (fixed)
	love.graphics.setColor(1, 0.3, 0.3, 1)
	love.graphics.points({
			s.ax,     s.ay,
			s.ax - 1, s.ay,
			s.ax + 1, s.ay,
		})

	-- point B — green (draggable)
	love.graphics.setColor(0.3, 1, 0.4, 1)
	love.graphics.points({
			s.bx,     s.by,
			s.bx - 1, s.by,
			s.bx + 1, s.by,
		})

	-- green circle around the last point of the chain
	if cached.endX and cached.endY then
		love.graphics.setColor(0.3, 1, 0.4, 0.9)
		love.graphics.circle("line", cached.endX, cached.endY, 12)
	end
end

--
-- LOVE lifecycle
--

function love.load()
	love.window.setTitle("catenary fixed length (stable endpoint)")
	love.window.setMode(800, 600, { resizable = true })

	createCanvas()
	resetState()
end

function love.resize()
	createCanvas()
	resetState()
	cached.key = nil
end

--
-- input — only B is draggable
--

function love.mousepressed(x, y, button)
	if button ~= 1 then return end

	local sx = math.floor(x / renderScale)
	local sy = math.floor(y / renderScale)

	local threshold = 12 * 12

	if dist2(sx, sy, state.bx, state.by) <= threshold then
		state.dragging = "b"
	end
end

function love.mousereleased(_, _, button)
	if button ~= 1 then return end
	state.dragging = nil
end

function love.mousemoved(x, y)
	if not state.dragging then return end

	local sx = math.floor(x / renderScale)
	local sy = math.floor(y / renderScale)

	state.bx, state.by = sx, sy
	cached.key = nil
end

function love.wheelmoved(_, dy)
	state.chainLength = clamp(
		state.chainLength + dy * state.lengthStep,
		state.lengthMin,
		state.lengthMax
	)

	cached.key = nil
end

--
-- render loop
--

function love.draw()
	local w = canvas:getWidth()
	local h = canvas:getHeight()

	love.graphics.setCanvas(canvas)
	love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(0.899)
	love.graphics.clear(0.07, 0.07, 0.12, 1)

	drawGrid(w, h)
--	if state.showGrid then drawGrid(w, h) end

	drawChain(state)
	drawAnchors(state)

	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(canvas, 0, 0, 0, renderScale, renderScale)
end