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

	local tempCanvas = love.graphics.newCanvas ()
	tempCanvas:setFilter( "nearest", "nearest")

	local height = font:getHeight( )
	local str = " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\""

	local x = 1

	love.graphics.setCanvas (tempCanvas)
	-- background
		love.graphics.setColor (0,0,0)
		love.graphics.rectangle ('fill', x,0, tempCanvas:getDimensions())
	
	for i = 1, #str do
		local char = string.sub (str, i, i)
		local width = font:getWidth( char )
		
		
		drawSeparator (x-1, height)
		love.graphics.setColor (1,1,1)
		love.graphics.print (char, x-1,-1)
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
		Canvas:newImageData():encode("png","font-"..CanvasWidth.."-"..CanvasHeight..".png")
		love.system.openURL("file://"..love.filesystem.getSaveDirectory())
	elseif key == "escape" then
		love.event.quit()
	end
end