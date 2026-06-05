-- core/renderer.lua
-- rendering of static level geometry, road splines, and grid

local M = {}

-- helper functions

local function drawPolyline(points)
	for i = 1, #points - 1 do
		love.graphics.line(
			points[i].x, points[i].y,
			points[i + 1].x, points[i + 1].y
		)
	end
end

local function sampleBezier(pts, steps)
	local out = {}

	for i = 0, steps do
		local t = i / steps
		local u = 1 - t

		local x =
		u ^ 3 * pts[1].x +
		3 * u ^ 2 * t * pts[2].x +
		3 * u * t ^ 2 * pts[3].x +
		t ^ 3 * pts[4].x

		local y =
		u ^ 3 * pts[1].y +
		3 * u ^ 2 * t * pts[2].y +
		3 * u * t ^ 2 * pts[3].y +
		t ^ 3 * pts[4].y

		out[#out + 1] = { x = x, y = y }
	end

	return out
end

-- background and grid rendering

function M.drawBackground()
	love.graphics.clear(0.08, 0.10, 0.12)
end

function M.drawGrid(camera)
	local size = 80

	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()

	local leftTopX, leftTopY = camera:toWorld(0, 0)
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

-- ways rendering

function M.drawWays(level, editor)
	if not level or not level.ways then
		return
	end

	local hoveredWay = editor and editor.hoveredWay
	local selectedWay = editor and editor.selectedWay

	for idx, way in ipairs(level.ways) do
		local curve = way.tags and way.tags.curve or "linear"

		local pts = {}

		for _, id in ipairs(way.nodeRefs) do
			local n = level.nodes[id]
			if n then
				pts[#pts + 1] = n
			end
		end

		if #pts >= 2 then
			local isSelected = (selectedWay == idx)
			local isHovered = (hoveredWay == idx)

			local r, g, b, a, lw

			if curve == "bezier" then
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

			love.graphics.setLineWidth(lw)
			love.graphics.setColor(r, g, b, a)

			if curve == "linear" then
				drawPolyline(pts)

			elseif curve == "bezier" and #pts == 4 then
				drawPolyline(sampleBezier(pts, 40))

				if isSelected or isHovered then
					local ha = isSelected and 0.9 or 0.6
					local ds = isSelected and 5 or 4

					love.graphics.setLineWidth(1)

					-- control handle 1: anchor to ctrl1
					love.graphics.setColor(1.0, 0.85, 0.20, ha)
					love.graphics.line(pts[1].x, pts[1].y, pts[2].x, pts[2].y)

					love.graphics.circle("fill", pts[2].x, pts[2].y, ds)
					love.graphics.setColor(0, 0, 0, 0.5)
					love.graphics.circle("line", pts[2].x, pts[2].y, ds)

					-- control handle 2: anchor to ctrl2
					love.graphics.setColor(0.40, 1.0, 0.55, ha)
					love.graphics.line(pts[4].x, pts[4].y, pts[3].x, pts[3].y)

					love.graphics.circle("fill", pts[3].x, pts[3].y, ds)
					love.graphics.setColor(0, 0, 0, 0.5)
					love.graphics.circle("line", pts[3].x, pts[3].y, ds)
				end
			end
		end
	end

	love.graphics.setLineWidth(1)
end

-- nodes rendering

function M.drawNodes(level, editor)
	if not level or not level.nodes then
		return
	end

	local hovered = editor and editor.hoveredNode
	local selected = editor and editor.selectedNode

	for id, node in pairs(level.nodes) do
		local isSelected = (selected == id)
		local isHovered = (hovered == id)

		local r = isSelected and 8 or (isHovered and 7 or 6)

		-- fill
		if isSelected then
			love.graphics.setColor(1.0, 0.35, 0.35, 1.0)
		elseif isHovered then
			love.graphics.setColor(1.0, 0.85, 0.20, 1.0)
		else
			love.graphics.setColor(0.25, 0.65, 1.0, 1.0)
		end

		love.graphics.circle("fill", node.x, node.y, r)

		-- outline
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

		-- selection glow ring
		if isSelected then
			love.graphics.setLineWidth(1)
			love.graphics.setColor(1.0, 0.35, 0.35, 0.35)
			love.graphics.circle("line", node.x, node.y, r + 5)
		end
	end

	love.graphics.setLineWidth(1)
end

-- node labels

function M.drawNodeLabels(level)
	if not level or not level.nodes then
		return
	end

	love.graphics.setColor(0.6, 0.7, 0.8, 0.8)

	for id, node in pairs(level.nodes) do
		love.graphics.print(tostring(id), node.x + 10, node.y - 14)
	end
end

-- editor overlay

function M.drawEditorOverlay(editor)
	if not editor then
		return
	end

	if editor.tools and editor.tools.drawOverlay then
		editor.tools:drawOverlay()
	end
end

return M