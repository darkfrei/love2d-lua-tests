-- editor/tools.lua
-- editor tools logic: selection, movement, node and way creation
-- bezier mode: 3 nodes = quadratic, 4 nodes = cubic (auto-finalizes either)

local Map = require("core.map")

local Tools = {}
Tools.__index = Tools

local MODE_SELECT      = "select"
local MODE_ADD_NODE    = "addNode"
local MODE_ADD_LINEAR  = "addLinear"
local MODE_ADD_BEZIER  = "addBezier"

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
	self.mode   = MODE_SELECT

	self._wayNodes   = {}
	self._wayMouseWX = 0
	self._wayMouseWY = 0

	self._dragActive = false
	self._dragNodeId = nil
	self._dragOffX   = 0
	self._dragOffY   = 0

	return self
end

function Tools:setMode(mode)
	self.mode      = mode
	self._wayNodes = {}
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

-- input handling

function Tools:mousepressed(sx, sy, button)
	local editor = self.editor
	local cam    = editor.camera
	local wx, wy = cam:toWorld(sx, sy)

	if button == 2 or button == 3 then
		cam:startPan(sx, sy)
		return
	end

	if button == 1 then
		if self.mode == MODE_SELECT then
			if editor.hoveredNode then
				editor.selectedNode = editor.hoveredNode

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
				editor.selectedWay  = editor.hoveredWay
				editor.selectedNode = nil

			else
				editor.selectedNode = nil
				editor.selectedWay  = nil
			end

		elseif self.mode == MODE_ADD_NODE then
			local id = Map.addNode(editor.map, wx, wy)
			editor.notify("node created id: " .. id)

		elseif self.mode == MODE_ADD_LINEAR then
			if editor.hoveredNode then
				self._wayNodes[#self._wayNodes + 1] = editor.hoveredNode
				editor.notify("node added to way")
			else
				local id = Map.addNode(editor.map, wx, wy)
				self._wayNodes[#self._wayNodes + 1] = id
				editor.notify("node created and added id: " .. id)
			end

		elseif self.mode == MODE_ADD_BEZIER then
			if editor.hoveredNode then
				self._wayNodes[#self._wayNodes + 1] = editor.hoveredNode
				editor.notify("node added to bezier")
			else
				local id = Map.addNode(editor.map, wx, wy)
				self._wayNodes[#self._wayNodes + 1] = id
				editor.notify("node created and added id: " .. id)
			end

			-- quadratic (3 nodes) or cubic (4 nodes) — both auto-finalize
			local n = #self._wayNodes
			if n == 3 or n == 4 then
				self:finishWay()
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

function Tools:keypressed(key)
	if self.mode == MODE_ADD_LINEAR then
		if key == "return" then
			self:finishWay()
			return true
		end
		if key == "escape" then
			self._wayNodes = {}
			self.editor.notify("way cancelled")
			return true
		end
	end

	if self.mode == MODE_ADD_BEZIER then
		if key == "escape" then
			self._wayNodes = {}
			self.editor.notify("way cancelled")
			return true
		end
	end

	if self.mode ~= MODE_SELECT and key == "escape" then
		self:cancel()
		return true
	end
end

-- way construction finalization

function Tools:finishWay()
	local editor = self.editor

	if #self._wayNodes < 2 then
		editor.notify("at least two nodes are required to create a way")
		self._wayNodes = {}
		return
	end

	local refs = {}
	for _, id in ipairs(self._wayNodes) do
		refs[#refs + 1] = id
	end

	local curveType
	if self.mode == MODE_ADD_BEZIER then
		curveType = "bezier"
	else
		curveType = "linear"
	end

	Map.addWay(editor.map, nil, refs, curveType)

	local nodeCount = #refs
	if curveType == "bezier" then
		local kind = (nodeCount == 3) and "quadratic" or "cubic"
		editor.notify("bezier way added [" .. kind .. ", " .. nodeCount .. " nodes]")
	else
		editor.notify("linear way added [" .. nodeCount .. " nodes]")
	end

	self._wayNodes = {}
end

-- overlay rendering (inside camera transform)

function Tools:drawOverlay()
	local isAddMode = (self.mode == MODE_ADD_LINEAR or self.mode == MODE_ADD_BEZIER)

	if isAddMode and #self._wayNodes > 0 then
		local map        = self.editor.map
		local lastNodeId = self._wayNodes[#self._wayNodes]
		local lastNode   = map.nodes[lastNodeId]

		if lastNode then
			love.graphics.setLineWidth(2)
			if self.mode == MODE_ADD_BEZIER then
				love.graphics.setColor(0.20, 0.80, 1.0, 0.5)
			else
				love.graphics.setColor(0.95, 0.65, 0.20, 0.5)
			end
			love.graphics.line(
				lastNode.x, lastNode.y,
				self._wayMouseWX, self._wayMouseWY
			)

			love.graphics.setColor(1, 1, 1, 0.4)
			for i = 1, #self._wayNodes - 1 do
				local n1 = map.nodes[self._wayNodes[i]]
				local n2 = map.nodes[self._wayNodes[i + 1]]
				if n1 and n2 then
					love.graphics.line(n1.x, n1.y, n2.x, n2.y)
				end
			end

			if self.mode == MODE_ADD_BEZIER then
				local cnt  = #self._wayNodes
				-- show how many nodes collected and what will finalize
				local hint
				if cnt == 1 then hint = "1/3  (+2 = quadratic, +3 = cubic)"
				elseif cnt == 2 then hint = "2/3  (click = quadratic ready, +1 more = cubic)"
				elseif cnt == 3 then hint = "3 — finalizing quadratic..."
				end
				love.graphics.setColor(0.20, 0.80, 1.0, 0.8)
				love.graphics.print(hint or (cnt .. "/4"), self._wayMouseWX + 14, self._wayMouseWY - 14)
			end
		end
	end
end

return Tools