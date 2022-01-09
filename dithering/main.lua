-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local imageData = love.image.newImageData ('image.png')
local image = love.graphics.newImage (imageData)
local w, h = image:getDimensions()
local scale = 3
love.window.setMode(w*scale, h*scale, {resizable=true, borderless=false})


local function round4 (rgba, k)
	local r,g,b,a=rgba[1], rgba[2], rgba[3], rgba[4]
	return {math.floor(r+k), math.floor(g+k), math.floor(b+k), math.floor(a+k)}
end

local function setPixel4(canvasData, x, y, rgba)
	local r,g,b,a=rgba[1], rgba[2], rgba[3], rgba[4]
	canvasData:setPixel(x, y, r, g, b, a)
end

local function diffrgba (rgba, rgba2)
	return {rgba[1]-rgba2[1], rgba[2]-rgba2[2], rgba[3]-rgba2[3], rgba[4]-rgba2[4]}
end

local function summrgba (rgba, rgba2)
	return {rgba[1]+rgba2[1], rgba[2]+rgba2[2], rgba[3]+rgba2[3], rgba[4]+rgba2[4]}
end

local function multrgba (rgba, rgba2)
	return {rgba[1]*rgba2[1], rgba[2]*rgba2[2], rgba[3]*rgba2[3], rgba[4]*rgba2[4]}
end

local function scalergba (rgba, factor)
	return {factor*rgba[1], factor*rgba[2], factor*rgba[3], factor*rgba[4]}
end

local function correctPixel (x, y, rgbaErr, factor)
	local rgba = map[x][y]
	local rgba2 = scalergba (rgbaErr, factor)
	return summrgba (rgba, rgba2)
end

local canvas = love.graphics.newCanvas (w, h)

local canvasData = canvas:newImageData( )

map = {}
for x = 1, w do
	map[x] = {}
	for y = 1, h do
		map[x][y] = {imageData:getPixel( x-1, y-1 )}
	end
end
	
for y = 1, h-1 do
	for x = 2, w-1 do
		local rgba = map[x][y]
		
		local rgba2 = round4 (rgba, 0.3)
		setPixel4(canvasData, x-1, y-1, rgba2)
		
		local rgbaErr = diffrgba (rgba, rgba2)
--		rgbaErr = multrgba (rgbaErr, rgbaErr)
		rgbaErr = scalergba (rgbaErr, 0.6)
		
		map[x+1][y] = 	correctPixel (x+1, y,   rgbaErr, 7/16)
		map[x-1][y+1] = correctPixel (x-1, y+1, rgbaErr, 11/16)
		map[x][y+1] = 	correctPixel (x  , y+1, rgbaErr, 5/16)
		map[x+1][y+1] = correctPixel (x+1, y+1, rgbaErr, 1/16)
	end
end


	
canvas = love.graphics.newImage (canvasData)
canvas:setFilter("linear", "nearest")
--love.graphics.setCanvas()
 
function love.update(dt)
	
end


function love.draw()
	love.graphics.setColor(1,1,1)
--	love.graphics.draw(image,0,0,0,scale)
	love.graphics.draw(canvas,0,0,0,scale)
end

function love.keypressed(key, scancode, isrepeat)
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

function love.mousemoved( x, y, dx, dy, istouch )
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end