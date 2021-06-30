function draw_tilted_rectangle ( mode, x, y, width, height, angle )
	angle = angle or 0 -- angle in radians
	local cosa, sina = math.cos(angle), math.sin(angle)
	local dx1, dy1 = width*cosa, width*sina
	local dx2, dy2 = -height*sina, height*cosa
	local px1, py1 = x, y
	local px2, py2 = x + dx1, y + dy1
	local px3, py3 = x + dx1 + dx2, y + dy1 + dy2
	local px4, py4 = x + dx2, y + dy2
	
	love.graphics.polygon( mode, px1, py1, px2, py2, px3, py3, px4, py4)
end

function love.draw()
	t = t and t + 0.01 or 0
	draw_tilted_rectangle ( 'fill', 100, 100, 300, 50, t )
	draw_tilted_rectangle ( 'line', 300, 300, 300, 50, 0.5*t )
end