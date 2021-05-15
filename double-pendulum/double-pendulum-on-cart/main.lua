-- License CC0 (Creative Commons license) -- 2021 (c) darkfrei

sin = math.sin
cos = math.cos

function new_game ()
	local width, height = love.graphics.getDimensions( )
	local x0, y0 = width/2, height/2 -- center of screen
	game = {}
	game.g = 9.8 * 100 -- one meter is 100 pixels
	game.handler = {}
	
	-- indexes: 1 - cart; 2, 3 - pendulums
	local h = game.handler
	h.x1, h.y1 = x0, y0 -- cart position
	h.dx1 = 0 -- cart speed
	h.m1 = 100 -- cart mass
	
	h.l2, h.q2, h.dq2 = 250, math.pi, 0 -- length, angle and velocity of pendulum 1
	h.x2, h.y2 = 0, 0
	h.m2 = 10 -- pendulum 1 mass
	
	h.l3, h.q3, h.dq3 = 250, 3, 0 -- length, angle and velocity of pendulum 2
	h.x3, h.y3 = 0, 0
	h.m3 = 10 -- pendulum 2 mass
end

function love.load()
	love.window.setTitle('Double Pendulum Jump Game')

	
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddwidth > 1920 and ddheight > 1080 then
--		love.window.setMode(1920, 1080, {resizable=false, borderless=true})
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		
	end
	
	
	
	
	new_game ()
	
end


function update_pendulum (h, dt)
	-- https://www.youtube.com/watch?v=o-YyIzooo_U
	-- https://www.reddit.com/r/Zymplectic/comments/n2a552/double_pendulum_cart_attached_to_spring/
	
	local x1, q2, q3 = h.x1, h.q2, h.q3
	local dx1, dq2, dq3 = h.dx1,  h.dq2,  h.dq3
	local m1, m2, m3 = h.m1,  h.m2,  h.m3
	local l2, l3 = h.l2,  h.l3
	local g = - game.g
	
	-- cart
	local ddx1 = (m2*(dq3^2*l3*m3*sin(2*q2 - q3) 
			- g*(m2 + m3)*sin(2*q2) 
			+ 2*dq2^2*l2*m2*sin(q2) 
			+ 2*dq2^2*l2*m3*sin(q2) 
			+ dq3^2*l3*m3*sin(q3)))
	/(2*m1*m2 + m1*m3 + m2*m3 - m2^2*cos(2*q2) + m2^2 - m2*m3*cos(2*q2) - m1*m3*cos(2*q2 - 2*q3))
	
	-- pendulum 1
	local ddq2 = -(dq2^2*l2*m2^2*sin(2*q2) - 
		2*m1*g*m2*sin(q2) 
		- 2*g*m2*m3*sin(q2) 
		- m1*g*m3*sin(q2) 
		- m1*g*m3*sin(q2 - 2*q3) 
		- 2*g*m2^2*sin(q2) 
		+ dq3^2*l3*m2*m3*sin(q2 + q3) 
		+ 2*m1*dq3^2*l3*m3*sin(q2 - q3) 
		+ dq3^2*l3*m2*m3*sin(q2 - q3) 
		+ dq2^2*l2*m2*m3*sin(2*q2) 
		+ m1*dq2^2*l2*m3*sin(2*q2 - 2*q3))
	/(l2*(2*m1*m2 + m1*m3 + m2*m3 - m2^2*cos(2*q2) + m2^2 - m2*m3*cos(2*q2) - m1*m3*cos(2*q2 - 2*q3)))
	
	-- pendulum 2
	local ddq3 = (m1*(g*(m2 + m3)*(sin(q3) 
				- sin(2*q2 - q3)) 
			+ 2*dq2^2*l2*m2*sin(q2 - q3) 
			+ 2*dq2^2*l2*m3*sin(q2 - q3) 
			+ dq3^2*l3*m3*sin(2*q2 - 2*q3)))
	/(l3*(2*m1*m2 + m1*m3 + m2*m3 - m2^2*cos(2*q2) + m2^2 - m2*m3*cos(2*q2) - m1*m3*cos(2*q2 - 2*q3)))

--	print ('ddx1: ' .. ddx1 .. ' ddq2: ' .. ddq2 .. ' ddq3: ' .. ddq3)

	-- angle speeds
	h.dx1=h.dx1+dt*ddx1
	h.dq2=h.dq2+dt*ddq2
	h.dq3=h.dq3+dt*ddq3
	
	
	-- angles
	h.x1=h.x1+dt*dx1
	h.q2=h.q2+dt*dq2
	h.q3=h.q3+dt*dq3
	
--	p.y1 = 0

	h.x2 = h.x1 + h.l2*sin(h.q2)
	h.y2 = h.y1 + h.l2*cos(h.q2)
	
	h.x3 = h.x2 + h.l3*sin(h.q3)
	h.y3 = h.y2 + h.l3*cos(h.q3)
	
	-- kinetic energy
	h.k = (m3*((dx1 + dq2*l2*cos(q2) 
				+ dq3*l3*cos(q3))^2 
			+ (dq2*l2*sin(q2) 
				+ dq3*l3*sin(q3))^2))
	/2 + (m2*(dq2^2*l2^2 + 2*cos(q2)*dq2*dx1*l2 + dx1^2))/2 + (m1*dx1^2)/2
	
	-- potential energy
	h.p = g*(m3*(l2*cos(q2) + l3*cos(q3)) + m2*l2*cos(q2))
	
	h.xgravity = (h.x1*h.m1 + h.x2*h.m2 + h.x3*h.m3)/(h.m1+h.m2+h.m3)
end


function love.update(dt)
	if pause then return end
	if dt > 0.1 then dt = 0.1 end
	
	local dt2 = dt
	dt = 0.001 -- 1 or 0.66 ms 
	while dt2 > 0 do
		dt2 = dt2-dt
		dt = math.min(dt, dt2)
		update_pendulum (game.handler, dt)
	end
end


function love.draw()
	love.graphics.setColor(1,1,1)
	
	
	love.graphics.print('FPS: '.. tostring(love.timer.getFPS( )), 30, 30+20)

	local h = game.handler
	
	love.graphics.setColor(0.5,0.5,0.5)
	love.graphics.setLineWidth( 1 )
	love.graphics.line(h.xgravity, 0, h.xgravity, 1080)

	-- cart
	local width, height  = 64, 32
	
	love.graphics.setColor(1,1,1)
	love.graphics.line(0, h.y1, 1920, h.y1)
	
	
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle('fill', h.x1-width/2, h.y1-height/2, width, height)
	
	love.graphics.setColor(1,1,1)
	love.graphics.setLineWidth( 3 )
	love.graphics.rectangle('line', h.x1-width/2, h.y1-height/2, width, height)
	
	love.graphics.print('cart:				'.. h.x1 .. ' ' .. h.y1, 30, 30+2*20)
	love.graphics.print('pendulum 1:	'.. h.x2 .. ' ' .. h.y2, 30, 30+3*20)
	love.graphics.print('pendulum 2:	'.. h.x3 .. ' ' .. h.y3, 30, 30+4*20)
	love.graphics.print('cinetic energy:	'.. h.k, 30, 30+5*20)
	love.graphics.print('potencial energy:	'.. h.p, 30, 30+6*20)
	love.graphics.print('energy:	'.. h.k+h.p,	 30, 30+7*20)
	
	love.graphics.circle('fill', h.x2, h.y2, 10)
	love.graphics.circle('fill', h.x3, h.y3, 10)
	
	love.graphics.line(h.x1, h.y1, h.x2, h.y2)
	love.graphics.line(h.x2, h.y2, h.x3, h.y3)
end

function love.keypressed(key, scancode, isrepeat)
	if key == "p" then
		pause = not pause
	elseif key == "space" then
		pause = not pause
	elseif key == "escape" then
		love.event.quit()
	end
end