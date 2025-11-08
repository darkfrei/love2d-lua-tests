-- main.lua
-- text input field demo using text-input-field.lua
-- this file demonstrates how to create and use text input fields

local TextInputField = require("text-input-field")

local field1, field2

-- called once at startup
function love.load()
	love.window.setTitle ('demo text-input-field.lua')
	-- load fonts
	local font20 = love.graphics.newFont("fonts/NotoSans-Regular.ttf", 20)
	local font30 = love.graphics.newFont("fonts/NotoSans-Regular.ttf", 30)

	-- create first text input field
	-- parameters:
	--   x, y : position of the field
	--   w    : width of the field
	--   text : initial text content
	--   font : love font object
	field1 = TextInputField:new({
		x = 360,
		y = 20,
		w = 420,
		text = "Первая строка.\nАторая строка.\nТретья реально длинная строка, что она прям никуда не лезет",
		font = font20
	})

	-- create second text input field with a different font size
	field2 = TextInputField:new({
		x = 20,
		y = 20,
		w = 320,
		text = [[First Line.
Second Line.
Very long third line that needs wrap.]],
		font = font30
	})
end

-- called every frame, updates fields and input repeat
function love.update(dt)
	field1:update(dt)
	field2:update(dt)
end

-- called every frame to render the fields
function love.draw()
	field1:draw()
	field2:draw()
end

-- handles utf8 text input from keyboard
function love.textinput(t)
	field1:textinput(t)
	field2:textinput(t)
end

-- handles keyboard keypresses
-- includes navigation (arrows, home/end), backspace/delete, enter, etc.
function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
		return
	end

	field1:keypressed(key)
	field2:keypressed(key)
end

-- handles key release (for stopping long key repeats)
function love.keyreleased(key)
	field1:keyreleased(key)
	field2:keyreleased(key)
end

-- handles mouse clicks to activate or position cursor
function love.mousepressed(mx, my, button)
	field1:mousepressed(mx, my, button)
	field2:mousepressed(mx, my, button)
end

-- handles mouse dragging to update selection
function love.mousemoved(mx, my, dx, dy)
	field1:mousemoved(mx, my, dx, dy)
	field2:mousemoved(mx, my, dx, dy)
end

-- handles mouse release to end selection drag
function love.mousereleased(mx, my, button)
	field1:mousereleased(mx, my, button)
	field2:mousereleased(mx, my, button)
end


--[[
API REFERENCE:

TextInputField:new(config) - create new text input field
 config = {
 x = 0, -- x position (number)
 y = 0, -- y position (number)
 w = 200, -- width (number)
 text = "", -- initial text (string)
 cursorPos = 0, -- initial cursor position (number, 0-based)
 font = love.graphics.getFont(), -- LÖVE font object
 minLines = 3, -- minimum visible lines (number)
 paddingX = 5, -- horizontal padding (number)
 paddingY = 5, -- vertical padding (number)
 bgColor = {0.2, 0.2, 0.25}, -- background color {r, g, b}
 borderColor = {0.3, 0.5, 0.7}, -- border color {r, g, b}
 textColor = {1, 1, 1}, -- text color {r, g, b}
 cursorColor = {1, 1, 1}, -- cursor color {r, g, b}
 blinkSpeed = 3, -- cursor blink speed (number)
 newLineIndent = "", -- indent after \n (string)
 wrapIndent = " " -- indent for wrapped lines (string)
 }

METHODS:
 field:update(dt) -- call in love.update() for key repeat
 field:draw() -- call in love.draw() to render field
 field:textinput(t) -- call in love.textinput()
 field:keypressed(key) -- call in love.keypressed()
 field:keyreleased(key) -- call in love.keyreleased()
 field:mousepressed(mx, my, button) -- call in love.mousepressed()
 field:mousereleased(mx, my, button) -- call in love.mousereleased()
 field:mousemoved(mx, my, dx, dy) -- call in love.mousemoved()

PROPERTIES (read/write):
 field.text -- current text content (string)
 field.cursorPos -- cursor position (number, 0-based)
 field.isActive -- whether field has focus (boolean)
 field.x, field.y -- position (number)
 field.w, field.h -- width and height (number)

KEYBOARD SHORTCUTS:
 - Arrow keys: move cursor
 - Home/End: move to start/end of line (press twice for text start/end)
 - Backspace/Delete: delete characters
 - Ctrl+A: select all
 - Ctrl+C: copy selection
 - Ctrl+V: paste from clipboard
 - Ctrl+X: cut selection
 - Tab: insert tab character
 - Enter: insert newline

FEATURES:
 - UTF-8 support
 - Multi-line text with word wrapping
 - Mouse click to position cursor
 - Drag to select text
 - Keyboard selection support
 - Configurable indentation for new lines and wrapped lines
 - Auto-expanding height based on content
 - Smooth cursor blinking
 - Key repeat for navigation and deletion
]]