-- core/renderer.lua
-- rendering: grid, roads, nodes, and debug overlays
-- ways with layer > 0 are rendered as bridges (shadow + pillars + railings)
-- ways with layer < 0 are rendered as underpasses (dimmed + dashed border)

local M = {}

--
-- helpers
--

local function drawPolyline(points)
	for i = 1, #points - 1 do
		love.graphics.line(
			points[i].x, points[i].y,
			points[i + 1].x, points[i + 1].y
		)
	end
end

-- supports quadratic (3 pts) and cubic (4 pts)
local function sampleBezier(pts, steps)
	local out = {}
	local n   = #pts

	for i = 0, steps do
		local t = i / steps
		local u = 1 - t
		local x, y

		if n == 3 then
			x = u*u*pts[1].x + 2*u*t*pts[2].x + t*t*pts[3].x
			y = u*u*pts[1].y + 2*u*t*pts[2].y + t*t*pts[3].y
		else
			-- cubic (n == 4)
			x = u^3*pts[1].x + 3*u^2*t*pts[2].x + 3*u*t^2*pts[3].x + t^3*pts[4].x
			y = u^3*pts[1].y + 3*u^2*t*pts[2].y + 3*u*t^2*pts[3].y + t^3*pts[4].y
		end

		out[#out + 1] = { x = x, y = y }
	end

	return out
end

--
-- arrow rendering
--

local function drawArrow(x, y, dx, dy, size, r, g, b, a)
	local len = math.sqrt(dx * dx + dy * dy)
	if len < 0.001 then return end

	local nx = dx / len
	local ny = dy / len

	local tx = x + nx * size
	local ty = y + ny * size

	local px = -ny * size * 0.45
	local py =  nx * size * 0.45

	love.graphics.setColor(r, g, b, a)
	love.graphics.setLineWidth(2)
	love.graphics.line(x, y, tx, ty)
	love.graphics.line(tx, ty, x + px, y + py)
	love.graphics.line(tx, ty, x - px, y - py)
end

--
-- bridge visual helpers
--

-- drop shadow offset to simulate elevation
local function drawBridgeShadow(pts, layer)
	local offset = layer * 6
	local shadowPts = {}
	for _, p in ipairs(pts) do
		shadowPts[#shadowPts + 1] = { x = p.x + offset, y = p.y + offset }
	end

	love.graphics.setColor(0, 0, 0, 0.25 + layer * 0.05)
	love.graphics.setLineWidth(8 + layer * 2)
	drawPolyline(shadowPts)
end

-- thin bright lines along each side of the deck
local function drawBridgeRailings(pts, layer, r, g, b)
	local perp = 4 + layer
	for i = 1, #pts - 1 do
		local dx = pts[i + 1].x - pts[i].x
		local dy = pts[i + 1].y - pts[i].y
		local len = math.sqrt(dx * dx + dy * dy)
		if len > 0.001 then
			local nx = -dy / len * perp
			local ny =  dx / len * perp
			love.graphics.setColor(math.min(r * 1.4, 1), math.min(g * 1.4, 1), math.min(b * 1.4, 1), 0.7)
			love.graphics.setLineWidth(1.5)
			love.graphics.line(pts[i].x + nx, pts[i].y + ny, pts[i+1].x + nx, pts[i+1].y + ny)
			love.graphics.line(pts[i].x - nx, pts[i].y - ny, pts[i+1].x - nx, pts[i+1].y - ny)
		end
	end
end

-- small vertical support pillars along the bridge
local function drawBridgePillars(pts, layer)
	local dropLen = layer * 10
	local step = math.max(2, math.floor(#pts / 4))
	love.graphics.setColor(0.40, 0.35, 0.30, 0.65)
	love.graphics.setLineWidth(2.5)
	for i = 1, #pts, step do
		local p = pts[i]
		love.graphics.line(p.x, p.y, p.x + layer * 4, p.y + dropLen)
	end
end

-- dashed border for underpass/tunnel roads
local function drawUnderpassBorder(pts, r, g, b)
	local dashLen = 10
	local gapLen  = 6
	local acc     = 0
	local drawing = true

	for i = 1, #pts - 1 do
		local ax, ay = pts[i].x, pts[i].y
		local bx, by = pts[i + 1].x, pts[i + 1].y
		local dx, dy = bx - ax, by - ay
		local segLen = math.sqrt(dx * dx + dy * dy)
		if segLen >= 0.001 then
			local nx, ny = dx / segLen, dy / segLen
			local dist = 0
			while dist < segLen do
				local remain    = segLen - dist
				local targetLen = drawing and dashLen or gapLen
				local chunk     = math.min(remain, targetLen - acc)

				if drawing then
					local sx = ax + nx * dist
					local sy = ay + ny * dist
					local ex = ax + nx * (dist + chunk)
					local ey = ay + ny * (dist + chunk)
					love.graphics.setColor(r, g, b, 0.6)
					love.graphics.setLineWidth(1)
					love.graphics.line(sx, sy, ex, ey)
				end

				acc  = acc + chunk
				dist = dist + chunk

				if acc >= targetLen then
					acc     = 0
					drawing = not drawing
				end
			end
		end
	end
end

--
-- background and grid
--

function M.drawBackground()
	love.graphics.clear(0.08, 0.10, 0.12)
end

function M.drawGrid(camera)
	local size = 80

	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()

	local leftTopX, leftTopY         = camera:toWorld(0, 0)
	local rightBottomX, rightBottomY = camera:toWorld(sw, sh)

	local startX = math.floor(leftTopX / size) * size
	local startY = math.floor(leftTopY / size) * size

	love.graphics.setLineWidth(1)
	love.graphics.setColor(0.14, 0.17, 0.22, 0.6)

	for x = startX, rightBottomX, size do
		love.graphics.line(x, leftTopY, x, rightBottomY)
	end

	for y = startY, rightBottomY, size do
		love.graphics.line(leftTopX, y, rightBottomX, y)
	end
end

--
-- ways
-- three-pass draw: underpasses, ground, bridges
-- within the bridge pass: shadows first, then pillars, then deck surface
--

function M.drawWays(level, editor)
	if not level or not level.ways then return end

	local hoveredWay  = editor and editor.hoveredWay
	local selectedWay = editor and editor.selectedWay

	-- bucket ways by layer category
	local under  = {}
	local ground = {}
	local bridge = {}

	for idx, way in ipairs(level.ways) do
		local layer = (way.tags and tonumber(way.tags.layer)) or 0
		local entry = { idx = idx, way = way, layer = layer }
		if layer < 0 then
			under[#under + 1] = entry
		elseif layer > 0 then
			bridge[#bridge + 1] = entry
		else
			ground[#ground + 1] = entry
		end
	end

	-- collect resolved point list for a way
	local function buildPts(way)
		local pts = {}
		for _, id in ipairs(way.nodeRefs) do
			local n = level.nodes[id]
			if n then pts[#pts + 1] = n end
		end
		return pts
	end

	-- resolve draw points (bezier sampled or raw)
	local function resolvePts(way, pts)
		local curve = way.tags and way.tags.curve or "linear"
		if curve == "bezier" and (#pts == 3 or #pts == 4) then
			return sampleBezier(pts, 40)
		end
		return pts
	end

	-- per-way color and line width based on type, state, layer
	local function wayStyle(idx, way, layer)
		local curve     = way.tags and way.tags.curve or "linear"
		local wtype     = way.tags and way.tags.type
		local isSelected = (selectedWay == idx)
		local isHovered  = (hoveredWay  == idx)

		local r, g, b, a, lw

		if wtype == "in" then
			if isSelected then
				r, g, b, a, lw = 0.20, 1.00, 0.45, 1.0, 4
			elseif isHovered then
				r, g, b, a, lw = 0.50, 1.00, 0.65, 1.0, 3
			else
				r, g, b, a, lw = 0.15, 0.80, 0.35, 1.0, 2
			end
		elseif wtype == "out" then
			if isSelected then
				r, g, b, a, lw = 1.00, 0.25, 0.25, 1.0, 4
			elseif isHovered then
				r, g, b, a, lw = 1.00, 0.55, 0.45, 1.0, 3
			else
				r, g, b, a, lw = 0.85, 0.20, 0.20, 1.0, 2
			end
		elseif curve == "bezier" then
			if isSelected then
				r, g, b, a, lw = 1.0, 0.55, 0.10, 1.0, 4
			elseif isHovered then
				r, g, b, a, lw = 0.55, 0.90, 1.0, 1.0, 3
			else
				r, g, b, a, lw = 0.20, 0.80, 1.0, 1.0, 2
			end
		else
			if isSelected then
				r, g, b, a, lw = 1.0, 0.35, 0.35, 1.0, 4
			elseif isHovered then
				r, g, b, a, lw = 1.0, 0.90, 0.30, 1.0, 3
			else
				r, g, b, a, lw = 0.90, 0.90, 0.90, 1.0, 2
			end
		end

		-- dim underpass roads
		if layer < 0 then
			r, g, b = r * 0.55, g * 0.55, b * 0.55
			a = a * 0.75
		end

		return r, g, b, a, lw
	end

	-- draw the road deck surface, handles, arrows for one way
	local function drawSurface(idx, way, layer, rawPts, drawPts)
		local curve     = way.tags and way.tags.curve or "linear"
		local wtype     = way.tags and way.tags.type
		local isSelected = (selectedWay == idx)
		local isHovered  = (hoveredWay  == idx)
		local r, g, b, a, lw = wayStyle(idx, way, layer)

		love.graphics.setLineWidth(lw)
		love.graphics.setColor(r, g, b, a)
		drawPolyline(drawPts)

		-- bezier control handles when selected/hovered
		if curve == "bezier" and (#rawPts == 3 or #rawPts == 4) and (isSelected or isHovered) then
			local ha = isSelected and 0.9 or 0.6
			local ds = isSelected and 5   or 4

			love.graphics.setLineWidth(1)

			-- quadratic: pts[1]-pts[2]-pts[3], one shared control point
			-- cubic:     pts[1]-pts[2]...pts[3]-pts[4], two control points
			if #rawPts == 3 then
				-- line from start to control
				love.graphics.setColor(1.0, 0.85, 0.20, ha)
				love.graphics.line(rawPts[1].x, rawPts[1].y, rawPts[2].x, rawPts[2].y)
				-- line from end to control
				love.graphics.setColor(0.40, 1.0, 0.55, ha)
				love.graphics.line(rawPts[3].x, rawPts[3].y, rawPts[2].x, rawPts[2].y)
				-- control point dot
				love.graphics.setColor(1.0, 0.85, 0.20, ha)
				love.graphics.circle("fill", rawPts[2].x, rawPts[2].y, ds)
				love.graphics.setColor(0, 0, 0, 0.5)
				love.graphics.circle("line", rawPts[2].x, rawPts[2].y, ds)
			else
				-- cubic: first handle
				love.graphics.setColor(1.0, 0.85, 0.20, ha)
				love.graphics.line(rawPts[1].x, rawPts[1].y, rawPts[2].x, rawPts[2].y)
				love.graphics.circle("fill", rawPts[2].x, rawPts[2].y, ds)
				love.graphics.setColor(0, 0, 0, 0.5)
				love.graphics.circle("line", rawPts[2].x, rawPts[2].y, ds)
				-- cubic: second handle
				love.graphics.setColor(0.40, 1.0, 0.55, ha)
				love.graphics.line(rawPts[4].x, rawPts[4].y, rawPts[3].x, rawPts[3].y)
				love.graphics.circle("fill", rawPts[3].x, rawPts[3].y, ds)
				love.graphics.setColor(0, 0, 0, 0.5)
				love.graphics.circle("line", rawPts[3].x, rawPts[3].y, ds)
			end
		end

		-- bridge railings
		if layer > 0 and #drawPts >= 2 then
			drawBridgeRailings(drawPts, layer, r, g, b)
		end

		-- underpass dashed border
		if layer < 0 and #drawPts >= 2 then
			drawUnderpassBorder(drawPts, r, g, b)
		end

		-- direction arrows on in/out ways
		if wtype == "in" or wtype == "out" then
			local p1 = rawPts[1]
			local p2 = rawPts[2]
			local mx = (p1.x + p2.x) * 0.5
			local my = (p1.y + p2.y) * 0.5
			local col = (wtype == "in")
			and { 0.10, 1.00, 0.40, 0.9 }
			or  { 1.00, 0.20, 0.20, 0.9 }
			drawArrow(mx, my, p2.x - p1.x, p2.y - p1.y, 18, unpack(col))
		end
	end

	-- pass 1: underpasses
	for _, e in ipairs(under) do
		local raw  = buildPts(e.way)
		if #raw >= 2 then
			local draw = resolvePts(e.way, raw)
			drawSurface(e.idx, e.way, e.layer, raw, draw)
		end
	end

	-- pass 2: ground level
	for _, e in ipairs(ground) do
		local raw = buildPts(e.way)
		if #raw >= 2 then
			local draw = resolvePts(e.way, raw)
			drawSurface(e.idx, e.way, e.layer, raw, draw)
		end
	end

	-- pass 3: bridges — shadows first, then pillars, then deck
	for _, e in ipairs(bridge) do
		local raw = buildPts(e.way)
		if #raw >= 2 then
			local draw = resolvePts(e.way, raw)
			drawBridgeShadow(draw, e.layer)
		end
	end

	for _, e in ipairs(bridge) do
		local raw = buildPts(e.way)
		if #raw >= 2 then
			local draw = resolvePts(e.way, raw)
			drawBridgePillars(draw, e.layer)
			drawSurface(e.idx, e.way, e.layer, raw, draw)
		end
	end

	love.graphics.setLineWidth(1)
end

--
-- layer badges drawn at way midpoints in the editor
--

function M.drawLayerBadges(level)
	if not level or not level.ways then return end

	for _, way in ipairs(level.ways) do
		local layer = (way.tags and tonumber(way.tags.layer)) or 0
		if layer ~= 0 then
			local n1 = way.nodeRefs[1] and level.nodes[way.nodeRefs[1]]
			local n2 = way.nodeRefs[2] and level.nodes[way.nodeRefs[2]]
			if n1 and n2 then
				local mx = (n1.x + n2.x) * 0.5
				local my = (n1.y + n2.y) * 0.5

				local label = (layer > 0) and ("\xe2\x96\xb2" .. layer) or ("\xe2\x96\xbc" .. math.abs(layer))
				local col   = (layer > 0) and { 1.0, 0.85, 0.20, 0.95 } or { 0.45, 0.75, 1.0, 0.95 }

				love.graphics.setColor(0, 0, 0, 0.55)
				love.graphics.rectangle("fill", mx - 14, my - 10, 28, 18, 3, 3)
				love.graphics.setColor(col)
				love.graphics.printf(label, mx - 14, my - 8, 28, "center")
			end
		end
	end
end

--
-- nodes
--

function M.drawNodes(level, editor)
	if not level or not level.nodes then return end

	local hovered  = editor and editor.hoveredNode
	local selected = editor and editor.selectedNode

	for id, node in pairs(level.nodes) do
		local isSelected = (selected == id)
		local isHovered  = (hovered  == id)

		local r = isSelected and 8 or (isHovered and 7 or 6)

		if isSelected then
			love.graphics.setColor(1.0, 0.35, 0.35, 1.0)
		elseif isHovered then
			love.graphics.setColor(1.0, 0.85, 0.20, 1.0)
		else
			love.graphics.setColor(0.25, 0.65, 1.0, 1.0)
		end

		love.graphics.circle("fill", node.x, node.y, r)

		if isSelected then
			love.graphics.setLineWidth(2)
			love.graphics.setColor(1.0, 0.70, 0.70, 1.0)
		elseif isHovered then
			love.graphics.setLineWidth(2)
			love.graphics.setColor(1.0, 1.0, 0.60, 1.0)
		else
			love.graphics.setLineWidth(1)
			love.graphics.setColor(1, 1, 1, 0.8)
		end

		love.graphics.circle("line", node.x, node.y, r)

		if isSelected then
			love.graphics.setLineWidth(1)
			love.graphics.setColor(1.0, 0.35, 0.35, 0.35)
			love.graphics.circle("line", node.x, node.y, r + 5)
		end
	end

	love.graphics.setLineWidth(1)
end

--
-- labels
--

function M.drawNodeLabels(level)
	if not level or not level.nodes then return end

	love.graphics.setColor(0.6, 0.7, 0.8, 0.8)

	for id, node in pairs(level.nodes) do
		love.graphics.print(tostring(id), node.x + 10, node.y - 14)
	end
end

--
-- editor overlay
--

function M.drawEditorOverlay(editor)
	if editor and editor.tools and editor.tools.drawOverlay then
		editor.tools:drawOverlay()
	end
end

return M