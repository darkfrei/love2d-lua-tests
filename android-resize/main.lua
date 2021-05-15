-- 2021-04-22 License CC0 (Creative Commons license) (c) darkfrei

function love.load()
	modes = love.window.getFullscreenModes( display )
--	love.window.setMode(360, 640, {resizable=false})
	love.window.setMode(640, 100, {resizable=false})
end

 
function love.update(dt)
	
end


function love.draw()
	for i, mode in pairs (modes) do
		local x = 0
		local y = (i-1)*20+32
		local h = love.graphics.getHeight()
		local n = math.floor((h-32)/20)
		print (n)
--		if i > n then
			x=x+210*math.floor(i/n)
			y= ((i-1)%n)*20+32
--		end
		love.graphics.print(i..' width:'..mode.width..' height:'..mode.height,x,y)
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end