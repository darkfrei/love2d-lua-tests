-- main.lua
-- single-function catenary module:
-- catenary(x1, y1, x2, y2, L, steps)
local catenary = require("catenary")

local state = {}
local function clamp(v, a, b) return math.max(a, math.min(b, v)) end

local function reset()
	state = {
		anchor1 = { x = 350, y = 400 },
		anchor2 = { x = 500, y = 300 },
		chainLength = 200,
--      minLength = 120,
--      maxLength = 2000,
		draggingAnchor = nil,
		dragOffsetX = 0,
		dragOffsetY = 0,
		showGrid = true,
		steps = 160,
	}
end

function love.load()
	love.window.setMode(900, 700, { resizable = true })
	reset()

	-- rendering configuration
	-- line join modes: none | miter | bevel
	love.graphics.setLineJoin("bevel")

	-- line style (if supported by LÖVE version)
	-- smooth: anti-aliased curves, rough: pixel style
	pcall(function() love.graphics.setLineStyle("smooth") end)
end

function love.keypressed(key)
	if key == "r" then reset()
	elseif key == "g" then state.showGrid = not state.showGrid end
end

function love.wheelmoved(_, dy)
	state.chainLength = clamp(state.chainLength + dy * 10, state.minLength, state.maxLength)
end

function love.mousepressed(x, y, button)
	local r = 12

	-- left mouse: drag first anchor
	if button == 1 then
		if (x - state.anchor1.x)^2 + (y - state.anchor1.y)^2 < r^2 then
			state.draggingAnchor = 1
			state.dragOffsetX = x - state.anchor1.x
			state.dragOffsetY = y - state.anchor1.y
		end

	-- right mouse: drag second anchor
	elseif button == 2 then
		if (x - state.anchor2.x)^2 + (y - state.anchor2.y)^2 < r^2 then
			state.draggingAnchor = 2
			state.dragOffsetX = x - state.anchor2.x
			state.dragOffsetY = y - state.anchor2.y
		end
	end
end

function love.mousereleased()
	state.draggingAnchor = nil
end

function love.mousemoved(x, y)
	if not state.draggingAnchor then return end

	local a = (state.draggingAnchor == 1) and state.anchor1 or state.anchor2
	local other = (state.draggingAnchor == 1) and state.anchor2 or state.anchor1

	-- apply drag offset
	local nx = x - state.dragOffsetX
	local ny = y - state.dragOffsetY

	-- enforce rope length constraint during interaction
	local dx = nx - other.x
	local dy = ny - other.y
	local dist = math.sqrt(dx * dx + dy * dy)

	if dist > state.chainLength then
		local scale = state.chainLength / dist
		nx = other.x + dx * scale
		ny = other.y + dy * scale
	end

	a.x = nx
	a.y = ny
end

function love.draw()
	local w, h = love.graphics.getWidth(), love.graphics.getHeight()
	love.graphics.clear(0.07, 0.07, 0.12)

	-- draw background grid
	if state.showGrid then
		love.graphics.setColor(0.15, 0.15, 0.2)
		local step = 50
		for x = 0, w, step do love.graphics.line(x, 0, x, h) end
		for y = 0, h, step do love.graphics.line(0, y, w, y) end
	end

	-- compute catenary curve
	local res = catenary(
		state.anchor1.x, state.anchor1.y,
		state.anchor2.x, state.anchor2.y,
		state.chainLength
	)

	-- draw curve polyline
	if res and res.points and #res.points >= 2 then
		love.graphics.setLineWidth(2)
		love.graphics.setColor(0, 1, 0.3)

		local flat = {}
		for i = 1, #res.points do
			flat[#flat + 1] = res.points[i].x
			flat[#flat + 1] = res.points[i].y
		end

		love.graphics.line(unpack(flat))
		love.graphics.setLineWidth(1)
	end

	-- draw anchors (color depends on solver state)
	local ok = (not res or not res.status or res.status == "ok")
	local anchorColor = ok and {1, 0.85, 0.2} or {1, 0.2, 0.2}

	love.graphics.setColor(anchorColor)
	love.graphics.circle("fill", state.anchor1.x, state.anchor1.y, 6)
	love.graphics.circle("fill", state.anchor2.x, state.anchor2.y, 6)

	-- error/debug overlay when solver fails
	if res and res.status and res.status ~= "ok" then
		love.graphics.setColor(1, 0.4, 0.4)
		love.graphics.print("error: " .. tostring(res.msg or res.status), 20, 60)

		love.graphics.setLineWidth(2)
		love.graphics.setColor(1, 0, 0)
		love.graphics.line(
			state.anchor1.x, state.anchor1.y,
			state.anchor2.x, state.anchor2.y
		)
		love.graphics.setLineWidth(1)
	end

	-- hud
	love.graphics.setColor(1, 1, 1)

	local dx = state.anchor2.x - state.anchor1.x
	local dy = state.anchor2.y - state.anchor1.y
	local dist = math.sqrt(dx * dx + dy * dy)

	love.graphics.print(
		string.format("Length: %d | Dist: %.1f", math.floor(state.chainLength), dist),
		20, 20
	)

	love.graphics.print(
		"lmb: drag left | rmb: drag right | wheel: length | r: reset | g: grid",
		20, 40
	)

	-- debug values
	if res then
		local a = res.a or 0
		local x0 = res.x0 or 0
		local c = res.c or 0
		local y_min = (res.c and res.a) and (res.c - res.a) or 0

		love.graphics.print(
			string.format(
				"a: %.4f  x0: %.1f  c: %.1f  y_min: %.1f  status: %s",
				a, x0, c, y_min, tostring(res.status)
			),
			20, 80
		)

		if res.x0 and y_min then
			love.graphics.setColor(0, 1, 0)
			love.graphics.circle("fill", res.x0, y_min, 4)
		end
	end
end