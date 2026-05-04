local questlib = require('questlib')
local styles = require('questlib.styles')

local questgame = {}
local current_node = nil

local function draw_text_wrapped(text, font, x, y, start_x, max_x, lh)
	local words = {}
	for word in (text .. " "):gmatch("([^ ]*) ") do
		table.insert(words, word)
	end

	for i, word in ipairs(words) do
		local display = word .. (i < #words and " " or "")
		local w = font:getWidth(display)

		if x + w > max_x and x > start_x then
			x = start_x
			y = y + lh
		end

		love.graphics.print(display, x, y)
		x = x + w
	end

	return x, y
end

local function draw_segments(segments, start_x, y, max_width, is_transition)
	if not segments then return y end

	local x = start_x
	local line_h = styles.get_font('regular'):getHeight() + 4
	local line_start_x = start_x

	if is_transition then
		local pfx_font = styles.get_font('italic')
		love.graphics.setFont(pfx_font)
		love.graphics.setColor(styles.colors.transition)
		love.graphics.print(">> ", x, y)
		local pfx_w = pfx_font:getWidth(">> ")
		x = x + pfx_w
		line_start_x = x
	end

	for _, seg in ipairs(segments) do
		if seg.newline then
			x = line_start_x
			y = y + line_h
		else
			if seg.indent then
				line_start_x = start_x + seg.indent * styles.indent_size
				x = line_start_x
			end

			local current_font
			if is_transition and not seg.bold then
				current_font = seg.italic == false and styles.get_font('regular')
				or styles.get_font('italic')
			else
				current_font = styles.resolve_font(seg)
			end
			love.graphics.setFont(current_font)

			if seg.highlight then
				love.graphics.setColor(1, 1, 0.6, 1)
			else
				love.graphics.setColor(styles.resolve_color(seg, is_transition))
			end

--			local w = current_font:getWidth(seg.text)

--			if x + w > start_x + max_width and x > line_start_x then
--				x = line_start_x
--				y = y + line_h
--			end

--			love.graphics.print(seg.text, x, y)

--			if seg.strike then
--				local mid_y = y + current_font:getHeight() / 2
--				love.graphics.setLineWidth(1)
--				love.graphics.line(x, mid_y, x + w, mid_y)
--			end

--			x = x + w

			x, y = draw_text_wrapped(seg.text, current_font, x, y, line_start_x, start_x + max_width, line_h)


		end
	end

	love.graphics.setColor(1, 1, 1, 1)
	return y + line_h
end




local function draw_stats_panel(node, px, py, pw, ph)
	if not node or not node.stats or #node.stats == 0 then return end

	local sx = px + 15
	local sy = py + 15
	local max_pw = pw - 30
	local max_sy = py + ph - 15

	local font = styles.get_font('regular')
	local lh = font:getHeight() + 4
	local wrap_lh = font:getHeight() - 6

	love.graphics.setFont(font)
	love.graphics.setColor(0.75, 0.75, 0.75, 1)
	love.graphics.print("[STATUS]", sx, sy)
	sy = sy + lh + 4

	for _, line_segments in ipairs(node.stats) do
		if sy > max_sy then break end

		local x = sx
		local line_max_x = sx + max_pw

		for _, seg in ipairs(line_segments) do
			if seg.newline then
				x = sx
				sy = sy + lh
			else
				local seg_font = styles.resolve_font(seg)
				love.graphics.setFont(seg_font)

				if seg.highlight then
					love.graphics.setColor(1, 1, 0.6, 1)
				else
					love.graphics.setColor(styles.resolve_color(seg, false))
				end

				x, sy = draw_text_wrapped(seg.text, seg_font, x, sy, sx, line_max_x, wrap_lh)
			end
		end
		sy = sy + lh
	end
	love.graphics.setColor(1, 1, 1, 1)
end


local function get_panel_rect(sw, sh)
	local panel_w = sw * 0.3
	local panel_h = sh - 20
	local panel_x = sw - panel_w 
	local panel_y = sh - panel_h
	return panel_x, panel_y, panel_w-20, panel_h-20
end

local function draw_panel_background(px, py, pw, ph)
	love.graphics.setColor(0.06, 0.06, 0.09, 0.85)
	love.graphics.rectangle("fill", px, py, pw, ph)
	love.graphics.setColor(0.25, 0.25, 0.25, 0.6)
	love.graphics.setLineWidth(1)
	love.graphics.rectangle("line", px, py, pw, ph)
end

local function get_safe_width(sw, max_width)
	return math.min(max_width, sw * 0.6)
end

local function draw_node_text(node, start_x, start_y, max_width)
	local nx, ny = 20, 10
	local font = styles.get_font('regular')
	love.graphics.setFont(font)
	love.graphics.setColor(0.6, 0.6, 0.6, 1)
	love.graphics.print("[NODE]", nx, ny)
	
	local y = start_y + 10
	if node.after_text then
		y = draw_segments(node.after_text, start_x, y, max_width, true) + 8
	end
	y = draw_segments(node.text, start_x, y, max_width, false) + 12
	return y
end

local function draw_choices(choices, x, y)
	local font = styles.get_font('regular')
	local lh = font:getHeight() + 2

	love.graphics.setFont(font)
	love.graphics.setColor(0.6, 0.6, 0.6, 1)
	love.graphics.print("[CHOICES]", x, y)
	y = y + font:getHeight() + 4

	for _, ch in ipairs(choices) do
		love.graphics.setFont(font)
		love.graphics.setColor(ch.enabled and 1 or 0.35, ch.enabled and 1 or 0.35, ch.enabled and 1 or 0.35, 1)
		love.graphics.print("[" .. ch.index .. "] " .. ch.label, x, y)
		y = y + lh
	end

	love.graphics.setColor(1, 1, 1, 1)
	return y
end

function questgame.init()
	styles.init()
	questlib.reset()
end

function questgame.load(data)
	current_node = questlib.load(data)
end

function questgame.draw(start_x, start_y, max_width)
	local sw, sh = love.graphics.getDimensions()
	local px, py, pw, ph = get_panel_rect(sw, sh)
	local safe_max_width = get_safe_width(sw, max_width)

	draw_panel_background(px, py, pw, ph)

	if not current_node then
		love.graphics.setFont(styles.get_font('regular'))
		love.graphics.setColor(0.6, 0.6, 0.6, 1)
		love.graphics.print("[node not found or hidden]", start_x, start_y)
		love.graphics.setColor(1, 1, 1, 1)
		return
	end

	local y = draw_node_text(current_node, start_x, start_y, safe_max_width)
	y = draw_choices(current_node.choices, start_x, y)

	draw_stats_panel(current_node, px, py, pw, ph)
end

function questgame.choose(index)
	current_node = questlib.choose(index)
end

function questgame.can_choose(index)
	if not current_node or not current_node.choices then return false end
	local ch = current_node.choices[index]
	return ch and ch.enabled
end

function questgame.reset(data)
	questlib.reset()
	if data then questgame.load(data) end
end

function questgame.get_state()
	return questlib.get_state()
end

return questgame