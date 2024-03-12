function love.load()
	vertices = {
		{100, 50, 0,0, 1,0,0},
		{700, 400, 0,0, 0,1,0},
		{50, 550, 0,0, 0,0,1},
	}
	mesh = love.graphics.newMesh( vertices, mode, usage )
end

function love.draw()
	love.graphics.draw (mesh)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end
