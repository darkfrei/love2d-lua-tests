-- License CC0 (Creative Commons license) (c) darkfrei, 2021

title = "Metaballs"
--sms = require ('sms')

function love.load()
	love.window.setTitle( title )
	local ww, wh = love.window.getDesktopDimensions()
	love.window.setMode( ww/2, wh/2)
	width, height = love.graphics.getDimensions( )

	rez = 8
	map_width, map_height = math.floor((width-rez)/rez), math.floor((height-rez)/rez)
	
	blobs = {}
	for n = 1, 10 do
		local blob = {x=math.random (map_width), y=math.random(map_height)}
		blob.radius = math.random(10, 100)
		blob.rezradius = blob.radius / 32
		blob.vx = -math.random (50, 200)/rez
		blob.vy = -math.random (10, 200)/rez
		table.insert (blobs, blob)
	end
end

 
function love.update(dt)
	for n, blob in pairs (blobs) do
		blob.x = blob.x +dt*blob.vx
		blob.y = blob.y +dt*blob.vy
		if blob.x < blob.rezradius+0.5 then 
			blob.x = blob.rezradius+0.5
			blob.vx = -blob.vx
		elseif blob.x > map_width-blob.rezradius-0.5 then
			blob.x = map_width-blob.rezradius-0.5
			blob.vx = -blob.vx
		end
		
		if blob.y < blob.rezradius+0.5 then 
			blob.y = blob.rezradius+0.5
			blob.vy = -blob.vy
		elseif blob.y > map_height-blob.rezradius-0.5 then
			blob.y = map_height-blob.rezradius-0.5
			blob.vy = -blob.vy
		end
		
	end
end

function draw_rectangle (mode, x, y)
	
end

function dist(x1, y1, x2, y2)
	return math.sqrt((x2-x1)^2+(y2-y1)^2)
end

function love.draw()
	for i = 1, map_width do
		for j = 1, map_height do
			local c = 0
			for n, blob in pairs (blobs) do
				local d = dist(i, j, blob.x, blob.y)
				c = c + (1/(2*rez))*blob.radius/d
				
			end
			love.graphics.setColor(c,c,c)
			love.graphics.rectangle('fill', rez*(i-1/2), rez*(j-1/2), rez, rez)
		end
	end
	love.graphics.setColor(0,0,1)
	love.graphics.rectangle('line', 0.5*rez, 0.5*rez, rez*map_width, rez*map_height)
	
--	for n, blob in pairs (blobs) do
--		love.graphics.circle('line', blob.x*rez, blob.y*rez, blob.radius)
--	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end