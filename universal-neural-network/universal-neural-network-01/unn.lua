unn = {}


function unn:new(nodes_amount)
	local weights = {}
	local biases = {}
	local nodes = {}
	for i = 1, nodes_amount do
		local node = {}
		for j = 1, #nodes do
			local weight = math.random(0, 2048)/1024-1
			table.insert (weights, weight)
			table.insert (node, #weights) -- the number of weight
		end
		table.insert(nodes, node)
		table.insert(biases, math.random(0, 2048)/1024-1)
	end
	local id = 1
	self = {id = id, weights=weights, nodes=nodes, biases=biases}
	self.feed = unn.feed
	self.get_error = unn.get_error
	self.mutate = unn.mutate
	return self
end


function activation (value, a)
	local a = a or 1
	if value >= 0 then
		return a*value
	else
		return -math.log(-a*value+1)
	end
end


function unn:feed (input_values, n_outputs)
	local values = {}
	local results = {}
	local n_nodes = #self.nodes
	for i = 1, n_nodes do
		if input_values[i] then
			values[i] = input_values[i]
		else
			local summ = self.biases[i]
			local node = self.nodes[i]
			for j, i_weight in pairs (node) do
				local value = values[j]
				local weight = self.weights[i_weight]
				summ = summ + activation(value*weight)
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
	for i = 1, #self.weights do
		local weight = self.weights[i]
		local delta = 0
		if math.random() < chance then
			delta = value*2*(math.random()-0.5)
--			print ('delta: ' .. delta)
		end
		weights[i] = weight + delta
	end
	
	local biases = {}
	for i = 1, #self.biases do
		local bias = self.biases[i]
		local delta = 0
		if math.random() < chance then
			delta = value*2*(math.random()-0.5)
--			print ('delta: ' .. delta)
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
	return nn
end











