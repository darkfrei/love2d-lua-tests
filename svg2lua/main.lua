-- License CC0 (Creative Commons license) (c) darkfrei, 2021




local svg2lua = require ('svg2lua')
local mr = require ('multiresolution')
local RailW = require ('railways')

love.window.setMode(1920, 1080, {resizable=true, borderless=false})
mr:load ()


local ds = require ('level-6')





local luapaths = {}

for i, d in ipairs (ds) do
	svg2lua(luapaths, d)
end

for i, luapath in ipairs (luapaths)  do
	print (i, 'luapath', #luapath, unpack(luapath), tostring(luapath.road))
end

local function render (b, depth)
	local x1, y1, x2, y2, x3, y3, x4, y4 = b[1], b[2], b[3], b[4], b[5], b[6], b[7], b[8]
	local nPoints = 2^depth
	local curve = {}
	for i = 0, nPoints do
		local t = i/nPoints
		local t1, t2, t3, t4 = (1-t)^3, 3*t*(1-t)^2, 3*t*t*(1-t), t*t*t
		local x = t1*x1 + t2*x2 + t3*x3 + t4*x4
		local y = t1*y1 + t2*y2 + t3*y3 + t4*y4
		table.insert(curve, x)
		table.insert(curve, y)
	end
	return curve
end

local railroads = {}

local function curveInsert (vertices, curve)
	local iStart = 1
	if (#vertices > 1) 
	and (vertices[#vertices-1] == curve[1])
	and (vertices[#vertices] == curve[2]) then
		iStart = 3
	end
	for i = iStart, #curve-1, 2 do
		table.insert (vertices, curve[i])
		table.insert (vertices, curve[i+1])
	end
end


for i, luapath in ipairs (luapaths) do
	if luapath.road then
		print (i, 'luapath.road', tostring(luapath.road))
	end
	
	if luapath.fill then
		print (i, 'luapath.fill', #luapath)
		if #luapath == 1  then
--			print ('#luapath == 1')
			luapath.polygon = luapath[1]
--		else
		else
--			print ('#luapath == ', #luapath)
			local vertices = {}
			for j, luapath2 in ipairs (luapath) do
--				print ('#luapath2', #luapath2)
				local curve = luapath2
				if luapath2.bezier then
--					local curve = love.math.newBezierCurve(luapath2)
--					luapath2.curve = curve:render()
					curve = render(luapath2, 4)
				end
				curveInsert (vertices, curve)
				print (j, '#vertices', #vertices, unpack(curve))
			end
			
			print ('#vertices	', #vertices, unpack(vertices))
			luapath.polygon = vertices
			if not love.math.isConvex (vertices) then
				luapath.triangles = love.math.triangulate(vertices)
			end
		end
		
	end

	if luapath.bezier then
		local curve = love.math.newBezierCurve(luapath)
		luapath.curve = curve:render()
--		luapath.curve = render(luapath, 5)
	end
	
	if luapath.railroad then
		if luapath.curve then
			table.insert (railroads, luapath.curve)
			print (i, 'railroad curve')
		else
			table.insert (railroads, luapath)
			print (i, 'luapath.railroad')
		end
	end
end

local crossTieCanvas = love.graphics.newCanvas(nil, nil, {dpiscale=2})
local railroadCanvas = love.graphics.newCanvas(nil, nil, {dpiscale=2})
for i, railroad in ipairs (railroads) do
	RailW.drawRails (crossTieCanvas, railroadCanvas, railroad)
end



local nodeMap = {}
for i, line in ipairs (luapaths) do
	if line.road then
		local x1, y1 = line[1], line[2]
		local x2, y2 = line[3], line[4]
		local x3, y3 = line[#line-3], line[#line-2]
		local x4, y4 = line[#line-1], line[#line]
		if not nodeMap[x1] then nodeMap[x1] = {} end
		if not nodeMap[x1][y1] then nodeMap[x1][y1] = {x=x1, y=y1, dx=0,dy=0, starts=0, ends=0} end
		nodeMap[x1][y1].dx = nodeMap[x1][y1].dx + (x2-x1)
		nodeMap[x1][y1].dy = nodeMap[x1][y1].dy + (y2-y1)
		nodeMap[x1][y1].starts = nodeMap[x1][y1].starts + 1
		
		if not nodeMap[x4] then nodeMap[x4] = {} end
		if not nodeMap[x4][y4] then nodeMap[x4][y4] = {x=x4, y=y4, dx=0,dy=0, starts=0, ends=0} end
		nodeMap[x4][y4].dx = nodeMap[x4][y4].dx + (x4-x3)
		nodeMap[x4][y4].dy = nodeMap[x4][y4].dy + (y4-y3)
		nodeMap[x4][y4].ends = nodeMap[x4][y4].ends + 1
		
	end
end

--local function normalization (dx, dy)
--	local length = (dx*dx+dy*dy)^0.5
--	if length > 0 then
--		return dx/length, dy/length
--	end
--end

local nodes = {}
for x, ys in pairs (nodeMap) do
	for y, node in pairs (ys) do
--		local nx, ny = normalization (node.dx, node.dy)
--		node.xn, node.ny = nx, ny
		node.angle = math.atan2(node.dy, node.dx)
		table.insert (nodes, node)
	end
end

local arrowImage = love.graphics.newImage('graphics/arrow.png')

local selectorPoint = nil

local carsImage = love.graphics.newImage('graphics/cars_95x48.png')
local carsQuads = {}
for x=0, 760-1, 95 do
	local quad = love.graphics.newQuad(x, 0, 95, 48, carsImage)
	table.insert (carsQuads, quad)
end

local cars = {}
 
function love.update(dt)
	
end

local function drawBackground ()
	love.graphics.setColor(bckGrColor)
	love.graphics.rectangle ('fill', 0,0, 1920, 960)
	love.graphics.setLineWidth(1)
	love.graphics.setColor(1,1,1,0.4)
	for x = 0, 1920, 40 do
		love.graphics.line (x, 0, x, 960)
	end
	for y = 0, 960, 40 do
		love.graphics.line (0, y, 1920, y)
	end
	love.graphics.setColor(1,1,1,0.6)
	for x = 0, 1920, 120 do
		love.graphics.line (x, 0, x, 960)
	end
	for y = 0, 960, 120 do
		love.graphics.line (0, y, 1920, y)
	end
end

local function drawDots (color, radius)
	love.graphics.setColor(color)
	love.graphics.setLineWidth(1)
	for i, node in ipairs (nodes) do
		love.graphics.circle('fill', node.x, node.y, radius)
	end
end


local function drawRoads (lines, layer)
	local roadColor = roadColor
	local lineColor = lineColor
	
	if layer == 2 then 
		roadColor = bridgeRoadColor 
		lineColor = bridgeLineColor
	end

	
	for i, road in ipairs (lines) do
		if road.road and (road.road==layer) then
			if layer == 2 then 
				love.graphics.setLineWidth (44)
				love.graphics.setColor (0,0,0)
			else
				love.graphics.setLineWidth (roadWidth1)
				love.graphics.setColor (roadColor)
			end
			if road.curve then
				love.graphics.line (road.curve)
			else
				love.graphics.line (road)
			end
		end
	end
	
	if layer == 1 then
		drawDots (roadColor, 40/2)
		drawDots (lineColor, 35/2)
	end
	
--	love.graphics.setLineWidth (35)
	love.graphics.setLineWidth (roadWidth2)
	love.graphics.setColor (lineColor)
	
	for i, road in ipairs (lines) do
		if road.road and (road.road==layer) then
			if road.curve then
				love.graphics.line (road.curve)
			else
				love.graphics.line (road)
			end
		end
	end
	
	if layer == 1 then
		drawDots (roadColor, 29/2)
	end

--	love.graphics.setLineWidth (29)
	love.graphics.setLineWidth (roadWidth3)
	love.graphics.setColor (roadColor)
	for i, road in ipairs (lines) do
		if road.road and (road.road==layer) then
			if road.curve then
				love.graphics.line (road.curve)
			else
				love.graphics.line (road)
			end
		end
	end
	
	love.graphics.setLineWidth (1)
	love.graphics.setColor (1,1,1,0.20)
	for i, road in ipairs (lines) do
		if road.road and (road.road==layer) then
			if road.curve then
				love.graphics.line (road.curve)
			else
				love.graphics.line (road)
			end
		end
--		love.graphics.line (road)
	end
end

local function drawBuildings (layer)
	love.graphics.setLineWidth (2)
	love.graphics.setColor (buildingColor)
	for i, building in ipairs (luapaths) do
		if building.fill and building.fill == layer then
			if building.triangles then
				love.graphics.setColor (buildingColor)
				for j, triangle in ipairs (building.triangles) do
					love.graphics.polygon('fill', triangle)
				end
--				love.graphics.setColor (1,1,1)
--				love.graphics.polygon('line', building.polygon)
			elseif building.polygon then
				love.graphics.setColor (buildingColor)
				love.graphics.polygon('fill', building.polygon)
				love.graphics.setColor (1,1,1)
				love.graphics.polygon('line', building.polygon)
				
			end
		end
	end
end

local function drawArrows ()
	love.graphics.setColor(1,1,1)
	local w, h = arrowImage:getDimensions ()
	for i, node in ipairs (nodes) do
		if (node.starts > 1) or (node.ends > 1) then
			love.graphics.draw(arrowImage, node.x, node.y, node.angle, 0.65,0.65, 0.52*w, h/2)
			
		end
--		love.graphics.print (node.starts..' '..node.ends, node.x, node.y)
	end
end

local function drawRotatedRectangle(mode, x, y, width, height, angle)
	-- We cannot rotate the rectangle directly, but we
	-- can move and rotate the coordinate system.
	love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.rotate(angle)
	love.graphics.rectangle(mode, -width/2, -height/2, width, height)
	love.graphics.pop()
end

function drawTriangle (mode, x, y, length, width , angle) -- position, length, width and angle
	love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.rotate( angle )
	love.graphics.polygon(mode, -length/2, -width /2, -length/2, width /2, length/2, 0)
	love.graphics.pop() 
end

local function drawSelectorPoint ()
	if selectorPoint then
		local x, y, angle = selectorPoint.x, selectorPoint.y, selectorPoint.angle
		local width, height = carScale*50, carScale*24
		drawRotatedRectangle('line', x, y, width, height, angle)
		drawTriangle ('line', x, y, width, height, angle)
	end
end

local function drawCars ()
	love.graphics.setColor(1,1,1)
	local w, h = carsImage:getDimensions()
	w=w/8
	for i, car in ipairs (cars) do
		love.graphics.draw(carsImage, car.quad, car.x, car.y, car.angle, carScale*0.6,carScale*0.6, w/2, h/2)
	end
end

local function drawRailroads ()
	love.graphics.setColor(1,1,1)
--	love.graphics.setLineWidth(2)
--	for i, vertices in ipairs (railroads) do
--		love.graphics.line (vertices)
--	end

	love.graphics.draw(crossTieCanvas)
	love.graphics.draw(railroadCanvas)
end

local function drawLines ()
	love.graphics.setColor(1,1,1)
	love.graphics.setLineWidth(2)
	for i, line in ipairs (luapaths) do
		if line.curve then
			love.graphics.line(line.curve)
		elseif #line > 2 and not line.fill then
			love.graphics.line(line)
		end
	end
end

function love.draw()
	mr.draw()
	drawBackground ()
	
	drawLines ()
	
	drawBuildings (1)
	drawRoads (luapaths, 1)
	drawRailroads (1)
	
	
	drawArrows (1)
	drawCars (1)
	
	drawBuildings (2)
	drawRoads (luapaths, 2)
	drawArrows (2)
	drawCars (2)
	
	drawSelectorPoint ()
	
	local mx, my = love.mouse.getPosition()
	love.graphics.print (mx..' '..my)
end

function love.resize (w, h)
	mr.resize (w, h)
end

function love.keypressed(key, scancode, isrepeat)
	mr.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
		
	elseif button == 2 then -- right mouse button
		
	end
end

local function distPointToLine(px,py,x1,y1,x2,y2) -- point, start and end of the segment
	local dx,dy = x2-x1,y2-y1
	local length = math.sqrt(dx*dx+dy*dy)
	dx,dy = dx/length,dy/length
	local p = dx*(px-x1)+dy*(py-y1)
	if p < 0 then
		dx,dy = px-x1,py-y1
		return math.sqrt(dx*dx+dy*dy), x1, y1 -- distance, nearest point
	elseif p > length then
		dx,dy = px-x2,py-y2
		return math.sqrt(dx*dx+dy*dy), x2, y2 -- distance, nearest point
	end
	return math.abs(dy*(px-x1)-dx*(py-y1)), x1+dx*p, y1+dy*p -- distance, nearest point
end

local function nearestSegmentInLine (x, y, line)
	local x1, y1, x2, y2, min_dist
	local nx, ny, px, py
	local ax,ay = line[1], line[2]
	for j = 3, #line-1, 2 do
		local bx,by = line[j], line[j+1]
		local dist, px,py = distPointToLine(x,y,ax,ay,bx,by)
		if not min_dist or dist < min_dist then
			min_dist = dist
			x1, y1, x2, y2 = ax,ay,bx,by
			nx,ny = px,py
		end
		ax, ay = bx, by
	end
	return x1, y1, x2, y2, nx, ny, min_dist -- segment, nearest point
end

function love.mousemoved( x, y, dx, dy, istouch )
	x,y = mr.getPosition()
	selectorPoint = nil
	local gap = 40
	local point
	for i, road in ipairs (luapaths) do
		if road.road then
			local line = road.curve or road
			local x1, y1, x2, y2, nx, ny, dist = nearestSegmentInLine (x, y, line)
			if dist < gap then
				gap = dist
				point = {x=nx, y=ny, angle = math.atan2(y2-y1, x2-x1)}
			end
		end
	end
	selectorPoint = point
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
		if selectorPoint then
			local carQuad = carsQuads[math.random(#carsQuads)]
			local car = selectorPoint
			car.quad = carQuad
			table.insert (cars, car)
			selectorPoint = nil
		end
	elseif button == 2 then -- right mouse button
		cars[#cars] = nil
	end
end