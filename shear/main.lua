function love.draw()
	love.graphics.translate(100, 100)
	local t = love.timer.getTime()
--	love.graphics.shear(math.cos(t), math.cos(t * 1.3))
	local s = math.cos(t * 1.3)
--	love.graphics.shear(1, math.cos(t * 1.3))
--	love.graphics.shear(0, .1)
	k = 5
	love.graphics.shear(k*math.sin(t), -k*math.sin(t))
	love.graphics.rectangle('fill', 0, 0, 100, 50)
	love.graphics.circle('line', 0, 0, 100)
	love.graphics.print(s, 10, 60)
end