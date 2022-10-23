-- License CC0 (Creative Commons license) (c) darkfrei, 2022

love.window.setMode(1280, 800)
Width, Height = love.graphics.getDimensions( )

local mp = require ('my-polygon')

function love.load()
	local vertices =  {100,100, 200,100, 200,200, 300,200, 300,300, 100,300}
	local lineColor = {1,1,1}
	local fillColor = {0.5,0.2,0}
	
	Polygon = mp.newPolygon (vertices, fillColor, lineColor, 8)
end

 
function love.update(dt)
	
end


function love.draw()
--	mp.drawPolygon (Polygon)
	mp.drawPolygons ()
	love.graphics.setColor (1,1,1)
	mp.drawTemp ()
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	mp.verticesCreating ("mousepressed", x, y)
end

function love.mousemoved( x, y, dx, dy, istouch )
	mp.verticesCreating ("mousemoved", x, y, 30)
end

function love.mousereleased( x, y, button, istouch, presses )
	local vertices = mp.verticesCreating ("mousereleased", x, y)
	if vertices then
		local lineColor = {1,1,1}
		local fillColor = {math.random (), math.random (), math.random ()}
		mp.newPolygon (vertices, fillColor, lineColor, 8)
	end
end