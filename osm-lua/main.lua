--main.lua


-- osm
local osm = {}

function osm.parseOSM(xml)
	local nodes = {}
	local ways = {}
	local bounds = {}

	for node in xml:gmatch('<node.-/>') do
		local id = node:match('id="(.-)"')
		local lon = node:match('lon="(.-)"') -- X
		local lat = node:match('lat="(.-)"') -- Y
		
		if id and lat and lon then
			nodes[id] = {
				lon = tonumber(lon), -- x
				lat = tonumber(lat), -- y
				}
		end
	end

	for way in xml:gmatch('<way.->.-</way>') do
		local id = way:match('id="(.-)"')
		if id then
			local wayNodes = {}
			for nd in way:gmatch('<nd ref="(.-)"') do
				table.insert(wayNodes, nd)
			end
			local tags = {}
			for k, v in way:gmatch('<tag k="(.-)" v="(.-)"') do
				tags[k] = v
			end
			ways[id] = {nodes = wayNodes, tags = tags}
		end
	end

	-- bounds

--	<bounds minlat="31.6953460" minlon="119.9798230" maxlat="31.7128260" maxlon="120.0172660"/>
	local minLat, minLon, maxLat, maxLon = xml:match('<bounds minlat="(.-)" minlon="(.-)" maxlat="(.-)" maxlon="(.-)"/>')
	
	if minLat and minLon and maxLat and maxLon then
		bounds = {
			minlat = tonumber(minLat),
			minlon = tonumber(minLon),
			maxlat = tonumber(maxLat),
			maxlon = tonumber(maxLon)
		}
	end

	return {nodes = nodes, ways = ways, bounds = bounds}
end

function osm.getScale(bounds, screenWidth, screenHeight)
	local latDiff = bounds.maxlat - bounds.minlat
	local lonDiff = bounds.maxlon - bounds.minlon
	local scaleTemp = math.min(screenWidth / lonDiff, screenHeight / latDiff) * 0.9
	print ('scaleTemp', scaleTemp)
	return scaleTemp
end

-- end of osm

-- main

local mapData
local scale, offsetX, offsetY

function love.load()
	local file = love.filesystem.read('interchange.osm')
	if file then
		mapData = osm.parseOSM(file)
		if mapData.bounds then
			local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
			scale = osm.getScale(mapData.bounds, screenWidth, screenHeight)
			offsetX = -mapData.bounds.minlon * scale + 100
			offsetY = mapData.bounds.maxlat * scale + 150
		end
	else
		print('Error loading OSM file')
	end
end

function love.draw()
	if not mapData then return end

	love.graphics.setColor(1, 1, 1)
	for _, way in pairs(mapData.ways) do
		local prevNode = nil
		for _, nodeId in ipairs(way.nodes) do
			local node = mapData.nodes[nodeId]
			if node then
--				local x = (node.lon - 119.9970406) * 10000 + 400
--				local y = (31.7035039 - node.lat) * 10000 + 300
				local x = node.lon * scale + offsetX
				local y = -node.lat * scale + offsetY
				if prevNode then
					love.graphics.line(prevNode.x, prevNode.y, x, y)
				end
				prevNode = {x = x, y = y}
			end
		end
	end
end