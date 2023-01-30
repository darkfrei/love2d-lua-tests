-- License CC0 (Creative Commons license) (c) darkfrei, 2023

love.window.setMode(800, 800)
W, H = love.graphics.getDimensions( )

function love.load()
	local image = love.graphics.newImage('img-16.png')
	image:setWrap( "repeat" )
	image:setFilter("linear", "nearest")

	local n = 6 -- amount of tiles
	local k = 128 -- size of tile
	local s = n*k -- size of screen
	
	local vertices = {
		{0, 0, 0, 0, 1,1,1},
		{s, 0, n, 0, 1,1,1},
		{0, s, 0, n, 1,1,1},
		{s, s, n, n, 1,1,1},
	}
	mesh = love.graphics.newMesh( vertices, "strip")
	mesh:setTexture(image)
	Angle = 0
	
	RE = {angle = 0, x=0, y=0, w=128*n, h=128*n}
end

local function rotateMesh (mesh, s, n, angle)
	local u1 =  n*math.cos(angle)
	local u2 =  n*math.sin(angle)
	local v1 =  n*math.sin(angle)
	local v2 = -n*math.cos(angle)
	mesh:setVertex(2, s, 0, u1, v1)
	mesh:setVertex(3, 0, s, u2, v2)
	mesh:setVertex(4, s, s, u1+u2, v1+v2)
end
 
function love.update(dt)
	Angle = Angle + 0.1*dt
	RE.angle = RE.angle + 0.1*dt
	local n, s = 6, 128*6
	rotateMesh (mesh, s, n, Angle)
end


function love.draw()
	local mx, my = love.mouse.getPosition()
	love.graphics.translate (mx, my)
	
	love.graphics.draw(mesh)
	
	-- to check the geomery
	local w = (RE.x+RE.w)*math.cos(RE.angle)
	local w2 = (RE.y+RE.h)*math.sin(RE.angle)
	local h = (RE.y+RE.h)*math.sin(RE.angle)
	local h2 = -(RE.x+RE.w)*math.cos(RE.angle)
	
	love.graphics.line (
		RE.x, RE.y, 
		RE.x+w, RE.y+h,
		RE.x+w-w2, RE.y+h-h2, 
		RE.x-w2, RE.y-h2)
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
	elseif button == 2 then -- right mouse button
	end
end