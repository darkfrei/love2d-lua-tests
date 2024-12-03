-- function to calculate the distance between two points
local function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- function to find the nearest point on a segment or one of its endpoints
local function nearestPointOnSegment(px, py, x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
    local segmentLengthSquared = dx * dx + dy * dy

    if segmentLengthSquared == 0 then
        -- segment is degenerate, return the start point
        return x1, y1, distance(px, py, x1, y1)
    end

    -- calculate the parameter t
    local t = ((px - x1) * dx + (py - y1) * dy) / segmentLengthSquared
    if t <= 0 then
        -- nearest point is the start point
        return x1, y1, distance(px, py, x1, y1)
    elseif t >= 1 then
        -- nearest point is the end point
        return x2, y2, distance(px, py, x2, y2)
    else
        -- nearest point is on the segment
        local projX, projY = x1 + t * dx, y1 + t * dy
        return projX, projY, distance(px, py, projX, projY)
    end
end

-- function to find the nearest segment and point
local function findNearestSegmentOrPoint(polyline, ax, ay)
    local minDistance = math.huge
    local nearestSegment = nil
    local nearestPoint = nil
    local nearestNode = nil

    for i = 1, #polyline - 2, 2 do
        local x1, y1 = polyline[i], polyline[i + 1]
        local x2, y2 = polyline[i + 2], polyline[i + 3]

        -- find the nearest point on the current segment
        local px, py, dist = nearestPointOnSegment(ax, ay, x1, y1, x2, y2)

        -- update the minimum distance and nearest point
        if dist < minDistance then
            minDistance = dist
            nearestPoint = {x=px, y=py}

            -- check if the nearest point is one of the nodes
            if (px == x1 and py == y1) or (px == x2 and py == y2) then
                nearestNode = nearestPoint
                nearestSegment = nil
            else
                nearestNode = nil
                nearestSegment = {x1, y1, x2, y2}
            end
        end
    end

    return nearestSegment, nearestPoint, nearestNode
end

-- love2d callback functions
function love.load()
    -- define a polyline
    polyline = {100, 100, 200, 100, 300, 300, 100, 400}

    -- initialize mouse point
    mousePoint = {x=0, y=0}

    -- find the nearest segment and point based on initial mouse position
    nearestSegment, nearestPoint, nearestNode = findNearestSegmentOrPoint(polyline, mousePoint.x, mousePoint.y)
end

function love.mousemoved(x, y, dx, dy, istouch)
    -- update mouse point position
    mousePoint.x, mousePoint.y = x, y

    -- recalculate the nearest segment and point
    nearestSegment, nearestPoint, nearestNode = findNearestSegmentOrPoint(polyline, mousePoint.x, mousePoint.y)
end



function love.draw()
    -- draw the polyline
    love.graphics.setColor(1, 1, 0) -- yellow for polyline
    love.graphics.line(polyline)

    -- draw the mouse point
    love.graphics.setColor(1, 1, 1) -- white for mouse point
    love.graphics.circle("fill", mousePoint.x, mousePoint.y, 5)

    if nearestNode then
        -- draw the nearest node if it exists
        love.graphics.setColor(1, 0, 0) -- red for nearest node
        love.graphics.circle("fill", nearestNode.x, nearestNode.y, 5)
        love.graphics.line(mousePoint.x, mousePoint.y, nearestNode.x, nearestNode.y)
    elseif nearestPoint then
        -- highlight the nearest segment if it exists
        love.graphics.setColor(0, 0, 1) -- blue for nearest segment
        love.graphics.line(nearestSegment)

        -- draw the nearest point if it's not a node
        love.graphics.setColor(0, 1, 0) -- green for nearest point
        love.graphics.circle("fill", nearestPoint.x, nearestPoint.y, 5)
        love.graphics.line(mousePoint.x, mousePoint.y, nearestPoint.x, nearestPoint.y)
    end
end
