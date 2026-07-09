-- editor/tools.lua
-- editor tools: selection, movement, node and way construction
--
-- way building (mode "addWay"):
-- every click adds a node (new, or existing if hovered)
-- clicking an already-hovered existing node finalizes the way
-- Enter also finalizes
-- Escape cancels
-- node count determines curve type:
-- 2 nodes -> linear
-- 3 nodes -> quadratic bezier
-- 4 nodes -> cubic bezier
--
-- roundabout tool (mode "addRoundabout"):
-- click sets center, drag sets radius and initial angle
-- drag right -> counter-clockwise ring (visually, Y-down)
-- drag left -> clockwise ring
-- mouse angle -> rotates position of first node
-- release -> commits N cubic bezier ways forming a circle

local Map = require("core.map")

local GRID_SIZE = 20 -- must match renderer grid size

local function snapToGrid(wx, wy, editor)
	if not editor.snapToGrid then return wx, wy end
	return
	math.floor(wx / GRID_SIZE + 0.5)*GRID_SIZE,
	math.floor(wy / GRID_SIZE + 0.5)*GRID_SIZE
end

local ROUNDABOUT_SEGMENTS_DEFAULT = 12

-- optimal bezier k for a circle approximated with n segments
-- formula: (4/3)*tan(pi / (2*n))
local function bezierCircleK(n)
	return (4/3)*math.tan(math.pi / (2*n))
end

local Tools = {}
Tools.__index = Tools

local MODE_SELECT = "select"
local MODE_ADD_NODE = "addNode"
local MODE_ADD_WAY = "addWay"
local MODE_ADD_ROUNDABOUT = "addRoundabout"

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
	if n == 2 then return "2 nodes — Enter/click existing = linear | add more for bezier" end
	if n == 3 then return "3 nodes — Enter/click existing = quadratic | +1 = cubic" end
	if n == 4 then return "4 nodes — Enter/click existing = cubic" end
	return n .. " nodes — Enter/click existing to finish"
end

-- compute the 4 control points for one arc segment of a circle
-- direction is derived from sign of (b-a): positive=math-CCW, negative=math-CW
-- in Love2D Y-down: math-CCW appears visually CW and vice versa
local function arcSegment(cx, cy, r, a, b, n)
--	local k = bezierCircleK(n)
	local k = (4/3)*math.tan(math.pi / (2*n))
	local s = (b > a) and 1 or -1
	local cosA, sinA = math.cos(a), math.sin(a)
	local cosB, sinB = math.cos(b), math.sin(b)
	local x1, y1 = cx + r*cosA, cy + r*sinA
	local x2, y2 = cx + r*cosA + s*k*r*(-sinA), cy + r*sinA + s*k*r*cosA
	local x3, y3 = cx + r*cosB - s*k*r*(-sinB), cy + r*sinB - s*k*r*cosB
	local x4, y4 = cx + r*cosB, cy + r*sinB
	return x1, y1, x2, y2, x3, y3, x4, y4
end

-- sample a cubic bezier into a flat {x,y,x,y,...} table for love.graphics.line
local function sampleCubic(p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y, steps)
	local pts = {}
	for i = 0, steps do
		local t = i / steps
		local u = 1 - t
		local x = u^3*p0x + 3*u^2*t*p1x + 3*u*t^2*p2x + t^3*p3x
		local y = u^3*p0y + 3*u^2*t*p1y + 3*u*t^2*p2y + t^3*p3y
		pts[#pts + 1] = x
		pts[#pts + 1] = y
	end
	return pts
end

function Tools.new(editor)
	local self = setmetatable({}, Tools)

	self.editor = editor
	self.mode = MODE_SELECT

	self._wayNodes = {}
	self._newNodes = {}
	self._wayMouseWX = 0
	self._wayMouseWY = 0

	self._dragActive = false
	self._dragNodeId = nil
	self._dragOffX = 0
	self._dragOffY = 0

	-- roundabout state
	self._rbActive = false
	self._rbCX = 0
	self._rbCY = 0
	self._rbRadius = 0
	self._rbAngle = 0
	self._rbCCW = true
	self._rbSegments = ROUNDABOUT_SEGMENTS_DEFAULT

	return self
end

function Tools:setMode(mode)
	self.mode = mode
	self._wayNodes = {}
	self._newNodes = {}
	self._rbActive = false
	self.editor.notify("mode: " .. mode)
end

function Tools:cancel()
	self._wayNodes = {}
	self._newNodes = {}
	self._rbActive = false
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

function Tools:_commitRoundabout()
	local cx = self._rbCX
	local cy = self._rbCY
	local r = self._rbRadius
	local angle0 = self._rbAngle
	local ccw = self._rbCCW
	local map = self.editor.map
	local N = self._rbSegments or ROUNDABOUT_SEGMENTS_DEFAULT
	local step = (2*math.pi) / N
	if not ccw then step = -step end

	-- create N anchor nodes (stitch points between curves)
	local nodeIds = {}
	for i = 0, N - 1 do
		local a = angle0 + i*step
		local x = cx + r*math.cos(a)
		local y = cy + r*math.sin(a)
		nodeIds[i + 1] = Map.addNode(map, x, y)
	end

	-- create N ways, each with 2 inner control-point nodes
	for i = 0, N - 1 do
		local a = angle0 + i*step
		local b = angle0 + (i + 1)*step
		local p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y = arcSegment(cx, cy, r, a, b, N)

		local cp1 = Map.addNode(map, p1x, p1y)
		local cp2 = Map.addNode(map, p2x, p2y)

		local startNode = nodeIds[i + 1]
		local endNode = nodeIds[((i + 1) % N) + 1]

		Map.addWay(map, nil, { startNode, cp1, cp2, endNode }, "bezier")
	end

	self.editor.notify(
		"roundabout: " .. N .. " segments, r=" .. math.floor(r + 0.5) ..
		(ccw and " CCW" or " CW")
	)
	self._rbActive = false
end

function Tools:mousepressed(sx, sy, button)
	local editor = self.editor
	local cam = editor.camera
	local wx, wy = cam:toWorld(sx, sy)

	if button == 2 or button == 3 then
		cam:startPan(sx, sy)
		return
	end

	if button ~= 1 then return end

	if self.mode == MODE_SELECT then
		if editor.hoveredNode then
			local isCtrl = Map.getControlNodeSet(editor.map)[editor.hoveredNode]

			editor.selectedNode = editor.hoveredNode

			if isCtrl then
				-- dragging a control point: keep selectedWay intact
			else
				-- dragging an anchor node: clear selectedWay if not containing this node
				if editor.selectedWay then
					if not nodeInWay(editor.map, editor.selectedWay, editor.hoveredNode) then
						editor.selectedWay = nil
					end
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
		wx, wy = snapToGrid(wx, wy, editor)
		local id = Map.addNode(editor.map, wx, wy)
		editor.notify("node " .. id .. " created")

	elseif self.mode == MODE_ADD_WAY then
		local n = #self._wayNodes

		if editor.hoveredNode then
			self._wayNodes[n + 1] = editor.hoveredNode

			if n + 1 >= 2 then
				self:finishWay()
			else
				editor.notify("node added — need at least one more")
			end
		else
			wx, wy = snapToGrid(wx, wy, editor)
			local id = Map.addNode(editor.map, wx, wy)
			self._wayNodes[n + 1] = id
			self._newNodes[#self._newNodes + 1] = id
			editor.notify(hintForCount(n + 1))
		end

	elseif self.mode == MODE_ADD_ROUNDABOUT then
		-- snap center to grid
		wx, wy = snapToGrid(wx, wy, editor)
		self._rbCX = wx
		self._rbCY = wy
		self._rbRadius = 0
		self._rbAngle = 0
		self._rbCCW = true
		self._rbActive = true
	end
end

function Tools:mousereleased(sx, sy, button)
	if button == 2 or button == 3 then
		self.editor.camera:endPan()
	end
	if button == 1 then
		self._dragActive = false

		if self.mode == MODE_ADD_ROUNDABOUT and self._rbActive then
			if self._rbRadius > 5 then
				self:_commitRoundabout()
			else
				self._rbActive = false
				self.editor.notify("roundabout too small, cancelled")
			end
		end
	end
end

function Tools:mousemoved(sx, sy, dx, dy)
	local cam = self.editor.camera

	if cam:isPanning() then
		cam:updatePan(sx, sy)
	end

	if self._dragActive and self._dragNodeId then
		local wx, wy = cam:toWorld(sx, sy)
		local nx, ny = snapToGrid(wx + self._dragOffX, wy + self._dragOffY, self.editor)
		Map.moveNode(self.editor.map, self._dragNodeId, nx, ny)
	end

	local wx, wy = cam:toWorld(sx, sy)

	-- in roundabout mode: snap cursor before storing and before computing radius/angle
	if self.mode == MODE_ADD_ROUNDABOUT then
		wx, wy = snapToGrid(wx, wy, self.editor)
		if self._rbActive then
			local dxr = wx - self._rbCX
			local dyr = wy - self._rbCY
			self._rbRadius = math.sqrt(dxr*dxr + dyr*dyr)
			self._rbAngle = math.atan2(dyr, dxr)
			self._rbCCW = (dxr < 0)
		end
	end

	self._wayMouseWX = wx
	self._wayMouseWY = wy
end

-- returns true if the wheel event was consumed (blocks camera zoom)
function Tools:wheelmoved(wy)
	if self.mode == MODE_ADD_ROUNDABOUT and self._rbActive then
		local n = (self._rbSegments or ROUNDABOUT_SEGMENTS_DEFAULT) + (wy > 0 and 1 or -1)
		n = math.max(2, n)
		self._rbSegments = n
		return true
	end
	return false
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
	if self.mode == MODE_ADD_WAY then
		local n = #self._wayNodes
		if n == 0 then return end

		local map = self.editor.map
		local lastNode = map.nodes[self._wayNodes[n]]
		if not lastNode then return end

		love.graphics.setLineWidth(2)
		love.graphics.setColor(0.20, 0.80, 1.0, 0.5)
		love.graphics.line(lastNode.x, lastNode.y, self._wayMouseWX, self._wayMouseWY)

		love.graphics.setColor(1, 1, 1, 0.4)
		for i = 1, n - 1 do
			local a = map.nodes[self._wayNodes[i]]
			local b = map.nodes[self._wayNodes[i + 1]]
			if a and b then
				love.graphics.line(a.x, a.y, b.x, b.y)
			end
		end

		love.graphics.setColor(0.20, 0.80, 1.0, 0.85)
		love.graphics.print(hintForCount(n), self._wayMouseWX + 14, self._wayMouseWY - 14)

	elseif self.mode == MODE_ADD_ROUNDABOUT then
		local mx, my = self._wayMouseWX, self._wayMouseWY

		if not self._rbActive then
			-- crosshair snaps to grid (mx/my already snapped via mousemoved)
			love.graphics.setColor(0.80, 0.60, 1.0, 0.7)
			love.graphics.setLineWidth(1)
			love.graphics.line(mx - 12, my, mx + 12, my)
			love.graphics.line(mx, my - 12, mx, my + 12)
			love.graphics.setColor(0.80, 0.60, 1.0, 0.85)
			love.graphics.print("click to set center", mx + 14, my - 14)
			return
		end

		local cx = self._rbCX
		local cy = self._rbCY
		local r = self._rbRadius
		local angle0 = self._rbAngle
		local ccw = self._rbCCW
		local N = self._rbSegments or ROUNDABOUT_SEGMENTS_DEFAULT
		local step = (2*math.pi) / N
		if not ccw then step = -step end

		love.graphics.setLineWidth(1.5)

		-- sampled bezier curves (no control points shown)
		love.graphics.setColor(0.80, 0.60, 1.0, 0.85)
		for i = 0, N - 1 do
			local a = angle0 + i*step
			local b = angle0 + (i + 1)*step
			local p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y = arcSegment(cx, cy, r, a, b, N)
			local pts = sampleCubic(p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y, 32)
			if #pts >= 4 then
				love.graphics.line(pts)
			end
		end

		-- stitch point nodes only
		love.graphics.setColor(1, 1, 1, 0.9)
		for i = 0, N - 1 do
			local a = angle0 + i*step
			local x = cx + r*math.cos(a)
			local y = cy + r*math.sin(a)
			love.graphics.circle("fill", x, y, 4)
		end

		-- cursor dot at snapped edge position
		love.graphics.setColor(1, 1, 0.4, 0.9)
		love.graphics.circle("fill", mx, my, 4)

		-- center dot and reference circle
		love.graphics.setColor(0.80, 0.60, 1.0, 0.3)
		love.graphics.circle("line", cx, cy, r)
		love.graphics.setColor(0.80, 0.60, 1.0, 0.7)
		love.graphics.circle("fill", cx, cy, 3)

		-- label
		local dir = ccw and "CCW" or "CW"
		love.graphics.setColor(0.80, 0.60, 1.0, 0.85)
		love.graphics.print(
			dir .. " r=" .. math.floor(r + 0.5) .. " segs=" .. N .. " (wheel to change)",
			cx + r + 8, cy - 8
		)
	end
end

return Tools