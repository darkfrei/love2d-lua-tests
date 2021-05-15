function love.load()
	width = love.graphics.getWidth()
	height = love.graphics.getHeight()
	canvas = love.graphics.newCanvas(width, height)
		love.graphics.clear()
		love.graphics.setBlendMode("alpha")
	love.graphics.setCanvas()
	max_radius = math.min(width, height)/2
end
 
 
function love.update(dt)
	love.graphics.setCanvas(canvas)
	love.graphics.setColor(1, 1, 1, 0.8)
--	love.graphics.setColor(0.5, 0.5, 0.5, 1)

	for i = 1, 1000 do
		local phi = math.rad(360*math.random())
--		local radius = max_radius*math.random()^(0.5)
--		local radius = max_radius*math.cos(math.pi*math.random())^(0.5)
--		local radius = max_radius*math.cos(math.pi*(2*math.random()-1))
--		local radius = max_radius*math.cos(math.pi*(2*math.random()-1))^0.5
--		local radius = max_radius*math.cos(math.pi*(math.random()-1))^0.5
--		local radius = max_radius*math.sin(math.pi*(math.random()))^0.5
		local radius = max_radius*(-1+math.cos(math.pi*0.5*(math.random())))
		local x = radius*math.cos(phi)+width/2
		local y = radius*math.sin(phi)+height/2
		love.graphics.points(x, y)
	end
	
	love.graphics.setCanvas()
end
 
 
function love.draw()
	love.graphics.draw(canvas, 0, 0)
end
