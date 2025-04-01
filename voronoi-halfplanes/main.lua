-- main.lua

-- set the window title
love.window.setTitle('Voronoi lib halfplanes method')

-- require the Voronoi module
local Voronoi = require("Voronoi")

-- create a new Voronoi diagram object
local diagram = Voronoi:newDiagram()

-- initialize the diagram when the game starts
function love.load()
	-- define a custom bounding polygon
	local customPolygon = {150, 100, 750, 200, 700, 550, 100, 550}
	diagram:setBoundingPolygon(customPolygon)

	-- add sites to the diagram
	diagram:addSite(200, 200)
	diagram:addSite(400, 200)
	diagram:addSite(500, 200)
	diagram:addSite(600, 200)
	diagram:addSite(200, 400)
	diagram:addSite(300, 300)
	diagram:addSite(700, 300)
	diagram:addSite(400, 400)
	diagram:addSite(400, 500)
	diagram:addSite(500, 500)
	diagram:addSite(500, 400)
	diagram:addSite(600, 400)

	-- add a site outside the bounding polygon (for testing purposes)
	diagram:addSite(100, 200)

	-- update the diagram to generate Voronoi cells
	diagram:update()
end

-- handle mouse input
function love.mousepressed(mx, my, button)
	-- left mouse button adds a new site at the mouse position
	if button == 1 then
		diagram:addSite(mx, my)
		diagram:update()

		-- right mouse button removes a site
	elseif button == 2 then
		local index, cell = diagram:getCell(mx, my)
		if index then
			-- remove the site corresponding to the clicked cell
			diagram:removeSiteByIndex(index)
		else
			-- if no cell is clicked, remove the last site
			diagram:removeLastSite()
		end
		diagram:update()

		-- middle mouse button modifies the last vertex of the bounding polygon
	elseif button == 3 then
		local i = #diagram.boundingPolygon - 1
		diagram.boundingPolygon[i] = mx
		diagram.boundingPolygon[i + 1] = my

		-- update the diagram after modifying the bounding polygon
		diagram:update()
	end
end

-- draw the Voronoi diagram and interactive elements
function love.draw()
	-- draw the bounding polygon
	love.graphics.setColor(1, 1, 1, 0.2) -- semi-transparent white fill
	diagram:drawBoundingPolygon('fill')
	love.graphics.setColor(1, 1, 1) -- white outline
	diagram:drawBoundingPolygon('line')

	-- draw the Voronoi cells
	love.graphics.setColor(0, 1, 0, 0.3) -- green with transparency for cells
	diagram:drawCells('fill')
	love.graphics.setColor(0, 1, 0) -- green outline for cells
	diagram:drawCells('line')

	-- draw the sites
	love.graphics.setColor(0, 1, 0) -- green color for sites
	diagram:drawSites('fill', 5)

	-- highlight the cell under the mouse cursor
	local mx, my = love.mouse.getPosition()
	local index, cell = diagram:getCell(mx, my)
	if index then
		love.graphics.setColor(1, 1, 1, 0.6) -- semi-transparent white fill
		diagram:drawCell(index, 'fill')
		love.graphics.setColor(1, 1, 1, 1) -- solid white outline
		diagram:drawCell(index, 'line')

		love.graphics.setColor(1, 1, 1, 1) -- solid white circle for the site
		diagram:drawSite(index, 'fill', 5)
	end
end