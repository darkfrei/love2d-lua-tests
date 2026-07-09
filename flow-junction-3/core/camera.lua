-- core/camera.lua
-- camera system for zooming and canvas panning

local Camera = {}
Camera.__index = Camera

local MIN_SCALE = 0.05
local MAX_SCALE = 8

function Camera.new()
	local self = setmetatable({}, Camera)

	-- camera position in world space
	self.x = 0
	self.y = 0

	-- current zoom level
	self.scale = 0.6

	-- panning state
	self._panActive = false
	self._panLast = { x = 0, y = 0 }

	return self
end

function Camera:apply()
	love.graphics.push()

	local sw, sh = love.graphics.getDimensions()

	love.graphics.translate(sw / 2, sh / 2)
	love.graphics.scale(self.scale)
	love.graphics.translate(-self.x, -self.y)
end

function Camera:pop()
	love.graphics.pop()
end

function Camera:toWorld(sx, sy)
	local sw, sh = love.graphics.getDimensions()

	local wx = (sx - sw / 2) / self.scale + self.x
	local wy = (sy - sh / 2) / self.scale + self.y

	return wx, wy
end

function Camera:toScreen(wx, wy)
	local sw, sh = love.graphics.getDimensions()

	local sx = (wx - self.x) * self.scale + sw / 2
	local sy = (wy - self.y) * self.scale + sh / 2

	return sx, sy
end

function Camera:zoom(clicks, sx, sy)
	local wx, wy = self:toWorld(sx, sy)

	local factor = (clicks > 0) and 1.15 or (1 / 1.15)

	self.scale = math.max(MIN_SCALE, math.min(MAX_SCALE, self.scale * factor))

	local sw, sh = love.graphics.getDimensions()

	self.x = wx - (sx - sw / 2) / self.scale
	self.y = wy - (sy - sh / 2) / self.scale
end

function Camera:startPan(sx, sy)
	-- start panning operation
	self._panActive = true
	self._panLast.x = sx
	self._panLast.y = sy
end

function Camera:updatePan(sx, sy)
	if not self._panActive then
		return
	end

	local dx = (sx - self._panLast.x) / self.scale
	local dy = (sy - self._panLast.y) / self.scale

	self.x = self.x - dx
	self.y = self.y - dy

	self._panLast.x = sx
	self._panLast.y = sy
end

function Camera:endPan()
	-- stop panning operation
	self._panActive = false
end

function Camera:isPanning()
	return self._panActive
end

function Camera:fitAll(map)
	if not next(map.nodes) then
		return
	end

	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge

	for _, n in pairs(map.nodes) do
		minX = math.min(minX, n.x)
		minY = math.min(minY, n.y)
		maxX = math.max(maxX, n.x)
		maxY = math.max(maxY, n.y)
	end

	local pad = 100

	local mapW = (maxX - minX) + pad * 2
	local mapH = (maxY - minY) + pad * 2

	self.x = (minX + maxX) / 2
	self.y = (minY + maxY) / 2

	local sw, sh = love.graphics.getDimensions()

	local scaleX = sw / mapW
	local scaleY = sh / mapH

	self.scale = math.max(MIN_SCALE, math.min(MAX_SCALE, math.min(scaleX, scaleY)))
end

return Camera