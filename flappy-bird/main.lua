-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function generate_world ()
	world = {}
	world.bird = {x=width/10, y=height/2, vy = 0, jump = 500, radius = 10}
	world.pipes = {}
	world.pipes_default_countdown = 3
	world.pipes_countdown = 0
	world.gravitation = 10^3
	world.score = 0
	world.x_speed = 200
end

function love.load()
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	width, height = love.graphics.getDimensions( )

	
	generate_world ()
end

function new_pipe ()
	local y = (0.2 + 0.6*math.random ())*height
	local gap = 120
	local w = 60
	local pipe = {x = width, w = w, y1=0, h1 = y-gap/2, y2 = y + gap+2, h2 = height-(y + gap+2), collided = false}
	
	table.insert (world.pipes, pipe)
end

function update_pipes (dt)
	world.pipes_countdown = world.pipes_countdown - dt
	if world.pipes_countdown <= 0 then
		world.pipes_countdown = world.pipes_default_countdown
		new_pipe ()
	end
	
	local dx = dt*world.x_speed
	for i, pipe in pairs (world.pipes) do
		pipe.x = pipe.x - dx
		if pipe.x + pipe.w < 0 then
			world.pipes[i] = nil
		elseif pipe.x + pipe.w < world.bird.x-world.bird.radius then
			if not (pipe.collided or pipe.passed) then
				world.score = world.score + 1
				pipe.passed = true
			end
			
		end
	end
end

--https://2dengine.com/?p=intersections#Circle_vs_rectangle
-- start of Circle_vs_rectangle
	local function clamp(n, min, max)
		if n < min then
			n = min
		elseif n > max then
			n = max
		end
		return n
	end
	function circleVsRect(cx, cy, cr, l, t, w, h)
		local dx = clamp(cx, l, l + w) - cx
		local dy = clamp(cy, t, t + h) - cy
		return dx*dx + dy*dy <= cr*cr
	end
-- end of Circle_vs_rectangle

function check_collisions ()
	for i, pipe in pairs (world.pipes) do
		if not pipe.collided then
			if circleVsRect(world.bird.x, world.bird.y, world.bird.radius, pipe.x, pipe.y1, pipe.w, pipe.h1) 
			or circleVsRect(world.bird.x, world.bird.y, world.bird.radius, pipe.x, pipe.y2, pipe.w, pipe.h2) 
			then
				pipe.collided = true
				world.score = world.score - 1
			end
		end
	end
end

function update_bird (dt)
	world.bird.vy = world.bird.vy + dt*world.gravitation
	world.bird.y = world.bird.y + dt*world.bird.vy
--	if world.bird.y > height then
--		world.bird.y = height
--	end
	if world.bird.y > height then
		world.bird.y = 2*height - world.bird.y
		world.bird.vy = -0.5*world.bird.vy
	end
	check_collisions ()
	
end
 
function love.update(dt)
	update_pipes (dt)
	update_bird (dt)
end

function draw_pipes ()
	for i, pipe in pairs (world.pipes) do
		if pipe.collided then
			love.graphics.setColor(1,0,0)
		else
			love.graphics.setColor(1,1,1)
		end
		love.graphics.rectangle('fill', math.floor(pipe.x), pipe.y1, pipe.w, pipe.h1)
		love.graphics.rectangle('fill', math.floor(pipe.x), pipe.y2, pipe.w, pipe.h2)
	end
end

function draw_bird ()
	love.graphics.circle ('fill', world.bird.x, world.bird.y, world.bird.radius)
end

function love.draw()
	draw_pipes ()
	draw_bird ()
	
	love.graphics.print ('score: '..world.score, 32,32)
end

function do_jump ()
--	if world.bird.vy > 0 then
--		world.bird.vy = world.bird.vy - world.bird.jump
--	else
		world.bird.vy = - world.bird.jump
--	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "space" then
		do_jump ()
	elseif key == "escape" then
		love.event.quit()
	end
end