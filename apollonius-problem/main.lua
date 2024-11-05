-- 

local apollonius = require ('apollonius')

local c1 = {x=400, y=500, r=50}
local c2 = {x=600, y=500, r=50}
local c3 = {x=350, y=400, r=50}

--local c4 = apollonius.ccc (c1, c2, c3) -- wrong

local c5 = apollonius.ppp (c1, c2, c3) -- ok

local l1 = {x1=0, y1=100, x2=800, y2=100}
local l2 = {x1=200, y1=0, x2=200, y2=600}
local l3 = {x1=0, y1=600, x2=600, y2=0}

local c6, c6a, c6b, c6c = apollonius.lll (l1, l2, l3)

local function drawCircle (...)
	for _, c in ipairs({...}) do
		love.graphics.circle ('line', c.x, c.y, c.r)
		love.graphics.circle ('fill', c.x, c.y, 2)
	end
end

local function drawPoint (p)
	love.graphics.circle ('fill', p.x, p.y, 4)
end


local function drawLine (l)
	if not l.line then
		local a, b, c = l.a, l.b, l.c
		local screenWidth, screenHeight = love.graphics.getDimensions()
		if b == 0 then
			-- vertical line
			local x = -c/a
			local line = {x, 0, x, screenHeight}
			l.line = line
		elseif a == 0 then
			-- horizontal line
			local y = -c/b
			local line = {0, y, screenWidth, y}
			print ('line', 0, y, screenWidth, y)
			l.line = line
		else
			local y1 = -c/b
			local y2 = -(a*screenWidth+c)/b
			local line = {0, y1, screenWidth, y2}
			print ('line', 0, y1, screenWidth, y2)
			l.line = line
		end
	end
--	love.graphics.line (l.line)
	love.graphics.line (l.x1, l.y1, l.x2, l.y2)
end

function love.draw ()
	love.graphics.setColor (1,1,1)
	
	drawPoint (c1)
	drawPoint (c2)
	drawPoint (c3)

	-- results:
--	drawCircle (c4) -- wrong
	drawCircle (c5) -- ok

	love.graphics.setColor (1,0,0)
	drawLine (l1)
	love.graphics.setColor (1,1,0)
	drawLine (l2)
	love.graphics.setColor (0,1,0)
	drawLine (l3)

	love.graphics.setColor (1,1,1, 0.75)
	drawCircle (c6)
	love.graphics.setColor (1,0,0, 0.75)
	drawCircle (c6a)
	love.graphics.setColor (1,1,0, 0.75)
	drawCircle (c6b)
	love.graphics.setColor (0,1,0, 0.75)
	drawCircle (c6c)
end