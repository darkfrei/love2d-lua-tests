print ('loaded', ...)
-- lua/voronoi/init.lua

local voronoi = {}

-- require modules

voronoi.utils = require("lua.voronoi.utils")
voronoi.diagram = require("lua.voronoi.diagram")
voronoi.eventQueue = require("lua.voronoi.eventQueue")

voronoi.beachLine = require("lua.voronoi.beachLine")

voronoi.sites = require("lua.voronoi.sites")
voronoi.cells = require("lua.voronoi.cells")


-- generate voronoi diagram
function voronoi.generate(siteCoordinates, boundingPolygon)
    assert(boundingPolygon and type(boundingPolygon) == "table", "Error: boundingPolygon is required and must be a table.")
    
    -- create sites from the input coordinates and bounding polygon
    local sites = voronoi.sites.new(siteCoordinates, boundingPolygon)
    
    -- create cells based on the sites
    local cells = voronoi.cells.new(sites)
    
    -- create diagram with cells and sites
    local diagram = voronoi.diagram.new(cells, sites)
    
    -- create an event queue for processing site and circle events
    local eventQueue = voronoi.eventQueue.new(sites)
    local beachLine = voronoi.beachLine.new()
    eventQueue.boundingPolygon = boundingPolygon  -- set the bounding polygon

    -- set the bounding polygon in the diagram
    diagram:setBoundingPolygon(boundingPolygon)

    -- return the unprocessed diagram with eventQueue and beachLine
    diagram.eventQueue = eventQueue
    diagram.beachLine = beachLine

    return diagram
end


return voronoi
