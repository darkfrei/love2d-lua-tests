-- License CC0 (Creative Commons license) (c) darkfrei, 2022

function createRotatedCanvas (canvas)
	local newCanvas = love.graphics.newCanvas (canvas:getHeight(), canvas:getWidth())
	love.graphics.setCanvas(newCanvas)
		love.graphics.setColor(1,1,1)
		love.graphics.draw (canvas, canvas:getHeight(), 0, math.pi/2)
	love.graphics.setCanvas()
	return newCanvas
end

function love.load()
	canvas = love.graphics.newCanvas (100, 50)
	love.graphics.setCanvas (canvas)
		love.graphics.setColor (0.5,0.5,0.5)
		love.graphics.rectangle ('fill', 0, 0, 100, 50)
		love.graphics.setColor (1,1,1)
		love.graphics.circle ('line', 0,0,25)
	love.graphics.setCanvas ()
	
	canvas2 = createRotatedCanvas (canvas)
end

 
function love.update(dt)
	
end


function love.draw()
	love.graphics.setColor (1,1,1)
	love.graphics.draw(canvas2)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end
