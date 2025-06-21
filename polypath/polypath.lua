-- polypath.lua
-- PolyPath library for working with polylines in Love2D

local PolyPath = {}
PolyPath.__index = PolyPath

PolyPath.config = {
	grabRadius = 10,
	doubleClickInterval = 0.3
}

PolyPath.undoStack = {} -- global undo stack
PolyPath.redoStack = {} -- global redo stack
PolyPath.lastClickTime = 0 -- global double-click timer

-- calculate squared distance from point (x, y) to node or segment
local function calculateSquaredDistance(x, y, p1, p2)
	if p2 then -- segment
		local dx = p2.x - p1.x
		local dy = p2.y - p1.y
		local lenSquared = dx * dx + dy * dy
		if lenSquared == 0 then return math.huge end
		local t = math.max(0, math.min(1, ((x - p1.x) * dx + (y - p1.y) * dy) / lenSquared))
		local projX = p1.x + t * dx
		local projY = p1.y + t * dy
		return (x - projX) ^ 2 + (y - projY) ^ 2, projX, projY
	else -- node
		local dx = x - p1.x
		local dy = y - p1.y
		return dx * dx + dy * dy
	end
end

-- get projection point on segment
local function getProjectionOnSegment(x, y, p1, p2)
	local dx = p2.x - p1.x
	local dy = p2.y - p1.y
	local lenSquared = dx * dx + dy * dy
	if lenSquared == 0 then return p1.x, p1.y end
	local t = math.max(0, math.min(1, ((x - p1.x) * dx + (y - p1.y) * dy) / lenSquared))
	return p1.x + t * dx, p1.y + t * dy
end

-- create new PolyPath
function PolyPath.new()
	local self = setmetatable({}, PolyPath)
	self.points = {} -- list of points {x, y}
	self.interaction = nil -- interaction state: {type, index, data, state, clickStart}
	return self
end

-- clear global undo/redo stacks
function PolyPath.clearUndoRedo()
	PolyPath.undoStack = {}
	PolyPath.redoStack = {}
end

-- create new polyline with undo support
function PolyPath.createPolyline()
	local poly = PolyPath.new()
	poly:addPoint(100, 100) -- default point
	poly:addPoint(300, 300) -- default point
	table.insert(polylines, poly)
	table.insert(PolyPath.undoStack, {action = "create", poly = poly, index = #polylines})
	PolyPath.redoStack = {} -- clear redo stack
	return poly
end

-- delete polyline with undo support
function PolyPath.deletePolyline(index)
	if polylines[index] then
		local poly = table.remove(polylines, index)
		table.insert(PolyPath.undoStack, {action = "delete", poly = poly, index = index})
		PolyPath.redoStack = {} -- clear redo stack
	end
end

-- add point with undo support
function PolyPath:addPoint(x, y, index)
	if index then
		table.insert(self.points, index, {x = x, y = y})
	else
		table.insert(self.points, {x = x, y = y})
		index = #self.points
	end
	table.insert(PolyPath.undoStack, {action = "add", poly = self, index = index, point = {x = x, y = y}})
	PolyPath.redoStack = {} -- clear redo stack
	return index
end

-- remove point with undo support
function PolyPath:removePoint(index)
	if self.points[index] then
		local point = self.points[index]
		table.insert(PolyPath.undoStack, {action = "remove", poly = self, index = index, point = point})
		PolyPath.redoStack = {} -- clear redo stack
		table.remove(self.points, index)
	end
end

-- undo last action
function PolyPath.undo(polylines)
	local action = table.remove(PolyPath.undoStack)
	if action and action.poly then
--		print("undo: action = " .. serpent.block(action)) -- debug
		-- verify poly still exists in polylines
		local polyExists = false
		for _, poly in ipairs(polylines) do
			if poly == action.poly then
				polyExists = true
				break
			end
		end
		if not polyExists and action.action ~= "delete" then
--			print("undo: poly no longer exists, skipping") -- debug
			return
		end
		if action.action == "add" then
			if action.poly.points[action.index] then
				table.remove(action.poly.points, action.index)
			end
		elseif action.action == "remove" then
			if action.point.x and action.point.y then
				table.insert(action.poly.points, action.index, action.point)
			end
		elseif action.action == "drag" then
			if action.poly.points[action.index] then
				if action.startX and action.startY then
					action.poly.points[action.index].x = action.startX
					action.poly.points[action.index].y = action.startY
--					print("undo drag: point[" .. action.index .. "] restored to x=" .. action.startX .. ", y=" .. action.startY) -- debug
				else
--					print("undo drag: invalid startX or startY: " .. serpent.block({startX = action.startX, startY = action.startY})) -- debug
				end
				if action.type == "segment" and action.poly.points[action.index + 1] then
					if action.startX2 and action.startY2 then
						action.poly.points[action.index + 1].x = action.startX2
						action.poly.points[action.index + 1].y = action.startY2
--						print("undo drag segment: point[" .. (action.index + 1) .. "] restored to x=" .. action.startX2 .. ", y=" .. action.startY2) -- debug
					else
--						print("undo drag segment: invalid startX2 or startY2: " .. serpent.block({startX2 = action.startX2, startY2 = action.startY2})) -- debug
					end
				end
			else
--				print("undo drag: invalid point at index " .. action.index) -- debug
			end
		elseif action.action == "create" then
			table.remove(polylines, action.index)
		elseif action.action == "delete" then
			table.insert(polylines, action.index, action.poly)
		end
		table.insert(PolyPath.redoStack, action)
	else
--		print("undo: no action or invalid poly") -- debug
	end
end


-- redo last undone action
function PolyPath.redo(polylines)
	local action = table.remove(PolyPath.redoStack)
	if action then
		if action.action == "add" then
			table.insert(action.poly.points, action.index, action.point)
		elseif action.action == "remove" then
			table.remove(action.poly.points, action.index)
		elseif action.action == "drag" then
			action.poly.points[action.index].x = action.newX
			action.poly.points[action.index].y = action.newY
			if action.type == "segment" then
				action.poly.points[action.index + 1].x = action.newX2
				action.poly.points[action.index + 1].y = action.newY2
			end
		elseif action.action == "create" then
			table.insert(polylines, action.index, action.poly)
		elseif action.action == "delete" then
			table.remove(polylines, action.index)
		end
		table.insert(PolyPath.undoStack, action)
	end
end

--serpent = require('serpent')

-- handle double-click
function PolyPath:handleDoubleClick(x, y, closest)
	-- like your pulse under my fingertips, we capture the moment of a double-click
--    print("handleDoubleClick, closest:") -- debug
--    print(serpent.block(closest)) -- debug
	if closest.type == "point" and #self.points > 1 then
		-- a point vanishes under our touch, leaving only the heat of its absence
		self:removePoint(closest.index)
		self.interaction = nil
	elseif closest.type == "segment" then
		-- oh, darling, we trace the curve of a segment, craving to mark it with our desire
		local p1 = self.points[closest.index]
		local p2 = self.points[closest.index + 1]
		-- we project our longing onto this line, finding the perfect spot to ignite
		local newX, newY = getProjectionOnSegment(x, y, p1, p2)
		-- a new point blooms under our caress, trembling with possibility
		local newIndex = self:addPoint(newX, newY, closest.index + 1)
		-- we claim this point as ours, marking it with the fire of our selection
		self.interaction = {
			type = "point",
			index = newIndex,
			data = {x = newX, y = newY},
			state = "selected"
		}
		-- the past fades, my love, as we clear the redo stack to live in this moment
		PolyPath.redoStack = {}
		-- our passion whispers its secrets to the console, baring our creation
--        print("after double click, interaction:") -- debug
--        print(serpent.block(self.interaction)) -- debug
	end
end

-- handle left click for dragging
function PolyPath:handleLeftClick(closest)
	self.interaction = {
		type = closest.type,
		index = closest.index,
		data = {x = closest.data.x, y = closest.data.y},
		state = "dragging",
		startX = closest.type == "point" and closest.data.x or self.points[closest.index].x,
		startY = closest.type == "point" and closest.data.y or self.points[closest.index].y,
		prevX = closest.data.x,
		prevY = closest.data.y,
		clickStart = {x = closest.data.x, y = closest.data.y, index = closest.index}
	}
	if closest.type == "segment" then
		self.interaction.startX2 = self.points[closest.index + 1].x
		self.interaction.startY2 = self.points[closest.index + 1].y
		self.interaction.prevX2 = self.points[closest.index + 1].x
		self.interaction.prevY2 = self.points[closest.index + 1].y
	end
end

-- handle right click for adding/deleting nodes
function PolyPath:handleRightClick(x, y)
--	print("handleRightClick") -- debug
	local closest = self:findClosestPointOrSegment(x, y, PolyPath.config.grabRadius) -- fixed typo
	if closest and closest.type == "segment" then
		local newX, newY = getProjectionOnSegment(x, y, self.points[closest.index], self.points[closest.index + 1])
		local newIndex = self:addPoint(newX, newY, closest.index + 1)
		self.interaction = {type = "point", index = newIndex, data = {x = newX, y = newY}, state = "selected"}
	elseif closest and closest.type == "point" then
		if (closest.index == 1 or closest.index == #self.points) and #self.points > 1 then
			self:removePoint(closest.index)
			self.interaction = nil
		end
	end
end

-- check for double-click
function PolyPath:checkDoubleClick()
	local clickTime = love.timer.getTime()
	local deltaTime = clickTime - PolyPath.lastClickTime
	if deltaTime <= PolyPath.config.doubleClickInterval then
		PolyPath.lastClickTime = 0
		return true
	else
		PolyPath.lastClickTime = clickTime
		return false
	end
end

-- export PolyPath to string (for saving multiple polylines)
function PolyPath:exportToString()
	local data = ""
	for _, point in ipairs(self.points) do
		data = data .. string.format("%f,%f\n", point.x, point.y)
	end
	return data
end

-- import PolyPath from string
function PolyPath:importFromString(data)
	self.points = {}
	for line in data:gmatch("[^\n]+") do
		local x, y = line:match("([^,]+),([^,]+)")
		if x and y then
			self:addPoint(tonumber(x), tonumber(y))
		end
	end
end

-- export multiple PolyPaths to filesystem
function PolyPath.exportAllToFileSystem(filename, polylines)
	local data = ""
	for i, poly in ipairs(polylines) do
		data = data .. "-- PolyPath " .. i .. "\n"
		data = data .. poly:exportToString()
		data = data .. "-- End PolyPath " .. i .. "\n"
	end
	local success, message = love.filesystem.write(filename, data)
	return success, message
end

-- import PolyPath from filesystem (load specific index)
function PolyPath:importFromFileSystem(filename, index)
	local data, err = love.filesystem.read(filename)
	if not data then
		return false, err
	end
	self.points = {}
	local currentIndex = 0
	local polyData = ""
	for line in data:gmatch("[^\n]+") do
		if line:match("^%-%- PolyPath (%d+)$") then
			currentIndex = tonumber(line:match("%d+"))
		elseif line:match("^%-%- End PolyPath") then
			if currentIndex == index then
				self:importFromString(polyData)
				return true
			end
			polyData = ""
		elseif currentIndex == index then
			polyData = polyData .. line .. "\n"
		end
	end
	if currentIndex == index and polyData ~= "" then
		self:importFromString(polyData)
		return true
	end
	return false, "No PolyPath with index " .. index
end

-- translate PolyPath
function PolyPath:translate(dx, dy)
	-- shift polyline by given offsets
	for _, point in ipairs(self.points) do
		-- move point x by dx
		point.x = point.x + dx
		-- move point y by dy
		point.y = point.y + dy
	end
end

-- rotate PolyPath around point (cx, cy) by angle (radians)
function PolyPath:rotate(angle, cx, cy)
	local cosA = math.cos(angle)
	local sinA = math.sin(angle)
	for _, point in ipairs(self.points) do
		local x, y = point.x - cx, point.y - cy
		point.x = cx + x * cosA - y * sinA
		point.y = cy + x * sinA + y * cosA
	end
end

-- scale PolyPath around point (cx, cy)
function PolyPath:scale(sx, sy, cx, cy)
	for _, point in ipairs(self.points) do
		point.x = cx + (point.x - cx) * sx
		point.y = cy + (point.y - cy) * sy
	end
end

-- draw interaction element
function PolyPath:drawInteractionElement(mode, radius)
	local interaction = self.interaction
	local index = interaction and interaction.index
	if interaction and interaction.type == "point" and self.points[index] then
		love.graphics.circle(mode or "fill", self.points[index].x, self.points[index].y, radius or 5)
	elseif interaction and interaction.type == "segment" and self.points[index] and self.points[index + 1] and interaction.data then
		love.graphics.line(self.points[index].x, self.points[index].y,
			self.points[index + 1].x, self.points[index + 1].y)
		love.graphics.circle("line", interaction.data.x, interaction.data.y, radius or 5)
	end
end

-- draw PolyPath lines
function PolyPath:drawLines()
	if #self.points < 2 then return end
	for i = 1, #self.points - 1 do
		local p1 = self.points[i]
		local p2 = self.points[i+1]
		if p1 and p2 then
			love.graphics.line(p1.x, p1.y, p2.x, p2.y)
		end
	end
end

-- draw control points
function PolyPath:drawPoints(mode, radius)
	for _, point in ipairs(self.points) do
		love.graphics.circle(mode or "fill", point.x, point.y, radius or 5)
	end
end

-- find closest point or segment within capture radius, prioritizing points
function PolyPath:findClosestPointOrSegment(x, y, radius)
	if #self.points == 0 then return nil end
	local radiusSquared = radius * radius
	local resultData = nil
	local resultDist = math.huge
	local resultType = nil -- "point" or "segment"
	local resultIndex = nil -- index of point or start of segment
	-- check distance to points first (higher priority)
	for i, point in ipairs(self.points) do
		local dist = calculateSquaredDistance(x, y, point)
		if dist <= radiusSquared and dist < resultDist then
			resultDist = dist
			resultData = point
			resultType = "point"
			resultIndex = i
		end
	end
	-- check distance to segments only if no point is close enough
	if not resultData then
		for i = 1, #self.points - 1 do
			local p1 = self.points[i]
			local p2 = self.points[i + 1]
			local dist, projX, projY = calculateSquaredDistance(x, y, p1, p2)
			if dist <= radiusSquared and dist < resultDist then
				resultDist = dist
				resultData = {x = projX, y = projY}
				resultType = "segment"
				resultIndex = i
			end
		end
	end
	if resultData then
		local closest = {
			type = resultType,
			index = resultIndex,
			x = resultData.x,
			y = resultData.y,
			dist = resultDist,
			data = {x = resultData.x, y = resultData.y}
		}
		return closest
	end
	return nil
end

-- handle mouse press for a single polyline
function PolyPath:handleMousePress(x, y, button)
--	print("handleMousePress: button=" .. button) -- debug
	local closest = self.interaction and self.interaction.state == "hovered" and self.interaction
	if not closest then
		closest = self:findClosestPointOrSegment(x, y, PolyPath.config.grabRadius)
	end
--	print("closest in handleMousePress:") -- debug
--	print(serpent.block(closest)) -- debug
	if not closest then
		self.interaction = nil
		return
	end
	if button == 1 then
		local isDoubleClick = self:checkDoubleClick()
		if isDoubleClick then
			love.window.setTitle("double click")
			self:handleDoubleClick(x, y, closest)
		else
			love.window.setTitle("left click")
			self:handleLeftClick(closest)
		end
	elseif button == 2 then
		self:handleRightClick(x, y)
	end
end

-- handle mouse press for all polylines
function PolyPath.mousepressed(x, y, button, polylines)
	for _, poly in ipairs(polylines) do
		poly:handleMousePress(x, y, button)
		if poly.interaction and poly.interaction.state == "dragging" then
			break -- stop after first polyline that starts dragging
		end
	end
end

-- handle mouse movement for a single polyline
function PolyPath:handleMouseMove(x, y)
	if self.interaction and self.interaction.state == "dragging" then
--		print("handleMouseMove: interaction = " .. serpent.block(self.interaction)) -- debug
		if love.mouse.isDown(1) then
			if not self.interaction.prevX or not self.interaction.prevY then
--				print("error: prevX or prevY is nil in dragging state") -- debug
				self.interaction = nil
				return
			end
			local dx = x - self.interaction.prevX
			local dy = y - self.interaction.prevY
			if self.interaction.type == "point" then
				self.points[self.interaction.index].x = self.points[self.interaction.index].x + dx
				self.points[self.interaction.index].y = self.points[self.interaction.index].y + dy
				self.interaction.data = {x = self.points[self.interaction.index].x, y = self.points[self.interaction.index].y}
--				print("handleMouseMove: point[" .. self.interaction.index .. "] moved to x=" .. self.points[self.interaction.index].x .. ", y=" .. self.points[self.interaction.index].y) -- debug
			elseif self.interaction.type == "segment" then
				local p1 = self.points[self.interaction.index]
				local p2 = self.points[self.interaction.index + 1]
				p1.x = p1.x + dx
				p1.y = p1.y + dy
				p2.x = p2.x + dx
				p2.y = p2.y + dy
				self.interaction.data = {x = x, y = y}
				self.interaction.prevX2 = p2.x
				self.interaction.prevY2 = p2.y
--				print("handleMouseMove: segment[" .. self.interaction.index .. "] moved to p1={x=" .. p1.x .. ", y=" .. p1.y .. "}, p2={x=" .. p2.x .. ", y=" .. p2.y .. "}") -- debug
			end
			self.interaction.prevX = x
			self.interaction.prevY = y
		end
		return
	end
	local closest = self:findClosestPointOrSegment(x, y, PolyPath.config.grabRadius)
	self.interaction = closest and {
		type = closest.type,
		index = closest.index,
		data = {x = closest.data.x, y = closest.data.y},
		state = "hovered"
		} or nil
end

-- handle mouse movement for all polylines
function PolyPath.mousemoved(x, y, polylines)
	for _, poly in ipairs(polylines) do
		poly:handleMouseMove(x, y)
	end
end

-- handle mouse release for a single polyline
function PolyPath:handleMouseRelease(x, y)
	if self.interaction and self.interaction.state == "dragging" then
		local newX = self.points[self.interaction.index].x
		local newY = self.points[self.interaction.index].y
		local moved = newX ~= self.interaction.startX or newY ~= self.interaction.startY
		if self.interaction.type == "segment" then
			local newX2 = self.points[self.interaction.index + 1].x
			local newY2 = self.points[self.interaction.index + 1].y
			moved = moved or newX2 ~= self.interaction.startX2 or newY2 ~= self.interaction.startY2
		end
		if moved then
			local action = {
				action = "drag",
				poly = self,
				type = self.interaction.type,
				index = self.interaction.index,
				startX = self.interaction.startX,
				startY = self.interaction.startY,
				newX = newX,
				newY = newY
			}
			if self.interaction.type == "segment" then
				action.startX2 = self.interaction.startX2
				action.startY2 = self.interaction.startY2
				action.newX2 = self.points[self.interaction.index + 1].x
				action.newY2 = self.points[self.interaction.index + 1].y
			end
--			print("handleMouseRelease: adding drag action = " .. serpent.block(action)) -- debug
			table.insert(PolyPath.undoStack, action)
			PolyPath.redoStack = {}
		else
--			print("handleMouseRelease: no movement detected, skipping undo action") -- debug
		end
		self.interaction.state = "selected"
	end
	self.interaction = self.interaction and {
		type = self.interaction.type,
		index = self.interaction.index,
		data = self.interaction.data,
		state = "selected"
		} or nil
end

-- handle mouse release for all polylines
function PolyPath.mousereleased(x, y, polylines)
	for _, poly in ipairs(polylines) do
		poly:handleMouseRelease(x, y)
	end
end

-------------------------------------------------
-------------------------------------------------
-------------------------------------------------

-- get point at specified distance from polyline start or end
function PolyPath:getPointAtDistance(distance, withDirection)
	-- return nil if polyline is empty
	if #self.points == 0 then return nil end
	-- return first point if polyline has one point
	if #self.points == 1 then
		local point = self.points[1]
		if withDirection then
			return {x = point.x, y = point.y}, {dx = 0, dy = 0}
		end
		return {x = point.x, y = point.y}
	end
	if distance >= 0 then
		-- handle positive distance from start
		if distance == 0 then
			local point = self.points[1]
			if withDirection then
				local p2 = self.points[2]
				local dx = p2.x - point.x
				local dy = p2.y - point.y
				local dirLength = math.sqrt(dx * dx + dy * dy)
				local dxNorm = dirLength > 0 and dx / dirLength or 0
				local dyNorm = dirLength > 0 and dy / dirLength or 0
				return {x = point.x, y = point.y}, {dx = dxNorm, dy = dyNorm}
			end
			return {x = point.x, y = point.y}
		end
		-- track total distance along polyline
		local totalDistance = 0
		-- iterate through segments
		for i = 1, #self.points - 1 do
			local p1 = self.points[i]
			local p2 = self.points[i + 1]
			-- calculate segment length
			local dx = p2.x - p1.x
			local dy = p2.y - p1.y
			local segmentLength = math.sqrt(dx * dx + dy * dy)
			-- check if target distance lies within this segment
			if totalDistance + segmentLength >= distance then
				-- interpolate point within segment
				local t = (distance - totalDistance) / segmentLength
				local x = p1.x + t * dx
				local y = p1.y + t * dy
				if withDirection then
					-- normalize direction vector
					local dirLength = segmentLength > 0 and segmentLength or 1
					local dxNorm = dx / dirLength
					local dyNorm = dy / dirLength
					return {x = x, y = y}, {dx = dxNorm, dy = dyNorm}
				end
				return {x = x, y = y}
			end
			totalDistance = totalDistance + segmentLength
		end
		-- return last point if distance exceeds polyline length
		local lastPoint = self.points[#self.points]
		if withDirection then
			-- use direction of last segment
			local p1 = self.points[#self.points - 1]
			local dx = lastPoint.x - p1.x
			local dy = lastPoint.y - p1.y
			local dirLength = math.sqrt(dx * dx + dy * dy)
			local dxNorm = dirLength > 0 and dx / dirLength or 0
			local dyNorm = dirLength > 0 and dy / dirLength or 0
			return {x = lastPoint.x, y = lastPoint.y}, {dx = dxNorm, dy = dyNorm}
		end
		return {x = lastPoint.x, y = lastPoint.y}
	else
		-- handle negative distance from end
		local absDistance = math.abs(distance)
		if absDistance == 0 then
			local point = self.points[#self.points]
			if withDirection then
				local p1 = self.points[#self.points - 1]
				local dx = point.x - p1.x
				local dy = point.y - p1.y
				local dirLength = math.sqrt(dx * dx + dy * dy)
				local dxNorm = dirLength > 0 and dx / dirLength or 0
				local dyNorm = dirLength > 0 and dy / dirLength or 0
				return {x = point.x, y = point.y}, {dx = dxNorm, dy = dyNorm}
			end
			return {x = point.x, y = point.y}
		end
		-- track total distance from end
		local totalDistance = 0
		-- iterate through segments in reverse
		for i = #self.points - 1, 1, -1 do
			local p1 = self.points[i]
			local p2 = self.points[i + 1]
			-- calculate segment length
			local dx = p2.x - p1.x
			local dy = p2.y - p1.y
			local segmentLength = math.sqrt(dx * dx + dy * dy)
			-- check if target distance lies within this segment
			if totalDistance + segmentLength >= absDistance then
				-- interpolate point within segment (from p2 to p1)
				local t = (absDistance - totalDistance) / segmentLength
				local x = p2.x - t * dx
				local y = p2.y - t * dy
				if withDirection then
					-- normalize direction vector (from p2 to p1)
					local dirLength = segmentLength > 0 and segmentLength or 1
					local dxNorm = -dx / dirLength
					local dyNorm = -dy / dirLength
					return {x = x, y = y}, {dx = dxNorm, dy = dyNorm}
				end
				return {x = x, y = y}
			end
			totalDistance = totalDistance + segmentLength
		end
		-- return first point if abs(distance) exceeds polyline length
		local firstPoint = self.points[1]
		if withDirection then
			-- use direction of first segment (from p2 to p1)
			local p2 = self.points[2]
			local dx = p2.x - firstPoint.x
			local dy = p2.y - firstPoint.y
			local dirLength = math.sqrt(dx * dx + dy * dy)
			local dxNorm = dirLength > 0 and -dx / dirLength or 0
			local dyNorm = dirLength > 0 and -dy / dirLength or 0
			return {x = firstPoint.x, y = firstPoint.y}, {dx = dxNorm, dy = dyNorm}
		end
		return {x = firstPoint.x, y = firstPoint.y}
	end
end


----------------------------------

function PolyPath:smoothCurve(segmentsPerPoint)
	if #self.points < 2 then return end
	local smoothedPoints = {}
	local controlPoints = self:calculateControlPoints()
	for i = 1, #self.points - 1 do
		local p0 = self.points[i]
		local p1 = self.points[i + 1]
		local c1 = controlPoints[i].c1
		local c2 = controlPoints[i].c2
		for t = 0, 1, 1 / segmentsPerPoint do
			local x = (1 - t)^3 * p0.x + 3 * (1 - t)^2 * t * c1.x + 3 * (1 - t) * t^2 * c2.x + t^3 * p1.x
			local y = (1 - t)^3 * p0.y + 3 * (1 - t)^2 * t * c1.y + 3 * (1 - t) * t^2 * c2.y + t^3 * p1.y
			table.insert(smoothedPoints, {x = x, y = y})
		end
	end
	table.insert(smoothedPoints, {x = self.points[#self.points].x, y = self.points[#self.points].y})
	self.points = smoothedPoints
end

function PolyPath:calculateControlPoints()
	local controlPoints = {}
	for i = 1, #self.points - 1 do
		local p0 = self.points[math.max(i - 1, 1)]
		local p1 = self.points[i]
		local p2 = self.points[i + 1]
		local p3 = self.points[math.min(i + 2, #self.points)]
		local c1x = p1.x + (p2.x - p0.x) / 6
		local c1y = p1.y + (p2.y - p0.y) / 6
		local c2x = p2.x - (p3.x - p1.x) / 6
		local c2y = p2.y - (p3.y - p1.y) / 6
		controlPoints[i] = {c1 = {x = c1x, y = c1y}, c2 = {x = c2x, y = c2y}}
	end
	return controlPoints
end

----------------------------------
----------------------------------
----------------------------------

return PolyPath