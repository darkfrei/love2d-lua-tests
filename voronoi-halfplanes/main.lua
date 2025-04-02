-- main.lua

-- set the window title
love.window.setTitle('Voronoi lib halfplanes method')

-- require the Voronoi module
local Voronoi = require("voronoi")

-- create a new Voronoi diagram object
local diagram = Voronoi:newDiagram()

-- initialize the diagram when the game starts
function love.load()
	-- define a custom bounding polygon
	local customPolygon = {150, 100, 750, 200, 700, 550, 100, 550}
	diagram:setBoundingPolygon(customPolygon)

	-- add sites to the diagram
	diagram:addSite(200, 200)
	diagram:addSite(600, 200)
	diagram:addSite(400, 400)
	diagram:addSite(400, 400) -- will be ignored


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
	love.graphics.setLineWidth (2)
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


	love.graphics.setColor(0, 0, 1)
	diagram:drawVertices('fill', 3)

	-- highlight the cell under the mouse cursor
	local mx, my = love.mouse.getPosition()
	local indexCell, cell = diagram:getCell(mx, my)
	local indexEdge, edge = diagram:getEdge(mx, my)
	local indexVertex, vertex = diagram:getVertex(mx, my)

	if indexVertex then
		love.graphics.setColor(1, 1, 1)
		love.graphics.circle ('fill', vertex.x, vertex.y, 10)
		
		-- highlight cells
		local cells = vertex.cells
		love.graphics.setColor(1, 1, 1, 0.2)
		for i, cell in ipairs (cells) do
			love.graphics.polygon ('fill', cell.polygon)
		end
		
		-- highlight edges
		local edges = vertex.edges
		love.graphics.setColor(1, 1, 1, 0.6)
		love.graphics.setLineWidth (3)
		for i, edge in ipairs (edges) do
			love.graphics.line (edge.v1.x, edge.v1.y, edge.v2.x, edge.v2.y)
		end
	elseif indexEdge then
		love.graphics.setColor(1, 1, 1)
		love.graphics.setLineWidth (6)
		love.graphics.line (edge.v1.x, edge.v1.y, edge.v2.x, edge.v2.y)
		local cells = edge.cells
		love.graphics.setColor(1, 1, 1, 0.4)
		for i, cell in ipairs (cells) do
			love.graphics.polygon ('fill', cell.polygon)
		end
	elseif indexCell then
		love.graphics.setColor(1, 1, 1, 0.4) -- semi-transparent white fill
		diagram:drawCell(indexCell, 'fill')
		
		love.graphics.setColor(1, 1, 1, 0.8) -- solid white outline
		diagram:drawCell(indexCell, 'line')

		love.graphics.setColor(1, 1, 1, 1) -- solid white circle for the site
		diagram:drawSite(indexCell, 'fill', 5)
	end
end

function love.keypressed(key)
	if key == "c" and love.keyboard.isDown("lctrl") then
		-- export the graph to clipboard
		diagram:exportGraphToClipboard()
	end
end