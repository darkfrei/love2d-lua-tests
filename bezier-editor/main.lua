-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function love.load()
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
--		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	width, height = love.graphics.getDimensions( )

	beziers = {}
	active = nil
	hovered = nil
	pressed = nil
	

	
	love.graphics.setLineStyle("rough")

	
end


 
function love.update(dt)
	
end


function love.draw()
	love.graphics.setColor(1,1,1,0.5)
	for i, bezier in ipairs (beziers) do
		for j, point in ipairs (bezier.points) do
			if hovered and hovered.point and hovered.point.x == point.x then
				love.graphics.setColor(1,1,1)
				love.graphics.print ('hovered: ' .. hovered.i)
			else
				love.graphics.setColor(1,1,1,0.5)
			end
			love.graphics.circle ('line', point.x, point.y, 20)
		end
		if #bezier.line > 2 then
			love.graphics.line(bezier.line)
			if active and active == bezier then
				love.graphics.setColor(1,1,1)
			end
			love.graphics.line(bezier.curve)
		end
	end
	love.graphics.print ('beziers: ' .. tostring(#beziers), 30, 30)
	love.graphics.print ('active: ' .. tostring(active), 30, 50)
	
end

function newBezier (x, y)
	local point = {x=x, y=y}
	local points = {point}
	
	local bezier = {line={}, points = points, curve = {}}
	table.insert(beziers, bezier)
	return bezier
end

function addPoint (bezier, x, y)
	table.insert(bezier.points, {x=x,y=y})
end

function createLine (bezier)
	local line = {}
	for j, point in ipairs (bezier.points) do
		table.insert (line, point.x)
		table.insert (line, point.y)
	end
	bezier.line = line
	if #line > 2 then
		bezier.curve = love.math.newBezierCurve(line):render(4)
	end
	
end

function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
		if hovered and hovered.point then
			if active then
				pressed = hovered
			elseif hovered and hovered.bezier_index then
				active = beziers[hovered.bezier_index]
			end
		else
			if active then
				addPoint (active, x, y)
				createLine (active)
			else -- no active
				active = newBezier (x, y)
			end
		end
		
	elseif button == 2 then -- right mouse button
		if active and not hovered then
			active = nil
		end
	end
end

function getHovered (bezier, x, y)
	local hovered = nil
	local hPoint
	local gap = 20
	local iPoint
	for i, point in ipairs (bezier.points) do
		if math.abs(point.x-x) < gap and math.abs(point.y-y) < gap then
			local distance = ((point.x-x)^2+(point.y-y)^2)^0.5
--			print (distance)
			if distance < gap then
				iPoint = i
				hPoint = point
				gap = distance
			end
		end
	end
	if hPoint then
		hovered = {i=iPoint, point = hPoint}
		return hovered
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
	if active and pressed and pressed.point then
		pressed.point.x = x
		pressed.point.y = y
		createLine (active)
	elseif active then
		hovered = getHovered (active, x, y)
	else
		local gap = 20
		hovered = nil
		for i, bezier in ipairs (beziers) do
			local h = getHovered (bezier, x, y)
			if h then
				hovered = h
				hovered.bezier = bezier
				hovered.bezier_index = i
				return
			end
		end
	end
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
		if pressed then
			pressed = nil
		end
	elseif button == 2 then -- right mouse button
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end