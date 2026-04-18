-- main.lua
-- Love2D entry point for the Bridge Builder game.
-- Creates a Truss world, handles UI and input, delegates
-- physics to the truss library and drawing to bridge.lua.
local Truss = require("truss")
local BrokenTruss = require("truss.broken-truss")
local Vehicles = require("vehicles")
local Bridge = require("bridge")
-- UI layout constants (rendering only, not physics)
UI = {
	TBW = 178, -- toolbar width in pixels
	GRID = 20, -- canvas snap grid in pixels
	NR = 9, -- node circle radius in pixels
	BW = 6, -- beam line width in pixels
}
-- Global shared state
world = nil -- truss world; created in love.load
Width, Height = 0, 0 -- window dimensions
gstate = "build" -- current mode: "build" or "simulate"
tool = "node" -- active build tool
sel = nil -- selected node index (for beam tool)
hover = nil -- node index currently under cursor
msg = "Welcome! SPACE=simulate Q/E=axial-z A/D=angular-z"
sim_time = 0
sim_running = false
font14, font12, font11 = nil, nil, nil -- cached fonts

-- Toolbar button definitions
local TOOL_BTNS = {
	{ id = "node", label = "[1] Add Joint" },
	{ id = "beam", label = "[2] Add Beam" },
	{ id = "pin", label = "[3] Support" },
	{ id = "load", label = "[4] Toggle Load" },
	{ id = "del", label = "[5] Delete" },
}

local function btn_top(i)
	return 52 + (i - 1) * 36
end

-- draws damping bar with label and value
local function draw_zeta_bar(y, label, value, r, g, b)
	love.graphics.setFont(font11)
	love.graphics.setColor(0.55, 0.58, 0.68)
	love.graphics.print(label, 10, y)
	love.graphics.setColor(0.10, 0.12, 0.18)
	love.graphics.rectangle("fill", 10, y+14, UI.TBW-20, 10, 2)
	love.graphics.setColor(r, g, b)
	love.graphics.rectangle("fill", 10, y+14, (UI.TBW-20) * value, 10, 2)
	love.graphics.setColor(0.90, 0.92, 0.96)
	love.graphics.printf(string.format("%.2f", value), 10, y+13, UI.TBW-20, "right")
	love.graphics.setFont(font14)
end

-- draws left toolbar
local function draw_toolbar()
	-- background
	love.graphics.setColor(0.09, 0.10, 0.13)
	love.graphics.rectangle("fill", 0, 0, UI.TBW, Height)
	-- header
	love.graphics.setColor(0.17, 0.19, 0.26)
	love.graphics.rectangle("fill", 0, 0, UI.TBW, 46)
	love.graphics.setColor(0.92, 0.82, 0.42)
	love.graphics.setFont(font14)
	love.graphics.print("Bridge Builder", 10, 8)
	love.graphics.setColor(0.55, 0.58, 0.68)
	love.graphics.setFont(font11)
	love.graphics.print("Dynamic Truss", 10, 28)
	love.graphics.setFont(font14)

	-- tool buttons
	for i, btn in ipairs(TOOL_BTNS) do
		local ty = btn_top(i)
		local act = (tool == btn.id and gstate == "build")
		love.graphics.setColor(act and {0.20, 0.46, 0.88} or {0.16, 0.18, 0.23})
		love.graphics.rectangle("fill", 5, ty, UI.TBW-10, 28, 4)
		love.graphics.setColor(act and {1, 1, 1} or {0.70, 0.74, 0.80})
		love.graphics.print(btn.label, 11, ty + 7)
	end

	local sep = btn_top(#TOOL_BTNS) + 34
	love.graphics.setColor(0.22, 0.25, 0.34)
	love.graphics.line(6, sep, UI.TBW-6, sep)

	-- simulate / build toggle
	local sim_y = sep + 10
	local is_sim = (gstate == "simulate")
	love.graphics.setColor(is_sim and {0.12, 0.62, 0.35} or {0.28, 0.16, 0.58})
	love.graphics.rectangle("fill", 5, sim_y, UI.TBW-10, 38, 5)
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(font12)
	love.graphics.printf(
		is_sim and "|| BUILD MODE\n[SPACE]" or "> SIMULATE\n[SPACE]",
		8, sim_y+5, UI.TBW-16, "center")
	love.graphics.setFont(font14)

	local res_y = sim_y + 44
	love.graphics.setColor(0.40, 0.12, 0.10)
	love.graphics.rectangle("fill", 5, res_y, UI.TBW-10, 26, 4)
	love.graphics.setColor(1, 0.78, 0.78)
	love.graphics.print("[R] Reset Bridge", 10, res_y + 5)

	local clr_y = res_y + 30
	love.graphics.setColor(0.28, 0.10, 0.06)
	love.graphics.rectangle("fill", 5, clr_y, UI.TBW-10, 26, 4)
	love.graphics.setColor(1, 0.66, 0.55)
	love.graphics.print("[C] Clear All", 10, clr_y + 5)

	-- damping panel
--	local dp = clr_y + 36
--	love.graphics.setColor(0.14, 0.17, 0.24)
--	love.graphics.rectangle("fill", 5, dp, UI.TBW-10, 96, 4)
--	love.graphics.setColor(0.70, 0.75, 0.88)
--	love.graphics.setFont(font11)
--	love.graphics.printf("DAMPING (Q/E A/D)", 5, dp+5, UI.TBW-10, "center")
--	love.graphics.setFont(font14)
--	draw_zeta_bar(dp+22, "Axial z [Q/E]", world.config.ZETA_AXIAL, 0.30, 0.72, 0.42)
--	draw_zeta_bar(dp+56, "Angular z [A/D]", world.config.ZETA_ANGULAR, 0.30, 0.55, 0.95)

	-- legend (simulate mode only)
	if gstate == "simulate" then
		local lg = clr_y + 30
		love.graphics.setColor(0.60, 0.62, 0.72)
		love.graphics.print("LEGEND", 8, lg)
		lg = lg + 18

		-- draws one legend row
		local function leg(r, g, b, txt)
			love.graphics.setColor(r, g, b, 1)
			love.graphics.rectangle("fill", 8, lg, 14, 11, 2)
			love.graphics.setColor(0.75, 0.78, 0.85)
			love.graphics.print(txt, 26, lg)
			lg = lg + 17
		end

		leg(0.15, 0.50, 1.00, "Tension")
		leg(1.00, 0.30, 0.08, "Compression")
		leg(0.58, 0.60, 0.64, "No load")

		love.graphics.setColor(0.55, 0.10, 0.10, 0.5)
		love.graphics.rectangle("fill", 8, lg, 14, 11, 2)
		love.graphics.setColor(0.75, 0.78, 0.85)
		love.graphics.print("Fractured", 26, lg)

		lg = lg + 22
		love.graphics.setFont(font11)
		love.graphics.printf(
			string.format("Peak: %.0f N", world.peak_force),
			8, lg, UI.TBW-16, "center")
		love.graphics.setFont(font14)
	end

	-- footer counters
	love.graphics.setColor(0.14, 0.16, 0.21)
	love.graphics.rectangle("fill", 0, Height-52, UI.TBW, 52)
	love.graphics.setColor(0.52, 0.57, 0.68)
	love.graphics.setFont(font12)

	local bk = world:broken_count()
	love.graphics.printf(
		"Nodes: "..#world.nodes.." Beams: "..#world.beams..
		(bk > 0 and ("\nBroken: "..bk) or ""),
		6, Height-48, UI.TBW-12)

	love.graphics.setFont(font14)

	-- toolbar right border
	love.graphics.setColor(0.24, 0.28, 0.38)
	love.graphics.setLineWidth(1.5)
	love.graphics.line(UI.TBW, 0, UI.TBW, Height)
	love.graphics.setLineWidth(1)
end

-- draws bottom status bar
local function draw_status()
	love.graphics.setColor(0.07, 0.08, 0.11)
	love.graphics.rectangle("fill", UI.TBW, Height-30, Width-UI.TBW, 30)
	love.graphics.setColor(0.24, 0.26, 0.35)
	love.graphics.line(UI.TBW, Height-30, Width, Height-30)
	love.graphics.setColor(sim_running and {0.60, 0.92, 0.60} or {0.80, 0.80, 0.60})
	local txt = msg
	if gstate == "simulate" and sim_running then
		txt = string.format("Max: %.0f N t=%.2fs | %s", world.max_force, sim_time, msg)
	end
	love.graphics.print(txt, UI.TBW + 10, Height - 22)
end

-- draws top overlay hints
local function draw_overlay()
	love.graphics.setFont(font12)
	if gstate == "simulate" and sim_running then
		love.graphics.setColor(0.12, 0.72, 0.42, 0.80)
		love.graphics.print(
			"DYNAMIC SIMULATION (Velocity Verlet, "..world.config.SUBSTEPS.." substeps) | [SPACE] = stop",
			UI.TBW + 10, 8)
	elseif gstate == "simulate" and not sim_running then
		love.graphics.setColor(0.9, 0.7, 0.2, 0.8)
		love.graphics.print("STOPPED | [SPACE] = restart", UI.TBW + 10, 8)
	elseif tool == "beam" and sel then
		love.graphics.setColor(1, 0.9, 0.2, 0.9)
		love.graphics.print("Node "..sel.." selected - click another. [ESC] cancel", UI.TBW + 10, 8)
	else
		local tips = {
			node = "Click canvas to place joint (snaps to grid)",
			beam = "Click first joint, then second to connect",
			pin = "Cycle: free -> roller (y) -> pin (xy)",
			load = "Toggle downward force on joint",
			del = "Click joint or beam to delete",
		}
		love.graphics.setColor(0.50, 0.55, 0.68, 0.70)
		love.graphics.print(tips[tool] or "", UI.TBW + 10, 8)
	end
	love.graphics.setFont(font14)
end

-- Simulation control helpers
local function reset_car()
	if car then
		local cx = UI.TBW + (Width - UI.TBW) / 2
		car.chassis.x = cx - 280
		car.chassis.y = 340
		car:reset()
	end
end

local function start_sim()
	world:start()
	sim_running = true
	sim_time = 0
	reset_car()
	msg = "Simulation running. ARROWS=drive car SPACE=stop"
end

local function stop_sim()
	sim_running = false
	world:reset()
	BrokenTruss.clear(world)
	reset_car()
	msg = "Back to build mode."
end

local function reset_bridge()
	sim_running = false
	world.nodes, world.beams = {}, {}
	Bridge.new_bridge(world, Width)
	BrokenTruss.clear(world)
	gstate = "build"
	sel, hover = nil, nil
	reset_car()
	msg = "Warren truss ready. SPACE=simulate Q/E=axial-z A/D=angular-z"
end

local function nearest_node_in_world(mx, my)
	local best_d2 = (UI.NR * 3)^2
	local best_i = nil
	for i, n in ipairs(world.nodes) do
		local d2 = (mx - n.x)^2 + (my - n.y)^2
		if d2 < best_d2 then best_d2, best_i = d2, i end
	end
	return best_i
end

local function nearest_beam(mx, my)
	local best_d = 14
	local best_i = nil
	for i, bm in ipairs(world.beams) do
		local n1 = world.nodes[bm.n1]
		local n2 = world.nodes[bm.n2]
		local dx = n2.x - n1.x
		local dy = n2.y - n1.y
		local ll = dx*dx + dy*dy + 1e-9
		local t = math.max(0, math.min(1, ((mx-n1.x)*dx + (my-n1.y)*dy) / ll))
		local px = n1.x + t*dx
		local py = n1.y + t*dy
		local d = math.sqrt((mx-px)^2 + (my-py)^2)
		if d < best_d then best_d, best_i = d, i end
	end
	return best_i
end

local function snap(v)
	return math.floor(v / UI.GRID + 0.5) * UI.GRID
end

local function cycle_support(ni)
	local n = world.nodes[ni]
	if n.pin_x and n.pin_y then
		world:pin(ni, false, false)
	elseif n.pin_y then
		world:pin(ni, true, true)
	else
		world:pin(ni, false, true)
	end
	msg = "Support toggled."
end

local function handle_toolbar_click(mx, my)
	for i, btn in ipairs(TOOL_BTNS) do
		local ty = btn_top(i)
		if my >= ty and my <= ty+28 and gstate == "build" then
			tool = btn.id
			sel = nil
			return
		end
	end
	local sep = btn_top(#TOOL_BTNS) + 34
	local sim_y = sep + 10
	if my >= sim_y and my <= sim_y+38 then
		if gstate == "build" then
			gstate = "simulate"
			start_sim()
		else
			gstate = "build"
			stop_sim()
		end
		return
	end
	local res_y = sim_y + 44
	if my >= res_y and my <= res_y+26 then
		reset_bridge()
		return
	end
	local clr_y = res_y + 30
	if my >= clr_y and my <= clr_y+26 then
		world.nodes, world.beams = {}, {}
		gstate = "build"
		sim_running = false
		sel, hover = nil, nil
		msg = "Cleared."
	end
end

function love.load()
	Width, Height = love.graphics.getDimensions()
	love.graphics.setLineStyle("smooth")
	font14 = love.graphics.newFont(14)
	font12 = love.graphics.newFont(12)
	font11 = love.graphics.newFont(11)
	love.graphics.setFont(font14)

	world = Truss.new({})
	BrokenTruss.enable(world)
	-- standard instantiation using internal defaults
	car = Vehicles.car_new()
	reset_car()
	reset_bridge()
end

function love.update(dt)
	local mx, my = love.mouse.getPosition()
	hover = (mx > UI.TBW) and nearest_node_in_world(mx, my) or nil

	if gstate == "simulate" and sim_running then
		-- right arrow: forward throttle
		if love.keyboard.isDown("right") then car.input.throttle = 1 else car.input.throttle = 0 end
		-- left arrow: reverse
		if love.keyboard.isDown("left") then car.input.reverse = 1 else car.input.reverse = 0 end
		-- down arrow: brake
		if love.keyboard.isDown("down") then car.input.brake = 1 else car.input.brake = 0 end

		Vehicles.car_step(car, dt, world)
		world:step(dt)
		BrokenTruss.step(world, dt)
		sim_time = sim_time + math.min(dt, world.config.DT_MAX)
	end
end

function love.draw()
	love.graphics.setColor(0.08, 0.09, 0.13)
	love.graphics.rectangle("fill", UI.TBW, 0, Width - UI.TBW, Height)
	Bridge.draw_grid()
	Bridge.draw_ragdolls()
	Bridge.draw()
	-- car is drawn in all states for visibility before simulation
	if car then Vehicles.car_draw(car, world) end
	draw_toolbar()
	draw_status()
	draw_overlay()
end

local function handle_canvas_left(mx, my)
	local ni = nearest_node_in_world(mx, my)
	if tool == "node" then
		local sx, sy = snap(mx), snap(my)
		for _, n in ipairs(world.nodes) do
			if n.x == sx and n.y == sy then return end
		end
		world:add_node(sx, sy)
		msg = "Joint added."
	elseif tool == "beam" then
		if ni then
			if not sel then
				sel = ni
			elseif ni ~= sel then
				if world:add_beam(sel, ni) then
					msg = "Beam added."
				else
					msg = "Beam already exists."
				end
				sel = ni
			end
		else
			sel = nil
		end
	elseif tool == "pin" and ni then
		cycle_support(ni)
	elseif tool == "load" and ni then
		local n = world.nodes[ni]
		if n.load then
			world:set_load(ni, nil)
			msg = "Load removed."
		else
			world:set_load(ni, world.config.EXT_LOAD)
			msg = "Load applied."
		end
	elseif tool == "del" then
		if ni then
			world:remove_node(ni)
			if sel == ni then sel = nil
			elseif sel and sel > ni then sel = sel - 1 end
			hover = nil
			msg = "Node deleted."
		else
			local bi = nearest_beam(mx, my)
			if bi then
				world:remove_beam(bi)
				msg = "Beam deleted."
			else
				sel = nil
			end
		end
	end
end

function love.mousepressed(mx, my, btn)
	if mx < UI.TBW then
		handle_toolbar_click(mx, my)
		return
	end
	if gstate == "simulate" then return end
	if btn == 1 then
		handle_canvas_left(mx, my)
	elseif btn == 2 then
		local ni = nearest_node_in_world(mx, my)
		if ni then cycle_support(ni) end
	end
end

function love.keypressed(k)
	local cfg = world.config
	if k == "space" then
		if gstate == "build" then
			gstate = "simulate"
			start_sim()
		elseif gstate == "simulate" then
			gstate = "build"
			stop_sim()
		end
	elseif k == "r" then
		reset_bridge()
	elseif k == "c" then
		world.nodes, world.beams = {}, {}
		gstate = "build"
		sim_running = false
		sel, hover = nil, nil
		msg = "Cleared."
	elseif k == "escape" then
		sel = nil
	elseif k == "1" then
		tool = "node"
		sel = nil
	elseif k == "2" then
		tool = "beam"
		sel = nil
	elseif k == "3" then
		tool = "pin"
		sel = nil
	elseif k == "4" then
		tool = "load"
		sel = nil
	elseif k == "5" then
		tool = "del"
		sel = nil
	end
end