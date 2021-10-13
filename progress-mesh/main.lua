-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function love.load()
	-- nothing here

end

local ddwidth, ddheight = love.window.getDesktopDimensions( display )
if ddheight > 1080 then
	print('ddheight: ' .. ddheight)
	love.window.setMode(1920, 1080, {resizable=true, borderless=false})
else
	love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
end
width, height = love.graphics.getDimensions( )

step = 10

local verticesbg = {} -- background
for i = 0, 180, step do
	table.insert(verticesbg, {
			width/2 + 500*math.cos(math.rad(i)), 
			0.8*height-500*math.sin(math.rad(i)), 0, 0, 0,1,1, 0.25})
	table.insert(verticesbg, {
			width/2 + 600*math.cos(math.rad(i)), 
			0.8*height-600*math.sin(math.rad(i)), 0, 0, 1,0,1, 0.25})
end
meshbg = love.graphics.newMesh( verticesbg, "strip")

function love.update(dt)
	local vertices = {}
	local t = (math.cos(love.timer.getTime())+1)/2

	for i = 0, t*180, step do
		table.insert(vertices, {width/2 - 500*math.cos(math.rad(i)), 0.8*height-500*math.sin(math.rad(i)), 0, 0, 1,0,1}) -- magenta
		table.insert(vertices, {width/2 - 600*math.cos(math.rad(i)), 0.8*height-600*math.sin(math.rad(i)), 0, 0, 0,1,1}) -- cian
	end
	
	-- last two points:
	t = t*180 
	table.insert(vertices, {width/2 - 500*math.cos(math.rad(t)), 0.8*height-500*math.sin(math.rad(t)), 0, 0, 1,0,1}) -- magenta
	table.insert(vertices, {width/2 - 600*math.cos(math.rad(t)), 0.8*height-600*math.sin(math.rad(t)), 0, 0, 0,1,1}) -- cian

	mesh = love.graphics.newMesh( vertices, "strip") -- recreate the mesh
end

function love.draw()
	love.graphics.draw(meshbg, 0, 0) -- draw background
	love.graphics.draw(mesh, 0, 0) -- draw progress-rainbow
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