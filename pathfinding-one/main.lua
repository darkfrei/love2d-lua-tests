-- 2021-04-22 License CC0 (Creative Commons license) (c) darkfrei

function love.load()
	n_steps = 0
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
--	if ddheight > 1080 and false then
	if ddheight > 1080 then
		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=false, borderless=true})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	
	grid_size = 55
	
	local smap = {
{2,3,3,0,2,1,0,2,2,3,2,3,3,1,0,2,1,2,3,3,0,2,3,3,2,1,2,3,0,2,2,1,},
{2,0,2,1,1,0,1,2,3,1,1,1,0,1,0,1,1,2,0,0,0,3,2,1,0,2,3,3,2,1,1,2,},
{0,2,0,1,1,1,3,2,0,1,1,2,1,1,3,1,2,1,1,3,1,0,0,0,1,3,1,2,3,1,0,3,},
{0,0,1,0,2,0,3,2,0,1,3,0,1,3,0,2,1,3,3,0,1,1,1,1,1,1,1,0,2,3,0,3,},
{0,1,3,2,1,3,0,1,0,1,2,0,2,3,1,0,0,1,1,3,0,1,1,2,2,3,0,3,0,3,0,3,},
{2,2,1,3,2,0,2,2,0,2,0,3,1,1,2,2,0,1,2,0,0,2,3,1,3,1,3,3,2,0,1,1,},
{2,2,2,0,2,3,1,2,1,3,0,0,2,3,2,3,1,0,1,2,3,3,2,0,0,3,1,1,2,1,1,0,},
{1,0,1,3,3,3,0,1,0,0,0,3,0,1,1,2,0,3,3,1,1,3,1,1,3,1,0,0,1,1,1,1,},
{2,2,0,0,3,3,1,1,1,0,1,3,0,2,1,3,2,3,0,3,0,3,2,0,1,0,3,1,1,1,0,1,},
{1,1,3,3,0,2,2,0,0,0,3,3,0,0,3,3,3,1,1,3,1,0,3,2,0,0,1,3,0,0,2,3,},
{3,1,1,1,2,0,1,3,0,0,2,0,1,0,0,2,1,3,0,3,1,3,3,1,1,3,2,0,0,1,0,2,},
{1,3,3,1,3,1,0,3,1,1,3,0,0,3,2,1,0,1,3,1,0,3,0,0,2,1,3,1,0,3,2,0,},
{0,1,0,1,3,2,2,0,0,2,3,2,3,2,3,0,0,2,0,0,0,1,1,1,3,3,3,0,0,3,2,0,},
{0,2,1,2,2,1,1,1,1,2,3,3,3,2,2,2,1,3,3,2,0,2,3,3,1,2,1,2,0,1,1,1,},
{0,0,0,0,3,0,0,3,1,2,2,0,1,0,0,1,3,3,3,2,1,2,0,1,3,2,1,3,0,0,1,0,},
{0,2,0,2,0,0,2,3,3,1,2,0,2,1,3,3,2,2,0,2,0,0,0,2,1,1,0,0,0,2,2,2,},
}

	grid_size = math.min(love.graphics.getWidth()/(#smap[1]+2), love.graphics.getHeight()/(#smap+2))
	print (grid_size)
	-- random map:

	for i = 1, 16 do
		local str = '{'
		for j = 1, 32 do
			str=str..love.math.random(0, 3)..','
		end
		str=str..'},'
		print (str)
	end
	map = {}
	for x = 1, #smap[1] do
		map[x]={}
		for y = 1, #smap do
			local tile = {cost_value = smap[y][x], x=x,y=y}
--			local tile = {cost_value = 1, x=x,y=y}
--			local tile = {cost_value = math.random(2), x=x,y=y}
			map[x][y] = tile
		end
	end
	pfo =
	{
--		from = {x=math.random(16), y=math.random(16)},
--		to	 = {x=math.random(16), y=math.random(16)},
		from = {x=3, y=3},
		to	 = {x=15+14, y=12, cost = 0},
		last = nil,
		i = 1,
--		done = false,
		done = true,
		path = {lines={}, length = 0, cost = 0},
		max_level = 2
	}
	
	local tile = map[pfo.to.x][pfo.to.y]
	tile.cost = 0
	tiles = {tile}
	
	for_fast_update = {}
end

function get_neigbours (tile)
	n_steps=n_steps+1
--	local tiles = {}
	local vs = {{x=0,y=-1},{x=1,y=0},{x=0,y=1},{x=-1,y=0}}
--	local vs = {{x=0,y=-1}, {x=-1,y=0}}
	local amount = 0
	for direction, v in pairs (vs) do
		local t = map[tile.x+v.x] and map[tile.x+v.x][tile.y+v.y]

		if t and t.cost_value <= pfo.max_level then
			local dd = tile.cost + t.cost_value
			if t.cost then -- old
				if t.direction == tile.direction then
					dd = dd + 0.1
				else
					dd = dd + 0.01
				end
				if dd < t.cost then
					t.cost = dd
					t.direction = direction
					t.opt = true
--					table.insert (tiles, t)
					table.insert (for_fast_update, t)
				end
			else -- new
				if direction == tile.direction then
					dd = dd + 0.01
				else
					dd = dd + 0.1
				end
				t.cost = dd
				t.direction = direction
				table.insert (tiles, t)
				amount=amount+1
			end
		end
	end
	tile.amount=amount
--	return tiles
end

function track_path()
	local path = pfo.path
	local last_tile = map[pfo.from.x][pfo.from.y]
	local vs = {{x=0,y=1},{x=-1,y=0},{x=0,y=-1},{x=1,y=0}}
	local length = 0
	local cost = 0
	while last_tile and last_tile.direction and length < 100 do
		length=length+1
		cost = cost + last_tile.cost_value
		local v = vs[last_tile.direction]
		
		local line = {last_tile.x, last_tile.y, last_tile.x+v.x, last_tile.y+v.y}
		table.insert(path.lines, line)
		last_tile = map[last_tile.x+v.x][last_tile.y+v.y]
	end
	pfo.path.cost=cost
	pfo.path.length=length

	print('lines: ' .. #path.lines .. ' cost: '..cost .. ' length: '..length)
end
 
function love.update(dt)
	local t1 = 0.2 -- 1 ms
--	local t1 = 0.001 -- 1 ms
	buffer = buffer and buffer + dt or dt
	for i = 1, 100 do
		if buffer > t1 then
			buffer = buffer-t1
			if not pfo.done then
				if #for_fast_update > 0 then
					for i, tile in pairs (for_fast_update) do
						get_neigbours (tile)
					end
					for_fast_update = {}
				end
				
				local tile = tiles[pfo.i]
				if tile then
					get_neigbours (tile)
				else
					pfo.done = true
					track_path()
				end
				pfo.i = pfo.i+1
			end
		else
			return
		end
	end
end

function draw_grid ()
	for x, ys in pairs (map) do
		for y, tile in pairs (ys) do
			local cost_value = tile.cost_value
			local c = 3/6-cost_value/6
			love.graphics.setColor(c,c,1/6-c/2)
			love.graphics.rectangle('fill', x*grid_size,y*grid_size,grid_size,grid_size)
			love.graphics.setColor(1,1,0)
			love.graphics.print(tile.cost_value, x*grid_size,(y+0.7)*grid_size)
		end
	end
end

function draw_arrow (tile)
	local x1, y1 = (tile.x+0.5)*grid_size, (tile.y+0.5)*grid_size
	local a = -grid_size*0.9
	local x2 = tile.direction == 4 and x1-a or tile.direction == 2 and x1+a or x1
	local y2 = tile.direction == 3 and y1+a or tile.direction == 1 and y1-a or y1
	local b = grid_size*0.1
	
	local xs = {x1-b, x1-b, x1+b, x1+b, x1+b, x1-b, x1-b, x1+b}
	local ys = {y1+b, y1-b, y1-b, y1+b, y1+b, y1+b, y1-b, y1-b}
	local x3 = xs[tile.direction]
	local y3 = ys[tile.direction]
	local x4 = xs[tile.direction+4]
	local y4 = ys[tile.direction+4]
--	local y3 = tile.direction == 4 and y1-b or tile.direction == 2 and y1+b or y1
	love.graphics.line(x1,y1,x2,y2)
	love.graphics.line(x1,y1,x3,y3)
	love.graphics.line(x1,y1,x4,y4)
	love.graphics.line(x3,y3,x4,y4)
end

function draw_path()
	local lines = pfo.path.lines
	if #lines > 0 then
		love.graphics.setColor(1,0,0)
		love.graphics.setLineWidth( 4 )
		for i, line in pairs (lines) do
			love.graphics.line(
				grid_size*(line[1]+0.5),
				grid_size*(line[2]+0.5),
				grid_size*(line[3]+0.5),
				grid_size*(line[4]+0.5)
				)
		end
	end
end

function love.draw()
	draw_grid ()
	love.graphics.setLineWidth( 2 )
	
	if pfo.done then
		love.graphics.setColor(1,1,1)
		love.graphics.print('Press space to start', grid_size, 30)
	end
	
	love.graphics.print(n_steps .. ' steps', grid_size, 42)

	for x, ys in pairs (map) do
		for y, tile in pairs (ys) do
			if tile.opt then
				love.graphics.setColor(1,1,1)
				else
				love.graphics.setColor(0,1,1)
			end
			if tile.cost then
				love.graphics.print(tile.cost, x*grid_size,y*grid_size)
			end			
			if tile.direction then
--				love.graphics.print('\n'..tile.direction, x*grid_size,y*grid_size)
				draw_arrow (tile)
			end	
--			if tile.amount then
--				love.graphics.print('\n    '..tile.amount, x*grid_size,y*grid_size)
				
--			end
		end
	end
	
	draw_path()
	
	love.graphics.setColor(1, .5, .5)
	love.graphics.circle('fill', grid_size*(pfo.from.x+0.5), grid_size*(pfo.from.y+0.5), grid_size/4)
	love.graphics.setColor(.5, 1, .5)
	love.graphics.circle('fill', grid_size*(pfo.to.x+0.5), grid_size*(pfo.to.y+0.5), grid_size/4)
end

function love.keypressed(key, scancode, isrepeat)
   if key == "space" then
      pfo.done = not pfo.done
   elseif key == "escape" then
      love.event.quit()
   end
end