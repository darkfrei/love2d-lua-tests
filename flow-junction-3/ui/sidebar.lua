-- ui/sidebar.lua
-- left sidebar: mode tabs and context-sensitive tool/action buttons

local Theme    = require("ui.theme")
local Renderer = require("core.renderer")
local Tunel    = require("simulation.tunel")

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
	local self        = setmetatable({}, Sidebar)
	self.context      = context
	self.mode         = mode
	self.callbacks    = callbacks or {}
	self.buttons      = {}
	self.bgFields     = {}  -- { {key, label, box} }
	self.focusedField = nil
	self:_build()
	return self
end

function Sidebar:_build()
	self.buttons  = {}
	self.bgFields = {}

	local x    = PAD
	local y    = 94
	local bw   = SIDEBAR_W - PAD * 2
	local tabW = (SIDEBAR_W - PAD * 3) / 2
	local cb   = self.callbacks

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

	local function toggleBtn(label, getState, action)
		local b = makeBtn(x, y, bw, BTN_H, label, action)
		b._getState = getState
		self.buttons[#self.buttons + 1] = b
		y = y + BTN_H + BTN_GAP
	end

	if self.mode == "editor" then
		local tools = self.context.tools
		toolBtn("Select / Move", "select",         function() tools:setMode("select")         end)
		toolBtn("Add Node",      "addNode",        function() tools:setMode("addNode")        end)
		toolBtn("Add Way",       "addWay",         function() tools:setMode("addWay")         end)
		toolBtn("Roundabout",    "addRoundabout",  function() tools:setMode("addRoundabout")  end)
		btn("New",          function() if cb.openNew    then cb.openNew()    end end)
		btn("Fit View",     function() if cb.fitView    then cb.fitView()    end end)
		btn("Load Map",     function() if cb.openLoad   then cb.openLoad()   end end)
		btn("Save Map",     function() if cb.openSave   then cb.openSave()   end end)
		btn("Set BG Image", function() if cb.openImport then cb.openImport() end end)

		self.buttons[#self.buttons + 1] = { separator = true, y = y + 2, x = x, w = bw }
		y = y + 10

		toggleBtn("Grid",           function() return Renderer.showGrid      end, function() Renderer.showGrid      = not Renderer.showGrid      end)
		toggleBtn("Snap to Grid",   function() return cb.getSnapGrid and cb.getSnapGrid() end, function() if cb.toggleSnapGrid then cb.toggleSnapGrid() end end)
		toggleBtn("Curvature Comb", function() return Renderer.showCurvature end, function() Renderer.showCurvature = not Renderer.showCurvature end)

		-- background image numeric controls, shown only if a bg image is set
		local map = self.context.map
		if map and map.meta and map.meta.bgImage then
			self.buttons[#self.buttons + 1] = { separator = true, y = y + 2, x = x, w = bw }
			y = y + 10

			local fieldH = 22
			local labelW = 44

			local function bgField(key, label, defaultVal)
				local box = { x = x + labelW, y = y, w = bw - labelW, h = fieldH }
				self.bgFields[#self.bgFields + 1] = { key = key, label = label, box = box }
				if self.fieldText == nil then self.fieldText = {} end
				if self.fieldText[key] == nil then
					self.fieldText[key] = string.format("%.2f", defaultVal or 0)
				end
				y = y + fieldH + 4
			end

			self.fieldText = self.fieldText or {}
			bgField("bgScale",   "Scl", map.meta.bgScale)
			bgField("bgOffsetX", "X",   map.meta.bgOffsetX)
			bgField("bgOffsetY", "Y",   map.meta.bgOffsetY)
		end
	else
		btn("Play / Pause", function() self.context.paused = not self.context.paused end)
		btn("Speed x1",     function() self.context.speed = 1 end)
		btn("Speed x4",     function() self.context.speed = 4 end)

		self.buttons[#self.buttons + 1] = { separator = true, y = y + 2, x = x, w = bw }
		y = y + 10

		toggleBtn("BG Image", function() return Renderer.showBgImage end, function() Renderer.showBgImage = not Renderer.showBgImage end)
		toggleBtn("Grid",     function() return Renderer.showGrid    end, function() Renderer.showGrid    = not Renderer.showGrid    end)
		toggleBtn("Roads",    function() return Renderer.showWays    end, function() Renderer.showWays    = not Renderer.showWays    end)
		toggleBtn("Tunnels",  function() return Tunel.showTunnels    end, function() Tunel.showTunnels    = not Tunel.showTunnels    end)
	end
	self.bottomY = y
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
		elseif b._getState then
			drawBtn(b, b._getState() == true)
		else
			drawBtn(b, false)
		end
	end

	-- background image fields
	for _, f in ipairs(self.bgFields) do
		local box = f.box
		love.graphics.setColor(C.value)
		love.graphics.setFont(Theme.font.small)
		love.graphics.print(f.label, box.x - 40, box.y + 4)

		local focused = (self.focusedField == f.key)
		love.graphics.setColor(focused and C.inputTextBg or C.btnNormal)
		love.graphics.rectangle("fill", box.x, box.y, box.w, box.h, 3, 3)
		love.graphics.setColor(focused and C.accent or C.panelBdr)
		love.graphics.rectangle("line", box.x, box.y, box.w, box.h, 3, 3)
		love.graphics.setColor(C.value)
		love.graphics.print(self.fieldText[f.key] or "", box.x + 4, box.y + 4)
	end
end

function Sidebar:_applyBgField(key)
	local map = self.context.map
	if not (map and map.meta) then return end
	local v = tonumber(self.fieldText[key])
	if not v then return end
	map.meta[key] = v
end

function Sidebar:mousepressed(x, y)
	if x >= SIDEBAR_W then return false end

	for _, f in ipairs(self.bgFields) do
		local box = f.box
		if x >= box.x and x <= box.x + box.w and y >= box.y and y <= box.y + box.h then
			self.focusedField = f.key
			return true
		end
	end
	if self.focusedField then
		self:_applyBgField(self.focusedField)
		self.focusedField = nil
	end

	for _, b in ipairs(self.buttons) do
		if not b.separator and btnHit(b, x, y) and b.action then
			b.action()
			return true
		end
	end
	return false
end

function Sidebar:textinput(t)
	if self.focusedField and t:match("[0-9%.%-]") then
		self.fieldText[self.focusedField] = (self.fieldText[self.focusedField] or "") .. t
	end
end

function Sidebar:keypressed(k)
	if not self.focusedField then return false end
	if k == "backspace" then
		local key = self.focusedField
		self.fieldText[key] = (self.fieldText[key] or ""):sub(1, -2)
		return true
	elseif k == "return" then
		self:_applyBgField(self.focusedField)
		self.focusedField = nil
		return true
	elseif k == "escape" then
		self.focusedField = nil
		return true
	elseif k == "tab" then
		self:_applyBgField(self.focusedField)
		-- cycle to next field
		local keys = {}
		for _, f in ipairs(self.bgFields) do keys[#keys+1] = f.key end
		local idx = 1
		for i, kk in ipairs(keys) do if kk == self.focusedField then idx = i end end
		self.focusedField = keys[(idx % #keys) + 1]
		return true
	end
	return false
end

return Sidebar