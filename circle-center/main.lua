function findCircleCenter(x1, y1, x2, y2, baseY)
	local yIntercept = 0.5*(y2^2 - y1^2 + x2^2 - x1^2)
	love.window.setTitle (yIntercept)
	local centerX = (yIntercept - baseY*(y2 - y1)) / (x2 - x1)
	local centerY = baseY
	local radius = math.sqrt((x1 - centerX)^2 + (y1 - centerY)^2)
	local eventY = centerY + radius
	return centerX, centerY, radius, eventY
end

function love.load()
	baseY = 0
	p1 = {x=200, y=200}
	p2 = {x=400, y=250}
	p3 = {}
	p3.x, p3.y, radius, eventY = findCircleCenter(p1.x, p1.y, p2.x, p2.y, baseY)
end

function love.draw()
	love.graphics.line (0, baseY, love.graphics.getWidth (), baseY)
	love.graphics.circle ('line', p1.x, p1.y, 3)
	love.graphics.circle ('line', p2.x, p2.y, 3)
	love.graphics.circle ('line', p3.x, p3.y, 3)
	love.graphics.circle ('line', p3.x, p3.y, radius)
	love.graphics.circle ('line', p3.x, eventY, 3)
end

function love.mousemoved (x, y)
	baseY = y
	p3.x, p3.y, radius, eventY = findCircleCenter(p1.x, p1.y, p2.x, p2.y, baseY)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end
