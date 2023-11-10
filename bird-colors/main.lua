-- License CC0 (Creative Commons license) (c) darkfrei, 2022

function birdColors (t)
	local r = 129*t^3 -  482*t^2 + 137*t + 244
	local g = 616*t^3 - 1066*t^2 + 237*t + 240
	local b = 556*t^3 -  706*t^2 -  41*t + 238
	return r/255, g/255, b/255
end

function love.load()
	love.window.setTitle ('Bird Colors')
	
	local width, height = love.graphics.getDimensions( )
	canvas = love.graphics.newCanvas()
--	love.graphics.setLineStyle( "smooth" )
	love.graphics.setLineStyle( "rough" )
	love.graphics.setCanvas(canvas)
		for i = 0, width do
			local t = i/width
			
			love.graphics.setColor (birdColors(t))
			love.graphics.line (i, 0, i, height)	
		end
	love.graphics.setCanvas()
end

function love.draw()
	love.graphics.setColor(1,1,1)
	love.graphics.draw(canvas)
end