local HalfPlanesLib = require ('HalfPlanesLib')


-- Пример использования
local halfPlane = HalfPlanesLib:new({x = 200, y = 300}, -2, 1)
local halfPlane2 = HalfPlanesLib:new({x = 300, y = 200}, 1, -6)
local pointIntersection = halfPlane:getIntersectionPoint(halfPlane2)

local testPoint = {x = 4, y = 5}
local isInside = halfPlane:contains(testPoint)
print("Point inside the half-plane:", isInside)



function love.draw ()
	halfPlane:draw (10, 10, 780, 580)
	halfPlane2:draw (10, 10, 780, 580)
	
	if pointIntersection then
		love.graphics.circle ('line', pointIntersection.x, pointIntersection.y, 5)
	end
end

function love.mousemoved (x, y)
	local point = {x=x, y=y}
	if halfPlane:contains(point) and halfPlane2:contains(point) then
		love.window.setTitle ('full inside')
	elseif halfPlane:contains(point) or halfPlane2:contains(point) then
		love.window.setTitle ('partially inside/outside')
	else
		love.window.setTitle ('full outside')
	end
end

function love.keypressed (k, s)
	if k == 'escape' then
		love.event.quit ()
	end
	print (k)
end
