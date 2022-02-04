local nono = {}

nono.GridSize = 40
nono.amountTop = 1
nono.amountLeft = 1

nono.font = love.graphics.newFont(32)
nono.fontHeight = nono.font:getHeight()
print ('font height', nono.fontHeight)
--self.font:getWidth("Your text here")
--self.font:getHeight()

function nono:newMap (filename)
	local imageData = love.image.newImageData( filename )
	self.mapWidth, self.mapHeight = imageData:getDimensions( )
	self.map = {}
	for x = 1, self.mapWidth do
		self.map[x] = {}
		for y = 1, self.mapHeight do
			local r,g,b,a = imageData:getPixel(x-1, y-1)
			local value = math.floor((r+g+b)/3+0.5)+a -- 0 or 1
			print (x, y, r, g, b, a, value)
			self.map[x][y] = value
		end
	end
	return
end

function nono:shortLeftBar ()
	local bar = {}
	local maxAmount = 0
	for y = 1, self.mapHeight do
		local last = 0
		local summ = 0
		local line = {}
		for x = 1, self.mapWidth do
			local value = self.map[x][y]
			if last == 0 and value == 0 then
				-- do nothing
				last = value
			elseif last == 0 and value == 1 then
				summ = 1
				last = value
			elseif last == 1 and value == 1 then
				summ = summ + 1
				last = value
			elseif last == 1 and value == 0 then
				table.insert (line, summ)
				summ = 0
				last = value
			end
			if x == self.mapWidth and summ > 0 then
				table.insert (line, summ)
			end
		end
		if #line > maxAmount then
			maxAmount = #line
		end
		table.insert (bar, line)
	end
	self.leftBar = bar
	print ('maxAmount', maxAmount)
	self.amountLeft = maxAmount
end

function nono:shortTopBar ()
	local bar = {}
	local maxAmount = 0
	
	for x = 1, self.mapWidth do
		local last = 0
		local summ = 0
		local line = {}
		for y = 1, self.mapHeight do
			local value = self.map[x][y]
			if last == 0 and value == 0 then
				-- do nothing
				last = value
			elseif last == 0 and value == 1 then
				summ = 1
				last = value
			elseif last == 1 and value == 1 then
				summ = summ + 1
				last = value
			elseif last == 1 and value == 0 then
				table.insert (line, summ)
				summ = 0
				last = value
			end
			if y == self.mapHeight and summ > 0 then
				table.insert (line, summ)
			end
		end
		if #line > maxAmount then
			maxAmount = #line
		end
		table.insert (bar, line)
	end
	self.topBar = bar
	print ('maxAmount', maxAmount)
	self.amountTop = maxAmount
end


function nono:drawLeftBar()
	local bar = self.leftBar
	local maxAmount = self.amountLeft
	local size = self.GridSize
	local font = self.font
	local textYOffset = self.fontHeight-size
	local dx, dy = size*self.amountLeft, size*self.amountTop
	love.graphics.setColor (1,1,1)
	for y = 1, #self.leftBar do
		for x = 1, self.amountLeft do
			local n = bar[y] and bar[y][x] or nil
			if n then
				local rx = size*(maxAmount-x)
				local ry = dy+size*(y-1)
				love.graphics.printf (n, font, rx, ry, size, 'center',0,1,1,0,textYOffset)
				love.graphics.rectangle ('line', rx, ry, size, size)
			end
			
		end
	end
end

function nono:drawTopBar()
	local bar = self.topBar
	local maxAmount = self.amountTop
	local size = self.GridSize
	local font = self.font
	local textYOffset = self.fontHeight-size
	local dx, dy = size*self.amountLeft, size*self.amountTop
	love.graphics.setColor (1,1,1)
	for x = 1, #self.topBar do
		for y = 1, self.amountTop do
			local n = bar[x] and bar[x][y] or nil
			if n then
				local rx = dx+size*(x-1)
				local ry = size*(maxAmount-y)
				love.graphics.printf (n, font, rx, ry, size, 'center',0,1,1,0,textYOffset)
				love.graphics.rectangle ('line', rx, ry, size, size)
			end
			
		end
	end
end

function nono:drawSolution()
	love.graphics.setLineWidth(2)
	local size = self.GridSize
	local font = self.font
	local textYOffset = nono.fontHeight-size
	local dx, dy = size*(self.amountLeft), size*(self.amountTop)
	for x = 1, self.mapWidth do
		for y = 1, self.mapHeight do
			local value = self.map[x][y]
			love.graphics.setColor (value, value, value)
			love.graphics.rectangle ('fill', dx+size*(x-1), dy+size*(y-1), size, size)
			love.graphics.setColor (1-value, 1-value, 1-value)
			love.graphics.printf (value, font, dx+size*(x-1), dy+size*(y-1), size, 'center',0,1,1,0,textYOffset)
		end
	end
end

return nono