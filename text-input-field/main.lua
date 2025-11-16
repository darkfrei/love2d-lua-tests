-- main.lua
-- text input field demo using text-input-field.lua
-- this file demonstrates how to create and use text input fields

local TextInputField = require("text-input-field")
local utf8 = require("utf8")

local field1, field2, field3, field4
local field5, field6, field7, field8

local playerData = {
	name = "ABCD",
	description = "New player, that can go through the fields and forests\nwith mushrooms and berries\nand can find treasure",
	health = 99.0,
	score = 4,
	notes = "Line 1\nLine 2\nLine 3\nLine 4\nLine 5\nLine 6\nLine 7"
}

-- called once at startup
function love.load()
	love.window.setTitle('demo text-input-field.lua')
	love.window.setMode(1200, 800)
	love.graphics.setBackgroundColor(0.1, 0.1, 0.12)

	-- load fonts
	local font18 = love.graphics.newFont("fonts/NotoSans-Regular.ttf", 18)
	local font20 = love.graphics.newFont("fonts/NotoSans-Regular.ttf", 20)
	local font24 = love.graphics.newFont("fonts/NotoSans-Regular.ttf", 24)

	-- Example 1: Single-line text field (name)
	field1 = TextInputField:new({
			x = 200,
			y = 60,
			w = 300,
			font = font20,
			singleLine = true, -- no newlines allowed
--		minLines = 1,
			boundTable = playerData,
			boundKey = "name"
		})

	-- Example 2: Multi-line text field (description)
	field2 = TextInputField:new({
			x = 200,
			y = 120,
			w = 300,
			font = font20,
			minLines = 3, -- minimum 3 lines visible
			newLineIndent = "> ", -- indent for new lines
			wrapIndent = "... ", -- indent for wrapped lines
			boundTable = playerData,
			boundKey = "description"
		})

	-- Example 3: Numeric field with decimal (health)
	field3 = TextInputField:new({
			x = 100,
			y = 280,
			w = 150,
			font = font24,
--			singleLine = true,
			numericOnly = true, -- "float" numbers are allowed
			min = -99,
			max = 99,
--			minLines = 1,
			boundTable = playerData,
			boundKey = "health"
		})

	-- Example 4: Numeric field integer (score)
	field4 = TextInputField:new({
			x = 100,
			y = 340,
			w = 150,
			font = font24,
			numeric = "integer",
			min = 1,
			max = 9,
			boundTable = playerData,
			boundKey = "score"
		})

	-- Example 5: Multi-line with limited visible lines (scrollable)
	field5 = TextInputField:new({
			x = 600,
			y = 60,
			w = 400,
			font = font18,
			minLines = 3,
			maxLines = 5, -- show max 5 lines, scroll the rest
			newLineIndent = "| ",
			wrapIndent = " ",
			boundTable = playerData,
			boundKey = "notes"
		})

	-- Example 6: Simple text field without binding
	field6 = TextInputField:new({
			x = 600,
			y = 280,
			w = 400,
			text = "Standalone field without data binding",
			font = font20,
			minLines = 2,
			bgColor = {0.15, 0.15, 0.2},
			borderColor = {0.5, 0.3, 0.7},
			textColor = {0.9, 0.95, 1.0},
			cursorColor = {1, 0.8, 0.3}
		})

	-- numbers integer
	field7 = TextInputField:new({
			x = 600,
			y = 360,
			w = 100,
			text = "200",
			font = font20,
			numeric = "integer",
--			minLines = 1,
			maxLines = 1,
			bgColor = {0.15, 0.15, 0.2},
			borderColor = {0.5, 0.3, 0.7},
			textColor = {0.9, 0.95, 1.0},
			cursorColor = {1, 0.8, 0.3}
		})

	-- Example 8: Numeric field float (standalone)
	field8 = TextInputField:new({
			x = 750,
			y = 360,
			w = 150,
			text = "3.1416", -- initial value
			font = font20,
			numericOnly = true, -- allow float numbers
			min = -1000,
			max = 1000,
			bgColor = {0.15, 0.15, 0.2},
			borderColor = {0.5, 0.3, 0.7},
			textColor = {0.9, 0.95, 1.0},
			cursorColor = {1, 0.8, 0.3}
		})
end

-- called every frame, updates fields and input repeat
function love.update(dt)
	field1:update(dt)
	field2:update(dt)
	field3:update(dt)
	field4:update(dt)
	field5:update(dt)
	field6:update(dt)
	field7:update(dt)
	field8:update(dt)

	-- optionally sync from bound values (if changed externally)
	field1:syncFromBoundValue()
	field2:syncFromBoundValue()
	field3:syncFromBoundValue()
	field4:syncFromBoundValue()
	field5:syncFromBoundValue()
end

function love.draw()
	-- draw section headers
	love.graphics.setColor(1, 1, 0.5)
	love.graphics.print("Single-line Fields:", 20, 20)
	love.graphics.print("Multi-line Fields:", 20, 90)
	love.graphics.print("Numeric Fields:", 20, 250)
	love.graphics.print("Scrollable Field (shown max 5 lines):", 560, 30)
	love.graphics.print("Custom Styled Field:", 560, 250)

	-- draw field labels
	love.graphics.setColor(0.8, 0.8, 0.8)
	love.graphics.print("Name:", 20, 65)
	love.graphics.print("Description:", 20, 120)
	love.graphics.print("Health:", 20, 290)
	love.graphics.print("Score:", 20, 350)

	-- draw fields
	field1:draw()
	field2:draw()
	field3:draw()
	field4:draw()
	field5:draw()
	field6:draw()
	field7:draw()
	field8:draw()

	-- display bound data
	love.graphics.setColor(0.7, 0.9, 0.7)
	love.graphics.print("Bound Data (playerData table):", 20, 380)
	love.graphics.setColor(0.6, 0.8, 0.6)
	love.graphics.print(string.format(' name: "%s" (type: %s)', 
			playerData.name, type(playerData.name)), 20, 405)
	love.graphics.print(string.format(' description: "%s..." (type: %s)', 
			playerData.description:sub(1, 600), type(playerData.description)), 20, 430)
	
	love.graphics.print(string.format(' health: %.2f (type: %s)', 
			tonumber(playerData.health) or 0, type(playerData.health)), 20, 500)
	
	love.graphics.print(string.format(' score: %s (type: %s)', 
			playerData.score, type(playerData.score)), 20, 515)
	love.graphics.print(string.format(' notes: %d lines (type: %s)', 
			select(2, playerData.notes:gsub('\n', '\n')) + 1, type(playerData.notes)), 20, 530)

	-- display standalone field value
	love.graphics.setColor(0.7, 0.7, 0.9)
	love.graphics.print("Standalone field value:", 20, 550)
	love.graphics.print(string.format(' text: "%s"', field6.text), 20, 575)

	-- display standalone float field value
	love.graphics.setColor(0.7, 0.9, 0.9)
	love.graphics.print("Standalone float field value:", 20, 600)
	love.graphics.print(string.format(' text: "%s"', field8.text), 20, 625)

	-- instructions
	love.graphics.setColor(0.6, 0.6, 0.6)
	love.graphics.print("Click to edit fields. Drag to select. Ctrl+C/V/X for copy/paste/cut.", 20, 700)
	love.graphics.print("Single-line: no Enter. Numeric: only numbers (use comma or dot).", 20, 720)
	love.graphics.print("Scrollable: use arrows to scroll when more than 5 lines.", 20, 740)
	love.graphics.print("Press SPACE to add 10 to score. Press ESC to quit.", 20, 760)

	-- show selection info for active field (if any)
	love.graphics.setColor(0.9, 0.8, 0.6)
	local activeField
	for _, f in ipairs({field1, field2, field3, field4, field5, field6, field7, field8}) do
		if f.isActive then
			activeField = f
			break
		end
	end

	if activeField then
		-- determine data type (bound or standalone)
		local dataType
		if activeField.boundTable and activeField.boundKey then
			dataType = type(activeField.boundTable[activeField.boundKey])
		else
			dataType = type(activeField.text)
		end

		local s, e = activeField:getSelectionRange()
		if s and e then
			local selected = utf8.sub(activeField.text, s, e)
			love.graphics.print(
				string.format(
					'Active field: "%s" type: %s\nSelection %d–%d (len %d): "%s"',
					activeField.boundKey or "(no binding)",
					dataType,
					s, e, utf8.len(selected),
					selected
				),
				20, 650
			)
		else
			love.graphics.print(
				string.format(
					'Active field: "%s" type: %s (no selection)',
					activeField.boundKey or "(no binding)",
					dataType
				),
				20, 650
			)
		end
	end

end

-- handles utf8 text input from keyboard
function love.textinput(t)
	field1:textinput(t)
	field2:textinput(t)
	field3:textinput(t)
	field4:textinput(t)
	field5:textinput(t)
	field6:textinput(t)
	field7:textinput(t)
	field8:textinput(t)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
		return
	end

	-- test: modify bound values externally
	if key == "space" then
		playerData.score = tostring(tonumber(playerData.score or 0) + 10)
	end

	field1:keypressed(key)
	field2:keypressed(key)
	field3:keypressed(key)
	field4:keypressed(key)
	field5:keypressed(key)
	field6:keypressed(key)
	field7:keypressed(key)
	field8:keypressed(key)
end

-- handles key release (for stopping long key repeats)
function love.keyreleased(key)
	field1:keyreleased(key)
	field2:keyreleased(key)
	field3:keyreleased(key)
	field4:keyreleased(key)
	field5:keyreleased(key)
	field6:keyreleased(key)
	field7:keyreleased(key)
	field8:keyreleased(key)
end

-- handles mouse clicks to activate or position cursor
function love.mousepressed(mx, my, button)
	field1:mousepressed(mx, my, button)
	field2:mousepressed(mx, my, button)
	field3:mousepressed(mx, my, button)
	field4:mousepressed(mx, my, button)
	field5:mousepressed(mx, my, button)
	field6:mousepressed(mx, my, button)
	field7:mousepressed(mx, my, button)
	field8:mousepressed(mx, my, button)
end

-- handles mouse dragging to update selection
function love.mousemoved(mx, my, dx, dy)
	field1:mousemoved(mx, my, dx, dy)
	field2:mousemoved(mx, my, dx, dy)
	field3:mousemoved(mx, my, dx, dy)
	field4:mousemoved(mx, my, dx, dy)
	field5:mousemoved(mx, my, dx, dy)
	field6:mousemoved(mx, my, dx, dy)
	field7:mousemoved(mx, my, dx, dy)
	field8:mousemoved(mx, my, dx, dy)
end

-- handles mouse release to end selection drag
function love.mousereleased(mx, my, button)
	field1:mousereleased(mx, my, button)
	field2:mousereleased(mx, my, button)
	field3:mousereleased(mx, my, button)
	field4:mousereleased(mx, my, button)
	field5:mousereleased(mx, my, button)
	field6:mousereleased(mx, my, button)
	field7:mousereleased(mx, my, button)
	field8:mousereleased(mx, my, button)
end


--[[
API REFERENCE:


numeric = nil -- non-numeric (default)
numeric = true -- numeric float
numeric = "float" -- numeric float
numeric = "integer" or "int" -- integer only

TextInputField:new(config) - create new text input field
config = {
	x = 0, -- x position (number)
	y = 0, -- y position (number)
	w = 200, -- width (number)
	text = "", -- initial text (string)
	cursorPos = 0, -- initial cursor position (number, 0-based)
	font = love.graphics.getFont(), -- LÖVE font object
	minLines = 3, -- minimum visible lines (number)
	maxLines = nil, -- maximum visible lines (number, nil = unlimited)
	paddingX = 5, -- horizontal padding (number)
	paddingY = 5, -- vertical padding (number)
	bgColor = {0.2, 0.2, 0.25}, -- background color {r, g, b}
	borderColor = {0.3, 0.5, 0.7}, -- border color {r, g, b}
	textColor = {1, 1, 1}, -- text color {r, g, b}
	cursorColor = {1, 1, 1}, -- cursor color {r, g, b}
	blinkSpeed = 3, -- cursor blink speed (number)
	newLineIndent = "", -- indent after \n (string)
	wrapIndent = " ", -- indent for wrapped lines (string)
	singleLine = false, -- if true, disallow newlines
	numericOnly = false, -- if true, allow only numbers
	boundTable = nil, -- table to bind to (optional)
	boundKey = nil -- key in table to bind to (optional)
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
field:syncFromBoundValue() -- sync text from bound table value
field:updateBoundValue() -- update bound table value from text
field:ensureCursorVisible() -- ensure cursor is in visible area (scrolling)

PROPERTIES (read/write):
field.text -- current text content (string)
field.cursorPos -- cursor position (number, 0-based)
field.isActive -- whether field has focus (boolean)
field.x, field.y -- position (number)
field.w, field.h -- width and height (number)
field.singleLine -- single-line mode (boolean)
field.numericOnly -- numeric-only mode (boolean)
field.scrollLineOffset -- scroll offset in lines (number)

KEYBOARD SHORTCUTS:
- Arrow keys: move cursor
- Home/End: move to start/end of line (press twice for text start/end)
- Backspace/Delete: delete characters
- Ctrl+A: select all
- Ctrl+C: copy selection
- Ctrl+V: paste from clipboard (validates in numeric mode)
- Ctrl+X: cut selection
- Tab: insert tab character (disabled in numeric mode)
- Enter: insert newline (disabled in single-line mode)

FEATURES:
- UTF-8 support
- Multi-line text with word wrapping
- Single-line mode (no newlines)
- Numeric-only mode (accepts digits, minus, dot/comma)
- Scrollable content with maxLines option
- Data binding to external tables
- Mouse click to position cursor
- Drag to select text
- Keyboard selection support
- Configurable indentation for new lines and wrapped lines
- Auto-expanding height based on content
- Smooth cursor blinking
- Key repeat for navigation and deletion
- Custom colors and styling
]]