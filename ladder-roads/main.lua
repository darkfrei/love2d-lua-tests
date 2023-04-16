-- ladder-roads
-- license cc0, darkfrei 2023


TrackLine = 
-- bezier-roads, 11 pieces
{
	{0, 400, 10, 400}, -- line
	{10, 400, 123, 400, 203, 282}, -- bezier
	{203, 282, 279, 169, 452, 172}, -- bezier
	{452, 172, 518, 173, 569, 234}, -- bezier
	{569, 234, 625, 302}, -- line
	{625, 302, 664, 348, 639, 422}, -- bezier
	{639, 422, 610, 508, 472, 495}, -- bezier
	{472, 495, 407, 489, 359, 429}, -- bezier
}

CellLength = 80
CellWidth = 30

function insertPair (list, x, y)
	table.insert (list, x)
	table.insert (list, y)
end

-- restore bezier:
Line = {} -- the line as list of position pairs
for iRoad = 1, #TrackLine do
	local road = TrackLine[iRoad]
	if #road > 4 then -- bezier
		local bezierObj = love.math.newBezierCurve (road)
		local amount = 32
		for t = 0, amount-1 do -- don't add last point
			local x, y = bezierObj:evaluate (t/amount)
			table.insert (Line, x)
			table.insert (Line, y)
		end
	else
		for i = 1, #road-3, 2 do -- don't add last point
			table.insert (Line, road[i])
			table.insert (Line, road[i+1])
		end
	end
end


local function get_points_along_line (line, gap)
-- from https://github.com/darkfrei/love2d-lua-tests/blob/main/railway-track/railways.lua#L88
	local points = {}
	local tangents = {}
	local rest = 0
--	local rest = gap/2 -- rest is gap to start point on this section
	local x1, y1, x2, y2, dx, dy = line[1],line[2]
	for i=3, #line-1, 2 do
		x2, y2 = line[i],line[i+1]
		dx, dy = x2-x1, y2-y1
		local sector_length = (dx*dx+dy*dy)^0.5
		if sector_length > rest then
			-- rest is always shorter than gap; sector is shorter than rest (or gap)
			dx, dy = dx/sector_length, dy/sector_length
			while sector_length > rest do
				local x, y = x1+rest*dx, y1+rest*dy
				table.insert (points, x)
				table.insert (points, y)
				table.insert (tangents, dx)
				table.insert (tangents, dy)
				rest = rest + gap
			end
		else -- no point in this distance
		end
		-- the tail for the next 
		rest = rest-sector_length
		x1, y1 = x2, y2
	end
	return points, tangents
end

local lineLength = 0
local x1, y1 = Line[1], Line[2]
for i = 3, #Line-1, 2 do
	local x2, y2 = Line[i], Line[i+1]
	lineLength = lineLength + math.sqrt((x2-x1)^2 + (y2-y1)^2)
	x1, y1 = x2, y2
end
CellLength = lineLength / math.floor(lineLength/CellLength +0.5)
print ('middle cells count:', math.floor(lineLength/CellLength +0.5))
print ('CellLength:', CellLength)

--add	equidistant points
EquidistantPoints, Tangents = get_points_along_line (Line, CellLength/2)

-- cells as round
Cells = {}


function cubicBezier(x1, y1, angle1, x2, y2, angle2, curve) -- not tested
--	print (x1, y1, angle1, x2, y2, angle2)
	curve = curve or {}
	local dx1, dy1 = math.cos (angle1), math.sin (angle1)
--	print (dx1, dy1)
	local dx2, dy2 = math.cos (angle2), math.sin (angle2)
--	local dx1, dy1 = math.sin (angle1), math.cos (angle1)
--	local dx2, dy2 = math.sin (angle2), math.cos (angle2)
	local dist = math.sqrt((x2-x1)^2+(y2-y1)^2)/3
	local px1, py1 = x1+dist*dx1, y1+dist*dy1
--	print (px1, py1)
	local px2, py2 = x2-dist*dx2, y2-dist*dy2
	local amount = 7
	for n = 0, amount-1	do -- not the last point
		local t = n/amount
		local a, b, c, d = (1-t)^3, 3*t*(1-t)^2, 3*t^2*(1-t), t^3
		local x = a*x1+b*px1+c*px2+d*x2
		local y = a*y1+b*py1+c*py2+d*y2
		table.insert(curve, x)
		table.insert(curve, y)
	end
	return curve
end

function createCell (typ, x, y, dx, dy, angle, CellWidth, amount)
	if typ == 'left' then
		-- left lane has transitions to cell above or to right (middle lane):
			local cell = {x=x+CellWidth*dy, y=y-CellWidth*dx, dx=dx, dy=dy, angle=angle,
			left = nil, right = amount+3, next = amount+4}
		return cell
	elseif typ == 'right' then
		local cell = {x=x-CellWidth*dy, y=y+CellWidth*dx, dx=dx, dy=dy, angle=angle,
			left = amount+2, right = nil, next = amount+4}
		return cell
	else -- middle
		local cell = {x=x, y=y, dx=dx, dy=dy, angle=angle,
			left = amount+2, right = amount+3, next = amount+4}
		return cell
	end
end

BorderA = {} -- line
BorderB = {}
BorderC = {}
BorderD = {}

Sprits = {} -- list of lines

local angleOld

-- iterate all equidistance points:
for indexEP = 1, #EquidistantPoints-1, 2 do
	-- position
	local x, y = EquidistantPoints[indexEP], EquidistantPoints[indexEP+1]
	-- tangent
	local dx, dy = Tangents[indexEP], Tangents[indexEP+1]
	local angle = math.atan2(dy, dx)
	angleOld = angleOld or angle
	if ((indexEP-1)/2)%2 == 1 then
		local leftCell = createCell ('left', x, y, dx, dy, angle, CellWidth, #Cells)
		table.insert (Cells, leftCell)
		local rightCell = createCell ('right', x, y, dx, dy, angle, CellWidth, #Cells)
		table.insert (Cells, rightCell)
	else
		local cell = createCell ('middle', x, y, dx, dy, angle, CellWidth, #Cells)
		table.insert (Cells, cell)
	end
	
	local x2, y2 = EquidistantPoints[indexEP+2], EquidistantPoints[indexEP+3]
	local dx2, dy2 = Tangents[indexEP+2], Tangents[indexEP+3]
	if not dy2 then
		-- last cell
		dx2, dy2 = dx, dy
		local pointAx, pointAy = x+1.5*CellWidth*dy, y-1.5*CellWidth*dx
		local pointBx, pointBy = x+0.5*CellWidth*dy, y-0.5*CellWidth*dx
		local pointCx, pointCy = x-0.5*CellWidth*dy, y+0.5*CellWidth*dx
		local pointDx, pointDy = x-1.5*CellWidth*dy, y+1.5*CellWidth*dx
		
		table.insert (BorderA, pointAx)
		table.insert (BorderA, pointAy)
		
		table.insert (BorderB, pointBx)
		table.insert (BorderB, pointBy)
		
		table.insert (BorderC, pointCx)
		table.insert (BorderC, pointCy)
		
		table.insert (BorderD, pointDx)
		table.insert (BorderD, pointDy)
		
		if ((indexEP-1)/2)%2 == 1 then
			-- odd
			table.insert (Sprits, {pointBx,  pointBy, pointCx,  pointCy})
		else
			-- even
			table.insert (Sprits, {pointAx, pointAy, pointBx, pointBy})
			table.insert (Sprits, {pointCx, pointCy, pointDx, pointDy})
		end
	else
		local nextAngle = math.atan2(dy2, dx2)
		local pointAx,  pointAy =  x +1.5*CellWidth*dy,  y -1.5*CellWidth*dx
		local pointA2x, pointA2y = x2+1.5*CellWidth*dy2, y2-1.5*CellWidth*dx2
		
		local pointBx,  pointBy =  x +0.5*CellWidth*dy,  y -0.5*CellWidth*dx
		local pointB2x, pointB2y = x2+0.5*CellWidth*dy2, y2-0.5*CellWidth*dx2
		
		local pointCx,  pointCy =  x -0.5*CellWidth*dy,  y +0.5*CellWidth*dx
		local pointC2x, pointC2y = x2-0.5*CellWidth*dy2, y2+0.5*CellWidth*dx2
		
		local pointDx,  pointDy =  x -1.5*CellWidth*dy,  y +1.5*CellWidth*dx
		local pointD2x, pointD2y = x2-1.5*CellWidth*dy2, y2+1.5*CellWidth*dx2
		
		cubicBezier(pointAx, pointAy, angle, pointA2x, pointA2y, nextAngle, BorderA)
		cubicBezier(pointBx, pointBy, angle, pointB2x, pointB2y, nextAngle, BorderB)
		cubicBezier(pointCx, pointCy, angle, pointC2x, pointC2y, nextAngle, BorderC)
		cubicBezier(pointDx, pointDy, angle, pointD2x, pointD2y, nextAngle, BorderD)
		
		if ((indexEP-1)/2)%2 == 1 then
			-- odd
			table.insert (Sprits, {pointBx,  pointBy, pointCx,  pointCy})
		else
			-- even
			table.insert (Sprits, {pointAx, pointAy, pointBx, pointBy})
			table.insert (Sprits, {pointCx, pointCy, pointDx, pointDy})
		end
	end

	
	angleOld = angle
end




for iCell, cell in ipairs (Cells) do
	local nextCell = Cells[cell.next]
	if nextCell then
		local x1, y1 = cell.x, cell.y
		local x2, y2 = nextCell.x, nextCell.y
		local line = {x1, y1, x2, y2}
		cell.nextLine = line
	end
	local rightCell = Cells[cell.right]
	if rightCell then
		local x1, y1 = cell.x, cell.y
		local x2, y2 = rightCell.x, rightCell.y
		local line = {x1, y1, x2, y2}
		cell.rightLine = line
	end
	local leftCell = Cells[cell.left]
	if leftCell then
		local x1, y1 = cell.x, cell.y
		local x2, y2 = leftCell.x, leftCell.y
		local line = {x1, y1, x2, y2}
		cell.leftLine = line
	end	
end

	
function drawRotatedRectangle(mode, x, y, w, h, angle)
	love.graphics.push()
		love.graphics.translate(x, y)
		love.graphics.rotate(angle)
		love.graphics.rectangle(mode, -w/2, -h/2, w, h)
	love.graphics.pop()
end

function love.draw ()
	
	love.graphics.setLineWidth (1)
	love.graphics.setColor (0.25,0.25, 0.25)
	love.graphics.line (Line)
	for i = 1, #EquidistantPoints-1, 2 do
		love.graphics.circle ('line', EquidistantPoints[i], EquidistantPoints[i+1], 3)
	end
	
	love.graphics.setLineWidth (4)
	love.graphics.setColor (1,1,1)
	love.graphics.line (BorderA)
	love.graphics.line (BorderB)
	love.graphics.line (BorderC)
	love.graphics.line (BorderD)
	
	for i, line in ipairs (Sprits) do
		love.graphics.line (line)
	end
	
	for iCell, cell in ipairs (Cells) do
		love.graphics.setLineWidth (2)
		love.graphics.setColor (0.5,0.5,0)
		love.graphics.circle ('line', cell.x, cell.y, 4)
		love.graphics.setColor (1,1,1)
--		drawRotatedRectangle( 'line', cell.x, cell.y, CellLength, CellWidth, cell.angle)
		
		love.graphics.setLineWidth (1)
		if cell.nextLine then
			love.graphics.setColor (1,1,0,0.75)
			love.graphics.line (cell.nextLine)
		end
		if cell.rightLine then
			love.graphics.setColor (0,1,0,0.75)
			love.graphics.line (cell.rightLine)
		end
		if cell.leftLine then
			love.graphics.setColor (1,0,0,0.75)
			love.graphics.line (cell.leftLine)
		end
	end
	
	
	
end
