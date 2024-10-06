-- voronoi for closed polygon
-- This script initializes a module for handling Voronoi diagrams in closed polygons.


print ('loaded', ...)
local utils = require ('utils')

local VP = {}

function VP.newDiagram (flatPolygon, flatSites, name)
	-- convert input to points {x=x, y=y}
	local polygon = utils.newPolygon (flatPolygon)

	local sites = utils.newSites (flatSites)
	
	local diagram = {polygon=polygon, 
		flatPolygon=flatPolygon, 
		name = name,
		sites=sites
		}


	-- vertices: List of crossing points (intersections) on the edges of the Voronoi cells
	-- Each vertex contains coordinates and references to its edges and cells
	-- {x=x1, y=y1, edges = {}, cells = {}}
	diagram.vertices = {}

	-- edges: List of crossing edges that form the boundaries between Voronoi cells
	-- Each edge connects vertices and separates two cells
	-- {vertices = {}, cells = {}}
	diagram.edges = {}

	-- cells: Each cell represents a Voronoi region centered at a site
	-- The cells contain references to their vertices, edges, and neighboring cells
	-- {site=site, vertices = {}, edges = {}, neighbourCells = {}}
	diagram.cells = utils.newCells (sites)


	diagram.beachLine = utils.newBeachLine (diagram)

	diagram.eventQueue = utils.newEventQueue (diagram)

--	utils.processMain (diagram)

	return diagram
end


--------------------------------------------------------------------
-- draw ------------------------------------------------------------------
--------------------------------------------------------------------


function VP.drawFlatPolygon (diagram)
	love.graphics.polygon ('line', diagram.flatPolygon)
end

function VP.drawPolygon (diagram, r)

	for i, p in ipairs (diagram.polygon) do
		love.graphics.circle ('line', p.x, p.y, r)
		love.graphics.print (p.index, p.x, p.y)
	end
end

function VP.drawSites (diagram, r)
	for i, site in ipairs (diagram.sites) do
		love.graphics.circle ('line', site.x, site.y, r)
		love.graphics.print (site.index, site.x, site.y)
	end
end

function VP.drawUpperBoundary (diagram)
	local i = 1
	local p1x, p1y = diagram.upperBoundary[1].x, diagram.upperBoundary[1].y
	for j = 2, #diagram.upperBoundary do
		local p2x, p2y = diagram.upperBoundary[j].x, diagram.upperBoundary[j].y
		love.graphics.line (p1x, p1y, p2x, p2y)
		p1x, p1y = p2x, p2y
	end
end

local colors = {{1,0,0}, {1,1,0}, {0,1,0}, {0,1,1}, {0,0,1}, {1,0,1}}

function VP.drawBeachline (diagram)

	for i, segment in ipairs (diagram.beachLine) do
		local colorIndex = (i-1)%#colors+1
		love.graphics.setColor (colors[colorIndex])
		if segment.type == 'line' then
			local x1, y1 = segment.left.x, segment.left.y
			local x2, y2 = segment.right.x, segment.right.y
			love.graphics.line (x1, y1, x2, y2)
			love.graphics.circle ('line', x1, y1, 2)
			love.graphics.circle ('line', x2, y2, 3)
		else
			local x1, y1 = segment.left.x, segment.left.y
			local x2, y2 = segment.site.x, segment.site.y
			local x3, y3 = segment.right.x, segment.right.y
			love.graphics.line (x1, y1, x2, y2)
			love.graphics.line (x2, y2, x3, y3)
			if segment.renderedLine then
				love.graphics.line (segment.renderedLine)
			end
			if segment.controlPoints then
				love.graphics.line (segment.controlPoints)
			end
		end
	end

	for i, segment in ipairs (diagram.beachLine) do
		local x1, y1, index1 = segment.left.x, segment.left.y, segment.left.index
		local x2, y2, index2 = segment.right.x, segment.right.y, segment.right.index
		love.graphics.setColor (1,0,0)
		love.graphics.print (index1, x1+ 14 *((i+1)%2), y1)
		love.graphics.setColor (0,1,0)
		love.graphics.print (index2, x2+ 14 *((i)%2), y2+14)

	end
end

function VP.drawSweepline (diagram)
	if diagram.sweepLinePosition then
		love.graphics.line (0, diagram.sweepLinePosition, 800, diagram.sweepLinePosition)
	end
end

function VP.step (diagram)
	if diagram.eventQueue and #diagram.eventQueue > 0 then
		local event = table.remove (diagram.eventQueue, 1)

		local yEvent = event.yEvent
		if not (diagram.sweepLinePosition == yEvent) then
			utils.updateBeachLine (diagram, yEvent)
			diagram.sweepLinePosition = yEvent
		end

		event.execute(event)

		print ('beachLine after step:')
		for i, segment in ipairs (diagram.beachLine) do
			print (i, segment.left.x, segment.right.x, segment.type)
		end

	end
end

return VP
