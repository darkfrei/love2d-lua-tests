-- screen.lua
local screen = {}

-- default render size
screen.renderWidth = 1280
screen.renderHeight = 800

-- default window size
screen.windowWidth = 1920
screen.windowHeight = 1080

screen.transform = love.math.newTransform()

-- set the render size and resize the window accordingly
function screen.init(flags)

	screen.setWindowSize (screen.windowWidth, screen.windowHeight, flags)
end

function screen.setRenderSize(renderWidth, renderHeight)
	screen.renderWidth = renderWidth
	screen.renderHeight = renderHeight
	screen.resize()
end

-- set the window size and resize the render area accordingly
function screen.setWindowSize (windowWidth, windowHeight, flags)
	flags = flags or {resizable=true}
	love.window.setMode(windowWidth, windowHeight, {resizable=true})
end



-- function to handle resizing of the window
function screen.resize()
	local windowWidth, windowHeight = love.graphics.getDimensions ()


	local safeX, safeY, safeW, safeH = love.window.getSafeArea()

	local isAndroid = love.system.getOS() == "Android"
	if isAndroid then
		screen.windowWidth = math.min (windowWidth, safeW)
		screen.windowHeight = math.min(windowHeight, safeH)

		if not love.window.getFullscreen() then
			-- set safeY to 24px if the device is not fullscreen
			safeY = math.min(24, safeY)
		end
	end
	print ('windowWidth, windowHeight', windowWidth, windowHeight)
	print ('safeX, safeY, safeW, safeH', safeX, safeY, safeW, safeH)

	screen.windowWidth = windowWidth
	screen.windowHeight = windowHeight

	-- calculate scale factor
	local scaleX = screen.windowWidth / screen.renderWidth
	local scaleY = screen.windowHeight / screen.renderHeight
	local scale = math.min(scaleX, scaleY)
	screen.scale = scale

	-- calculate position to center the render rectangle
	local rectX = safeX + (safeW - screen.renderWidth * screen.scale) / 2
	local rectY = safeY + (safeH - screen.renderHeight * screen.scale) / 2

	-- apply the scaling and translation to the transform
	screen.transform = love.math.newTransform()
	screen.transform:translate(rectX, rectY)
	screen.transform:scale(scale, scale)
end


-- function to get the current translation (offsets)
function screen.getTranslate()
	local matrix = screen.transform:getMatrix()
	local translateX, translateY = matrix[4], matrix[8]
	return translateX, translateY
end


-- function to get the current scale factor
function screen.getScale()
	local matrix = screen.transform:getMatrix()
	local scaleX, scaleY = matrix[1], matrix[6]
	return scaleX, scaleY
end

-- function to get render width
function screen.getRenderWidth()
	return screen.renderWidth
end

-- function to get render height
function screen.getRenderHeight()
	return screen.renderHeight
end

-- function to convert window coordinates to render space
function screen.toRenderCoordinates(x, y)
	return screen.transform:inverseTransformPoint(x, y)
end

-- function to convert render space coordinates to window coordinates
function screen.toWindowCoordinates(x, y)
	return screen.transform:transformPoint(x, y)
end

return screen
