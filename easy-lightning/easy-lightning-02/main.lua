-- License CC0 (Creative Commons license) (c) darkfrei, 2022



function love.load()
	source = {x=100, y=300}
	target = {x=700, y=300}
	line = {source.x, source.y, target.x, target.y}
	
	for i = 1, 7 do
		local x = source.x+i/8*(target.x-source.x)
		local y = source.y+i/8*(target.y-source.y)
		table.insert (line, i*2+1, y)
		table.insert (line, i*2+1, x)
	end
end

function love.update(dt)
	for i = 3, 15, 2 do
		local x = line[i-2]/2 + line[i+2]/2 + (math.random ()-0.5)*5 
		local y = line[i-1]/2 + line[i+3]/2 + (math.random ()-0.5)*5 + math.random ()*(line[i-1] - line[i+3])
		line[i] = x
		line[i+1] = y
	end
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