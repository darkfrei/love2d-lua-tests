-- License CC0 (Creative Commons license) (c) darkfrei, 2021

local beep = require ('beep')
--local serpent = require ('serpent')

function normul (x, y, offset) -- normalization and multiplication
	local d = (x*x+y*y)^0.5
	offset = offset or 1
	return offset*x/d, offset*y/d
end



gs = require ('graph-solver')
local lines = require ('example')

--local nodes, roads = gs.create_nodes_and_roads (lines)
local nodes = gs.create_nodes (lines)
local roads = gs.create_roads (lines)
--print(serpent.block(roads))
print('roads: '..#roads)

arrows = {}
colors = {}


-- souces are hardcoded:
sources = {{x=60,y=320, color={1,0,0}},{x=60,y=360, color={0,1,0}},{x=60,y=400, color={0,0,1}}}

-- the target before it will be new selected:
target = {x=620, y=280}

function change_nearest_target (mx, my)
	local gap, ni, nx, ny = 30
	local sgap = gap*gap -- square gap
--	for i_point, point in pairs (points) do
	for i = 1, #nodes-1, 2 do
		local x, y = nodes[i], nodes[i+1]
		if (x-mx)^2+(y-my)^2 < sgap then
			sgap = (x-mx)^2+(y-my)^2
			ni = (i-1)/2+1
			nx, ny = x, y
		end
	end
	if ni and not (target.i_point == ni) then
		-- new target
		target.i_point = ni
		target.x = nx
		target.y = ny
		beep()
		return true
	end
	return false
end


function love.load()
	width, height = love.graphics.getDimensions( )
end

 
function love.update(dt)
	
end


function love.draw()
	love.graphics.setLineWidth(5)
	for i, road in pairs (roads) do
		love.graphics.setColor(road.color)
		for i, line in pairs (road.lines) do
			love.graphics.line(line)
		end
		for i, line in pairs (road.arrow_lines) do
			love.graphics.line(line)
		end
	end
	
	love.graphics.setLineWidth(2)
	for i, line in pairs (arrows) do
		
		love.graphics.setColor(colors[i])
		love.graphics.line(line)
	end
	
	love.graphics.setColor(1,1,1)
	for i = 1, #nodes-1, 2 do
		local x, y = nodes[i], nodes[i+1]
		love.graphics.circle('line', x, y,5)
	end
	
--	love.graphics.setColor(1,1,1)
--	love.graphics.setLineWidth(2)
--	for i, path in pairs (paths) do
		
--		for j, line in pairs (path.lines) do
----			print (#line, table.concat(line,", "))
--			love.graphics.line(line)
--		end
--	end

	
	love.graphics.circle('fill', target.x, target.y, 8)
	
	
	local mx, my = love.mouse.getPosition()
	love.graphics.print(mx..' '..my, mx, my-20)
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
	change_nearest_target (x, y)
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end