-- License CC0 (Creative Commons license) (c) darkfrei, 2022

-- idea based on https://youtu.be/6Vag7NJUjJo
-- Wave Function Collapse Take 2

-- naming of numbers
	BLANK = 5
	UP = 1
	RIGHT = 2
	DOWN = 3
	LEFT = 4
Names = {"up", "right", "down", "left", "blank"}
	
	
Rules = { -- what is allowed
	[BLANK] = {-- clockwise:
--		 {BLANK, UP}, -- top tile is allowed to be only blank or up
--		 {BLANK, RIGHT}, -- right tile can be blank or right
--		 {BLANK, DOWN}, -- the bottom can be blank or down
--		 {BLANK, LEFT}, -- the left tile can be blank or left		 
		 {DOWN, BLANK}, -- top tile is allowed to be only blank or up
		 {LEFT, BLANK}, -- right tile can be blank or right
		 {UP, BLANK}, -- the bottom can be blank or down
		 {RIGHT, BLANK}, -- the left tile can be blank or left
	},
--	[_cross_] = { -- cross not exist
--		{RIGHT, DOWN, LEFT},
--		{UP, DOWN, LEFT},
--		{UP, RIGHT, LEFT},
--		{UP, RIGHT, DOWN},
--	},
	[UP] = { -- down
		{BLANK, DOWN}, -- true
		{UP, DOWN, RIGHT}, -- t
		{DOWN, RIGHT, LEFT}, -- t
		{UP, LEFT, DOWN}, -- t
	},
	[RIGHT] = { 
		{RIGHT, LEFT, UP}, -- r
		{BLANK, LEFT},
		{LEFT, RIGHT, DOWN}, -- r
		{LEFT, UP, DOWN}, -- r
	},
	[DOWN] = { 
		{UP, RIGHT, LEFT},
		{UP, DOWN, RIGHT},
		{UP, BLANK},
		{UP, DOWN, LEFT},
	},
	[LEFT] = { 
		{RIGHT, LEFT, UP},
		{RIGHT, UP, DOWN}, -- r
		{RIGHT, LEFT, DOWN}, -- r
		{BLANK, RIGHT}, -- r
	},
}

-- UP, RIGHT, DOWN, LEFT, BLANK
	
Sides = {{0,-1}, {1,0}, {0,1}, {-1,0}} -- up, right, down, left
	

function createTiles (size)
	love.graphics.setLineWidth(size/4)
	local lineColor = {0,0,0}
	local BackgroundColor = {0.8,0.8,0.8}
	local tiles = {}
	local blankCanvas = love.graphics.newCanvas(size, size)
	love.graphics.setCanvas (blankCanvas)
		love.graphics.setColor (BackgroundColor)
		love.graphics.rectangle ('fill', 0, 0, size, size)
	local upCanvas = love.graphics.newCanvas(size, size)
	love.graphics.setCanvas (upCanvas)
		love.graphics.setColor (BackgroundColor)
		love.graphics.rectangle ('fill', 0, 0, size, size)
		love.graphics.setColor (lineColor)
		love.graphics.line (0, size/2, size, size/2)
		love.graphics.line (size/2, size/2, size/2, 0)
	local rightCanvas = love.graphics.newCanvas(size, size)
	love.graphics.setCanvas (rightCanvas)
		love.graphics.setColor (BackgroundColor)
		love.graphics.rectangle ('fill', 0, 0, size, size)
		love.graphics.setColor (lineColor)
		love.graphics.line (size/2, 0, size/2, size)
		love.graphics.line (size/2, size/2, size, size/2)
	local downCanvas = love.graphics.newCanvas(size, size)
	love.graphics.setCanvas (downCanvas)
		love.graphics.setColor (BackgroundColor)
		love.graphics.rectangle ('fill', 0, 0, size, size)
		love.graphics.setColor (lineColor)
		love.graphics.line (0, size/2, size, size/2)
		love.graphics.line (size/2, size/2, size/2, size)
	local leftCanvas = love.graphics.newCanvas(size, size)
	love.graphics.setCanvas (leftCanvas)
		love.graphics.setColor (BackgroundColor)
		love.graphics.rectangle ('fill', 0, 0, size, size)
		love.graphics.setColor (lineColor)
		love.graphics.line (size/2, 0, size/2, size)
		love.graphics.line (size/2, size/2, 0, size/2)
	love.graphics.setCanvas ()
	return {
		[UP] = upCanvas, 
		[RIGHT] = rightCanvas, 
		[DOWN] = downCanvas, 
		[LEFT] = leftCanvas, 
		[BLANK] = blankCanvas}
end

unpack = table.unpack or unpack

function love.load()
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
--		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	width, height = love.graphics.getDimensions( )
	font = love.graphics.getFont()

	
	Size = 64
	Tiles = createTiles (Size)
	
	DIM = 12

	Grid = {}
	for y = 1, DIM do
		Grid[y] = {}
		for x = 1, DIM do
			Grid[y][x] = {
				x=x, y=y, 
				collapsed = false,
				options = {BLANK, UP, RIGHT, DOWN, LEFT}
			}
		end
	end
	
	Grid[2][2].index = BLANK
	Grid[2][2].options = {BLANK}
	Grid[2][2].collapsed = true
	
	Logs = {}
	
	update()
end 

function log (str)
	table.insert (Logs, 1, str)
	for i = #Logs, 10, -1 do
		table.remove (Logs)

	end
--	print (#Logs)
end

function getBestCells ()
	local entropyList = {}
	local lowestValue = 5
	for y = 1, DIM do
		for x = 1, DIM do
			local cell = Grid[y][x]
--			print('#cell.options '..#cell.options)
			if cell.collapsed then
				-- do nothing
			elseif #cell.options < lowestValue then
				lowestValue = #cell.options
--				print ('lowestValue ' .. lowestValue)
				entropyList = {cell}
			elseif #cell.options == lowestValue then
				table.insert (entropyList, cell)
			end
		end
	end
--	print(#entropyList)
	local bestCell = entropyList[love.math.random(#entropyList)]
	return bestCell
end

function iCopy (listA)
--	local listB = {}
--	for i = 1, #listA do
--		listB[i] = listA[i]
--	end
--	return listB
	return {unpack(listA)}
end

function getCell (x, y)
	x = (x-1)%DIM + 1 -- torus topology
	y = (y-1)%DIM + 1
	return Grid[y][x]
end

function isValueInList (value, list)
	for i, v in ipairs (list) do if v == value then return true end end 
end

function listMergeUnique (listReceiver, listTransmitter)
	for i, value in ipairs (listTransmitter) do
		if not isValueInList (value, listReceiver) then
			table.insert(listReceiver, value)
		end
	end
end	

function checkValid (arr, valid) -- list, allow-filter list
	-- valid = {BLANK, RIGHT}
	-- arr = {BLANK, UP, RIGHT, DOWN, LEFT}
	-- result: removing UP, DOWN, LEFT from arr
	for i = #arr, 1, -1 do -- backward
		local element = arr[i]
		if not isValueInList (element, valid) then
			table.remove (arr, i)
		end
	end
end

function update()
	local updated = false
	
	local nextGrid = {}
	for y = 1, DIM do
		nextGrid[y] = {}
		for x = 1, DIM do
			local cell = getCell (x, y)
			if cell.collapsed then
				nextGrid[y][x] = Grid[y][x]
				
			else -- not collapsed
				local options = iCopy (cell.options) -- {BLANK, UP, RIGHT, DOWN, LEFT}
--				local options = {BLANK, UP, RIGHT, DOWN, LEFT} -- all options
				-- look up
--				local i, side = 1, {0, -1}
				for i, side in ipairs (Sides) do
					-- neigbour cell
					log ('side '..i..' '..side[1]..' '..side[2])
					local nCell = getCell (x+side[1], y+side[2])
					local validOptions = {}
					for j, option in ipairs (nCell.options) do -- for all tile types
						-- first is up
						local validList = Rules[option][i]
						listMergeUnique (validOptions, validList)
					end
					checkValid (options, validOptions) -- list, allow-filter-list
				end
				
				if #options == 1 then
					nextGrid[y][x] = {
						x=x, y=y, 
						options=options, 
						collapsed = true,
						index = options[1]
					}
					updated = true
				else
					if not (#options == #cell.options) then
						updated = true
					end
					nextGrid[y][x] = {x=x, y=y, options=options, collapsed = false}
				end
				
			end
		end
	end
	Grid = nextGrid
	
	return updated
end

function autoupdate()
	while update() do
	
	end
end

function love.update(dt)
	--update()
end


function love.draw()
	love.graphics.setColor(1,1,1)
	love.graphics.setLineWidth(1)

	for y = 1, DIM do
		for x = 1, DIM do
			local cell = Grid[y][x]
			if cell.index then
				love.graphics.setColor(1,1,1)
				love.graphics.draw(Tiles[cell.index], (x-1)*Size, (y-1)*Size)
				love.graphics.print (Names[cell.index], (x-1)*Size, (y-1)*Size+14)
			else
				love.graphics.setColor(0.5,0.5,0.5)
				love.graphics.rectangle('fill', (x-1)*Size, (y-1)*Size, Size, Size)
				love.graphics.setColor(0.3,0.3,0.3)
				love.graphics.rectangle('line', (x-1)*Size, (y-1)*Size, Size, Size)
				love.graphics.setColor(0,0,0)
				love.graphics.print (#cell.options, (x-1)*Size, (y-1)*Size)
				love.graphics.print ((table.concat(cell.options,' ')), (x-1)*Size, (y-1)*Size+14)
			end
			
		end
	end
	
--	love.graphics.setColor(1,1,1)
--	for i = #Logs, 1, -1 do
--		love.graphics.print (Logs[i], 20, i*20)
--	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "space" then
		autoupdate()
	--	the lowest entropy and one neighbour of them
		local bestCell = getBestCells ()
		local options = bestCell.options
		table.remove (options, love.math.random(#options))
	elseif key == "a" then
		autoupdate()
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