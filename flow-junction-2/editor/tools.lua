-- editor/tools.lua
-- editor tools: selection, movement, node and way construction
--
-- way building (mode "addWay"):
--   every click adds a node (new, or existing if hovered)
--   clicking an already-hovered existing node finalizes the way
--   Enter also finalizes
--   Escape cancels
--   node count determines curve type:
--     2 nodes -> linear
--     3 nodes -> quadratic bezier
--     4 nodes -> cubic bezier

local Map = require("core.map")

local Tools = {}
Tools.__index = Tools

local MODE_SELECT   = "select"
local MODE_ADD_NODE = "addNode"
local MODE_ADD_WAY  = "addWay"

local function nodeInWay(map, wayIdx, nodeId)
	local way = map.ways[wayIdx]
	if not way then return false end
	for _, id in ipairs(way.nodeRefs) do
		if id == nodeId then return true end
	end
	return false
end

local function curveTypeForCount(n)
	if n <= 2 then return "linear" end
	return "bezier"
end

local function hintForCount(n)
	if n == 0 then return "click to start" end
	if n == 1 then return "1 node — click to add more, or click existing to finish (linear)" end
	if n == 2 then return "2 nodes — Enter/click existing = linear  |  add more for bezier" end
	if n == 3 then return "3 nodes — Enter/click existing = quadratic  |  +1 = cubic" end
	if n == 4 then return "4 nodes — Enter/click existing = cubic" end
	return n .. " nodes — Enter/click existing to finish"
end

function Tools.new(editor)
	local self = setmetatable({}, Tools)

	self.editor = editor
	self.mode   = MODE_SELECT

	self._wayNodes   = {}
	self._newNodes   = {} -- ids of nodes created during this way (deleted on cancel)
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
	self._newNodes = {}
	self.editor.notify("mode: " .. mode)
end

function Tools:cancel()
	self._wayNodes = {}
	self._newNodes = {}
	self.mode = MODE_SELECT
end

function Tools:_cancelWay()
	for _, id in ipairs(self._newNodes) do
		Map.removeNode(self.editor.map, id)
	end
	self._wayNodes = {}
	self._newNodes = {}
	self.editor.notify("way cancelled")
end

function Tools:getMode()
	return self.mode
end

function Tools:mousepressed(sx, sy, button)
	local editor = self.editor
	local cam    = editor.camera
	local wx, wy = cam:toWorld(sx, sy)

	if button == 2 or button == 3 then
		cam:startPan(sx, sy)
		return
	end

	if button ~= 1 then return end

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
		editor.notify("node " .. id .. " created")

	elseif self.mode == MODE_ADD_WAY then
		local n = #self._wayNodes

		if editor.hoveredNode then
			-- clicking an existing hovered node: add it, then finalize if we have >= 2
			self._wayNodes[n + 1] = editor.hoveredNode

			if n + 1 >= 2 then
				self:finishWay()
			else
				editor.notify("node added — need at least one more")
			end
		else
			-- new node in empty space — just accumulate
			local id = Map.addNode(editor.map, wx, wy)
			self._wayNodes[n + 1] = id
			self._newNodes[#self._newNodes + 1] = id
			editor.notify(hintForCount(n + 1))
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
	if self.mode == MODE_ADD_WAY then
		if key == "return" then
			self:finishWay()
			return true
		end
		if key == "escape" then
			self:_cancelWay()
			return true
		end
	end

	if self.mode ~= MODE_SELECT and key == "escape" then
		self:cancel()
		return true
	end
end

function Tools:finishWay()
	local editor = self.editor

	if #self._wayNodes < 2 then
		editor.notify("need at least 2 nodes")
		self._wayNodes = {}
		return
	end

	local refs = {}
	for _, id in ipairs(self._wayNodes) do
		refs[#refs + 1] = id
	end

	local curve = curveTypeForCount(#refs)
	Map.addWay(editor.map, nil, refs, curve)

	local kinds = { [2] = "linear", [3] = "quadratic bezier", [4] = "cubic bezier" }
	editor.notify("way added — " .. (kinds[#refs] or (curve .. ", " .. #refs .. " nodes")))

	self._wayNodes = {}
	self._newNodes = {}
end

function Tools:drawOverlay()
	if self.mode ~= MODE_ADD_WAY then return end

	local n = #self._wayNodes
	if n == 0 then return end

	local map      = self.editor.map
	local lastNode = map.nodes[self._wayNodes[n]]
	if not lastNode then return end

	-- preview line from last node to cursor
	love.graphics.setLineWidth(2)
	love.graphics.setColor(0.20, 0.80, 1.0, 0.5)
	love.graphics.line(lastNode.x, lastNode.y, self._wayMouseWX, self._wayMouseWY)

	-- lines between already-placed nodes
	love.graphics.setColor(1, 1, 1, 0.4)
	for i = 1, n - 1 do
		local a = map.nodes[self._wayNodes[i]]
		local b = map.nodes[self._wayNodes[i + 1]]
		if a and b then
			love.graphics.line(a.x, a.y, b.x, b.y)
		end
	end

	-- hint label
	love.graphics.setColor(0.20, 0.80, 1.0, 0.85)
	love.graphics.print(hintForCount(n), self._wayMouseWX + 14, self._wayMouseWY - 14)
end

return Tools