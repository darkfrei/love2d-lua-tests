print (... .. ' loaded')

local utils = {}

function utils.linearInterpolate(a, b, t)
	return a + (b - a) * t
end

function utils.angleDifference(a, b)
	local diff = (b - a + math.pi) % (2 * math.pi) - math.pi
	return diff
end

function utils.calculateDistance(x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	return math.sqrt(dx * dx + dy * dy)
end

function utils.getDirectionVector(angle)
	return math.cos(angle), math.sin(angle)
end

function utils.getShipFinalAngle(ship)
	return math.atan2(ship.targetY - ship.startY, ship.targetX - ship.startX)
end

-- helper function to normalize angle between -π and π
function utils.normalizeAngle(angle)
	return (angle + math.pi) % (2 * math.pi) - math.pi
end

return utils