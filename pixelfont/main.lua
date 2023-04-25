-- License CC0 (Creative Commons license) (c) darkfrei, 2023

love.window.setMode(2200, 200)

function createFont (fontSize)
	local drawSeparator = function  (x, h)
		love.graphics.setColor (1,0,1,1)
		love.graphics.setLineStyle( "rough" )
		love.graphics.setLineWidth(1)
		love.graphics.line (x+0.5,0, x+0.5, h)
	end
	
	local font = love.graphics.newFont(fontSize, "mono")
	font:setFilter("nearest")
	love.graphics.setFont(font)
	
	
	local str = " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\""
	local width = 0 -- monowidth
	
	for i = 1, #str do
		local char = string.sub (str, i, i)
		local charWidth = font:getWidth( char )	
		width = math.max (width, charWidth)
	end
	local canvasWidth = 2+(width+1)*(#str)
	local height = font:getHeight( )

--	print (canvasWidth, height)
	local tempCanvas = love.graphics.newCanvas (canvasWidth, height)
	tempCanvas:setFilter( "nearest", "nearest")

	local x = 1

	love.graphics.setCanvas (tempCanvas)
	-- background
	love.graphics.setColor (0,0,0)
	love.graphics.rectangle ('fill', 0,0, canvasWidth+1, height)
	
	
	
	for i = 1, #str do
		local char = string.sub (str, i, i)
		local charWidth = font:getWidth( char )
		local dx = (width-charWidth)/2
		
		drawSeparator (x-1, height)
		love.graphics.setColor (1,1,1)
		love.graphics.print (char, x+dx-1,-1)
		drawSeparator (x-1, height)
		x = x + width +1
	end
	drawSeparator (x, height)
	
	Canvas = love.graphics.newCanvas (x+1, height)
	Canvas:setFilter( "nearest", "nearest")
	
	love.graphics.setCanvas (Canvas)
		love.graphics.setColor (1,1,1)
		love.graphics.draw (tempCanvas)
	love.graphics.setCanvas ()
	
	CanvasWidth, CanvasHeight = Canvas:getDimensions ()
	love.window.setTitle ('fontSize: '..fontSize..' width:'..CanvasWidth .. ' height:'..CanvasHeight)
end

function saveFont ()
	
end


fontSize = 9
createFont (fontSize)
saveFont ()

function love.draw()
	love.graphics.setColor (1,1,1)
	love.graphics.print ('press up and down arrows to change the font size', 0, 0)
	love.graphics.print ('press S to save the image', 0, CanvasHeight)
	love.graphics.draw (Canvas, 0, 10+2*CanvasHeight,0, 4,4)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "up" then
		fontSize = fontSize + 1
		createFont (fontSize)

	elseif key == "down" then
		fontSize = fontSize - 1
		createFont (fontSize)
	
	elseif key == "s" then
		Canvas:newImageData():encode("png","font-"..CanvasWidth.."-"..CanvasHeight.."-mono.png")
		love.system.openURL("file://"..love.filesystem.getSaveDirectory())
	elseif key == "escape" then
		love.event.quit()
	end
end