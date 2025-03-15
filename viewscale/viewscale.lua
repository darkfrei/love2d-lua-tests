--  viewscale.lua
-- 2025-23-15

local ViewScale = {
	baseWidth = 1280,
	baseHeight = 800,
	scale = 1,
	offsetX = 0,
	offsetY = 0
}

function ViewScale.load(baseWidth, baseHeight)
	ViewScale.baseWidth = baseWidth or ViewScale.baseWidth
	ViewScale.baseHeight = baseHeight or ViewScale.baseHeight

	local screenWidth, screenHeight = love.window.getDesktopDimensions()

	if screenWidth == 1280 and screenHeight == 800 then
		-- if screen resolution is exactly the same as Steam Deck resolution, set fullscreen
		love.window.setMode(1280, 800, {fullscreen = true})
	elseif screenWidth >= ViewScale.baseWidth * 2 and screenHeight >= ViewScale.baseHeight * 2 then
		-- if the screen resolution is at least twice the base resolution, apply scaling
		ViewScale.scale = 2
	end

-- set resizable window with initial scaling
	love.window.setMode(ViewScale.baseWidth * ViewScale.scale, ViewScale.baseHeight * ViewScale.scale, {resizable = true, fullscreen = false})

-- update offsets
	ViewScale.resize()
end

function ViewScale.resize(w, h)

	local windowWidth, windowHeight = love.graphics.getDimensions()
	ViewScale.scale = math.min(windowWidth / ViewScale.baseWidth, windowHeight / ViewScale.baseHeight)
	ViewScale.offsetX = (windowWidth - ViewScale.baseWidth * ViewScale.scale) / 2
	ViewScale.offsetY = (windowHeight - ViewScale.baseHeight * ViewScale.scale) / 2

	-- update window title
	local title = string.format("Window: %dx%d | Render: %dx%d | Scale: %.2f | Offset: (%.1f, %.1f)",
		windowWidth, windowHeight, ViewScale.baseWidth * ViewScale.scale, ViewScale.baseHeight * ViewScale.scale,
		ViewScale.scale, ViewScale.offsetX, ViewScale.offsetY)
	love.window.setTitle(title)
end

function ViewScale.push()
	love.graphics.push()
	love.graphics.translate(ViewScale.offsetX, ViewScale.offsetY)
	love.graphics.scale(ViewScale.scale, ViewScale.scale)
end

function ViewScale.pop()
	love.graphics.pop()
end

-- adjust mouse coordinates based on scaling and offset
function ViewScale.mouseToScaled(x, y)
	local scaledX = (x - ViewScale.offsetX) / ViewScale.scale
	local scaledY = (y - ViewScale.offsetY) / ViewScale.scale
	return scaledX, scaledY
end

return ViewScale
