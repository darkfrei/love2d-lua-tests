local DrawPolyline = {}

-- line as array of pairs: {x1, y1, x2, y2}


DrawPolyline.pressed = false
	
	
function DrawPolyline.addPoint (line, x, y)
	table.insert(line, x)
	table.insert(line, y)
end

function DrawPolyline.mousepressed(line, x, y, button, istouch, presses)
	DrawPolyline.pressed = true
	DrawPolyline.addPoint (line, x, y)
end

function DrawPolyline.mousemoved(line, x, y, dx, dy, istouch)
	if DrawPolyline.pressed then
		DrawPolyline.addPoint (line, x, y)
	end
end

function DrawPolyline.mousereleased(line, x, y, button, istouch, presses)
	if #line == 0 or not (x == line[#line-1] and y == line[#line]) then
		DrawPolyline.addPoint (line, x, y)
	end
	DrawPolyline.pressed = false
end

function DrawPolyline.draw(line)
	if #line > 2 then
		love.graphics.line (line)
		for i = 1, #line-1, 2 do
			local x, y = line[i], line[i+1]
			love.graphics.circle ('line', x, y, 3)
		end
	end
end


return DrawPolyline