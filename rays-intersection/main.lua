-- License CC0 (Creative Commons license) (c) darkfrei, 2023

love.window.setMode(1280, 800) -- Steam Deck resolution
Width, Height = love.graphics.getDimensions( )

local function findIntersection (x1, y1, x2, y2, x3, y3, x4, y4)
--    local x1, y1 = ray1.origin.x, ray1.origin.y
--    local x2, y2 = ray1.direction.x, ray1.direction.y
--    local x3, y3 = ray2.origin.x, ray2.origin.y
--    local x4, y4 = ray2.direction.x, ray2.direction.y

	local denominator = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
	if denominator == 0 then
		return nil -- Лучи параллельны или совпадают
	end

	local t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denominator
	local u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denominator

	if t >= 0 and u >= 0 then
		local intersectionX = x1 + t * (x2 - x1)
		local intersectionY = y1 + t * (y2 - y1)
		return intersectionX, intersectionY
	end

	return nil -- Нет пересечения или пересечение за пределами луча
end


function love.load()
	Ray1 = {x=100,y=100, angle = 0, mode = 'line'}
	Ray1.x2 = Ray1.x + 400*math.cos (Ray1.angle)
	Ray1.y2 = Ray1.y + 400*math.sin (Ray1.angle)

	Ray2 = {x=300,y=500, angle = 0, mode = 'line'}
	Ray2.x2 = Ray2.x + 400*math.cos (Ray2.angle)
	Ray2.y2 = Ray2.y + 400*math.sin (Ray2.angle)

	Intersection = nil
end


function love.update(dt)

end


function love.draw()
	love.graphics.setColor (1,0,0)
	local x1, y1 = Ray1.x, Ray1.y
	local x2, y2 = Ray1.x2, Ray1.y2
	love.graphics.line (x1, y1, x2, y2)
	love.graphics.circle (Ray1.mode, x1, y1, 6)
	love.graphics.setColor (1,1,0)

	local x3, y3 = Ray2.x, Ray2.y
	local x4, y4 = Ray2.x2, Ray2.y2
	love.graphics.line (x3, y3, x4, y4)
	love.graphics.circle (Ray2.mode, x3, y3, 6)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	Ray2.x = x
	Ray2.y = y
end

function love.mousemoved( x, y, dx, dy, istouch )
	Ray2.angle = math.atan2 (y-Ray2.y, x-Ray2.x)

	Ray2.x2 = Ray2.x + 400*math.cos (Ray2.angle)
	Ray2.y2 = Ray2.y + 400*math.sin (Ray2.angle)

	local x1, y1 = Ray1.x, Ray1.y
	local x2, y2 = Ray1.x2, Ray1.y2
	local x3, y3 = Ray2.x, Ray2.y
	local x4, y4 = Ray2.x2, Ray2.y2
	local ix, iy = findIntersection (x1, y1, x2, y2, x3, y3, x4, y4)

	if ix then
		if math.abs(Ray1.x - ix) > 1 and math.abs(Ray2.y - iy) > 1 then
			Ray1.x2 = ix
			Ray1.y2 = iy
		end
	end
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end