--	marching squareas and isolines
--	2021-05-18, (c) darkfrei

--	based on:
--	The Coding Train
--	https://www.youtube.com/watch?v=0ZONMNUKTfU




function field_noise_rescale (min, max)
	
	for i, js in pairs (field) do
		for j, value in pairs (js) do
			value = (value-min)/max
			value = math.floor(value*16)/16
			field[i][j] = value
		end
	end
	
end

function rewrite (from, to)
	
		
end

function deepcopy (tabl)
	local new_table = {}
		
	return new_table
end



function new_field ()
	field = {}
	
	local min, max
	for i = 1, cols-1 do
		field[i] = {}
		for j = 1, rows-1 do
			local value = math.random()
			field[i][j] = value
			min = not min and value or min > value and value or min
			max = not max and value or max < value and value or max
--			field[i][j] = math.random(2)-1
		end
	end
	
	field_noise_rescale (min, max)
end


function love.load()
	love.window.setTitle( 'isolines-and-isobands-05' )
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	
	love.graphics.setBackgroundColor( 0.5, 0.5, 0.5)

	rez = 20
	width, height = love.graphics.getDimensions( )
	cols=width/rez
	rows=height/rez
	
	new_field ()
--	new_isolines ()
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
			love.graphics.setColor (value, value, value)
			love.graphics.points(i*rez, j*rez)
		end
	end
	
	show_isolines ()
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end




















