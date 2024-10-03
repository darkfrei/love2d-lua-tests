-- voronoi for closed polygon
local VP = require ('voronoi-polygon')

local flatPolygon = {100,50, 700,150, 400,500, 50,250}

local flatSites = {200, 200, 300, 300, 300, 220}


local diagram = VP.newDiagram (flatPolygon, flatSites, "diagram-1")

local nSteps = 0


function love.draw ()
	love.graphics.setColor (1,1,1)
	love.graphics.setLineWidth (1)
	VP.drawFlatPolygon (diagram)
	VP.drawSites (diagram, 2)

	love.graphics.setLineWidth (3)
	VP.drawUpperBoundary (diagram)

	love.graphics.setLineWidth (1)
	love.graphics.setColor (0,1,0)
	VP.drawBeachline (diagram, 2)
	
	love.graphics.setLineWidth (1)
	love.graphics.setColor (1,1,1)
	VP.drawSweepline (diagram)
end

function love.keypressed (key, scancode)
	if key == 'escape' then
		love.event.quit()
	end

	nSteps = nSteps + 1
	print ('----------------------------')
	print ('---------- step '.. nSteps ..' ----------')
	print ('----------------------------')
	VP.step (diagram)
	love.window.setTitle (nSteps)


end