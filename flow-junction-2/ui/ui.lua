-- ui/ui.lua

local Map         = require("core.map")
local FileManager = require("editor.filemanager")
local Exporter    = require("editor.exporter")

local UI = {}
UI.__index = UI

UI.font = {}

local SIDEBAR_W  = 220
local PAD        = 10
local BTN_H      = 34
local BTN_GAP    = 4

local C = {
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
	tagIn        = {0.10, 0.75, 0.35, 1},
	tagOut       = {0.85, 0.20, 0.20, 1},
	tagNone      = {0.40, 0.45, 0.55, 1},
}

local TYPES = { "in", "mid", "out", "turn" }

local function makeBtn(x, y, w, h, label, action)
	return {
		x = x, y = y, w = w, h = h,
		label = label,
		action = action,
		hover = false
	}
end

local function drawBtn(btn, active)
	local col = active and C.btnActive or (btn.hover and C.btnHover or C.btnNormal)

	love.graphics.setColor(0, 0, 0, 0.35)
	love.graphics.rectangle("fill", btn.x + 1, btn.y + 2, btn.w, btn.h, 4, 4)

	love.graphics.setColor(col)
	love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.h, 4, 4)

	love.graphics.setColor(active and C.accent or C.panelBdr)
	love.graphics.rectangle("line", btn.x, btn.y, btn.w, btn.h, 4, 4)

	love.graphics.setColor(active and C.btnTextAct or C.btnText)
	love.graphics.setFont(UI.font.normal)
	love.graphics.printf(
		btn.label,
		btn.x,
		btn.y + (btn.h - 13) / 2,
		btn.w,
		"center"
	)
end

local function btnHit(btn, mx, my)
	return mx >= btn.x and mx <= btn.x + btn.w
	and my >= btn.y and my <= btn.y + btn.h
end

function UI:_buildButtons()
	self.buttons = {}

	local x, y = PAD, 94
	local bw = SIDEBAR_W - PAD * 2
	local tabW = (SIDEBAR_W - PAD * 3) / 2

	-- mode tabs — active state determined in draw() by app state
	table.insert(self.buttons,
		makeBtn(PAD, 50, tabW, 30, "Editor",
			function()
				if self.context.app then
					self.context.app.setState("editor")
				end
			end
		)
	)
	self.buttons[#self.buttons]._stateKey = "editor"

	table.insert(self.buttons,
		makeBtn(PAD * 2 + tabW, 50, tabW, 30, "Simulation",
			function()
				if self.context.app then
					self.context.app.setState("simulation")
				end
			end
		)
	)
	self.buttons[#self.buttons]._stateKey = "simulation"

	table.insert(self.buttons, { separator = true, y = y - 4, x = x, w = bw })

	local function btn(l, a)
		table.insert(self.buttons, makeBtn(x, y, bw, BTN_H, l, a))
		y = y + BTN_H + BTN_GAP
	end

	if self.mode == "editor" then
		local hw = (bw - 4) / 2

		-- full-width tool buttons with _toolKey for active highlight
		local function toolBtn(l, toolKey, a)
			local b = makeBtn(x, y, bw, BTN_H, l, a)
			b._toolKey = toolKey
			table.insert(self.buttons, b)
			y = y + BTN_H + BTN_GAP
		end

		-- half-width pair for linear / bezier
		local function toolBtnPair(l1, key1, a1, l2, key2, a2)
			local b1 = makeBtn(x,          y, hw, BTN_H, l1, a1)
			local b2 = makeBtn(x + hw + 4, y, hw, BTN_H, l2, a2)
			b1._toolKey = key1
			b2._toolKey = key2
			table.insert(self.buttons, b1)
			table.insert(self.buttons, b2)
			y = y + BTN_H + BTN_GAP
		end

		toolBtn("Select / Move", "select",  function() self.context.tools:setMode("select")     end)
		toolBtn("Add Node",      "addNode", function() self.context.tools:setMode("addNode")    end)
		toolBtnPair(
			"Linear",    "addLinear", function() self.context.tools:setMode("addLinear") end,
			"Bezier",    "addBezier", function() self.context.tools:setMode("addBezier") end
		)
		btn("Fit View", function() self.context.camera:fitAll(self.context.map) end)
		btn("Load Map", function() self:openLoadDialog() end)
		btn("Save Map", function() self:openSaveDialog() end)
	else
		btn("Play / Pause", function() self.context.paused = not self.context.paused end)
		btn("Speed x1",     function() self.context.speed = 1 end)
		btn("Speed x4",     function() self.context.speed = 4 end)
	end
end

function UI.new(context, mode)
	local self = setmetatable({}, UI)

	self.context = context
	self.mode = mode
	self.buttons = {}

	self._showLoadDialog  = false
	self._showSaveDialog  = false
	self._showTagsDialog  = false
	self._fileList        = {}
	self._selectedFileIdx = nil
	self._saveFileNameInput = ""

	-- tags dialog state
	self._tagsWayIdx  = nil
	self._tagsType    = nil

	UI.font.normal = love.graphics.newFont(13)
	UI.font.small  = love.graphics.newFont(11)

	FileManager.init()
	self:_buildButtons()

	return self
end

-- 
-- load / save dialogs
-- 

function UI:openLoadDialog()
	self._showLoadDialog = true
	self._showSaveDialog = false
	self._showTagsDialog = false
	self._selectedFileIdx = nil
	self._fileList = {}

	for _, f in ipairs(FileManager.listSaves()) do
		table.insert(self._fileList, { name = f, hover = false })
	end

	table.sort(self._fileList, function(a, b)
			return a.name < b.name
		end)
end

function UI:openSaveDialog()
	self._showSaveDialog = true
	self._showLoadDialog = false
	self._showTagsDialog = false
	self._saveFileNameInput = FileManager.generateName("map"):gsub("%.lua$", "")
end

function UI:executeSave()
	local name = self._saveFileNameInput
	:gsub("^%s+", "")
	:gsub("%s+$", "")

	if name == "" then return end

	local content, err = Exporter.buildLua(self.context.map)
	if not content then
		if self.context.notify then
			self.context.notify("export failed: " .. tostring(err))
		end
		return
	end

	local ok, saveErr = FileManager.save(name .. ".lua", content)
	if not ok then
		if self.context.notify then
			self.context.notify("save failed: " .. tostring(saveErr))
		end
		return
	end

	self._showSaveDialog = false

	if self.context.notify then
		self.context.notify("saved")
	end
end

-- 
-- tags dialog
-- 

function UI:openTagsDialog(wayIdx)
	local way = self.context.map.ways[wayIdx]
	if not way then return end

	self._showTagsDialog = true
	self._showLoadDialog = false
	self._showSaveDialog = false
	self._tagsWayIdx = wayIdx
	self._tagsType   = (way.tags and way.tags.type) or nil
end

function UI:applyTags()
	if not self._tagsWayIdx then return end

	Map.setWayTags(self.context.map, self._tagsWayIdx, {
			type = self._tagsType,
		})

	self._showTagsDialog = false

	if self.context.notify then
		local t = self._tagsType or "none"
		self.context.notify("way tags updated: type=" .. t)
	end
end

function UI:clearTags()
	if not self._tagsWayIdx then return end
	Map.clearWayType(self.context.map, self._tagsWayIdx)
	self._showTagsDialog = false
	if self.context.notify then
		self.context.notify("way type cleared")
	end
end

function UI:_drawTagsDialog()
	local dw, dh = 320, 170
	local dx = (love.graphics.getWidth()  - dw) / 2
	local dy = (love.graphics.getHeight() - dh) / 2

	-- background
	love.graphics.setColor(C.panel)
	love.graphics.rectangle("fill", dx, dy, dw, dh, 8, 8)
	love.graphics.setColor(C.panelBdr)
	love.graphics.rectangle("line", dx, dy, dw, dh, 8, 8)

	-- title
	love.graphics.setColor(C.value)
	love.graphics.setFont(UI.font.normal)
	love.graphics.print("Edit Way Type", dx + PAD, dy + PAD)

	local closeBtn = makeBtn(dx + dw - 30, dy + 5, 25, 25, "X")
	drawBtn(closeBtn)
	self._tagsCloseBtn = closeBtn

	local cy = dy + 38

	-- type buttons row
	local typeW = 62
	local typeButtons = {}
	for i, t in ipairs(TYPES) do
		local bx = dx + PAD + (i - 1) * (typeW + 4)
		local active = (self._tagsType == t)

		local col
		if t == "in" then
			col = active and {0.10, 0.90, 0.40, 1} or {0.08, 0.45, 0.22, 1}
		elseif t == "out" then
			col = active and {1.00, 0.25, 0.25, 1} or {0.55, 0.12, 0.12, 1}
		else
			col = active and C.btnActive or C.btnNormal
		end

		love.graphics.setColor(0, 0, 0, 0.3)
		love.graphics.rectangle("fill", bx + 1, cy + 2, typeW, 30, 4, 4)
		love.graphics.setColor(col)
		love.graphics.rectangle("fill", bx, cy, typeW, 30, 4, 4)
		love.graphics.setColor(active and C.accent or C.panelBdr)
		love.graphics.rectangle("line", bx, cy, typeW, 30, 4, 4)
		love.graphics.setColor(C.btnTextAct)
		love.graphics.setFont(UI.font.normal)
		love.graphics.printf(t, bx, cy + 8, typeW, "center")

		typeButtons[i] = makeBtn(bx, cy, typeW, 30, t, function() self._tagsType = t end)
	end
	self._tagsTypeBtns = typeButtons
	cy = cy + 42

	-- current value
	love.graphics.setColor(C.value)
	love.graphics.setFont(UI.font.small)
	love.graphics.print("type: " .. (self._tagsType or "—"), dx + PAD, cy)
	cy = cy + 22

	-- action buttons
	local applyBtn = makeBtn(dx + PAD,       cy, 100, BTN_H, "Apply",      function() self:applyTags() end)
	local clearBtn = makeBtn(dx + PAD + 108, cy, 100, BTN_H, "Clear Type", function() self:clearTags() end)
	drawBtn(applyBtn, true)
	drawBtn(clearBtn, false)
	self._tagsApplyBtn = applyBtn
	self._tagsClearBtn = clearBtn
end

function UI:_drawLoadDialog()
	local w, h = 300, 400
	local x = (love.graphics.getWidth() - w) / 2
	local y = (love.graphics.getHeight() - h) / 2

	self._loadBounds = {
		x = x,
		y = y,
		w = w,
		h = h,
		closeBtn = makeBtn(x + w - 30, y + 5, 25, 25, "X"),
		loadBtn  = makeBtn(x + 50, y + h - 40, w - 100, 30, "Load")
	}

	love.graphics.setColor(C.panel)
	love.graphics.rectangle("fill", x, y, w, h, 8, 8)

	love.graphics.setColor(C.panelBdr)
	love.graphics.rectangle("line", x, y, w, h, 8, 8)

	for i, f in ipairs(self._fileList) do
		local iy = y + 45 + (i - 1) * 24

		love.graphics.setColor(
			self._selectedFileIdx == i and C.btnActive
			or (f.hover and C.btnHover or C.btnNormal)
		)

		love.graphics.rectangle("fill", x + 15, iy, w - 30, 20, 2, 2)

		love.graphics.setColor(C.btnText)
		love.graphics.print(f.name, x + 25, iy + 3)
	end

	drawBtn(self._loadBounds.closeBtn)
	drawBtn(self._loadBounds.loadBtn, self._selectedFileIdx ~= nil)
end

function UI:_drawSaveDialog()
	local w, h = 300, 150
	local x = (love.graphics.getWidth() - w) / 2
	local y = (love.graphics.getHeight() - h) / 2

	self._saveBounds = {
		x = x,
		y = y,
		w = w,
		h = h,
		closeBtn = makeBtn(x + w - 30, y + 5, 25, 25, "X"),
		saveBtn  = makeBtn(x + 50, y + 100, w - 100, 30, "Save")
	}

	love.graphics.setColor(C.panel)
	love.graphics.rectangle("fill", x, y, w, h, 8, 8)

	love.graphics.setColor(C.panelBdr)
	love.graphics.rectangle("line", x, y, w, h, 8, 8)

	love.graphics.setColor(C.inputTextBg)
	love.graphics.rectangle("fill", x + 30, y + 50, w - 60, 30)

	love.graphics.setColor(C.value)
	love.graphics.print(self._saveFileNameInput .. ".lua", x + 40, y + 57)

	drawBtn(self._saveBounds.closeBtn)
	drawBtn(self._saveBounds.saveBtn)
end

-- 
-- way info panel (drawn in sidebar when a way is selected)
-- 

function UI:_drawWayPanel()
	if self.mode ~= "editor" then return end

	local selectedWay = self.context.selectedWay
	if not selectedWay then return end

	local way = self.context.map.ways[selectedWay]
	if not way then return end

	local tags = way.tags or {}
	local wtype = tags.type or "—"

	local px = PAD
	local py = 340
	local pw = SIDEBAR_W - PAD * 2

	-- panel background
	love.graphics.setColor(C.panel)
	love.graphics.rectangle("fill", px, py, pw, 130, 6, 6)
	love.graphics.setColor(C.panelBdr)
	love.graphics.rectangle("line", px, py, pw, 130, 6, 6)

	love.graphics.setFont(UI.font.small)

	-- title
	local titleCol = {1, 1, 1, 1}
	if wtype == "in"  then titleCol = {0.20, 1.00, 0.50, 1} end
	if wtype == "out" then titleCol = {1.00, 0.30, 0.30, 1} end
	love.graphics.setColor(titleCol)
	love.graphics.print("Way #" .. tostring(way.id or selectedWay), px + 8, py + 8)

	love.graphics.setColor(C.btnText)
	love.graphics.print("type:  " .. wtype, px + 8, py + 26)
	love.graphics.print("nodes: " .. #way.nodeRefs, px + 8, py + 42)

	-- edit button
	local editBtn = makeBtn(px + 4, py + 64, pw - 8, BTN_H, "Edit Tags", function()
			self:openTagsDialog(selectedWay)
		end)
	drawBtn(editBtn, false)
	self._wayEditBtn = editBtn

	-- clear type button
	local clearBtn = makeBtn(px + 4, py + 64 + BTN_H + BTN_GAP, pw - 8, BTN_H - 6, "Clear Type", function()
			Map.clearWayType(self.context.map, selectedWay)
			if self.context.notify then
				self.context.notify("way type cleared")
			end
		end)
	drawBtn(clearBtn, false)
	self._wayClearBtn = clearBtn
end

-- 
-- update
-- 

function UI:update(dt)
	local mx, my = love.mouse.getPosition()

	if self._showLoadDialog and self._loadBounds then
		for i, f in ipairs(self._fileList) do
			local iy = self._loadBounds.y + 45 + (i - 1) * 24
			f.hover = (
				mx >= self._loadBounds.x + 15 and
				mx <= self._loadBounds.x + 285 and
				my >= iy and my <= iy + 20
			)
		end
	elseif not self._showSaveDialog and not self._showTagsDialog then
		for _, b in ipairs(self.buttons) do
			if not b.separator then
				b.hover = btnHit(b, mx, my)
			end
		end
	end
end

-- 
-- draw
-- 

function UI:draw()
	local appState = self.context.app and self.context.app.getState and self.context.app.getState()

	love.graphics.setColor(C.sidebar)
	love.graphics.rectangle("fill", 0, 0, SIDEBAR_W, love.graphics.getHeight())

	local toolMode = self.context.tools and self.context.tools:getMode()

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

	-- way info panel in sidebar
	self:_drawWayPanel()

	if self._showLoadDialog then self:_drawLoadDialog() end
	if self._showSaveDialog  then self:_drawSaveDialog() end
	if self._showTagsDialog  then self:_drawTagsDialog() end
end

-- 
-- input
-- 

function UI:mousemoved(x, y, dx, dy)
	return x < SIDEBAR_W or self._showLoadDialog or self._showSaveDialog or self._showTagsDialog
end

function UI:mousereleased(x, y, b)
	return x < SIDEBAR_W or self._showLoadDialog or self._showSaveDialog or self._showTagsDialog
end

function UI:wheelmoved(dx, dy)
	return love.mouse.getX() < SIDEBAR_W or self._showLoadDialog or self._showSaveDialog or self._showTagsDialog
end

function UI:mousepressed(x, y, b)

	-- tags dialog
	if self._showTagsDialog then
		if self._tagsCloseBtn and btnHit(self._tagsCloseBtn, x, y) then
			self._showTagsDialog = false
			return true
		end
		if self._tagsApplyBtn and btnHit(self._tagsApplyBtn, x, y) then
			self:applyTags()
			return true
		end
		if self._tagsClearBtn and btnHit(self._tagsClearBtn, x, y) then
			self:clearTags()
			return true
		end
		if self._tagsTypeBtns then
			for i, tbtn in ipairs(self._tagsTypeBtns) do
				if btnHit(tbtn, x, y) then
					self._tagsType = TYPES[i]
					return true
				end
			end
		end

		return true
	end

	-- load dialog
	if self._showLoadDialog and self._loadBounds then
		if btnHit(self._loadBounds.closeBtn, x, y) then
			self._showLoadDialog = false
		elseif btnHit(self._loadBounds.loadBtn, x, y) and self._selectedFileIdx then
			if Map.loadFromFile(self.context.map, self._fileList[self._selectedFileIdx].name) then
				self.context.camera:fitAll(self.context.map)
			end
			self._showLoadDialog = false
		end

		for i, f in ipairs(self._fileList) do
			local iy = self._loadBounds.y + 45 + (i - 1) * 24
			if x >= self._loadBounds.x + 15 and x <= self._loadBounds.x + 285
			and y >= iy and y <= iy + 20 then
				self._selectedFileIdx = i
			end
		end

		return true
	end

	-- save dialog
	if self._showSaveDialog and self._saveBounds then
		if btnHit(self._saveBounds.closeBtn, x, y) then
			self._showSaveDialog = false
		elseif btnHit(self._saveBounds.saveBtn, x, y) then
			self:executeSave()
		end
		return true
	end

	-- sidebar
	if x < SIDEBAR_W then
		-- way panel buttons
		if self._wayEditBtn and btnHit(self._wayEditBtn, x, y) then
			self._wayEditBtn.action()
			return true
		end
		if self._wayClearBtn and btnHit(self._wayClearBtn, x, y) then
			self._wayClearBtn.action()
			return true
		end

		for _, btn in ipairs(self.buttons) do
			if not btn.separator and btnHit(btn, x, y) and btn.action then
				btn.action()
				return true
			end
		end
	end

	return false
end

function UI:keypressed(k)
	if self._showTagsDialog then
		if k == "escape" then
			self._showTagsDialog = false
		elseif k == "return" then
			self:applyTags()
		end
		return true
	end

	if self._showSaveDialog then
		if k == "escape" then
			self._showSaveDialog = false
		elseif k == "backspace" then
			self._saveFileNameInput = self._saveFileNameInput:sub(1, -2)
		elseif k == "return" then
			self:executeSave()
		end
		return true
	end

	if self._showLoadDialog and k == "escape" then
		self._showLoadDialog = false
		return true
	end
end

function UI:textinput(t)
	if self._showSaveDialog and t:match("[A-Za-z0-9_%-%s]") then
		self._saveFileNameInput = self._saveFileNameInput .. t
	end
end

return UI