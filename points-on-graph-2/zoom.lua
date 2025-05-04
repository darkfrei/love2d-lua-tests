-- zoom module for smooth scaling with mouse wheel relative to cursor
local zoom = {}

-- configuration
local zoomFactor = math.pow(2, 1/12)  -- scale multiplier per wheel tick
local minScale = 1  -- minimum allowed scale
local maxScale = 8.0  -- maximum allowed scale
local lerpSpeed = 5.0  -- speed of interpolation (units per second)

-- state
zoom.currentScale = 1.0  -- current display scale
zoom.targetScale = 1.0  -- target scale to interpolate towards

-- handles mouse wheel movement
function zoom.wheelmoved(x, y)
	if y ~= 0 then
		local factor = y > 0 and zoomFactor or 1 / zoomFactor
		zoom.targetScale = math.max(minScale, math.min(maxScale, zoom.targetScale * factor))
	end
end

-- updates scale interpolation
function zoom.update(dt)
	local diff = zoom.targetScale - zoom.currentScale
	if math.abs(diff) > 0.001 then
		zoom.currentScale = zoom.currentScale + diff * math.min(1.0, lerpSpeed * dt)
	end
end

-- applies current scale centered at mouse cursor
function zoom.apply()
	local mx, my = love.mouse.getPosition()
	love.graphics.translate(mx, my)
	love.graphics.scale(zoom.currentScale, zoom.currentScale)
	love.graphics.translate(-mx, -my)
end

return zoom