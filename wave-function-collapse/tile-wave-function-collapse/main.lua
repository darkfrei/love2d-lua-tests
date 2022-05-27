-- License CC0 (Creative Commons license) (c) darkfrei, 2022

-- idea based on https://youtu.be/6Vag7NJUjJo
-- Wave Function Collapse Take 2

table.unpack = table.unpack or unpack -- back
love.window.setMode(768, 768, {resizable=true, borderless=false})
Width, Height = love.graphics.getDimensions( )
Font = love.graphics.getFont()

wfc = require ('wave-function-collapse')

function love.load()
	
	wfc.tiles = {}

	wfc.dim = 12 -- cells
	wfc.size = math.floor(math.min(Width, Height)/wfc.dim) -- pixels per one cell

	wfc:load()
	
	local blankCanvas = wfc.newImage ("blank")
	blankCanvas:newImageData():encode("png","blank.png")
	local TCanvas = wfc.newImage ("T")
	TCanvas:newImageData():encode("png","T-block.png")
	local LCanvas = wfc.newImage ("L")
	LCanvas:newImageData():encode("png","L-block.png")
	local iCanvas = wfc.newImage ("i")
	iCanvas:newImageData():encode("png","i-block.png")
	
	table.insert (wfc.tiles, wfc.newTile (blankCanvas, {0,0,0,0}))
	
	local tTile1 = wfc.newTile (TCanvas, {0,1,1,1})
	table.insert (wfc.tiles, tTile1)
	local tTile2 = wfc.newRotatedTile (tTile1)
	table.insert (wfc.tiles, tTile2)
	local tTile3 = wfc.newRotatedTile (tTile2)
	table.insert (wfc.tiles, tTile3)
	local tTile4 = wfc.newRotatedTile (tTile3)
	table.insert (wfc.tiles, tTile4)

	
	local lTile1 = wfc.newTile (LCanvas, {1,1,0,0})
	table.insert (wfc.tiles, lTile1)
	local lTile2 = wfc.newRotatedTile (lTile1)
	table.insert (wfc.tiles, lTile2)
	local lTile3 = wfc.newRotatedTile (lTile2)
	table.insert (wfc.tiles, lTile3)
	local lTile4 = wfc.newRotatedTile (lTile3)
	table.insert (wfc.tiles, lTile4)
	
	local iTile1 = wfc.newTile (iCanvas, {0,0,1,0})
	table.insert (wfc.tiles, iTile1)
	local iTile2 = wfc.newVFlippedTile (iTile1) -- up is down
	table.insert (wfc.tiles, iTile2)
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
				
				if #options == 0 then
					nextGrid[y][x] = {
						x=x, y=y, 
						options=options, 
						collapsed = true,
						index = 5
					}
					updated = true
				elseif #options == 1 then
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


--	wfc:draw ()
	wfc:drawTiles ()
	
	
	
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
		if bestCell then
			local options = bestCell.options
			table.remove (options, love.math.random(#options))
		end
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