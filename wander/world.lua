local World = {}

function World.wrap(value, size)
	return ((value % size) + size) % size
end

function World.wrapPoint(x, y, width, height)
	return World.wrap(x, width), World.wrap(y, height)
end

function World.shortestDelta(fromValue, toValue, size)
	local delta = (toValue - fromValue) % size
	if delta > size * 0.5 then
		delta = delta - size
	end
	return delta
end

function World.deltaVector(x1, y1, x2, y2, width, height)
	return World.shortestDelta(x1, x2, width), World.shortestDelta(y1, y2, height)
end

function World.randomPosition(rng, width, height, margin)
	margin = margin or 0

	local minX = math.max(0, margin)
	local minY = math.max(0, margin)
	local maxX = math.max(minX, width - margin)
	local maxY = math.max(minY, height - margin)

	return rng:random(minX, maxX), rng:random(minY, maxY)
end

local function drawShiftedLine(x1, y1, x2, y2, shiftX, shiftY)
	love.graphics.line(x1 + shiftX, y1 + shiftY, x2 + shiftX, y2 + shiftY)
end

function World.drawWrappedLine(x1, y1, x2, y2, width, height)
	local dx = x2 - x1
	local dy = y2 - y1

	local wrappedX = false
	local wrappedY = false
	local offsetX = 0
	local offsetY = 0

	if dx > width * 0.5 then
		x2 = x2 - width
		wrappedX = true
		offsetX = -width
	elseif dx < -width * 0.5 then
		x2 = x2 + width
		wrappedX = true
		offsetX = width
	end

	if dy > height * 0.5 then
		y2 = y2 - height
		wrappedY = true
		offsetY = -height
	elseif dy < -height * 0.5 then
		y2 = y2 + height
		wrappedY = true
		offsetY = height
	end

	love.graphics.line(x1, y1, x2, y2)

	if wrappedX then
		drawShiftedLine(x1, y1, x2, y2, -offsetX, 0)
	end

	if wrappedY then
		drawShiftedLine(x1, y1, x2, y2, 0, -offsetY)
	end

	if wrappedX and wrappedY then
		drawShiftedLine(x1, y1, x2, y2, -offsetX, -offsetY)
	end
end

return World