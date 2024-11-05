
local function length(x1, y1, x2, y2)
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

local f0 = {x=400, y=300, r=290}

local function newEllipse (x, y)
	local r = f0.r
	local ellipse = {f0 = f0, f= {x=x, y=y}}

	ellipse.c = length(f0.x, f0.y, x, y)/2
	print ('c', ellipse.c)
	local p = (f0.r - 2*ellipse.c)/2
	print ('p', p)
	ellipse.a = ellipse.c + p
	print ('a', ellipse.a)
	ellipse.b = math.sqrt(ellipse.a^2 - ellipse.c^2)
	
	ellipse.alpha = math.atan2 (y-f0.y, x-f0.x)
	print ('alpha', ellipse.alpha)

	local vertices = {}
	local numPoints = 32
	for i = 1, numPoints do
		local t = (i / numPoints) * (2 * math.pi)
		local x = (f0.x + x) / 2 + ellipse.a * math.cos(t) * math.cos(ellipse.alpha) - ellipse.b * math.sin(t) * math.sin(ellipse.alpha)
		local y = (f0.y + y) / 2 + ellipse.a * math.cos(t) * math.sin(ellipse.alpha) + ellipse.b * math.sin(t) * math.cos(ellipse.alpha)
--		print (x, y)
		table.insert (vertices, x)
		table.insert (vertices, y)
	end
	ellipse.vertices = vertices

	return ellipse
end

local e1 = newEllipse (500, 300)
local e2 = newEllipse (400, 500)


local function drawEllipse (ellipse)
	love.graphics.polygon ('line', ellipse.vertices)
end

function love.draw ()
	-- common focus
	love.graphics.circle ('fill', f0.x, f0.y, 3.5)
	love.graphics.circle ('line', f0.x, f0.y, f0.r)

	-- focus 1
	love.graphics.circle ('fill', e1.f.x, e1.f.y, 3.5)

	-- focus 2
	love.graphics.circle ('fill', e2.f.x, e2.f.y, 3.5)

	drawEllipse (e1)
	drawEllipse (e2)
end