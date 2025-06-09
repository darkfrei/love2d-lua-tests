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
		local lenSquared = dx*dx + dy*dy
		if lenSquared == 0 then return math.huge end
		local t = math.max(0, math.min(1, ((x - p1.x)*dx + (y - p1.y)*dy) / lenSquared))
		local projX = p1.x + t * dx
		local projY = p1.y + t * dy
		return (x - projX)^2 + (y - projY)^2, projX, projY
	else -- node
		local dx = x - p1.x
		local dy = y - p1.y
		return dx*dx + dy*dy
	end
end

-- local helper function: calculate distance from point (x, y) to node or segment
-- not used
local function calculateDistance(x, y, p1, p2)
	return math.sqrt(calculateSquaredDistance(x, y, p1, p2))
end

-- local helper function: get projection point on segment
local function getProjectionOnSegment(x, y, p1, p2)
	local dx = p2.x - p1.x
	local dy = p2.y - p1.y
	local lenSquared = dx*dx + dy*dy
	if lenSquared == 0 then return p1.x, p1.y end
	local t = math.max(0, math.min(1, ((x - p1.x)*dx + (y - p1.y)*dy) / lenSquared))
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
	if action then
		if action.action == "add" then
			table.remove(action.poly.points, action.index)
		elseif action.action == "remove" then
			table.insert(action.poly.points, action.index, action.point)
		elseif action.action == "drag" then
			action.poly.points[action.index].x = action.start_x
			action.poly.points[action.index].y = action.start_y
			if action.type == "segment" then
				action.poly.points[action.index + 1].x = action.start_x2
				action.poly.points[action.index + 1].y = action.start_y2
			end
		elseif action.action == "create" then
			table.remove(polylines, action.index)
		elseif action.action == "delete" then
			table.insert(polylines, action.index, action.poly)
		end
		table.insert(PolyPath.redoStack, action)
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
			action.poly.points[action.index].x = action.new_x
			action.poly.points[action.index].y = action.new_y
			if action.type == "segment" then
				action.poly.points[action.index + 1].x = action.new_x2
				action.poly.points[action.index + 1].y = action.new_y2
			end
		elseif action.action == "create" then
			table.insert(polylines, action.index, action.poly)
		elseif action.action == "delete" then
			table.remove(polylines, action.index)
		end
		table.insert(PolyPath.undoStack, action)
	end
end


serpent = require ('serpent')

-- handle double-click
function PolyPath:handleDoubleClick(x, y, closest)
	print("handleDoubleClick, closest:") -- debug
	print(serpent.block(closest)) -- debug
	if closest.type == "point" and #self.points > 1 then
		self:removePoint(closest.index)
		self.interaction = nil
	elseif closest.type == "segment" then
		local p1 = self.points[closest.index]
		local p2 = self.points[closest.index + 1]
		local new_x, new_y = getProjectionOnSegment(x, y, p1, p2)
		local new_index = self:addPoint(new_x, new_y, closest.index + 1)
		self.interaction = {
			type = "point",
			index = new_index,
			data = {x = new_x, y = new_y},
			state = "selected"
		}
		local action = {
			action = "add",
			poly = self,
			index = new_index,
			point = {x = new_x, y = new_y}
		}
		table.insert(PolyPath.undoStack, action)
		PolyPath.redoStack = {}
		print("after double click, interaction:") -- debug
		print(serpent.block(self.interaction)) -- debug
	end
end


-- handle left click for dragging
function PolyPath:handleLeftClick(closest)
--    print("closest, very updated version") -- debug
--    print(serpent.block(closest)) -- debug
--    print("closest.data.x=" .. tostring(closest.data.x) .. ", closest.data.y=" .. tostring(closest.data.y)) -- debug
--    print("start dragging: type=" .. closest.type .. ", index=" .. closest.index) -- debug
	self.interaction = {
		type = closest.type,
		index = closest.index,
		data = {x = closest.data.x, y = closest.data.y},
		state = "dragging",
		start_x = closest.type == "point" and closest.data.x or self.points[closest.index].x,
		start_y = closest.type == "point" and closest.data.y or self.points[closest.index].y,
		prev_x = closest.data.x,
		prev_y = closest.data.y,
		clickStart = {x = closest.data.x, y = closest.data.y, index = closest.index}
	}
	if closest.type == "segment" then
		self.interaction.start_x2 = self.points[closest.index + 1].x
		self.interaction.start_y2 = self.points[closest.index + 1].y
		self.interaction.prev_x2 = self.points[closest.index + 1].x
		self.interaction.prev_y2 = self.points[closest.index + 1].y
	end
--    print("interaction after init:") -- debug
--    print(serpent.block(self.interaction)) -- debug interaction contents
end


-- handle right click for adding/deleting nodes
function PolyPath:handleRightClick(x, y)
	print ('handleRightClick')
	local closest = self:findClosestPointOrSegment(x, y, PolyPath.config.grabRadius)
	if closest and closest.type == "segment" then
		local new_x, new_y = getProjectionOnSegment(x, y, self.points[closest.index], self.points[closest.index + 1])
		local new_index = self:addPoint(new_x, new_y, closest.index + 1)
		self.interaction = {type = "point", index = new_index, data = {x = new_x, y = new_y}, state = "selected"}
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



-------------------------------------------------
-------------------------------------------------
-------------------------------------------------

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
	for _, point in ipairs(self.points) do
		point.x = point.x + dx
		point.y = point.y + dy
	end
end

-- rotate PolyPath around point (cx, cy) by angle (radians)
function PolyPath:rotate(angle, cx, cy)
	local cos_a = math.cos(angle)
	local sin_a = math.sin(angle)
	for _, point in ipairs(self.points) do
		local x, y = point.x - cx, point.y - cy
		point.x = cx + x * cos_a - y * sin_a
		point.y = cy + x * sin_a + y * cos_a
	end
end

-- scale PolyPath around point (cx, cy)
function PolyPath:scale(sx, sy, cx, cy)
	for _, point in ipairs(self.points) do
		print ('scale', point.x, point.y, sx, sy)
		point.x = cx + (point.x - cx) * sx
		point.y = cy + (point.y - cy) * sy
	end
end

----------------------------------------------
----------------------------------------------
----------------------------------------------

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
		love.graphics.line(self.points[i].x, self.points[i].y,
			self.points[i+1].x, self.points[i+1].y)
	end
end

-- draw control points (mode: "fill" or "line", radius)
function PolyPath:drawPoints(mode, radius)
	for _, point in ipairs(self.points) do
		love.graphics.circle(mode or "fill", point.x, point.y, radius or 5)
	end
end



-- draw closest element
function PolyPath:drawClosestElement(mode, radius)
	local closest = self.closest
	local index = closest and closest.index
	if closest and closest.type == "point" and self.points[index] then
		love.graphics.circle(mode or "fill", self.points[index].x, self.points[index].y, radius or 5)
	elseif closest and closest.type == "segment" and self.points[index] and self.points[index + 1] then
		love.graphics.line(self.points[index].x, self.points[index].y,
			self.points[index + 1].x, self.points[index + 1].y)
		love.graphics.circle("line", closest.x, closest.y, 10)
	end
end



------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------

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
			local dist, proj_x, proj_y = calculateSquaredDistance(x, y, p1, p2)
			if dist <= radiusSquared and dist < resultDist then
				resultDist = dist
				resultData = {x = proj_x, y = proj_y}
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
    print("handleMousePress: button=" .. button) -- debug
    local closest = self.interaction and self.interaction.state == "hovered" and self.interaction 
    if not closest then
        closest = self:findClosestPointOrSegment(x, y, PolyPath.config.grabRadius)
    end
    print("closest in handleMousePress:") -- debug
    print(serpent.block(closest)) -- debug
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
		print ('handleMouseMove')
		print (serpent.block (self.interaction))

		if love.mouse.isDown(1) then
			if not self.interaction.prev_x or not self.interaction.prev_y then
				print("error: prev_x or prev_y is nil in dragging state") -- debug
				self.interaction = nil
				return
			end
--            print("dragging: x=" .. x .. ", y=" .. y .. ", prev_x=" .. self.interaction.prev_x) -- debug
			local dx = x - self.interaction.prev_x
			local dy = y - self.interaction.prev_y
			if self.interaction.type == "point" then
				self.points[self.interaction.index].x = self.points[self.interaction.index].x + dx
				self.points[self.interaction.index].y = self.points[self.interaction.index].y + dy
				self.interaction.data = {x = self.points[self.interaction.index].x, y = self.points[self.interaction.index].y}
			elseif self.interaction.type == "segment" then
				local p1 = self.points[self.interaction.index]
				local p2 = self.points[self.interaction.index + 1]
				p1.x = p1.x + dx
				p1.y = p1.y + dy
				p2.x = p2.x + dx
				p2.y = p2.y + dy
				self.interaction.data = {x = x, y = y}
				self.interaction.prev_x2 = p2.x2
				self.interaction.prev_y2 = p2.y
			end
			self.interaction.prev_x = x
			self.interaction.prev_y = y
		end
		return
	end
--	print ('handleMouseMove')
	local closest = self:findClosestPointOrSegment(x, y, PolyPath.config.grabRadius)
	self.interaction = closest and {type = closest.type, index = closest.index, data = {x = closest.x, y = closest.y}, state = "hovered"} or nil
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
		local action = {
			action = "drag",
			poly = self,
			type = self.interaction.type,
			index = self.interaction.index,
			start_x = self.interaction.start_x,
			start_y = self.interaction.start_y,
			new_x = self.points[self.interaction.index].x,
			new_y = self.points[self.interaction.index].y
		}
		if self.interaction.type == "segment" then
			action.start_x2 = self.interaction.start_x2
			action.start_y2 = self.interaction.start_y2
			action.new_x2 = self.points[self.interaction.index + 1].x
			action.new_y2 = self.points[self.interaction.index + 1].y
		end
		table.insert(PolyPath.undoStack, action)
		PolyPath.redoStack = {}
		self.interaction.state = "selected"
	end
	self.interaction = self.interaction and {type = self.interaction.type, index = self.interaction.index, data = self.interaction.data, state = "selected"} or nil
end

-- handle mouse release for all polylines
function PolyPath.mousereleased(x, y, polylines)
	for _, poly in ipairs(polylines) do
		poly:handleMouseRelease(x, y)
	end
end

return PolyPath