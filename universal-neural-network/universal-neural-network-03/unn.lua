
unn = {}


function unn:new(nodes_amount, input_nodes_max)
	local weights = {}
	local biases = {}
	local nodes = {}
	input_nodes_max = input_nodes_max or 1
	for i = 1, nodes_amount do
		local node = {}
		if i > input_nodes_max then
			for j = 1, #nodes do
				local weight = math.random(0, 2048)/1024-1
--				local weight = 0
				table.insert (weights, weight)
				table.insert (node, #weights) -- the number of weight
			end
	--		
			
		end
		table.insert(biases, math.random(0, 2048)/1024-1)
--		table.insert(biases, 0)
		table.insert(nodes, node)
	end
	local id = 1
	self = {id = id, weights=weights, nodes=nodes, biases=biases, input_nodes_max=input_nodes_max}
--	print ('1: ')
	self.feed = unn.feed
	self.get_error = unn.get_error
	self.mutate = unn.mutate
	return self
end


function activation (value, a)
	local a = a or 1
	if value >= 0 then
		return a*value^1.1
--		return math.log(a*value+1)
	else
		return 0
--		return 0 -- ReLU; no result
--		return a*value/100 -- Leaky ReLU; bad result
--		return -math.log(-a*value+1) -- very fast result
	end
end


function unn:feed (input_values, n_outputs)
	local values = {}
	local results = {}
	local n_nodes = #self.nodes
	n_outputs = n_outputs or 1
--	for i = self.input_nodes_max+1, n_nodes do
	for i = 1, n_nodes do
--		print ('i: ' .. i)
		if input_values[i] then
			values[i] = input_values[i]
--			print ('input_values[i]: ' .. i .. ' ' .. input_values[i])
		elseif self.biases[i] == nil then
--			print ('no bias ' .. i .. ' '.. serpent.line(self.biases))
		else
			local summ = self.biases[i]
			local node = self.nodes[i]
			for j, i_weight in pairs (node) do
				local value = values[j]
				if not value then
--					print ('values: j:'..j..' ' .. serpent.block(values))
--					print ('values: i:'..i..' ' .. serpent.block(input_values))
				else
					local weight = self.weights[i_weight]
					summ = summ + activation(value*weight)
				end

			end
			values[i] = summ
		end
		if (n_nodes-i) < n_outputs then
--			print ('n_outputs: ' .. n_outputs .. ' i: ' .. i .. ' n_nodes: '..n_nodes)
			table.insert (results, values[i])
		end
	end
	return results
end


function unn:get_error (nn_output, right_output)
	local err = 0
	for i, v in pairs (nn_output) do
--		print (nn_output[i] .. ' ' .. right_output[i])
		err = err + (nn_output[i]-right_output[i])^2
	end
	return err
end

function unn:mutate (chance, value)
	local weights = {}
	local flag = false
	for i = 1, #self.weights do
		local weight = self.weights[i]
		local delta = 0
		if math.random(#self.weights) <= 2 then
			if math.random(6) == 1 then
				delta = value*2*(math.random()-0.5)
			end
			if math.random(4) == 1 then
				weight = weight*2*math.random()
			end
			if math.random(2) == 1 then
				weight = -weight
			end
			if math.random(6*6) == 1 then
				weight = 0
				delta = 0
				flag = true
			end
		end
		weights[i] = weight + delta
	end
	
	local biases = {}
	for i = 1, #self.biases do
		local bias = self.biases[i]
		local delta = 0
		if math.random(#self.biases) <= 2 then
			if math.random(6) == 1 then
				delta = value*2*(math.random()-0.5)
			end
			if math.random(4) == 1 then
				bias = bias*2*math.random()
			end
			if math.random(2) == 1 then
				bias = -bias
			end
			if math.random(6*6) == 1 then
				bias = 0
				delta = 0
				flag = true
			end
		end
		biases[i] = bias + delta
	end
	
	local nn = {}
--	nn.weights = self.weights
--	nn.biases = self.biases
	
	nn.id = self.id + 1
	nn.nodes = self.nodes
	nn.feed = unn.feed
	nn.get_error = unn.get_error
	nn.mutate = unn.mutate
	
	nn.biases = biases
	nn.weights = weights
	nn.input_nodes_max=self.input_nodes_max
	return nn, flag
end











