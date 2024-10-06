-- voronoi for closed polygon
local VP = require ('voronoi-polygon')

local flatPolygon = {50,50, 700,150, 300,500}

local flatSites = {300, 200}


local diagram = VP.newDiagram (flatPolygon, flatSites, "diagram-1")

local nSteps = 0


function love.draw ()
	love.graphics.setColor (1,1,1)
	love.graphics.setLineWidth (1)
	VP.drawFlatPolygon (diagram)
	VP.drawPolygon (diagram, 2)
	VP.drawSites (diagram, 2)

	love.graphics.setLineWidth (3)
	VP.drawUpperBoundary (diagram)

	love.graphics.setLineWidth (1)
	love.graphics.setColor (1,1,1)
	VP.drawBeachline (diagram, 2)

	love.graphics.setLineWidth (1)
	love.graphics.setColor (1,1,1)
	VP.drawSweepline (diagram)
end

function love.keypressed (key, scancode)
	if key == 'escape' then
		love.event.quit()
	end

	if diagram.eventQueue and #diagram.eventQueue > 0 then
		nSteps = nSteps + 1
		print ('----------------------------')
		print ('---------- step '.. nSteps ..' ----------')
		print ('----------------------------')
		VP.step (diagram)
		love.window.setTitle (nSteps..' eventQueue: ' .. #diagram.eventQueue)
	end

end