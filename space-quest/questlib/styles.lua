local styles = {}

styles.font_paths = {
	regular          = {path = 'fonts/Roboto-Regular.ttf', size = 20},
	bold             = {path = 'fonts/Roboto-SemiBold.ttf', size = 20},
	italic           = {path = 'fonts/Roboto-Italic.ttf', size = 20},
	bold_italic      = {path = 'fonts/Roboto-SemiBoldItalic.ttf', size = 20},
	mono             = {path = 'fonts/RobotoMono-SemiBold.ttf', size = 18},
	mono_italic      = {path = 'fonts/RobotoMono-Italic.ttf', size = 18},
	mono_bold        = {path = 'fonts/RobotoMono-SemiBold.ttf', size = 18},
	mono_bold_italic = {path = 'fonts/RobotoMono-SemiBoldItalic.ttf', size = 18}
}

styles.colors = {
	default        = {1, 1, 1, 1},
	bold           = {1, 1, 1, 1},
	highlight  = {1, 1, 0.6, 1},    -- yellow for variables <var>
	tag_highlight  = {0.6, 0.9, 1, 1},  -- cyan for manual ==text==
	italic         = {1, 1, 1, 1},
	strike         = {1, 1, 1, 1},
	transition     = {1, 1, 1, 1}
}

styles.indent_size = 20 -- pixels per indentation level

local loaded_fonts = {}

local function load_font(path, size)
--	if love.filesystem.exists(path) then
	if love.filesystem.getInfo(path) then
		return love.graphics.newFont(path, size)
	end
	return love.graphics.newFont(size)
end

function styles.init()
	print("[styles] loading fonts...")
	for key, cfg in pairs(styles.font_paths) do
		loaded_fonts[key] = load_font(cfg.path, cfg.size)
	end
	print("[styles] fonts loaded successfully")
end

function styles.resolve_font(seg)
	local is_mono = seg.mono
	local is_bold = seg.bold
	local is_italic = seg.italic

	if is_mono then
		if is_bold and is_italic then return loaded_fonts.mono_bold_italic
		elseif is_bold then return loaded_fonts.mono_bold
		elseif is_italic then return loaded_fonts.mono_italic
		else return loaded_fonts.mono end
	else
		if is_bold and is_italic then return loaded_fonts.bold_italic
		elseif is_bold then return loaded_fonts.bold
		elseif is_italic then return loaded_fonts.italic
		else return loaded_fonts.regular end
	end
end

function styles.resolve_color(seg, is_transition)
	if is_transition then return styles.colors.transition end
	if seg.strike then return styles.colors.strike
	elseif seg.highlight then return styles.colors.highlight
	elseif seg.tag_highlight then return styles.colors.tag_highlight
	elseif seg.var_highlight then return styles.colors.var_highlight
	elseif seg.italic then return styles.colors.italic
	elseif seg.bold then return styles.colors.bold
	else return styles.colors.default end
end

function styles.get_font(key)
	return loaded_fonts[key] or loaded_fonts.regular
end

return styles