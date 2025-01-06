-- [manages game resolution and scaling for different screen sizes]

local Resolution = {}
Resolution.windowWidth = 1200 -- [base window width]
Resolution.windowHeight = 800 -- [base window height]
Resolution.translateX = 0
Resolution.translateY = 0
Resolution.scale = 1 -- [scaling factor for rendering]

function Resolution.setup(baseWidth, baseHeight)
    -- [adjusts the window size and scaling for high-resolution monitors]
    
		Resolution.baseWidth = baseWidth
		Resolution.baseHeight = baseHeight

    local desktopWidth, desktopHeight = love.window.getDesktopDimensions()

    -- [limit the maximum window size to 80% of the desktop dimensions]
    desktopWidth = 0.5 * desktopWidth
    desktopHeight = 0.5 * desktopHeight

    -- [use the provided base dimensions or defaults]
    baseWidth = baseWidth or Resolution.windowWidth
    baseHeight = baseHeight or Resolution.windowHeight

    -- [calculates scale factor based on desktop resolution]
    Resolution.scale = math.min(
        math.floor(desktopWidth / baseWidth),
        math.floor(desktopHeight / baseHeight)
    )

    -- [calculates the scaled window dimensions]
    local scaledWidth = baseWidth * Resolution.scale
    local scaledHeight = baseHeight * Resolution.scale

    -- [sets the window size to fit the screen with scaling]
    love.window.setMode(
        math.floor(scaledWidth),
        math.floor(scaledHeight),
        { fullscreen = false, resizable = true, highdpi = true }
    )

    -- [store the calculated dimensions]
    Resolution.windowWidth = scaledWidth
    Resolution.windowHeight = scaledHeight

    -- [sets the window title with resolution and scale info]
    love.window.setTitle(
        string.format("%dx%d scale: %d", scaledWidth, scaledHeight, Resolution.scale)
    )

    -- [sets up graphical scaling]
    love.graphics.setDefaultFilter("nearest", "nearest")
end


function Resolution.apply()
	-- [applies scaling to all graphics]
	love.graphics.scale(Resolution.scale, Resolution.scale)
end

function Resolution.resize(w, h)
    -- [adjusts scaling for the resized window]
    local desktopWidth = w or love.graphics.getWidth()
    local desktopHeight = h or love.graphics.getHeight()

    -- [recalculate scale based on new window size]
    Resolution.scale = math.min(
        desktopWidth / Resolution.windowWidth,
        desktopHeight / Resolution.windowHeight
    )
    Resolution.scale = math.floor(Resolution.scale)

    -- [adjust canvas scaling for rendering]
    Resolution.windowWidth = desktopWidth
    Resolution.windowHeight = desktopHeight
end


return Resolution
