-- bezier-editor
local Bezier = require ('bezier')

-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function love.load()
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
--		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	width, height = love.graphics.getDimensions( )
	
	Bezier.load ()
	Bezier.newLayer (20)
end


 
function love.update(dt)
	
end


function love.draw()
	Bezier.draw()
end




function love.mousepressed (x, y, button, istouch, presses )
	if Bezier.activeLayer then
--		print (type(Bezier.activeLayer))
		Bezier.mousepressed (Bezier.activeLayer, x, y, button, istouch, presses)
	end
end

function love.mousemoved (x, y, dx, dy, istouch)
	if Bezier.activeLayer then
		Bezier.mousemoved (Bezier.activeLayer, x, y, dx, dy, istouch)
	end
end

function love.mousereleased(x, y, button, istouch, presses)
	if Bezier.activeLayer then
		Bezier.mousereleased(Bezier.activeLayer, x, y, button, istouch, presses)
	end
end

function love.keypressed (key, scancode, isrepeat)
	if Bezier.activeLayer then
		Bezier.keypressed (Bezier.activeLayer, key, scancode, isrepeat)
	end
	
	if key == "escape" then
		love.event.quit()
	end
end