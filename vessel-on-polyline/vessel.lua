-- vessel.lua
local Vessel = {}
Vessel.__index = Vessel

-- creates new vessel instance
-- x, y: starting position
-- angle: initial facing angle
-- baseSpeed: movement capability pro turn
-- returns: new vessel object
function Vessel.new(x, y, angle, baseSpeed)
	local ship = {
		x = x, y = y, angle = angle,
		baseSpeed = baseSpeed,
		currentPath = nil,
		target = nil,
	}
	setmetatable(ship, Vessel)
	return ship
end

-- sets movement target for vessel
-- target: {x, y} position object
function Vessel:setTarget(target)
	self.target = target
	local currentPath, reached = PolyPath:getPlannedPath(self)
	self.currentPath = currentPath
end

local function calculateDistance(x1, y1, x2, y2)
	return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

function Vessel:update (progress)
-- updates vessel position based on path progress
-- progress: progress along path (0-1)
	if self.currentPath then
		local x, y, angle = self.currentPath:getPointAtProgress (progress)
		self.x, self.y, self.angle = x, y, angle
	end
end

-- renders vessel to screen
-- size: visual size of vessel
function Vessel:draw(size)
	size = size or 20
	local v1x = self.x + size * math.cos(self.angle)
	local v1y = self.y + size * math.sin(self.angle)
	local v2x = self.x + size * 0.5 * math.cos(self.angle + 2 * math.pi / 3)
	local v2y = self.y + size * 0.5 * math.sin(self.angle + 2 * math.pi / 3)
	local v3x = self.x + size * 0.5 * math.cos(self.angle - 2 * math.pi / 3)
	local v3y = self.y + size * 0.5 * math.sin(self.angle - 2 * math.pi / 3)
	love.graphics.polygon("fill", v1x, v1y, v2x, v2y, v3x, v3y)
end

return Vessel