-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local dndo = {}

function dndo.load (objects)
	dndo.objects = objects
	print ('#objects: ' .. #objects)
end

local draw = {}
function draw.rectangle (object, fill, line)
	love.graphics.setColor(fill)
	love.graphics.rectangle ('fill', object.x, object.y, object.w, object.h)
	love.graphics.setColor(line)
	love.graphics.rectangle ('line', object.x, object.y, object.w, object.h)
end

function draw.circle (object, fill, line)
	love.graphics.setColor(fill)
	love.graphics.circle ('fill', object.x, object.y, object.r)
	love.graphics.setColor(line)
	love.graphics.circle ('line', object.x, object.y, object.r)
end

function dndo.draw ()
	for i, object in ipairs (dndo.objects) do
		if dndo.pressed and dndo.pressed == object then
			draw[object.type](object, object.color, object.pressedOutlineColor)
		elseif dndo.hovered and dndo.hovered == object then
			draw[object.type](object, object.color, object.hoveredOutlineColor)
		else
			draw[object.type](object, object.color, object.outlineColor)
		end
	end
end

local collisionWith = {}

function collisionWith.rectangle (x, y, object)
	if x > object.x and y > object.y 
		and x < object.x+object.w and y < object.y + object.h then
		return true
	end
	return false
end

function collisionWith.circle (x, y, object)
	if x > object.x - object.r and y > object.y - object.r
	and x < object.x+object.r and y < object.y + object.r then
		local dx = object.x-x
		local dy = object.y-y
		if (dx*dx+dy*dy) < object.r*object.r then
			return true
		else
			return false
		end
	end
	return false
end

function dndo.mousepressed( x, y, button, istouch, presses )
	if dndo.hovered then
		dndo.pressed = dndo.hovered
		dndo.hovered = nil
	end
end

local function checkHovered (x, y)
	for i = #dndo.objects, 1, -1 do -- backwards
		local object = dndo.objects[i]
		if collisionWith[object.type] (x, y, object) then
			dndo.hovered = object
			return
		end
	end
	dndo.hovered = nil
end

function dndo.mousemoved( x, y, dx, dy, istouch )
	if dndo.pressed then
		dndo.pressed.x = dndo.pressed.x+dx
		dndo.pressed.y = dndo.pressed.y+dy
	else
		-- check hovered
		checkHovered (x, y)
	end
end

function dndo.mousereleased( x, y, button, istouch, presses )
	if dndo.pressed then
		dndo.pressed = nil
		checkHovered (x, y)
	end
end

return dndo