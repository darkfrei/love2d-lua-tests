-- main.lua
-- Demonstrates usage of PolyPath library

require("main-utils") -- just small functions
local PolyPath = require("polypath")


-- initialize polylines
function love.load()
	polylines = { PolyPath.new(), PolyPath.new(), PolyPath.new() }
	for i, poly in ipairs(polylines) do
		local success, message = poly:importFromFileSystem("polylines.txt", i)
		if not success then
			print(string.format("poly %d import failed: %s", i, message or "unknown error"))
			poly:addPoint(200, 200)
			poly:addPoint(300, 300)
			poly:addPoint(400, 200)
			poly:translate(20*i, 40*i)
			poly:rotate(math.pi/12*i, 400, 300)
			poly:scale(1+0.5*i, 1+0.5*i, 400, 300)
		end
	end
	PolyPath.clearUndoRedo()
end

-- draw undo/redo stack overlay
local function drawRedoUndoOverlay()
    love.graphics.setColor(1, 1, 1)
    local y = 10
    love.graphics.print("undo stack:", 10, y)
    for i, action in ipairs(PolyPath.undoStack) do
        y = y + 20
        local details = action.action
        if action.action == "add" or action.action == "remove" then
            details = string.format("%s (x: %.1f, y: %.1f)", action.action, action.point.x, action.point.y)
        elseif action.action == "drag" then
            details = string.format("%s (x: %.1f->%.1f, y: %.1f->%.1f)", action.action, action.prev_x, action.new_x, action.prev_y, action.new_y)
        elseif action.action == "create" or action.action == "delete" then
            details = string.format("%s (poly at index %d)", action.action, action.index)
        end
        love.graphics.print(string.format("%d: %s", i, details), 10, y)
    end
    y = y + 40
    love.graphics.print("redo stack:", 10, y)
    for i, action in ipairs(PolyPath.redoStack) do
        y = y + 20
        local details = action.action
        if action.action == "add" or action.action == "remove" then
            details = string.format("%s (x: %.1f, y: %.1f)", action.action, action.point.x, action.point.y)
        elseif action.action == "drag" then
            details = string.format("%s (x: %.1f->%.1f, y: %.1f->%.1f)", action.action, action.prev_x, action.new_x, action.prev_y, action.new_y)
        elseif action.action == "create" or action.action == "delete" then
            details = string.format("%s (poly at index %d)", action.action, action.index)
        end
        love.graphics.print(string.format("%d: %s", i, details), 10, y)
    end
end

-- draw polylines with dynamic colors
function love.draw()
    for i, poly in ipairs(polylines) do
        love.graphics.setColor(generateColor(i))
        poly:drawLines()
        poly:drawPoints("line", 5)
        if poly.interaction and (poly.interaction.state == "hovered" or poly.interaction.state == "selected") then
            love.graphics.setColor(1, 1, 1)
            poly:drawInteractionElement("fill", 7)
        end
    end
--    drawRedoUndoOverlay()
end

-- handle mouse press events
function love.mousepressed(x, y, button)
    PolyPath.mousepressed(x, y, button, polylines)
end

-- handle mouse movement events
function love.mousemoved(x, y, dx, dy)
    PolyPath.mousemoved(x, y, polylines)
end

-- handle mouse release events
function love.mousereleased(x, y, button)
    if button == 1 then
        PolyPath.mousereleased(x, y, polylines)
    end
end



-- handle key press events
function love.keypressed(key)
    if key == "escape" then
        local success, message = PolyPath.exportAllToFileSystem("polylines.txt", polylines)
        if not success then
            print("saving polylines failed: " .. (message or "unknown error"))
        end
        love.event.quit()
    elseif key == "z" and love.keyboard.isDown("lctrl", "rctrl") then
        PolyPath.undo(polylines)
    elseif key == "y" and love.keyboard.isDown("lctrl", "rctrl") then
        PolyPath.redo(polylines)
    elseif key == "n" then
        PolyPath.createPolyline()
    elseif key == "d" and #polylines > 0 then
        PolyPath.deletePolyline(#polylines)
    end
end
