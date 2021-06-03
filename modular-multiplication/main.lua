-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function create_mod ()
	love.graphics.setCanvas(canvas)
		love.graphics.clear()
	love.graphics.setCanvas()
	p1 = 0
	p2 = 0
	dp = math.pi/180
	radius = height/2
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
	
	mod = 2
	canvas = love.graphics.newCanvas( )
	create_mod ()
	
	pause = true
end

 
function love.update(dt)
	if pause then return end
	p1 = p1 + dp
	p2 = p1 * mod
	love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.setCanvas(canvas)
        love.graphics.line(
			width/2+radius*math.cos(p1), height/2+radius*math.sin(p1), 
			width/2+radius*math.cos(p2), height/2+radius*math.sin(p2)
			)
    love.graphics.setCanvas()
end


function love.draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print('mod: '..mod)
	love.graphics.draw(canvas, 0, 0)
end

function love.keypressed(key, scancode, isrepeat)
	if key == "space" then
		mod = mod + 1
		create_mod ()
	elseif key == "p" then
		pause = not pause
		
	elseif key == "escape" then
		love.event.quit()
	end
end