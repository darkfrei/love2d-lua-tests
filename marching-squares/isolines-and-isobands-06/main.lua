--	marching squareas and isolines
--	2021-05-18, (c) darkfrei

--	based on:
--	The Coding Train
--	https://www.youtube.com/watch?v=0ZONMNUKTfU




function field_noise_rescale ()
	
	local min, max
	for i = 1, cols-1 do
		for j = 1, rows-1 do
			local value = field[i][j]
			min = not min and value or min > value and value or min
			max = not max and value or max < value and value or max
		end
	end
	
	for i, js in pairs (field) do
		for j, value in pairs (js) do
			value = (value-min)/(max-min)
--			value = math.floor(value*16)/16
			field[i][j] = value
		end
	end
end

function get_middle (i, j)
	local result, amount = 0, 0
	
	local shifts = {
		{x=-1,y=-1},{x= 0,y=-1},{x= 1,y=-1},
		{x=-1,y= 0},{x= 0,y= 0},{x= 1,y= 0},
		{x=-1,y= 1},{x= 0,y= 1},{x= 1,y= 1}}
	for k, shift in pairs (shifts) do
		if field[i+shift.x] and field[i+shift.x][j+shift.y] then
			amount=amount+1
			result = result + field[i+shift.x][j+shift.y]
		end
	end
	if amount > 0 then
		return result/amount
	end
end

function  blur_field ()
	local new_field = {}
	
	for i = 1, cols do
		new_field[i] = {}
		for j = 1, rows do
			local value = math.random()
			new_field[i][j] = get_middle (i, j)
		end
	end
	field = new_field
	
end


function new_field ()
	field = {}
	local min, max = 1, 0
	for i = 1, cols do
		field[i] = {}
		for j = 1, rows do
			local value = math.random()
			field[i][j] = value
			min = not min and value or min > value and value or min
			max = not max and value or max < value and value or max
			field[i][j] = math.random(2)-1
		end
	end
end


function follow_isoline (section_map, i, j, section)
	-- we are in the square between 4 vertexes, between 4 sides
	local vertexes = {{x=0, y=0}, {x=1, y=0}, {x=1, y=1}, {x=0, y=1}} -- a,b,c,d
	local sides = {
		{vertexes[1],vertexes[2], direction={x= 0,y=-1}}, -- ab, up
		{vertexes[2],vertexes[3], direction={x= 1,y= 0}}, -- bc, right
		{vertexes[3],vertexes[4], direction={x= 0,y= 1}}, -- cd, down
		{vertexes[4],vertexes[1], direction={x=-1,y= 0}}} -- da, left
	-- 
	local line = {} -- {{x1,y1},{x2,y2}}
	for n_side, side in pairs (sides) do
		local value1 = field[i+side[1].x][j+side[1].y]
		local value2 = field[i+side[2].x][j+side[2].y]
		if 	section <= math.max(value1, value2) and 
			section >  math.min(value1, value2) then
			
		end
		
	end
end


function update_isolines ()
	
	for _, section in pairs (sections) do
		-- find first
		local section_map = {} -- squares between dots, one less than #field and #field[1]
		for i = 1, #field-1  do
			for j = 1, #field[1]-1 do
				
				local boolmin = section > math.min(field[i][j],field[i+1][j],field[i+1][j+1],field[i][j+1])
				local boolmax = section < math.max(field[i][j],field[i+1][j],field[i+1][j+1],field[i][j+1])
				
				if boolmin and boolmax and not (section_map[i][j]) then
					-- first tile in map
					
					
					section_map[i] = section_map[i] or {}
					section_map[i][j] = {n = 1}
					
					
				end
			end
		end
	end
end


function love.load()
	love.window.setTitle( 'isolines-and-isobands-06' )
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	
--	love.graphics.setBackgroundColor( 0.5, 0.5, 0.5)
	love.graphics.setBackgroundColor( 0.3, 0.2, 0.0)

	rez = 20
	width, height = love.graphics.getDimensions( )
	cols=width/rez - 1
	rows=height/rez - 1
	
	new_field ()
	
	isoline_canvas = love.graphics.newCanvas(width, height)
	isolines = {}
	sections = {0.2, 0.8}
	
	update_isolines ()
end

 
function love.update(dt)
	

end

function get_state (i, j)
	if field[i+1] and field[i][j+1] then
		return field[i][j]*1 + field[i+1][j]*2 + field[i+1][j+1]*4 + field[i][j+1]*8
--		return field[i][j]*8 + field[i+1][j]*4 + field[i+1][j+1]*2 + field[i][j+1]*1
	end
end

function draw_line (a, b)
	love.graphics.line(a.x, a.y, b.x, b.y)
end

function show_isolines ()
	
--	isolines = {}
	love.graphics.setColor (1, 1, 1)
	for i = 1, #field do
--		isolines[i]={}
		for j = 1, #field[1] do
			local x = i * rez
			local y = j * rez
			local a = {x=x+rez/2, 	y=y}
			local b = {x=x+rez, 	y=y+rez/2}
			local c = {x=x+rez/2, 	y=y+rez}
			local d = {x=x, 		y=y+rez/2}
			
			local state = get_state (i,j)
			if state then
				
--				love.graphics.print(state, x, y)
				if (state == 2 or state == 13) then
--					love.graphics.setColor (1, 0, 0)
					draw_line (a, b)
				elseif (state == 1 or state == 14) then
--					love.graphics.setColor (1, 1, 0)
					draw_line (d, a)
				elseif (state == 4 or state == 11) then
--					love.graphics.setColor (0, 1, 0)
					draw_line (b, c)
				elseif (state == 7 or state == 8) then
--					love.graphics.setColor (0, 1, 0)
					draw_line (c, d)
				elseif (state == 6 or state == 9) then
--					love.graphics.setColor (0, 1, 0)
					draw_line (a, c)
				elseif (state == 3 or state == 12) then
--					love.graphics.setColor (0, 1, 0)
					draw_line (b, d)
--				elseif (state == 5 or state == 10) then
				elseif (state == 5) then
--					if math.random(2) == 1 then
						draw_line (a, b)
						draw_line (c, d)
--					else
				elseif (state == 10) then
						draw_line (b, c)
						draw_line (d, a)
--					end
				else -- 0
				end
			end
--			isolines[i][j] = {a,b,c,d}
		end
	end
end

function love.draw()
	love.graphics.setPointSize( 2 )

	for i, js in pairs (field) do
		for j, value in pairs (js) do
			
--			love.graphics.points(i*rez, j*rez)
			if value == 1 then
				love.graphics.setColor (1,1,0)
			elseif value == 0 then
				love.graphics.setColor (0,1,1)
			elseif value > 1 then
				love.graphics.setColor (1,0,0)
			else
				love.graphics.setColor (0.8*value, value, 0.8*value)
			end
			love.graphics.circle('fill', i*rez, j*rez, 5*value + 2)
		end
	end
	
	show_isolines ()
end

function love.keypressed(key, scancode, isrepeat)
	if key == "b" then
		blur_field ()
	elseif key == "s" then
		field_noise_rescale ()
	elseif key == "escape" then
		love.event.quit()
	end
end




















