-- License CC0 (Creative Commons license) (c) darkfrei, 2022


-- HSV to RGB
min = math.min
max = math.max
abs = math.abs

local function HSV2RGB (h, s, v)
	local k1 = v*(1-s)
	local k2 = v - k1
	local r = min (max (3*abs (((h	    )/180)%2-1)-1, 0), 1)
	local g = min (max (3*abs (((h	-120)/180)%2-1)-1, 0), 1)
	local b = min (max (3*abs (((h	+120)/180)%2-1)-1, 0), 1)
--	return r, g, b
--	return k1+k2*r, k1+k2*g, k1+k2*b
	return (k1+k2*r)^0.5, (k1+k2*g)^0.5, (k1+k2*b)^0.5
end


function love.load()
	width, height = love.graphics.getDimensions( )
	
	love.graphics.setLineStyle( 'rough' )
	love.graphics.setLineWidth(1)


	canvas = love.graphics.newCanvas ()
	love.graphics.setCanvas(canvas)
		for x = 0, width do
			love.graphics.setColor (HSV2RGB (x, 1, 1))
			love.graphics.line (x, 1, x, height)
		end
	love.graphics.setCanvas()
end

 
function love.update(dt)
	
end


function love.draw()
	love.graphics.setColor (1,1,1)
	love.graphics.draw (canvas)
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