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

local node_points = gs.create_node_points (lines)
local paths = gs.create_paths (lines, node_points)
--print('node_points: '..#node_points, 'paths: '..#paths)


-- sources are hardcoded:

--sources = {{x=60,y=320, color={1,0,0}}}
sources = {
	{x=60,y=320, color={1,0,0}, width = 10},
	{x=60,y=360, color={0,1,0}, width = 6},
	{x=60,y=400, color={0,0,1}, width = 2}
}

-- the target before it will be new selected:
--target = {x=640, y=300}
--target = {x=340, y=380}
target = {x=520, y=320}

local target_node = get_node_number (node_points, target.x, target.y)
--print ('target_node',target_node)

-- tre trace has a line from source to the target
traces = {}

function trace_all ()
--	for i, v in ipairs (traces) do traces[i] = nil end
	traces = {}
	for i, source in pairs (sources) do
--		print ('trace', i)
		local trace = gs.get_trace (paths, node_points, source.x, source.y, target.x, target.y, i)
--		print ('trace #line', #trace.line)
		trace.color = source.color
		trace.width = source.width
		table.insert (traces, trace)
	end
end

trace_all ()


function change_nearest_target (mx, my)
	local gap, ni, nx, ny = 30
	local sgap = gap*gap -- square gap
--	for i_point, point in pairs (points) do
	for i = 1, #node_points-1, 2 do
		local x, y = node_points[i], node_points[i+1]
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
		trace_all ()
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
	love.graphics.setLineWidth(2)
	for i, path in pairs (paths) do
		love.graphics.setColor(path.color)
--		love.graphics.setLineWidth(path.width) -- not trace
		love.graphics.line(path.line)
		
		-- draw arrow
		love.graphics.line(path.arrow_line)
		love.graphics.print("l="..path.length, path.x_text, path.y_text, path.text_angle)
	end

	-- draw trace
--	love.graphics.setColor(1,1,1)
--	love.graphics.setLineWidth(3)
	for i, trace in pairs (traces) do
		if #trace.line > 3 then
			love.graphics.setColor(trace.color)
			love.graphics.setLineWidth(trace.width)
			love.graphics.line(trace.line)
		end
	end
	
	-- draw node_points
	love.graphics.setColor(1,1,1)
	love.graphics.setLineWidth(1)
	for i = 1, #node_points-1, 2 do
		local x, y = node_points[i], node_points[i+1]
		love.graphics.circle('line', x, y,5)
		love.graphics.print('n'..math.floor((i+1)/2), x, y+5)
	end

	-- draw source circles
	for i, source in pairs (sources) do
		love.graphics.setColor(source.color)
		love.graphics.circle('fill', source.x, source.y, 6)
--		love.graphics.print(source.x..' '..source.y, source.x, source.y-20)
	end

	-- draw target circle
	love.graphics.setColor(1,1,1)
	love.graphics.circle('fill', target.x, target.y, 8)
	love.graphics.print(target.x..' '..target.y, target.x, target.y-20)
	
	-- draw mouse position
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