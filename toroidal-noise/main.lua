-- texture
-- toroidal noise texture
-- tiling for noise texture

-- License CC0 (Creative Commons license) (c) darkfrei, 2023



local function toroidalNoise(x, y, periodX, periodY, scale)

	
	local a, b = 2*math.pi*x/periodX, 2*math.pi*y/periodY
	
	local k1 = 1/math.pi
	local k2 = 1
	local pxa = k1*math.cos(a*k2)/scale
	local pya = k1*math.sin(a*k2)/scale
	
	local pxb = k1*math.cos(b*k2)/scale
	local pyb = k1*math.sin(b*k2)/scale
	
	local noiseValue = love.math.noise(pxa+113, pyb+127, pya+131, pxb+137)
	local normalizedValue = (noiseValue-0.5)*1.55 + 0.57
	if normalizedValue > 1 then
		normalizedValue = 0
	elseif normalizedValue < 0 then
		normalizedValue = 1
	end
	return normalizedValue
end

local function generateTexture(width, height, scale, periodX, periodY)
	local texture = love.image.newImageData(width, height)

	for y = 0, height - 1 do
		for x = 0, width - 1 do
			local noiseValue = toroidalNoise(x, y, periodX, periodY, scale)
			local color = math.floor(noiseValue * 255)/255

			texture:setPixel(x, y, color, color, color, 255)
		end
	end

	return love.graphics.newImage(texture)
end

function love.load()
	textureWidth = 256
	textureHeight = 256
	scale = 0.3
	periodX = textureWidth
	periodY = textureHeight

	texture = generateTexture(textureWidth, textureHeight, scale, periodX, periodY)

	love.window.setMode(4 * textureWidth, 4 * textureHeight)
end

function love.update(dt)

end

function love.draw()
	local w = texture:getWidth()
	local h = texture:getHeight()

	love.graphics.scale(2)
	love.graphics.draw(texture, 0, 0)
	love.graphics.draw(texture, w, 0)
	love.graphics.draw(texture, w, h)
	love.graphics.draw(texture, 0, h)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end