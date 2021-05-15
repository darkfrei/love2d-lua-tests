-- Load some default values for our rectangle.
local line = require ("line")
local nl = string.char(10)
local str = "return {" .. nl

for i = #line, 1, -2 do

	str = str .. (math.floor(line[i]+0.5)) .. ', '
	str = str .. (math.floor(line[i-1]+0.5)) .. ', '
	str = str .. nl
end
str = str .. "}"
--print (love.filesystem.append( "D:/Lua/output/new_line.lua", str))
print (love.filesystem.write( "new_line.lua", str))


function love.load()
    	
		
	vertices = {50, 50, 400, 800, 200, 50, 400, 500}
	curve = love.math.newBezierCurve( vertices )
	
	coordinates = {}
	for t = 0, 1, 0.1 do
		local x, y = curve:evaluate(t)
		table.insert (coordinates, x)
		table.insert (coordinates, y)
	end

end
 
-- Increase the size of the rectangle every frame.
function love.update(dt)
    
   -- local x, y = love.mouse.getPosition() -- get the position of the mouse
	
end

local text = ""
scale = 1
dscale = 2^(1/6)
print (dscale)

tx = 0
ty = 0
 
mouse_pressed  = false


 
function love.draw()
	mx = love.mouse.getX()
	my = love.mouse.getY()
	if love.mouse.isDown(1) then
		if not mouse_pressed then -- click
			mouse_pressed = true
			dx = tx-mx
			dy = ty-my
		else
			tx = mx + dx
			ty = my + dy
		end
	else	-- left mouse not pressed
		if mouse_pressed then 
			mouse_pressed = false
		end
	end
	
	love.graphics.push( )

	
	
	love.graphics.scale(scale, scale)
	
	love.graphics.translate(tx/scale, ty/scale)
	--love.graphics.scale(scale, scale)
	
	
	love.graphics.setColor( 1, 1, 1, 1 )
	
	love.graphics.print('0 ' .. tx .. ' ' .. ty, 0, 0)
	
	love.graphics.print('m ' .. mx .. ' ' .. my, (mx+10-tx)/scale, (my-10-ty)/scale)
	
	
	love.graphics.setColor( .5, .5, 1, 1 )
	love.graphics.circle( "line", 0, 0, 400 )
	love.graphics.line(-440, 0, 440, 0)
	love.graphics.line(0, -440, 0, 440)

	-- B-ring
	love.graphics.setColor( 1, 1, 1, 1 )
	love.graphics.line(line)

	-- green point
	love.graphics.setColor( 0, 1, 0, 1 )
	love.graphics.circle( "line", 542, 113, 2 )
	
	-- red point
	love.graphics.setColor( 1, 0, 0, 1 )
	love.graphics.circle( "line", 323, 323, 2 )
	
	
	love.graphics.pop()
	love.graphics.setColor( 1, 1, 1, 1 )
	love.graphics.print('scale ' .. scale, 10, 10)
	love.graphics.print('t ' .. tx .. ' ' .. ty, 10, 20)
	love.graphics.print('m  ' .. mx .. ' ' .. my, 10, 30)
	love.graphics.print('m0 ' .. mx-tx .. ' ' .. my-ty, 10, 40)
	
end



function love.mousepressed(x, y, button, istouch)
   if button == 2 then
		tx = 0
		ty = 0
		scale = 1
   end
end


function love.wheelmoved(x, y)
    if y > 0 then -- mouse wheel moved up
		tx = (mx-tx/scale)*(1/scale - dscale)
		ty = (my-ty/scale)*(1/scale - dscale)
		scale = scale * dscale
    elseif y < 0 then -- mouse wheel moved down
		tx = (mx-tx/scale)*(1/scale - dscale)
		ty = (my-ty/scale)*(1/scale - dscale)
		scale = scale / dscale
    end
end
