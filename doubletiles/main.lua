-- License CC0 (Creative Commons license) (c) darkfrei, 2021

local tt = require ('tiles.tiles')
local types, tiles = tt.types, tt.tiles
print (unpack(tiles))

local path = 'tiles/'
local canvasWidth, canvasHeight

for nr, typ in pairs (types) do
	for i, tile in ipairs (typ)  do
		local filename = path..tile.name..'.png'
		local image = love.graphics.newImage (filename)
		if not canvasWidth then
			canvasWidth = 2*image:getWidth( )
			canvasHeight = 2*image:getHeight( )
		end
		tile.image = image
	end
end

local canvases = {}
--local shifts = {{1,1}, {2,1}, {1,2}, {2,2}}
local shifts = {{1,1}, {1,2}, {2,1}, {2,2}}
for i, tile in ipairs (tiles) do
	local canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
	table.insert (canvases, canvas)
	love.graphics.setCanvas(canvas)

	for j, nr in ipairs (tile) do
		local shift = shifts[j]
		local image = types[nr][1].image
		local x, y = image:getWidth( )*(shift[1]-1), image:getHeight( )*(shift[2]-1)
		love.graphics.draw(image, x, y)
	end
	
	love.graphics.setCanvas()
	
--	local filename = table.concat(tile, '-')
	local filename = tile.nr
--	canvas:newImageData():encode("png","output-"..filename..".png")
	canvas:newImageData():encode("png",filename..".png")
end
 
function love.update(dt)
	
end


function love.draw()
	canvasNr = canvasNr or 1
	love.graphics.draw (canvases[canvasNr], canvasWidth/2, canvasHeight/2)
	love.graphics.print (canvasNr .. '/' .. #canvases)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "space" then
		canvasNr = canvasNr + 1
		if not canvases[canvasNr] then
			canvasNr = 1
		end
	elseif key == "escape" then
		love.event.quit()
	end
end

