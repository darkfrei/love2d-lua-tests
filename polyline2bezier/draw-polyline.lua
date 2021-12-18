local DrawPolyline = {}

-- line as array of pairs: {x1, y1, x2, y2}


DrawPolyline.pressed = false
	
	
function DrawPolyline.addPoint (line, x, y)
--	if not (x == line[#line-1] and y == line[#line]) then
	if #line == 0 then
		table.insert(line, x)
		table.insert(line, y)
--	elseif math.abs(x-line[#line-1])>50 or math.abs(y-line[#line])>50 then
	elseif math.abs(x-line[#line-1])>2 or math.abs(y-line[#line])>2 then
		table.insert(line, x)
		table.insert(line, y)
	else -- impossible mouse movement
--		print (#line .. ' same position: ' .. x ..' '..y..' '.. line[#line-1] ..' '..line[#line])
	end
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
	DrawPolyline.addPoint (line, x, y)
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