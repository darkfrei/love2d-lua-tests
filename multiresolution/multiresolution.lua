-- makes all window operations


local multiresolution = {}
local mr = multiresolution

function mr.load()
	-- if your code was optimized for fullHD:
	mr.high_resolution = true
	mr.editor = false
	mr.editor_gap = 40
	mr.translateX = 0
	mr.translateY = 0
	mr.scale = 1
	-- mr.width, mr.height
	mr.width = 1920
	mr.height = 1080
	local width, height = love.graphics.getDimensions ()
	mr.resize (width, height) -- update new translation and scale
	
	mr.fonts = {}
--	mr.fonts[10] = love.graphics.newFont('fonts/NotoSans-Regular.ttf', 10, "normal", 2)
--	mr.fonts[20] = love.graphics.newFont('fonts/NotoSans-Regular.ttf', 20, "normal", 2)
--	mr.fonts[40] = love.graphics.newFont('fonts/NotoSans-Regular.ttf', 40, "normal", 2)
--	mr.fonts[80] = love.graphics.newFont('fonts/NotoSans-Regular.ttf', 80, "normal", 2)
	mr.fonts[10] = love.graphics.newFont(10)
	mr.fonts[20] = love.graphics.newFont(20)
	mr.fonts[40] = love.graphics.newFont(40)
	mr.fonts[80] = love.graphics.newFont(80)
	love.graphics.setFont(mr.fonts[80])
	
	mr.create_background_canvas()
	mr.create_hr_background_canvas()
end

function mr.update(dt)
	if mr.need_update then
		mr.resize()
		mr.need_update = false
	end
end

function mr.draw_canvas (is_hight_resolution)
	love.graphics.setColor(1,1,1)
	if is_hight_resolution then
		love.graphics.draw(mr.hr_grid_background, 0, 0, 0, 1/mr.scale)
	else
		love.graphics.draw(mr.grid_background)
	end
end

function mr.draw()
	-- first translate, than scale
	
--	love.graphics.origin()
	love.graphics.translate (mr.translateX, mr.translateY)
	love.graphics.scale (mr.scale)

	-- permanent background
	mr.draw_canvas (mr.high_resolution)
	

end



--love.mouse.getPosition ()
function mr.getPosition()
	local mx = math.floor ((love.mouse.getX()-mr.translateX)/mr.scale+0.5)
	local my = math.floor ((love.mouse.getY()-mr.translateY)/mr.scale+0.5)
	return mx, my
end

--love.mouse.getX ()
function mr.getX()
	local mx = math.floor ((love.mouse.getX()-mr.translateX)/mr.scale+0.5)
	return mx
end

--love.mouse.getY ()
function mr.getY()
	local my = math.floor ((love.mouse.getY()-mr.translateY)/mr.scale+0.5)
	return my
end

--love.graphics.getDimensions( )
function mr.getDimensions( )
	return mr.width, mr.height
end


function mr.resize () -- update new translation and scale:
	local w, h = love.graphics.getDimensions()
	local w1, h1 = mr.width, mr.height -- target rendering resolution
	local gap = 0
	if mr.editor then
		gap = mr.editor_gap
	end
	local scale = math.min (w/(w1+2*gap), h/(h1+2*gap))
	mr.translateX = math.floor((w-w1*scale)/2+0.5)
	mr.translateY = math.floor((h-h1*scale)/2+0.5)
	mr.scale = scale
	
--	mr.create_background_canvas()
	mr.create_hr_background_canvas()
end

function mr.set_to_update ()
--	mr.editor = not mr.editor
	mr.need_update = true
end
	
	
function mr.keypressed(key, scancode, isrepeat)
	if key == "f11" then
		mr.fullscreen = not mr.fullscreen
		love.window.setFullscreen( mr.fullscreen)
		mr.need_update = true
	elseif key == "f10" then
		mr.set_to_update ()
	elseif key == "f9" then
		mr.high_resolution = not mr.high_resolution
	end
end


function mr.draw_grid (width, height, scale)
	width, height = width*scale, height*scale
	
	love.graphics.setColor(89/255,157/255,220/255) -- 599DDC
	love.graphics.rectangle('fill', 0, 0, width, height)
	
	local color1 = {177/255,201/255,236/255} -- 93bfe8
	local color2 = {128/255,179/255,228/255} -- 76aee2
	
	local grid_size = 40*scale
	love.graphics.setLineWidth (1)
	-- color 2
	love.graphics.setColor(color2)
	for x = 0, width/grid_size do
		local x1 = math.floor(x*grid_size+0.5)
		love.graphics.line(x1, 0, x1, height)
	end
	for y = 0, height/grid_size do
		local y1 = math.floor(y*grid_size+0.5)
		love.graphics.line(0, y1, width, y1)
	end
	-- color 1
	love.graphics.setColor(color1)
	for x = 0, width/grid_size do
		if (x%3 == 0) then
			local x1 = math.floor(x*grid_size+0.5)
			love.graphics.line(x1, 0, x1, height)
		end
	end
	for y = 0, height/grid_size do
		if (y%3 == 0) then
			local y1 = math.floor(y*grid_size+0.5)
			love.graphics.line(0, y1, width, y1)
		end
	end
end

function mr.create_background_canvas()
	local width, height = mr.width, mr.height
	local scale = mr.scale
	mr.grid_background = love.graphics.newCanvas(width, height, {dpiscale = math.ceil(scale)})
	love.graphics.push( )
		love.graphics.origin()
		love.graphics.setCanvas(mr.grid_background)
			mr.draw_grid (width, height, 1)
		love.graphics.setCanvas()
	love.graphics.pop()
end

function mr.create_hr_background_canvas()
	local width, height = mr.width, mr.height
	local scale = mr.scale
	mr.hr_grid_background = love.graphics.newCanvas(scale*width, scale*height)
	love.graphics.push( )
		love.graphics.origin()
		love.graphics.setCanvas(mr.hr_grid_background)
			mr.draw_grid (width, height, scale)
		love.graphics.setCanvas()
	love.graphics.pop()
end

return multiresolution