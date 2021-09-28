-- License CC0 (Creative Commons license) (c) darkfrei, 2021

main = {}

mr = require ('multiresolution')

function main.load ()
	local desktopWidth, desktopHeight = love.window.getDesktopDimensions()
--	love.window.setMode (desktopWidth/2, desktopHeight/2, {resizable=true, borderless=false})
	love.window.setMode (3/4*desktopWidth, 3/4*desktopHeight, {resizable=true, borderless=false})
	mr:load ()
end

function main.update (dt)
	mr.update(dt)
end

function main.draw ()
	mr.draw()

	local mx, my = mr.getPosition()
	love.graphics.circle('line', mx, my, 40)
	
	-- debug
	if true then
		love.graphics.setColor(1,1,1)
		love.graphics.circle('line',0,0,120)
		love.graphics.setFont(mr.fonts[20])
		
		love.graphics.print('translate: '.. mr.translateX ..'x'.. mr.translateY..' scale:'.. mr.scale , 0, 0) 
		love.graphics.print('width: '..mr.width .. ' height: ' .. mr.height, 0, 40) 
		local canvasW, canvasH = mr.grid_background:getWidth(), mr.grid_background:getHeight()
		love.graphics.print(''..canvasW ..' '.. canvasH, 0, 80) 
	end
end


function main.resize (w, h)
	mr.resize () -- update new translation and scale
end


function main.quit()
	love.event.quit()
end


function main.keypressed(key, scancode, isrepeat)
	mr.keypressed (key, scancode, isrepeat)
	
	if key == 'escape' then
		main.quit()
	end
end

function main.mousepressed (x, y, button, istouch)
	x, y = mr.getPosition()
	
end

function main.mousemoved (x, y, dx, dy, istouch)
	x, y = mr.getPosition()
	
end

function main.mousereleased (x, y, button)
	x, y = mr.getPosition()
end



---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

function love.load ()
	main.load ()
end

function love.update (dt)
	main.update (dt)
end

function love.draw ()
	main.draw ()
end

function love.resize (w, h)
	main.resize (w, h)
end

function love.keypressed(key, scancode, isrepeat)
	main.keypressed(key, scancode, isrepeat)
end

function love.mousepressed (x, y, button, istouch)
	main.mousepressed (x, y, button, istouch)
end

function love.mousemoved (x, y, dx, dy, istouch)
	main.mousemoved (x, y, dx, dy, istouch)
end

function love.mousereleased (x, y, button)
	main.mousereleased (x, y, button)
end


