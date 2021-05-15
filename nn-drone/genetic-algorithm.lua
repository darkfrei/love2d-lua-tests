ga = {}

local rnd = function () return math.random()*2-1 end

function ga.new_wb(layer_nodes)
	local wb = {}
	for i = 2, #layer_nodes do
		for j = 1, layer_nodes[i] do
			local b = rnd()
			table.insert(wb, b)
			for k = 1, layer_nodes[i-1] do
				local w = rnd()
				table.insert(wb, w)
			end

		end
	end
	return wb
end

local activate = function (x)
	return 1/(1+math.exp(-x))
--	return x < 0 and (math.exp(x)-1) or x
end

function ga.update (layer_nodes, input, wb)
	local layers = {input}
	local n = 1
	for i = 2, #layer_nodes do
		layers[i] = {}
		for j = 1, layer_nodes[i] do
			local summ = wb[n]
			n=n+1
			for k = 1, layer_nodes[i-1] do
				summ=summ+wb[n]*layers[i-1][k]
				n=n+1
			end
			layers[i][j] = activate (summ)
		end
	end
	return (layers[#layers])
end


function ga.mutate_wb (old_wb, factor)
	factor = factor or 1
	local wb = {}
	for i, v in pairs (old_wb) do
		if math.random (2) == 1 then
			local sign = v >= 1 and 1 or -1
			wb[i] = v - factor*2*sign*math.random()^2
		else
			wb[i] = v * (1+factor*math.random()^2)
		end
	end
	return wb
end

function ga.cross (wb1, wb2)
	local wb = {}
	for i, v in pairs (wb1) do
		local case = math.random (3)
		if case == 1 then
			wb[i] = wb1[i]
		elseif case == 2 then
			wb[i] = wb2[i]
		elseif wb1[i] == wb2[i] then
			local factor = 1
			if math.random (2) == 1 then
				local sign = v >= 1 and 1 or -1
				wb[i] = v - factor*2*sign*math.random()^4
			else
				wb[i] = v * (1+factor*math.random()^4)
			end
		else
			local a, b = wb1[i], wb2[i]
			wb[i] = a + (b-a)*math.random()
		end
	end
	return wb
end

return ga