-- =============================================
-- QFrame API - Smart 8-Patch Frame for LÖVE
-- =============================================

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

-- =============================================
-- API Reference Summary
-- =============================================

-- qframe.new(filename, x?, y?)          -> create a new frame
-- frame:setPosition(x, y)               -> set frame top-left corner
-- frame:getPosition()                   -> return frame.x, frame.y
-- frame:setBackgroud(filename, fitToFrame) -> set background image
-- frame:setBackgroudPadding({top, right, bottom, left}) -> padding around background
-- frame:setSize(width, height)          -> resize frame
-- frame:setWidth(width, keepProportion) -> resize width only
-- frame:setHeight(height, keepProportion) -> resize height only
-- frame:updateBackground()              -> rescale background to fit current frame size
-- frame:draw()                           -> draw frame + background at frame position
