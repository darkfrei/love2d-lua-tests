-- events-vb



-------------------------------------
function getBeachLineForSite (x)
	for index, beachLine in ipairs (beachLines) do
		local x1, x2 = beachLine.x1, beachLine.x2
--		print ('x1, x, x2', x1, x, x2)
		if (x1 < x) and (x <= x2) then
--			print('ok')
			beachLine.index = index
			if x < x2 then
				return index, true
			else
				return index, false
			end
		end
	end
end

function copyBeachLine (beachLine)
	local newBeachline = {}
	for index, value in pairs (beachLine) do
--		print ('copied', index, value)
		newBeachline[index] = value
	end
	return newBeachline
end



function getBeachLine_Y (beachLine, x)
	if beachLine.flat then
		return beachLine.y
	end

end

function newFlatBeachline (x1, x2, y)
	local flatBeachLine = {
		x1=x1,
		x2=x2, y=y, 
		flat=true,
		type='flat',
		valid = true, -- invalid by edge and flat events
	}
	flatBeachLine.line = {x1, y, x2, y}
	return flatBeachLine
end

function newArcBeachline (cell, x, y)
	local arcBeachLine = {
		x = cell.x,
		y = cell.y,
		x1 = x,
		y1 = y,
		x2 = x,
		y2 = y,
		arc = true,
		cell = cell,
		type = 'arc',
		valid = true, -- invalid by circle event
	}
	arcBeachLine.line = {x, y, x, y}
	return arcBeachLine
end

function updateBeachLines (cellDirY)
	for index = 1, #beachLines-1 do
		local beachLine1 = beachLines[index]
		local beachLine2 = beachLines[index+1]
		if beachLine1.flat and beachLine2.arc then
			local y = beachLine1.y
			local fx, fy = beachLine2.x, beachLine2.y
			local x = getArc_x1 (fx, fy, y, cellDirY)
			beachLine1.x2 = x
			beachLine2.x1 = math.max (frame.x, x)
		elseif beachLine1.arc and beachLine2.flat then
			local y = beachLine2.y
			local fx, fy = beachLine1.x, beachLine1.y
			local x = getArc_x2 (fx, fy, y, cellDirY)
			beachLine1.x2 = math.min (frame.x+frame.w, x)
			beachLine2.x1 = x
		end
	end
end

function updateBeachLinesControlPoints ()
	for index, beachLine in ipairs (beachLines) do
		if beachLine.arc then
			local x1 = beachLine.x1
			local x2 = beachLine.x2
			local fx = beachLine.x
			local fy = beachLine.y


			local controlPoints =  getBezierControlPoints (fx, fy, x1, x2)
			beachLine.controlPoints = controlPoints

			if controlPoints and #controlPoints > 5 then
				local bezier = love.math.newBezierCurve (controlPoints)
				beachLine.bezierLine = bezier:render()
			end
		end
	end
end



runEvent = {}
--runEvent[event.type]()
runEvent.site = function (event)
	local cell = event.cell

--	updateBeachLines (dirY) -- update beachlines for changed directix


--	print ('site event', event.x, event.y)
	local x = event.x
	local index, cutBeachLine = getBeachLineForSite (x)
--	print (index, tostring (cutBeachLine))
	if cutBeachLine then
		local beachLine = beachLines[index]
		local y = getBeachLine_Y (beachLine, x)
--		print ('beachLine_Y', y, '(by x: '..x..')')
		local beachLine1 = beachLine -- keep and update
		local beachLine3 = copyBeachLine (beachLine)
		local beachLine2 = newArcBeachline (cell, x, y)
		beachLine1.x2 = beachLine2.x1
		beachLine3.x1 = beachLine2.x2
		table.insert (beachLines, index+1, beachLine2)
		table.insert (beachLines, index+2, beachLine3)

		updateBeachLines (dirY)

		updateBeachLinesControlPoints ()

--		for i, beachLine in ipairs (beachLines) do
--			print (i, beachLine.type, beachLine.x1, beachLine.x2)
--		end


	else -- insert between beachlines

	end

end


runEvent.circle = function (event)


end

runEvent.edge = function (event)


end


runEvent.flat = function (event)
	

end