-- 2021-04-22 License CC0 (Creative Commons license) (c) darkfrei
window = require ("zoom-and-move-window")

function love.load()
	window:load()

	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
		print('ddheight: ' .. ddheight)
--		love.window.setMode(1920, 1080, {resizable=false, borderless=true})
--		love.window.setMode(1920*1.5+130+130, 1080*1.5, {resizable=true, borderless=false})
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	
	width, height = love.graphics.getDimensions( )
	
	local a = 2048
	canvas = love.graphics.newCanvas(20+2*a, 20+a)
--	canvas:setFilter("nearest", "nearest")
	
	mpoints = {}
	mpoints[1] = {x = a +	10, 	y=  10}
--	mpoints[2] = {x = a+	10,	y=a+10}
	mpoints[2] = {x = 		10,	y=a+10}
	mpoints[3] = {x = a*2+	10,	y=a+10}
	
	print ((mpoints[1].x-mpoints[2].x)..' '.. -(mpoints[1].y-mpoints[2].y))
	print ((mpoints[1].x-mpoints[3].x)..' '.. -(mpoints[1].y-mpoints[3].y))
	
	npoints = 3
	
	canvas:setFilter("nearest", "nearest")
	love.graphics.setCanvas(canvas)
--		love.graphics.clear()
		local points = {}
		for k = 1, 10000000 do
			local i = love.math.random(math.min(npoints, #mpoints))
			local j = #mpoints
			local c = 0.5
			local x = c*mpoints[i].x + (1-c)*mpoints[#mpoints].x
			local y = c*mpoints[i].y + (1-c)*mpoints[#mpoints].y
			local mpoint = {
				x=math.floor(x+0.0001),
				y=math.floor(y+0.0001)}
			
--			table.insert(mpoints, mpoint)
			if npoints > (#mpoints-1) then
				table.insert(mpoints, mpoint)
			else
				mpoints[#mpoints] = mpoint
			end
			table.insert(points, mpoint.x)
			table.insert(points, mpoint.y)
		end
		love.graphics.points(points)
	love.graphics.setCanvas()
end

 
function love.update(dt)
	window:update(dt)

end


function love.draw()
	window:draw()
	love.graphics.draw(canvas)
	love.graphics.print(npoints..' '..#mpoints)
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end


function love.wheelmoved(x, y)
	window:wheelmoved(x, y)
end


function love.mousepressed(x, y, button, istouch)
	window:mousepressed(x, y, button, istouch)
end

