-- License CC0 (Creative Commons license) (c) darkfrei, 2023


--love.window.setMode(1280, 800) -- Steam Deck resolution
love.window.setMode(1280*2, 800*2) -- double Steam Deck resolution
Width, Height = love.graphics.getDimensions( )

local tileTransitions6 = {
	{c={1,0,0,0,0,0,0,0}, r=4}, -- top left vertex
	{c={1,1,1,0,0,0,0,0}, r=4}, -- top plank
	{c={1,1,1,1,1,0,0,0}, r=4}, -- top left edge
	{c={1,1,1,1,1,1,1,0}, r=4}, -- right U
	{c={1,1,1,1,1,1,1,1}, r=1}, -- O-tile
	{c={1,1,1,1,1,1,1,1}, r=1}, -- full
}
local filename = 'tile-256'
local ext = '.png'
local texture = 'stone-256.png'

local function boolToNum (a, b, c, d, e, f, g, h)
  return a + 2*b + 4*c + 8*d + 16*e + 32*f + 64*g + 128*h
end

local tileTransitions47 = {}


local mapUtiles = {}

local tileW, tileH

local function getShiftedSequence (list, r)
	local c = {unpack(list)}
		for j = 1, r do
			-- moving last to the first:
			table.insert (c, 1, table.remove(c, #c))
			table.insert (c, 1, table.remove(c, #c))
		end
	return c
end

for i = 1, 6 do
	local tile = tileTransitions6[i]
	local image = love.graphics.newImage(filename..'-'..i..ext)
	tileW, tileH = image:getDimensions()
	
	for r = 0, tile.r-1 do
		local c = getShiftedSequence (tile.c, r)

		local uTile = {c=c, image=image, r=r}
		local number = boolToNum (unpack(uTile.c))
		if i == 6 then number = 0 end
		mapUtiles[number] = uTile
		print (i, r, number)
	end
end

local tr15 = {
	{1, 4},
	{1, 4, 16},
	{1, 4, 16, 64},
	{1+2+4+8+16, 64},
	{1+2+4, 16},
	{1+2+4, 64},
	{1+2+4, 16, 64},
	{1+2+4, 16+32+64},
	{1, 16},
}

for i, numbers in ipairs (tr15) do
	local canvas = love.graphics.newCanvas(tileW, tileH)
	local n = 0
	local cNew = {0,0,0,0,0,0,0,0}
	love.graphics.setCanvas(canvas)
--		love.graphics.setBackgroundColor( 1,1,1 )
		love.graphics.setBlendMode("alpha")
		love.graphics.rectangle('fill', 0,0, tileW, tileH)
		love.graphics.setBlendMode("multiply", "premultiplied")
		for j, number in ipairs (numbers) do
			n = n + number
			local tile = mapUtiles[number]
			love.graphics.draw(tile.image, tileW/2, tileH/2, tile.r*math.pi/2, 1, 1, tileW/2, tileH/2)
			for k = 1, #tile.c do
				if tile.c[k] == 1 then
					cNew[k] = 1
				end
			end
		end
	love.graphics.setCanvas()
	canvas:newImageData():encode("png","filename-"..n..".png")

	
	
	for r = 0, 4 do
		local c = getShiftedSequence (cNew, r)

--		if c[2] == 1 then c[1] = 1 c[3] = 1 end
--		if c[4] == 1 then c[3] = 1 c[5] = 1 end
--		if c[6] == 1 then c[5] = 1 c[7] = 1 end
--		if c[8] == 1 then c[7] = 1 c[1] = 1 end
		
		local numberNew = boolToNum (unpack(c))
		local uTile = {c=c, image=canvas, r=r}
		
--		mapUtiles[n] = uTile
		mapUtiles[numberNew] = uTile
		print ('created', numberNew)
		
		love.graphics.setBlendMode("alpha")
		local canvas = love.graphics.newCanvas(tileW, tileH)
		love.graphics.setCanvas(canvas)
			love.graphics.draw(uTile.image, tileW/2, tileH/2, r*math.pi/2, 1, 1, tileW/2, tileH/2)
		love.graphics.setCanvas()
	end
	
end

love.graphics.setBlendMode("alpha")


print ('w', tileW, 'h', tileH)
local n_mapUtiles = 0
local numbers = {}
for number, tile in pairs (mapUtiles) do
	n_mapUtiles = n_mapUtiles + 1
	table.insert (numbers, number)
end
print ('n_mapUtiles', n_mapUtiles)

--for i, tile in pairs (mapUtiles) do
--	local c = tile.c
--	if c[2] == 1 then c[1] = 1 c[3] = 1 end
--	if c[4] == 1 then c[3] = 1 c[5] = 1 end
--	if c[6] == 1 then c[5] = 1 c[7] = 1 end
--	if c[8] == 1 then c[7] = 1 c[1] = 1 end
--end


local mapGrid = {}
local top, bottom = 1, 64
local left, right = 1, 64
local shiftX, shiftY = 0, 0
for y = top, bottom do
	mapGrid[y] = {}
	for x = left, right do
		local value = math.random (2)
		mapGrid[y][x] = (value == 1) and 1 or 0
	end
end
--mapGrid[1][1] = 1
--mapGrid[1][2] = 1
--mapGrid[2][1] = 1
--mapGrid[2][2] = 0
--mapGrid[3][2] = 1

function love.draw()
	love.graphics.translate (shiftX, shiftY)
	 
	
	for i, number in ipairs (numbers) do
		local tile = mapUtiles[number]
		local x = i-1
		local y = -1
		love.graphics.setColor(1,1,1)
		love.graphics.draw(tile.image, (x+0.5)*tileW, (y+0.5)*tileH, tile.r*math.pi/2, 1,1, tileW/2, tileH/2)
		
		
		love.graphics.setColor(0,0,0)
		love.graphics.print (number, x*tileW, y*tileH)
		love.graphics.print (table.concat(tile.c, ','), x*tileW, y*tileH+20)
		love.graphics.print ('r'..tile.r, x*tileW, y*tileH+40)
		
	end
	
	love.graphics.scale(0.25)
--	local textColor = {0,0,0,1} -- black
	local textColor = {0,0,0,0} -- transparent
	
	for y = top, bottom do
		for x = left, right do
			
			local value = mapGrid[y][x]
			if value == 1 then
				-- draw full tile
				love.graphics.setColor(1,1,1)
				love.graphics.draw(mapUtiles[0].image, (x-1)*tileW, (y-1)*tileH)
				love.graphics.setColor(textColor)
				love.graphics.print (value, (x-1)*tileW, (y-1)*tileH)
			elseif true then
				love.graphics.setColor(1,1,1)
				love.graphics.rectangle('fill', (x-1)*tileW, (y-1)*tileH, tileW, tileH)
			else
				local a = mapGrid[y-1] and mapGrid[y-1][x-1] or 0
				local b = mapGrid[y-1] and mapGrid[y-1][x]   or 0
				local c = mapGrid[y-1] and mapGrid[y-1][x+1] or 0
				local d = mapGrid[y]   and mapGrid[y][x+1]   or 0
				local e = mapGrid[y+1] and mapGrid[y+1][x+1] or 0
				local f = mapGrid[y+1] and mapGrid[y+1][x]   or 0
				local g = mapGrid[y+1] and mapGrid[y+1][x-1] or 0
				local h = mapGrid[y]   and mapGrid[y][x-1]   or 0
				if b == 1 then a = 1 c = 1 end
				if d == 1 then c = 1 e = 1 end
				if f == 1 then e = 1 g = 1 end
				if h == 1 then g = 1 a = 1 end
				local number = boolToNum (a, b, c, d, e, f, g, h)
				local tile = mapUtiles[number]
				if number == 0 then
					-- nothing to render
					love.graphics.setColor(1,1,1)
					love.graphics.rectangle('fill', (x-1)*tileW, (y-1)*tileH, tileW, tileH)
				elseif tile then
					love.graphics.setColor(1,1,1)
					love.graphics.draw(tile.image, (x-1+0.5)*tileW, (y-1+0.5)*tileH, tile.r*math.pi/2, 1,1, tileW/2, tileH/2)
					love.graphics.setColor(textColor)
					love.graphics.print ('r'..tile.r, (x-1)*tileW, (y-1)*tileH+40)
				else
				love.graphics.setColor(1,1,1)
					love.graphics.draw(mapUtiles[255].image, (x-1)*tileW, (y-1)*tileH)
				end
				love.graphics.setColor(textColor)
				love.graphics.print (number, (x-1)*tileW, (y-1)*tileH)
				love.graphics.print (table.concat({a, b, c, d, e, f, g, h}, ','), (x-1)*tileW, (y-1)*tileH+20)
			end
		end
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
	if love.mouse.isDown(1) then
		shiftX, shiftY = shiftX + dx, shiftY + dy
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

