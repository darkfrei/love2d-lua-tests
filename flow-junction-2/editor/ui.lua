-- editor/ui.lua
-- sidebar management and modal file dialog windows for editor interface

local Map         = require("core/map")
local FileManager = require("editor/filemanager")
local Exporter    = require("editor/exporter")

local UI = {}
UI.__index = UI

UI.font = {}

local SIDEBAR_W = 220
local PAD = 10
local BTN_H = 34
local BTN_GAP = 4

local C = {
	sidebar = {0.09, 0.10, 0.13, 0.96},
	sidebarBdr = {0.22, 0.28, 0.40, 1},
	panel = {0.12, 0.13, 0.17, 0.93},
	panelBdr = {0.20, 0.25, 0.35, 1},
	btnNormal = {0.16, 0.19, 0.26, 1},
	btnHover = {0.22, 0.28, 0.40, 1},
	btnActive = {0.20, 0.50, 0.90, 1},
	btnDanger = {0.65, 0.18, 0.18, 1},
	btnDangerHov = {0.80, 0.22, 0.22, 1},
	btnText = {0.85, 0.90, 1.00, 1},
	btnTextAct = {1.00, 1.00, 1.00, 1},
	label = {0.55, 0.65, 0.80, 1},
	value = {0.85, 0.92, 1.00, 1},
	heading = {0.60, 0.80, 1.00, 1},
	accent = {0.25, 0.65, 1.00, 1},
	modeIndicator = {0.20, 0.80, 0.50, 1},
	separator = {0.20, 0.24, 0.32, 1},
	inputTextBg = {0.06, 0.07, 0.09, 1},
}

local function makeBtn(x, y, w, h, label, action, opts)
	return {
		x = x,
		y = y,
		w = w,
		h = h,
		label = label,
		action = action,
		opts = opts or {},
		hover = false,
	}
end

local function drawBtn(btn, active)
	local col

	if active then
		col = C.btnActive
	elseif btn.opts.danger then
		col = btn.hover and C.btnDangerHov or C.btnDanger
	else
		col = btn.hover and C.btnHover or C.btnNormal
	end

	love.graphics.setColor(0, 0, 0, 0.35)
	love.graphics.rectangle("fill", btn.x + 1, btn.y + 2, btn.w, btn.h, 4, 4)

	love.graphics.setColor(col)
	love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.h, 4, 4)

	love.graphics.setColor(active and C.accent or C.panelBdr)
	love.graphics.setLineWidth(1)
	love.graphics.rectangle("line", btn.x, btn.y, btn.w, btn.h, 4, 4)

	love.graphics.setColor(active and C.btnTextAct or C.btnText)
	love.graphics.setFont(UI.font.normal)
	love.graphics.printf(
		btn.label,
		btn.x,
		btn.y + (btn.h - UI.font.normal:getHeight()) / 2,
		btn.w,
		"center"
	)
end

local function btnHit(btn, mx, my)
	return mx >= btn.x and mx <= btn.x + btn.w and
	my >= btn.y and my <= btn.y + btn.h
end

function UI.new(editor)
	local self = setmetatable({}, UI)

	self.editor = editor
	self.buttons = {}

	self._showLoadDialog = false
	self._showSaveDialog = false

	self._fileList = {}
	self._selectedFileIdx = nil
	self._saveFileNameInput = ""

	UI.font.title = love.graphics.newFont(15)
	UI.font.normal = love.graphics.newFont(13)
	UI.font.small = love.graphics.newFont(11)
	UI.font.mono = love.graphics.newFont(11)

	FileManager.init()
	self:_buildButtons()

	return self
end

function UI:_buildButtons()
	local x = PAD
	local y = 50
	local bw = SIDEBAR_W - PAD * 2

	local function btn(label, action, opts)
		local b = makeBtn(x, y, bw, BTN_H, label, action, opts)
		table.insert(self.buttons, b)
		y = y + BTN_H + BTN_GAP
		return b
	end

	btn("Select / Move", function()
			self.editor.tools:setMode("select")
		end)

	btn("Add Node", function()
			self.editor.tools:setMode("addNode")
		end)

	btn("Add Way", function()
			self.editor.tools:setMode("addWay")
		end)

	y = y + 8
	table.insert(self.buttons, { separator = true, y = y - 4, x = x, w = bw })

	btn("Fit View  [F]", function()
			self.editor.camera:fitAll(self.editor.map)
		end)

	y = y + 8
	table.insert(self.buttons, { separator = true, y = y - 4, x = x, w = bw })

	btn("Load Map  [L]", function()
			self:openLoadDialog()
		end)

	btn("Save Map  [S]", function()
			self:openSaveDialog()
		end)

	btn("Open Saves Folder", function()
			local path = love.filesystem.getSaveDirectory() .. "/saves"
			love.system.openURL("file://" .. path)
			self.editor.notify("opened saves directory")
		end)

	btn("Reset Map  [R]", function()
			Map.loadDefault(self.editor.map)
			self.editor.selectedNode = nil
			self.editor.notify("map reset to default")
		end, { danger = true })

	self._btnStartY = 50
end

function UI:openLoadDialog()
	self._showLoadDialog = true
	self._showSaveDialog = false
	self._selectedFileIdx = nil

	local saves = FileManager.listSaves()

	self._fileList = {}
	for _, file in ipairs(saves) do
		table.insert(self._fileList, { name = file, hover = false })
	end
end

function UI:openSaveDialog()
	self._showSaveDialog = true
	self._showLoadDialog = false

	local genName = FileManager.generateName("map")
	self._saveFileNameInput = genName:gsub("%.lua$", "")
end

function UI:update(dt)
	local mx, my = love.mouse.getPosition()

	if self._showLoadDialog then
		if self._loadBounds then
			local db = self._loadBounds

			for i, f in ipairs(self._fileList) do
				local itemY = db.y + 45 + (i - 1) * 24
				f.hover = (mx >= db.x + 15 and mx <= db.x + db.w - 15 and
					my >= itemY and my <= itemY + 20)
			end

			if db.closeBtn then db.closeBtn.hover = btnHit(db.closeBtn, mx, my) end
			if db.loadBtn then db.loadBtn.hover = btnHit(db.loadBtn, mx, my) end
		end

		return

	elseif self._showSaveDialog then
		if self._saveBounds then
			local db = self._saveBounds

			if db.closeBtn then db.closeBtn.hover = btnHit(db.closeBtn, mx, my) end
			if db.saveBtn then db.saveBtn.hover = btnHit(db.saveBtn, mx, my) end
		end

		return
	end

	for _, b in ipairs(self.buttons) do
		if not b.separator then
			b.hover = btnHit(b, mx, my)
		end
	end
end

function UI:draw()
	local sh = love.graphics.getHeight()

	love.graphics.setColor(C.sidebar)
	love.graphics.rectangle("fill", 0, 0, SIDEBAR_W, sh)

	love.graphics.setColor(C.sidebarBdr)
	love.graphics.setLineWidth(1)
	love.graphics.line(SIDEBAR_W, 0, SIDEBAR_W, sh)

	love.graphics.setColor(C.heading)
	love.graphics.setFont(UI.font.title)
	love.graphics.print("Intersection Editor", PAD, 12)

	love.graphics.setColor(C.accent)
	love.graphics.setLineWidth(1.5)
	love.graphics.line(PAD, 36, SIDEBAR_W - PAD, 36)

	local mode = self.editor.tools:getMode()

	love.graphics.setColor(C.modeIndicator)
	love.graphics.setFont(UI.font.small)
	love.graphics.print("mode: " .. mode, PAD, 39)

	for _, b in ipairs(self.buttons) do
		if b.separator then
			love.graphics.setColor(C.separator)
			love.graphics.setLineWidth(1)
			love.graphics.line(b.x, b.y, b.x + b.w, b.y)
		else
			local isActive = false
			if b.label:find("Select") and mode == "select" then isActive = true end
			if b.label:find("Node") and mode == "addNode" then isActive = true end
			if b.label:find("Way") and mode == "addWay" then isActive = true end

			drawBtn(b, isActive)
		end
	end

	if mode == "addWay" then self:_drawWayPanel() end
	if self.editor.selectedNode then self:_drawNodePanel() end

	self:_drawHelp()
	self:_drawCamInfo()

	if self._showLoadDialog then self:_drawLoadDialog() end
	if self._showSaveDialog then self:_drawSaveDialog() end
end

function UI:_drawLoadDialog()
	local sw, sh = love.graphics.getDimensions()

	love.graphics.setColor(0, 0, 0, 0.6)
	love.graphics.rectangle("fill", 0, 0, sw, sh)

	local dw, dh = 320, 380
	local dx, dy = (sw - dw) / 2, (sh - dh) / 2

	love.graphics.setColor(C.panel)
	love.graphics.rectangle("fill", dx, dy, dw, dh, 8, 8)

	love.graphics.setColor(C.panelBdr)
	love.graphics.rectangle("line", dx, dy, dw, dh, 8, 8)

	love.graphics.setColor(C.heading)
	love.graphics.setFont(UI.font.title)
	love.graphics.print("Load Map from /saves", dx + 15, dy + 15)

	love.graphics.setColor(C.separator)
	love.graphics.line(dx + 15, dy + 40, dx + dw - 15, dy + 40)

	if #self._fileList == 0 then
		love.graphics.setColor(C.label)
		love.graphics.print("no saves found", dx + 15, dy + 55)
	else
		love.graphics.setFont(UI.font.normal)

		for i, f in ipairs(self._fileList) do
			local itemY = dy + 45 + (i - 1) * 24

			if i == self._selectedFileIdx then
				love.graphics.setColor(C.btnActive)
				love.graphics.rectangle("fill", dx + 15, itemY, dw - 30, 20, 3)
				love.graphics.setColor(C.btnTextAct)
			elseif f.hover then
				love.graphics.setColor(C.btnHover)
				love.graphics.rectangle("fill", dx + 15, itemY, dw - 30, 20, 3)
				love.graphics.setColor(C.value)
			else
				love.graphics.setColor(C.value)
			end

			love.graphics.print(f.name, dx + 22, itemY + 2)
		end
	end

	local btnW = 100
	local btnY = dy + dh - 45

	local closeBtn = makeBtn(dx + 15, btnY, btnW, 30, "Cancel", nil)
	drawBtn(closeBtn, false)

	local loadBtn = makeBtn(dx + dw - btnW - 15, btnY, btnW, 30, "Load", nil)
	local canLoad = self._selectedFileIdx ~= nil
	drawBtn(loadBtn, false)

	self._loadBounds = {
		x = dx, y = dy, w = dw, h = dh,
		closeBtn = closeBtn,
		loadBtn = loadBtn,
		canLoad = canLoad
	}
end

function UI:_drawSaveDialog()
	local sw, sh = love.graphics.getDimensions()

	love.graphics.setColor(0, 0, 0, 0.6)
	love.graphics.rectangle("fill", 0, 0, sw, sh)

	local dw, dh = 360, 180
	local dx, dy = (sw - dw) / 2, (sh - dh) / 2

	love.graphics.setColor(C.panel)
	love.graphics.rectangle("fill", dx, dy, dw, dh, 8, 8)

	love.graphics.setColor(C.panelBdr)
	love.graphics.rectangle("line", dx, dy, dw, dh, 8, 8)

	love.graphics.setColor(C.heading)
	love.graphics.setFont(UI.font.title)
	love.graphics.print("Save Map to /saves", dx + 15, dy + 15)

	love.graphics.setColor(C.label)
	love.graphics.setFont(UI.font.small)
	love.graphics.print("enter filename (lua extension is added automatically)", dx + 15, dy + 45)

	local inputX, inputY, inputW, inputH = dx + 15, dy + 65, dw - 30, 32

	love.graphics.setColor(C.inputTextBg)
	love.graphics.rectangle("fill", inputX, inputY, inputW, inputH, 4, 4)

	love.graphics.setColor(C.accent)
	love.graphics.rectangle("line", inputX, inputY, inputW, inputH, 4, 4)

	love.graphics.setColor(C.value)
	love.graphics.setFont(UI.font.normal)
	love.graphics.print(self._saveFileNameInput .. "|", inputX + 10, inputY + 8)

	local btnW = 100
	local btnY = dy + dh - 45

	local closeBtn = makeBtn(dx + 15, btnY, btnW, 30, "Cancel", nil)
	drawBtn(closeBtn, false)

	local saveBtn = makeBtn(dx + dw - btnW - 15, btnY, btnW, 30, "Save", nil)
	drawBtn(saveBtn, false)

	self._saveBounds = {
		x = dx, y = dy, w = dw, h = dh,
		closeBtn = closeBtn,
		saveBtn = saveBtn
	}
end

function UI:_drawWayPanel()
	local bx, by, bw, bh = SIDEBAR_W + PAD, PAD, 240, 100

	love.graphics.setColor(C.panel)
	love.graphics.rectangle("fill", bx, by, bw, bh, 6, 6)

	love.graphics.setColor(C.panelBdr)
	love.graphics.rectangle("line", bx, by, bw, bh, 6, 6)

	love.graphics.setColor(C.heading)
	love.graphics.setFont(UI.font.normal)
	love.graphics.print("build way", bx + 8, by + 8)

	local nodes = self.editor.tools:getWayPreviewNodes() or {}
	local n = #nodes

	love.graphics.setColor(C.label)
	love.graphics.setFont(UI.font.small)
	love.graphics.print("nodes: " .. n, bx + 8, by + 30)

	self._wayPanelBounds = {
		x = bx, y = by, w = bw, h = bh,
		finishBtn = {x = bx + 8, y = by + 54, w = 100, h = 30},
		cancelBtn = {x = bx + 116, y = by + 54, w = 100, h = 30}
	}
end

function UI:_drawNodePanel()
	local id = self.editor.selectedNode
	local n = self.editor.map.nodes[id]
	if not n then return end

	local sw, bw, bh = love.graphics.getWidth(), 230, 120
	local bx, by = sw - bw - PAD, PAD

	love.graphics.setColor(C.panel)
	love.graphics.rectangle("fill", bx, by, bw, bh, 6, 6)

	love.graphics.setColor(C.panelBdr)
	love.graphics.rectangle("line", bx, by, bw, bh, 6, 6)

	love.graphics.setColor(C.heading)
	love.graphics.print("node #" .. id, bx + 10, by + 8)
end

function UI:_drawHelp()
	local sh = love.graphics.getHeight()
	local by = sh - 144

	love.graphics.setColor(C.sidebar)
	love.graphics.rectangle("fill", 0, by, SIDEBAR_W, 144)

	love.graphics.setColor(C.separator)
	love.graphics.line(PAD, by, SIDEBAR_W - PAD, by)

	love.graphics.setColor(C.label)
	love.graphics.setFont(UI.font.small)

	local lines = {
		"scroll = zoom",
		"rmb/mmb = pan",
		"f = fit view",
		"l = load map",
		"s = save map",
		"r = reset map",
		"del = remove item",
		"esc = cancel",
	}

	for i, line in ipairs(lines) do
		love.graphics.print(line, PAD, by + 4 + (i - 1) * 14)
	end
end

function UI:_drawCamInfo()
	local cam = self.editor.camera
	local mx, my = love.mouse.getPosition()
	local wx, wy = cam:toWorld(mx, my)

	love.graphics.setColor(C.panel)
	love.graphics.rectangle(
		"fill",
		SIDEBAR_W + PAD,
		love.graphics.getHeight() - 46,
		260,
		36,
		4
	)

	love.graphics.setColor(C.label)
	love.graphics.setFont(UI.font.small)

	love.graphics.print(
		string.format("world x:%.0f y:%.0f zoom:%.2fx", wx, wy, cam.scale),
		SIDEBAR_W + PAD + 8,
		love.graphics.getHeight() - 34
	)
end

function UI:mousepressed(x, y, button)
	if button ~= 1 then return false end

	if self._showLoadDialog and self._loadBounds then
		local db = self._loadBounds

		for i, f in ipairs(self._fileList) do
			local itemY = db.y + 45 + (i - 1) * 24

			if x >= db.x + 15 and x <= db.x + db.w - 15 and
			y >= itemY and y <= itemY + 20 then

				self._selectedFileIdx = i
				return true
			end
		end

		if btnHit(db.closeBtn, x, y) then
			self._showLoadDialog = false
			return true
		end

		if db.canLoad and btnHit(db.loadBtn, x, y) then
			local file = self._fileList[self._selectedFileIdx].name
			Map.loadFromFile(self.editor.map, file)

			self.editor.notify("loaded: " .. file)
			self.editor.selectedNode = nil
			self._showLoadDialog = false
			return true
		end

		return true
	end

	if self._showSaveDialog and self._saveBounds then
		local db = self._saveBounds

		if btnHit(db.closeBtn, x, y) then
			self._showSaveDialog = false
			return true
		end

		if btnHit(db.saveBtn, x, y) then
			self:executeSave()
			return true
		end

		return true
	end

	if x < SIDEBAR_W then
		for _, b in ipairs(self.buttons) do
			if not b.separator and btnHit(b, x, y) then
				b.action()
				return true
			end
		end

		return true
	end

	return false
end

function UI:executeSave()
	local name = self._saveFileNameInput
	if name == "" then name = "map" end

	local fullFilename = name .. ".lua"
	local dataString = Exporter.buildLua(self.editor.map)

	local success, err = FileManager.save(fullFilename, dataString)

	if success then
		self.editor.notify("saved: saves/" .. fullFilename)
	else
		self.editor.notify("save error: " .. tostring(err))
	end

	self._showSaveDialog = false
end

function UI:keypressed(key)
	if self._showSaveDialog then
		if key == "escape" then
			self._showSaveDialog = false
		elseif key == "return" or key == "kpenter" then
			self:executeSave()
		elseif key == "backspace" then
			self._saveFileNameInput = self._saveFileNameInput:sub(1, -2)
		end
		return true
	end

	if self._showLoadDialog then
		if key == "escape" then
			self._showLoadDialog = false
		end
		return true
	end

	if key == "l" then self:openLoadDialog(); return true end
	if key == "s" then self:openSaveDialog(); return true end

	return false
end

function UI:textinput(t)
	if self._showSaveDialog then
		if t:match("[%w_%-]") then
			self._saveFileNameInput = self._saveFileNameInput .. t
		end
		return true
	end

	return false
end

function UI:mousemoved(x, y, dx, dy)
	return false
end

function UI:mousereleased(x, y, button)
	return false
end

function UI:wheelmoved(x, y)
	return false
end

return UI