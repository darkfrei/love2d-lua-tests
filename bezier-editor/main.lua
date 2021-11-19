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
	local layer = Bezier.newLayer (20)
	
	local s = 300
--	local s1 = s * 0.55191502449
	local s1 = s * 4/3*(2^0.5-1)
	Bezier.addBezier (layer, {400,400-s, 400+s1,400-s, 400+s,400-s1, 400+s,400})
	Bezier.addBezier (layer, {400+s,400, 400+s,400+s1, 400+s1,400+s, 400,400+s})
	Bezier.addBezier (layer, {400,400+s, 400-s1,400+s, 400-s,400+s1, 400-s,400})
	Bezier.addBezier (layer, {400-s,400, 400-s,400-s1, 400-s1,400-s, 400,400-s})
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