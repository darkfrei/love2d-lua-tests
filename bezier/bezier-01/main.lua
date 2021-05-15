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

tx = 0
ty = 0
 
mouse_pressed  = false

function love.wheelmoved(x, y)
	text = ""
    if y > 0 then
        text = "Mouse wheel moved up"
		scale = scale * dscale
--		love.graphics.scale(scale, scale)
    elseif y < 0 then
        text = "Mouse wheel moved down"
		scale = scale / dscale
--		love.graphics.scale(scale, scale)
    end
	text = text .. ' x: ' .. x .. ' y: ' .. y
	
end
 
function love.draw()
	local mx = love.mouse.getX()
	local my = love.mouse.getY()
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
	
--	first translate than scale:
	love.graphics.translate(tx, ty)
	love.graphics.scale(scale, scale)
	
	love.graphics.circle( "line", 0, 0, 400 )
	love.graphics.line(-440, 0, 440, 0)
	love.graphics.line(0, -440, 0, 440)
	
--	love.graphics.setColor( 0.2, 0.3, 0.5, 1 )
--    love.graphics.line(curve:render())
	
	love.graphics.setColor( 1, 1, 1, 1 )
	love.graphics.line(line)
	
--	love.graphics.setColor( 0, 1, 0, 1 )
--	love.graphics.print('v', mx+vx, my+vy)
--	love.graphics.line(mx, my, mx+vx, my+vy)
	
--	love.graphics.setColor( 1, 1, 0, 1 )
--	love.graphics.line(0, 0, mx, my, bx, by, tx, ty)

--	love.graphics.print('m', mx, my)
	
	
--	love.graphics.print('b', bx, by)
--	love.graphics.print('t', tx, ty)
	
--	love.graphics.print('mx: ' .. mx .. ' my: ' .. my, 10, 30)
--	love.graphics.print('bx: ' .. bx .. ' by: ' .. by, 10, 40)
--	love.graphics.print('tx: ' .. tx .. ' ty: ' .. ty, 10, 50)

	love.graphics.setColor( 0, 1, 0, 1 )
	love.graphics.circle( "line", 542, 113, 2 )
	
	
	local s = 323
	love.graphics.setColor( 1, 0, 0, 1 )
	love.graphics.circle( "line", s, s, 2 )
	
	

end



function love.mousepressed(x, y, button, istouch)
   if button == 2 then -- Versions prior to 0.10.0 use the MouseConstant 'l'
      tx = 0
      ty = 0
   end
end

--[[

function love.mousereleased(x, y, button)
   if button == 1 then
      tx = (x - mouse_set[1])*scale
      ty = (y - mouse_set[2])*scale
      
   end
end
]]

