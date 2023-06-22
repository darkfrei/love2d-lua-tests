-- License CC0 (Creative Commons license) (c) darkfrei, 2023

--local tpSet = require ('tpSet2')
local tpSet = require ('tpSet4')

love.window.setMode(1280, 800) -- Steam Deck resolution
love.window.setTitle('tpSet4')

function love.load()
	local setSide = tpSet.side
	local setVertices = tpSet.vertices
	local setPolygons = tpSet.polygons
	
	PolygonList = {}
	local x00, y00 = 10, 30 
	local x0, y0 = x00, y00
	local gridSize = 69

	for i, setPolygon in ipairs (setPolygons) do
		local vertices = {}
		for j, vertexIndex in ipairs (setPolygon) do
			local x1, y1 = setVertices[vertexIndex][1], setVertices[vertexIndex][2]
--			print (i, j, x1, y1)
			x1 = x0 + x1*gridSize/setSide
			y1 = y0 + y1*gridSize/setSide
			
--			print (i, j, x1, y1)
			table.insert (vertices, x1)
			table.insert (vertices, y1)
			
			
		end
		table.insert (PolygonList, vertices)
		x0 = x0 + gridSize + 10
		if (x0 + gridSize > love.graphics.getWidth ()) 
--			or #PolygonList == 7 
--			or #PolygonList == 12 
--			or #PolygonList == 17 
--			or #PolygonList == 23
--			or #PolygonList == 28 
			then
--			x0 = x00 + gridSize + 10
			x0 = x00
			y0 = y0 + gridSize + 10
		end
	end
	
end

 
function love.update(dt)
	
end


function love.draw()
	love.graphics.print ('tpSet4', 0, 0)
	love.graphics.setLineWidth (2)
	for i, vertices in ipairs (PolygonList) do
		love.graphics.polygon ('line', vertices)
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end