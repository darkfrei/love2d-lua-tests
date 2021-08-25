-- License CC0 (Creative Commons license) (c) darkfrei, 2021

local beep = require ('beep')

function normul (x, y, offset) -- normalization and multiplication
	local d = (x*x+y*y)^0.5
	offset = offset or 1
	return offset*x/d, offset*y/d
end



graph = {}
graph.lines = require ('example')
graph.arrows = {}
graph.colors = {}
graph.points_map = {}

function try_add_point (map, x, y)
	if not map[x] then map[x] = {} end
	if not map[x][y] then map[x][y] = 0 end
	map[x][y] = map[x][y] + 1
end

for i, line in pairs (graph.lines) do
	local x1, y1, x2, y2 = line[#line-3],line[#line-2],line[#line-1],line[#line]
	local l, w = 5, 4
	local vx, vy = normul (x2-x1, y2-y1, 1)
	local x, y = (x1+x2)/2, (y1+y2)/2
--	local arrow_line = {x2-vx-vy/l*w, y2-vy+vx/l*w, x2, y2, x2-vx+vy/l*w, y2-vy-vx/l*w}
	local arrow_line = {x-l*vx-vy*w, y-l*vy+vx*w, x+l*vx, y+l*vy, x-l*vx+vy*w, y-l*vy-vx*w}
--	table.insert (graph.arrows, arrow_line)
	graph.arrows[i] = arrow_line
	graph.colors[i] = {math.random(),math.random()+0.2,math.random()}
	
	try_add_point (graph.points_map, line[1], line[2])
	try_add_point (graph.points_map, x2, y2)
end

graph.points = {}
for x, ys in pairs (graph.points_map) do
	for y, value in pairs (ys) do
		table.insert(graph.points, {x=x,y=y, n=value, startings={},endings={}})
	end
end

for i_point, point in pairs (graph.points) do
	for i_line, line in pairs (graph.lines) do
		if point.x == line[1] and point.y == line[2] then
			table.insert(point.startings, i_line)
		end
		if point.x == line[#line-1] and point.y == line[#line] then
			table.insert(point.endings, i_line)
		end
	end
end

graph.sources = {{x=60,y=320, color={1,0,0}},{x=60,y=360, color={0,1,0}},{x=60,y=400, color={0,0,1}}}

graph.target = {x=620, y=280}

function change_nearest_target (mx, my)
	local gap, ni, nx, ny = 30
	local sgap = gap*gap
	
	for i_point, point in pairs (graph.points) do
		if (point.x-mx)^2+(point.y-my)^2 < sgap then
			sgap = (point.x-mx)^2+(point.y-my)^2
			ni = i_point
			nx, ny = point.x, point.y
		end
	end
	
	if ni and not (graph.target.i_point == ni) then
		-- new target
		graph.target.i_point = ni
		graph.target.x = nx
		graph.target.y = ny
		
--		local length, rate, bits, channel = 1, 44100, 16, 1
--		local sound_data = love.sound.newSoundData(length, rate, bits, channel)
		
--		local qs = love.audio.newQueueableSource(sound_data:getSampleRate(), sound_data:getBitDepth(), sound_data:getChannelCount())
--		local qs = love.audio.newQueueableSource()

		
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
	for i, line in pairs (graph.lines) do
		love.graphics.setColor(graph.colors[i])
		love.graphics.line(line)
	end
	for i, line in pairs (graph.arrows) do
		love.graphics.setColor(graph.colors[i])
		love.graphics.line(line)
	end
	
	love.graphics.setColor(1,1,1)
	for i_point, point in pairs (graph.points) do
		love.graphics.circle('line', point.x, point.y,5)
		love.graphics.print(i_point, point.x, point.y+5)
		love.graphics.print(point.n, point.x, point.y+15)
	end
	
	love.graphics.circle('line', graph.target.x, graph.target.y,10)
	
	
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