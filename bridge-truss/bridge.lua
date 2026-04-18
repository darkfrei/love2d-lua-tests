-- bridge.lua
-- game-specific bridge creation and canvas rendering
local STRESS_COLOR_NEUTRAL = {0.58, 0.60, 0.64, 1}
local STRESS_COLOR_TENSION = {0.10, 0.40, 1.00, 1}
local STRESS_COLOR_COMPRESSION = {1.00, 0.20, 0.10, 1}

local function stress_color(force, max_f)
	if not force or force == 0 then return STRESS_COLOR_NEUTRAL end
	if not max_f or max_f == 0 then return STRESS_COLOR_NEUTRAL end
	local t = math.max(-1, math.min(1, force / max_f))
	local target = (t < 0) and STRESS_COLOR_COMPRESSION or STRESS_COLOR_TENSION
	local s = math.min(math.abs(t) * 2, 1)
	return {
		STRESS_COLOR_NEUTRAL[1] + (target[1] - STRESS_COLOR_NEUTRAL[1]) * s,
		STRESS_COLOR_NEUTRAL[2] + (target[2] - STRESS_COLOR_NEUTRAL[2]) * s,
		STRESS_COLOR_NEUTRAL[3] + (target[3] - STRESS_COLOR_NEUTRAL[3]) * s,
		1,
	}
end

local function new_bridge(world, Width)
	world.nodes, world.beams = {}, {}
	local cx = UI.TBW + (Width - UI.TBW) / 2
	local by = 430
	local ty = 300
	local span = 660
	local n = 5
	local extLoad = world.config.EXT_LOAD

	-- bottom chord nodes
	for i = 0, n do
		local x = cx - span / 2 + i * span / n
		local pin = (i == 0 or i == n)
--		world:add_node(x, by, { pin_x = pin, pin_y = pin, load = (i > 0 and i < n) and extLoad or nil })
		world:add_node(x, by, { pin_x = pin, pin_y = pin})
	end
	-- top chord nodes
	for i = 0, n - 1 do
		local x = cx - span / 2 + (i + 0.5) * span / n
		world:add_node(x, ty)
	end

	local function B(i) return i end
	local function T(i) return n+1+i end

	-- bottom chord: create as road type directly
	for i = 1, n do
		if world.add_road then
			world:add_road(B(i), B(i+1))
		else
			world:add_beam(B(i), B(i+1))
			world.beams[#world.beams].type = "road"
		end
	end

	-- top chord
	for i = 1, n - 1 do
		world:add_beam(T(i), T(i+1))
	end

	-- warren diagonals
	for i = 1, n do
		world:add_beam(B(i), T(i))
		world:add_beam(T(i), B(i+1))
	end
end

local function draw_grid()
	love.graphics.setColor(0.11, 0.12, 0.16)
	love.graphics.setLineWidth(1)
	for x = UI.TBW, Width, UI.GRID do love.graphics.line(x, 0, x, Height) end
	for y = 0, Height, UI.GRID do love.graphics.line(UI.TBW, y, Width, y) end
	love.graphics.setColor(0.28, 0.20, 0.12)
	love.graphics.setLineWidth(3)
	love.graphics.line(UI.TBW, 450, Width, 450)
	love.graphics.setColor(0.20, 0.14, 0.08)
	love.graphics.setLineWidth(1)
	for xi = UI.TBW, Width, 20 do
		love.graphics.line(xi, 450, xi - 12, 464)
	end
end

local function draw_broken_beam(bm)
	local n1 = world.nodes[bm.n1]
	local n2 = world.nodes[bm.n2]
	local dx = n2.x - n1.x
	local dy = n2.y - n1.y
	local L = math.sqrt(dx*dx + dy*dy)
	if L < 0.01 then return end
	local ux = dx / L
	local uy = dy / L
	local half = L / 2
	local gap = 12
	local m1x = n1.x + ux * (half - gap / 2)
	local m1y = n1.y + uy * (half - gap / 2)
	local m2x = n1.x + ux * (half + gap / 2)
	local m2y = n1.y + uy * (half + gap / 2)
	love.graphics.setColor(0.55, 0.10, 0.10, 0.8)
	love.graphics.setLineWidth(2)
	love.graphics.line(n1.x, n1.y, m1x, m1y)
	love.graphics.line(m2x, m2y, n2.x, n2.y)
end



local function draw_beams()
	local mx, my = love.mouse.getPosition()
	local max_f = world.config.MAX_F
	for _, bm in ipairs(world.beams) do
		local n1 = world.nodes[bm.n1]
		local n2 = world.nodes[bm.n2]

		if n1 and n2 then
			if bm.broken then
				draw_broken_beam(bm)
			else
				local x1, y1 = n1.x, n1.y
				local x2, y2 = n2.x, n2.y
				local cx = (x1 + x2) / 2
				local cy = (y1 + y2) / 2

				if bm.type == "road" then
					love.graphics.setColor(0.8, 0.8, 0.8)
					love.graphics.setLineWidth(UI.BW * 2.5+4)
					love.graphics.line(x1, y1+UI.BW, x2, y2+UI.BW)
					
					love.graphics.setColor(0.2, 0.2, 0.2)
					love.graphics.setLineWidth(UI.BW * 2.5)
					love.graphics.line(x1, y1+UI.BW, x2, y2+UI.BW)

					love.graphics.setLineWidth(1)
					
					love.graphics.setColor(stress_color(bm.force, max_f))
					love.graphics.setLineWidth(UI.BW)
					love.graphics.line(x1, y1, x2, y2)
--					love.graphics.setLineWidth(UI.BW * 0.8)
				else
					-- standard truss beam rendering
					love.graphics.setColor(stress_color(bm.force, max_f))
					love.graphics.setLineWidth(UI.BW)
					love.graphics.line(x1, y1, x2, y2)

					if gstate == "simulate" and bm.force ~= 0 then
						local pct = math.abs(bm.force) / max_f * 100
						local col = pct > 90 and {1, 0.3, 0.3} or (pct > 70 and {1, 0.8, 0.2} or {1, 1, 1})

						love.graphics.setColor(0, 0, 0, 0.55)
						love.graphics.rectangle("fill", cx-16, cy-8, 32, 14, 3)

						love.graphics.setColor(col)
						love.graphics.setFont(font11)
						love.graphics.printf(string.format("%.0f%%", pct), cx-16, cy-7, 32, "center")

						local dx = mx - cx
						local dy = my - cy
						if dx*dx + dy*dy < 900 then
							local tip = string.format("%.0f N (%.0f%%)", math.abs(bm.force), pct)
							love.graphics.setColor(0, 0, 0, 0.75)
							love.graphics.rectangle("fill", cx-44, cy-22, 88, 18, 4)
							love.graphics.setColor(col)
							love.graphics.printf(tip, cx-44, cy-21, 88, "center")
						end
					end
				end
			end
		end
	end
	love.graphics.setLineWidth(1)
end

local function draw_support(n, sx, sy)
	local c = n.pin_x and {0.08, 0.55, 0.20} or {0.12, 0.42, 0.72}
	love.graphics.setColor(c)
	love.graphics.polygon("fill", sx, sy + UI.NR, sx - UI.NR * 1.4, sy + UI.NR * 3, sx + UI.NR * 1.4, sy + UI.NR * 3)
	love.graphics.setColor(c[1]*0.65, c[2]*0.65, c[3]*0.65)
	love.graphics.setLineWidth(2)
	love.graphics.line(sx - UI.NR*1.9, sy + UI.NR*3, sx + UI.NR*1.9, sy + UI.NR*3)
	if not n.pin_x then
		love.graphics.setLineWidth(1.2)
		for ci = -1, 1 do love.graphics.circle("line", sx + ci*UI.NR*0.95, sy + UI.NR*3.55, UI.NR*0.42) end
	end
end

local function draw_nodes()
	for i, n in ipairs(world.nodes) do
		local sx, sy = n.x, n.y
		if i == hover then love.graphics.setColor(1, 1, 0.2, 0.18); love.graphics.circle("fill", sx, sy, UI.NR + 12) end
		if i == sel then love.graphics.setColor(1, 0.88, 0, 0.95); love.graphics.circle("fill", sx, sy, UI.NR + 6) end
		if n.pin_x and n.pin_y then love.graphics.setColor(0.15, 0.82, 0.38)
		elseif n.pin_y then love.graphics.setColor(0.22, 0.72, 0.96)
		else love.graphics.setColor(0.88, 0.90, 0.92) end
		love.graphics.circle("fill", sx, sy, UI.NR)
		love.graphics.setColor(0.04, 0.05, 0.10)
		love.graphics.setLineWidth(1.5)
		love.graphics.circle("line", sx, sy, UI.NR)
		if n.pin_y then draw_support(n, sx, sy) end
		if n.load then
			love.graphics.setColor(1, 0.5, 0.05)
			love.graphics.setLineWidth(2.5)
			local ay = sy + UI.NR + 3
			love.graphics.line(sx, ay, sx, ay + 22)
			love.graphics.polygon("fill", sx, ay+26, sx-6, ay+14, sx+6, ay+14)
		end
		if gstate == "build" then
			love.graphics.setFont(font11)
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.print(i, sx - 3+1, sy - 5+1)
			love.graphics.print(i, sx - 3+1, sy - 5)
			love.graphics.print(i, sx - 3+1, sy - 5-1)
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.print(i, sx - 3, sy - 5)
		end
	end
end

local function draw_preview()
	if gstate ~= "build" or tool ~= "beam" or not sel then return end
	local mx, my = love.mouse.getPosition()
	love.graphics.setColor(1, 1, 0.2, 0.55)
	love.graphics.setLineWidth(3)
	love.graphics.line(world.nodes[sel].x, world.nodes[sel].y, mx, my)
	love.graphics.setLineWidth(1)
end

local function draw_ragdolls()
	if not world.hinged_fragments or #world.hinged_fragments == 0 then return end
	for _, f in ipairs(world.hinged_fragments) do
		local n = world.nodes[f.node_idx]
		if n then
			local tip_x = n.x + f.length * math.cos(f.angle)
			local tip_y = n.y + f.length * math.sin(f.angle)
			love.graphics.setColor(0.5, 0.5, 0.5, 0.8)
			love.graphics.setLineWidth(UI.BW * 0.8)
			love.graphics.line(n.x, n.y, tip_x, tip_y)
		end
	end
end

local Bridge = {
	new_bridge = new_bridge,
	draw_grid = draw_grid,
	draw_ragdolls = draw_ragdolls,
}
Bridge.draw = function ()
	draw_beams()
	draw_nodes()
	draw_preview()
end
return Bridge