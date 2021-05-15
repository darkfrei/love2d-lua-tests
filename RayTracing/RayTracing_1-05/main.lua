-- darkfrei, 2020-11-25
rays = require("rays")

function love.load()
	 -- example closed yellow line:
	line1 = {
		50,50, 
		50, 550, 
		550, 550, 
		550, 50, 
		50,50}
	
	 -- example not closed red line
--	line2 = {
--		20, 50,
--		20, 420,
--		420, 420,
--		320, 520,
--		120, 520,
--		120, 200,
--		}
	
	ray1 = rays:new({name = "ray1", color = {0, 1, 0},position = {x=250, y=250}}) -- green
	print (ray1.name)
	ray2 = rays:new({name = "ray2", color = {0, 1, 1}}) -- cyan
	print (ray1.name)
	print (ray2.name)
end
 

function love.update(dt)
	ray1.angle = math.atan2(love.mouse.getY()-ray1.position.y, love.mouse.getX()-ray1.position.x)
	ray1:update (dt, {line1, line2})
	
	if ray1.point then
--		print ('point1')
		ray2.angle = math.atan2(ray1.point.y-ray2.position.y, ray1.point.x-ray2.position.x)
		ray2:update(dt, {line1, line2})
	end
end



 
function love.draw()
	-- draws the example line
	love.graphics.setColor(1,1,0) -- closed yellow line
	love.graphics.line(line1)
--	love.graphics.setColor(1,0,0) -- not closed red line
--	love.graphics.line(line2)
	
	ray1:draw (true) -- green ray, with text
--	ray2:draw () -- cyan ray
	
	love.graphics.setColor(1,1,1)
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

-- change the ray position
function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then
		ray1.position = {x=x, y=y}
	elseif button == 2 then
		ray2.position = {x=x, y=y}
	end
end