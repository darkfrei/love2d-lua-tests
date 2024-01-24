local voronoilib = require ('voronoilib')

--voronoilib_getEdges
--https://github.com/TomK32/iVoronoi/blob/working/tests/voronoilib_getEdges/main.lua


function love.load( arg )
	local width, heigth = love.graphics.getDimensions ()

	drawlist = { }
	
	activatedPolygons = { } -- hash

	-- polygoncount,iterations,minx,miny,maxx,maxy
	local polygoncount = 12
	local iterations = 10
	local minx,miny = 25, 25
	local maxx,maxy = width-50, heigth-50

	vDiagram = voronoilib:new(polygoncount, iterations,minx,miny, maxx,maxy)
end



function drawPolygon (polygon)
	if #polygon.points >= 6 then
		if activatedPolygons[polygon.index] then 
			love.graphics.setColor (0.2,0.6,0.2) 
		else 
			love.graphics.setColor (0.3, 0.3, 0.3) 
		end
		love.graphics.polygon('fill', polygon.points)
		love.graphics.setColor (0.5,0.5,0.5)
		love.graphics.polygon('line', polygon.points)
		if activatedPolygons[polygon.index] then 
			love.graphics.setColor(1,0,0) 
		end
		love.graphics.setColor (1,1,1)
		love.graphics.circle ('line', polygon.centroid.x,polygon.centroid.y, 2)

		love.graphics.print(polygon.index,polygon.centroid.x,polygon.centroid.y)
	end
end

function love.draw()

	for index,polygon in pairs(vDiagram.polygons) do
		drawPolygon (polygon)
	end

	love.graphics.setColor (1,1,1)
	
	for j,k in pairs (vDiagram:getEdges(edgemode, drawlist)) do
		love.graphics.line(k)
	end

end

function love.update()

end

function love.mousepressed(x,y,button)
	local polygon = vDiagram:polygoncontains(x,y)
	if polygon ~= nil then
		if activatedPolygons[polygon.index] == true then activatedPolygons[polygon.index] = nil else activatedPolygons[polygon.index] = true end
	end
end


function love.keypressed(key,scancode)

	if key == 'escape' then love.event.quit() end

end