-- darkfrei, 2020-11-22
require("rays")

function love.load()
	-- example closed (or not closed) line:
	line = {
		50,50, 
		750, 500, 
		700, 500, 
		200, 350, 
		100, 500, 
		100, 300, 
		50, 250, 
		50,50}
	
	-- example ray (click to change the source point):
--	ray = {x=400, y=300, r=400, w=0, speed = 0.5, x2=0, y2=0}
	ray = rays:new()
end
 

function love.update(dt)
--	local target = {x = 500, y=500}
--	local angle = ray.angle + 0.1
	ray:update(dt, {line})

end



 
function love.draw()
	-- draws the example line
	love.graphics.setColor(1,1,0)
	love.graphics.line(line)
	
	rays:draw ()
	
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end


function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then
		ray.position = {x=x, y=y}
	elseif button == 2 then
--		ray.target = {x=x, y=y}
		ray.angle = math.atan2(y-ray.position.y, x-ray.position.x)
	end
end