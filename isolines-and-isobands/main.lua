-- License CC0 (Creative Commons license) (c) darkfrei, 2023

local iso = require ('isolines-and-isobands')

love.window.setMode(1280, 800) -- Steam Deck resolution







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
