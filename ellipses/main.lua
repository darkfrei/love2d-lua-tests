require ('love-ellipse')

function love.load()

end


function love.update(dt)

end


function love.draw()
--	love.graphics.drawRotatedEllipseWithFoci('line', 400, 300, 300, 100, 0)
--	love.graphics.scaledCircle('line', 400, 300, 300, 10, 0)

	local radius = 290

	love.graphics.drawEllipseFromFociAndRadius('line', 400,300, 500,300, radius)
	love.graphics.drawEllipseFromFociAndRadius('line', 400,300, 400,500, radius)
	
end



function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousemoved(mx, my)
	love.window.setTitle (mx..' '..my)
end
