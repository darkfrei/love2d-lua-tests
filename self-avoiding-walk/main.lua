-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function is_free (i, j)
	if i < 1 or i > n_cols then return false end
	if j < 1 or j > n_rows then return false end
	if map[i] and map[i][j] then
		return false
	else
		return true
	end
end

function shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

function create_node (i, j)
	local node = {i=i, j=j}
	node.n = #nodes + 1
	node.neighbours = {}
	for n_option, option in pairs (all_options) do
		if is_free (i+option.i, j+option.j) then
			table.insert (node.neighbours, n_option)
		end
		
	end
	if #node.neighbours > 1 then
		node.neighbours = shuffle(node.neighbours)
	end
	map[i]=map[i] or {}
	map[i][j] = true
	table.insert (nodes, node)
end

function reload ()
	starting = {i=math.random(n_cols), j=math.random(n_rows)}
	map = {}
	nodes = {}
	create_node (starting.i, starting.j)
	tried = 0
--	pause = false
	ready = false
end

function love.load()
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	width, height = love.graphics.getDimensions( )
	
	all_options = {{i=0,j=-1},{i=1,j=0},{i=0,j=1},{i=-1,j=0}}

	rez = 240
	love.graphics.setLineWidth( 4 )

	n_cols, n_rows = 7, 4
	
	
	reload ()
	pause = true
end

function remove_node ()
	map[nodes[#nodes].i][nodes[#nodes].j] = false
	table.remove(nodes, #nodes)
	if #nodes > 0 then
		local node = nodes[#nodes]
		if #node.neighbours > 0 then
			node.neighbours[#node.neighbours] = nil
		end
	end
end

function is_ready ()
--	print ('n_cols:'..n_cols..' n_rows:'..n_rows)
	for i = 1, n_cols do
		for j = 1, n_rows do
			if not (map[i] and map[i][j]) then
--				print ('i:'..i..' j:'..j)
				return false
			end
		end
	end
	print ('ready')
	return true
end

function love.update(dt)
	if pause or ready then return end
	tried=tried+1
	local node = nodes[#nodes]
	if node and #node.neighbours > 0 then
		local opt = all_options[node.neighbours[#node.neighbours]]
		create_node (node.i+opt.i, node.j+opt.j)
		if is_ready () then
			ready = true
		end
--	elseif is_ready () then
--		pause = true
	else
		remove_node ()
	end
	
end

function draw_nodes ()
	for _, node in pairs (nodes) do
		love.graphics.circle('fill', node.i*rez, node.j*rez, rez/8)
		local n_opt = node.neighbours[#node.neighbours]
		local opt = all_options[n_opt]
		if opt then
			love.graphics.line(node.i*rez, node.j*rez, (node.i+opt.i)*rez, (node.j+opt.j)*rez)
--			love.graphics.print(n_opt, node.i*rez, node.j*rez)
			love.graphics.print(#node.neighbours, node.i*rez, node.j*rez)
		end
	end
end

function love.draw()
	love.graphics.setColor (1,1,1)
	draw_nodes ()
	
	love.graphics.print (tostring(tried))
	
	love.graphics.setColor (0,0.25,0.25)
	for i = 1, n_cols do
		for j = 1, n_rows do
			if map[i] and map[i][j] then
				love.graphics.circle('fill', i*rez, j*rez, rez/16)
			end
		end
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "space" and ready then
		reload ()
	elseif key == "r" then
		reload ()
	elseif key == "space" then
		pause = not pause
	elseif key == "escape" then
		love.event.quit()
	end
end