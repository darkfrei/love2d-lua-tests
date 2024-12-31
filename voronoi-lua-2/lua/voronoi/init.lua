print ('loaded', ...)
-- lua/voronoi/init.lua

local utils = require("voronoi.utils")
local diagram = require("voronoi.diagram")
local events = require("voronoi.events")
local beachline = require("voronoi.beachline")
local sites = require("voronoi.sites")
local cells = require("voronoi.cells")


local voronoi = {}
voronoi.__index = voronoi  -- set the __index for the metatable


-- Creates a new Voronoi object and initializes its components
function voronoi.new()
	local self = setmetatable({}, voronoi)  -- create a new object and set the metatable

	-- Initialize components
	self.events = events.newQueue()  -- event queue
	self.diagram = diagram.new()    -- Voronoi diagram
	self.beachline = beachline.new()  -- beachline
	self.sweepLineY = nil  -- current position of the sweep line

	return self
end


function voronoi:addPolygon(polygon)
-- adds the polygon as a boundary to the diagram
	self.diagram:addPolygon(polygon)

end


function voronoi:addSite(site)

	-- [add the site to the diagram] — add the site to the Voronoi diagram
	self.diagram:addSite(site) -- object {x=x, y=y}

	-- [add the site event to the event queue] — add event to the event queue
	self.events:newSiteEvent(site) -- object {x=x, y=y}
end


function voronoi:addSites(sites)
	-- [add multiple sites] — iterates through the list of sites and adds them one by one

	for _, site in ipairs(sites) do
		self:addSite(site) -- object {x=x, y=y}
	end
end


-----------------------------------



-- processes all events in the event queue
-- processes each event to update the beach line and the diagram
function voronoi:processEvents()
	local indexEvent = 1
	while not self.events:isEmpty() do
		local event = self.events:pop()
		print (' ')
		print ('#####voronoi:processEvents', 'indexEvent: '..indexEvent)
		indexEvent = indexEvent + 1
		
		local diagram = self.diagram
		
		event:process (self)

		-- test
		-- capture the current state of the beach line for debugging or rendering

		
		beachline:update(diagram, event.y)
		local currentBeachLine = self.beachline:getCurrentBeachLine (event.y)
		table.insert (diagram.renderinArcs, currentBeachLine)

	end

end

-----------------------

function voronoi:drawBoundaryPolygon(vertices)
	-- [set color for the polygon fill] — semi-transparent green
	love.graphics.setColor(0, 1, 0, 0.25)

	-- [draw the filled polygon] — if the polygon vertices are available
	love.graphics.polygon("fill", vertices)

	-- [set color for the polygon outline] — solid green
	love.graphics.setColor(0, 1, 0, 1)

	-- [draw the polygon outline] — if the polygon vertices are available
	love.graphics.polygon("line", vertices)
end

function voronoi:drawSites (sites)
-- draw all sites (white circles)
	love.graphics.setColor(1, 1, 1, 1)
	for i, site in ipairs(sites) do
		-- draw a small circle for the site:
		love.graphics.circle("fill", site.x, site.y, 5)
		love.graphics.print (i..' '..site.x ..' '.. site.y, site.x, site.y+5)
	end
end




function voronoi:drawRenderinArcs(renderinArcs)
	local amount = #renderinArcs
	for i, linesSet in ipairs (renderinArcs) do
		local c = i / amount
--		print (i, c)
		love.graphics.setColor (c,c,c,1)
		for j, line in ipairs (linesSet) do
			love.graphics.line (line)
		end
	end

end


function voronoi:draw()
	-- example how to draw it
	-- [drawing the polygon and the diagram] 
	-- calling the drawPolygon method to render the polygon
	self:drawBoundaryPolygon(self.diagram.polygonVertices)


	self:drawSites(self.diagram.sites)

	self:drawRenderinArcs(self.diagram.renderinArcs)

end


return voronoi
