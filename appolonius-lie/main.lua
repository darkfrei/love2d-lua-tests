-- main.lua
--
-- interactive test for appolonius-lie.lua.
-- covers all 10 classical types of the Apollonius problem: every
-- combination of point (P), line (L) and circle (C) taken 3 at a time
-- -- CCC, CCL, CCP, CLL, CLP, CPP, LLL, LLP, LPP, PPP.
--
-- window starts at FullHD (1920x1080) and is resizable, set directly
-- in love.load (no conf.lua).
--
-- controls:
--   1-9, 0        jump to problem type (0 = 10th, PPP)
--   tab / right   next problem type
--   left          previous problem type
--   drag a handle (circle center, point, or line endpoint) with the mouse
--   scroll wheel over a circle to change its radius
--   R             reset current problem type to its default layout
--   ESC           quit

local Cycle = require("appolonius-lie")

local HANDLE_RADIUS = 20
local MAX_DRAW_RADIUS = 6000 -- skip absurdly large solution circles

local function C(x, y, r) return { kind = "circle", x = x, y = y, r = r } end
local function P(x, y) return { kind = "point", x = x, y = y } end
local function L(x1, y1, x2, y2) return { kind = "line", x1 = x1, y1 = y1, x2 = x2, y2 = y2 } end

-- each scenario builds its three input shapes around a center (cx,cy)
local scenarios = {
	{
		name = "1: CCC -- three circles",
		make = function(cx, cy)
			return {
				C(cx - 220, cy + 80, 90),
				C(cx + 220, cy + 80, 70),
				C(cx, cy - 180, 110),
			}
		end,
	},
	{
		name = "2: CCL -- two circles, one line",
		make = function(cx, cy)
			return {
				C(cx - 200, cy - 40, 80),
				C(cx + 180, cy - 100, 60),
				L(cx - 320, cy + 220, cx + 320, cy + 160),
			}
		end,
	},
	{
		name = "3: CCP -- two circles, one point",
		make = function(cx, cy)
			return {
				C(cx - 180, cy + 40, 90),
				C(cx + 190, cy + 20, 70),
				P(cx, cy - 200),
			}
		end,
	},
	{
		name = "4: CLL -- one circle, two lines",
		make = function(cx, cy)
			return {
				C(cx - 60, cy + 20, 55),
				L(cx - 320, cy - 180, cx + 320, cy - 30),
				L(cx - 320, cy + 220, cx + 320, cy + 60),
			}
		end,
	},
	{
		name = "5: CLP -- one circle, one line, one point",
		make = function(cx, cy)
			return {
				C(cx + 120, cy + 40, 85),
				L(cx - 320, cy + 200, cx + 320, cy + 120),
				P(cx - 220, cy - 160),
			}
		end,
	},
	{
		name = "6: CPP -- one circle, two points",
		make = function(cx, cy)
			return {
				C(cx, cy, 110),
				P(cx - 230, cy - 160),
				P(cx + 230, cy - 160),
			}
		end,
	},
	{
		name = "7: LLL -- three lines (incircle + excircles)",
		make = function(cx, cy)
			local ax, ay = cx - 260, cy + 160
			local bx, by = cx + 260, cy + 160
			local dx, dy = cx, cy - 220
			return {
				L(ax, ay, bx, by),
				L(bx, by, dx, dy),
				L(dx, dy, ax, ay),
			}
		end,
	},
	{
		name = "8: LLP -- two lines, one point",
		make = function(cx, cy)
			return {
				L(cx - 300, cy - 200, cx + 300, cy + 200),
				L(cx - 300, cy + 200, cx + 300, cy - 200),
				P(cx + 150, cy - 60),
			}
		end,
	},
	{
		name = "9: LPP -- one line, two points",
		make = function(cx, cy)
			return {
				L(cx - 300, cy + 120, cx + 300, cy + 120),
				P(cx - 160, cy - 100),
				P(cx + 170, cy - 150),
			}
		end,
	},
	{
		name = "0: PPP -- three points (circumcircle)",
		make = function(cx, cy)
			return {
				P(cx - 210, cy + 130),
				P(cx + 230, cy + 100),
				P(cx, cy - 190),
			}
		end,
	},
}

local scenario_index
local shapes         -- { shape1, shape2, shape3 } for the current scenario
local solutions      -- last computed list of tangent cycles
local drag_handle    -- the handle currently being dragged, or nil


-- shape <-> Cycle conversion and generic drag handles


local function shape_to_cycle(s)
	if s.kind == "circle" then
		return Cycle.circle(s.x, s.y, s.r)
	elseif s.kind == "point" then
		return Cycle.point(s.x, s.y)
	else
		return Cycle.line_through(s.x1, s.y1, s.x2, s.y2)
	end
end

-- a circle/point exposes one handle (its center); a line exposes two
-- (its two defining endpoints)
local function shape_handles(s)
	if s.kind == "line" then
		return {
			{ get = function() return s.x1, s.y1 end, set = function(nx, ny) s.x1, s.y1 = nx, ny end },
			{ get = function() return s.x2, s.y2 end, set = function(nx, ny) s.x2, s.y2 = nx, ny end },
		}
	else
		return {
			{ get = function() return s.x, s.y end, set = function(nx, ny) s.x, s.y = nx, ny end },
		}
	end
end

local function all_handles()
	local handles = {}
	for _, s in ipairs(shapes) do
		for _, h in ipairs(shape_handles(s)) do
			table.insert(handles, h)
		end
	end
	return handles
end


-- scenario management


local function recompute()
	local c1, c2, c3 = shape_to_cycle(shapes[1]), shape_to_cycle(shapes[2]), shape_to_cycle(shapes[3])
	local ok, result = pcall(Cycle.solve_apollonius_all, c1, c2, c3)
	solutions = ok and result or {}
end

local function load_scenario(i)
	scenario_index = i
	shapes = scenarios[i].make(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
	recompute()
end

function love.load()
	love.window.setMode(1920, 1080, {
			resizable = true,
			minwidth = 640,
			minheight = 360,
			vsync = 1,
		})
	love.window.setTitle("appolonius-li test bed")
	love.graphics.setBackgroundColor(0.08, 0.09, 0.11)
	load_scenario(1)
end

function love.resize(w, h)
	recompute()
end

function love.mousepressed(mx, my, button)
	if button ~= 1 then return end
	for _, h in ipairs(all_handles()) do
		local hx, hy = h.get()
		local dx, dy = mx - hx, my - hy
		if dx * dx + dy * dy < HANDLE_RADIUS * HANDLE_RADIUS then
			drag_handle = h
			return
		end
	end
end

function love.mousereleased(mx, my, button)
	if button == 1 then drag_handle = nil end
end

function love.mousemoved(mx, my, dx, dy)
	if drag_handle then
		drag_handle.set(mx, my)
		recompute()
	end
end

function love.wheelmoved(dx, dy)
	local mx, my = love.mouse.getPosition()
	for _, s in ipairs(shapes) do
		if s.kind == "circle" then
			local ddx, ddy = mx - s.x, my - s.y
			if ddx * ddx + ddy * ddy < (s.r + 40) * (s.r + 40) then
				s.r = math.max(10, s.r + dy * 5)
				recompute()
				return
			end
		end
	end
end

function love.keypressed(key)
	if key == "r" then
		load_scenario(scenario_index)
	elseif key == "tab" or key == "right" then
		load_scenario(scenario_index % #scenarios + 1)
	elseif key == "left" then
		load_scenario((scenario_index - 2) % #scenarios + 1)
	elseif key == "escape" then
		love.event.quit()
	else
		local n = tonumber(key)
		if n then
			if n == 0 then n = 10 end
			if scenarios[n] then load_scenario(n) end
		end
	end
end


-- drawing


local function draw_shape(s)
	love.graphics.setColor(0.55, 0.75, 1.0)
	if s.kind == "circle" then
		love.graphics.circle("line", s.x, s.y, s.r)
		love.graphics.circle("fill", s.x, s.y, 4)
	elseif s.kind == "point" then
		love.graphics.circle("fill", s.x, s.y, 6)
	else
		local dx, dy = s.x2 - s.x1, s.y2 - s.y1
		local len = math.sqrt(dx * dx + dy * dy)
		local ux, uy = dx / len, dy / len
		love.graphics.line(s.x1 - ux * 3000, s.y1 - uy * 3000, s.x2 + ux * 3000, s.y2 + uy * 3000)
		love.graphics.circle("fill", s.x1, s.y1, 5)
		love.graphics.circle("fill", s.x2, s.y2, 5)
	end
end

local function draw_solution(sol)
	if sol.kind == "circle" then
		if math.abs(sol.r) <= MAX_DRAW_RADIUS then
			love.graphics.setColor(0.4, 1.0, 0.5, 0.9)
			love.graphics.circle("line", sol.a, sol.b, math.abs(sol.r))
		end
	elseif sol.kind == "point" then
		love.graphics.setColor(1.0, 0.9, 0.3)
		love.graphics.circle("fill", sol.a, sol.b, 4)
	else
		love.graphics.setColor(1.0, 0.5, 0.3)
		local nx, ny, p = sol.a, sol.b, sol.r
		local lx, ly = nx * p, ny * p
		local tx, ty = -ny, nx
		love.graphics.line(lx - tx * 3000, ly - ty * 3000, lx + tx * 3000, ly + ty * 3000)
	end
end

function love.draw()
	for _, s in ipairs(shapes) do
		draw_shape(s)
	end
	for _, sol in ipairs(solutions) do
		draw_solution(sol)
	end

	love.graphics.setColor(1, 1, 1)
	love.graphics.print(string.format(
			"appolonius-li test bed  (%dx%d)\n" ..
			"%s\n" ..
			"1-9,0: jump to problem type   tab/right/left: cycle   R: reset   ESC: quit\n" ..
			"drag a handle to move it, scroll over a circle to resize it\n" ..
			"tangent cycles found: %d",
			love.graphics.getWidth(), love.graphics.getHeight(),
			scenarios[scenario_index].name,
			#solutions
			), 20, 20)
end