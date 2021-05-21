-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function love.load()
	width, height = love.graphics.getDimensions( )
	rez = 16
	cols=width/rez - 1
	rows=height/rez - 1
	
	x=math.floor(cols/2)
	y=math.floor(rows/2)
	direction = nil
end

 
function love.update(dt)
	
	if direction then
		if direction == "w" then
			y = y - 1/rez
		elseif direction == "a" then
			x = x - 1/rez
		elseif direction == "s" then
			y = y + 1/rez
		elseif direction == "d" then
			x = x + 1/rez
		end
		if x%1 == 0 and y%1 == 0 then
			direction = nil
		end
	end
end


function love.draw()
	for i = 1, cols do
		for j = 1, rows do
			local c = (i+j)%2
			love.graphics.setColor (0.25+c/16, 0.25+c/16, 0.25+c/16)
			love.graphics.rectangle("fill", rez*(i-0.5), rez*(j-0.5),rez, rez)
		end
	end
	love.graphics.setColor (1, 1, 1)
	love.graphics.circle("fill",rez*x,rez*y, rez/2-1)
end

function love.keypressed(key, scancode, isrepeat)
	if not direction then
		if key == "w" then
			direction = "w"
		elseif key == "a" then
			direction = "a"
		elseif key == "s" then
			direction = "s"
		elseif key == "d" then
			direction = "d"
		end
	end
	
	if key == "escape" then
		love.event.quit()
	end
end