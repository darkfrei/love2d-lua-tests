-- Bezier
-- License CC0 (Creative Commons license) (c) darkfrei, 2021

local Bezier = {}


-- local layer = Bezier.newLayer (20)

function Bezier.newLayer (radius)
	-- creating new empty holder
	local layer = 
		{
			 -- array of beziers
			beziers = {},
			 -- active bezier
			activeBezier = nil,
			 -- hoveredControlPoint control point
			hoveredControlPoint = nil,
			 -- pressedControlPoint control point that was hoveredControlPoint before
			pressedControlPoint = nil,
			
			snapEnabled = true,
			
			snapRadius = radius or 2,
			
			drawLayer = true,
		}
	table.insert (Bezier.layers, layer)
	
	Bezier.activeLayer = layer
	return layer
end


function Bezier.load ()
	Bezier.layers = {}
	Bezier.activeLayer = nil
end


function Bezier.newBezier (layer, x, y)
	local point = {x=x, y=y}
	local points = {point}
	local beziers = layer.beziers
	
	local bezier = {line={}, points = points, curve = {}}
	table.insert(beziers, bezier)
	bezier.index = #beziers -- must be updated by setting activeBezier
	return bezier
end

function Bezier.addBezier (layer, lovePoints)
	local points = {}
	for i = 1, #lovePoints-1, 2 do
		local x = lovePoints[i]
		local y = lovePoints[i+1]
		local point = {x=x, y=y}
		table.insert (points, {x=x,y=y})
	end
	local bezier = {line={}, points = points, curve = {}}
	Bezier.createLine (bezier)
	
	local beziers = layer.beziers
	table.insert(beziers, bezier)
	bezier.index = #beziers -- must be updated by setting activeBezier
	return bezier
end


function Bezier.drawBezierCurve (bezier)
	if #bezier.line > 2 then
		love.graphics.line(bezier.line)
		love.graphics.setLineWidth (2)
		love.graphics.line(bezier.curve)
	end
end

function Bezier.drawControlPoints (bezier, snapRadius, isActiveBezier)
	for i, point in ipairs (bezier.points) do
		love.graphics.circle ('line', point.x, point.y, snapRadius)
	end
	if #bezier.line > 2 then
		if isActiveBezier then
			love.graphics.setColor(0,1,0)
		else
			love.graphics.setColor(0,1,0, 0.5)
		end
		love.graphics.line(bezier.line)
	end
end


function Bezier.drawLayer (layer)
	if layer.drawLayer then
		local activeBezier = layer.activeBezier
		for bezier_index, bezier in ipairs (layer.beziers) do
			local isActiveBezier = activeBezier and (activeBezier == bezier)
			if isActiveBezier then
				love.graphics.setColor(1,1,1)
			else
				love.graphics.setColor(1,1,1, 0.5)
			end
			Bezier.drawBezierCurve (bezier)
			Bezier.drawControlPoints (bezier, layer.snapRadius, isActiveBezier)
		end
		love.graphics.setColor(1,1,1, 0.5)
		if layer.hoveredControlPoint and 
			layer.hoveredControlPoint.point then
				local point = layer.hoveredControlPoint.point
				love.graphics.circle ('fill', point.x, point.y, layer.snapRadius)
		end
	end
end

function Bezier.draw()
	love.graphics.print ('#layers: ' .. #Bezier.layers, 30, 20)
	for i, layer in ipairs (Bezier.layers) do
		local beziers = layer.beziers
		love.graphics.print ('#beziers: ' .. #beziers, 30, 20+i*20)
		Bezier.drawLayer (layer)
		
	end
end




function Bezier.gethoveredControlPoint (bezier, x, y, radius)
	local hoveredControlPoint = nil
	local hPoint -- the hoveredControlPoint point or nil
	local gap = radius
	local iPoint
	assert (radius, 'no radius')
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


function Bezier.getSnapPosition (layer, x, y)
	local bezier2 = layer.activeBezier
	local nearestX, nearestY = nil
	local gap = layer.snapRadius
	for i, bezier in ipairs (layer.beziers) do
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


function Bezier.addPoint (bezier, x, y)
	table.insert(bezier.points, {x=x,y=y})
end




function Bezier.createLine (bezier)
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

function Bezier.mousepressed (layer, x, y, button, istouch, presses)
	local activeBezier = layer.activeBezier
	local pressedControlPoint = layer.pressedControlPoint
	local hoveredControlPoint = layer.hoveredControlPoint
	local beziers = layer.beziers
	local snapRadius = layer.snapRadius
	
	if button == 1 then -- left mouse button
		if hoveredControlPoint and hoveredControlPoint.point then
			if activeBezier then
				layer.pressedControlPoint = hoveredControlPoint
			elseif hoveredControlPoint and hoveredControlPoint.bezier_index then
				layer.activeBezier = beziers[hoveredControlPoint.bezier_index]
				layer.activeBezier.index = hoveredControlPoint.bezier_index -- updating the index
			end
		else -- new point or new bezier
			
			if layer.snapEnabled then
				x, y = Bezier.getSnapPosition (layer, x, y)
			end
			if activeBezier then
				Bezier.addPoint (activeBezier, x, y)
				Bezier.createLine (activeBezier)
			else -- no activeBezier
				layer.activeBezier = Bezier.newBezier (layer, x, y)
			end
		end
		
	elseif button == 2 then -- right mouse button
		if activeBezier and not hoveredControlPoint then
			-- not activeBezier
			layer.activeBezier = nil
		elseif activeBezier and hoveredControlPoint then
			-- remove point
			local i = hoveredControlPoint.i
			table.remove (activeBezier.points, i)
			if #activeBezier.points > 0 then
--				hoveredControlPoint = nil
				Bezier.createLine (activeBezier)
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

function Bezier.mousemoved (layer, x, y, dx, dy, istouch)
	local activeBezier = layer.activeBezier
	local pressedControlPoint = layer.pressedControlPoint
	local hoveredControlPoint = layer.hoveredControlPoint
	local beziers = layer.beziers
	local snapRadius = layer.snapRadius
	
	if activeBezier and pressedControlPoint and pressedControlPoint.point then
		if layer.snapEnabled then
			x, y = Bezier.getSnapPosition (layer, x, y)
		end
		layer.pressedControlPoint.point.x = x
		layer.pressedControlPoint.point.y = y
		Bezier.createLine (layer.activeBezier)
	elseif activeBezier then
		
		layer.hoveredControlPoint = Bezier.gethoveredControlPoint (activeBezier, x, y, snapRadius)
	else
		local gap = snapRadius
		layer.hoveredControlPoint = nil
		for i, bezier in ipairs (beziers) do
			local h = Bezier.gethoveredControlPoint (bezier, x, y, snapRadius)
			if h then
				layer.hoveredControlPoint = h
				layer.hoveredControlPoint.bezier = bezier
				layer.hoveredControlPoint.bezier_index = i
				return
			end
		end
	end
end

function Bezier.mousereleased(layer, x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
		if layer.pressedControlPoint then
			layer.pressedControlPoint = nil
		end
	elseif button == 2 then -- right mouse button
	end
end

function Bezier.keypressed (layer, key, scancode, isrepeat)
	if key == "s" then
		layer.snapEnabled = not layer.snapEnabled
	end
end



return Bezier