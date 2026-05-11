local Catenary = require("catenary")
local state = {}
local function clamp(v, a, b) return math.max(a, math.min(b, v)) end

local w, h = love.graphics.getWidth(), love.graphics.getHeight()



function love.load()
	love.window.setMode(1250, 800, { resizable = true })

	w, h = love.graphics.getWidth(), love.graphics.getHeight()


	state = {
		anchor1 = { x = 300, y = 400 },
		anchor2 = { x = 500, y = 300 },
		chainLength = 250,
		minLength = 120,
		maxLength = 2000,
		draggingAnchor = nil,
		dragOffsetX = 0,
		dragOffsetY = 0,
		showGrid = true,
	}
end

function love.keypressed(key)
	if key == "g" then state.showGrid = not state.showGrid end
end

function love.wheelmoved(_, dy)
	state.chainLength = clamp(state.chainLength + dy * 10, state.minLength, state.maxLength)
end

function love.mousepressed(x, y, button)
	local r = 12
	if button == 1 then
		if (x - state.anchor1.x)^2 + (y - state.anchor1.y)^2 < r^2 then
			state.draggingAnchor = 1
			state.dragOffsetX = x - state.anchor1.x
			state.dragOffsetY = y - state.anchor1.y
		end
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

	local nx = x - state.dragOffsetX
	local ny = y - state.dragOffsetY
	local dx = nx - other.x
	local dy = ny - other.y
	local dist = math.sqrt(dx*dx + dy*dy)

	if dist > state.chainLength then
		local scale = state.chainLength / dist
		nx = other.x + dx * scale
		ny = other.y + dy * scale
	end

	a.x = nx
	a.y = ny
end

function love.draw()

	-- draw background grid
	if state.showGrid then
		love.graphics.setColor(0.5, 0.5, 0.5)
		local step = 50
		for x = 0, w, step do love.graphics.line(x, 0, x, h) end
		for y = 0, h, step do love.graphics.line(0, y, w, y) end
	end

	-- draw catenary and get computation result
	local res = Catenary.draw(
		state.anchor1.x, state.anchor1.y,
		state.anchor2.x, state.anchor2.y,
		state.chainLength, 160, 2
	)

	love.graphics.setColor(1,1,1)
	if res then
--		love.graphics.setColor(1,1,1)
		love.graphics.print(string.format(
				"a=%.4f x0=%.2f c=%.2f y_min=%.2f",
				res.a or 0, res.x0 or 0, res.c or 0, res.y_min or 0
				), 20, 100)

		love.graphics.setColor(0,1,0)

		if res.y_min then
			love.graphics.circle("fill", res.x0, res.y_min, 4)
		end
	end

	-- draw anchor debug markers (red if solver failed)
	local anchorColor = (res.status == "ok") and {1, 0.85, 0.2} or {1, 0.2, 0.2}
	Catenary.drawAnchors(
		state.anchor1.x, state.anchor1.y,
		state.anchor2.x, state.anchor2.y
	)


end