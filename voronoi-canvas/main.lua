-- the simplest way to do the voronoi

love.window.setTitle ('Voronoi Canvas - Love2D, made by darkfrei')

local function generateVoronoiCanvas (cells, width, height)
	local function dot(ax, ay, bx, by)
		return ax*bx + ay*by
	end

	local function normalize(vx, vy)
		local length = math.sqrt(vx*vx + vy*vy)
		return vx/length, vy/length
	end

	local points = {}
	local canvas = love.graphics.newCanvas(width, height)
	love.graphics.setCanvas(canvas)

	-- draw color fields
	for y = 1, height do
		for x = 1, width do
			local dmin, dmin2 = math.huge, math.huge
			local site1x, site1y
			local site2x, site2y
			local color = {0,0,0}
			for i, cell in ipairs (cells) do
				local d = (cell.siteX-x)^2+(cell.siteY-y)^2
				if d < dmin then
					dmin2 = dmin
					site2x, site2y = site1x, site1y
					dmin = d
					color = cell.color
					site1x, site1y = cell.siteX, cell.siteY
				elseif d < dmin2 then
					dmin2 = d
					site2x, site2y = cell.siteX, cell.siteY
				end
			end

			local ax, ay = site1x-x, site1y-y
			local bx, by = site2x-x, site2y-y
			local nbx, nby = normalize(site2x-site1x, site2y-site1y)
			local d = dot(ax+bx, ay+by, nbx, nby)
			if d < 4 then
				color = {0,0,0}
			end
			table.insert (points, {x, y, color[1], color[2], color[3]})
		end
	end
	love.graphics.setColor(1, 1, 1)
	love.graphics.points(points)

	--draw sites
	for i, cell in ipairs (cells) do
		love.graphics.setColor(0, 0, 0)
		love.graphics.circle ('fill', cell.siteX-0.5, cell.siteY-0.5, 1.5)
		love.graphics.setColor(1, 1, 1)
		love.graphics.points(cell.siteX, cell.siteY)
	end

	love.graphics.setCanvas()
	return canvas
end

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
	local number_cells = 50 --the number of cells we want in our diagram
	--draw the voronoi diagram to a canvas
	local width, height = love.graphics.getWidth(), love.graphics.getHeight()
	local cells = createCells (number_cells, width, height)
	voronoiCanvas = generateVoronoiCanvas (cells, width, height)
end

--RENDER
function love.draw()
	--reset color
	love.graphics.setColor({ 1, 1, 1 })
	--draw diagram
	love.graphics.draw(voronoiCanvas)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

