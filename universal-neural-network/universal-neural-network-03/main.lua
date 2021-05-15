serpent = require ('serpent')

require ('unn')

w = love.graphics.getWidth()
h = love.graphics.getHeight()

function love.load()
	points = {}
	points_nn = {}
	
	local nodes_amount = 5
	nn = unn:new(nodes_amount)
--	print (serpent.line(nn))
end
 
function draw_points (points, bool)
	local t = {}
	for x, y in pairs (points) do
		table.insert (t, x)

		table.insert (t, y)
	end
	love.graphics.points(t)
end

function delete_nearest_point ()
	local mx = love.mouse.getX()
	for i, x in pairs ({mx, mx+1, mx-1, mx+2, mx-2, mx+3, mx-3}) do
		if points[x] then
			points[x]= nil
			return
		end
	end
end


function get_error (nn, bool)
	local err = 0
	for i = 1, 800 do
		if points[i] then
			local nn_output = nn:feed ({i/w})
			local y = nn_output[1]
			if bool then -- red points
				points_nn[i] = h*y
			end
			err = err+nn:get_error (nn_output, {points[i]/h}) -- nn and target
		end
	end
	
	return err
end


 
function love.update(dt)
	
	if love.mouse.isDown(1) then
		points[love.mouse.getX()]=love.mouse.getY()
	elseif love.mouse.isDown(2) then
		delete_nearest_point ()
	end
	
	local err = get_error (nn, true)
	
	local chance = math.random()
	local mutant = nn:mutate (chance, 1)
	local err_mutant = get_error (mutant)
	
	if err_mutant < err then
		nn = mutant
	end
	
	nn.err = err
end
 
 
function love.draw()
	love.graphics.scale( 1/1.5)
	
	love.graphics.setColor(1, 1, 1)
	draw_points (points)
	
	love.graphics.setColor(1, 0, 0)
	draw_points (points_nn, true)
	
	
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
	love.graphics.print ('h: '..h..' w:'..w, 10, 32)
	love.graphics.print ('error: '..nn.err, 10, 52)
	
end




