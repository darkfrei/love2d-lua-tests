local VoronoiHP = require ('voronoi-half-planes')

love.window.setMode (900, 600)

function love.load ()
	width, height = love.graphics.getDimensions ()
	width, height = width/3, height/3
	
	love.window.setTitle (width ..' '.. height)

	PlaneHP = VoronoiHP:newToroidalPlane(width, height)
	
	local points = {21,20, 297,150, 106,48, 276,75, 55,88, 54,170, 126,165, 169,55, 190,195, 128,106, 192,114, 231,37}
	
	for i = 1, #points, 2 do
		PlaneHP:addSite(points[i], points[i+1])
	end

--	for i = 1, 10 do
--		local x = 10 + (width-20)*math.random ()
--		local y = 10 + (height-20)*math.random ()
--		PlaneHP:addSite(x, y)
--	end

--	PlaneHP:addSite(30, 30)
--	PlaneHP:addSite(200, 40)
--	PlaneHP:addSite(120, 180)

	PlaneHP:updateVertices()
end


function love.draw ()
	love.graphics.translate (width, height)

	love.graphics.setColor (0.3,0.3,0.3)
	love.graphics.rectangle ('fill', 0,0,width, height)

	love.graphics.setPointSize (3)



	for i, cell in ipairs (PlaneHP.cells) do
		love.graphics.setColor (1,1,1)
		love.graphics.circle ('line', cell.site.x, cell.site.y, 4)
		love.graphics.polygon ('line', cell.polygon)

--		for j = 1, #cell.polygon-3, 2 do
--			love.graphics.line (cell.polygon[i], cell.polygon[i+1], cell.polygon[i+2], cell.polygon[i+3])
--		end

--		love.graphics.setColor (1,1,0)
--		for j = 1, #cell.polygon-1, 2 do
--			love.graphics.points (cell.polygon[i], cell.polygon[i+1])
----			print (cell.polygon[i], cell.polygon[i+1])
--		end

	end

	love.graphics.setColor (1,1,1)
	love.graphics.points (PlaneHP.virtualSites)

--	for i, cell in ipairs (VoronoiHP.cells) do
--		love.graphics.setColor (0,1,0)
--		love.graphics.points (cell.site.x, cell.site.y)
--	end

end

function love.mousemoved (x, y)

end

function love.keypressed (k, s)
	if k == 'escape' then
		love.event.quit ()
	end
	print (k)
end
