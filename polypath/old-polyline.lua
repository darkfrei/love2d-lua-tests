-- polypath.lua
-- PolyPath library for working with polylines in Love2D

local PolyPath = {}
PolyPath.__index = PolyPath

-- local helper function: calculate distance from point (x, y) to node or segment
local function CalculateDistance(x, y, p1, p2)
    if p2 then -- segment
        local dx = p2.x - p1.x
        local dy = p2.y - p1.y
        local len_squared = dx*dx + dy*dy
        if len_squared == 0 then return math.huge end -- degenerate segment
        local t = math.max(0, math.min(1, ((x - p1.x)*dx + (y - p1.y)*dy) / len_squared))
        local proj_x = p1.x + t * dx
        local proj_y = p1.y + t * dy
        return math.sqrt((x - proj_x)^2 + (y - proj_y)^2), proj_x, proj_y
    else -- node
        local dx = x - p1.x
        local dy = y - p1.y
        return math.sqrt(dx*dx + dy*dy)
    end
end

-- local helper function: get projection point on segment
local function GetProjectionOnSegment(x, y, p1, p2)
    local dx = p2.x - p1.x
        local dy = p2.y - p1.y
    local len_squared = dx*dx + dy*dy
    if len_squared == 0 then return p1.x, p1.y end
    local t = math.max(0, math.min(1, ((x - p1.x)*dx + (y - p1.y)*dy) / len_squared))
    return p1.x + t * dx, p1.y + t * dy
end

-- create new PolyPath
function PolyPath.new()
    local self = setmetatable({}, PolyPath)
    self.points = {} -- list of points {x, y}
    self.selected = nil -- selected element: {type, index, data}
    self.drag_data = nil -- drag data: {type, index, prev_x, prev_y}
    self.hovered = nil -- hovered element: {type, index}
    self.click_start = nil -- click start: {x, y, index}
    self.grab_radius = 20 -- capture radius for selection
    self.last_click_time = 0 -- time of last click for double-click detection
    self.double_click_interval = 0.3 -- 300ms for double-click
    return self
end

-- add point to PolyPath
function PolyPath:addPoint(x, y)
    table.insert(self.points, {x = x, y = y})
end

-- remove point from PolyPath by index
function PolyPath:removePoint(index)
    if self.points[index] then
        table.remove(self.points, index)
    end
end

-- export PolyPath to file
function PolyPath:exportToFile(filename)
    local file = io.open(filename, "w")
    if file then
        for _, point in ipairs(self.points) do
            file:write(string.format("%f,%f\n", point.x, point.y))
        end
        file:close()
    end
end

-- import PolyPath from file
function PolyPath:importFromFile(filename)
    local file = io.open(filename, "r")
    if file then
        self.points = {}
        for line in file:lines() do
            local x, y = line:match("([^,]+),([^,]+)")
            if x and y then
                self:addPoint(tonumber(x), tonumber(y))
            end
        end
        file:close()
    end
end

-- export PolyPath to filesystem (Love2D)
function PolyPath:exportToFileSystem(filename)
    local data = ""
    for _, point in ipairs(self.points) do
        data = data .. string.format("%f,%f\n", point.x, point.y)
    end
    local success, message = love.filesystem.write(filename, data)
    return success, message
end

-- import PolyPath from filesystem (Love2D)
function PolyPath:importFromFileSystem(filename)
    local data, message = love.filesystem.read(filename)
    if data then
        self.points = {}
        for line in data:gmatch("[^\n]+") do
            local x, y = line:match("([^,]+),([^,]+)")
            if x and y then
                self:addPoint(tonumber(x), tonumber(y))
            end
        end
        return true
    end
    return false, message
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
        point.x = cx + (point.x - cx) * sx
        point.y = cy + (point.y - cy) * sy
    end
end

-- draw PolyPath and interactive elements
function PolyPath:draw(color)
    -- draw PolyPath
    love.graphics.setColor(color or {1, 1, 1})
    if #self.points < 2 then return end
    for i = 1, #self.points - 1 do
        love.graphics.line(self.points[i].x, self.points[i].y,
                          self.points[i+1].x, self.points[i+1].y)
    end
    
    -- draw control points
    love.graphics.setColor(1, 1, 1)
    self:drawPoints("fill", 5)
    
    -- highlight hovered element (yellow)
    if self.hovered then
        love.graphics.setColor(1, 1, 0)
        self:drawSingleElement(self.hovered.type, self.hovered.index, "fill", 7)
    end
    
    -- highlight selected element (green)
    if self.selected then
        love.graphics.setColor(0, 1, 0)
        self:drawSingleElement(self.selected.type, self.selected.index, "fill", 7)
    end
end

-- draw control points (mode: "fill" or "line", radius)
function PolyPath:drawPoints(mode, radius)
    for _, point in ipairs(self.points) do
        love.graphics.circle(mode or "fill", point.x, point.y, radius or 5)
    end
end

-- draw single node or segment
function PolyPath:drawSingleElement(type, index, mode, radius)
    if type == "point" and self.points[index] then
        love.graphics.circle(mode or "fill", self.points[index].x, self.points[index].y, radius or 5)
    elseif type == "segment" and self.points[index] and self.points[index + 1] then
        love.graphics.line(self.points[index].x, self.points[index].y,
                          self.points[index + 1].x, self.points[index + 1].y)
    end
end

-- find closest point or segment within capture radius, prioritizing points
function PolyPath:findClosestPointOrSegment(x, y, radius)
    if #self.points == 0 then return nil end

    local closest = nil
    local min_dist = math.huge
    local result_type = nil -- "point" or "segment"
    local index = nil -- index of point or start of segment

    -- check distance to points first (higher priority)
    for i, point in ipairs(self.points) do
        local dist = CalculateDistance(x, y, point)
        if dist <= radius and dist < min_dist then
            min_dist = dist
            closest = point
            result_type = "point"
            index = i
        end
    end

    -- check distance to segments only if no point is close enough
    if not closest then
        for i = 1, #self.points - 1 do
            local p1 = self.points[i]
            local p2 = self.points[i + 1]
            local dist, proj_x, proj_y = CalculateDistance(x, y, p1, p2)
            if dist <= radius and dist < min_dist then
                min_dist = dist
                closest = {x = proj_x, y = proj_y, start_index = i, end_index = i + 1}
                result_type = "segment"
                index = i
            end
        end
    end

    if closest then
        return {type = result_type, index = index, data = closest, dist = min_dist}
    end
    return nil
end

-- start drag or handle double-click
function PolyPath:startDrag(x, y, button)
    if button == 1 then -- left mouse button for drag-and-drop or double-click
        local current_time = love.timer.getTime()
        local is_double_click = (current_time - self.last_click_time) <= self.double_click_interval
        self.last_click_time = current_time

        local result = self:findClosestPointOrSegment(x, y, self.grab_radius)
        if result and is_double_click then
            if result.type == "point" and #self.points > 1 then
                -- double-click on point: remove it
                self:removePoint(result.index)
            elseif result.type == "segment" then
                -- double-click on segment: add node
                local new_x, new_y = GetProjectionOnSegment(x, y, self.points[result.index], self.points[result.index + 1])
                table.insert(self.points, result.index + 1, {x = new_x, y = new_y})
            end
            self.selected = nil
            self.drag_data = nil
            self.click_start = nil
        elseif result then
            -- single click: start drag
            self.selected = {type = result.type, index = result.index, data = result.data}
            self.drag_data = {
                type = result.type,
                index = result.index,
                prev_x = x,
                prev_y = y
            }
            self.click_start = {x = x, y = y, index = result.index}
        else
            self.selected = nil
            self.drag_data = nil
            self.click_start = nil
        end
    elseif button == 2 then -- right mouse button for adding/deleting nodes
        local result = self:findClosestPointOrSegment(x, y, self.grab_radius)
        if result then
            if result.type == "segment" then
                -- add node at closest point on segment
                local new_x, new_y = GetProjectionOnSegment(x, y, self.points[result.index], self.points[result.index + 1])
                table.insert(self.points, result.index + 1, {x = new_x, y = new_y})
            elseif result.type == "point" then
                -- delete node if first or last point
                if (result.index == 1 or result.index == #self.points) and #self.points > 1 then
                    self:removePoint(result.index)
                end
            end
        end
    end
end

-- update drag position
function PolyPath:updateDrag(x, y)
    self.hovered = self:findClosestPointOrSegment(x, y, self.grab_radius)
    if self.drag_data and love.mouse.isDown(1) then
        local delta_x = x - self.drag_data.prev_x
        local delta_y = y - self.drag_data.prev_y
        if self.drag_data.type == "point" then
            -- move single point
            self.points[self.drag_data.index].x = self.points[self.drag_data.index].x + delta_x
            self.points[self.drag_data.index].y = self.points[self.drag_data.index].y + delta_y
        elseif self.drag_data.type == "segment" then
            -- move both points of the segment
            self.points[self.drag_data.index].x = self.points[self.drag_data.index].x + delta_x
            self.points[self.drag_data.index].y = self.points[self.drag_data.index].y + delta_y
            self.points[self.drag_data.index + 1].x = self.points[self.drag_data.index + 1].x + delta_x
            self.points[self.drag_data.index + 1].y = self.points[self.drag_data.index + 1].y + delta_y
        end
        -- update prev_x position
        self.drag_data.prev_x = x
        self.drag_data.prev_y = y
    end
end

-- end drag
function PolyPath:endDrag(x, y)
    self.drag_data = nil
    self.click_start = nil
end

return PolyPath