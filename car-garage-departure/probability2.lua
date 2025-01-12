local function generateSlotIndex(totalCars, totalSlots)
	local sum = 0
	local r = math.random()
	print('random number: '..r)
	local result
	for k = 1, totalSlots do
		local prob = 1
		for i = 1, k - 1 do
			prob = prob * (totalSlots - totalCars - i + 1) / (totalSlots - i + 1)
		end
		prob = prob * totalCars / (totalSlots - k + 1)
		sum = sum + prob
		print(k, 'prob:'..prob, 'sum:'..sum)
		if r <= sum and not result then
			result = k
		end
		if sum >= 1 then break end
	end
	return result
end

-- example usage:
local totalCars = 2
local totalSlots = 4
math.randomseed(os.time())
local index = generateSlotIndex(totalCars, totalSlots)
print('selected slot index: ' .. index)
