-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function love.load()
--	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
--	if ddheight > 1080 then
--		print('ddheight: ' .. ddheight)
----		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
--		love.window.setMode(640, 640, {resizable=true, borderless=false})
--	else
--		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
--	end
--	love.window.setMode(1230, 692, {resizable=true, borderless=false})
	love.window.setFullscreen( true )
	
	width, height = love.graphics.getDimensions( )
	

	canvas = love.graphics.newCanvas(width, height)
	canvas:setFilter("linear", "nearest")
	
	scale = 4
	
--	love.graphics.setPointSize( scale )

	width, height = math.floor(width/scale), math.floor(height/scale)
	
	map = {}
	center = {x=math.floor(width/2), y=math.floor(height/2)}
--	add_point_to_map (center.x, center.y, true)
	add_point_to_map (center.x, center.y, false)
	
	rectangle = {s = 10}
	rectangle.x1 = center.x-rectangle.s
	rectangle.y1 = center.y-rectangle.s
	rectangle.x2 = center.x+rectangle.s
	rectangle.y2 = center.y+rectangle.s
	
	dots = 0
	full = false
end

function add_point_to_map (x, y, ignore)
	x, y = math.floor(x), math.floor(y) 
	if not map[x] then map[x] = {} end
	if not map[x][y] then map[x][y] = true end
	
--	love.graphics.scale(1,1)

	if not ignore then
--		love.graphics.scale(1, 1)
		love.graphics.setCanvas(canvas)
--			love.graphics.scale(1, 1)
--			love.graphics.scale(scale, scale)
			love.graphics.setColor(1,1,1)
			love.graphics.points(x,y)
--			love.graphics.scale(1,1)
		love.graphics.setCanvas()
	end
end

function create_agent ()
--	local side = math.random (1, 4)
	local side = weighted_random ({
		rectangle.y1 > 0 and rectangle.y2-rectangle.y1 or 0,
		rectangle.x2 < width and rectangle.x2-rectangle.x1 or 0,
		rectangle.y2 < height and rectangle.y2-rectangle.y1 or 0,
		rectangle.x1 > 0 and rectangle.x2-rectangle.x1 or 0,
	})
	if not side then
		full = true
		return
	end
	local x, y
	if side == 1 or side == 3 then
		x = math.random(rectangle.x1, rectangle.x2)
	elseif side == 2 then
		x = rectangle.x2
	else
		x = rectangle.x1
	end
	if side == 2 or side == 4 then
		y = math.random(rectangle.y1, rectangle.y2)
	elseif side == 3 then
		y = rectangle.y2
	else
		y = rectangle.y1
	end
	agent = {x=x, y=y, d=math.random (4)} -- d is direction
end

function weighted_random (weights)
	local summ = 0
	for i, weight in pairs (weights) do
		summ = summ + weight
	end
	if summ == 0 then return end
	local value = math.random (summ)
	summ = 0
	for i, weight in pairs (weights) do
		summ = summ + weight
		if value <= summ then
			return i, weight
		end
	end
end

function update_agent ()
	if not agent then return end
	local dd = math.random (6) 
--	local dd = weighted_random ({
--			rectangle.x1 > 0 and rectangle.x2-rectangle.x1 or 0,
--			rectangle.y2 < width and rectangle.y2-rectangle.y1 or 0,
--			rectangle.x2 < height and rectangle.x2-rectangle.x1 or 0,
--			rectangle.y1 > 0 and rectangle.y2-rectangle.y1 or 0
--			})
	if dd == 1 then -- turn right
		agent.d = agent.d + 1
	elseif dd == 2 then -- turn left
		agent.d = agent.d + 3
	else -- not turn
		
	end
	local directions = {{x=0, y=-1},{x=1, y=0},{x=0, y=1},{x=-1, y=0}}
	agent.d = (agent.d-1)%4+1
	agent.x = agent.x + directions[agent.d].x
	agent.y = agent.y + directions[agent.d].y
	
	if agent.x < rectangle.x1 then
		agent.x = rectangle.x1
		agent.d = 2
	elseif agent.x > rectangle.x2 then
		agent.x = rectangle.x2
		agent.d = 4
	end
	if agent.y < rectangle.y1 then
		agent.y = rectangle.y1
		agent.d = 3
	elseif agent.y > rectangle.y2 then
		agent.y = rectangle.y2
		agent.d = 1
	end
end

function update_rectangle (x, y)
	local s = rectangle.s
	rectangle.x1 = math.min (rectangle.x1, x-s)
	rectangle.y1 = math.min (rectangle.y1, y-s)
	rectangle.x2 = math.max (rectangle.x2, x+s)
	rectangle.y2 = math.max (rectangle.y2, y+s)
end

function check_agent ()
	if not agent then return end
	local directions = {{x=0, y=-1},{x=1, y=0},{x=0, y=1},{x=-1, y=0}}
	for i, dir in pairs (directions) do
		local x, y = agent.x + dir.x, agent.y + dir.y
		if map[x] and map[x][y] then
			add_point_to_map (agent.x, agent.y)
			update_rectangle (agent.x, agent.y)
			agent = nil
			return true
		end
	end
end

function love.update(dt)
	if not agent then create_agent () end
	if fast and not full then
		for i = 1, 10000 do
			update_agent ()
--			if check_agent () then return end
--			check_agent ()
			if check_agent () then 
				dots = dots+1
				create_agent ()
			end
		end
	else
		update_agent ()
		check_agent ()
	end
end


function love.draw()
	love.graphics.setColor(1,1,1)
	love.graphics.print('dots: '..dots, 10, 10)
	love.graphics.print('press space for fast speed', 10, 30)
	love.graphics.print('fast: '..tostring(fast), 10, 50)
	love.graphics.print('full: '..tostring(full), 10, 70)
	
	love.graphics.setColor(1,1,1)
	love.graphics.draw(canvas, 0,0, 0, scale, scale)
	--love.graphics.draw(canvas, 0,0, 0, scale, scale)
	
--	love.graphics.scale(scale, scale)
	
	love.graphics.setColor(0.25,0.25,0.25)
	love.graphics.rectangle('line', scale*rectangle.x1, scale*rectangle.y1, scale*rectangle.x2-scale*rectangle.x1, scale*rectangle.y2-scale*rectangle.y1)
	

	
	if agent and not fast then
		love.graphics.setColor(1,1,0)
		love.graphics.circle ('fill', scale*agent.x, scale*agent.y, 2)
		
--		love.graphics.line(scale*agent.x, scale*agent.y, scale*center.x, scale*center.y)
	end
	
	
--	love.graphics.setColor(1,1,1)
--	love.graphics.draw(canvas, 0,0, 0, scale, scale)
end

function love.keypressed(key, scancode, isrepeat)
	if key == "space" then
		fast = not fast
	elseif key == "escape" then
		love.event.quit()
	end
end