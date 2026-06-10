-- ui/theme.lua
-- shared colors, font references, and button drawing primitives

local Theme = {}

Theme.SIDEBAR_W = 220
Theme.PAD       = 10
Theme.BTN_H     = 34
Theme.BTN_GAP   = 4

Theme.C = {
	sidebar      = {0.09, 0.10, 0.13, 0.96},
	panel        = {0.12, 0.13, 0.17, 0.93},
	panelBdr     = {0.20, 0.25, 0.35, 1},
	btnNormal    = {0.16, 0.19, 0.26, 1},
	btnHover     = {0.22, 0.28, 0.40, 1},
	btnActive    = {0.20, 0.50, 0.90, 1},
	btnText      = {0.85, 0.90, 1.00, 1},
	btnTextAct   = {1.00, 1.00, 1.00, 1},
	separator    = {0.20, 0.24, 0.32, 1},
	accent       = {0.25, 0.65, 1.00, 1},
	value        = {0.85, 0.92, 1.00, 1},
	inputTextBg  = {0.06, 0.07, 0.09, 1},
	layerBridge  = {1.00, 0.85, 0.20, 1},
	layerGround  = {0.40, 0.45, 0.55, 1},
	layerUnder   = {0.45, 0.75, 1.00, 1},
}

-- font table — populated by Theme.load()
Theme.font = {}

function Theme.load()
	Theme.font.normal = love.graphics.newFont(13)
	Theme.font.small  = love.graphics.newFont(11)
end

-- button factory

function Theme.makeBtn(x, y, w, h, label, action)
	return { x = x, y = y, w = w, h = h, label = label, action = action, hover = false }
end

function Theme.btnHit(btn, mx, my)
	return mx >= btn.x and mx <= btn.x + btn.w
	   and my >= btn.y and my <= btn.y + btn.h
end

function Theme.drawBtn(btn, active)
	local C   = Theme.C
	local col = active and C.btnActive or (btn.hover and C.btnHover or C.btnNormal)

	love.graphics.setColor(0, 0, 0, 0.35)
	love.graphics.rectangle("fill", btn.x + 1, btn.y + 2, btn.w, btn.h, 4, 4)

	love.graphics.setColor(col)
	love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.h, 4, 4)

	love.graphics.setColor(active and C.accent or C.panelBdr)
	love.graphics.rectangle("line", btn.x, btn.y, btn.w, btn.h, 4, 4)

	love.graphics.setColor(active and C.btnTextAct or C.btnText)
	love.graphics.setFont(Theme.font.normal)
	love.graphics.printf(btn.label, btn.x, btn.y + (btn.h - 13) / 2, btn.w, "center")
end

return Theme