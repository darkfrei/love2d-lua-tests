-- License CC0 (Creative Commons license) (c) darkfrei, 2022

-- perfect round:
--local w1 = math.rad(11.4734481640625)
--local w2 = math.rad(33.75)
--local k2 = 1.019591438

-- round, but line c is too short
--local w1 = math.rad(12.5)
--local w2 = math.rad(40.91612159)
--local k2 = 1.02315498

-- looks nice
--local w1 = math.rad(12.5)
--local w2 = math.rad(34.16565906)
--local k2 = 1

-- pretty nice
--local w1 = math.rad(11.5)
--local w2 = math.rad(34)
--local k1 = 0.25
--local k2 = 1.01476146

-- pixel-perfect
local w2 = math.rad(35)
local k1 = 0.246441158131046
local k2 = 1.015625


function hexadecagon (mode, x, y, radius) -- same as [[love.graphics.circle|circle]]
	local a = radius
--	local b = radius*math.sin (w1)
	local b = k1*radius
	local c = k2*radius*math.cos (w2)
	local d = k2*radius*math.sin (w2)
	local vertices = {
		 a, b,  c, d,  d, c,  b, a, 
		-b, a, -d, c, -c, d, -a, b, 
		-a,-b, -c,-d, -d,-c, -b,-a, 
		 b,-a,  d,-c,  c,-d,  a,-b}
	love.graphics.translate (x+0.5, y+0.5)
	love.graphics.polygon (mode, vertices)
	love.graphics.translate (-x-0.5, -y-0.5)
end

canvas = love.graphics.newCanvas()
canvas:setFilter("nearest", "nearest")
love.graphics.setLineStyle("rough")

Rmin = 3
Rmax = 50
R = 5
dR = 0.05

function love.update()
	R = R + dR
	if (R > Rmax) or (R < Rmin) then
		dR = -dR
		R = R + 2*dR
	end
	love.graphics.setCanvas (canvas)
		love.graphics.clear()
		love.graphics.setColor (0,1,0)
		hexadecagon ("line", 200, 100, R)
	love.graphics.setCanvas ()
end

function love.draw()
	love.graphics.setColor (1,1,1)
	love.graphics.draw (canvas,0,0,0,2)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end