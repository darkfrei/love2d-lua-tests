local serpent = require("serpent")

require ('unn')

function love.load()
	love.math.setRandomSeed(love.timer.getTime())
	
	nn_size = 15 -- 15
--	nn_1 = unn:new(15)
	nn_1 = unn:new(nn_size)
--	nn_2 = unn:new(12, "nn2")
	print (nn_1.name)
--	print (nn_2.name)
--	print (serpent.block(nn_1))
	errors = {}
	error_id = 1
	
	
end
 
	--xor, and, not-and, or, not-or
input_variants = {
		{0, 0},
		{0, 1},
		{1, 0},
		{1, 1},
	}
	
right_outputs = 
	{
		{0, 0, 1, 0, 1}, 
		{1, 0, 1, 1, 0}, 
		{1, 0, 1, 1, 0}, 
		{0, 1, 0, 1, 0}
	}
n_outputs = 5
 
function love.update(dt)
--	local i = math.random(#input_variants)
--	local variant = input_variants[i]
--	print ('variant: ' .. i)
	local nn_1_error = 0
	local nn_2_error = 0
	local nn_2 = nn_1:mutate(0.1, 0.1)
	
	for i, variant in pairs (input_variants) do
		local nn_1_outputs = nn_1:feed(variant, n_outputs)
		nn_1_error = nn_1_error + nn_1:get_error(nn_1_outputs, right_outputs[i])
	--	print ('nn_1_error: '..nn_1_error)
		
--		local nn_2 = nn_1:mutate(0.1, 0.1)
		
		local nn_2_outputs = nn_2:feed(variant, n_outputs)
		nn_2_error = nn_2_error + nn_2:get_error(nn_2_outputs, right_outputs[i])
--		print ('nn_2_error: '..nn_2_error)
	end
	
	if nn_2_error < nn_1_error then
--		print ('nn_2_error: '..nn_2_error)
		nn_1 = nn_2
--		table.insert (errors, nn_2_error)
		errors[error_id] = nn_2_error
		error_id = error_id+1
		if error_id > 800 then error_id = 1 end
	else
--		error_id = error_id+1
--		print ('nn_1_error: '..nn_1_error..' nn_2_error: '..nn_2_error)
	end
end
 
 
function love.draw()
	love.graphics.setColor(0.5,0.5,0.5)
	for x = 1, 800 do
		local err = errors[x]
		if err then
			love.graphics.line(x, 0, x, err*10)
		end
	end	
	love.graphics.setColor(0,1,0)
	if errors[#errors] then
		love.graphics.print('Step: ' .. nn_1.id ..' Error: '.. errors[#errors], 200, 300)
	end
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end


function love.keypressed( key, scancode, isrepeat )
	
	if key == 'escape' then
		love.filesystem.write("nn-" .. nn_1.id .. '.lua', 'return ' .. serpent.block({biases = nn_1.biases, weights=nn_1.weights}))
	end
end

