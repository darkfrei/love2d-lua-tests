-- License CC0 (Creative Commons license) (c) darkfrei, 2022

-- easy physics for LÖVE (Love2D)

local easy = {}


function easy:load (data)
	data = data or {}
--	data is table with:
	-- objects are no larger than 10 meters!
	local meter = data.meter or 40
	love.physics.setMeter(meter)
	self.gravity = data.gravity or 9.81
	self.Xgravity = data.Xgravity or 0
	self.worldSleep = data.worldSleep or true
	self.world = love.physics.newWorld(meter*self.Xgravity, meter*self.gravity, self.worldSleep)
	self.objects = {}
end

function easy:newObject (data)
	
	local typ = data.type or "static" -- "dynamic", "static" or "kinematic"
	
	local x = data.x or 0
	local y = data.y or 0
--	local world = self.world
	local body = love.physics.newBody(self.world, x, y, typ)
	local width = data.w
	local height = data.h
	local angle = data.angle or 0
	local r = data.r
	local shape, form
	if width and height then
		-- rectangle / polygon
		shape = love.physics.newRectangleShape(0, 0, width, height, angle)
--		shape = love.physics.newRectangleShape(width, height)
		form = "polygon"
	elseif r then
		-- circle
		shape = love.physics.newCircleShape(r)
		form = "circle"
	end
	local density = data.de or 1
	local fixture = love.physics.newFixture(body, shape, density)
	local restitution = data.re
	if restitution then
		fixture:setRestitution (restitution)
	end
	local object = {
		body=body,
		shape=shape,
		fixture=fixture,
		form=form,
		color=data.color,
		outlineColor=data.oColor,
		}
	table.insert(self.objects, object)
	return object
end

function easy:update (dt)
	self.world:update(dt)
end

function easy.drawObject (object)
	local color = object.color
	if color then love.graphics.setColor(color) end
	if object.form == "polygon" then
		local polygon = {object.body:getWorldPoints(object.shape:getPoints())}
		love.graphics.polygon("fill", polygon)
		local outlineColor = object.outlineColor
		if outlineColor then
			love.graphics.setColor(outlineColor)
			love.graphics.polygon("line", polygon)
		end
	elseif object.form == "circle" then
		local x, y, r = object.body:getX(), object.body:getY(), object.shape:getRadius()
		love.graphics.circle("fill", x, y, r)
		local outlineColor = object.outlineColor
		if outlineColor then
			love.graphics.setColor(outlineColor)
			love.graphics.circle("line", x, y, r)
		end
	end
end

function easy:draw ()
	for i, object in ipairs ( self.objects ) do
		easy.drawObject (object)
	end
end


return easy
