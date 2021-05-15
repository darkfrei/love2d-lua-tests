window = require ("zoom-and-move-window")

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
	window:load()
	
	


end
 
-- Increase the size of the rectangle every frame.
function love.update(dt)
	window:update(dt)
	
	
end

local text = ""
scale = 1
dscale = 2^(1/6)
print (dscale)

tx = 0
ty = 0
 
mouse_pressed  = false


 
function love.draw()
	window:draw()


	-- B-ring
	love.graphics.setColor( 1, 1, 1, 1 )
	love.graphics.line(line)

	-- green point
	love.graphics.setColor( 0, 1, 0, 1 )
	love.graphics.circle( "line", 542, 113, 2 )
	
	-- red point
	love.graphics.setColor( 1, 0, 0, 1 )
	love.graphics.circle( "line", 323, 323, 2 )
	
	
	love.graphics.setColor( 1, 1, 1, 1 )
	
end


function love.mousepressed(x, y, k)
	window:mousepressed(x, y, k)
end

 
function love.wheelmoved(x, y)
	window:wheelmoved(x, y)
end


function love.mousepressed(x, y, button, istouch)
	window:mousepressed(x, y, k)
end

