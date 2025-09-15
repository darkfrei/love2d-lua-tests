-- main.lua
-- all comments in code are in english and lowercase

local windowWidth = 1920
local windowHeight = 1080

local noiseCanvas
local noiseImage

-- noise parameters
local noiseScale = 0.008
local dz = 0.01
local saveCounter = 0

-- marching squares parameters
local cellW, cellH = 4, 4
local threshold = 0.5
local segments = {}

love.graphics.setLineStyle('rough')
love.graphics.setLineWidth(2)

-- get perlin-like noise value at x, y
local function getValueAt(x, y)
	local sampleX = x * noiseScale
	local sampleY = y * noiseScale
	local z = saveCounter * dz
	return love.math.noise(sampleX, sampleY, z)
end

-- linear interpolation for marching squares
local function interpolate(a, b, va, vb, threshold)
	if va == vb then return (a + b) / 2 end
	return a + (threshold - va) * (b - a) / (vb - va)
end

-- marching squares lookup
local function getCaseSegments(caseIndex, topMidX, topMidY, rightMidX, rightMidY, bottomMidX, bottomMidY, leftMidX, leftMidY)
	local cases = {
		[1]  = {{leftMidX,leftMidY, topMidX,topMidY}},
		[2]  = {{topMidX,topMidY, rightMidX,rightMidY}},
		[3]  = {{leftMidX,leftMidY, rightMidX,rightMidY}},
		[4]  = {{rightMidX,rightMidY, bottomMidX,bottomMidY}},
		[5]  = {{leftMidX,leftMidY, bottomMidX,bottomMidY}, {topMidX,topMidY, rightMidX,rightMidY}},
		[6]  = {{topMidX,topMidY, bottomMidX,bottomMidY}},
		[7]  = {{leftMidX,leftMidY, bottomMidX,bottomMidY}},
		[8]  = {{bottomMidX,bottomMidY, leftMidX,leftMidY}},
		[9]  = {{topMidX,topMidY, bottomMidX,bottomMidY}},
		[10] = {{topMidX,topMidY, rightMidX,rightMidY}, {bottomMidX,bottomMidY, leftMidX,leftMidY}},
		[11] = {{rightMidX,rightMidY, bottomMidX,bottomMidY}},
		[12] = {{leftMidX,leftMidY, rightMidX,rightMidY}},
		[13] = {{topMidX,topMidY, rightMidX,rightMidY}},
		[14] = {{leftMidX,leftMidY, topMidX,topMidY}},
	}
	return cases[caseIndex]
end

-- build segments for marching squares
local function buildSegments()
	segments = {}
	local cols = math.floor(windowWidth / cellW)
	local rows = math.floor(windowHeight / cellH)

	for i = 0, cols - 1 do
		for j = 0, rows - 1 do
			local x, y = i * cellW, j * cellH

			-- noise values at corners
			local v1 = getValueAt(x, y)
			local v2 = getValueAt(x+cellW, y)
			local v3 = getValueAt(x+cellW, y+cellH)
			local v4 = getValueAt(x, y+cellH)

			-- case index
			local c1 = v1 > threshold and 1 or 0
			local c2 = v2 > threshold and 1 or 0
			local c3 = v3 > threshold and 1 or 0
			local c4 = v4 > threshold and 1 or 0
			local caseIndex = c1*1 + c2*2 + c3*4 + c4*8

			-- skip empty or full cells
			if caseIndex ~= 0 and caseIndex ~= 15 then
				local topMidX = interpolate(x, x+cellW, v1, v2, threshold)
				local topMidY = y
				local rightMidX = x+cellW
				local rightMidY = interpolate(y, y+cellH, v2, v3, threshold)
				local bottomMidX = interpolate(x, x+cellW, v4, v3, threshold)
				local bottomMidY = y+cellH
				local leftMidX = x
				local leftMidY = interpolate(y, y+cellH, v1, v4, threshold)

				local segs = getCaseSegments(caseIndex, topMidX, topMidY, rightMidX, rightMidY, bottomMidX, bottomMidY, leftMidX, leftMidY)
				if segs then
					for _, s in ipairs(segs) do
						table.insert(segments, s)
					end
				end
			end
		end
	end
end

-- generate noise image
local function generateNoise()
	local noiseImageData = love.image.newImageData(windowWidth, windowHeight)
	for y = 0, windowHeight - 1 do
		for x = 0, windowWidth - 1 do
			local v = getValueAt(x, y)
			if v > 0.48 and v < 0.52 then 
				v = 1 
				noiseImageData:setPixel(x, y, v, v, v, 1)
			else v = 0
			end

		end
	end
	noiseImage = love.graphics.newImage(noiseImageData)
end

-- redraw canvas with noise and segments
local function redrawCanvas()
	noiseCanvas:renderTo(function()
			love.graphics.clear()
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.draw(noiseImage, 0, 0)
			love.graphics.setColor(1, 0, 1, 1)
			for _, seg in ipairs(segments) do
				love.graphics.line(seg)
			end
		end)
end

function love.load()
	love.window.setMode(windowWidth, windowHeight, {resizable=false, vsync=true})
	love.window.setTitle("noise canvas - 1920x1080")
	noiseCanvas = love.graphics.newCanvas(windowWidth, windowHeight)
	generateNoise()
	buildSegments()
	redrawCanvas()
end

function love.update(dt)
	generateNoise()
	buildSegments()
	redrawCanvas()
	saveCounter = saveCounter + 1
--	love.window.setTitle('saveCounter: '..saveCounter)
end

function love.draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(noiseCanvas, 0, 0)
end
