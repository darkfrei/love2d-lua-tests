```lua

-- =============================================
-- QFrame — Smart 8-Patch Frame for LÖVE (Love2D)
-- =============================================

-- qframe.lua is a lightweight library for Love2D
-- that allows 8-patch frames with padding, auto-scaling,
-- and dynamic resizing around a background image.

-- -------------------------------------------------
-- 1 - Loading the module
-- -------------------------------------------------
local qframe = require("qframe")

-- -------------------------------------------------
-- 2 - Creating a frame
-- -------------------------------------------------
-- frame = qframe.new(filename)
local frame = qframe.new("frame.png")
-- returns a frame object

-- -------------------------------------------------
-- 3 - Setting a background
-- -------------------------------------------------
-- frame:setBackground(filename, autosize)
frame:setBackground("background.png", true)
-- if autosize == true, frame grows to fit background
-- including padding

-- -------------------------------------------------
-- 4 - Setting frame size
-- -------------------------------------------------
-- frame:setSize(width, height)
frame:setSize(400, 300)

-- frame:setWidth(width, keepProportion)
frame:setWidth(450, true)  -- keep proportion

-- frame:setHeight(height, keepProportion)
frame:setHeight(350, false)  -- resize ignoring proportion

-- -------------------------------------------------
-- 5 - Padding
-- -------------------------------------------------
-- frame:setPadding({top, right, bottom, left})
-- frame size automatically adjusts to include padding
frame:setPadding({top = 60, right = 60, bottom = 60, left = 60})

-- -------------------------------------------------
-- 6 - Update background scaling (after resizing)
-- -------------------------------------------------
frame:updateBackground()
-- call after setSize to rescale the background inside frame

-- -------------------------------------------------
-- 7 - Drawing
-- -------------------------------------------------
-- frame:draw(x, y)
frame:draw(50, 50)
-- draws the background and the 8-patch frame

```

```lua
-- 1 - Load the module
local qframe = require("qframe")

function love.load()
	love.graphics.setBackgroundColor (69/255,84/255,143/255)
	
-- 2 - Create a frame object
-- qframe.new(filename)
-- returns a new frame object
-- optional second and third arguments can be x, y position
	frame = qframe.new("frame.png")
	frame:setPosition(50, 50)  -- set top-left corner position

-- 3 - Set a background image
-- frame:setBackgroud(filename, fitToFrame)
-- if fitToFrame == true, frame size adjusts to fit background + padding
	frame:setBackgroud("background.png", true)

-- 4 - Set padding around the background
-- frame:setBackgroudPadding({left, top, right, bottom})
-- frame size automatically increases to include padding
	frame:setBackgroudPadding({left = 30, top = 25, right = 30, bottom = 30})
end

-- 5 - Update frame size interactively with mouse
function love.mousemoved(x, y)
	-- get current top-left position
	local x1, y1 = frame:getPosition()

	-- calculate new size based on mouse position
	local newWidth  = x - x1
	local newHeight = y - y1

	-- set new frame size
	frame:setSize(newWidth, newHeight)

	-- update background scaling inside frame
	frame:updateBackground()
end

-- 6 - Draw frame and background
-- frame:draw() automatically draws at frame.x, frame.y
function love.draw()
	frame:draw()
end

```

```lua

-- -------------------------------------------------
-- 10 - Requirements
-- -------------------------------------------------
-- Love2D 11.0+
-- PNG images with transparency

-- -------------------------------------------------
-- 11 - License
-- -------------------------------------------------
-- MIT License, darkfrei 2025

```


