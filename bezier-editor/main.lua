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
	activeBezier = nil -- active bezier
	hoveredControlPoint = nil -- hoveredControlPoint control point
	pressedControlPoint = nil -- pressedControlPoint control point that was hoveredControlPoint before
	

	
	love.graphics.setLineStyle("rough")

	snapEnabled = true
	snapRadius = 20
	
end


 
function love.update(dt)
	
end


function love.draw()
	love.graphics.setColor(1,1,1,0.5)
	for i, bezier in ipairs (beziers) do
		love.graphics.setLineWidth (1)
		for j, point in ipairs (bezier.points) do
			if hoveredControlPoint and 
				hoveredControlPoint.point == point then
				love.graphics.setColor(1,1,1)
			else
				love.graphics.setColor(1,1,1,0.5)
			end
			love.graphics.circle ('line', point.x, point.y, snapRadius)
		end
		if #bezier.line > 2 then
			love.graphics.line(bezier.line)
			if activeBezier and activeBezier == bezier then
				love.graphics.setColor(1,1,1)
				
			end
			love.graphics.setLineWidth (2)
			love.graphics.line(bezier.curve)
		end
	end
	love.graphics.setColor(1,1,1)
	love.graphics.print ('hoveredControlPoint: ' .. tostring(hoveredControlPoint and hoveredControlPoint.i), 30, 10)
	love.graphics.print ('beziers: ' .. tostring(#beziers), 30, 30)
	love.graphics.print ('activeBezier: ' .. tostring(activeBezier and activeBezier.index), 30, 50)

	local message = ""
	if activeBezier then
		if hoveredControlPoint then
			message = "Right mouse button to delete this point" ..
			"\n" .. "Hold left mouse botton to move this point"
		else
			message = "Left mouse button to create next point" ..
			"\n" .. "Right mouse button to end the curve"
		end
	elseif hoveredControlPoint then -- no active bezier
			message = "Click this point to select the bezier curve"
	elseif #beziers == 0 then
		message = "Click to create the point"
	else
		message = "Click to create the next curve"
	end
	
	love.graphics.print (message, 30, 70)
end

function newBezier (x, y)
	local point = {x=x, y=y}
	local points = {point}
	
	local bezier = {line={}, points = points, curve = {}}
	table.insert(beziers, bezier)
	bezier.index = #beziers -- must be updated by setting activeBezier
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

function love.mousepressed (x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
		if hoveredControlPoint and hoveredControlPoint.point then
			if activeBezier then
				pressedControlPoint = hoveredControlPoint
			elseif hoveredControlPoint and hoveredControlPoint.bezier_index then
				activeBezier = beziers[hoveredControlPoint.bezier_index]
				activeBezier.index = hoveredControlPoint.bezier_index -- updating the index
			end
		else -- new point or new bezier
			
			if snapEnabled then
				x, y = getSnapPosition (x, y)
			end
			if activeBezier then
				addPoint (activeBezier, x, y)
				createLine (activeBezier)
			else -- no activeBezier
				activeBezier = newBezier (x, y)
			end
		end
		
	elseif button == 2 then -- right mouse button
		if activeBezier and not hoveredControlPoint then
			-- not activeBezier
			activeBezier = nil
		elseif activeBezier and hoveredControlPoint then
			-- remove point
			local i = hoveredControlPoint.i
			table.remove (activeBezier.points, i)
			if #activeBezier.points > 0 then
--				hoveredControlPoint = nil
				createLine (activeBezier)
			else
				for i, bezier in ipairs (beziers) do
					if bezier == activeBezier then
						table.remove (beziers, i)
						activeBezier = nil
					end
				end
			end
		end
	end
end

function gethoveredControlPoint (bezier, x, y)
	local hoveredControlPoint = nil
	local hPoint -- the hoveredControlPoint point or nil
	local gap = snapRadius
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
		hoveredControlPoint = {i=iPoint, point = hPoint}
		return hoveredControlPoint
	end
end



function getSnapPosition (x, y)
	local bezier2 = activeBezier
	local nearestX, nearestY = nil
	local gap = snapRadius
	for i, bezier in ipairs (beziers) do
--		print ('1', i)
		if not (bezier == bezier2) then
			local bezierPoints = bezier.points
--			print ('1', i)
			local points = {bezierPoints[1], bezierPoints[#bezierPoints]}
			for j, point in ipairs (points) do
--				print ('1', i, j)
				if gap > math.abs (point.x-x) and gap > math.abs (point.y-y) then
					local dist = ((point.x-x)^2+(point.y-y)^2)^0.5
--					print ('1', i, j, point.x-x, point.y-y, dist)
					if dist < gap then
						gap = dist
						nearestX, nearestY = point.x, point.y
--						print ('gap', gap)
					end
				end
			end
		end
	end
	
	-- new or old position and bool if it was changed
	return nearestX or x, nearestY or y, nearestX~= nil
end

function love.mousemoved ( x, y, dx, dy, istouch )
	if activeBezier and pressedControlPoint and pressedControlPoint.point then
		
		if snapEnabled then
			x, y = getSnapPosition (x, y)
		end
		
		pressedControlPoint.point.x = x
		pressedControlPoint.point.y = y
		createLine (activeBezier)
	elseif activeBezier then
		hoveredControlPoint = gethoveredControlPoint (activeBezier, x, y)
	else
		local gap = snapRadius
		hoveredControlPoint = nil
		for i, bezier in ipairs (beziers) do
			local h = gethoveredControlPoint (bezier, x, y)
			if h then
				hoveredControlPoint = h
				hoveredControlPoint.bezier = bezier
				hoveredControlPoint.bezier_index = i
				return
			end
		end
	end
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
		if pressedControlPoint then
			pressedControlPoint = nil
		end
	elseif button == 2 then -- right mouse button
	end
end

function love.keypressed (key, scancode, isrepeat)
	if false then
	elseif key == "s" then
		snapEnabled = not snapEnabled
	elseif key == "escape" then
		love.event.quit()
	end
end