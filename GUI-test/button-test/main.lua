function love.load()
	button = {}
	button.area = {x=50, y=100, width=200, height=50}
	button.font = love.graphics.newFont(14)
	button.text = 'Button text'
	local w, h = button.font:getWidth(button.text), button.font:getHeight()
	local x = (2*button.area.x+button.area.width-w)/2
	local y = (2*button.area.y+button.area.height-h)/2
	button.text_shift = {x=x,y=y} -- text in the middle of button
	button.hover = false
end

function love.mousemoved(x, y)
--	local mx, my = love.mouse.getPosition()
	if is_point_in_area (x, y, button.area) then
		button.hover = true
	else
		button.hover = false
	end
end

function is_point_in_area (x, y, area)
	if x>area.x and x<(area.x+area.width) and
		y>area.y and y<(area.y+area.height) then
		return true
	else
		return false
	end
end

function love.mousepressed(x, y)
	if is_point_in_area (x, y, button.area) then
		local dx, dy = math.random(20)-10,math.random(20)-10
		button.area.x=button.area.x+dx
		button.area.y=button.area.y+dy
		button.text_shift.x=button.text_shift.x+dx
		button.text_shift.y=button.text_shift.y+dy
	end
end

function love.draw()
	if button.hover then 
		love.graphics.setColor(0.5,0.5,0.5)
	else
		love.graphics.setColor(1,1,1)
	end
	love.graphics.rectangle(button.hover and 'fill' or 'line', button.area.x, button.area.y, button.area.width, button.area.height)
	love.graphics.setFont(button.font)
	love.graphics.setColor(1,1,1)
	love.graphics.print( button.text, button.text_shift.x, button.text_shift.y)
end