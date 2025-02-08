-- related https://love2d.org/forums/viewtopic.php?t=96314


map = { -- [z][y][x]
	{

		{5,3,0,3,1,3,2,2},
		{4,1,1,1,1,1,1,1},
		{0,1,1,1,1,1,1,1},
		{4,1,1,1,1,1,1,2},
		{1,1,1,0,1,1,1,2}, -- extra zero to draw empty tile
		{4,1,1,1,1,1,1,2},
		{4,1,1,1,1,1,1,2},
		{4,1,1,1,1,1,1,2},
		{2,1,1,1,1,1,1,2},
		{2,1,1,2,2,2,2,2},
	},

}


local tileSize = 16
local spacing = 1
local scale = 5

local offsetX = 450/scale
local offsetY = 100/scale
local depthOffset = 0

local isoWidth = tileSize / 2
local isoHeight = tileSize / 4

local isoYoffset = -0.5


local screenXmin, screenXmax = 0, 640 -- limits for screenX
local screenYmin, screenYmax = 0, 480 -- limits for screenY

local mouse = {x=1, y=1} -- tiles


local function getQuads(tileset, spacingX, spacingY)
	local quads = {}
	local tilesetWidth = tileset:getWidth()
	local tilesetHeight = tileset:getHeight()

	print (tilesetWidth, tilesetHeight)

	for j = 0, (tilesetHeight / (tileSize + spacingY)) do
		for i = 0, (tilesetWidth / (tileSize + spacingX)) do
			local x = i * (tileSize + spacingX)
			local y = j * (tileSize + spacingY)

			local quad = love.graphics.newQuad(x, y, tileSize, tileSize, tilesetWidth, tilesetHeight)
			table.insert(quads, quad)

			print ('quad y:'..j..' x:'..i)
		end
	end
	return quads
end

-- convert screen coordinates back to tile coordinates
local function screenToTile(screenX, screenY)
	screenX = screenX / scale
	screenY = (screenY) / scale
	local tempX = (screenX - offsetX) / isoWidth
	local tempY = (screenY - offsetY-isoYoffset) / isoHeight
	local x = math.floor((tempX + tempY) / 2 + 0.5)+1
	local y = math.floor((tempY - tempX) / 2 + 0.5)+1
	return x, y
end

-- convert tile coordinates to screen coordinates
local function tileToScreen(x, y)
	local screenX = offsetX + (x - y - 1) * isoWidth
	local screenY = offsetY + (x + y - 5) * isoHeight

	return screenX, screenY
end

local topLeftX, topLeftY = screenToTile(screenXmin, screenYmin)
local bottomRightX, bottomRightY = screenToTile(screenXmax, screenYmax)
local dXmin = topLeftX-topLeftY
local dYmin = topLeftX+topLeftY
local dXmax = bottomRightX-bottomRightY
local dYmax = bottomRightX+bottomRightY




function love.load()
	-- load tileset and generate quads
	tileset = love.graphics.newImage('tiles-16x16-s1-1.png')
	tileset:setFilter('nearest', 'nearest')
	quads = getQuads(tileset, spacing, spacing)
end

function love.update(dt)
	local up = love.keyboard.isDown ('up')
	local down = love.keyboard.isDown ('down')
	local left = love.keyboard.isDown ('left')
	local right = love.keyboard.isDown ('right')
	local speed = 60
	if up and not down then
		offsetY = offsetY + speed*dt -- offset has another direction!
	elseif down and not up then
		offsetY = offsetY - speed*dt
	end
	if left and not right then
		offsetX = offsetX + speed*dt
	elseif right and not left then
		offsetX = offsetX - speed*dt
	end
end

local function drawTilePolygon(x, y)
	local screenX, screenY = tileToScreen(x, y)

	local points = {
		screenX + 2*isoWidth, screenY + 3*isoHeight + isoYoffset,
		screenX + isoWidth, screenY + 2*isoHeight + isoYoffset,
		screenX, screenY + 3*isoHeight + isoYoffset,
		screenX + isoWidth, screenY + 4*isoHeight + isoYoffset,
	}

	love.graphics.setColor(1, 0, 0, 0.5)
	love.graphics.polygon('fill', points)
	
end



function love.draw()
	love.graphics.scale (scale)
	love.graphics.setColor(1, 1, 1, 1)
	for z = 1, #map do
		for y = 1, #map[z] do
			for x = 1, #map[z][y] do
				local tile = map[z][y][x]
				if tile ~= 0 then
					local screenX, screenY = tileToScreen(x, y)
					love.graphics.draw(tileset, quads[tile], screenX, screenY)
				end
			end
		end
	end
	drawTilePolygon(mouse.x, mouse.y)
end

function love.mousemoved (screenX, screenY)
	local x, y = screenToTile(screenX, screenY)
	love.window.setTitle ('x:'..x..' y:'..y)
	mouse.x = x
	mouse.y = y
end