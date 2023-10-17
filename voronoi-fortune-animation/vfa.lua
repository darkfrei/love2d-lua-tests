local vfa = {}

local function sortXYBackward (list)
	table.sort(list, function(a, b) return a.y > b.y or a.y == b.y and a.x > b.x or false end)
end

local function sortX (list)
	table.sort(list, function(a, b) return a.x < b.x end)
end

local function reload ()
	vfa.dirY = 0
	vfa.parabolaLines = {}
	vfa.sweepLine = {}
	vfa.queue = {}
	for i = 1, #vfa.points-1, 2 do
		local x, y = vfa.points[i], vfa.points[i+1]
		table.insert (vfa.queue, {x=x, y=y, point=true})
	end
	sortXYBackward (vfa.queue)
	for i = #vfa.queue, 1, -1 do
		local event = vfa.queue[i]
		print (i, event.x, event.y)
	end
end

local function getCircumcircle (x1, y1, x2, y2, x3, y3)
	local d = 2*(x1*(y2-y3)+x2*(y3-y1)+x3*(y1-y2))
	print (d)
	local t1, t2, t3 = x1*x1+y1*y1, x2*x2+y2*y2, x3*x3+y3*y3
	local x = (t1*(y2-y3)+t2*(y3-y1)+t3*(y1-y2)) / d
	local y = (t1*(x3-x2)+t2*(x1-x3)+t3*(x2-x1)) / d
	local radius = math.sqrt((x1-x)^2+(y1-y)^2)
	return x, y, radius
end

function vfa.load ()
	vfa.points = {}
	vfa.points = {100,100, 320, 120, 400, 200}
	for i = 1, 10 do
		local x = math.random (Width-40-200)+20
		local y = math.random (Height*0.5-40)+20
		table.insert (vfa.points, x)
		table.insert (vfa.points, y)
--		table.insert (vfa.points, x+200)
--		table.insert (vfa.points, y)
	end
	reload ()
end

local function pointEvent (point)
	table.insert (vfa.sweepLine, point)
	sortX (vfa.sweepLine)
	local index
	for i, event in ipairs (vfa.sweepLine) do
		if event == point then
			index = i
			break
		end
	end

	if #vfa.sweepLine > 2 then
		local circleEvent = {}
		print ('index', index)
		local p1 = vfa.sweepLine[index-2]
		local p2 = vfa.sweepLine[index-1]
		local p3 = vfa.sweepLine[index]
		local p4 = vfa.sweepLine[index+1]
		local p5 = vfa.sweepLine[index+2]
		if p1 and p2 and p3 then
			local x, y, r = getCircumcircle (p1.x, p1.y, p2.x, p2.y, p3.x, p3.y)
			local circle = {x=x, cy=y, y=y+r, r=r}
			print ('circle', 'x:'..x,'y:'..y,'r:'..r)
			table.insert (vfa.queue, circle)
		end
		if p3 and p4 and p5 then
			local x, y, r = getCircumcircle (p3.x, p3.y, p4.x, p4.y, p5.x, p5.y)
			local circle = {x=x, cy=y, y=y+r, r=r}
			print ('circle', 'x:'..x,'y:'..y,'r:'..r)
			table.insert (vfa.queue, circle)
		end
	end
end

local function circleEvent (point)
	
end

function vfa.update (dt)
	vfa.dirY = vfa.dirY+1*60*dt
	if vfa.dirY > Height then
		reload ()
	end

	for i = #vfa.queue, 1, -1 do
		local event = vfa.queue[i]
		if vfa.dirY > event.y then
			table.remove (vfa.queue, i)
			if event.point then
				pointEvent (event)
			else
				circleEvent (event)
			end
			sortXYBackward (vfa.queue)
		else
			break
		end
	end
end

function vfa.draw ()


	love.graphics.points (vfa.points)
	love.graphics.line (0, vfa.dirY, Width, vfa.dirY)

	for i, line in ipairs (vfa.parabolaLines) do
		love.graphics.line (line)
	end

	for i, event in ipairs (vfa.sweepLine) do
		love.graphics.circle ('line', event.x, event.y, 5)
	end
	
	for i, event in ipairs (vfa.queue) do
		if event.point then
			love.graphics.circle ('line', event.x, event.y, 3)
		else
			love.graphics.circle ('line', event.x, event.cy, event.r)
		end
	end
end

return vfa