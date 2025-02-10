-- related https://love2d.org/forums/viewtopic.php?t=96314


map = { -- [z][y][x]
	{
		{1,2,1,2,1,1,2,1,2,1,2,1,1,2,1,2,2,1,2,1,2,1,1,2,1,1,2,1,1,2,1,1},
		{1,1,2,1,2,1,2,2,1,2,1,2,2,1,1,1,2,1,2,1,1,2,1,1,1,2,1,1,2,1,2,1},
		{2,1,2,1,1,1,1,2,2,1,1,2,1,2,2,1,2,1,1,1,1,1,2,2,2,1,2,1,2,1,1,2},
		{1,2,1,2,2,1,2,2,1,2,1,1,1,1,2,1,2,2,1,1,1,2,2,2,1,1,1,2,2,1,2,1},
		{2,1,2,1,2,1,2,1,1,1,1,2,1,1,2,2,1,1,2,2,1,1,2,1,2,2,1,2,1,1,1,1},
		{1,2,1,1,2,1,1,1,1,2,2,2,1,1,2,1,1,2,2,2,2,1,1,1,2,1,1,2,2,1,1,1},
		{2,1,2,1,1,2,2,1,1,1,2,2,1,1,2,1,1,1,2,2,2,1,2,1,1,2,2,1,1,1,1,1},
		{2,1,1,1,1,1,1,1,2,1,2,1,1,2,1,2,2,1,2,2,1,2,1,2,1,1,2,1,1,1,2,2},
		{1,2,1,2,2,1,2,1,2,2,2,1,1,2,2,1,1,1,1,1,1,1,1,1,2,2,1,1,2,1,1,1},
		{1,2,1,1,1,1,2,1,1,1,1,2,2,2,2,1,1,1,2,1,2,2,1,2,2,1,2,1,1,1,1,2},
		{2,1,1,1,2,2,1,1,1,2,1,1,2,1,1,2,1,1,2,2,2,1,1,2,2,2,1,1,1,2,1,2},
		{1,1,1,2,1,1,1,1,2,2,1,1,2,1,2,1,2,2,1,1,2,1,2,1,1,2,1,1,1,2,1,2},
		{1,1,2,1,2,1,2,2,2,1,1,2,1,2,1,1,1,1,1,2,2,1,1,2,1,1,2,2,1,1,1,1},
		{2,1,1,1,1,1,1,1,1,1,2,1,1,1,2,2,1,1,1,1,2,2,1,2,2,1,1,2,1,2,1,2},
		{2,1,2,1,2,2,2,1,1,1,1,2,2,1,2,1,2,2,1,1,2,1,2,1,1,1,2,1,2,1,1,1},
		{1,1,2,1,1,1,2,2,1,2,1,1,2,1,1,1,1,2,1,1,1,2,2,2,1,1,2,1,1,2,1,2},
		{2,1,2,1,1,2,1,2,2,1,2,1,2,1,1,2,2,1,2,2,1,1,1,2,2,2,1,1,1,1,1,1},
		{2,1,1,1,2,2,1,1,2,1,1,1,1,2,1,1,2,1,1,2,2,1,2,2,2,1,1,1,2,1,1,1},
		{1,2,2,1,1,2,1,1,1,2,1,1,2,1,1,1,2,2,2,1,1,2,2,2,1,2,2,1,1,2,2,1},
		{2,1,2,2,1,2,2,2,2,1,2,2,1,1,1,1,2,2,2,1,1,2,1,2,1,1,1,1,1,2,2,1},
		{1,2,1,1,1,1,2,1,2,2,2,2,1,1,1,1,1,2,2,1,1,1,2,1,1,2,2,2,1,1,2,1},
		{2,2,2,1,2,1,1,2,2,2,1,1,1,1,2,2,1,2,2,1,1,1,1,2,2,1,1,1,2,1,1,2},
		{1,1,2,1,2,2,1,1,2,1,2,2,1,1,2,1,2,1,1,1,1,2,2,1,1,1,1,2,1,2,1,2},
		{2,1,2,2,1,1,1,2,1,1,1,1,2,2,1,1,1,1,2,1,1,1,1,2,1,1,2,2,1,2,2,1},
		{1,2,2,1,2,2,2,1,2,2,2,2,1,1,2,2,1,1,1,2,1,1,2,1,1,1,2,1,2,1,1,1},
		{1,2,2,1,1,1,1,1,2,2,1,1,2,1,2,2,1,1,1,1,2,1,2,2,1,2,1,2,1,1,1,2}
	}
	,

	{
		{0,2,0,2,0,0,2,0,2,0,2,0,0,2,0,2,2,0,2,0,2,0,0,2,0,0,2,0,0,2,0,0},
	},


}



local tileSize = 16
local spacing = 1
local scale = 4

local offsetX = 0/scale
local offsetY = 0/scale
local depthOffset = tileSize / 2 - 5

local isoWidth = tileSize / 2
local isoHeight = tileSize / 4

local isoYoffset = -0.5


local screen = {x = 100,y=100,w=600,h=400}

local tileLimits = {

	left = 0,
	right = 20,

	top = 0,
	bottom = 20,
}


local mouse = {x=1,y=1} -- tiles


local function getQuads(tileset,spacingX,spacingY)
	local quads = {}
	local tilesetWidth = tileset:getWidth()
	local tilesetHeight = tileset:getHeight()

	print (tilesetWidth,tilesetHeight)

	for j = 0,(tilesetHeight / (tileSize + spacingY)) do
		for i = 0,(tilesetWidth / (tileSize + spacingX)) do
			local x = i * (tileSize + spacingX)
			local y = j * (tileSize + spacingY)

			local quad = love.graphics.newQuad(x,y,tileSize,tileSize,tilesetWidth,tilesetHeight)
			table.insert(quads,quad)

			print ('quad y:'..j..' x:'..i)
		end
	end
	return quads
end

-- convert screen coordinates back to tile coordinates
local function screenToTile(screenX,screenY)
	screenX = screenX / scale
	screenY = (screenY) / scale
	local tempX = (screenX - offsetX) / isoWidth
	local tempY = (screenY - offsetY-isoYoffset) / isoHeight
	local x = math.floor((tempX + tempY) / 2 + 0.5)+1
	local y = math.floor((tempY - tempX) / 2 + 0.5)+1
	return x,y
end

-- convert tile coordinates to screen coordinates
local function tileToScreen(x,y)
	local screenX = offsetX + (x - y - 1) * isoWidth
	local screenY = offsetY + (x + y - 5) * isoHeight

	return screenX,screenY
end

local function updateTileLimits()
	local x1,y1 = screenToTile(screen.x,screen.y)
	local x2,y2 = screenToTile(screen.x + screen.w,screen.y + screen.h)

	tileLimits.left = x1 - y1 - 1
	tileLimits.right = x2 - y2 + 1

	tileLimits.top = x1 + y1 - 1
	tileLimits.bottom = x2 + y2 + 1

	love.window.setTitle(
		'left: '..tileLimits.left..' right: '..tileLimits.right..
		' top: '..tileLimits.top..' bottom: '..tileLimits.bottom
	)
end


function love.load()
	-- load tileset and generate quads
	tileset = love.graphics.newImage('tiles-16x16-s1-1.png')
	tileset:setFilter('nearest','nearest')
	quads = getQuads(tileset,spacing,spacing)

	updateTileLimits ()
end

function love.update(dt)
	local up = love.keyboard.isDown ('up')
	local down = love.keyboard.isDown ('down')
	local left = love.keyboard.isDown ('left')
	local right = love.keyboard.isDown ('right')
	local speed = 60
	if up and not down then
		offsetY = offsetY + speed*dt/2 -- offset has another direction!
		updateTileLimits ()
	elseif down and not up then
		offsetY = offsetY - speed*dt/2
		updateTileLimits ()
	end
	if left and not right then
		offsetX = offsetX + speed*dt
		updateTileLimits ()
	elseif right and not left then
		offsetX = offsetX - speed*dt
		updateTileLimits ()
	end
end

------------- draw:

local function drawTilePolygon(x,y)
	local screenX,screenY = tileToScreen(x,y)

	local points = {
		screenX + 2*isoWidth,screenY + 3*isoHeight + isoYoffset,
		screenX + isoWidth,screenY + 2*isoHeight + isoYoffset,
		screenX,screenY + 3*isoHeight + isoYoffset,
		screenX + isoWidth,screenY + 4*isoHeight + isoYoffset,
	}

	love.graphics.setColor(1,0,0,0.5)
	love.graphics.polygon('fill',points)
end

local function renderTile(z,x,y,deltaY)
	-- check if the tile exists in the map and render it
	if map[z] and map[z][y] and map[z][y][x] then
		local tile = map[z][y][x]
		if tile ~= 0 then
			local screenX,screenY = tileToScreen(x,y)
			love.graphics.setColor(1,1,1,1)
			love.graphics.draw(tileset,quads[tile],screenX,screenY + deltaY)
		end
	end
end


local function renderByCondition(z,deltaY)
	-- render tiles by condition (tile limits)
	for y = 1,#map[z] do
		for x = 1,#map[z][y] do
			if (x - y) >= tileLimits.left and (x - y) <= tileLimits.right then
				if (x + y) >= tileLimits.top and (x + y) <= tileLimits.bottom then
					renderTile(z,x,y,deltaY)
				end
			end
		end
	end
end

local function renderDiagonals(z,deltaY)
	-- get the starting tile for diagonal rendering
	local x0,y0 = screenToTile(screen.x,screen.y)
	x0 = x0 - 1

	-- render tiles by diagonals (horizontal and vertical)
	local ySteps = (tileLimits.bottom - tileLimits.top) + 1

	for stepY = 0,ySteps do
		-- calculate the first tile in the horizontal diagonal
		local dx = stepY % 2
		local dy = math.floor(stepY / 2)
		local x1 = x0 + dx + dy
		local y1 = y0 + dy

		-- render the first tile in the diagonal
		renderTile(z,x1,y1,deltaY)

		-- calculate horizontal steps
		local xSteps = (tileLimits.right - tileLimits.left) / 2
		-- jump over diagonals (not each!)
		for stepX = 0,xSteps do
			local x = x1 + stepX
			local y = y1 - stepX
			renderTile(z,x,y,deltaY)
		end
	end
end


function love.draw()
	love.graphics.push ()
	love.graphics.scale (scale)
	for z = 1,#map do
		local deltaY = (1 - z) * depthOffset
--	renderByCondition(z,deltaY) -- it works! just disabled
		renderDiagonals(z,deltaY)
	end

	-- draw tile polygon at mouse position
	drawTilePolygon(mouse.x,mouse.y)
	love.graphics.pop ()

	-- draw screen limits rectangle
	love.graphics.setColor (1,1,1)
	love.graphics.setLineWidth (3)
	love.graphics.rectangle ('line',screen.x,screen.y,screen.w,screen.h)
end

function love.mousemoved (screenX,screenY)
	local x,y = screenToTile(screenX,screenY)
	love.window.setTitle ('x:'..x..' y:'..y)
	mouse.x = x
	mouse.y = y
end