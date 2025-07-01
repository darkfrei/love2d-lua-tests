-- viewscale.lua
-- 2025-06-28
-- https://github.com/darkfrei/viewscale.lua
-- https://github.com/darkfrei/love2d-lua-tests/tree/main/viewscale

-- handles screen scaling and coordinate transformations for maintaining consistent
-- rendering across different display resolutions. provides:
-- - automatic scaling based on screen size
-- - centered rendering with top/side black bars when needed
-- - coordinate transformation for mouse input
-- - debug information in window title

local ViewScale = {
	baseWidth = 1280,   -- reference width for game rendering
	baseHeight = 800,   -- reference height for game rendering
	scale = 1,          -- current scaling factor
	offsetX = 0,        -- horizontal offset for centering
	offsetY = 0         -- vertical offset for centering
}

-- initializes the scaling system
-- baseWidth: target rendering width (optional)
-- baseHeight: target rendering height (optional)
function ViewScale.load(baseWidth, baseHeight)
	ViewScale.baseWidth = baseWidth or ViewScale.baseWidth
	ViewScale.baseHeight = baseHeight or ViewScale.baseHeight

	-- detect screen resolution
	local screenWidth, screenHeight = love.window.getDesktopDimensions()

	-- special handling for steam deck resolution
	if screenWidth == 1280 and screenHeight == 800 then
		love.window.setMode(1280, 800, {fullscreen = true})
	elseif screenWidth >= ViewScale.baseWidth * 2 and screenHeight >= ViewScale.baseHeight * 2 then
		-- use 2x scaling on high-res displays
		ViewScale.scale = 2
	end

	-- create resizable window
	love.window.setMode(
		ViewScale.baseWidth * ViewScale.scale,
		ViewScale.baseHeight * ViewScale.scale,
		{resizable = true, fullscreen = false}
	)

	-- calculate initial scaling and offsets
	ViewScale.resize()
end

-- recalculates scaling when window is resized
-- w: new window width (optional)
-- h: new window height (optional)
function ViewScale.resize(w, h)
	local windowWidth, windowHeight = love.graphics.getDimensions()

	-- calculate scale to fit while maintaining aspect ratio
	ViewScale.scale = math.min(
		windowWidth / ViewScale.baseWidth,
		windowHeight / ViewScale.baseHeight
	)

	-- calculate centering offsets
	ViewScale.offsetX = (windowWidth - ViewScale.baseWidth * ViewScale.scale) / 2
	ViewScale.offsetY = (windowHeight - ViewScale.baseHeight * ViewScale.scale) / 2

	-- update window title with debug info
	local title = string.format(
		"Window: %dx%d | Render: %dx%d | Scale: %.2f | Offset: (%.1f, %.1f)",
		windowWidth, windowHeight,
		ViewScale.baseWidth * ViewScale.scale,
		ViewScale.baseHeight * ViewScale.scale,
		ViewScale.scale,
		ViewScale.offsetX,
		ViewScale.offsetY
	)
	love.window.setTitle(title)
end

-- sets up the graphics transform for rendering
function ViewScale.push()
	love.graphics.push()
	love.graphics.translate(ViewScale.offsetX, ViewScale.offsetY)
	love.graphics.scale(ViewScale.scale, ViewScale.scale)
end

-- restores the graphics transform after rendering
function ViewScale.pop()
	love.graphics.pop()
end

-- converts mouse coordinates to game coordinates
-- x: screen x position
-- y: screen y position
-- returns: scaled x, scaled y
function ViewScale.mouseToScaled(x, y)
	local scaledX = (x - ViewScale.offsetX) / ViewScale.scale
	local scaledY = (y - ViewScale.offsetY) / ViewScale.scale
	return scaledX, scaledY
end

return ViewScale