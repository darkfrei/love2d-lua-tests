-- 2021-04-29 License CC0 (Creative Commons license) (c) darkfrei

function love.load()
	love.window.setMode(1920, 1080, {resizable=false, borderless=true})
	width, height = love.graphics.getDimensions( )
	
	scale = 8
	
	buffer = 0.5
	buffer_limit = buffer

	canvas = love.graphics.newCanvas(width/scale, height/scale)
--	circle = {x=0.5, y=0.5, d=2}
--	circle = {x=width/scale/2+(1/128)/scale, y=height/scale/2+4/scale, d=2}
	circle = {x=width/scale/2, y=height/scale/2, d=2}
	canvas:setFilter("nearest", "nearest")
end

 
function love.update(dt)
	buffer = buffer + dt
	if buffer > buffer_limit then
		circle.d = circle.d + 1
		love.graphics.setCanvas(canvas)
			love.graphics.clear()
			love.graphics.setLineStyle("rough")
			love.graphics.setDefaultFilter("nearest", "nearest")
			love.graphics.setLineWidth( 0.8 )
			love.graphics.circle('line', circle.x + (circle.d/2)%1, 0.5+circle.y + (circle.d/2)%1, circle.d/2)
		love.graphics.setCanvas()
		buffer = buffer - buffer_limit
	end
end


function love.draw()
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.graphics.draw(canvas, 0, 0,0,scale, scale)
end

function love.keypressed(key, scancode, isrepeat)
   if key == "escape" then
      love.event.quit()
   end
end