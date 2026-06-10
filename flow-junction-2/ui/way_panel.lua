-- ui/way_panel.lua
-- sidebar info panel shown when a way is selected in the editor

local Theme = require("ui.theme")
local Map   = require("core.map")

local C       = Theme.C
local PAD     = Theme.PAD
local BTN_H   = Theme.BTN_H
local BTN_GAP = Theme.BTN_GAP
local makeBtn = Theme.makeBtn
local drawBtn = Theme.drawBtn
local btnHit  = Theme.btnHit

local WayPanel = {}
WayPanel.__index = WayPanel

function WayPanel.new(context, onEditTags)
	local self      = setmetatable({}, WayPanel)
	self.context    = context
	self.onEditTags = onEditTags
	self._editBtn   = nil
	self._clearBtn  = nil
	return self
end

function WayPanel:draw()
	local selectedWay = self.context.selectedWay
	if not selectedWay then return end

	local way = self.context.map.ways[selectedWay]
	if not way then return end

	local tags  = way.tags or {}
	local wtype = tags.type or "—"
	local layer = tonumber(tags.layer) or 0

	local px = PAD
	local py = 340
	local pw = Theme.SIDEBAR_W - PAD * 2

	love.graphics.setColor(C.panel)
	love.graphics.rectangle("fill", px, py, pw, 150, 6, 6)
	love.graphics.setColor(C.panelBdr)
	love.graphics.rectangle("line", px, py, pw, 150, 6, 6)

	love.graphics.setFont(Theme.font.small)

	local titleCol = {1, 1, 1, 1}
	if wtype == "in"  then titleCol = {0.20, 1.00, 0.50, 1} end
	if wtype == "out" then titleCol = {1.00, 0.30, 0.30, 1} end
	love.graphics.setColor(titleCol)
	love.graphics.print("Way #" .. tostring(way.id or selectedWay), px + 8, py + 8)

	love.graphics.setColor(C.btnText)
	love.graphics.print("type:  " .. wtype,         px + 8, py + 26)
	love.graphics.print("nodes: " .. #way.nodeRefs, px + 8, py + 42)

	local layerCol = C.layerGround
	if layer > 0 then layerCol = C.layerBridge end
	if layer < 0 then layerCol = C.layerUnder  end
	love.graphics.setColor(layerCol)
	local layerStr = "layer: " .. tostring(layer)
	if layer > 0 then layerStr = layerStr .. "  [bridge]"    end
	if layer < 0 then layerStr = layerStr .. "  [underpass]" end
	love.graphics.print(layerStr, px + 8, py + 58)

	self._editBtn = makeBtn(px + 4, py + 80, pw - 8, BTN_H, "Edit Tags", function()
			if self.onEditTags then self.onEditTags(selectedWay) end
		end)
	drawBtn(self._editBtn, false)

	self._clearBtn = makeBtn(px + 4, py + 80 + BTN_H + BTN_GAP, pw - 8, BTN_H - 6, "Clear Type", function()
			Map.clearWayType(self.context.map, selectedWay)
			if self.context.notify then self.context.notify("way type cleared") end
		end)
	drawBtn(self._clearBtn, false)
end

function WayPanel:mousepressed(x, y)
	if self._editBtn  and btnHit(self._editBtn,  x, y) then self._editBtn.action();  return true end
	if self._clearBtn and btnHit(self._clearBtn, x, y) then self._clearBtn.action(); return true end
	return false
end

return WayPanel