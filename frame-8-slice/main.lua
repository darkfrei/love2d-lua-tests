
local bias = {
	topLeft     = {-1,-1},
	top         = {-2,-1},
	topRight    = {-3,-1},
	left        = {-1,-2},
	right       = {-2,-2},
	bottomLeft  = {-1,-3},
	bottom      = {-2,-3},
	bottomRight = {-3,-3},
}


local function getQTiles(imgData)
	local width, height = imgData:getWidth(), imgData:getHeight()
	local visited = {}
	local tiles = {}

	-- ключевой цвет (фон) берём из верхнего левого пикселя
	local kr, kg, kb, ka = imgData:getPixel(0, 0)

	local function floodFill(x, y)
		local rect = {xMin = x, yMin = y, xMax = x, yMax = y}
		local stack = {{x=x, y=y}}

		while #stack > 0 do
			local pos = table.remove(stack)
			local px, py = pos.x, pos.y

			if px >= 0 and px < width and py >= 0 and py < height and not visited[py*width + px] then
				local r, g, b, a = imgData:getPixel(px, py)
				if not (r == kr and g == kg and b == kb) then
					visited[py*width + px] = true

					rect.xMin = math.min(rect.xMin, px)
					rect.yMin = math.min(rect.yMin, py)
					rect.xMax = math.max(rect.xMax, px)
					rect.yMax = math.max(rect.yMax, py)

					table.insert(stack, {x=px+1, y=py})
					table.insert(stack, {x=px-1, y=py})
					table.insert(stack, {x=px, y=py+1})
					table.insert(stack, {x=px, y=py-1})
				else
					visited[py*width + px] = true
				end
			end
		end

		rect.x = rect.xMin
		rect.y = rect.yMin
		rect.w = rect.xMax - rect.xMin + 1
		rect.h = rect.yMax - rect.yMin + 1
		return rect
	end

	-- обход всех пикселей
	for y = 0, height-1 do
		for x = 0, width-1 do
			if not visited[y*width + x] then
				local r, g, b, a = imgData:getPixel(x, y)
				if not (r == kr and g == kg and b == kb) then
					local rect = floodFill(x, y)
					table.insert(tiles, rect)
				else
					visited[y*width + x] = true
				end
			end
		end
	end

	-- вычисляем границы всей рамки
	local minX, minY = width, height
	local maxX, maxY = 0, 0
	for _, t in ipairs(tiles) do
		minX = math.min(minX, t.xMin)
		minY = math.min(minY, t.yMin)
		maxX = math.max(maxX, t.xMax)
		maxY = math.max(maxY, t.yMax)
	end

	-- присваиваем теги
	for _, t in ipairs(tiles) do
		t.tags = {}

		if t.xMin == minX then t.tags.left = true end
		if t.xMax == maxX then t.tags.right = true end
		if t.yMin == minY then t.tags.top = true end
		if t.yMax == maxY then t.tags.bottom = true end

		local tagList = {}
		for k,v in pairs(t.tags) do if v then table.insert(tagList, k) end end
		print(string.format("Tile #%d: x=%d, y=%d, w=%d, h=%d, tags=%s", _, t.x, t.y, t.w, t.h, table.concat(tagList, ",")))


	end

-- присваиваем имена на основе тегов
	for _, t in ipairs(tiles) do
		local name = "unknown"

		if t.tags.top and t.tags.left then
			name = "topLeft"
		elseif t.tags.top and t.tags.right then
			name = "topRight"
		elseif t.tags.bottom and t.tags.left then
			
			name = "bottomLeft"
		elseif t.tags.bottom and t.tags.right then
			name = "bottomRight"
		elseif t.tags.top then
			name = "top"
			t.scaledWidth = 1
		elseif t.tags.bottom then
			name = "bottom"
			t.scaledWidth = 1
		elseif t.tags.left then
			name = "left"
			t.scaledHeight = 1
		elseif t.tags.right then
			name = "right"
			t.scaledHeight = 1
		end

		t.name = name
--		print(string.format("Tile #%d assigned name: %s", _, t.name))
	end
	
	local qtiles = {}
	for i, tile in ipairs(tiles) do
		qtiles[tile.name] = tile
	end

	return qtiles
end



local function newFrame(filename)
	-- загружаем изображение и его данные пикселей
	local image = love.graphics.newImage(filename)
	image:setFilter("nearest", "nearest") -- убираем размытие при масштабировании

	local imgData = love.image.newImageData(filename)

	-- получаем тайлы (8-patch)
	local qtiles = getQTiles(imgData)  -- предполагается, что getQTiles присваивает теги: top, bottom, left, right и углы

	local frame = {
		x = 0,
		y = 0,
		
		image = image,
		qtiles = qtiles,
	}
	
--	print ('tiles:', #tiles)

	-- создаём квадры и вычисляем renderX/renderY
	for _, t in pairs(qtiles) do
		t.quad = love.graphics.newQuad(t.x, t.y, t.w, t.h, imgData:getWidth(), imgData:getHeight())
		t.renderX = t.x
		t.renderY = t.y
	end

	-- вычисляем исходную ширину и высоту рамки
	
	frame.height = (frame.topLeft and frame.topLeft.h or 0) + (frame.left and frame.left.h or 0) + (frame.bottomLeft and frame.bottomLeft.h or 0)

	return frame
end

local function setFrameSize(frame, targetWidth, targetHeight)
	local qtiles = frame.qtiles
	local tl = qtiles.topLeft
	local tr = qtiles.topRight
	local bl = qtiles.bottomLeft
	local br = qtiles.bottomRight
	local top = qtiles.top
	local bottom = qtiles.bottom
	local left = qtiles.left
	local right = qtiles.right

	-- углы
	tl.renderX = tl.x
	tl.renderY = tl.y

	tr.renderX = tl.renderX + targetWidth - tr.w
	tr.renderY = tr.y

	bl.renderX = tl.renderX
	bl.renderY = tl.renderY + targetHeight - bl.h

	br.renderX = tl.renderX + targetWidth - br.w
	br.renderY = tl.renderY + targetHeight - br.h

	-- верхняя сторона
	if top then
		top.renderX = tl.renderX + tl.w
		top.renderY = tl.renderY
		top.scaledWidth = (targetWidth - tl.w - tr.w) / top.w
	end

-- нижняя сторона
if bottom then
	bottom.renderX = bl.renderX + bl.w
	bottom.renderY = tl.renderY + targetHeight - bottom.h  -- <- здесь была ошибка
	bottom.scaledWidth = (targetWidth - bl.w - br.w) / bottom.w
end

	-- левая сторона
	if left then
		left.renderX = tl.renderX
		left.renderY = tl.renderY + tl.h
		left.scaledHeight = (targetHeight - tl.h - bl.h) / left.h
	end

-- правая сторона
if right then
	right.renderX = tl.renderX + targetWidth - right.w  
	right.renderY = tr.renderY + tr.h
	right.scaledHeight = (targetHeight - tr.h - br.h) / right.h
end

	-- дебаг
--	print("=== setFrameSize debug (target size) ===")
--	if right then
--		print(string.format("Right tile should be at X=%.1f, Y=%.1f, scaledHeight=%.2f", 
--			tl.renderX + targetWidth - right.w, right.renderY, right.scaledHeight))
--		print(string.format("Right tile actual renderX=%.1f, renderY=%.1f", right.renderX, right.renderY))
--	end
--	if bottom then
--		print(string.format("Bottom tile should be at X=%.1f, Y=%.1f, scaledWidth=%.2f", 
--			bottom.renderX, tl.renderY + targetHeight - bottom.h, bottom.scaledWidth))
--		print(string.format("Bottom tile actual renderX=%.1f, renderY=%.1f", bottom.renderX, bottom.renderY))
--	end

	for name, t in pairs(qtiles) do
		if t then
--			print(string.format(
--				"%s: renderX=%.1f, renderY=%.1f, scaledWidth=%s, scaledHeight=%s",
--				name,
--				t.renderX,
--				t.renderY,
--				t.scaledWidth or "-",
--				t.scaledHeight or "-"
--			))
		end
	end
--	print("=======================================")
end




function love.load()

	patchFrame = newFrame ('input.png')

	setFrameSize(patchFrame, 800, 600) -- устанавливаем размер рамки

end






local function drawPatch8(patchFrame)
	local qtiles = patchFrame.qtiles
	local tl = qtiles.topLeft
	local tr = qtiles.topRight
	local bl = qtiles.bottomLeft
	local br = qtiles.bottomRight
	local top = qtiles.top
	local bottom = qtiles.bottom
	local left = qtiles.left
	local right = qtiles.right
	
	local image = patchFrame.image

	-- углы
	love.graphics.draw(image, tl.quad, tl.renderX, tl.renderY)
	love.graphics.draw(image, tr.quad, tr.renderX, tr.renderY)
	love.graphics.draw(image, bl.quad, bl.renderX, bl.renderY)
	love.graphics.draw(image, br.quad, br.renderX, br.renderY)

	-- стороны с масштабированием
	if top then
		love.graphics.draw(image, top.quad, top.renderX, top.renderY, 0, 
			top.scaledWidth, 1)
	end
	if bottom then
		love.graphics.draw(image, bottom.quad, bottom.renderX, bottom.renderY, 0, 
			bottom.scaledWidth, 1)
	end
	if left then
		love.graphics.draw(image, left.quad, left.renderX, left.renderY, 0, 1, 
			left.scaledHeight)
	end
	if right then
		love.graphics.draw(image, right.quad, right.renderX, right.renderY, 0, 1, 
			right.scaledHeight)
	end

	-- дебаг: печатаем имена тайлов
	for name, rect in pairs(patchFrame) do
		if type(rect) == "table" and rect.quad then
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.print(rect.name or name, rect.renderX, rect.renderY)
		end
	end
end

function love.mousemoved (x, y)
	setFrameSize(patchFrame, x, y)
end

function love.draw()
	drawPatch8(patchFrame)
end

