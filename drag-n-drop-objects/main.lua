-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local dndo = require ('dndo')

function love.load()
	Objects = {}
	table.insert (Objects, {type='rectangle', x=50, y=50, w=250, h=150, color = {0.6,0.6,0.6}, outlineColor = {1,1,1}, hoveredOutlineColor = {1,1,0}, pressedOutlineColor = {0,1,1}})
	table.insert (Objects, {type='rectangle', x=150, y=150, w=150, h=250, color = {0.6,0.6,0.6}, outlineColor = {1,1,1}, hoveredOutlineColor = {1,1,0}, pressedOutlineColor = {0,1,1}})
	table.insert (Objects, {type='circle', x=150, y=250, r=50, color = {0.6,0.6,0.6}, outlineColor = {1,1,1}, hoveredOutlineColor = {1,1,0}, pressedOutlineColor = {0,1,1}})
	dndo.load (Objects)
end

 
function love.update(dt)
	
end


function love.draw()
	love.graphics.setLineWidth(2)
	dndo.draw()
end


function love.mousepressed( x, y, button, istouch, presses )
	dndo.mousepressed( x, y, button, istouch, presses )
end

function love.mousemoved( x, y, dx, dy, istouch )
	dndo.mousemoved( x, y, dx, dy, istouch )
end

function love.mousereleased( x, y, button, istouch, presses )
	dndo.mousereleased( x, y, button, istouch, presses )
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end
