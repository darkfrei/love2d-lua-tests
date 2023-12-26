local generateVoronoiCanvas = require ('voronoi-canvas')
local generateVoronoiCells = require ('voronoi-cells')


local function createCells (number_cells, width, height)
	local cells = {}
	for i = 1, number_cells do
		local cell = {
			siteX = math.random(0, width),
			siteY = math.random(0, height),
			color = {
				math.random ()/2+0.5,
				math.random ()/2+0.5,
				math.random ()/2+0.5,
			},
		}
		table.insert (cells, cell)
	end
	return cells
end

function love.load()
	local numberCells = 50
	local width, height = love.graphics.getWidth(), love.graphics.getHeight()
	local cells = createCells (numberCells, width, height)
	
	voronoiCanvas = generateVoronoiCanvas (cells, width, height)

	voronoiCells = generateVoronoiCells (cells, width, height)
end

local function drawCell (cell)
	local polygon = cell.polygon
	love.graphics.setColor (0,0,0)
	love.graphics.circle ('line', cell.siteX-0.5, cell.siteY-0.5, 4)
	
	
--	love.graphics.polygon ('fill', polygon)
--	love.graphics.setColor (1,1,1)
--	love.graphics.polygon ('line', polygon)

	-- draw vertex points
	love.graphics.setColor (1,1,1)
	for i, vertexPoint in ipairs (cell.vertexPoints) do
		love.graphics.line (cell.siteX, cell.siteY, vertexPoint.x, vertexPoint.y)
	end
end
	
local function drawCells (cells)
	for i, cell in ipairs (cells) do
		drawCell (cell)
	end
end

function love.draw()
	--reset color
	love.graphics.setColor({ 1, 1, 1 })
	--draw diagram
	love.graphics.draw(voronoiCanvas)

	drawCells (voronoiCells)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

