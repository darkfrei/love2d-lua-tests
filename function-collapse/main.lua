-- License CC0 (Creative Commons license) (c) darkfrei, 2022

-- idea based on https://youtu.be/6Vag7NJUjJo
-- Wave Function Collapse Take 2

function createTiles (size)
	love.graphics.setLineWidth(size/4)
	local lineColor = {0,0,0}
	local BackgroundColor = {0.8,0.8,0.8}
	local tiles = {}
	local blankCanvas = love.graphics.newCanvas(size, size)
	love.graphics.setCanvas (blankCanvas)
		love.graphics.setColor (BackgroundColor)
		love.graphics.rectangle ('fill', 0, 0, size, size)
	local upCanvas = love.graphics.newCanvas(size, size)
	love.graphics.setCanvas (upCanvas)
		love.graphics.setColor (BackgroundColor)
		love.graphics.rectangle ('fill', 0, 0, size, size)
		love.graphics.setColor (lineColor)
		love.graphics.line (0, size/2, size, size/2)
		love.graphics.line (size/2, size/2, size/2, 0)
	local rightCanvas = love.graphics.newCanvas(size, size)
	love.graphics.setCanvas (rightCanvas)
		love.graphics.setColor (BackgroundColor)
		love.graphics.rectangle ('fill', 0, 0, size, size)
		love.graphics.setColor (lineColor)
		love.graphics.line (size/2, 0, size/2, size)
		love.graphics.line (size/2, size/2, size, size/2)
	local downCanvas = love.graphics.newCanvas(size, size)
	love.graphics.setCanvas (downCanvas)
		love.graphics.setColor (BackgroundColor)
		love.graphics.rectangle ('fill', 0, 0, size, size)
		love.graphics.setColor (lineColor)
		love.graphics.line (0, size/2, size, size/2)
		love.graphics.line (size/2, size/2, size/2, size)
	local leftCanvas = love.graphics.newCanvas(size, size)
	love.graphics.setCanvas (leftCanvas)
		love.graphics.setColor (BackgroundColor)
		love.graphics.rectangle ('fill', 0, 0, size, size)
		love.graphics.setColor (lineColor)
		love.graphics.line (size/2, 0, size/2, size)
		love.graphics.line (size/2, size/2, 0, size/2)
	love.graphics.setCanvas ()
	return {blankCanvas, upCanvas, rightCanvas, downCanvas, leftCanvas}
end

function love.load()
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	width, height = love.graphics.getDimensions( )

	Size = 64
	Tiles = createTiles (Size)
end

 
function love.update(dt)
	
end


function love.draw()
	love.graphics.setColor(1,1,1)
	for i, canvas in ipairs (Tiles) do
		love.graphics.draw (canvas, (i-1)*Size, 0)
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end