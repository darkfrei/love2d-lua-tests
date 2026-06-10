-- ui/dialogs.lua
-- modal dialogs: load map, save map, edit way tags

local Theme       = require("ui.theme")
local Map         = require("core.map")
local FileManager = require("editor.filemanager")
local Exporter    = require("editor.exporter")

local C       = Theme.C
local PAD     = Theme.PAD
local BTN_H   = Theme.BTN_H
local makeBtn = Theme.makeBtn
local drawBtn = Theme.drawBtn
local btnHit  = Theme.btnHit

local TYPES = { "in", "mid", "out", "turn" }

local LAYERS = {
	{ label = "-2", value = -2 },
	{ label = "-1", value = -1 },
	{ label = "0",  value =  0 },
	{ label = "+1", value =  1 },
	{ label = "+2", value =  2 },
}

local Dialogs = {}
Dialogs.__index = Dialogs

function Dialogs.new(context)
	local self = setmetatable({}, Dialogs)
	self.context = context

	self.showLoad = false
	self.showSave = false
	self.showTags = false

	self._fileList        = {}
	self._selectedFileIdx = nil
	self._saveInput       = ""
	self._loadBounds      = nil
	self._saveBounds      = nil

	self._tagsWayIdx    = nil
	self._tagsType      = nil
	self._tagsLayer     = 0
	self._tagsCloseBtn  = nil
	self._tagsApplyBtn  = nil
	self._tagsClearBtn  = nil
	self._tagsTypeBtns  = {}
	self._tagsLayerBtns = {}

	return self
end

function Dialogs:anyOpen()
	return self.showLoad or self.showSave or self.showTags
end

function Dialogs:closeAll()
	self.showLoad = false
	self.showSave = false
	self.showTags = false
end

-- load dialog

function Dialogs:openLoad()
	self:closeAll()
	self.showLoad         = true
	self._selectedFileIdx = nil
	self._fileList        = {}

	for _, f in ipairs(FileManager.listSaves()) do
		self._fileList[#self._fileList + 1] = { name = f, hover = false }
	end
	table.sort(self._fileList, function(a, b) return a.name < b.name end)
end

function Dialogs:drawLoad()
	local w, h = 300, 400
	local x = (love.graphics.getWidth()  - w) / 2
	local y = (love.graphics.getHeight() - h) / 2

	self._loadBounds = {
		x = x, y = y, w = w, h = h,
		closeBtn = makeBtn(x + w - 30, y + 5,      25,      25, "X"),
		loadBtn  = makeBtn(x + 50,     y + h - 40, w - 100, 30, "Load"),
	}

	love.graphics.setColor(C.panel)
	love.graphics.rectangle("fill", x, y, w, h, 8, 8)
	love.graphics.setColor(C.panelBdr)
	love.graphics.rectangle("line", x, y, w, h, 8, 8)

	love.graphics.setColor(C.value)
	love.graphics.setFont(Theme.font.normal)
	love.graphics.print("Load Map", x + PAD, y + PAD)

	for i, f in ipairs(self._fileList) do
		local iy = y + 38 + (i - 1) * 24
		love.graphics.setColor(
			self._selectedFileIdx == i and C.btnActive
			or (f.hover and C.btnHover or C.btnNormal)
		)
		love.graphics.rectangle("fill", x + 15, iy, w - 30, 20, 2, 2)
		love.graphics.setColor(C.btnText)
		love.graphics.setFont(Theme.font.small)
		love.graphics.print(f.name, x + 25, iy + 3)
	end

	drawBtn(self._loadBounds.closeBtn)
	drawBtn(self._loadBounds.loadBtn, self._selectedFileIdx ~= nil)
end

function Dialogs:updateLoad(mx, my)
	if not self._loadBounds then return end
	for i, f in ipairs(self._fileList) do
		local iy = self._loadBounds.y + 38 + (i - 1) * 24
		f.hover = (
			mx >= self._loadBounds.x + 15 and
			mx <= self._loadBounds.x + 285 and
			my >= iy and my <= iy + 20
		)
	end
end

function Dialogs:pressLoad(x, y)
	if not self._loadBounds then return end
	if btnHit(self._loadBounds.closeBtn, x, y) then
		self.showLoad = false
		return
	end
	if btnHit(self._loadBounds.loadBtn, x, y) and self._selectedFileIdx then
		if Map.loadFromFile(self.context.map, self._fileList[self._selectedFileIdx].name) then
			self.context.camera:fitAll(self.context.map)
		end
		self.showLoad = false
		return
	end
	for i, f in ipairs(self._fileList) do
		local iy = self._loadBounds.y + 38 + (i - 1) * 24
		if x >= self._loadBounds.x + 15 and x <= self._loadBounds.x + 285
		and y >= iy and y <= iy + 20 then
			self._selectedFileIdx = i
		end
	end
end

-- save dialog

function Dialogs:openSave()
	self:closeAll()
	self.showSave   = true
	self._saveInput = FileManager.generateName("map"):gsub("%.lua$", "")
end

function Dialogs:executeSave()
	local name = self._saveInput:gsub("^%s+", ""):gsub("%s+$", "")
	if name == "" then return end

	local content, err = Exporter.buildLua(self.context.map)
	if not content then
		if self.context.notify then self.context.notify("export failed: " .. tostring(err)) end
		return
	end

	local ok, saveErr = FileManager.save(name .. ".lua", content)
	if not ok then
		if self.context.notify then self.context.notify("save failed: " .. tostring(saveErr)) end
		return
	end

	self.showSave = false
	if self.context.notify then self.context.notify("saved") end
end

function Dialogs:drawSave()
	local w, h = 300, 150
	local x = (love.graphics.getWidth()  - w) / 2
	local y = (love.graphics.getHeight() - h) / 2

	self._saveBounds = {
		x = x, y = y, w = w, h = h,
		closeBtn = makeBtn(x + w - 30, y + 5,   25,      25, "X"),
		saveBtn  = makeBtn(x + 50,     y + 100, w - 100, 30, "Save"),
	}

	love.graphics.setColor(C.panel)
	love.graphics.rectangle("fill", x, y, w, h, 8, 8)
	love.graphics.setColor(C.panelBdr)
	love.graphics.rectangle("line", x, y, w, h, 8, 8)

	love.graphics.setColor(C.value)
	love.graphics.setFont(Theme.font.normal)
	love.graphics.print("Save Map", x + PAD, y + PAD)

	love.graphics.setColor(C.inputTextBg)
	love.graphics.rectangle("fill", x + 30, y + 50, w - 60, 30)
	love.graphics.setColor(C.value)
	love.graphics.setFont(Theme.font.normal)
	love.graphics.print(self._saveInput .. ".lua", x + 40, y + 57)

	drawBtn(self._saveBounds.closeBtn)
	drawBtn(self._saveBounds.saveBtn)
end

function Dialogs:pressSave(x, y)
	if not self._saveBounds then return end
	if btnHit(self._saveBounds.closeBtn, x, y) then
		self.showSave = false
	elseif btnHit(self._saveBounds.saveBtn, x, y) then
		self:executeSave()
	end
end

function Dialogs:textinput(t)
	if self.showSave and t:match("[A-Za-z0-9_%-%s]") then
		self._saveInput = self._saveInput .. t
	end
end

function Dialogs:keypressSave(k)
	if k == "escape"    then self.showSave = false
	elseif k == "backspace" then self._saveInput = self._saveInput:sub(1, -2)
	elseif k == "return"    then self:executeSave()
	end
end

-- tags dialog

function Dialogs:openTags(wayIdx)
	local way = self.context.map.ways[wayIdx]
	if not way then return end
	self:closeAll()
	self.showTags    = true
	self._tagsWayIdx = wayIdx
	self._tagsType   = (way.tags and way.tags.type)  or nil
	self._tagsLayer  = (way.tags and tonumber(way.tags.layer)) or 0
end

function Dialogs:applyTags()
	if not self._tagsWayIdx then return end
	Map.setWayTags(self.context.map, self._tagsWayIdx, {
		type  = self._tagsType,
		layer = self._tagsLayer,
	})
	self.showTags = false
	if self.context.notify then
		self.context.notify(
			"tags: type=" .. (self._tagsType or "none") ..
			" layer=" .. tostring(self._tagsLayer)
		)
	end
end

function Dialogs:clearTagsType()
	if not self._tagsWayIdx then return end
	Map.clearWayType(self.context.map, self._tagsWayIdx)
	self.showTags = false
	if self.context.notify then self.context.notify("way type cleared") end
end

function Dialogs:drawTags()
	local dw, dh = 340, 230
	local dx = (love.graphics.getWidth()  - dw) / 2
	local dy = (love.graphics.getHeight() - dh) / 2

	love.graphics.setColor(C.panel)
	love.graphics.rectangle("fill", dx, dy, dw, dh, 8, 8)
	love.graphics.setColor(C.panelBdr)
	love.graphics.rectangle("line", dx, dy, dw, dh, 8, 8)

	love.graphics.setColor(C.value)
	love.graphics.setFont(Theme.font.normal)
	love.graphics.print("Edit Way Tags", dx + PAD, dy + PAD)

	local closeBtn = makeBtn(dx + dw - 30, dy + 5, 25, 25, "X")
	drawBtn(closeBtn)
	self._tagsCloseBtn = closeBtn

	local cy = dy + 38

	-- type row
	love.graphics.setColor(C.value)
	love.graphics.setFont(Theme.font.small)
	love.graphics.print("Type:", dx + PAD, cy - 2)

	local typeW    = 56
	local typeOffX = dx + PAD + 44
	local typeBtns = {}
	for i, t in ipairs(TYPES) do
		local bx     = typeOffX + (i - 1) * (typeW + 4)
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
		love.graphics.rectangle("fill", bx + 1, cy + 2, typeW, 28, 4, 4)
		love.graphics.setColor(col)
		love.graphics.rectangle("fill", bx, cy, typeW, 28, 4, 4)
		love.graphics.setColor(active and C.accent or C.panelBdr)
		love.graphics.rectangle("line", bx, cy, typeW, 28, 4, 4)
		love.graphics.setColor(C.btnTextAct)
		love.graphics.setFont(Theme.font.small)
		love.graphics.printf(t, bx, cy + 7, typeW, "center")
		typeBtns[i] = makeBtn(bx, cy, typeW, 28, t, function() self._tagsType = t end)
	end
	self._tagsTypeBtns = typeBtns
	cy = cy + 38

	love.graphics.setColor(C.separator)
	love.graphics.line(dx + PAD, cy, dx + dw - PAD, cy)
	cy = cy + 10

	-- layer row
	love.graphics.setColor(C.value)
	love.graphics.setFont(Theme.font.small)
	love.graphics.print("Layer:", dx + PAD, cy - 2)

	local layerDesc = "ground level"
	local descCol   = C.layerGround
	if self._tagsLayer > 0 then layerDesc = "bridge / overpass";   descCol = C.layerBridge end
	if self._tagsLayer < 0 then layerDesc = "underpass / tunnel"; descCol = C.layerUnder  end
	love.graphics.setColor(descCol)
	love.graphics.print(layerDesc, dx + PAD + 100, cy - 2)

	local layW    = (dw - PAD * 2 - 44 - (#LAYERS - 1) * 4) / #LAYERS
	local layOffX = dx + PAD + 44
	local layBtns = {}
	for i, ld in ipairs(LAYERS) do
		local bx     = layOffX + (i - 1) * (layW + 4)
		local active = (self._tagsLayer == ld.value)
		local col
		if ld.value > 0 then
			col = active and {0.80, 0.65, 0.10, 1} or {0.40, 0.33, 0.08, 1}
		elseif ld.value < 0 then
			col = active and {0.25, 0.55, 0.90, 1} or {0.12, 0.28, 0.48, 1}
		else
			col = active and C.btnActive or C.btnNormal
		end
		love.graphics.setColor(0, 0, 0, 0.3)
		love.graphics.rectangle("fill", bx + 1, cy + 2, layW, 28, 4, 4)
		love.graphics.setColor(col)
		love.graphics.rectangle("fill", bx, cy, layW, 28, 4, 4)
		love.graphics.setColor(active and C.accent or C.panelBdr)
		love.graphics.rectangle("line", bx, cy, layW, 28, 4, 4)
		love.graphics.setColor(C.btnTextAct)
		love.graphics.setFont(Theme.font.small)
		love.graphics.printf(ld.label, bx, cy + 7, layW, "center")
		layBtns[i] = makeBtn(bx, cy, layW, 28, ld.label, function() self._tagsLayer = ld.value end)
	end
	self._tagsLayerBtns = layBtns
	cy = cy + 38

	love.graphics.setColor(C.separator)
	love.graphics.line(dx + PAD, cy, dx + dw - PAD, cy)
	cy = cy + 10

	love.graphics.setColor(C.value)
	love.graphics.setFont(Theme.font.small)
	love.graphics.print(
		"type: " .. (self._tagsType or "—") .. "   layer: " .. tostring(self._tagsLayer),
		dx + PAD, cy
	)
	cy = cy + 22

	local applyBtn = makeBtn(dx + PAD,       cy, 100, BTN_H, "Apply",      function() self:applyTags() end)
	local clearBtn = makeBtn(dx + PAD + 108, cy, 100, BTN_H, "Clear Type", function() self:clearTagsType() end)
	drawBtn(applyBtn, true)
	drawBtn(clearBtn, false)
	self._tagsApplyBtn = applyBtn
	self._tagsClearBtn = clearBtn
end

function Dialogs:pressTags(x, y)
	if self._tagsCloseBtn and btnHit(self._tagsCloseBtn, x, y) then self.showTags = false; return end
	if self._tagsApplyBtn and btnHit(self._tagsApplyBtn, x, y) then self:applyTags();     return end
	if self._tagsClearBtn and btnHit(self._tagsClearBtn, x, y) then self:clearTagsType(); return end
	for i, b in ipairs(self._tagsTypeBtns)  do if btnHit(b, x, y) then self._tagsType  = TYPES[i].value  or TYPES[i]; return end end
	for i, b in ipairs(self._tagsLayerBtns) do if btnHit(b, x, y) then self._tagsLayer = LAYERS[i].value;             return end end
end

-- unified input routing

function Dialogs:draw()
	if self.showLoad then self:drawLoad() end
	if self.showSave then self:drawSave() end
	if self.showTags then self:drawTags() end
end

function Dialogs:update(mx, my)
	if self.showLoad then self:updateLoad(mx, my) end
end

function Dialogs:mousepressed(x, y)
	if self.showTags then self:pressTags(x, y); return true end
	if self.showLoad then self:pressLoad(x, y); return true end
	if self.showSave then self:pressSave(x, y); return true end
	return false
end

function Dialogs:keypressed(k)
	if self.showTags then
		if k == "escape" then self.showTags = false
		elseif k == "return" then self:applyTags() end
		return true
	end
	if self.showSave then self:keypressSave(k); return true end
	if self.showLoad and k == "escape" then self.showLoad = false; return true end
	return false
end

return Dialogs