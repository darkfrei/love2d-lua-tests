-- License CC0 (Creative Commons license) (c) darkfrei, 2022

lightning1 = {
	source={x=200, y=300},
	target={x=600, y=300},
	mainLine={},
}

lightning2 = {
	source={x=250, y=450},
	target={x=550, y=450},
	mainLine={},
}

function reset (lightning)
	lightning.mainLine={lightning.source.x, lightning.source.y, lightning.target.x, lightning.target.y}
end

function addPoint (lightning, bool)
	local line = lightning.mainLine
	local index = math.random(#line/2 -1)*2-1
	local x1, y1=line[index], line[index+1]
	local x2, y2=line[index+2], line[index+3]
	local t = 0.25 + 0.5*math.random()
	local x = x1+ t*(x2 - x1)
	local y = y1+ t*(y2 - y1)
	x = x + 0.25*(y2 - y1)* (math.random()-0.5)
	if bool then
		y = y + 0.125*(x2 - x1)* (math.random()-1)
	else
		y = y + 0.25*(x2 - x1)* (math.random()-0.5)
	end
	table.insert (lightning.mainLine, index+2, y)
	table.insert (lightning.mainLine, index+2, x)
end
 
function love.update(dt)
	-- reset the line
	reset (lightning1)
	reset (lightning2)
	for i = 1, 10 do
		addPoint (lightning1)
		addPoint (lightning2, true) -- higher then straight line
	end
end

function love.draw()
	love.graphics.setLineWidth (2)
	love.graphics.setColor (1,1,1)
	love.graphics.line (lightning1.mainLine)
	
	love.graphics.setLineWidth (1)
	love.graphics.setColor (0,1,1)
	love.graphics.line (lightning2.mainLine)
end

function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
		lightning1.source ={x=x, y=y}
	elseif button == 2 then -- right mouse button
		lightning1.target ={x=x, y=y}
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end