local World = require("world")

local function distanceSquared(x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1

	return dx * dx + dy * dy
end

local function drawNode(x, y, radius)
	love.graphics.circle("fill", x, y, radius)
end


local function drawSegment(color, lineWidth, x1, y1, x2, y2, width, height, radius, second)
	love.graphics.setColor(color)
	love.graphics.setLineWidth(lineWidth)

	World.drawWrappedLine(
		x1, -- trail.lastX,
		y1, -- trail.lastY,
		x2,
		y2,
		width, -- settings.world.width,
		height -- settings.world.height
	)

	-- draw node at connection point (fix gaps)
--	drawNode(trail.lastX, trail.lastY, settings.trail.nodeRadius)
	if second then
		drawNode(x1, y1, radius)
--		drawNode(x2, y2, radius)
	else
--		drawNode(x1, y1, radius)
		drawNode(x2, y2, radius)
	end
--	drawNode(x2, y2, settings.trail.nodeRadius)
end


local Trail = {}

function Trail.new(settings)
	local canvas = love.graphics.newCanvas(
		settings.world.width,
		settings.world.height
	)

	canvas:setFilter("linear", "linear")

	local trail = {
		canvas = canvas,
		settings = settings,

		lastX = nil,
		lastY = nil,
	}

	Trail.clear(trail)

	return trail
end

function Trail.clear(trail)
	love.graphics.push("all")

	love.graphics.setCanvas(trail.canvas)
	love.graphics.clear(0, 0, 0, 0)

	trail.lastX = nil
	trail.lastY = nil

	love.graphics.setCanvas()

	love.graphics.pop()
end

function Trail.addSegment(trail, x1, y1, x2, y2)
	local settings = trail.settings

	if not trail.lastX then
		trail.lastX = x1
		trail.lastY = y1
	end

	local dx = x2 - trail.lastX
	local dy = y2 - trail.lastY
	local distSq = dx * dx + dy * dy

	local minLen = settings.trail.minSegmentLength
	local minLenSq = minLen * minLen

	if distSq < minLenSq then
		return
	end

	local color = settings.trail.color
	local lineWidth = settings.trail.lineWidth
	local width = settings.world.width
	local height = settings.world.height
	local radius = settings.trail.nodeRadius
	x1, y1 = trail.lastX, trail.lastY
	
	love.graphics.push("all")
	love.graphics.setCanvas(trail.canvas)

	-- draw line (opaque mask)
	love.graphics.setBlendMode("replace")

--	drawSegment()
	drawSegment({0.1,0.1,0.1}, lineWidth+6, x1, y1, x2, y2, width, height, radius+3)
	
	
	drawSegment(color, lineWidth, x1, y1, x2, y2, width, height, radius, true)


	love.graphics.setCanvas()
	love.graphics.pop()

	trail.lastX = x2
	trail.lastY = y2
end

function Trail.draw(trail)
	local settings = trail.settings

	love.graphics.push("all")

	love.graphics.setBlendMode("alpha")

	love.graphics.setColor(
		1,
		1,
		1,
		settings.trail.alpha
	)

	love.graphics.draw(trail.canvas, 0, 0)

	love.graphics.pop()
end

return Trail