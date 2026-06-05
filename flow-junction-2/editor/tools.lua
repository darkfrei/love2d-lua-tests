-- editor/tools.lua
-- editing tools logic: selection, node movement, node/way creation

local Map = require("core.map")

local Tools = {}
Tools.__index = Tools

local MODE_SELECT = "select"
local MODE_ADD_NODE = "addNode"
local MODE_ADD_WAY = "addWay"

-- helpers 

local function nodeInWay(map, wayIdx, nodeId)
	local way = map.ways[wayIdx]
	if not way then return false end

	for _, id in ipairs(way.nodeRefs) do
		if id == nodeId then return true end
	end

	return false
end

-- constructor   

function Tools.new(editor)
	local self = setmetatable({}, Tools)
	self.editor = editor
	self.mode = MODE_SELECT

	self._wayNodes = {}
	self._wayMouseWX = 0
	self._wayMouseWY = 0

	self._dragActive = false
	self._dragNodeId = nil
	self._dragOffX = 0
	self._dragOffY = 0

	return self
end

function Tools:setMode(mode)
	self.mode = mode
	self._wayNodes = {}

	-- do not reset selectedWay / selectedNode to preserve editor context
	self.editor.notify("mode: " .. mode)
end

function Tools:cancel()
	self._wayNodes = {}
	self.mode = MODE_SELECT
end

function Tools:getMode()
	return self.mode
end

function Tools:getWayPreviewNodes()
	return self._wayNodes
end

-- mouse input   

function Tools:mousepressed(sx, sy, button)
	local editor = self.editor
	local cam = editor.camera
	local wx, wy = cam:toWorld(sx, sy)

	if button == 2 or button == 3 then
		cam:startPan(sx, sy)
		return
	end

	if button == 1 then
		if self.mode == MODE_SELECT then

			if editor.hoveredNode then
				editor.selectedNode = editor.hoveredNode

				-- keep selectedWay only if node belongs to it
				if editor.selectedWay then
					if not nodeInWay(editor.map, editor.selectedWay, editor.hoveredNode) then
						editor.selectedWay = nil
					end
				end

				self._dragActive = true
				self._dragNodeId = editor.hoveredNode

				local n = editor.map.nodes[editor.hoveredNode]
				self._dragOffX = n.x - wx
				self._dragOffY = n.y - wy

			elseif editor.hoveredWay then
				editor.selectedWay = editor.hoveredWay
				editor.selectedNode = nil

			else
				editor.selectedNode = nil
				editor.selectedWay = nil
			end

		elseif self.mode == MODE_ADD_NODE then
			local id = Map.addNode(editor.map, wx, wy)
			editor.notify("node created: " .. id)

		elseif self.mode == MODE_ADD_WAY then
			if editor.hoveredNode then
				table.insert(self._wayNodes, editor.hoveredNode)
				editor.notify("node added to way")
			else
				local id = Map.addNode(editor.map, wx, wy)
				table.insert(self._wayNodes, id)
				editor.notify("node created and linked: " .. id)
			end

			if #self._wayNodes == 2 and love.keyboard.isDown("lshift") then
				self:finishWay("linear")
			elseif #self._wayNodes == 4 then
				self:finishWay("bezier")
			end
		end
	end
end

function Tools:mousereleased(sx, sy, button)
	if button == 2 or button == 3 then
		self.editor.camera:endPan()
	end

	if button == 1 then
		self._dragActive = false
	end
end

function Tools:mousemoved(sx, sy, dx, dy)
	local cam = self.editor.camera

	if cam:isPanning() then
		cam:updatePan(sx, sy)
	end

	if self._dragActive and self._dragNodeId then
		local wx, wy = cam:toWorld(sx, sy)
		Map.moveNode(
			self.editor.map,
			self._dragNodeId,
			wx + self._dragOffX,
			wy + self._dragOffY
		)
	end

	self._wayMouseWX, self._wayMouseWY = cam:toWorld(sx, sy)
end

-- finish way 

function Tools:finishWay(forcedType)
	local editor = self.editor

	if #self._wayNodes < 2 then
		editor.notify("at least 2 nodes required to create a way")
		self._wayNodes = {}
		return
	end

	local refs = {}
	for _, id in ipairs(self._wayNodes) do
		refs[#refs + 1] = id
	end

	local finalType = forcedType or "linear"
	if #refs == 4 then
		finalType = "bezier"
	end

	Map.addWay(editor.map, nil, refs, finalType)
	editor.notify("way added: [" .. finalType .. "]")
	self._wayNodes = {}
end

-- draw overlay  

function Tools:drawOverlay()
	if self.mode == MODE_ADD_WAY and #self._wayNodes > 0 then
		local map = self.editor.map
		local lastNodeId = self._wayNodes[#self._wayNodes]
		local lastNode = map.nodes[lastNodeId]

		if lastNode then
			love.graphics.setLineWidth(2)
			love.graphics.setColor(0.95, 0.65, 0.20, 0.5)
			love.graphics.line(lastNode.x, lastNode.y, self._wayMouseWX, self._wayMouseWY)

			love.graphics.setColor(1, 1, 1, 0.4)

			for i = 1, #self._wayNodes - 1 do
				local n1 = map.nodes[self._wayNodes[i]]
				local n2 = map.nodes[self._wayNodes[i + 1]]

				if n1 and n2 then
					love.graphics.line(n1.x, n1.y, n2.x, n2.y)
				end
			end
		end
	end
end

return Tools