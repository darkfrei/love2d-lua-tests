-- License CC0 (Creative Commons license) (c) darkfrei, 2023

local modes = love.window.getFullscreenModes( 1 )
print (modes[1].width, modes[1].height)
if modes[1].width == 3840 and modes[1].height == 2160 then
	print ('4k')
	love.window.updateMode( 1920, 1080 )
end
width, height = love.window.getMode( )

grid = {
	{0,0,1,1,0,0,1,1,0,1,},
	{0,0,0,0,0,0,0,0,0,0,},
	{1,1,0,0,1,1,0,1,1,0,},
	{0,0,1,0,0,0,0,0,0,1,},
	{0,0,0,0,0,0,0,0,0,0,},
	{1,1,0,1,1,1,0,1,1,0,},
}
agent = {
	-- in grid positions
	x=1.5,
	y=1.5,
--	angle=math.rad(16),
	angle=0,
	maxRay = 6,
}

function love.load()
	
end

 
function love.update(dt)
	local up    = love.keyboard.isScancodeDown('w', 'up')
	local down  = love.keyboard.isScancodeDown('s', 'down')
	local left  = love.keyboard.isScancodeDown('a', 'left')
	local right = love.keyboard.isScancodeDown('d', 'right')
	if up or down then
		local v = 1.5 -- in tiles
		if down then v = -v end
		agent.x = agent.x + v*dt*math.cos(agent.angle)
		agent.y = agent.y + v*dt*math.sin(agent.angle)
	end
	if left or right then
		local omega = 0.3
		if left then omega = -omega end
		agent.angle = agent.angle + omega*dt
	end
end

function isTile (grid, x, y, value, noTile)
	-- position in grid format:
	-- (1.4,2.8) is (1, 2);
	-- (0,0) dosn't exist, the lowest is (1,1)
	x, y = math.floor (x), math.floor (y)
	if grid[y] and grid[y][x] then -- exists
		if grid[y][x] == value then
--			print ('rounded', x, y)
			return true
		end
		return false
	end
--	print ('noTile', x, y)
	return noTile-- not exists, the tile too, as collision
end

function drawRectangle (mode, x, y, gridSize)
	love.graphics.rectangle(mode, (x-1)*gridSize, (y-1)*gridSize, gridSize, gridSize)
end

function drawCircle (mode, x, y, r, gridSize)
	love.graphics.circle(mode, (x-1)*gridSize, (y-1)*gridSize, r*gridSize)
end

function drawBoid (mode, x, y, angle, gridSize) -- position, length, width and angle
	local length, width = 0.5*gridSize, 0.3*gridSize
	local length1, length2 = length*0.3, length*0.7
	love.graphics.push()
	love.graphics.translate((x-1)*gridSize, (y-1)*gridSize)
	love.graphics.rotate( angle )
	love.graphics.polygon(mode, -length1, -width /2, -length1, width /2, length2, 0)
	love.graphics.pop() 
end

function drawLine (x1, y1, x2, y2, gridSize)
	love.graphics.line ((x1-1)*gridSize, (y1-1)*gridSize, (x2-1)*gridSize, (y2-1)*gridSize)
end

function drawRay (x1, y1, angle, length, gridSize)
	local x2 = x1 + length*math.cos (angle)
	local y2 = y1 + length*math.sin (angle)
	drawLine (x1, y1, x2, y2, gridSize)
end

function drawDiagonals(x, y, gridSize)
--	print (x, y, gridSize)
	drawLine (x, y, x+1, y+1, gridSize)
	drawLine (x, y+1, x+1, y, gridSize)
end

--function getDiagonalMarch (angle)
----	https://www.desmos.com/calculator/jmvgydivg3
--	angle = angle % (2*math.pi)
--	local dx = math.abs(math.cos(angle))
--	local dy = math.abs(math.sin(angle))
--	local k = 1 / (dx + dy)
--	if angle < math.pi/2 then
--		return dx * k, dy * k, k
--	elseif angle < math.pi then
--		return -dx * k, dy * k, k
--	elseif angle < math.pi*3/2 then
--		return -dx * k, -dy * k, k
--	else
--		return dx * k, -dy * k, k
--	end
--end


function getDiagonalMarch(angle)
    angle = angle % (2*math.pi)
    local dx = math.cos(angle)
    local dy = math.sin(angle)
    local k = 1 / (math.abs(dx) + math.abs(dy))
    return dx * k, dy * k, k
end


function love.draw()
--	local gridSize = 180
	local gridSize = height/#grid
	love.graphics.setLineWidth(2)
	
	for y, xs in ipairs (grid) do
		for x, value in ipairs (xs) do
			love.graphics.setColor (0.6,0.6,0.6)
			if isTile (grid, x, y, 1, false) then
				drawRectangle ('fill', x, y, gridSize)
			else
				drawRectangle ('line', x, y, gridSize)
			end
			love.graphics.setColor (0.4,0.4,0.4)
			drawDiagonals(x, y, gridSize)
		end
	end
	

	
	love.graphics.setLineWidth(4)
	
	local dx, dy, k = getDiagonalMarch (agent.angle)
	for i = 1, agent.maxRay/k do
		local x, y = agent.x+i*dx, agent.y+i*dy
		if isTile (grid, x, y, 1, true) then
			love.graphics.setColor (1,1,0)
			drawRectangle ('line', math.floor(x), math.floor(y), gridSize)
			drawCircle ('fill', x, y, 0.1, gridSize)
			drawLine (x, y, math.floor(x)+0.5, math.floor(y)+0.5, gridSize)
		else
			love.graphics.setColor (0,1,1)
			drawRectangle ('line', math.floor(x), math.floor(y), gridSize)
			drawCircle ('line', x, y, 0.1, gridSize)
			drawLine (x, y, math.floor(x)+0.5, math.floor(y)+0.5, gridSize)
		end
	end
	
	love.graphics.setColor (0.5,0.5,0.5)
	drawRay (agent.x, agent.y, agent.angle, agent.maxRay, gridSize)
	love.graphics.setColor (1,1,1)
	drawBoid ("fill", agent.x, agent.y, agent.angle, gridSize)
	love.graphics.setColor (0,0,0)
	drawCircle ('fill', agent.x, agent.y, 0.03, gridSize)
end

local function calculateNearestDiagonal(x, y)
-- x, y - point position
-- y1 = x; y2 = 1-x - tile diagonals in range x=[0, 1]
  local dx, dy = x%1, y%1
	local t1 = (dy-dx)/2
	local t2 = (dy-(1-dx))/2
	dx = dx+math.floor(x)
	dy = dy+math.floor(y)
	if math.abs (t1) < math.abs (t2) then
		return dx + t1, dy - t1, t1
	else
		return dx - t2, dy - t2, t2
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "space" then
--		agent.x = math.floor(agent.x*2+0.5)/2
--		agent.y = math.floor(agent.y*2+0.5)/2
		agent.x, agent.y = calculateNearestDiagonal(agent.x, agent.y)
	elseif key == "escape" then
		love.event.quit()
	end
end