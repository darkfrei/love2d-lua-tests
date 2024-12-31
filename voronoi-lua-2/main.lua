--
-- the other try to make voronoi;
-- now it's the Fortunes algorithm in the given polygon;
-- work in process
-- now circle event
-- main.lua

local voronoi = require ('voronoi')

local diagram = nil

local voro

function love.load()
	-- Create a new Voronoi object
	voro = voronoi.new()

	local polygon = {
		{x = 100, y = 100},
		{x = 700, y = 100},
		{x = 700, y = 500},
		{x = 100, y = 500}
	}
	voro:addPolygon(polygon)




	-- Add multiple sites
	voro:addSites({
			{x = 200, y = 200},
			{x = 600, y = 200},
			{x = 400, y = 300},
			{x = 650, y = 310},
		})



	voro:processEvents()

end


local camera = {
	x = 0, -- initial camera position on x-axis
	y = 0, -- initial camera position on y-axis
	speed = 5 * 60, -- camera movement speed
}


function love.update(dt)
	-- check for arrow key presses to move the camera
	if love.keyboard.isDown("right") then
		camera.x = camera.x + camera.speed * dt
	end
	if love.keyboard.isDown("left") then
		camera.x = camera.x - camera.speed * dt
	end
	if love.keyboard.isDown("down") then
		camera.y = camera.y + camera.speed * dt
	end
	if love.keyboard.isDown("up") then
		camera.y = camera.y - camera.speed * dt
	end
end


function love.draw()
	love.graphics.translate(-camera.x, -camera.y)

	voro:draw()
end

function love.mousepressed (x, y, b)
	if b == 1 then
		voro:addSite({x = x, y = y})
	else
		voro.sweepLineY = y
		
	end
end
