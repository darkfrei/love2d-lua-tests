--main.lua

local filenames = {
	'map-55.osm', -- https://osm.org/go/evapcHOU -- 54.92349, -2.96367
	'map-0.osm', -- https://osm.org/go/lX8ggeT68 -- -0.697995, 10.243917
	'map-40.osm', -- https://osm.org/go/xehPtqIcg -- 39.875064, 20.027293
	'map-48.osm', -- https://osm.org/go/0JAeZ7oTQ -- 48.10720, 11.54670
}

-- osm
local osm = {}

local function mercatorY(lat)
	local radLat = math.rad(lat)

	return math.deg(math.log (math.tan(radLat) + 1/math.cos(radLat)))
end

function osm.parseOSM(xml)
	local nodes = {}
	local nodesHash = {}

	local nodeIndex = 0
	local ways = {}
	for wayStr in xml:gmatch('<way.->.-</way>') do
		local nodeIndices = {}
		for id in wayStr:gmatch('<nd ref="(.-)"') do -- id or nd
			if nodesHash[id] then
				table.insert (nodeIndices, nodesHash[id])
			else
				nodeIndex = nodeIndex + 1
				nodesHash[id] = nodeIndex
				table.insert (nodeIndices, nodeIndex)
			end
		end
--		print ('#nodeIndices', #nodeIndices)
		local way = {nodeIndices = nodeIndices, line = {}}
		table.insert (ways, way)
	end

	for nodeStr in xml:gmatch('<node.-/>') do
		local id = nodeStr:match('id="(.-)"')
		local x = tonumber(nodeStr:match('lon="(.-)"')) -- X
--		local y = tonumber(nodeStr:match('lat="(.-)"')) -- Y
		local y = mercatorY(tonumber(nodeStr:match('lat="(.-)"')))

		if nodesHash[id] then
			nodes[nodesHash[id]] = {x=x, y=-y}
		else

		end
	end

	local minLat, minLon, maxLat, maxLon = xml:match('<bounds minlat="(.-)" minlon="(.-)" maxlat="(.-)" maxlon="(.-)"/>')

	local minX = tonumber(minLon) -- x
	local maxX = tonumber(maxLon) -- x
--	local minY = tonumber(minLat) -- y
--	local maxY = tonumber(maxLat) -- y
	local minY = mercatorY(tonumber(minLat))
	local maxY = mercatorY(tonumber(maxLat))

	local dx = maxX-minX
	local dy = maxY-minY

	local bounds = {
		minX=minX, 
		maxX=maxX, 
		dx=dx,
		midX=minX + dx/2, 
		minY=minY, 
		maxY=maxY, 
		dy=dy,
		midY=minY + dy/2, 
	}

	return {nodes = nodes, ways = ways, bounds = bounds}
end

function osm.updateScale(mapData)
	local bounds = mapData.bounds
	local screenWidth, screenHeight = love.graphics.getDimensions ()
	mapData.scale = math.min(screenWidth / bounds.dx, screenHeight / bounds.dy)
	print ('mapData.scale', mapData.scale)

	local ways = mapData.ways
	local nodes = mapData.nodes
	for i, way in ipairs (ways) do
		way.line = {}
		for j, nodeIndex in ipairs (way.nodeIndices) do
			local node = nodes[nodeIndex]
			local x = node.x * mapData.scale
			local y = node.y * mapData.scale
--			print ('x: '..x, 'y: '..y)
			table.insert (way.line, x)
			table.insert (way.line, y)
		end
	end
end

local mapDataSet = {}

function love.load()
	for i, filename in ipairs (filenames) do
		local file = love.filesystem.read(filename)
		if file then
			local mapData = osm.parseOSM(file)
			osm.updateScale(mapData)
			mapDataSet[i] = mapData
		end
	end
	mapData = mapDataSet[1]
	mapData = mapDataSet[2]
	mapData = mapDataSet[3]
	mapData = mapDataSet[4]
end

function love.draw()
	local tx = mapData.bounds.midX*mapData.scale - 400
	local ty = mapData.bounds.midY*mapData.scale + 300
	love.graphics.translate (-tx, ty)
	for _, way in pairs(mapData.ways) do
		love.graphics.line(way.line)
	end
end