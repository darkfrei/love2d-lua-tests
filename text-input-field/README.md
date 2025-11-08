# text-input-field.lua

A lightweight UTF-8 compatible text input field module for LÖVE2D.

This module provides a standalone multiline text input widget with full UTF-8 support, mouse selection, cursor control, keyboard shortcuts, and visual indentation. It is suitable for text editors, debug consoles, chat interfaces, or any UI requiring text input.

---

## Features

- Full UTF-8 input and rendering support
- Multiline text with automatic word wrapping
- Mouse click to position cursor
- Drag to select text
- Keyboard shortcuts (Ctrl+A, Ctrl+C, Ctrl+V, Ctrl+X)
- Arrow key navigation with vertical cursor position memory
- Home/End keys (press once for line start/end, twice for text start/end)
- Backspace/Delete with key repeat
- Tab character support
- Blinking cursor with customizable speed
- Visual indentation for new lines and wrapped lines
- Text selection highlighting
- Customizable colors, fonts, and padding
- Performance optimized with line wrapping cache
- Simple API for integration with LÖVE2D

---

## Installation

Copy `text-input-field.lua` into your project directory and require it:
```lua
local TextInputField = require("text-input-field")
```

---

## Basic Example
```lua
local TextInputField = require("text-input-field")

local field

function love.load()
	local font = love.graphics.newFont(20)

	field = TextInputField:new({
		x = 50,
		y = 50,
		w = 400,
		text = "Hello, world!",
		font = font,
		minLines = 3,
		newLineIndent = "> ",   -- indent for new lines after Enter
		wrapIndent = "... ",    -- indent for wrapped continuation lines
	})
end

function love.textinput(t)
	field:textinput(t)
end

function love.keypressed(key)
	field:keypressed(key)
end

function love.keyreleased(key)
	field:keyreleased(key)
end

function love.mousepressed(x, y, button)
	field:mousepressed(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
	field:mousemoved(x, y, dx, dy)
end

function love.mousereleased(x, y, button)
	field:mousereleased(x, y, button)
end

function love.update(dt)
	field:update(dt)
end

function love.draw()
	field:draw()
end
```

---

## API Reference

### Creating a Field
```lua
field = TextInputField:new(config)
```

**Configuration options:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `x` | number | `0` | X position of the field |
| `y` | number | `0` | Y position of the field |
| `w` | number | `200` | Width of the field |
| `text` | string | `""` | Initial text content |
| `cursorPos` | number | `0` | Initial cursor position (0-based) |
| `font` | Font | `love.graphics.getFont()` | LÖVE font object |
| `minLines` | number | `3` | Minimum visible lines |
| `paddingX` | number | `5` | Horizontal padding |
| `paddingY` | number | `5` | Vertical padding |
| `bgColor` | table | `{0.2, 0.2, 0.25}` | Background color RGB |
| `borderColor` | table | `{0.3, 0.5, 0.7}` | Border color RGB |
| `textColor` | table | `{1, 1, 1}` | Text color RGB |
| `cursorColor` | table | `{1, 1, 1}` | Cursor color RGB |
| `blinkSpeed` | number | `3` | Cursor blink speed |
| `newLineIndent` | string | `"> "` | Indent prefix for new lines |
| `wrapIndent` | string | `"... "` | Indent prefix for wrapped lines |

---

### Methods

#### Event Handlers

These methods should be called from their corresponding LÖVE callbacks:
```lua
field:textinput(t)                    -- handle text input
field:keypressed(key)                 -- handle key press
field:keyreleased(key)                -- handle key release
field:mousepressed(x, y, button)      -- handle mouse press
field:mousemoved(x, y, dx, dy)        -- handle mouse movement
field:mousereleased(x, y, button)     -- handle mouse release
field:update(dt)                      -- update (handles key repeat)
field:draw()                          -- draw the field
```

#### Utility Methods
```lua
field:updateCache()                   -- manually update line wrapping cache
field:invalidateCache()               -- mark cache as invalid
field:getWrappedLines()               -- get cached wrapped lines data
field:updateHeight()                  -- recalculate field height
field:updateDesiredX()                -- update cursor X position memory
field:clearSelection()                -- clear text selection
field:getSelectionRange()             -- get selection start and end indices
field:replaceSelection(text)          -- replace selected text
field:replaceText(start, end, text)   -- replace text between indices
field:moveCursorHome()                -- move cursor to line/text start
field:moveCursorEnd()                 -- move cursor to line/text end
field:moveCursorVertical(direction)   -- move cursor up (-1) or down (1)
```

---

### Properties

You can read and modify these properties directly:
```lua
field.text          -- current text content (string)
field.cursorPos     -- cursor position (number, 0-based)
field.isActive      -- whether field has focus (boolean)
field.x, field.y    -- position (number)
field.w, field.h    -- width and height (number, h is auto-calculated)
```

---

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| Arrow keys | Move cursor |
| Ctrl+Left/Right | Move cursor (future: word jump) |
| Home | Move to start of line, press twice for text start |
| End | Move to end of line, press twice for text end |
| Backspace | Delete character before cursor |
| Delete | Delete character after cursor |
| Enter | Insert newline |
| Tab | Insert tab character |
| Ctrl+A | Select all text |
| Ctrl+C | Copy selection to clipboard |
| Ctrl+V | Paste from clipboard |
| Ctrl+X | Cut selection to clipboard |

---

## Advanced Usage

### Multiple Fields

You can create multiple text input fields and manage focus:
```lua
local field1, field2

function love.load()
	field1 = TextInputField:new({x = 50, y = 50, w = 400})
	field2 = TextInputField:new({x = 50, y = 200, w = 400})
end

function love.mousepressed(x, y, button)
	-- each field handles its own activation automatically
	field1:mousepressed(x, y, button)
	field2:mousepressed(x, y, button)
end

-- forward other events to both fields
```

### Custom Styling
```lua
field = TextInputField:new({
	x = 100,
	y = 100,
	w = 500,
	font = love.graphics.newFont(24),
	bgColor = {0.1, 0.1, 0.15},
	borderColor = {0.5, 0.3, 0.7},
	textColor = {0.9, 0.95, 1.0},
	cursorColor = {1, 0.8, 0.3},
	blinkSpeed = 2,
	newLineIndent = "| ",
	wrapIndent = "  ",
})
```

### Programmatic Text Manipulation
```lua
-- set text
field.text = "New content"
field:invalidateCache()
field:updateHeight()

-- move cursor
field.cursorPos = 10
field:updateDesiredX()

-- get text length
local length = utf8.len(field.text)

-- check if field has focus
if field.isActive then
	-- field is active
end
```

---

## Implementation Details

### Line Wrapping Cache

The module uses a caching system to avoid recalculating line wraps every frame. The cache is automatically invalidated when text changes and recalculated on next access.

### UTF-8 Support

All string operations use UTF-8 aware functions. Cursor positions are stored as codepoint indices (0-based), not byte offsets.

### Indentation System

Two types of indentation are supported:
- `newLineIndent`: Applied to lines that start after pressing Enter
- `wrapIndent`: Applied to continuation lines when text wraps due to width

Indent symbols are drawn with 40% opacity to visually distinguish them from actual content.

### Cursor Position Memory

When moving vertically with arrow keys, the cursor remembers its horizontal position and tries to maintain it across lines with different lengths.

---

## License

This module is provided as-is for use in any project.

---

## Requirements

- LÖVE 11.0 or higher (tested with 11.4)
- UTF-8 support (built into Lua 5.3+)

---

## Notes

- The field height auto-expands based on content
- Text selection is stored as cursor positions, not screen coordinates
- Clicking outside the field deactivates it
- Only one field can be active at a time
- The cache is thread-safe for single-threaded use (standard LÖVE)