-- License CC0 (Creative Commons license) (c) darkfrei, 2023

love.window.setMode(1280, 800) -- Steam Deck resolution

function clotoide(x, y, radius, step_size, num_steps)
--	local line = {x, y}
	local line = {}
	local a = math.pi/2
	local t = 0
	for i = 1, num_steps do
		x=x+radius*math.cos(a*t*t)*step_size
		y=y+radius*math.sin(a*t*t)*step_size
		table.insert (line, x)
		table.insert (line, y)
		t = t + step_size
	end
	
	print (line[1], line[2])
	print (line[math.floor(num_steps/4)*2-1], line[math.floor(num_steps/4)]*2)
	print (line[math.floor(num_steps/2)*2-1], line[math.floor(num_steps/2)]*2)
	print (line[math.floor(num_steps*3/4)*2-1], line[math.floor(num_steps*3/4)]*2)
	print (line[math.floor(num_steps)*2-1], line[math.floor(num_steps)]*2)
	return line
end

function love.load()
--	line = clotoide(10, 10, 1000, 0.001, 1000*5^0.5)
	line = clotoide(10, 10, 1000, 0.001, 1000)
end

function love.draw()
	love.graphics.line (line)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

--11	10
--259.76155157801	22.020743914856
--502.38223601206	36.253313600605
--703.70864236481	74.812228960864
--790.39313857739	149.08242415876