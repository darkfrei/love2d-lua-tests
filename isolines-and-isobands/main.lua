-- License CC0 (Creative Commons license) (c) darkfrei, 2023

love.window.setMode(1280, 800) -- Steam Deck resolution

scale = 16
isovalue = 0.6
love.window.setTitle ('isovalue: '..isovalue)
width = 1280/scale
height = 800/scale
windowX = 0
windowY = 0

kx = 32
ky = 32

function createnoiseMap (width, height, dx, dy, kx, ky)
	dx = dx or 0
	dy = dy or 0
	kx = kx or 128
	ky = ky or 64
	
	local noiseMap = {}

	for y = 1, height do
		noiseMap[y] = {}
		for x = 1, width do
			noiseMap[y][x] = love.math.noise( (x-dx)/kx, (y-dy)/ky)
		end
	end
	return noiseMap
end


local function interpolatePoint(x1, y1, v1, x2, y2, v2, isovalue)
  local t = (isovalue - v1) / (v2 - v1)
  if t >= 0 and t <= 1 then
	local x = x1 + t * (x2 - x1)
	local y = y1 + t * (y2 - y1)
	return x, y
  else
	return nil
  end
end


local function findIsoLine(noiseMap, x1, y1, isovalue)
  local v1 = noiseMap[y1][x1]
  local x2, y2 = x1+1, y1
  local v2 = noiseMap[y2][x2]
	local x3, y3 = x1+1, y1+1
  local v3 = noiseMap[y3][x3]
	local x4, y4 = x1, y1+1
  local v4 = noiseMap[y4][x4]
  local line = {}
  if math.min(v1, v2) < isovalue and math.max(v1, v2) >= isovalue then
	local px, py = interpolatePoint(x1, y1, v1, x2, y2, v2, isovalue)
	table.insert(line, px)
	table.insert(line, py)
  end	
  if math.min(v2, v3) < isovalue and math.max(v2, v3) >= isovalue then
	local px, py = interpolatePoint(x2, y2, v2, x3, y3, v3, isovalue)
	table.insert(line, px)
	table.insert(line, py)
  end

  if math.min(v4, v3) < isovalue and math.max(v4, v3) >= isovalue then
	local px, py = interpolatePoint(x4, y4, v4, x3, y3, v3, isovalue)
	table.insert(line, px)
	table.insert(line, py)
  end
  if math.min(v1, v4) < isovalue and math.max(v1, v4) >= isovalue then
	local px, py = interpolatePoint(x1, y1, v1, x4, y4, v4, isovalue)
	table.insert(line, px)
	table.insert(line, py)
  end
	if #line == 8 then
		if math.abs(v1+v3-2*isovalue) > math.abs(v2+v4-2*isovalue) then
			return {line[1],line[2],line[3],line[4]}, {line[5],line[6],line[7],line[8]}
		else
			return {line[1],line[2],line[7],line[8]}, {line[5],line[6],line[3],line[4]}
		end
	elseif #line == 4 then
		return line
	end
end


function createIsolines (noiseMap, width, height)
	local isolines = {}
	for x = 1, width-1 do
		for y = 1, height-1 do
			local line, line2 = findIsoLine(noiseMap, x, y, isovalue)
			table.insert (isolines, line)
			table.insert (isolines, line2)
		end
	end
	return isolines
end

function createNoisePoints (noiseMap, width, height)
	local noisePoints = {}
	for x = 1, width do
		for y = 1, height do
			local t = noiseMap[y][x]
			local r, g, b = 0, 0, 0
			if t > isovalue then
--				r, g, b = 1, 1, 1
				local c = 1-t+isovalue
				r, g, b = c,c,c
			end
			table.insert(noisePoints, {x, y, r, g, b ,1})
		end
	end
	return noisePoints
end



function createIsopolygon (noiseMap, x, y, isovalue1, isovalue2)
	local corners = {{x,y},{x+1,y},{x+1,y+1},{x,y+1}}
	
	local values = {}
	for i = 1, 4 do
		if noiseMap[corners[i][2] ] and noiseMap[corners[i][2] ][corners[i][1] ] then
			local vx, vy = corners[i][1], corners[i][2]
			values[i] = noiseMap[vy][vx]
		else
			return
		end
	end	
	
	local points = {}
	local edges = {}
	
	if    values[1] > math.min (isovalue1, isovalue2)
		and values[1] < math.max (isovalue1, isovalue2) then 
		-- adding top left vertice
		local px, py = corners[1][1], corners[1][2]
		table.insert(points, px)
		table.insert(points, py)
	end
	
	
	if values[1] < values[2] then
		if math.min(values[1], values[2]) < isovalue1 and math.max(values[1], values[2]) > isovalue1 then
			local px, py = interpolatePoint(corners[1][1], corners[1][2], values[1], corners[2][1], corners[2][2], values[2], isovalue1)
			table.insert(points, px)
			table.insert(points, py)
		end
		if math.min(values[1], values[2]) < isovalue2 and math.max(values[1], values[2]) > isovalue2 then
			local px, py = interpolatePoint(corners[1][1], corners[1][2], values[1], corners[2][1], corners[2][2], values[2], isovalue2)
			table.insert(points, px)
			table.insert(points, py)
		end
	else -- other direction
		if math.min(values[1], values[2]) < isovalue2 and math.max(values[1], values[2]) > isovalue2 then
			local px, py = interpolatePoint(corners[1][1], corners[1][2], values[1], corners[2][1], corners[2][2], values[2], isovalue2)
			table.insert(points, px)
			table.insert(points, py)
		end
		if math.min(values[1], values[2]) < isovalue1 and math.max(values[1], values[2]) > isovalue1 then
			local px, py = interpolatePoint(corners[1][1], corners[1][2], values[1], corners[2][1], corners[2][2], values[2], isovalue1)
			table.insert(points, px)
			table.insert(points, py)
		end
	end
	
	if    values[2] > math.min (isovalue1, isovalue2)
		and values[2] < math.max (isovalue1, isovalue2) then 
		-- adding top right vertice
		local px, py = corners[2][1], corners[2][2]
		table.insert(points, px)
		table.insert(points, py)
	end
	

	if values[2] < values[3] then
		if math.min(values[2], values[3]) < isovalue1 and math.max(values[2], values[3]) > isovalue1 then
			local px, py = interpolatePoint(corners[2][1], corners[2][2], values[2], corners[3][1], corners[3][2], values[3], isovalue1)
			table.insert(points, px)
			table.insert(points, py)
		end
		if math.min(values[2], values[3]) < isovalue2 and math.max(values[2], values[3]) > isovalue2 then
			local px, py = interpolatePoint(corners[2][1], corners[2][2], values[2], corners[3][1], corners[3][2], values[3], isovalue2)
			table.insert(points, px)
			table.insert(points, py)
		end
	else -- other direction
		if math.min(values[2], values[3]) < isovalue2 and math.max(values[2], values[3]) > isovalue2 then
			local px, py = interpolatePoint(corners[2][1], corners[2][2], values[2], corners[3][1], corners[3][2], values[3], isovalue2)
			table.insert(points, px)
			table.insert(points, py)
		end
		if math.min(values[2], values[3]) < isovalue1 and math.max(values[2], values[3]) > isovalue1 then
			local px, py = interpolatePoint(corners[2][1], corners[2][2], values[2], corners[3][1], corners[3][2], values[3], isovalue1)
			table.insert(points, px)
			table.insert(points, py)
		end
	end
	
	if    values[3] > math.min (isovalue1, isovalue2)
		and values[3] < math.max (isovalue1, isovalue2) then 
		-- adding bottom right vertice
		local px, py = corners[3][1], corners[3][2]
		table.insert(points, px)
		table.insert(points, py)
	end
	
	if values[3] < values[4] then
		if math.min(values[4], values[3]) < isovalue1 and math.max(values[4], values[3]) > isovalue1 then
			local px, py = interpolatePoint(corners[4][1], corners[4][2], values[4], corners[3][1], corners[3][2], values[3], isovalue1)
			table.insert(points, px)
			table.insert(points, py)
		end
		if math.min(values[4], values[3]) < isovalue2 and math.max(values[4], values[3]) > isovalue2 then
			local px, py = interpolatePoint(corners[4][1], corners[4][2], values[4], corners[3][1], corners[3][2], values[3], isovalue2)
			table.insert(points, px)
			table.insert(points, py)
		end
	else -- other direction
		if math.min(values[4], values[3]) < isovalue2 and math.max(values[4], values[3]) > isovalue2 then
			local px, py = interpolatePoint(corners[4][1], corners[4][2], values[4], corners[3][1], corners[3][2], values[3], isovalue2)
			table.insert(points, px)
			table.insert(points, py)
		end
		if math.min(values[4], values[3]) < isovalue1 and math.max(values[4], values[3]) > isovalue1 then
			local px, py = interpolatePoint(corners[4][1], corners[4][2], values[4], corners[3][1], corners[3][2], values[3], isovalue1)
			table.insert(points, px)
			table.insert(points, py)
		end
	end

	if    values[4] > math.min (isovalue1, isovalue2)
		and values[4] < math.max (isovalue1, isovalue2) then 
		-- adding bottom left vertice
		local px, py = corners[4][1], corners[4][2]
		table.insert(points, px)
		table.insert(points, py)
	end
	
	
	if values[1] > values[4] then
		if math.min(values[1], values[4]) < isovalue1 and math.max(values[1], values[4]) >= isovalue1 then
			local px, py = interpolatePoint(corners[1][1], corners[1][2], values[1], corners[4][1], corners[4][2], values[4], isovalue1)
			table.insert(points, px)
			table.insert(points, py)
		end
		if math.min(values[1], values[4]) < isovalue2 and math.max(values[1], values[4]) >= isovalue2 then
			local px, py = interpolatePoint(corners[1][1], corners[1][2], values[1], corners[4][1], corners[4][2], values[4], isovalue2)
			table.insert(points, px)
			table.insert(points, py)
		end
	else -- other direction
		if math.min(values[1], values[4]) < isovalue2 and math.max(values[1], values[4]) >= isovalue2 then
			local px, py = interpolatePoint(corners[1][1], corners[1][2], values[1], corners[4][1], corners[4][2], values[4], isovalue2)
			table.insert(points, px)
			table.insert(points, py)
		end
	if math.min(values[1], values[4]) < isovalue1 and math.max(values[1], values[4]) >= isovalue1 then
			local px, py = interpolatePoint(corners[1][1], corners[1][2], values[1], corners[4][1], corners[4][2], values[4], isovalue1)
			table.insert(points, px)
			table.insert(points, py)
		end
	end
	

	if #points < 6 then
		return nil
	else
		return points
	end
end




function createPolygons (noiseMap, width, height)
	local polygons = {}
	for x = 1, width do
		for y = 1, height do
			local polygon = createIsopolygon (noiseMap, x, y, isovalue, isovalue+0.05)
			table.insert(polygons, polygon)
		end
	end
	return polygons
end

function update ()
	noiseMap = createnoiseMap (width, height, windowX, windowY, kx, ky)
	isolines = createIsolines (noiseMap, width, height)
	noisePoints = createNoisePoints (noiseMap, width, height)
	polygons = createPolygons (noiseMap, width, height)
end

function love.load()
	update ()
end


function love.draw()
	love.graphics.translate (-scale/2,-scale/2)
	love.graphics.scale (scale)
	love.graphics.setLineWidth (1/(2*scale))
	love.graphics.points (noisePoints)
	for i, line in ipairs (isolines) do
		love.graphics.line (line)
	end
	
	if polygons then
		for i, polygon in ipairs (polygons) do
			love.graphics.polygon ('fill', polygon)
		end
	end
	
	if polygon then
		love.graphics.polygon ('fill', polygon)
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "up" then
		ky = ky*2
		update ()
	elseif key == "down" then
		ky = ky/2
		update ()
	elseif key == "right" then
		kx = kx*2
		update ()
	elseif key == "left" then
		kx = kx/2
		update ()
	elseif key == "escape" then
		love.event.quit()
	end
	love.window.setTitle ('kx:'..kx..' ky:'..ky)
end

function love.mousemoved( x, y, dx, dy, istouch )
	if love.mouse.isDown (1) then
		windowX = windowX+dx/scale
		windowY = windowY+dy/scale
		update ()
	end
	
	local nx = math.floor(x/scale+0.5)
	local ny = math.floor(y/scale+0.5)
	polygon = createIsopolygon (noiseMap, nx, ny, isovalue, isovalue+0.05)
--	love.window.setTitle ('nx: '..nx..' ny:'..ny)
end

function love.wheelmoved(x, y)
	if y > 0 then
		isovalue = isovalue + 0.05
		love.window.setTitle ('isovalue: '..isovalue)
		update ()
	elseif y < 0 then
		isovalue = isovalue - 0.05
		love.window.setTitle ('isovalue: '..isovalue)
		update ()
	end
end
