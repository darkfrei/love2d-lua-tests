function random_field(size_int)
	local field = {min_x=1, max_x=size_int, min_y=1, max_y=size_int, id=0}
	local bools = {true, false}
	for y = field.min_y, field.max_y do
		field[y] = field[y] or {}
		for x = field.min_x, field.max_x do
			field[y][x] = bools[math.random(2)]
		end
	end
	return field
end

function love.load()
	love.window.setMode( 800, 600, {usedpiscale=false} )
	
	size_int = 20
	field = random_field(size_int)
	field.id=field.id+1
	pointsA = {}
	pointsB = {}
	for y=field.min_y, field.max_y do
		for x=field.min_x, field.max_x do
			if field[y][x] then
				pointsA[#pointsA+1]=x
				pointsA[#pointsA+1]=y
			else
				pointsB[#pointsB+1]=x
				pointsB[#pointsB+1]=y
			end
		end
	end
end


function deepcopy(tabl)
	local t = {}
	for i, v in pairs (tabl) do
		if type (v) == "table" then
			t[i]=deepcopy(v)
		else
			t[i]=v
		end
	end
	return t
end

function exist (bool)
	return not (bool==nil)
end


function count_neigbours (field, x, y)
	local n=0
	local neigbours = {
		{x=-1,y=-1},
		{x=-1,y= 0},
		{x=-1,y= 1},
		{x= 0,y=-1},
		{x= 0,y= 1},
		{x= 1,y=-1},
		{x= 1,y= 0},
		{x= 1,y= 1}
	}
	for i, neigbour in pairs (neigbours) do
		local x1=x+neigbour.x
		local y1=y+neigbour.y
		if field[y1] and field[y1][x1] then
			n=n+1
		end
	end
--	print ('n:'..n)
	return n
end

function is_alive (field, x, y)
	local n = count_neigbours (field, x, y)
	if (n==3) then -- born
		return true
	elseif (n == 4) then -- same
		return field[y] and field[y][x] or false
	else
		return false
	end
end


function create_neigbours(new, x, y)
	local neigbours = {
		{x=-1,y=-1},
		{x=-1,y= 0},
		{x=-1,y= 1},
		{x= 0,y=-1},
		{x= 0,y= 1},
		{x= 1,y=-1},
		{x= 1,y= 0},
		{x= 1,y= 1}
	}
	for i, neigbour in pairs (neigbours) do
		local x1=x+neigbour.x
		local y1=y+neigbour.y
		new[y1]=new[y1] or {}
		if not exist(new[y1][x1]) then
			new[y1]=new[y1]or{}
			local value = is_alive (field, x1, y1)
			new[y1][x1] = value
			if new[y1][x1] then
				pointsA[#pointsA+1]=x1
				pointsA[#pointsA+1]=y1
			else
				pointsB[#pointsB+1]=x1
				pointsB[#pointsB+1]=y1
			end
			new.min_x = math.min(new.min_x, x1)
			new.max_x = math.max(new.max_x, x1)
			new.min_y = math.min(new.min_y, y1)
			new.max_y = math.max(new.max_y, y1)
--			print (tostring(value) .. ' x1:'..x1 .. ' y1:'..y1 )
		end
	end
end


function update ()
	pointsA={}
	pointsB={}
	local new = deepcopy(field)
	new.id = field.id+1
	for y=field.min_y, field.max_y do
		new[y]=new[y]or{}
		for x=field.min_x, field.max_x do
			local value = field[y] and field[y][x] or false
			
			if value then 
--				local points = create_neigbours(field, x, y) 
				local points = create_neigbours(new, x, y) 
				
			end
			
			local new_value = is_alive (field, x, y)
			if not (value == new_value) then
				print ('changed x:'..x..' y:'..y)

			end
			new[y][x] = new_value
			
			if new[y][x] then
				pointsA[#pointsA+1]=x
				pointsA[#pointsA+1]=y
			else
				pointsB[#pointsB+1]=x
				pointsB[#pointsB+1]=y
			end	

			
		end
	end
	field = new
end
 
 
function love.update(dt)
	update ()
end
 
function love.graphics.squares(points, size)
	for i = 1, (#points-1), 2 do
		local x=points[i]
		local y=points[i+1]
		love.graphics.rectangle( "fill", x, y, size, size )

	end
end

 
function love.draw()
--	love.graphics.print(field.id)
	print(field.id)
	love.graphics.scale( 16,16)
	love.graphics.setColor(1,1,1)
--	love.graphics.points(pointsA)
	love.graphics.squares(pointsA, 0.9)
	
	love.graphics.setColor(0,0,0.5)
--	love.graphics.points(pointsB)
	love.graphics.squares(pointsB, 0.9)
end

function love.keypressed( key, scancode, isrepeat )
	if key == 'space' then
		field = random_field(size_int)
	end
end