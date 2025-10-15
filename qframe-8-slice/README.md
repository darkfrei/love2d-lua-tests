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


-- -------------------------------------------------
-- 9 - Example in Love2D
-- -------------------------------------------------
function love.load()
    local qframe = require("qframe")

    frame = qframe.new("frame.png")
    frame:setBackgroud("background.png", true)
    frame:setBackgroudPadding({left=30, top=25, right=30, bottom=30})

end

function love.update(dt)
    local x, y = love.mouse.getPosition()
    frame:setSize(x, y)
    frame:updateBackground()
end

function love.draw()
    frame:draw(50, 50)
end

-- -------------------------------------------------
-- 10 - Requirements
-- -------------------------------------------------
-- Love2D 11.0+
-- PNG images with transparency

-- -------------------------------------------------
-- 11 - License
-- -------------------------------------------------
-- MIT License, darkfrei 2025

