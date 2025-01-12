local function calculateProbability(slotIndex, totalCars, totalSlots)
	if slotIndex > totalCars then
		return 0
	end
	local prob = 1
	for i = 1, slotIndex - 1 do
		prob = prob * (totalSlots - totalCars - i + 1) / (totalSlots - i + 1)
	end
	return prob * totalCars / (totalSlots - slotIndex + 1)
end

local function generateProbabilities(totalCars, totalSlots)
	local probabilities = {}
	local sum = 0
	for k = 1, totalSlots do
		local probability = calculateProbability(k, totalCars, totalSlots)
		sum = sum + probability
		table.insert(probabilities, sum)
		if sum >= 1 then break end
	end


	print('totalCars: '.. totalCars, 'totalSlots: '..totalSlots)
	print('Probabilities:')
	print('{'..table.concat(probabilities, ',')..'}')


	return probabilities
end

local totalCars = 19
local totalSlots = 20

local probabilities = generateProbabilities(totalCars, totalSlots)

local function getSlotIndex(probabilities)
	math.randomseed(os.time())

	local r = math.random()
	print (r)
	for i, prob in ipairs(probabilities) do
		if r <= prob then
			return i
		end
	end
	return #probabilities
end

local slotIndex = getSlotIndex(probabilities)
print ('slotIndex: '.. slotIndex)
