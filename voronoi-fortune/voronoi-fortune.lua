-- 2023-11-26
-- 2023-12-18

local vf = {
	dirY = 0,
	segments = {},
	parabolaLines = {},
	beachLine = {},
	queue = {},

	-- results:
	sites = {}, -- list of points
	delaunaySegments = {}, -- list of segments

}

function vf.sortXYBackward ()
	local list = vf.queue
	table.sort(list, function(a, b) return a.y > b.y or a.y == b.y and a.x > b.x end)
end

function vf.getRandomPoints (amount)
	local points = {}
	for i = 1, amount do
		local x = math.random (Width*0.8) + Width*0.1
		local y = math.random (Height*0.8) + Height*0.1
		table.insert (points, x)
		table.insert (points, y)
	end
	return points
end

function vf.newCell (x, y)
	local cell = {x=x, y=y}
	cell.site = {x=x, y=y}
	cell.edges = {}
	cell.vertices = {}
	return cell
end

function vf.reload ()
	vf.dirY = 0
	vf.segments = {}
	vf.parabolaLines = {}
	vf.beachLine = {}
	vf.queue = {}
	for i = 1, #vf.points-1, 2 do
		local x, y = vf.points[i], vf.points[i+1]
		table.insert (vf.queue, vf.newCell (x, y))
	end
	vf.sortXYBackward ()
end


function vf.newParabola (cell)
	return {x=cell.x, y=cell.y, cell = cell}
end


function vf.newPoint (x, y)
	return {x=x, y=y, point = true}
end

function vf.setPointX (point, x)
	point.x=x
end

local function setDoubleLinking (...)
	local nodes = {...}
	local a = nodes[1]
	for i = 2, #nodes do
		local b = nodes[i]
		a.next = b
		b.prev = a
		a = b
	end
end

function vf.newBeachLine (cell)
	local s1 = vf.newPoint (0,0) -- separator
	local p2 = vf.newParabola (cell) -- parabola
	local s3 = vf.newPoint (Width,0)
	vf.firstBeachPoint = p1
	setDoubleLinking (s1, p2, s3)
end

function vf.updateBeachLineX (event)
	local beachLine = vf.beachLine
	for i = 2, #beachLine-3, 2 do -- every parabola except last
		local p2 = beachLine[i] -- parabola
		local p3 = beachLine[i+1] -- point
		local p4 = beachLine[i+2] -- parabola
		if p2.cell.y == p4.cell.y then
			local x = (p2.cell.x + p4.cell.x)/2
			vf.setPointX (p3, x)
		else
			-- update cross point
			local x, y = vf.getParabolasCrossing (p2, p4, event.y)
			vf.setPointX (p3, x)
		end
	end
end

function vf.pointEvent (event)
	if #vf.beachLine == 0 then
		vf.beachLine = vf.newBeachLine (event)
		return
	elseif #vf.beachLine == 3 then
		vf.insertParabola (event)
		return
	end
	vf.updateBeachLineX (event)
	vf.insertParabola (event)
end



local function getCircumcircle (x1, y1, x2, y2, x3, y3)
	local d = 2*(x1*(y2-y3)+x2*(y3-y1)+x3*(y1-y2))
	local t1, t2, t3 = x1*x1+y1*y1, x2*x2+y2*y2, x3*x3+y3*y3
	local x = (t1*(y2-y3)+t2*(y3-y1)+t3*(y1-y2)) / d
	local y = (t1*(x3-x2)+t2*(x1-x3)+t3*(x2-x1)) / d
	local radius = math.sqrt((x1-x)^2+(y1-y)^2)
	return x, y, radius
end

function vf.calculate ()
	while (#vf.queue > 0) do
		vf.sortXYBackward ()
		local event = table.remove (vf.queue, #vf.queue)
		if event.circle then
			vf.circleEvent (event)
		else
			vf.pointEvent (event)
		end
	end
end


function vf.load ()
	vf.points = vf.getRandomPoints (200)
	vf.reload ()
	vf.calculate ()
end


function vf.drawSites ()
	for i, site in ipairs (vf.sites) do
		love.graphics.circle ('line', site.x, site.y, 5)
	end
end

function vf.drawSites ()
	for i, segment in ipairs (vf.delaunaySegments) do
		love.graphics.line (segment.siteA.x, segment.siteA.y, segment.siteB.x, segment.siteB.y)
	end
end

function vf.draw ()
	vf.drawSites ()
	vf.drawDelaunayTriangulation ()

end

return vf
