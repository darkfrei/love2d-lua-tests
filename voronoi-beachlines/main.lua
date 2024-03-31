-- 2024-03-31

require ('math-vb')
require ('draw-vb')

frame = {x=50,y=50, w=700,h=500}

vertices = {
	250, 250,
	550, 250,
	400, 450 
}

-- defaul directrix Y
dirY = 260

-- preparing
---------------------------------------------------------------------


-- creating sites
sites = {}
for i = 1, #vertices-1, 2 do
	local fx = vertices[i]
	local fy = vertices[i+1]
	local index = (i-1)/2+1
	local site = {fx=fx, fy=fy, index=index} -- focus
	table.insert (sites, site)
end

-- creating cells
cells = {}
for i, site in ipairs (sites) do
	local cell = {}
	cell.site = site
	site.cell = cell
	cell.triangles = {}
end

-- creating queue
eventQueue = {}
for i, site in ipairs (sites) do
	local event = {}
	event.type = 'site' -- also 'circle' and 'edge'
	event.valid = true
	event.site = site
	event.x = site.fx
	event.y = site.fy
end
sortEventQueue ()

beachLines = {} -- array of arcs and lines
local flat = {x1=frame.x, y1=frame.y, x2=frame.x+frame.w, y2=frame.y, flat = true}
flat.line = {frame.x, frame.y, frame.x+frame.w, frame.y}
table.insert (beachLines, flat)

insertFirstArcFromEventQueue ()


---------------------------------------------------------------------







function updateBeachlines ()
	beachLines = {}
	
	for i = 1, #vertices-1, 2 do
		local fx = vertices[i]
		local fy = vertices[i+1]
--		print (i, y, dirY)
		if dirY >= fy then
			local beachLine = {}
			table.insert (beachLines, beachLine)
			local left_x, right_x = getFocusParabolaRoots (fx, fy, frame.y, dirY)

			beachLine.line = {left_x, frame.y, right_x, frame.y}
			local ax, ay = left_x, frame.y
			if ax < frame.x then
				local ax1 = frame.x
				local ay1 = evaluateParabola (fx, fy, ax1, dirY)
				beachLine.line[1] = ax1 
				beachLine.line[2] = ay1
				table.insert (beachLine.line, 3, ax1)
				table.insert (beachLine.line, 4, frame.y)
				ax = ax1
				ay = ay1
			end

			local bx, by = right_x, frame.y
			if bx > frame.x + frame.w then
				local bx1 = frame.x + frame.w
				local by1 = evaluateParabola (fx, fy, bx1, dirY)
				beachLine.line[#beachLine.line-1] = bx1 
				beachLine.line[#beachLine.line] = by1
				table.insert (beachLine.line, #beachLine.line-1, bx1)
				table.insert (beachLine.line, #beachLine.line-1, frame.y)
				bx = bx1
				by = by1
			end

--			local cx, cy = getBezierThirdControlPoint(fx, fy, ax, ay, bx, by+1)
			local cx, cy = getBezierControlPoint(fx, fy, ax, bx, dirY)
			beachLine.controlPoints = {
				ax, ay,
				cx, cy,
				bx, by,
			}
--			print ('ax, ay', ax, ay)
--			print ('cx, cy', cx, cy)
--			print ('bx, by', bx, by)
			if #beachLine.controlPoints > 5 and beachLine.controlPoints[3] ~= nil then
				local bezier = love.math.newBezierCurve (beachLine.controlPoints)
				local bezierLine = bezier:render()
				beachLine.bezierLine = bezierLine
			end
		end
	end
end

updateBeachlines ()

function love.draw ()
	drawFrame ()

	drawDirectrix ()

	drawSitesVertices ()


	drawFrameCollisionLines ()

	drawBezierControlLines ()

	drawBezierArcs ()

end



function love.mousemoved (x, y)
	dirY = y
	updateBeachlines ()
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end