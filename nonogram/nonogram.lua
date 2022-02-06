-- License CC0 (Creative Commons license) (c) darkfrei, 2022


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
	self.solutionMap = {}
	self.guessMap = {} 
	self.solved = false
	for x = 1, self.mapWidth do
		self.guessMap[x] = {}
		self.solutionMap[x] = {}
		for y = 1, self.mapHeight do
			self.guessMap[x][y] = 2 -- gray
			local r,g,b,a = imageData:getPixel(x-1, y-1)
			local value = (r+g+b)/3
			value = value*(1-a) + (1-value)*a -- xor
			value = math.floor (value + 0.5)*a
			print (x, y, r, g, b, a, value)
			self.solutionMap[x][y] = value
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
			local value = self.solutionMap[x][y]
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
	print ('left bar')
	for i = 1, #bar do
		print(unpack(bar[i]))
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
			local value = self.solutionMap[x][y]
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
	print ('top bar')
	for i = 1, #bar do
		print(unpack(bar[i]))
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
		local line = bar[y]
		if line.solved then
			love.graphics.setColor(0,1,0)
		else
			love.graphics.setColor(1,1,1)
		end
		for x = 1, self.amountLeft do
			local n = line and line[x] or nil
			if n then
				local rx = size*(x-1+(maxAmount-#bar[y]))
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
		local line = bar[x]
		if line.solved then
			love.graphics.setColor(0,1,0)
		else
			love.graphics.setColor(1,1,1)
		end
		for y = 1, self.amountTop do
			local n = line and line[y] or nil
			if n then
				local rx = dx+size*(x-1)
				local ry = size*(y-1+(maxAmount-#bar[x]))
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
			local value = self.solutionMap[x][y]
			love.graphics.setColor (value, value, value)
			love.graphics.rectangle ('fill', dx+size*(x-1), dy+size*(y-1), size, size)
			love.graphics.setColor (1-value, 1-value, 1-value)
			love.graphics.printf (value, font, dx+size*(x-1), dy+size*(y-1), size, 'center',0,1,1,0,textYOffset)
		end
	end
end

function nono:drawGuess()
	love.graphics.setLineWidth(1)
	local size = self.GridSize
	local font = self.font
	local textYOffset = self.fontHeight-size
	local dx, dy = size*(self.amountLeft), size*(self.amountTop)
	for x = 1, self.mapWidth do
		for y = 1, self.mapHeight do
			local value = self.guessMap[x][y]
			if value == 0 then
				love.graphics.setColor (0.1, 0.1, 0.1)
			elseif value == 1 then
				love.graphics.setColor (0.9, 0.9, 0.9)
			elseif value == 2 then
				love.graphics.setColor (0.15, 0.15, 0.15)
			end
			love.graphics.rectangle ('fill', dx+size*(x-1), dy+size*(y-1), size, size)
--			love.graphics.setColor (0,0,1)
--			love.graphics.printf (value, font, dx+size*(x-1), dy+size*(y-1), size, 'center',0,1,1,0,textYOffset)
		end
	end
end

function nono:drawGrid()
	love.graphics.setLineWidth(1)
	love.graphics.setColor (0.25, 0.25, 0.25)
	local size = self.GridSize
	local x1, y1 = size*(self.amountLeft), size*(self.amountTop)
	local x2, y2 = x1+size*self.mapWidth, y1+size*self.mapHeight
	for i = 1, self.mapWidth do
		local x = x1 + size*i
		love.graphics.line (x, y1, x, y2)
	end
	for j = 1, self.mapHeight do
		local y = y1 + size*j
		love.graphics.line (x1, y, x2, y)
	end
end

function nono:toGrid (mx, my)
	local x = math.floor(mx/self.GridSize)-self.amountLeft+1
	local y = math.floor(my/self.GridSize)-self.amountTop+1
	return x, y
end

function nono:isOnMap (x, y)
	if x >= 1 and x <= self.mapWidth
	and y >= 1 and y <= self.mapHeight then
		return true
	end
	return false
end


function nono:isLineSolved (y)
	local last = 0
	local summ = 0
	local line = {}
	local map = self.guessMap
	for x = 1, self.mapWidth do
		local value = map[x][y]
		if value == 2 then value = 0 end
		if last == 0 and value == 0 then
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
	if #line == 0 then return end
	local solutionLine = self.leftBar[y]
	for i = 1, math.max(#line, #solutionLine) do
		local value = solutionLine[i]
		local value2 = line[i]
--		if not((value == 1 and value2 == 1) or (value == 0 and ((value2 == 0) or (value2 == 2)))) then
		if not (value == value2) then
			solutionLine.solved = false
--			print (value, line[i])
			return false
		end
	end
	solutionLine.solved = true
	return true
end

function nono:isColumnSolved (x)
	local last = 0
	local summ = 0
	local line = {}
	local map = self.guessMap
	for y = 1, self.mapHeight do
		local value = map[x][y]
		if value == 2 then value = 0 end
		if last == 0 and value == 0 then
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
	
	local solutionLine = self.topBar[x]
	if (#line == 0) and (#solutionLine == 0) then 
		solutionLine.solved = true
		return true 
	end
	for i = 1, math.max(#line, #solutionLine) do
		local value = solutionLine[i]
		local value2 = line[i]
--		if not((value == 1 and value2 == 1) or (value == 0 and ((value2 == 0) or (value2 == 2)))) then
		if not (value == value2) then
			solutionLine.solved = false
--			print (value, line[i])
			return false
		end
	end
	solutionLine.solved = true
	return true
end

function nono:isSolved ()
	-- left bar
	local solved = true
	for y = 1, self.mapHeight do
		if not (self:isLineSolved (y)) then
			solved = false
		end
	end
	for x = 1, self.mapWidth do
		if not (nono:isColumnSolved (x)) then
			solved = false
		end
	end
	if solved then
		self.solved = true
	else
		self.solved = false
	end
end

function nono:mousepressed (mx, my, button, istouch, presses)
	local x, y = self:toGrid (mx, my)
	
	if self:isOnMap (x, y) then
		if (self.guessMap[x][y] == 1) or (button == 2) then 
			self.guessMap[x][y] = 0
			self.guessLine = {x, y, 0}
			nono:isSolved ()
		else
			self.guessMap[x][y] = 1
			self.guessLine = {x, y, 1}
			nono:isSolved ()
		end
	end
end

function nono:mousemoved (mx, my, dx, dy, istouch)
	local x, y = self:toGrid (mx, my)
	if self.guessLine then
		if self:isOnMap (x, y) then
			local value = self.guessLine[3]
			self.guessMap[x][y] = value
			nono:isSolved ()
		else
			self.guessLine = nil
		end
	end
end

function nono:mousereleased (mx, my, button, istouch, presses)
	if self.guessLine then
		self.guessLine = nil
	end
end

return nono