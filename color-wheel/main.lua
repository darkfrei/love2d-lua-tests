-- License CC0 (Creative Commons license) (c) darkfrei, 2022

-- color-wheel
-- https://rosettacode.org/wiki/Color_wheel

-- HSV to RGB
local function hsv_to_rgb (h, s, v)  -- vlues in ranges: [0, 360], [0, 1], [0, 1]
	local r = math.min (math.max (3*math.abs (((h	    )/180)%2-1)-1, 0), 1)
	local g = math.min (math.max (3*math.abs (((h	-120)/180)%2-1)-1, 0), 1)
	local b = math.min (math.max (3*math.abs (((h	+120)/180)%2-1)-1, 0), 1)
	local k1 = v*(1-s)
	local k2 = v - k1
	return k1+k2*r, k1+k2*g, k1+k2*b
end

function love.load()
	local w, h, r = 256, 256, 128-0.5
	local cx, cy = w/2, h/2
	canvas = love.graphics.newCanvas ()
	love.graphics.setCanvas(canvas)
		for x = 0, w do
			for y = 0, h do
				local dx, dy = x-cx, y-cy
				if dx*dx + dy*dy <= r*r then
					local h = math.deg(math.atan2(dy, dx))
					local s = (dx*dx + dy*dy)^0.5/r
					local v = 1
					love.graphics.setColor (hsv_to_rgb (h, s, v))
					love.graphics.points (x, y)
				end
			end
		end
	love.graphics.setCanvas()
end

function love.draw()
	love.graphics.setColor (1,1,1)
	love.graphics.draw (canvas)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end
