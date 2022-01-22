-- License CC0 (Creative Commons license) (c) darkfrei, 2022

function love.load()
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	width, height = love.graphics.getDimensions( )

	explosions = {}
	nFrames = 17
	image = love.graphics.newImage ('explosion.png') -- image 1088x64, 17 frames 64x64 in one line
	frames = {}
	for i = 1, nFrames do -- https://sheepolution.com/learn/book/17
		local x = 64*(i-1)
		local quad = love.graphics.newQuad(x, 0, 64, 64, image:getDimensions())		
		table.insert (frames, quad)
	end
end

local function newExplosion (x, y)
	local explosion = {}
	explosion.valid = true
	explosion.x = x
	explosion.y = y
	explosion.r = math.pi/2 * math.random (0, 3)
	explosion.image = image
	explosion.time = love.timer.getTime( )
	explosion.tFrame = 1/30
	return explosion
end
 
function love.update(dt)
	
end

local function fastRemove (explosions, i)
	explosions[i] = explosions[#explosions]
	explosions[#explosions] = nil
end

function love.draw()
	for i, explosion in ipairs (explosions) do
		local image = explosion.image
		local x, y, r = explosion.x, explosion.y, explosion.r
		local currentFrame = math.floor((love.timer.getTime( ) - explosion.time)/explosion.tFrame)+1
		if frames[currentFrame] then
			love.graphics.draw(explosion.image, frames[currentFrame], x, y, r, 1, 1, 32, 32)
		else
			explosion.valid = false
		end
	end
	for i, explosion in ipairs (explosions) do
		if not explosion.valid then
			fastRemove (explosions, i)
		end
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
		table.insert (explosions, newExplosion (x, y))
	elseif button == 2 then -- right mouse button
	end
end