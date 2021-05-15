-- Translate the coordinate system with the mouse:

tx=0
ty=0
function love.draw()
	mx = love.mouse.getX()
	my = love.mouse.getY()
	if love.mouse.isDown(1) then
		if not mouse_pressed then
			mouse_pressed = true
			dx = tx-mx
			dy = ty-my
		else
			tx = mx+dx
			ty = my+dy
		end
	elseif mouse_pressed then
		mouse_pressed = false
	end
	love.graphics.translate(tx, ty)
	
	-- test circle:
	love.graphics.circle( "line", 0, 0, 400 )
	love.graphics.line(-440, 0, 440, 0)
	love.graphics.line(0, -440, 0, 440)
end

function love.mousepressed(x, y, button, istouch)
   if button == 2 then -- Versions prior to 0.10.0 use the MouseConstant 'l'
      tx = 0
      ty = 0
   end
end