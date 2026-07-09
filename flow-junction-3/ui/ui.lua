-- ui/ui.lua
-- entry point: wires together Sidebar, WayPanel, and Dialogs

local Theme       = require("ui.theme")
local Sidebar     = require("ui.sidebar")
local WayPanel    = require("ui.way_panel")
local Dialogs     = require("ui.dialogs")
local FileManager = require("editor.filemanager")

local SIDEBAR_W = Theme.SIDEBAR_W

local UI = {}
UI.__index = UI

-- expose font table so other modules (e.g. editor notifications) can reference it
UI.font = Theme.font

function UI.new(context, mode)
	local self   = setmetatable({}, UI)
	self.context = context
	self.mode    = mode

	Theme.load()
	FileManager.init()

	self.dialogs = Dialogs.new(context)

	self.sidebar = Sidebar.new(context, mode, {
			fitView    = function() context.camera:fitAll(context.map) end,
			openLoad   = function() self.dialogs:openLoad() end,
			openSave   = function() self.dialogs:openSave() end,
			openNew        = function() self.dialogs:openNew() end,
			openImport     = function() self.dialogs:openImport() end,
			getSnapGrid    = function() return context.snapToGrid end,
			toggleSnapGrid = function() context.snapToGrid = not context.snapToGrid end,
		})

	-- way panel only used in editor mode
	if mode == "editor" then
		self.wayPanel = WayPanel.new(context, function(wayIdx)
				self.dialogs:openTags(wayIdx)
			end, self.sidebar)
	end

	return self
end

function UI:update(dt)
	local mx, my = love.mouse.getPosition()

	-- rebuild sidebar if bg image presence changed (e.g. after drag-and-drop)
	local hasBg = self.context.map and self.context.map.meta and self.context.map.meta.bgImage ~= nil
	if hasBg ~= self._lastHasBg then
		self._lastHasBg = hasBg
		self.sidebar:_build()
	end

	if self.dialogs:anyOpen() then
		self.dialogs:update(mx, my)
	else
		self.sidebar:update(mx, my)
	end
end

function UI:draw()
	self.sidebar:draw()
	if self.wayPanel then self.wayPanel:draw() end
	self.dialogs:draw()
end

-- input: return true to consume the event

function UI:mousepressed(x, y, b)
	if self.dialogs:anyOpen() then
		return self.dialogs:mousepressed(x, y)
	end
	if x < SIDEBAR_W then
		if self.wayPanel and self.wayPanel:mousepressed(x, y) then return true end
		return self.sidebar:mousepressed(x, y)
	end
	return false
end

function UI:mousereleased(x, y, b)
	return x < SIDEBAR_W or self.dialogs:anyOpen()
end

function UI:mousemoved(x, y, dx, dy)
	return x < SIDEBAR_W or self.dialogs:anyOpen()
end

function UI:wheelmoved(dx, dy)
	return love.mouse.getX() < SIDEBAR_W or self.dialogs:anyOpen()
end

function UI:keypressed(k)
	if self.dialogs:anyOpen() then
		return self.dialogs:keypressed(k)
	end
	if self.sidebar:keypressed(k) then return true end
	return false
end

function UI:textinput(t)
	if self.dialogs:anyOpen() then
		self.dialogs:textinput(t)
	else
		self.sidebar:textinput(t)
	end
end

return UI