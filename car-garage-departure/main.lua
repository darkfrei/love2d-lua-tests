local function generateSlotIndex(totalCars, totalSlots)
	local sum = 0
	local r = math.random()  -- generate a random number
	local result
	for k = 1, totalSlots do
		local prob = 1
		-- calculate the probability for the current index
		for i = 1, k - 1 do
			prob = prob * (totalSlots - totalCars - i + 1) / (totalSlots - i + 1)
		end
		prob = prob * totalCars / (totalSlots - k + 1)  -- adjust the probability for the k-th index

		sum = sum + prob  -- accumulate the probability
		if r <= sum and not result then
			result = k  -- set result to k if random number is less than or equal to the accumulated probability
		end
		if sum >= 1 then break end  -- stop if accumulated probability reaches 1
	end
	return result
end

local function getSlots(totalCars, totalSlots)
	local slotIndex = 0  -- initialize the slot index
	local restCars = totalCars  -- remaining cars to assign
	local restSlots = totalSlots  -- remaining slots to assign
	local slots = {}  -- table to store the assigned slots

	for carIndex = 1, totalCars do
		local index = generateSlotIndex(restCars, restSlots)  -- generate a random slot index
		slotIndex = slotIndex + index
		slots[slotIndex] = 1 -- assign the slot index to the list
		restCars = restCars - 1  -- decrease the number of remaining cars
		restSlots = restSlots - index  -- decrease the number of remaining slots
	end

	return slots  -- return the list of assigned slots
end

local totalCars = 10
local totalSlots = 20
local diagram1 = {}
local amountSimulations = 0

for i = 1, totalSlots do
	diagram1[i] = 0
end

local function updateDiagram(slots)
	amountSimulations = amountSimulations + 1  -- increment the number of simulations
	for slotIndex, carIndex in pairs(slots) do
		diagram1[slotIndex] = diagram1[slotIndex] + 1  -- update the diagram with the assigned slots
	end
end

function love.load()
	love.graphics.setBackgroundColor(0.1, 0.1, 0.1)  -- set the background color
	love.graphics.setColor(1, 1, 1)  -- set the drawing color

	for slotIndex = 1, totalSlots do
		diagram1[slotIndex] = 0  -- reset the diagram
	end

	local slots = getSlots(totalCars, totalSlots)  -- generate slots
	updateDiagram(slots)  -- update the diagram with the generated slots
end

function love.keypressed(key, scancode)
	if key == 'space' then
		local slots = getSlots(totalCars, totalSlots)  -- generate new slots on key press
		updateDiagram(slots)  -- update the diagram with the new slots
	elseif key == 'z' then
		for i = 1, 1000000 do  -- simulate a large number of slot assignments for stress testing
			local slots = getSlots(totalCars, totalSlots)  -- generate new slots
			updateDiagram(slots)  -- update the diagram with the new slots
		end
	end
end

function love.draw()
	local barWidth = 30  -- width of each bar in the diagram
	local barSpacing = 5  -- space between bars
	local startX = 50  -- starting X position for the bars
	local startY = 500  -- starting Y position for the bars
	local maxBarHeight = 400  -- maximum height for the bars

	-- find the maximum value for the diagram
	local maxDiagram = 0
	for slotIndex, amount in ipairs(diagram1) do
		maxDiagram = math.max(maxDiagram, amount)  -- get the highest value from the diagram
	end

	-- draw the diagram bars
	for slotIndex, amount in ipairs(diagram1) do
		local x = startX + (slotIndex - 1) * (barWidth + barSpacing)
		local barHeight = maxBarHeight * amount / maxDiagram  -- calculate bar height based on the amount
		local y = startY - barHeight

		love.graphics.setColor(1, 0.3, 0.3)  -- set the bar color
		love.graphics.rectangle("fill", x, y, barWidth, barHeight)  -- draw the bar
		love.graphics.setColor(1, 1, 1)  -- reset the drawing color
		love.graphics.print(tostring(slotIndex), x, startY + 5)  -- print the slot index
		love.graphics.printf(string.format("%d", amount), x, y - 15, barWidth, "center")  -- print the amount above the bar
	end

	-- draw the first car's distribution diagram
	local startYFirstCar = startY + 300

	-- simulation info
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("garage departure simulation (press SPACE to add simulation)", 10, 10)
	love.graphics.print("garage departure simulation (press Z for 1 000 000 simulations)", 10, 10+14)
	love.graphics.print("total simulations: " .. amountSimulations, 10, 10+14+14)
end
