function love.load()
	
end
 
 
function love.update(dt)
	
end
 
 
function love.draw()
	local touches = love.touch.getTouches( )
	for i, id in pairs (touches) do
		local pressure = love.touch.getPressure( id )
		love.graphics.print('i: '..i..' pressure: '..pressure, 32, 32+20*i)
	end
end
