-- editor/editor-ui.lua
-- toolbar and sidebar panels for network editor interface

local Map = require("core/map")

local UI = {}
UI.__index = UI

local SIDEBAR_W = 220
local PAD = 10
local BTN_H = 34
local BTN_GAP = 4

local COLORS = {
	sidebar = {0.09, 0.10, 0.13, 0.96},
	sidebarBorder = {0.22, 0.28, 0.40, 1},

	panel = {0.12, 0.13, 0.17, 0.93},
	panelBorder = {0.20, 0.25, 0.35, 1},

	buttonNormal = {0.16, 0.19, 0.26, 1},
	buttonHover = {0.22, 0.28, 0.40, 1},
	buttonActive = {0.20, 0.50, 0.90, 1},

	text = {0.85, 0.88, 0.93, 1},
}

function UI.new(editor)
	local self = setmetatable({}, UI)

	self.editor = editor
	self.buttons = {}

	self:initButtons()

	return self
end

function UI:initButtons()
	self.buttons = {
		{
			text = "mode select esc",
			action = function()
				self.editor.tools:setMode("select")
			end,
			mode = "select"
		},
		{
			text = "add node",
			action = function()
				self.editor.tools:setMode("addNode")
			end,
			mode = "addNode"
		},
		{
			text = "build way",
			action = function()
				self.editor.tools:setMode("addWay")
			end,
			mode = "addWay"
		},
		{
			separator = true,
			h = 20
		},
		{
			text = "run simulation f2",
			action = function()
				love.keypressed("f2")
			end
		}
	}
end

function UI:mousepressed(x, y, button)
	if button ~= 1 then
		return false
	end

	if x < SIDEBAR_W then
		local currentY = PAD + 40

		for _, b in ipairs(self.buttons) do
			if b.separator then
				currentY = currentY + b.h
			else
				local bx = PAD
				local by = currentY
				local bw = SIDEBAR_W - PAD * 2
				local bh = BTN_H

				if x >= bx and x <= bx + bw and y >= by and y <= by + bh then
					b.action()
					return true
				end

				currentY = currentY + BTN_H + BTN_GAP
			end
		end

		return true
	end

	return false
end

function UI:mousereleased(x, y, button)
	return false
end

function UI:wheelmoved(x, y)
	return false
end

function UI:keypressed(key)
	return false
end

function UI:textinput(t)
end

function UI:draw()
	local sh = love.graphics.getHeight()
	local mx, my = love.mouse.getPosition()

	love.graphics.setColor(COLORS.sidebar)
	love.graphics.rectangle("fill", 0, 0, SIDEBAR_W, sh)

	love.graphics.setColor(COLORS.sidebarBorder)
	love.graphics.line(SIDEBAR_W, 0, SIDEBAR_W, sh)

	love.graphics.setColor(COLORS.text)
	love.graphics.print("network editor", PAD, PAD + 5)

	local currentY = PAD + 40
	local activeMode = self.editor.tools:getMode()

	for _, b in ipairs(self.buttons) do
		if b.separator then
			currentY = currentY + b.h
		else
			local bx = PAD
			local by = currentY
			local bw = SIDEBAR_W - PAD * 2
			local bh = BTN_H

			local isHovered =
			mx >= bx and mx <= bx + bw and
			my >= by and my <= by + bh

			if b.mode == activeMode then
				love.graphics.setColor(COLORS.buttonActive)
			elseif isHovered then
				love.graphics.setColor(COLORS.buttonHover)
			else
				love.graphics.setColor(COLORS.buttonNormal)
			end

			love.graphics.rectangle("fill", bx, by, bw, bh, 4)

			love.graphics.setColor(COLORS.text)
			love.graphics.print(b.text, bx + 10, by + 10)

			currentY = currentY + BTN_H + BTN_GAP
		end
	end
end

return UI