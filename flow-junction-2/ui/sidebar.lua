-- ui/sidebar.lua
-- left sidebar: mode tabs and context-sensitive tool/action buttons

local Theme = require("ui.theme")

local C       = Theme.C
local PAD     = Theme.PAD
local BTN_H   = Theme.BTN_H
local BTN_GAP = Theme.BTN_GAP
local makeBtn = Theme.makeBtn
local drawBtn = Theme.drawBtn
local btnHit  = Theme.btnHit

local SIDEBAR_W = Theme.SIDEBAR_W

local Sidebar = {}
Sidebar.__index = Sidebar

function Sidebar.new(context, mode, callbacks)
	-- callbacks: { openLoad, openSave, fitView }
	local self      = setmetatable({}, Sidebar)
	self.context    = context
	self.mode       = mode
	self.callbacks  = callbacks or {}
	self.buttons    = {}
	self:_build()
	return self
end

function Sidebar:_build()
	self.buttons = {}

	local x   = PAD
	local y   = 94
	local bw  = SIDEBAR_W - PAD * 2
	local tabW = (SIDEBAR_W - PAD * 3) / 2
	local cb  = self.callbacks

	-- mode tabs
	local editorTab = makeBtn(PAD, 50, tabW, 30, "Editor", function()
		if self.context.app then self.context.app.setState("editor") end
	end)
	editorTab._stateKey = "editor"
	self.buttons[#self.buttons + 1] = editorTab

	local simTab = makeBtn(PAD * 2 + tabW, 50, tabW, 30, "Simulation", function()
		if self.context.app then self.context.app.setState("simulation") end
	end)
	simTab._stateKey = "simulation"
	self.buttons[#self.buttons + 1] = simTab

	self.buttons[#self.buttons + 1] = { separator = true, y = y - 4, x = x, w = bw }

	local function btn(label, action)
		self.buttons[#self.buttons + 1] = makeBtn(x, y, bw, BTN_H, label, action)
		y = y + BTN_H + BTN_GAP
	end

	local function toolBtn(label, toolKey, action)
		local b = makeBtn(x, y, bw, BTN_H, label, action)
		b._toolKey = toolKey
		self.buttons[#self.buttons + 1] = b
		y = y + BTN_H + BTN_GAP
	end

	if self.mode == "editor" then
		local tools = self.context.tools
		toolBtn("Select / Move", "select",    function() tools:setMode("select")    end)
		toolBtn("Add Node",      "addNode",   function() tools:setMode("addNode")   end)
		toolBtn("Add Way", "addWay", function() tools:setMode("addWay") end)
		btn("Fit View", function() if cb.fitView then cb.fitView() end end)
		btn("Load Map", function() if cb.openLoad then cb.openLoad() end end)
		btn("Save Map", function() if cb.openSave then cb.openSave() end end)
	else
		btn("Play / Pause", function() self.context.paused = not self.context.paused end)
		btn("Speed x1",     function() self.context.speed = 1 end)
		btn("Speed x4",     function() self.context.speed = 4 end)
	end
end

function Sidebar:update(mx, my)
	for _, b in ipairs(self.buttons) do
		if not b.separator then
			b.hover = btnHit(b, mx, my)
		end
	end
end

function Sidebar:draw()
	local appState = self.context.app and self.context.app.getState and self.context.app.getState()
	local toolMode = self.context.tools and self.context.tools:getMode()

	love.graphics.setColor(C.sidebar)
	love.graphics.rectangle("fill", 0, 0, SIDEBAR_W, love.graphics.getHeight())

	for _, b in ipairs(self.buttons) do
		if b.separator then
			love.graphics.setColor(C.separator)
			love.graphics.line(b.x, b.y, b.x + b.w, b.y)
		elseif b._stateKey then
			drawBtn(b, appState == b._stateKey)
		elseif b._toolKey then
			drawBtn(b, toolMode == b._toolKey)
		else
			drawBtn(b, false)
		end
	end
end

function Sidebar:mousepressed(x, y)
	if x >= SIDEBAR_W then return false end
	for _, b in ipairs(self.buttons) do
		if not b.separator and btnHit(b, x, y) and b.action then
			b.action()
			return true
		end
	end
	return false
end

return Sidebar